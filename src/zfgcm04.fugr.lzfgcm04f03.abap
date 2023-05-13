*&---------------------------------------------------------------------*
*&  Include           LZCM_DOIF03
*&---------------------------------------------------------------------*

FORM FRM_GET_GLOBE_FCAT USING IS_LAYOUT_LVC TYPE LVC_S_LAYO
                              IS_VARIANT LIKE DISVARIANT
                              .


  DATA: LS_FCAT TYPE LVC_S_FCAT.
  DATA: LT_FCAT TYPE LVC_T_FCAT. "存放列表的名称
  DATA: I_LAYOUT TYPE SLIS_LAYOUT_ALV.
  DATA: LT_COMPLETE_FCAT TYPE SLIS_T_FIELDCAT_ALV,
        LT_COMPLETE_FCAT2 TYPE SLIS_T_FIELDCAT_ALV,
        LS_COMPLETE_FCAT LIKE LINE OF LT_COMPLETE_FCAT.
  DATA: LS_VARIANT TYPE DISVARIANT.

  CHECK GV_ACT_VAR = 'X'.

  LS_VARIANT = IS_VARIANT.

  CALL FUNCTION 'LVC_TRANSFER_TO_SLIS'
    EXPORTING
      IT_FIELDCAT_LVC = GT_FCAT
    IMPORTING
      ET_FIELDCAT_ALV = LT_COMPLETE_FCAT.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  REFRESH:GT_FCAT[].

  MOVE-CORRESPONDING IS_LAYOUT_LVC TO I_LAYOUT.

  CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
    EXPORTING
   I_DIALOG                  = ''
   I_USER_SPECIFIC           = 'X'
      IT_DEFAULT_FIELDCAT       = LT_COMPLETE_FCAT
      I_LAYOUT                  = I_LAYOUT
 IMPORTING
*   E_EXIT                    =
   ET_FIELDCAT               = LT_COMPLETE_FCAT2
*   ET_SORT                   =
*   ET_FILTER                 =
*   ES_LAYOUT                 =
    CHANGING
      CS_VARIANT                = LS_VARIANT
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV       =  LT_COMPLETE_FCAT2
*   IT_SORT_ALV           =
*   IT_FILTER_ALV         =
*   IS_LAYOUT_ALV         =
   IMPORTING
     ET_FIELDCAT_LVC       = GT_FCAT
*   ET_SORT_LVC           =
*   ET_FILTER_LVC         =
*   ES_LAYOUT_LVC         =
    TABLES
      IT_DATA               = LT_COMPLETE_FCAT
* EXCEPTIONS
*   IT_DATA_MISSING       = 1
*   OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*
*  LOOP AT LT_COMPLETE_FCAT2 INTO LS_COMPLETE_FCAT.
*    MOVE-CORRESPONDING LS_COMPLETE_FCAT TO LS_FCAT.
*    APPEND LS_FCAT TO GT_FCAT.
*    CLEAR:LS_COMPLETE_FCAT,LS_FCAT.
*  ENDLOOP.



ENDFORM.                    "FRM_GET_GLOBE_FCAT

*&---------------------------------------------------------------------*
*&      Form  FRM_CREAT_DYNAMIC_EXCEL_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CREAT_DYNAMIC_EXCEL_HEADER .

  DATA: LV_LANGU TYPE SY-LANGU.
  DATA: LT_FCAT TYPE LVC_T_FCAT. "存放列表的名称
  DATA: LS_FCAT TYPE LVC_S_FCAT. "存放列表的名称
  DATA: LS_FCAT_OLD TYPE LVC_S_FCAT. "存放列表的名称

  DATA: DY_TABLE_HEADER TYPE REF TO DATA,
        DY_TABLE_ITEM TYPE REF TO DATA,
        DY_WA_HEADER TYPE REF TO DATA.
  FIELD-SYMBOLS: <DYN_WA_HEADER> TYPE ANY,
               <FS> TYPE ANY.

  CHECK GV_NO_HEADER = ''.
  DATA: LV_INDEX TYPE SY-TABIX.

  LOOP AT GT_FCAT INTO LS_FCAT.
    LS_FCAT-DATATYPE = 'CHAR'.
    LS_FCAT-INTTYPE = 'C'.
    LS_FCAT-INTLEN = 20.
    LS_FCAT-DD_OUTLEN = 20.
    CLEAR:LS_FCAT-DOMNAME,LS_FCAT-CONVEXIT,LS_FCAT-REF_TABLE,LS_FCAT-REF_FIELD.
    APPEND LS_FCAT TO LT_FCAT.
    CLEAR:LS_FCAT.
  ENDLOOP.

  DESCRIBE TABLE LT_FCAT LINES GV_EXCEL_COLUMN.

*此方法用于构建动态内表，输入=构建的结构，输出=dy_table
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = LT_FCAT
    IMPORTING
      EP_TABLE        = DY_TABLE_HEADER.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = LT_FCAT
    IMPORTING
      EP_TABLE        = DY_TABLE_ITEM.


  ASSIGN DY_TABLE_HEADER->* TO <DYN_TABLE_HEADER>.
  ASSIGN DY_TABLE_ITEM->* TO <DYN_TABLE_ITEM>.
  CREATE DATA DY_WA_HEADER LIKE LINE OF <DYN_TABLE_HEADER>.
  ASSIGN DY_WA_HEADER->* TO <DYN_WA_HEADER>.

  SORT LT_FCAT BY COL_POS.

  LOOP AT LT_FCAT INTO LS_FCAT.
    LV_INDEX = SY-TABIX.
    READ TABLE GT_FCAT_OLD INTO LS_FCAT_OLD WITH KEY FIELDNAME = LS_FCAT-FIELDNAME.
    IF SY-SUBRC = 0.
      ASSIGN COMPONENT LV_INDEX OF STRUCTURE <DYN_WA_HEADER> TO <FS>. "assign update flag to excel
      <FS> = LS_FCAT_OLD-COL_POS.
    ENDIF.

  ENDLOOP.
  APPEND <DYN_WA_HEADER> TO <DYN_TABLE_HEADER>.

  LOOP AT LT_FCAT INTO LS_FCAT.
    ASSIGN COMPONENT SY-TABIX OF STRUCTURE <DYN_WA_HEADER> TO <FS>. "assign update flag to excel
    <FS> = LS_FCAT-FIELDNAME.
  ENDLOOP.
  APPEND <DYN_WA_HEADER> TO <DYN_TABLE_HEADER>.


  LOOP AT LT_FCAT INTO LS_FCAT.
    ASSIGN COMPONENT SY-TABIX OF STRUCTURE <DYN_WA_HEADER> TO <FS>. "assign update flag to excel
    <FS> = LS_FCAT-REPTEXT.
  ENDLOOP.
  APPEND <DYN_WA_HEADER> TO <DYN_TABLE_HEADER>.

ENDFORM.                    "FRM_CREAT_DYNAMIC_EXCEL_HEADER


*&---------------------------------------------------------------------*
*&      Form  FRM_FILL_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  IR_CONTROL        Container Control
*  -->  IR_PROXY          General Document
*  -->  IR_SPREADSHEET    Spreadsheet
*----------------------------------------------------------------------*
FORM FRM_FILL_EXCEL_OUTTAB
        USING IR_CONTROL     TYPE REF TO I_OI_CONTAINER_CONTROL
              IR_PROXY       TYPE REF TO I_OI_DOCUMENT_PROXY
              IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
              .

  DATA: L_STR TYPE STRING,
        L_ANGDT(20).
  DATA: LV_LENS TYPE SY-TABIX.

* Copy模版
*  L_STR = L_BEG_ROW.
  CONCATENATE 'A' L_STR INTO L_STR.
  PERFORM FRM_COPY_TEMPLATE USING IR_PROXY L_STR.

  PERFORM FRM_INSERT_TABLE_RANGE USING IR_SPREADSHEET 2 2 <DYN_TABLE_HEADER> 1 GV_EXCEL_COLUMN.

*  DESCRIBE TABLE <DYN_TABLE_ITEM> LINES LV_LENS.

*  IF LV_LENS <= 999.
    PERFORM FRM_INSERT_TABLE_RANGE USING IR_SPREADSHEET 5 2 <DYN_TABLE_ITEM> 1 GV_EXCEL_COLUMN.
*  ENDIF.


ENDFORM.                    " FRM_FILL_EXCEL

*&---------------------------------------------------------------------*
*&      Form  FRM_CHANGE_STRUCTURE_FACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CHANGE_STRUCTURE_FACT.

  DATA: LS_FCAT LIKE LINE OF GT_FCAT_OLD.

  IF GT_FCAT_OLD IS INITIAL AND GV_STRUCTURE_NAME IS NOT INITIAL.


    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME       = GV_STRUCTURE_NAME
      CHANGING
        CT_FIELDCAT            = GT_FCAT_OLD[]
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.

  ENDIF.

*  LOOP AT GT_FCAT_OLD INTO LS_FCAT.
*    IF LS_FCAT-DATATYPE = 'DATS'.
*      LS_FCAT-DATATYPE = 'CHAR'.
*      LS_FCAT-INTTYPE = 'C'.
*    ENDIF.
*    IF LS_FCAT-DATATYPE = 'CURR'.
*      LS_FCAT-DATATYPE = 'CHAR'.
*      LS_FCAT-INTTYPE = 'C'.
*    ENDIF.
*
*    MODIFY GT_FCAT_OLD FROM LS_FCAT.
*    CLEAR:LS_FCAT.
*  ENDLOOP.


*  not change gt_fact when act_variant = ''
  GT_FCAT[] = GT_FCAT_OLD[].

ENDFORM.                    "FRM_CHANGE_STRUCTURE_FACT

*&---------------------------------------------------------------------*
*&      Form  FRM_CHANGE_OUTTAB_DYNOUTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CREAT_DYNAMIC_ITEM.

  IF GV_ACT_VAR = 'X'.
    PERFORM FRM_CHANGE_STAND_DYN_ITEM.

  ELSE.
    ASSIGN <GLB_TABLE_ITEM> TO <DYN_TABLE_ITEM>.
  ENDIF.




ENDFORM.                    "FRM_CHANGE_STRUCTURE_FACT

*&---------------------------------------------------------------------*
*&      Form  FRM_CHANGE_STAND_DYN_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CHANGE_STAND_DYN_ITEM.
  BREAK SUNHM.
  FIELD-SYMBOLS: <DYN_WA_GLB_ITEM> TYPE ANY.
  FIELD-SYMBOLS: <DYN_WA_DYN_ITEM> TYPE ANY.
  DATA: DY_WA_GLB_ITEM TYPE REF TO DATA,
        DY_WA_DYN_ITEM TYPE REF TO DATA.
  CREATE DATA DY_WA_GLB_ITEM LIKE LINE OF <GLB_TABLE_ITEM>.
  CREATE DATA DY_WA_DYN_ITEM LIKE LINE OF <DYN_TABLE_ITEM>.
  ASSIGN DY_WA_GLB_ITEM->* TO <DYN_WA_GLB_ITEM>.
  ASSIGN DY_WA_DYN_ITEM->* TO <DYN_WA_DYN_ITEM>.

  LOOP AT <GLB_TABLE_ITEM> ASSIGNING <DYN_WA_GLB_ITEM>.
    MOVE-CORRESPONDING <DYN_WA_GLB_ITEM> TO <DYN_WA_DYN_ITEM>.
    APPEND <DYN_WA_DYN_ITEM> TO <DYN_TABLE_ITEM>.
  ENDLOOP.
ENDFORM.                    "FRM_CHANGE_STAND_DYN_ITEM
