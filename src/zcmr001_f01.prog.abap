*&---------------------------------------------------------------------*
*&  Include           ZINCL_BDC_UPLOAD
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  upload_data
*&---------------------------------------------------------------------*
*       上载数据
*----------------------------------------------------------------------*
FORM FRM_UPLOAD_DATA USING I_FILENAME TYPE RLGRAP-FILENAME.
  DATA: LT_UPLOAD_I TYPE TABLE OF ALSMEX_TABLINE,
        LS_UPLOAD_I TYPE ALSMEX_TABLINE.

  DATA: LT_UPLOAD_H TYPE TABLE OF ALSMEX_TABLINE,
      LS_UPLOAD_H TYPE ALSMEX_TABLINE.

  DATA: LV_TCODE TYPE TCODE.

  DATA: LT_RETURN TYPE TABLE OF BAPIRET2,
        LS_RETURN TYPE BAPIRET2.

  DATA: CTU_PARAMS TYPE CTU_PARAMS.

  DATA: LT_BDC_TAB TYPE BDCDATA_TAB.

  DATA: LV_COL TYPE I .

  FIELD-SYMBOLS:<FS_BDC_TAB> TYPE BDCDATA.
  DATA: LV_INDEX TYPE INDEX.
  DATA: LV_ROW TYPE CHAR4.
  DATA: LT_FCAT TYPE LVC_T_FCAT. "存放列表的名称

  CALL FUNCTION 'ZCM_GET_BDC' "Get SHDB Item Function
    EXPORTING
      NAME          = P_GRPID
    IMPORTING
      CTU_PARAMS    = CTU_PARAMS
      TCODE         = LV_TCODE
    TABLES
      BDC_TAB       = GT_GLOBE_BDC_TAB
      BDC_FCAT      = GT_GLOBE_BDC_FCAT
      BDC_TAB_FIELD = GT_GLOBE_BDC_TAB_FIELD.

  IF CTU_PARAMS-RACOMMIT <> P_COMMIT.
    CTU_PARAMS-RACOMMIT = P_COMMIT.
  ENDIF.

  DESCRIBE TABLE GT_GLOBE_BDC_TAB_FIELD LINES LV_COL.
  LV_COL = LV_COL + 1.

* Upload excel Head data
  PERFORM FRM_EXCEL_TO_ITAB USING I_FILENAME 2 3 LV_COL 3
                         CHANGING LT_UPLOAD_H.

* Upload excel Item data
  PERFORM FRM_EXCEL_TO_ITAB USING I_FILENAME 2 5 LV_COL 65536
                         CHANGING LT_UPLOAD_I.

  LT_BDC_TAB[] = GT_GLOBE_BDC_TAB.

*  process bdc from excel template
  LOOP AT LT_UPLOAD_I INTO LS_UPLOAD_I.
    READ TABLE LT_UPLOAD_H INTO LS_UPLOAD_H WITH KEY COL = LS_UPLOAD_I-COL.
    IF SY-SUBRC = 0.
      LV_INDEX = LS_UPLOAD_H-VALUE.
      READ TABLE LT_BDC_TAB ASSIGNING <FS_BDC_TAB> INDEX LV_INDEX.
      IF SY-SUBRC = 0.
        <FS_BDC_TAB>-FVAL = LS_UPLOAD_I-VALUE.
      ENDIF.

    ENDIF.
    LV_ROW = LS_UPLOAD_I-ROW + 4.
    AT END OF ROW.

      CALL FUNCTION 'ZCM_CALL_BDC'   "Call tcode used SHDB items
        EXPORTING
          NAME             = P_GRPID
          TCODE            = LV_TCODE
          CTU_PARAMS       = CTU_PARAMS
        TABLES
          BDC_TAB          = LT_BDC_TAB
          RETURN           = LT_RETURN
                .

**    check bapi success
      READ TABLE LT_RETURN INTO LS_RETURN WITH KEY TYPE = 'E'.
      IF SY-SUBRC = 0.
        PERFORM FRM_RETURN_MSG USING 'E' LT_RETURN LV_ROW.
      ELSE.
        PERFORM FRM_RETURN_MSG USING 'S' LT_RETURN LV_ROW.
      ENDIF.

      REFRESH:LT_BDC_TAB[].
      REFRESH:LT_RETURN[].
      LT_BDC_TAB[] = GT_GLOBE_BDC_TAB.
    ENDAT.
    CLEAR:LS_UPLOAD_I,LS_UPLOAD_H.
  ENDLOOP.


*  show alv
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'BAPIRET2'
    CHANGING
      CT_FIELDCAT            = LT_FCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      I_SAVE             = 'A'
      IT_FIELDCAT_LVC    = LT_FCAT
    TABLES
      T_OUTTAB           = GT_GLOBE_BDC_RETURN
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.



ENDFORM.                    " upload_data

*&---------------------------------------------------------------------*
*&      Form  FRM_ERRO_MSG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_TYID     text
*      -->I_MESSAGE  text
*      -->I_TYMES    text
*----------------------------------------------------------------------*
FORM FRM_RETURN_MSG USING LV_FLAG TYPE CHAR1 LT_RETURN TYPE BAPIRET2_T LV_ROW TYPE CHAR4.

  DATA: ES_RETURN LIKE BAPIRET2.
  DATA: LS_RETURN LIKE BAPIRET2.
  LS_RETURN-TYPE = LV_FLAG.

  CONCATENATE 'excel line of' LV_ROW INTO LS_RETURN-ID.

  LOOP AT LT_RETURN INTO ES_RETURN WHERE TYPE = LV_FLAG.
    CONCATENATE LS_RETURN-MESSAGE ES_RETURN-MESSAGE INTO LS_RETURN-MESSAGE.
    CONCATENATE LS_RETURN-MESSAGE_V1 ES_RETURN-MESSAGE_V1 INTO LS_RETURN-MESSAGE_V1.
    CONCATENATE LS_RETURN-MESSAGE_V2 ES_RETURN-MESSAGE_V2 INTO LS_RETURN-MESSAGE_V2.
    CONCATENATE LS_RETURN-MESSAGE_V3 ES_RETURN-MESSAGE_V3 INTO LS_RETURN-MESSAGE_V3.
    CONCATENATE LS_RETURN-MESSAGE_V4 ES_RETURN-MESSAGE_V4 INTO LS_RETURN-MESSAGE_V4.
  ENDLOOP.

  APPEND LS_RETURN TO GT_GLOBE_BDC_RETURN.
  CLEAR:LS_RETURN.

ENDFORM.                    "FRM_ERRO_MSG
