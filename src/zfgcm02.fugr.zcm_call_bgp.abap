FUNCTION ZCM_CALL_BGP.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_BKPARA) TYPE  ZCM_IN_CALL_BGP
*"     VALUE(UUID) TYPE  SYSUUID_C OPTIONAL
*"     VALUE(RECALL) TYPE  CHAR1 OPTIONAL
*"  TABLES
*"      IT_RSPARAMS STRUCTURE  RSPARAMS
*"----------------------------------------------------------------------


  DATA: LV_TIMES TYPE ORA_SECONDS_IN_WAIT.

*  Clear Globe Background Program Variable
  REFRESH:GT_GLOBE_RSPARAMS[].
  CLEAR:GS_GLOBE_BKPARA.

*  Fill in Globe Background Parameter
  GT_GLOBE_RSPARAMS[] = IT_RSPARAMS[].
  GS_GLOBE_BKPARA = IS_BKPARA.
  GV_GLOBE_BGP_RECALL = RECALL.

*  Create Log
  CREATE OBJECT GO_LOG_UPDATE
    EXPORTING
      SOUR_UUID = UUID.

  MOVE-CORRESPONDING GS_GLOBE_BKPARA TO GO_LOG_UPDATE->GS_LOG_HEADER.
  GV_LOG_UUID = GO_LOG_UPDATE->GS_LOG_HEADER-UUID.


  IF GS_GLOBE_BKPARA-LANGU <> ''.
    SET LOCALE LANGUAGE GS_GLOBE_BKPARA-LANGU.
  ENDIF.

  IF GS_GLOBE_BKPARA-IMMED = 'X'.
    MOVE SPACE TO: GS_GLOBE_BKPARA-STIME, GS_GLOBE_BKPARA-SDATE.
  ENDIF.

  IF GS_GLOBE_BKPARA-JOBCOUNT IS INITIAL.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        JOBNAME          = GS_GLOBE_BKPARA-JOBNAME
        SDLSTRTDT        = GS_GLOBE_BKPARA-SDATE
        SDLSTRTTM        = GS_GLOBE_BKPARA-STIME
      IMPORTING
        JOBCOUNT         = GS_GLOBE_BKPARA-JOBCOUNT
      EXCEPTIONS
        CANT_CREATE_JOB  = 1
        INVALID_JOB_DATA = 2
        JOBNAME_MISSING  = 3
        OTHERS           = 4.

  ENDIF.

  IF GS_GLOBE_BKPARA-UNAME = ''.
    GS_GLOBE_BKPARA-UNAME = 'ADMIN'.
  ENDIF.


*  Summit Background job
  SUBMIT (GS_GLOBE_BKPARA-PROGNAME)
  WITH SELECTION-TABLE  GT_GLOBE_RSPARAMS
  USER GS_GLOBE_BKPARA-UNAME
  VIA JOB GS_GLOBE_BKPARA-JOBNAME
  NUMBER GS_GLOBE_BKPARA-JOBCOUNT
  AND RETURN.

  IF SY-SUBRC = 0.
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        JOBCOUNT             = GS_GLOBE_BKPARA-JOBCOUNT
        JOBNAME              = GS_GLOBE_BKPARA-JOBNAME
        SDLSTRTDT            = GS_GLOBE_BKPARA-SDATE
        SDLSTRTTM            = GS_GLOBE_BKPARA-STIME
        STRTIMMED            = GS_GLOBE_BKPARA-IMMED
      EXCEPTIONS
        CANT_START_IMMEDIATE = 1
        INVALID_STARTDATE    = 2
        JOBNAME_MISSING      = 3
        JOB_CLOSE_FAILED     = 4
        JOB_NOSTEPS          = 5
        JOB_NOTEX            = 6
        LOCK_FAILED          = 7
        OTHERS               = 8.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

*  check program recall staute
  LV_TIMES = GS_GLOBE_BKPARA-SECONDS + 30.
  DATA: LS_V_OP TYPE V_OP.
  DATA: LS_ZPFB_HLOG TYPE ZCMT0001.

* Wait Backupground Program Running Finished when Parameter RECALL = 'X'
  CHECK GV_GLOBE_BGP_RECALL = 'X'.

  DO LV_TIMES TIMES.
*    Check Job Finished
    SELECT SINGLE *
      FROM V_OP
      INTO LS_V_OP
      WHERE JOBCOUNT = GS_GLOBE_BKPARA-JOBCOUNT
      AND JOBNAME = GS_GLOBE_BKPARA-JOBNAME
      .

    IF LS_V_OP-STATUS = 'F'.
      DO GS_GLOBE_BKPARA-SECONDS TIMES.
        SELECT SINGLE * FROM ZCMT0001 INTO LS_ZPFB_HLOG WHERE SOUR_UUID = UUID AND PROGNAME <> SY-CPROG.
        IF SY-SUBRC <> 0.
          EXIT.
        ELSE.
          WAIT UP TO 1 SECONDS.
        ENDIF.
      ENDDO.
      IF LS_ZPFB_HLOG-STATE <> 'A'.
        EXIT.
      ENDIF.
    ELSE.
      WAIT UP TO 1 SECONDS.
    ENDIF.

  ENDDO.


  SELECT SINGLE *
    INTO LS_ZPFB_HLOG
    FROM ZCMT0001
    WHERE SOUR_UUID = UUID
    AND PROGNAME <> SY-CPROG
    .

  IF LS_ZPFB_HLOG-STATE = 'A'.

    GO_LOG_UPDATE->GS_MESSAGE-MESSAGE = '未知错误，请检查后台程序'.
    GO_LOG_UPDATE->GS_MESSAGE-TYPE = 'E'.

  ELSE.
    GO_LOG_UPDATE->GS_MESSAGE-MESSAGE = LS_ZPFB_HLOG-MSG.
    GO_LOG_UPDATE->GS_MESSAGE-TYPE = LS_ZPFB_HLOG-STATE.
  ENDIF.

  UPDATE ZCMT0001
     SET SOUR_UUID = GV_LOG_UUID
   WHERE UUID = LS_ZPFB_HLOG-UUID
        .

  CALL METHOD GO_LOG_UPDATE->MT_UPDATE_LOG_STATE.



ENDFUNCTION.
