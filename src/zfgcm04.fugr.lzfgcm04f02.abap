*&---------------------------------------------------------------------*
*&  Include           LZCM_DOIF02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZINCL_BDC_UPLOAD
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  upload_data
*&---------------------------------------------------------------------*
*       上载数据
*----------------------------------------------------------------------*
FORM FRM_UPLOAD_DATA USING I_FILENAME TYPE RLGRAP-FILENAME.

  DATA: LT_UPLOAD TYPE TABLE OF ALSMEX_TABLINE,
        LS_UPLOAD TYPE ALSMEX_TABLINE.
  DATA: LV_INDEX TYPE SY-INDEX.

  DATA: LS_FCAT TYPE LVC_S_FCAT. "存放列表的名称
  DATA: LV_LEN TYPE I.
  FIELD-SYMBOLS: <DYN_WA> TYPE ANY,
               <FS> TYPE ANY.
  DATA:DY_WA TYPE REF TO DATA.

  DATA: BEGIN_COL TYPE I,
        BEGIN_ROW TYPE I,
        END_COL   TYPE I,
        END_ROW   TYPE I.

  BEGIN_COL = GS_UPOPTIONS-BEGIN_COL.
  BEGIN_ROW = GS_UPOPTIONS-BEGIN_ROW.
  END_COL = GS_UPOPTIONS-END_COL.
  END_ROW = GS_UPOPTIONS-END_ROW.

  PERFORM FRM_EXCEL_TO_ITAB USING I_FILENAME BEGIN_COL BEGIN_ROW END_COL END_ROW
                         CHANGING LT_UPLOAD.

  PERFORM FRM_CREAT_DYN_TABLE.

  CREATE DATA DY_WA LIKE LINE OF <DYN_UPLOAD_TABLE>.
  ASSIGN DY_WA->* TO <DYN_WA>.

  LOOP AT LT_UPLOAD INTO LS_UPLOAD.
    READ TABLE GT_FCAT INTO LS_FCAT WITH KEY COL_POS = LS_UPLOAD-COL.
    IF SY-SUBRC = 0.
      LV_INDEX = LS_UPLOAD-COL.
      ASSIGN COMPONENT LV_INDEX OF STRUCTURE <DYN_WA> TO <FS>. "assign bdc value to excel
* Callback
      IF NOT G_CALLBACK_CHECK_FIELD IS INITIAL.
        PERFORM (G_CALLBACK_CHECK_FIELD)
                IN PROGRAM (G_CALLBACK_PROGRAM)
                USING LS_FCAT
                      CHANGING LS_UPLOAD-VALUE
                IF FOUND.
      ENDIF.
      IF LS_FCAT-DATATYPE = 'QUAN' OR LS_FCAT-DATATYPE = 'CURR'.
        CONDENSE LS_UPLOAD-VALUE NO-GAPS.
        REPLACE ALL OCCURRENCES OF ',' IN LS_UPLOAD-VALUE WITH ''.
      ENDIF.
      IF LS_FCAT-DATATYPE = 'DATS'.
        LV_LEN = CL_ABAP_LIST_UTILITIES=>DYNAMIC_OUTPUT_LENGTH( LS_UPLOAD-VALUE ).
        IF LV_LEN = 8.

        ELSEIF LV_LEN = 10.
          REPLACE ALL OCCURRENCES OF '.' IN LS_UPLOAD-VALUE WITH ''.
        ENDIF.
      ENDIF.
      <FS> = LS_UPLOAD-VALUE.
    ENDIF.
    AT END OF ROW.
      APPEND <DYN_WA> TO <DYN_UPLOAD_TABLE>.
      CLEAR <DYN_WA>.
    ENDAT.
  ENDLOOP.


ENDFORM.                    " upload_data
*&---------------------------------------------------------------------*
*&      Form  FRM_CREAT_DYN_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CREAT_DYN_TABLE.

  DATA: DY_TABLE TYPE REF TO DATA.




*此方法用于构建动态内表，输入=构建的结构，输出=dy_table
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT
    IMPORTING
      EP_TABLE        = DY_TABLE.


  ASSIGN DY_TABLE->* TO <DYN_UPLOAD_TABLE>.



ENDFORM.                    "FRM_CREAT_DYN_TABLE
