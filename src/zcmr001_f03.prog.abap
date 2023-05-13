*&---------------------------------------------------------------------*
*&  Include           ZCON_GET_BDCTABLE
*&---------------------------------------------------------------------*
FORM FRM_CLEAR_GLOBE_BDC_VAR.

  REFRESH:GT_GLOBE_BDC_TAB[],GT_GLOBE_BDC_FCAT[],GT_GLOBE_BDC_TAB_FIELD[],GT_GLOBE_BDC_RETURN[].
  CLEAR:GV_GLOBE_BDC_TCODE,GV_GLOBE_CTU_PARAMS,GV_GLOBE_BDC_NAME,GV_GLOBE_LOG_WADATA.

ENDFORM.                    "frm_clear_globe_bdc_var

*&---------------------------------------------------------------------*
*&      Form  frm_build_fcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->BDC_TAB    text
*----------------------------------------------------------------------*
FORM FRM_BUILD_FCAT TABLES BDC_TAB TYPE BDCDATA_TAB.

  DATA: LS_BDC_TAB TYPE BDCDATA,
        WA_STR TYPE LVC_S_FCAT.  "是一个Structure  用于存储即将构建的动态内表结构
  LOOP AT BDC_TAB.
    IF BDC_TAB-FNAM(4) = 'BDC_' OR BDC_TAB-FNAM = ''.

    ELSE.
      BDC_TAB-DYNPRO = SY-TABIX.
      APPEND BDC_TAB TO GT_GLOBE_BDC_TAB_FIELD.
    ENDIF.
    CLEAR:BDC_TAB.
  ENDLOOP.

  LOOP AT GT_GLOBE_BDC_TAB_FIELD INTO LS_BDC_TAB.

    WA_STR-FIELDNAME = LS_BDC_TAB-DYNPRO.
    WA_STR-COL_POS = 1.
    WA_STR-INTTYPE = 'CHAR'.
    WA_STR-INTLEN = 20.
    APPEND WA_STR TO GT_GLOBE_BDC_FCAT.
    CLEAR WA_STR.
    MODIFY GT_GLOBE_BDC_TAB_FIELD FROM LS_BDC_TAB.
    CLEAR:LS_BDC_TAB.

  ENDLOOP.

  DESCRIBE TABLE GT_GLOBE_BDC_FCAT LINES GV_GLOBE_BDC_EXCEL_COLUMN.

ENDFORM.                    "frm_build_fcat
*&---------------------------------------------------------------------*
*&      Form  RECORD_PLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_QUEUE_ID  text
*      -->P_NAME  text
*----------------------------------------------------------------------*
FORM FRM_GET_RECORD USING P_QUEUE_ID
                          P_NAME
                          P_MEMORY_ID
                          P_TCODE TYPE TCODE
                    CHANGING BDC_TAB TYPE BDCDATA_TAB
                      IS_PARAMS TYPE CTU_PARAMS
                      .
  DATA: L_DYNPROTAB LIKE BDCDATA OCCURS 1.
  DATA: LS_DYNPROTAB TYPE BDCDATA .

  DATA: OPT_SIMUBATCH TYPE C VALUE SPACE.


  DATA: BEGIN OF TRANS_TAB OCCURS 0.
          INCLUDE STRUCTURE BDCTH.
  DATA: END OF TRANS_TAB.
  DATA:   L_COUNT       LIKE SY-TABIX.

  L_COUNT = 1.
  IF P_QUEUE_ID IS NOT INITIAL.
    CALL FUNCTION 'BDC_OBJECT_READ'
         EXPORTING
              QUEUE_ID         = P_QUEUE_ID
*             datatype         = '%BDC'
         TABLES
              DYNPROTAB        = L_DYNPROTAB
         EXCEPTIONS
              NOT_FOUND        = 1
              SYSTEM_FAILURE   = 2
              INVALID_DATATYPE = 3
              OTHERS           = 4.
    IF SY-SUBRC >< 0.
      MESSAGE S627 WITH P_QUEUE_ID. EXIT.
    ENDIF.
  ENDIF.

  BDC_RECORD-QID = P_QUEUE_ID.
  BDC_RECORD-GROUPID = P_NAME.
  IS_PARAMS-DISMODE = 'N'.
  IS_PARAMS-UPDMODE = 'A'.
  IS_PARAMS-CATTMODE = ''.
  IS_PARAMS-RACOMMIT = ''.
  IS_PARAMS-NOBINPT = ''.
  IS_PARAMS-NOBIEND = ''.
  IS_PARAMS-DEFSIZE = 'X'.

  READ TABLE L_DYNPROTAB INTO LS_DYNPROTAB WITH KEY DYNBEGIN = 'T'.
  IF SY-SUBRC = 0.
    P_TCODE = LS_DYNPROTAB-FNAM.
  ENDIF.


  IF P_MEMORY_ID <> SPACE.
    EXPORT BDC_TAB TO MEMORY ID P_MEMORY_ID.
  ENDIF.

  IF OPT_SIMUBATCH = 'X'.
    TRANSLATE IS_PARAMS-DISMODE USING 'ADEHNQPS'.
  ENDIF.

  CALL FUNCTION 'BDC_RECORD_OPEN'
    EXPORTING
      NAME           = BDC_RECORD-GROUPID
      QUEUE_ID       = BDC_RECORD-QID
    TABLES
      TRANSACTIONS   = TRANS_TAB
      DYNPROTAB      = BDC_TAB
    EXCEPTIONS
      NOT_FOUND      = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    MESSAGE S627 WITH BDC_RECORD-QID.
    WRITE: / 'Interner Fehler'(001), '2'.
    STOP.
  ENDIF.

  CALL FUNCTION 'BDC_RECORD_GET'
    EXPORTING
      TRANSACTION_INDEX = L_COUNT
    TABLES
      DYNPROTAB         = BDC_TAB
    EXCEPTIONS
      INVALID_INDEX     = 1
      OTHERS            = 2.
  IF SY-SUBRC <> 0.
    WRITE: / 'Interner Fehler'(001), '3'.
    STOP.
  ENDIF.

  FIELD-SYMBOLS:<FS_TAB> TYPE TABLE.

ENDFORM.                    " RECORD_PLAY
*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_CTU_PARAMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CHECK_CTU_PARAMS.

  DATA: ITAB_APQI LIKE APQI OCCURS   0 WITH HEADER LINE.
  DATA: LT_BDC_TAB TYPE BDCDATA_TAB,
        LS_BDC_TAB TYPE BDCDATA.
  DATA: LV_MSG TYPE BAPI_MSG.
  DATA: LS_CTU_PARAMS TYPE CTU_PARAMS.
  DATA: LV_TCODE TYPE TCODE.

  DATA: WA_STR TYPE LVC_S_FCAT.  "是一个Structure  用于存储即将构建的动态内表结构

  CALL FUNCTION 'BDC_OBJECT_SELECT'
    EXPORTING
      NAME    = GV_GLOBE_BDC_NAME
    TABLES
      APQITAB = ITAB_APQI
    EXCEPTIONS
      OTHERS  = 1.
  IF SY-SUBRC <> 0.
    MESSAGE A604 WITH 'BDC_OBJECT_SELECT' SY-SUBRC.
    CONCATENATE 'Internal error: Fctn '  'BDC_OBJECT_SELECT' ', RC = ' '04' INTO LV_MSG.
    PERFORM FRM_ERRO_MSG USING 'E'  LV_MSG   .
  ENDIF.

  CHECK GT_GLOBE_BDC_RETURN[] IS INITIAL.

  CHECK GV_GLOBE_CTU_PARAMS IS INITIAL OR GV_GLOBE_BDC_TCODE IS INITIAL.

  READ TABLE ITAB_APQI INDEX 1.
  PERFORM FRM_GET_RECORD USING  ITAB_APQI-QID
                                ITAB_APQI-GROUPID
                                SPACE
                                LV_TCODE
                       CHANGING LT_BDC_TAB
                                LS_CTU_PARAMS
                            .

  LOOP AT LT_BDC_TAB INTO LS_BDC_TAB.
    IF LS_BDC_TAB-FNAM(4) = 'BDC_' OR LS_BDC_TAB-FNAM = ''.

    ELSE.
      LS_BDC_TAB-DYNPRO = SY-TABIX.
      APPEND LS_BDC_TAB TO GT_GLOBE_BDC_TAB_FIELD.
    ENDIF.
    CLEAR:LS_BDC_TAB.
  ENDLOOP.


  LOOP AT GT_GLOBE_BDC_TAB_FIELD INTO LS_BDC_TAB.

    WA_STR-FIELDNAME = LS_BDC_TAB-DYNPRO.
    WA_STR-COL_POS = 1.
    WA_STR-INTTYPE = 'CHAR'.
    WA_STR-INTLEN = 20.
    APPEND WA_STR TO GT_GLOBE_BDC_FCAT.
    CLEAR WA_STR.
    MODIFY GT_GLOBE_BDC_TAB_FIELD FROM LS_BDC_TAB.
    CLEAR:LS_BDC_TAB.

  ENDLOOP.

  DESCRIBE TABLE GT_GLOBE_BDC_FCAT LINES GV_GLOBE_BDC_EXCEL_COLUMN.

  IF GV_GLOBE_CTU_PARAMS IS INITIAL.
    MOVE-CORRESPONDING LS_CTU_PARAMS TO GV_GLOBE_CTU_PARAMS.
  ENDIF.

  IF GV_GLOBE_BDC_TCODE IS INITIAL.
    GV_GLOBE_BDC_TCODE = LV_TCODE.
  ENDIF.


ENDFORM.                    "FRM_CHECK_CTU_PARAMS
*&---------------------------------------------------------------------*
*&      Form  FRM_CALL_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CALL_BDC.

  DATA: BEGIN OF MESSTAB OCCURS 0.
          INCLUDE STRUCTURE BDCMSGCOLL.
  DATA: END OF MESSTAB.

  CHECK GT_GLOBE_BDC_RETURN[] IS INITIAL.

  CALL TRANSACTION GV_GLOBE_BDC_TCODE USING GT_GLOBE_BDC_TAB
                              OPTIONS FROM GV_GLOBE_CTU_PARAMS
                              MESSAGES INTO MESSTAB.

  CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
    TABLES
      IMT_BDCMSGCOLL = MESSTAB
      EXT_RETURN     = GT_GLOBE_BDC_RETURN[].

ENDFORM.                    "FRM_CALL_BDC

*&---------------------------------------------------------------------*
*&      Form  FRM_ERRO_MSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_TYMES    text
*      -->I_MESSAGE  text
*----------------------------------------------------------------------*
FORM FRM_ERRO_MSG USING I_TYMES TYPE CHAR1 I_MESSAGE TYPE BAPI_MSG .

  DATA: LS_RETURN LIKE BAPIRET2.

  LS_RETURN-TYPE = I_TYMES.
  LS_RETURN-MESSAGE = I_MESSAGE.

  APPEND LS_RETURN TO GT_GLOBE_BDC_RETURN.
  CLEAR:LS_RETURN.

ENDFORM.                    "FRM_ERRO_MSG
