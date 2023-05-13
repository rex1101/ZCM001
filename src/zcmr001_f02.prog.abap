*&---------------------------------------------------------------------*
*&  Include           ZINCL_BDC_DOWNLOAD
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  frm_select_bdc_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_SELECT_BDC_INFO.

  DATA: BEGIN OF BDC_TAB OCCURS 0.
          INCLUDE STRUCTURE BDCDATA.
  DATA: END OF BDC_TAB.
  DATA: RETURN TYPE TABLE OF BAPIRET2.
  DATA: CTU_PARAMS TYPE CTU_PARAMS.
  DATA: LV_TCODE TYPE TCODE.

  CALL FUNCTION 'ZCM_GET_BDC'
    EXPORTING
      NAME          = P_GRPID
    TABLES
      BDC_TAB       = GT_GLOBE_BDC_TAB
      BDC_FCAT      = GT_GLOBE_BDC_FCAT
      BDC_TAB_FIELD = GT_GLOBE_BDC_TAB_FIELD.


ENDFORM.                    "frm_select_bdc_info

*&---------------------------------------------------------------------*
*&      Form  FRM_DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->BDC_TAB    text
*----------------------------------------------------------------------*
FORM FRM_DOWNLOAD_BDC_TEMPLATE .

  DATA: DY_TABLE TYPE REF TO DATA,
        DY_WA TYPE REF TO DATA.

  FIELD-SYMBOLS: <DYN_WA> TYPE ANY,
                 <FS> TYPE ANY.

  DATA: LS_BDC_TAB TYPE BDCDATA.

*此方法用于构建动态内表，输入=构建的结构，输出=dy_table
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = GT_GLOBE_BDC_FCAT
    IMPORTING
      EP_TABLE        = DY_TABLE.

  DESCRIBE TABLE GT_GLOBE_BDC_FCAT LINES GV_GLOBE_BDC_EXCEL_COLUMN.

  ASSIGN DY_TABLE->* TO <DYN_GLOBE_TABLE>.
  CREATE DATA DY_WA LIKE LINE OF <DYN_GLOBE_TABLE>.
  ASSIGN DY_WA->* TO <DYN_WA>.

  LOOP AT GT_GLOBE_BDC_TAB_FIELD INTO LS_BDC_TAB.
    ASSIGN COMPONENT SY-TABIX OF STRUCTURE <DYN_WA> TO <FS>. "assign update flag to excel
    <FS> = 'X'.
  ENDLOOP.
  APPEND <DYN_WA> TO <DYN_GLOBE_TABLE>.

  LOOP AT GT_GLOBE_BDC_TAB_FIELD INTO LS_BDC_TAB.
    ASSIGN COMPONENT SY-TABIX OF STRUCTURE <DYN_WA> TO <FS>. "assign bdctable index to excel
    <FS> = LS_BDC_TAB-DYNPRO.
  ENDLOOP.
  APPEND <DYN_WA> TO <DYN_GLOBE_TABLE>.

  LOOP AT GT_GLOBE_BDC_TAB_FIELD INTO LS_BDC_TAB.
    ASSIGN COMPONENT SY-TABIX OF STRUCTURE <DYN_WA> TO <FS>. "assign bdc field name to excel
    <FS> = LS_BDC_TAB-FNAM.
  ENDLOOP.
  APPEND <DYN_WA> TO <DYN_GLOBE_TABLE>.

  LOOP AT GT_GLOBE_BDC_TAB_FIELD INTO LS_BDC_TAB.
    ASSIGN COMPONENT SY-TABIX OF STRUCTURE <DYN_WA> TO <FS>. "assign bdc value to excel
    <FS> = LS_BDC_TAB-FVAL.
  ENDLOOP.
  APPEND <DYN_WA> TO <DYN_GLOBE_TABLE>.

  DATA: LS_OPTIONS TYPE Zcm_DOIOPTS.

  DATA: LV_TMP_VALUE TYPE CHAR20.
  CONCATENATE P_GRPID 'BDC' INTO LV_TMP_VALUE.

  EXPORT LV_TMP_VALUE TO MEMORY ID 'Z_MID_DOWNLOAD'.

  CALL FUNCTION 'ZCM_EXCEL_DOWNLOAD'
    EXPORTING
      I_CLSNAM             = 'PICTURES'
      I_CLSTYP             = 'OT'
      I_TYPEID             = 'ZBDC'
      I_FILENA             = 'BDC_TEMPLATE.xls'
      I_CALLBACK_PROGRAM   = SY-REPID
      I_CALLBACK_FILL_DATA = 'FRM_FILL_EXCEL'
*      I_CALLBACK_NEXT      = 'FRM_PRINT_NEXT'
      I_TITLE              = '交货单单打印'
      IS_OPTIONS           = LS_OPTIONS
    EXCEPTIONS
      PROGRAM_ERROR        = 1
      OTHERS               = 2.



ENDFORM.                    "RECORD_PLAY


*&---------------------------------------------------------------------*
*&      Form  frm_row_change_column
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->BDC_TAB    text
*      -->DYN_TABLE  text
*----------------------------------------------------------------------*
FORM FRM_ROW_CHANGE_COLUMN TABLES BDC_TAB TYPE BDCDATA_TAB.
*                           DYN_TABLE.


ENDFORM.                    "frm_row_change_column

*&---------------------------------------------------------------------*
*&      Form  FRM_FILL_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  IR_CONTROL        Container Control
*  -->  IR_PROXY          General Document
*  -->  IR_SPREADSHEET    Spreadsheet
*----------------------------------------------------------------------*
FORM FRM_FILL_EXCEL
        USING IR_CONTROL     TYPE REF TO I_OI_CONTAINER_CONTROL
              IR_PROXY       TYPE REF TO I_OI_DOCUMENT_PROXY
              IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET.

  DATA: L_STR TYPE STRING,
        L_ANGDT(20).

* Copy模版
*  L_STR = L_BEG_ROW.
  CONCATENATE 'A' L_STR INTO L_STR.
  PERFORM FRM_COPY_TEMPLATE USING IR_PROXY L_STR.
*  L_BEG_ROW = L_BEG_ROW - 1.
  PERFORM FRM_INSERT_TABLE_RANGE USING IR_SPREADSHEET 2 2 <DYN_GLOBE_TABLE> 1 GV_GLOBE_BDC_EXCEL_COLUMN.

ENDFORM.                    " FRM_FILL_EXCEL
