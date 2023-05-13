*&---------------------------------------------------------------------*
*&  Include           LZFGCM05ALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           LZFGFI02ALV
*&---------------------------------------------------------------------*


DATA: G_UCOM  LIKE SY-UCOMM."屏幕元素
DATA: G_CPROG LIKE SY-CPROG.
DATA: G_OKCODE  LIKE SY-UCOMM.

DATA: GV_FCAT_STR TYPE DD02L-TABNAME.
DATA: GV_STATE TYPE CHAR1. " V:View E:edit P:Posting R:Reversve
DATA: GV_TCODE TYPE TCODE. "
*----------------------------------------------------------------------*
* LOCAL CLASSES: Definition
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.

    DATA: G_OBJECT_TEXT TYPE CHAR30.

    METHODS: CONSTRUCTOR
               IMPORTING E_OBJECT_TEXT TYPE C OPTIONAL.

    METHODS: HANDLE_DATA_CHANGED
               FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
               IMPORTING ER_DATA_CHANGED
                         E_ONF4
                         E_ONF4_BEFORE
                         E_ONF4_AFTER
                         E_UCOMM.

    METHODS: HANDLE_DATA_CHANGED_FINISHED
               FOR EVENT DATA_CHANGED_FINISHED OF CL_GUI_ALV_GRID
               IMPORTING E_MODIFIED
                         ET_GOOD_CELLS.

    METHODS: HANDLE_DOUBLE_CLICK
               FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
               IMPORTING E_ROW
                         E_COLUMN.

    METHODS: HANDLE_HOTSPOT_CLICK
             FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
             IMPORTING E_ROW_ID
                       E_COLUMN_ID.

    METHODS: PRINT_TOP_OF_PAGE
             FOR EVENT PRINT_TOP_OF_PAGE OF CL_GUI_ALV_GRID.

    METHODS: HANDLE_ON_F4
               FOR EVENT ONF4 OF CL_GUI_ALV_GRID
               IMPORTING SENDER
                         E_FIELDNAME
                         E_FIELDVALUE
                         ES_ROW_NO
                         ER_EVENT_DATA
                         ET_BAD_CELLS
                         E_DISPLAY.

    METHODS: HANDLE_TOOLBAR
               FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
               IMPORTING E_OBJECT
                         E_INTERACTIVE.

    METHODS: HANDLE_BEFORE_USER_COMMAND
               FOR EVENT BEFORE_USER_COMMAND OF CL_GUI_ALV_GRID
               IMPORTING E_UCOMM.

    METHODS: HANDLE_USER_COMMAND
               FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
               IMPORTING E_UCOMM.

    METHODS: HANDLE_AFTER_USER_COMMAND
               FOR EVENT AFTER_USER_COMMAND OF CL_GUI_ALV_GRID
               IMPORTING E_UCOMM
                         E_SAVED
                         E_NOT_PROCESSED.

    METHODS: HANDLE_BUTTON_CLICK
               FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
               IMPORTING ES_COL_ID
                         ES_ROW_NO.

    METHODS: HANDLE_CONTEXT_MENU
               FOR EVENT CONTEXT_MENU_REQUEST OF CL_GUI_ALV_GRID
               IMPORTING E_OBJECT.

ENDCLASS.  "(LCL_EVENT_RECEIVER DEFINITION)

*----------------------------------------------------------------------*
* LOCAL CLASSES: Implementation
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    CALL METHOD SUPER->CONSTRUCTOR.
    G_OBJECT_TEXT = E_OBJECT_TEXT.
  ENDMETHOD.                    "constructor

  METHOD HANDLE_DATA_CHANGED.

    PERFORM ALV_DATA_CHANGED USING G_OBJECT_TEXT
                                        ER_DATA_CHANGED
                                        E_ONF4
                                        E_ONF4_BEFORE
                                        E_ONF4_AFTER
                                        E_UCOMM.

  ENDMETHOD.                    "handle_data_changed

  METHOD HANDLE_DATA_CHANGED_FINISHED.

    PERFORM ALV_DATA_CHANGED_FINISHED USING G_OBJECT_TEXT
                                                 E_MODIFIED
                                                 ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED

  METHOD HANDLE_DOUBLE_CLICK.
    BREAK SUNHM.
*    PERFORM ALV_DOUBLE_CLICK  USING G_OBJECT_TEXT
*                                        E_ROW
*                                        E_COLUMN.
  ENDMETHOD.    "HANDLE_DOUBLE_CLICK

  METHOD HANDLE_HOTSPOT_CLICK.

*    PERFORM ALV_DOUBLE_CLICK  USING G_OBJECT_TEXT
*                                        E_ROW_ID
*                                        E_COLUMN_ID.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD PRINT_TOP_OF_PAGE.
*    PERFORM ALV_TOP_OF_PAGE    USING G_OBJECT_TEXT.
  ENDMETHOD.                    "print_top_of_page

  METHOD HANDLE_ON_F4.

*    PERFORM ALV_ON_F4        USING G_OBJECT_TEXT
*                                 SENDER
*                                 E_FIELDNAME
*                                 E_FIELDVALUE
*                                 ES_ROW_NO
*                                 ER_EVENT_DATA
*                                 ET_BAD_CELLS
*                                 E_DISPLAY.
  ENDMETHOD.                                                "on_f4

  METHOD HANDLE_TOOLBAR.
    PERFORM ALV_TOOLBAR   USING G_OBJECT_TEXT
                                   E_OBJECT
                                   E_INTERACTIVE.
  ENDMETHOD.                    "handle_toolbar

  METHOD HANDLE_BEFORE_USER_COMMAND.
    BREAK SUNHM.
*    PERFORM ALV_BEFORE_USER_COMMAND  USING G_OBJECT_TEXT
*                                               E_UCOMM.
  ENDMETHOD.                    "HANDLE_BEFORE_USER_COMMAND

  METHOD HANDLE_USER_COMMAND.
    PERFORM ALV_USER_COMMAND    USING G_OBJECT_TEXT
                                        E_UCOMM.
  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD HANDLE_AFTER_USER_COMMAND.
*    PERFORM ALV_AFTER_USER_COMMAND    USING G_OBJECT_TEXT
*                                              E_UCOMM
*                                              E_SAVED
*                                              E_NOT_PROCESSED.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND

  METHOD HANDLE_BUTTON_CLICK.

    PERFORM ALV_BUTTON_CLICK    USING G_OBJECT_TEXT
                                        ES_COL_ID
                                        ES_ROW_NO.
  ENDMETHOD.    "HANDLE_BUTTON_CLICK

  METHOD HANDLE_CONTEXT_MENU.
    BREAK SUNHM.
*    PERFORM ALV_CONTEXT_MENU   USING G_OBJECT_TEXT
*                                        E_OBJECT.
  ENDMETHOD.    "HANDLE_CONTEXT_MENU

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION

*----------------------------------------------------------------------*
* ALV
*----------------------------------------------------------------------*
DATA: GO_GUI_CONT      TYPE REF TO CL_GUI_CONTAINER,
      GO_CONT          TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_GRID          TYPE REF TO CL_GUI_ALV_GRID,
      GO_EDITOR        TYPE REF TO CL_GUI_TEXTEDIT,
      GO_EVT_REC       TYPE REF TO LCL_EVENT_RECEIVER,
      GS_LAYOUT        TYPE LVC_S_LAYO,
      GT_FCAT          TYPE LVC_T_FCAT WITH HEADER LINE,
      GT_SORT          TYPE LVC_T_SORT WITH HEADER LINE,
      GT_ALV_F4        TYPE LVC_T_F4   WITH HEADER LINE,
      GS_STABLE        TYPE LVC_S_STBL,
      GS_VARIANT       TYPE DISVARIANT,
      GT_EXCLUDE       TYPE UI_FUNCTIONS WITH HEADER LINE,
      GT_EX_UCOMM      TYPE TABLE OF SY-UCOMM WITH HEADER LINE.

*&---------------------------------------------------------------------*
*&      Form  ALV_EX_TOOLBAR
*&---------------------------------------------------------------------*
*  ### ### #### ## ### ####.
*----------------------------------------------------------------------*
FORM ALV_EX_TOOLBAR USING P_TB_NAME.

  FIELD-SYMBOLS: <TABLE> TYPE UI_FUNCTIONS.

  DATA: LS_EXCLUDE TYPE UI_FUNC,
        L_TB_NAME  LIKE FELD-NAME.

  G_CPROG = SY-CPROG.

  CONCATENATE P_TB_NAME '[]' INTO  L_TB_NAME.
  ASSIGN     (L_TB_NAME)    TO <TABLE>.

  REFRESH: <TABLE>.

  PERFORM ALV_EXCLUDE_TB_1
    TABLES <TABLE>
*   USING: CL_GUI_ALV_GRID=>mc_fc_excl_all.      "## ####
    USING:
*      CL_GUI_ALV_GRID=>mc_fc_detail,            "####
*      CL_GUI_ALV_GRID=>mc_fc_refresh,           "Refresh

      CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           "### ####
*      CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          "### ##
*      CL_GUI_ALV_GRID=>MC_MB_PASTE
*      CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         "### ####
*      CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, "Paste new Row
      CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,          "####

*      CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    "# ##
*      CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    "# ##
*      CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    "# ##
*      CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      "# ##

      CL_GUI_ALV_GRID=>MC_FC_GRAPH,             "###
      CL_GUI_ALV_GRID=>MC_FC_INFO,              "Info

      CL_GUI_ALV_GRID=>MC_MB_VIEW,              "
      CL_GUI_ALV_GRID=>MC_FC_VIEWS,             "#####    '&VIEW'
      CL_GUI_ALV_GRID=>MC_FC_VIEW_CRYSTAL,      "######
      CL_GUI_ALV_GRID=>MC_FC_VIEW_EXCEL,        "####
      CL_GUI_ALV_GRID=>MC_FC_VIEW_GRID,         "Grid##      '&VGRID'
      CL_GUI_ALV_GRID=>MC_FC_VIEW_LOTUS,        "

      CL_GUI_ALV_GRID=>MC_FC_SORT,
      CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,          "Sort ASC
      CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,          "Sort DESC
      CL_GUI_ALV_GRID=>MC_FC_FIND,              "Find
      CL_GUI_ALV_GRID=>MC_FC_FIND_MORE,         "Find Next

*      CL_GUI_ALV_GRID=>MC_MB_FILTER,
*      CL_GUI_ALV_GRID=>MC_FC_FILTER,            "Set ##
*      CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER,     "Del ##

      CL_GUI_ALV_GRID=>MC_FC_SUM,               "Sum
      CL_GUI_ALV_GRID=>MC_FC_MINIMUM,           "Min
      CL_GUI_ALV_GRID=>MC_FC_MAXIMUM,           "Max
      CL_GUI_ALV_GRID=>MC_FC_AVERAGE,           "##
      CL_GUI_ALV_GRID=>MC_FC_AUF,               "####&AUF
      CL_GUI_ALV_GRID=>MC_FC_SUBTOT,            "Sub Sum

      CL_GUI_ALV_GRID=>MC_FC_PRINT,             "###
      CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK,
      CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV,

*      CL_GUI_ALV_GRID=>MC_MB_EXPORT,            "
*      CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE,         "Export
*      CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR,    "##
*      CL_GUI_ALV_GRID=>MC_FC_PC_FILE,           "####
*      CL_GUI_ALV_GRID=>MC_FC_SEND,              "Send
*      CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE,         "Office
*      CL_GUI_ALV_GRID=>MC_FC_CALL_ABC,          "ABC##
*      CL_GUI_ALV_GRID=>MC_FC_HTML,              "HTML

*      CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT,      "####
*      CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT,   "##
*      CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT,      "##
*      CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT,  "Vari##

*      CL_GUI_ALV_GRID=>MC_FC_COL_OPTIMIZE,      "Optimize
*      CL_GUI_ALV_GRID=>MC_FC_SEPARATOR,         "###
*      CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,        "####
*      CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,      "####
*      CL_GUI_ALV_GRID=>MC_FC_COL_INVISIBLE,     "#####
*      CL_GUI_ALV_GRID=>MC_FC_FIX_COLUMNS,       "####
*      CL_GUI_ALV_GRID=>MC_FC_UNFIX_COLUMNS,     "######
*      CL_GUI_ALV_GRID=>MC_FC_AVERAGE,           "Average         '&AVERAGE'
*
*      CL_GUI_ALV_GRID=>MC_FC_F4,
*      CL_GUI_ALV_GRID=>MC_FC_HELP,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_ABC,          "               '&ABC'
*      CL_GUI_ALV_GRID=>MC_FC_CALL_CHAIN,
*      CL_GUI_ALV_GRID=>MC_FC_BACK_CLASSIC,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_CRBATCH,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_CRWEB,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_LINEITEMS,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_MASTER_DATA,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_MORE,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_REPORT,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_XINT,
*      CL_GUI_ALV_GRID=>MC_FC_CALL_XXL,
*      CL_GUI_ALV_GRID=>MC_FC_EXPCRDATA,
*      CL_GUI_ALV_GRID=>MC_FC_EXPCRDESIG,
*      CL_GUI_ALV_GRID=>MC_FC_EXPCRTEMPL,
*      CL_GUI_ALV_GRID=>MC_FC_EXPMDB,
*      CL_GUI_ALV_GRID=>MC_FC_EXTEND,
*      CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,

      CL_GUI_ALV_GRID=>MC_FC_REPREP,
      CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE.

ENDFORM.                    " ALV_EX_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  ALV_EX_TOOLBAR_NO
*&---------------------------------------------------------------------*
*  ### ### #### ## ### ####.
*----------------------------------------------------------------------*
FORM ALV_EX_TOOLBAR_NO USING P_TB_NAME.

  FIELD-SYMBOLS: <TABLE> TYPE UI_FUNCTIONS.

  DATA: LS_EXCLUDE TYPE UI_FUNC,
        L_TB_NAME  LIKE FELD-NAME.

  G_CPROG = SY-REPID.

  CONCATENATE P_TB_NAME '[]' INTO  L_TB_NAME.
  ASSIGN     (L_TB_NAME)    TO <TABLE>.

  REFRESH: <TABLE>.

  PERFORM ALV_EXCLUDE_TB_1
    TABLES <TABLE>
    USING  CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.      "## ####

ENDFORM.                    " ALV_EX_TOOLBAR_NO

*&---------------------------------------------------------------------*
*&      Form  ALV_EXCLUDE_TB_1
*&---------------------------------------------------------------------*
FORM ALV_EXCLUDE_TB_1  TABLES   PT_EX TYPE UI_FUNCTIONS
                       USING    PV_VALUE.

  DATA: LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = PV_VALUE.
  APPEND LS_EXCLUDE TO PT_EX.

ENDFORM.                    " ALV_EXCLUDE_TB_1

*&---------------------------------------------------------------------*
*&      Form  ALV_EXEC_TOOLBAR_FCODE
*&---------------------------------------------------------------------*
*  ## ### #####
*&---------------------------------------------------------------------*
FORM ALV_EXEC_TOOLBAR_FCODE USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                  P_LVC_FCODE.

  DATA: L_SLIS_FCODE LIKE SY-UCOMM.

*  P_LVC_FCODE = '&PRINT_BACK_PREVIEW'.   " '&RNT'  '%SC' '&PRINT_BACK_PREVIEW' '&VIEW'

  CALL METHOD CL_GUI_ALV_GRID=>TRANSFER_FCODE_LVC_TO_SLIS
    EXPORTING
*      IT_FCODES_LVC  =
      I_FCODE_LVC    = P_LVC_FCODE
    IMPORTING
*      ET_FCODES_SLIS =
      E_FCODE_SLIS   = L_SLIS_FCODE
    EXCEPTIONS
       NO_MATCH_FOUND = 1
       OTHERS         = 2          .

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD PO_GRID->SET_FUNCTION_CODE
    CHANGING
      C_UCOMM = L_SLIS_FCODE.


ENDFORM.                    " ALV_EXEC_TOOLBAR_FCODE

*&---------------------------------------------------------------------*
*&      Form  ALV_FIELDCAT_MERGE
*&---------------------------------------------------------------------*
FORM ALV_FIELDCAT_MERGE TABLES PT_M        TYPE TABLE
                               PT_FIELDCAT TYPE LVC_T_FCAT
                        USING  P_IT_NAME P_TYPE TYPE CHAR1.

  DATA: LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE.
  DATA: LV_IT_NAME  TYPE SLIS_TABNAME.

  G_CPROG   = SY-CPROG.
  LV_IT_NAME = P_IT_NAME.

* IT ### #### ##
  IF P_TYPE = 'I'.
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        I_PROGRAM_NAME     = G_CPROG
        I_INTERNAL_TABNAME = LV_IT_NAME
        I_INCLNAME         = G_CPROG
        I_BYPASSING_BUFFER = 'X'
      CHANGING
        CT_FIELDCAT        = LT_FIELDCAT[].
  ELSE.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME       = GV_FCAT_STR
      CHANGING
        CT_FIELDCAT            = LT_FIELDCAT[]
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.
  ENDIF.


* ALV Control### ##
  CLEAR: PT_FIELDCAT, PT_FIELDCAT[].

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FIELDCAT[]
    IMPORTING
      ET_FIELDCAT_LVC = PT_FIELDCAT[]
    TABLES
      IT_DATA         = PT_M.

ENDFORM.                    " ALV_FIELDCAT_MERGE

*&---------------------------------------------------------------------*
*&      Form  ALV_GET_CURSOR
*&---------------------------------------------------------------------*
FORM ALV_GET_CURSOR USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                    CHANGING P_ROW_ID    "LVC_S_ROW-INDEX
                             P_COL_NM.   "LVC_S_COL-FIELDNAME

  DATA: L_ROW TYPE I,
        L_VALUE(255),
        L_COL TYPE I,
        LS_ROW TYPE LVC_S_ROW,
        LS_COL TYPE LVC_S_COL,
        LS_ROW_NO TYPE LVC_S_ROID.

  CLEAR: P_ROW_ID, P_COL_NM.

  CALL METHOD PO_GRID->GET_CURRENT_CELL
    IMPORTING
      E_ROW     = L_ROW
      E_VALUE   = L_VALUE
      E_COL     = L_COL
      ES_ROW_ID = LS_ROW
      ES_COL_ID = LS_COL
      ES_ROW_NO = LS_ROW_NO.

  IF LS_ROW-ROWTYPE IS INITIAL.
    P_ROW_ID = LS_ROW-INDEX.
  ENDIF.

  P_COL_NM = LS_COL-FIELDNAME.

ENDFORM.                    " ALV_GET_CURSOR

*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT_INIT USING    P_EDIT    "#### ####
                              P_COLOR   "#### ####
                     CHANGING PS_LAYOUT TYPE LVC_S_LAYO.

  CLEAR PS_LAYOUT.

  PS_LAYOUT-DETAILINIT = 'X'.        "Detail## NULL### ###
  PS_LAYOUT-SEL_MODE   = 'D'.        "Selection mode(A,B,C,D)
  PS_LAYOUT-NO_ROWINS  = 'X'.
  PS_LAYOUT-NO_ROWMOVE = 'X'.
  PS_LAYOUT-SMALLTITLE = 'X'.

*  IF P_EDIT = 'X'.
*    PS_LAYOUT-STYLEFNAME = 'CELLTAB'.  "Input/Output ##
*  ENDIF.
*
*  IF P_COLOR = 'X'.
*    PS_LAYOUT-CTAB_FNAME = 'CELLCOL'.  "Color ##
*  ENDIF.
*
*  PS_LAYOUT-INFO_FNAME = 'CELLINF'.    "### ##

  GS_VARIANT-REPORT    = SY-REPID.    "Default Variant Set

*  PS_LAYOUT-ZEBRA      = 'X'.         "#### ###,### ##
*  PS_LAYOUT-EDIT       = 'X'.         "## ######
*  PS_LAYOUT-NO_TOOLBAR = 'X'.
*  PS_LAYOUT-GRID_TITLE = 'GRID ##'.
*  PS_LAYOUT1-NO_ROWMARK = 'X'.        "MARK ##(###### ####)
*  PS_LAYOUT1-SEL_MODE   = 'A'.        "CELL ## ##(###### ####)
*  PS_LAYOUT1-SEL_MODE   = 'B'.        "## ## ##(###### ####)

ENDFORM.                    " ALV_LAYOUT_INIT

*&---------------------------------------------------------------------*
*&      Form  ALV_REFRESH
*&---------------------------------------------------------------------*
*  P_GB = ' ' : REFRESH # ##
*         'F' : Fieldcat ### ### ## ##
*         'S' : Sort, SUMMARY # ## REFRESH ##
*         'A' : Fieldcat ## + Sort, SUMMARY ##
*----------------------------------------------------------------------*
FORM ALV_REFRESH USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                       PT_FCAT TYPE LVC_T_FCAT
                       P_GB.

  DATA: LS_STBL TYPE LVC_S_STBL,
        L_SOFT_REFRESH.

* Fieldcat ### ##### ### ##
  CASE P_GB.
    WHEN 'F' OR 'A'.
      CALL METHOD PO_GRID->SET_FRONTEND_FIELDCATALOG
        EXPORTING
          IT_FIELDCATALOG = PT_FCAT[].
  ENDCASE.

* Sort, SUMMARY## REFRESH
  CASE P_GB.
    WHEN 'S' OR 'A'.
      L_SOFT_REFRESH = ''.
    WHEN OTHERS.
      L_SOFT_REFRESH = 'X'.
  ENDCASE.

  LS_STBL-ROW = 'X'.
  LS_STBL-COL = 'X'.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STBL
      I_SOFT_REFRESH = L_SOFT_REFRESH.

ENDFORM.                    " ALV_REFRESH
*&---------------------------------------------------------------------*
*&      Form  frm_refresh_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ICL_ALVGRID  text
*----------------------------------------------------------------------*
FORM FRM_REFRESH_ALV  USING ICL_ALVGRID TYPE REF TO CL_GUI_ALV_GRID.
  DATA: LS_STBL TYPE LVC_S_STBL,
        LR_GRID TYPE REF TO CL_GUI_ALV_GRID..
  "稳定刷新
  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'       "得到当前屏幕上的ALV的句柄
    IMPORTING
      E_GRID = LR_GRID.

  CALL METHOD LR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL.
ENDFORM.                    "frm_refresh_alv
*&---------------------------------------------------------------------*
*&      Form  ALV_RELOAD
*&---------------------------------------------------------------------*
FORM ALV_RELOAD.

*  IF GO_GRID    IS NOT INITIAL. CALL METHOD GO_GRID->FREE.    ENDIF.
*
*  IF GO_SPCONT  IS NOT INITIAL. CALL METHOD GO_SPCONT->FREE.  ENDIF.

*  IF GO_SPLT    IS NOT INITIAL. CALL METHOD GO_SPLT->FREE.    ENDIF.

*  IF GO_DOCK    IS NOT INITIAL. CALL METHOD GO_DOCK->FREE.    ENDIF.
*  IF GO_CONT    IS NOT INITIAL. CALL METHOD GO_CONT->FREE.    ENDIF.

*  CLEAR: GO_DOCK,
*         GO_CONT,
*         GO_SPLT,
*         GO_SPCONT,
*         GO_GRID.
*
** CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    " ALV_RELOAD

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_CURSOR
*&---------------------------------------------------------------------*
FORM ALV_SET_CURSOR USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                          P_ROWID
                          P_COLNM.

  DATA: LS_ROW TYPE LVC_S_ROW,
        LS_COL TYPE LVC_S_COL.

  LS_ROW-INDEX     = P_ROWID.
  LS_COL-FIELDNAME = P_COLNM.

*  CALL METHOD PO_GRID->SET_SCROLL_INFO_VIA_ID
*    EXPORTING
*      IS_ROW_INFO = LS_ROW
*      IS_COL_INFO = LS_COL.

  CALL METHOD PO_GRID->SET_CURRENT_CELL_VIA_ID
    EXPORTING
      IS_ROW_ID    = LS_ROW
      IS_COLUMN_ID = LS_COL.

  CALL METHOD CL_GUI_ALV_GRID=>SET_FOCUS
    EXPORTING
      CONTROL = PO_GRID.

ENDFORM.                    " ALV_SET_CURSOR

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_DDLB
*&---------------------------------------------------------------------*
FORM ALV_SET_DDLB USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
*                        PT_DROP TYPE        LVC_T_DROP.
                        PT_DRAL TYPE        LVC_T_DRAL.

  CALL METHOD PO_GRID->SET_DROP_DOWN_TABLE
    EXPORTING
*      IT_DROP_DOWN =       PT_DROP[].
      IT_DROP_DOWN_ALIAS = PT_DRAL[].

ENDFORM.                    " ALV_SET_DDLB

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_MARK
*&---------------------------------------------------------------------*
*  ### ### MARK ### 'X' ####. SY-TABIX# ### ## ##
*----------------------------------------------------------------------*
FORM ALV_SET_MARK USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                        PT_ITAB TYPE STANDARD TABLE.

  FIELD-SYMBOLS: <FS_WA> TYPE ANY,
                 <FS>.

  DATA: LT_ROW  TYPE LVC_T_ROW WITH HEADER LINE,
        L_TABIX TYPE SY-TABIX.

  CALL METHOD PO_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_INDEX_ROWS = LT_ROW[].

  LOOP AT PT_ITAB ASSIGNING <FS_WA>.
    ASSIGN COMPONENT 'MARK' OF STRUCTURE <FS_WA> TO <FS>.
    IF <FS> = ' '. CONTINUE. ENDIF.
    <FS> = ' '.
    MODIFY PT_ITAB FROM <FS_WA>.
  ENDLOOP.

  LOOP AT LT_ROW WHERE ROWTYPE = ' '.
    READ TABLE PT_ITAB ASSIGNING <FS_WA> INDEX LT_ROW-INDEX.
    IF SY-SUBRC <> 0. CONTINUE. ENDIF.
    ASSIGN COMPONENT 'MARK' OF STRUCTURE <FS_WA> TO <FS>.
    <FS> = 'X'.
    MODIFY PT_ITAB FROM <FS_WA> INDEX LT_ROW-INDEX.
    L_TABIX = L_TABIX + 1.
  ENDLOOP.

  SY-TABIX = L_TABIX.

ENDFORM.                    " ALV_SET_MARK

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_SEL_ROW
*&---------------------------------------------------------------------*
FORM ALV_SET_SEL_ROW USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                           P_ROW.

  DATA: LT_ROW TYPE LVC_T_ROW WITH HEADER LINE.

  LT_ROW-INDEX = P_ROW.
  APPEND LT_ROW.

  CALL METHOD PO_GRID->SET_SELECTED_ROWS
    EXPORTING
      IT_INDEX_ROWS = LT_ROW[].
*      IT_ROW_NO                =
*      IS_KEEP_OTHER_SELECTIONS = 'X'.

ENDFORM.                    " ALV_SET_SEL_ROW

*&---------------------------------------------------------------------*
*&      Form  ALV_USER_COMM_FILTER
*&---------------------------------------------------------------------*
FORM ALV_USER_COMM_FILTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                                PT_FCAT TYPE LVC_T_FCAT
                                P_FNAME
                                P_VAL.

  DATA: LT_FILTER TYPE LVC_T_FILT WITH HEADER LINE.

  CALL METHOD PO_GRID->GET_FILTER_CRITERIA
    IMPORTING
      ET_FILTER = LT_FILTER[].

  IF P_FNAME IS INITIAL.
    CLEAR LT_FILTER[].
  ELSE.
    DELETE LT_FILTER WHERE FIELDNAME = P_FNAME.
  ENDIF.

  IF P_VAL IS NOT INITIAL.
    CLEAR: LT_FILTER.
    LT_FILTER-FIELDNAME = P_FNAME.
    LT_FILTER-SIGN      = 'I'.
    LT_FILTER-OPTION    = 'EQ'.
    LT_FILTER-LOW       = P_VAL.
    APPEND LT_FILTER.
  ENDIF.

  CALL METHOD PO_GRID->SET_FILTER_CRITERIA
    EXPORTING
      IT_FILTER                 = LT_FILTER[]
    EXCEPTIONS
      NO_FIELDCATALOG_AVAILABLE = 1
      OTHERS                    = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  PERFORM ALV_REFRESH USING PO_GRID PT_FCAT[] 'A'.

ENDFORM.                    " ALV_USER_COMM_FILTER


*----------------------------------------------------------------------*
* ### FORM ## ## ## ##### #### ##
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ALV_FIELDCAT_9000
*&---------------------------------------------------------------------*
*FORM ALV_FIELDCAT_9000 TABLES PT_FCAT STRUCTURE LVC_S_FCAT.
*
*  LOOP AT PT_FCAT.
*  PT_FCAT-TABNAME   = 'GT_OUT'.
*  PT_FCAT-REF_TABLE = 'SFLIGHT'.
*  PT_FCAT-FIELDNAME = I_FIELDNAME. "字段名称
*  PT_FCAT-REF_FIELD = I_FIELDNAME. "字段名称
*  PT_FCAT-REPTEXT   = I_REPTEXT.   "标题
*  PT_FCAT-LZERO     = ''.          "输出前导零
*  PT_FCAT-NO_ZERO   = ''.          "隐藏零
*  PT_FCAT-NO_SIGN   = ''.          "抑制符号
*  PT_FCAT-EMPHASIZE = 'C310'.      "列颜色
*  PT_FCAT-CHECKBOX  = ''.          "作为复选框输出
*  PT_FCAT-DECIMALS  = 0.           "小数位数
*    CASE PT_FCAT-FIELDNAME.
*      WHEN 'RCOMP'.

*        PT_FCAT-NO_ZERO = 'X'.
*        PT_FCAT-EMPHASIZE = 'C310'."列颜色
*        PT_FCAT-DO_SUM = 'X'.
*      WHEN OTHERS.
*        PT_FCAT-NO_OUT      = 'X'.
*    ENDCASE.
*
*    MODIFY PT_FCAT.
*
*  ENDLOOP.
*
*ENDFORM.                    " ALV_FIELDCAT_0100

*&---------------------------------------------------------------------*
*&      Form  ALV_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM ALV_DATA_CHANGED USING P_GRID_NM
                            ER_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                            E_ONF4
                            E_ONF4_BEFORE
                            E_ONF4_AFTER
                            E_UCOMM.

  DATA:IS_STABLE    TYPE LVC_S_STBL.
  FIELD-SYMBOLS: <DYN_WA> TYPE ANY,
                 <FS> TYPE ANY.

  DATA:
        L_IT_DATA   TYPE  LVC_T_MODI,
        L_WA_DATA   LIKE LINE OF L_IT_DATA.

  DATA: L_PRICE_OLD TYPE STRING,
        L_PRICE_NEW TYPE STRING,
        L_MSG       TYPE STRING.

*  L_IT_DATA = ER_DATA_CHANGED->MT_MOD_CELLS.
*
*
*  LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO L_WA_DATA .
*    READ TABLE <DYN_GLOBE_TABLE> ASSIGNING <DYN_WA> INDEX L_WA_DATA-ROW_ID.
*    ASSIGN COMPONENT L_WA_DATA-FIELDNAME OF STRUCTURE <DYN_WA> TO <FS>.
*    <FS> = L_WA_DATA-VALUE.
*  ENDLOOP.


ENDFORM.                    " ALV_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
FORM ALV_DATA_CHANGED_FINISHED USING P_GRID_NAME
                                     E_MODIFIED    TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.
*
*  DATA: LS_MODI TYPE LVC_S_MODI.
*  FIELD-SYMBOLS: <DYN_WA> TYPE ANY.
*  FIELD-SYMBOLS: <FS> TYPE ANY.
*  FIELD-SYMBOLS: <FS_PK> TYPE ANY.
*  FIELD-SYMBOLS: <FIX_FS> TYPE ANY.
*  DATA: LV_FIELDNAME TYPE FIELDNAME.
*  DATA: LV_FIXFIELDNAME TYPE FIELDNAME VALUE '<DYN_WA>-FIX_WRBTR'.
*  DATA: LV_NEWBSIELDNAME TYPE FIELDNAME VALUE '<DYN_WA>-NEWBS'.
*
*  DATA: LS_TBSL TYPE TBSL.
*  DATA: LT_TBSL TYPE TABLE OF TBSL.
*  SELECT * FROM TBSL INTO TABLE LT_TBSL.
*
*  IF E_MODIFIED = ''. EXIT. ENDIF.
*
*  LOOP AT ET_GOOD_CELLS INTO LS_MODI.
*
*    READ TABLE <DYN_GLOBE_TABLE> ASSIGNING <DYN_WA> INDEX LS_MODI-ROW_ID.
*    IF SY-SUBRC <> 0.
*      MESSAGE E899(MM) WITH 'IT READ ERROR'.
*    ENDIF.
*
*    CONCATENATE '<DYN_WA>-' LS_MODI-FIELDNAME INTO LV_FIELDNAME.
*
*
*    IF LV_FIELDNAME = '<DYN_WA>-WRBTR'.
*
*      "这里使用指针的方式获取数据
*      ASSIGN (LV_FIELDNAME) TO <FS>.
*      ASSIGN (LV_FIXFIELDNAME) TO <FIX_FS>.
*      ASSIGN (LV_NEWBSIELDNAME) TO <FS_PK>.
*      <FIX_FS> = <FS>.
*      READ TABLE LT_TBSL INTO LS_TBSL WITH KEY BSCHL = <FS_PK>.
*      IF SY-SUBRC = 0.
*        IF LS_TBSL-SHKZG = 'H'.
*          <FIX_FS> = 0 - <FIX_FS>.
*        ENDIF.
*      ENDIF.
*
*
*    ENDIF.

*
*    CASE LS_MODI-FIELDNAME.
*
*      WHEN 'RCOMP'.
*        PERFORM SEL_T880_TXT USING    GT_A-RCOMP
*                             CHANGING GT_A-RCOMP_NM
*                                      GT_A-HWAER.

*    ENDCASE.


*  ENDLOOP.

*  G_MODI_GB = 'X'.

  PERFORM ALV_REFRESH USING GO_GRID GT_FCAT[] 'A'.

ENDFORM.                    " ALV_DATA_CHANGED_FINISHED

*&---------------------------------------------------------------------*
*&      Form  ALV_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*FORM ALV_DOUBLE_CLICK USING P_GRID_NM
*                            P_ROW TYPE LVC_S_ROW
*                            P_COL TYPE LVC_S_COL.
*  BREAK SUNHM.
** ## PAI # ### # ##
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ALV_DBL_CLK'.
*
*
*ENDFORM.                    " ALV_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  ALV_F4
*&---------------------------------------------------------------------*
*FORM ALV_F4  USING P_GRID_NM
*                   PO_sender      TYPE REF TO cl_gui_alv_grid
*                   P_fieldname    TYPE lvc_fname
*                   P_fieldvalue   TYPE lvc_value
*                   PS_row_no      TYPE lvc_s_roid
*                   PO_event_data  TYPE REF TO cl_alv_event_data
*                   PT_bad_cells   TYPE lvc_t_modi
*                   P_display      TYPE char01.
*
*ENDFORM.                    " ALV_F4

*&---------------------------------------------------------------------*
*&      Form  ALV_TOOLBAR
*&---------------------------------------------------------------------*
FORM ALV_TOOLBAR USING P_GRID_NM
                       E_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                       E_INTERACTIVE.


  DATA: LS_TOOLBAR TYPE STB_BUTTON.
  CHECK GV_STATE = 'P'.

* Seperator
  LS_TOOLBAR-FUNCTION  = 'DUMMY'.
  LS_TOOLBAR-BUTN_TYPE = '3'.
  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* Normal Button
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = '&INS'.
  LS_TOOLBAR-ICON      = ICON_INSERT_ROW.
  LS_TOOLBAR-BUTN_TYPE = '0'.
  LS_TOOLBAR-DISABLED  = SPACE.
  LS_TOOLBAR-TEXT      = '插入行'.
  LS_TOOLBAR-QUICKINFO = '插入行'.
  LS_TOOLBAR-CHECKED   = SPACE.
  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.



ENDFORM.                    " ALV_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  ALV_BEFORE_USER_COMMAND
*&---------------------------------------------------------------------*
*FORM ALV_BEFORE_USER_COMMAND USING P_GRID_NM
*                                   E_UCOMM LIKE SY-UCOMM.
*
*ENDFORM.                    " ALV_BEFORE_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  ALV_USER_COMMAND
*&---------------------------------------------------------------------*
FORM ALV_USER_COMMAND USING P_GRID_NM
                            E_UCOMM LIKE SY-UCOMM.

  BREAK SUNHM.
  CASE E_UCOMM .
*    WHEN '&INS'. PERFORM FRM_INSERT_NULL_ROW.
*	WHEN .
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " ALV_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  ALV_AFTER_USER_COMMAND
*&---------------------------------------------------------------------*
*FORM ALV_AFTER_USER_COMMAND USING P_GRID_NM
*                                  E_UCOMM LIKE sy-ucomm
*                                  E_SAVED
*                                  E_NOT_PROCESSED.
*
*ENDFORM.                    " ALV_AFTER_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  ALV_BUTTON_CLICK
*&---------------------------------------------------------------------*
FORM ALV_BUTTON_CLICK USING P_GRID_NAME
                            PS_COL_ID TYPE LVC_S_COL
                            PS_ROW_NO TYPE LVC_S_ROID.

  DATA: LS_OUT TYPE ZCM_ATTACHMENT_LIST.
  READ TABLE GT_GLOBE_TABLE INTO LS_OUT INDEX PS_ROW_NO-ROW_ID .

  PERFORM FRM_DOWNLOAD_FILES USING LS_OUT.
*GT_GLOBE_UUID


ENDFORM.                    " ALV_BUTTON_CLICK

*&---------------------------------------------------------------------*
*&      Form  ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*FORM ALV_TOP_OF_PAGE USING P_GRID_NAME.
*
*  WRITE: /,
*         / SY-TITLE CENTERED,
*         /.
*
*ENDFORM.                    " ALV_TOP_OF_PAGE
