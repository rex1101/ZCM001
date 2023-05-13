class ZCL_CM_OO_ALV definition
  public
  final
  create public .

public section.

  interfaces ZIF_CM_OOALV_EVENT .

  types:
    BEGIN OF TY_SPLITS,
          ROW       TYPE I,
          COL       TYPE I,
          CONTAINER TYPE REF TO CL_GUI_CONTAINER,
        END OF TY_SPLITS .
  types:
    TY_T_SPLITS TYPE TABLE OF TY_SPLITS .

  constants GC_A type C value 'A' ##NO_TEXT.
  constants GC_D type C value 'D' ##NO_TEXT.
  data GO_GRID type ref to CL_GUI_ALV_GRID .
  data GO_CONT type ref to CL_GUI_CUSTOM_CONTAINER .
  data SALV_TABLE type ref to CL_SALV_TABLE .
  data SPLIT_N2 type I .
  data GV_REPID type PROGNAME .
  data GE_F4_FORM type STRING .
  data GE_TOOLBAR_FORM type STRING .
  data GE_HOTSPOT_FORM type STRING .
  data GE_USER_COMMAND_FORM type STRING .
  data GE_DATACHANGED_FORM type STRING .
  data GE_DATACHANGED_FINISHED_FORM type STRING .
  data GE_BEFORE_UCOMM_FORM type STRING .
  data GE_DOUBLE_CLICK_FORM type STRING .
  data GE_MENU_BUTTON_FORM type STRING .
  data GT_FCAT type LVC_T_FCAT .
  data GS_LAYOUT2 type LVC_S_LAYO .
  data GT_EXCLUDE2 type UI_FUNCTIONS .
  data GS_DISVARIANT type DISVARIANT .
  data LS_EXCLUDE2 type UI_FUNC .
  data GV_GRID_NAME type CHAR30 .

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR .
  methods MT_CREATE_OO_ALV
    importing
      value(IV_REPID) type PROGNAME default SY-CPROG
      value(IV_SCREEN) type SY-DYNNR default '9000'
      value(IV_DEFAULT_EX) type CHAR1 default 'X'
      value(IS_LAYOUT) type LVC_S_LAYO optional
      value(IT_FIELDCAT) type LVC_T_FCAT optional
      value(IT_EXCLUDE) type UI_FUNCTIONS optional
      value(IV_SPLIT_NUMBER) type I optional
      value(IV_SPLIT_CONTAINER) type ref to CL_GUI_CONTAINER optional
      value(IV_CONTAINER_NAME) type CHAR30 default 'GO_CONT'
      value(IV_VARIANT_HANDLE) type DISVARIANT-HANDLE default '1'
      !I_F4_FORM type STRING optional
      !I_TOOLBAR_FORM type STRING optional
      !I_USER_COMMAND_FORM type STRING optional
      !I_HOTSPOT_FORM type STRING optional
      !I_DATACHANGED_FORM type STRING optional
      !I_DATACHANGED_FINISHED_FORM type STRING optional
      !I_BEFORE_UCOMM_FORM type STRING optional
      !I_DOUBLE_CLICK_FORM type STRING optional
      !I_MENU_BUTTON_FORM type STRING optional
      !I_BUTTON_CLICK_FORM type STRING optional
      !I_STRUCTURE_NAME type DD02L-TABNAME optional
    changing
      !IT_DATA type STANDARD TABLE .
  class-methods MT_SPLIT_CONTAINER
    importing
      !IV_CONTAINER_NAME type CHAR30
      !I_ROW type I
      !I_COL type I
    exporting
      !ET_CONTAINER_T type ZCM_OOALV_SPLIT_LIST_TY .
  class-methods MT_DEFAULT_EXCLUDE_FUNC
    exporting
      value(IT_EXCLUDE) type UI_FUNCTIONS .
  class-methods MT_GET_DEFAULT_FIELDCAT
    changing
      !IT_DATA type STANDARD TABLE
      value(RT_FIELDCAT) type LVC_T_FCAT
    exceptions
      ERROR_IN_GET_FIELDCAT .
  class-methods MT_GET_DEFAULT_LAYOUT
    returning
      value(ES_LAYOUT) type LVC_S_LAYO .
  methods MT_REFRESH_OO_ALV .
  methods FREE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CM_OO_ALV IMPLEMENTATION.


  method CLASS_CONSTRUCTOR.
  endmethod.


  method CONSTRUCTOR.
  endmethod.


  method FREE.
      IF GO_GRID IS NOT INITIAL.
    CALL METHOD GO_GRID->FREE.
  ENDIF.

  IF GO_CONT IS NOT INITIAL.
    CALL METHOD GO_CONT->FREE.
  ENDIF.


  CLEAR: GO_CONT,
         GO_GRID.

  CALL METHOD CL_GUI_CFW=>FLUSH.

  endmethod.


  method MT_CREATE_OO_ALV.


  DATA LT_FILEDCAT TYPE LVC_T_FCAT.
  DATA LS_LAYOUT TYPE LVC_S_LAYO.
  GV_REPID = IV_REPID.

  ME->ZIF_CM_OOALV_EVENT~DATA_CHANGED_FORM = I_DATACHANGED_FORM.
  ME->ZIF_CM_OOALV_EVENT~DATA_CHANGED_FINISHED_FORM = I_DATACHANGED_FINISHED_FORM.
  ME->ZIF_CM_OOALV_EVENT~DOUBLE_CLICK_FORM = I_DOUBLE_CLICK_FORM.
  ME->ZIF_CM_OOALV_EVENT~HOTSPOT_CLICK_FORM = I_HOTSPOT_FORM.

  ME->ZIF_CM_OOALV_EVENT~ON_F4_FORM = I_F4_FORM.
  ME->ZIF_CM_OOALV_EVENT~TOOLBAR_FORM = I_TOOLBAR_FORM.
  ME->ZIF_CM_OOALV_EVENT~BEFORE_USER_COMMAND_FORM = I_BEFORE_UCOMM_FORM.
  ME->ZIF_CM_OOALV_EVENT~USER_COMMAND_FORM = I_USER_COMMAND_FORM.
  ME->ZIF_CM_OOALV_EVENT~BUTTON_CLICK_FORM = I_BUTTON_CLICK_FORM.


  ME->ZIF_CM_OOALV_EVENT~MENU_BUTTON_FORM = I_MENU_BUTTON_FORM.

  "iv_split_number
  "判断是否是分割容器
  IF IV_SPLIT_NUMBER IS INITIAL.
    CREATE OBJECT GO_CONT
      EXPORTING
        CONTAINER_NAME = IV_CONTAINER_NAME. "屏幕上用户自定义控件名
* create alv
    CREATE OBJECT GO_GRID
      EXPORTING
        I_PARENT = GO_CONT.

    GV_GRID_NAME = 'GO_GRID'.
  ELSE.
    "分割容器
    CREATE OBJECT GO_GRID
      EXPORTING
        I_PARENT = IV_SPLIT_CONTAINER.
  ENDIF.

  CHECK GO_GRID IS NOT INITIAL.

  DATA LT_EXCLUDE TYPE UI_FUNCTIONS.
  IF IV_DEFAULT_EX = 'X'.
    "使用默认排除按钮
    CALL METHOD ME->MT_DEFAULT_EXCLUDE_FUNC
      IMPORTING
        IT_EXCLUDE = LT_EXCLUDE.

  ENDIF.
  "手动排除按钮
  IF IT_EXCLUDE[] IS NOT INITIAL.
    APPEND LINES OF IT_EXCLUDE TO LT_EXCLUDE.
    SORT LT_EXCLUDE.
    DELETE ADJACENT DUPLICATES FROM LT_EXCLUDE.
  ENDIF.
  "布局
  IF IS_LAYOUT IS NOT INITIAL.
    LS_LAYOUT = IS_LAYOUT.
  ELSE.
    LS_LAYOUT = ME->MT_GET_DEFAULT_LAYOUT( ).
  ENDIF.

  "字段目录
  IF IT_FIELDCAT[] IS NOT INITIAL.
    LT_FILEDCAT = IT_FIELDCAT.
  ELSE.
    CALL METHOD ME->MT_GET_DEFAULT_FIELDCAT
      CHANGING
        IT_DATA               = IT_DATA
        RT_FIELDCAT           = LT_FILEDCAT
      EXCEPTIONS
        ERROR_IN_GET_FIELDCAT = 1
        OTHERS                = 2.
*       IF sy-subrc NE 0.
*         MESSAGE e368(00) WITH 'Failed to get fiedlcat' ''.
*       ENDIF.
  ENDIF.

  "变式布局
  DATA:LS_DISVARIANT TYPE DISVARIANT.
  LS_DISVARIANT-REPORT = SY-REPID.
  LS_DISVARIANT-HANDLE = IV_VARIANT_HANDLE.
  LS_DISVARIANT-USERNAME = SY-UNAME.


  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED                 FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED_FINISHED        FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_DOUBLE_CLICK                 FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_HOTSPOT_CLICK                FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~PRINT_TOP_OF_PAGE                   FOR GO_GRID.

*  PERFORM REGISTER_F4_PBO CHANGING GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_ON_F4                        FOR GO_GRID.

  SET HANDLER ZIF_CM_OOALV_EVENT~HANDLE_TOOLBAR                      FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_BEFORE_USER_COMMAND          FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_USER_COMMAND                 FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_AFTER_USER_COMMAND           FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_BUTTON_CLICK                 FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_CONTEXT_MENU                 FOR GO_GRID.
  SET HANDLER ME->ZIF_CM_OOALV_EVENT~HANDLE_MENU_BUTTON                  FOR GO_GRID.


*    CALL METHOD
  CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_VARIANT           = LS_DISVARIANT
      I_DEFAULT            = ABAP_ON
      I_SAVE               = GC_A
      IS_LAYOUT            = LS_LAYOUT
      IT_TOOLBAR_EXCLUDING = LT_EXCLUDE
      I_STRUCTURE_NAME = I_STRUCTURE_NAME
    CHANGING
      IT_OUTTAB            = IT_DATA
      IT_FIELDCATALOG      = LT_FILEDCAT.


  CALL METHOD GO_GRID->SET_TOOLBAR_INTERACTIVE.
* register enter event
  CALL METHOD GO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER
    EXCEPTIONS
      ERROR      = 1
      OTHERS     = 2.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1
    SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CALL METHOD GO_GRID->REGISTER_EDIT_EVENT     "register modify event
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED
    EXCEPTIONS
      ERROR      = 1
      OTHERS     = 2.
  IF SY-SUBRC NE 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1
    SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  endmethod.


  method MT_DEFAULT_EXCLUDE_FUNC.


  DATA: LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.                 APPEND LS_EXCLUDE TO IT_EXCLUDE.      "## ####
  LS_EXCLUDE =    CL_GUI_ALV_GRID=>MC_FC_DETAIL.                APPEND LS_EXCLUDE TO IT_EXCLUDE.            "####
  LS_EXCLUDE =   CL_GUI_ALV_GRID=>MC_FC_REFRESH.                APPEND LS_EXCLUDE TO IT_EXCLUDE.           "Refresh

  LS_EXCLUDE =   CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.                APPEND LS_EXCLUDE TO IT_EXCLUDE.           "### ####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.                APPEND LS_EXCLUDE TO IT_EXCLUDE.          "### ##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_MB_PASTE.                   APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.               APPEND LS_EXCLUDE TO IT_EXCLUDE.         "### ####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.       APPEND LS_EXCLUDE TO IT_EXCLUDE. "Paste new Row
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.                APPEND LS_EXCLUDE TO IT_EXCLUDE.          "####

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.          APPEND LS_EXCLUDE TO IT_EXCLUDE.    "# ##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.          APPEND LS_EXCLUDE TO IT_EXCLUDE.    "# ##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.          APPEND LS_EXCLUDE TO IT_EXCLUDE.    "# ##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.            APPEND LS_EXCLUDE TO IT_EXCLUDE.      "# ##

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_GRAPH.                   APPEND LS_EXCLUDE TO IT_EXCLUDE.             "###
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_INFO.                    APPEND LS_EXCLUDE TO IT_EXCLUDE.              "Info

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_MB_VIEW.                    APPEND LS_EXCLUDE TO IT_EXCLUDE.              "
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_VIEWS.                   APPEND LS_EXCLUDE TO IT_EXCLUDE.             "#####    '&VIEW'
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_VIEW_CRYSTAL.            APPEND LS_EXCLUDE TO IT_EXCLUDE.      "######
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_VIEW_EXCEL.              APPEND LS_EXCLUDE TO IT_EXCLUDE.        "####
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_VIEW_GRID.                APPEND LS_EXCLUDE TO IT_EXCLUDE.         "Grid##      '&VGRID'
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_VIEW_LOTUS.              APPEND LS_EXCLUDE TO IT_EXCLUDE.        "

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SORT.                    APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SORT_ASC.                APPEND LS_EXCLUDE TO IT_EXCLUDE.          "Sort ASC
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SORT_DSC.                APPEND LS_EXCLUDE TO IT_EXCLUDE.          "Sort DESC
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_FIND.                    APPEND LS_EXCLUDE TO IT_EXCLUDE.            "Find
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_FIND_MORE.               APPEND LS_EXCLUDE TO IT_EXCLUDE.         "Find Next

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_MB_FILTER.                  APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_FILTER.                  APPEND LS_EXCLUDE TO IT_EXCLUDE.           "Set ##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER.           APPEND LS_EXCLUDE TO IT_EXCLUDE.     "Del ##

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SUM.                     APPEND LS_EXCLUDE TO IT_EXCLUDE.               "Sum
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_MINIMUM.                 APPEND LS_EXCLUDE TO IT_EXCLUDE.           "Min
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_MAXIMUM.                 APPEND LS_EXCLUDE TO IT_EXCLUDE.           "Max
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_AVERAGE.                 APPEND LS_EXCLUDE TO IT_EXCLUDE.           "##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_AUF.                     APPEND LS_EXCLUDE TO IT_EXCLUDE.               "####&AUF
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SUBTOT.                  APPEND LS_EXCLUDE TO IT_EXCLUDE.            "Sub Sum

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_PRINT.                   APPEND LS_EXCLUDE TO IT_EXCLUDE.             "###
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK.              APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV.              APPEND LS_EXCLUDE TO IT_EXCLUDE.

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_MB_EXPORT.                  APPEND LS_EXCLUDE TO IT_EXCLUDE.            "
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE.               APPEND LS_EXCLUDE TO IT_EXCLUDE.         "Export
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR.          APPEND LS_EXCLUDE TO IT_EXCLUDE.    "##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_PC_FILE.                 APPEND LS_EXCLUDE TO IT_EXCLUDE.           "####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SEND.                    APPEND LS_EXCLUDE TO IT_EXCLUDE.              "Send
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE.               APPEND LS_EXCLUDE TO IT_EXCLUDE.         "Office
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_CALL_ABC.                 APPEND LS_EXCLUDE TO IT_EXCLUDE.          "ABC##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_HTML.                    APPEND LS_EXCLUDE TO IT_EXCLUDE.              "HTML

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT.             APPEND LS_EXCLUDE TO IT_EXCLUDE.      "####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT.         APPEND LS_EXCLUDE TO IT_EXCLUDE.   "##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT.            APPEND LS_EXCLUDE TO IT_EXCLUDE.      "##
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT.        APPEND LS_EXCLUDE TO IT_EXCLUDE.  "Vari##

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_COL_OPTIMIZE.            APPEND LS_EXCLUDE TO IT_EXCLUDE.      "Optimize
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SEPARATOR.               APPEND LS_EXCLUDE TO IT_EXCLUDE.         "###
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL.              APPEND LS_EXCLUDE TO IT_EXCLUDE.        "####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL.            APPEND LS_EXCLUDE TO IT_EXCLUDE.      "####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_COL_INVISIBLE.           APPEND LS_EXCLUDE TO IT_EXCLUDE.     "#####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_FIX_COLUMNS.             APPEND LS_EXCLUDE TO IT_EXCLUDE.       "####
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_UNFIX_COLUMNS.           APPEND LS_EXCLUDE TO IT_EXCLUDE.     "######
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_AVERAGE.                 APPEND LS_EXCLUDE TO IT_EXCLUDE.           "Average         '&AVERAGE'

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_F4.                      APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_HELP.                    APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_ABC.                APPEND LS_EXCLUDE TO IT_EXCLUDE.          "               '&ABC'
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_CHAIN.              APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_BACK_CLASSIC.            APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_CRBATCH.            APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_CRWEB.              APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_LINEITEMS.          APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_MASTER_DATA.        APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_MORE.               APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_REPORT.             APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_XINT.               APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_CALL_XXL.                APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_EXPCRDATA.               APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_EXPCRDESIG.              APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_EXPCRTEMPL.              APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_EXPMDB.                  APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_EXTEND.                  APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.            APPEND LS_EXCLUDE TO IT_EXCLUDE.

  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_REPREP.                  APPEND LS_EXCLUDE TO IT_EXCLUDE.
  LS_EXCLUDE =  CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE.             APPEND LS_EXCLUDE TO IT_EXCLUDE.

  endmethod.


  method MT_GET_DEFAULT_FIELDCAT.


  DATA: SALV_TABLE TYPE REF TO CL_SALV_TABLE.
  DATA: R_COLUMNS TYPE REF TO CL_SALV_COLUMNS_TABLE.
  DATA: R_AGGREGATIONS TYPE REF TO CL_SALV_AGGREGATIONS.
  DATA: LV_TEXT TYPE STRING.

  DATA LX_ROOT TYPE REF TO CX_ROOT.


  TRY.
      CL_SALV_TABLE=>FACTORY( IMPORTING
                                R_SALV_TABLE   = SALV_TABLE
                              CHANGING
                                T_TABLE        = IT_DATA[] ).

      R_COLUMNS = SALV_TABLE->GET_COLUMNS( ).
      R_AGGREGATIONS = SALV_TABLE->GET_AGGREGATIONS( ).
      RT_FIELDCAT = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG( R_COLUMNS = R_COLUMNS R_AGGREGATIONS = R_AGGREGATIONS ).

    CATCH CX_ROOT INTO LX_ROOT.
      LV_TEXT = LX_ROOT->GET_TEXT( ).
      RAISE ERROR_IN_GET_FIELDCAT.


  ENDTRY.

  endmethod.


  method MT_GET_DEFAULT_LAYOUT.


  CLEAR es_layout.

  es_layout-DETAILINIT = 'X'.        "Detail## NULL### ###
  es_layout-SEL_MODE   = 'D'.        "Selection mode(A,B,C,D)
  es_layout-NO_ROWINS  = 'X'.
  es_layout-NO_ROWMOVE = 'X'.
  es_layout-SMALLTITLE = 'X'.
  es_layout-ZEBRA = 'X'.
*  es_layout-STYLEFNAME = 'CELLTAB'.  "Input/Output ##
*  es_layout-CTAB_FNAME = 'CELLCOL'.  "Color ##


*  es_layout-INFO_FNAME = 'CELLINF'.    "### ##

  IF es_layout-NO_TOOLBAR = ''.
*    PERFORM ALV_EX_TOOLBAR USING 'GT_EXCLUDE'.
  ENDIF.

  endmethod.


  method MT_REFRESH_OO_ALV.

      DATA: LS_STBL TYPE LVC_S_STBL,
        L_SOFT_REFRESH.

  LS_STBL-ROW = 'X'.
  LS_STBL-COL = 'X'.

  CALL METHOD GO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STBL
      I_SOFT_REFRESH = L_SOFT_REFRESH.



  endmethod.


  method MT_SPLIT_CONTAINER.


  DATA LV_ROW TYPE I.
  DATA LV_COL TYPE I.
  DATA LS_SPLITS TYPE ZCM_OOALV_SPLIT_LIST.

  DATA: LO_CC TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
  DATA: LO_SPLIT TYPE REF TO CL_GUI_SPLITTER_CONTAINER.
  DATA: LO_SPLIT_CC1 TYPE REF TO CL_GUI_CONTAINER.

  CREATE OBJECT LO_CC
    EXPORTING
      CONTAINER_NAME = IV_CONTAINER_NAME.

  IF LO_CC IS BOUND.

    CREATE OBJECT LO_SPLIT
      EXPORTING
        PARENT  = LO_CC
        ROWS    = I_ROW
        COLUMNS = I_COL.

  ENDIF.

  LV_ROW = 1.
  LV_COL = 1.

  DO.
    CALL METHOD LO_SPLIT->GET_CONTAINER
      EXPORTING
        ROW       = LV_ROW
        COLUMN    = LV_COL
      RECEIVING
        CONTAINER = LO_SPLIT_CC1.

    CHECK LO_SPLIT_CC1 IS BOUND.
    LS_SPLITS-ROW = LV_ROW.
    LS_SPLITS-COL = LV_COL.
    LS_SPLITS-CONTAINER = LO_SPLIT_CC1.
    APPEND LS_SPLITS TO ET_CONTAINER_T.
    CLEAR LS_SPLITS.

    IF LV_COL < I_COL.
      LV_COL = LV_COL + 1.
    ELSE.
      IF LV_ROW < I_ROW.
        LV_ROW = LV_ROW + 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.
    CLEAR LO_SPLIT_CC1.
  ENDDO.

  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_AFTER_USER_COMMAND.


  PERFORM (ZIF_CM_OOALV_EVENT~AFTER_USER_COMMAND_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                    E_UCOMM
                                    E_SAVED
                                    E_NOT_PROCESSED.

*
**&---------------------------------------------------------------------*
**&      Form  ALV_AFTER_USER_COMMAND
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NM        text
**      -->E_UCOMM          text
**      -->E_SAVED          text
**      -->E_NOT_PROCESSED  text
**----------------------------------------------------------------------*
*FORM FRM_ALV_AFTER_USER_COMMAND USING P_GRID_NM
*                                  E_UCOMM LIKE SY-UCOMM
*                                  E_SAVED
*                                  E_NOT_PROCESSED.
*
*ENDFORM.                    " ALV_AFTER_USER_COMMAND

  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_BEFORE_USER_COMMAND.


    PERFORM (ZIF_CM_OOALV_EVENT~BEFORE_USER_COMMAND_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                    E_UCOMM.

**&---------------------------------------------------------------------*
**&      Form  ALV_BEFORE_USER_COMMAND
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NM  text
**      -->E_UCOMM    text
**----------------------------------------------------------------------*
*FORM FRM_ALV_BEFORE_USER_COMMAND USING P_GRID_NM
*                                   E_UCOMM LIKE SY-UCOMM.
*
*ENDFORM.                    "ALV_BEFORE_USER_COMMAND

  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_BUTTON_CLICK.


    PERFORM (ZIF_CM_OOALV_EVENT~BUTTON_CLICK_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                        ES_COL_ID
                                        ES_ROW_NO.
*
**&---------------------------------------------------------------------*
**&      Form  ALV_BUTTON_CLICK
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NAME  text
**      -->PS_COL_ID    text
**      -->PS_ROW_NO    text
**----------------------------------------------------------------------*
*FORM FRM_ALV_BUTTON_CLICK USING P_GRID_NAME
*                            PS_COL_ID TYPE LVC_S_COL
*                            PS_ROW_NO TYPE LVC_S_ROID.
*
**  <Botton Parameters--begin>
**  LS_OUT-ICONNAME = ICON_EXPORT."/Internal Table field value/
**  LS_FCAT-FIELDNAME = 'ICONNAME'.
**  LS_FCAT-OUTPUTLEN = 3.
**  LS_FCAT-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
**  LS_FCAT-REPTEXT = 'Button'.
**  <Botton Parameters--end>
*  DATA: LS_OUT TYPE TY_OUT.
*  READ TABLE GT_OUT INTO LS_OUT INDEX PS_ROW_NO-ROW_ID .
*
*
*ENDFORM.                    "ALV_BUTTON_CLICK
*

  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_CONTEXT_MENU.


    PERFORM (ZIF_CM_OOALV_EVENT~CONTEXT_MENU_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                        E_OBJECT.

**&---------------------------------------------------------------------*
**&      Form  FRM_ALV_CONTEXT_MENU
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NAME  text
**      -->P_OBJECT     text
**----------------------------------------------------------------------*
*FORM FRM_ALV_CONTEXT_MENU USING P_GRID_NAME
*                            P_OBJECT TYPE REF TO CL_CTMENU
*                            .
*  BREAK SUNHM.
*
***------ 上下文菜单实现 -------
**  CALL METHOD cl_ctmenu=>load_gui_status
**    EXPORTING
**      program = sy-repid"SY-REPID指的是本程序
**      status  = 'CONTEXT_MENUS'"定义的上下文菜单id
**      menu    = P_OBJECT.
**
*
*  "N个菜单就调用N次method.
*  CALL METHOD P_OBJECT->ADD_FUNCTION
*    EXPORTING
*      FCODE = '&DEL1'
*      TEXT  = '删除1'.
*
*  "N个菜单就调用N次method.
*  CALL METHOD P_OBJECT->ADD_FUNCTION
*    EXPORTING
*      FCODE = '&DEL2'
*      TEXT  = '删除2'.
*
*
*ENDFORM.                    "ALV_BUTTON_CLICK
  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED.

      PERFORM (ZIF_CM_OOALV_EVENT~DATA_CHANGED_FORM) IN PROGRAM (GV_REPID) IF FOUND
                                USING GV_GRID_NAME
                                        ER_DATA_CHANGED
                                        E_ONF4
                                        E_ONF4_BEFORE
                                        E_ONF4_AFTER
                                        E_UCOMM.

**&---------------------------------------------------------------------*
**&      Form  ALV_DATA_CHANGED
**&---------------------------------------------------------------------*
**       FORM DEMO
**----------------------------------------------------------------------*
**      -->P_GRID_NM        text
**      -->ER_DATA_CHANGED  text
**      -->E_ONF4           text
**      -->E_ONF4_BEFORE    text
**      -->E_ONF4_AFTER     text
**      -->E_UCOMM          text
**----------------------------------------------------------------------*
*FORM FRM_ALV_DATA_CHANGED USING P_GRID_NM
*                            ER_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
*                            E_ONF4
*                            E_ONF4_BEFORE
*                            E_ONF4_AFTER
*                            E_UCOMM.
*
**  DATA: LT_DATA   TYPE  LVC_T_MODI,
**        LS_DATA   TYPE  LVC_S_MODI.
**  FIELD-SYMBOLS: <FS_OUT> TYPE TY_OUT.
**
**  IF E_ONF4 = 'X' AND E_ONF4_BEFORE = 'X' AND E_ONF4_AFTER = ''.
**    EXIT.
**  ENDIF.
**
**
***  lT_DATA = ER_DATA_CHANGED->MT_MOD_CELLS.
**  LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO LS_DATA .
**    READ TABLE GT_OUT ASSIGNING <FS_OUT> INDEX LS_DATA-ROW_ID.
**  ENDLOOP.
*
*ENDFORM.                    "ALV_DATA_CHANGED


  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED_FINISHED.

  PERFORM (ZIF_CM_OOALV_EVENT~DATA_CHANGED_FINISHED_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                    E_MODIFIED
                                    ET_GOOD_CELLS.


**&---------------------------------------------------------------------*
**&      Form  ALV_DATA_CHANGED_FINISHED
**&---------------------------------------------------------------------*
**       FORM DEMO
**----------------------------------------------------------------------*
**      -->P_GRID_NAME    text
**      -->E_MODIFIED     text
**      -->ET_GOOD_CELLS  text
**----------------------------------------------------------------------*
*FORM FRM_ALV_DATA_CHANGED_FINISHED USING P_GRID_NAME
*                                     E_MODIFIED    TYPE CHAR01
*                                     ET_GOOD_CELLS TYPE LVC_T_MODI.
**
**  DATA: LS_MODI TYPE LVC_S_MODI.
**  DATA: LS_OUT TYPE TY_OUT.
**
**  IF E_MODIFIED = ''. EXIT. ENDIF.
**
**  LOOP AT ET_GOOD_CELLS INTO LS_MODI.
**
**    READ TABLE GT_OUT INTO LS_OUT INDEX LS_MODI-ROW_ID.
**    IF SY-SUBRC <> 0.
**      MESSAGE E899(MM) WITH 'IT READ ERROR'.
**    ENDIF.
**
**    MODIFY GT_OUT FROM LS_OUT.
**
**  ENDLOOP.
**
**  PERFORM FRM_ALV_REFRESH USING GO_GRID GT_FCAT[] 'F'.
*
*ENDFORM.                    "ALV_DATA_CHANGED_FINISHED
  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_DOUBLE_CLICK.

    PERFORM (ZIF_CM_OOALV_EVENT~DOUBLE_CLICK_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                        E_ROW
                                        E_COLUMN
                                        ES_ROW_NO.

**&---------------------------------------------------------------------*
**&      Form  ALV_DOUBLE_CLICK
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NM  text
**      -->P_ROW      text
**      -->P_COL      text
**----------------------------------------------------------------------*
*FORM FRM_ALV_DOUBLE_CLICK USING P_GRID_NM
*                            P_ROW TYPE LVC_S_ROW
*                            P_COL TYPE LVC_S_COL
*                            P_COL_N TYPE LVC_S_ROID.
**  BREAK SUNHM.
*** ## PAI # ### # ##
**  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
**    EXPORTING
**      NEW_CODE = 'ALV_DBL_CLK'.
**
*
**  DATA:LS_OUT TYPE TY_OUT.
**  READ TABLE GT_OUT INTO LS_OUT INDEX P_COL_N-ROW_ID.
**  IF P_COL-FIELDNAME = ''.
**  ENDIF.
*
*ENDFORM.                    "ALV_DOUBLE_CLICK
  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_HOTSPOT_CLICK.



    PERFORM (ZIF_CM_OOALV_EVENT~HOTSPOT_CLICK_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                        E_ROW_ID
                                        E_COLUMN_ID
                                        ES_ROW_NO.


**&---------------------------------------------------------------------*
**&      Form  FRM_ALV_HOTSPOTE_CLICK
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NM  text
**      -->P_ROW      text
**      -->P_COL      text
**----------------------------------------------------------------------*
*FORM FRM_ALV_HOTSPOTE_CLICK USING P_GRID_NM
*                            P_ROW TYPE LVC_S_ROW
*                            P_COL TYPE LVC_S_COL
*                            P_COL_N TYPE LVC_S_ROID.
*
*
**  <HOTSPOTE Parameters--begin>
**  LS_FCAT-fieldname = 'ICONNAME'.
**  LS_FCAT-HOTSPOTE = 'X'.
**  <HOTSPOTE Parameters--end>
*
**  DATA:LS_OUT TYPE TY_OUT.
**  READ TABLE GT_OUT INTO LS_OUT INDEX P_COL_N-ROW_ID. " 判断行号
**  CASE P_COL-FIELDNAME = ''. " 判断列名
**    WHEN 'NAME1'.
**    WHEN 'ZICON'.         "
**    WHEN OTHERS.
**  ENDCASE.
*  BREAK SUNHM.
*
*
*ENDFORM.                    "ALV_DOUBLE_CLICK


  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_MENU_BUTTON.


  PERFORM (ZIF_CM_OOALV_EVENT~MENU_BUTTON_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                        E_OBJECT
                                        E_UCOMM.

**&---------------------------------------------------------------------*
**&      Form  FRM_ALV_MENU_BUTTON
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NAME  text
**      -->P_OBJECT     text
**----------------------------------------------------------------------*
*FORM FRM_ALV_MENU_BUTTON USING P_GRID_NAME
*                            P_OBJECT TYPE REF TO CL_CTMENU
*                            E_UCOMM LIKE SY-UCOMM
*                            .
*  BREAK SUNHM.
*  IF E_UCOMM = 'B_LIST'.
*    CALL METHOD P_OBJECT->ADD_FUNCTION
*      EXPORTING
*        ICON  = ICON_DISPLAY
*        FCODE = 'B_SUM'
*        TEXT  = '显示 ALV 总数'.
*  ENDIF.
*
*ENDFORM.                    "ALV_BUTTON_CLICK
  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_ON_F4.


    PERFORM (ZIF_CM_OOALV_EVENT~ON_F4_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                 SENDER
                                 E_FIELDNAME
                                 E_FIELDVALUE
                                 ES_ROW_NO
                                 ER_EVENT_DATA
                                 ET_BAD_CELLS
                                 E_DISPLAY.

**&---------------------------------------------------------------------*
**&      Form  ALV_F4
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NM      text
**      -->PO_SENDER      text
**      -->P_FIELDNAME    text
**      -->P_FIELDVALUE   text
**      -->PS_ROW_NO      text
**      -->PO_EVENT_DATA  text
**      -->PT_BAD_CELLS   text
**      -->P_DISPLAY      text
**----------------------------------------------------------------------*
*FORM FRM_ALV_ON_F4  USING P_GRID_NM
*                   PO_SENDER      TYPE REF TO CL_GUI_ALV_GRID
*                   P_FIELDNAME    TYPE LVC_FNAME
*                   P_FIELDVALUE   TYPE LVC_VALUE
*                   PS_ROW_NO      TYPE LVC_S_ROID
*                   PO_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
*                   PT_BAD_CELLS   TYPE LVC_T_MODI
*                   P_DISPLAY      TYPE CHAR01.
*
*
**  <F4 Parameters--begin>
**  LS_FCAT-fieldname = 'ICONNAME'.
**  LS_FCAT-F4AVAILABL = 'X'.
**  <F4 Parameters--end>
*  BREAK SUNHM.
*  CASE  P_FIELDNAME.
*    WHEN 'CARRID'.
*      PERFORM FRM_F4_CARRID   USING P_FIELDNAME PS_ROW_NO PO_EVENT_DATA.
*    WHEN OTHERS.
*  ENDCASE.
*
*  PERFORM FRM_ALV_REFRESH USING GO_GRID GT_FCAT[] 'F'.
*
*ENDFORM.                    "FRM_ALV_ON_F4
  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_TOOLBAR.


  PERFORM (ZIF_CM_OOALV_EVENT~TOOLBAR_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                   E_OBJECT
                                   E_INTERACTIVE.

*
**&---------------------------------------------------------------------*
**&      Form  ALV_TOOLBAR
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NM      text
**      -->E_OBJECT       text
**      -->E_INTERACTIVE  text
**----------------------------------------------------------------------*
*FORM FRM_ALV_TOOLBAR USING P_GRID_NM
*                       E_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
*                       E_INTERACTIVE.
*
*
*  DATA: LS_TOOLBAR TYPE STB_BUTTON.
**
*** Seperator
**  LS_TOOLBAR-FUNCTION  = 'DUMMY'.
**  LS_TOOLBAR-BUTN_TYPE = '3'.
**  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
**
*** Normal Button
**  CLEAR LS_TOOLBAR.
**  LS_TOOLBAR-FUNCTION  = '&INS'.
**  LS_TOOLBAR-ICON      = ICON_INSERT_ROW.
**  LS_TOOLBAR-BUTN_TYPE = '0'.
**  LS_TOOLBAR-DISABLED  = SPACE.
**  LS_TOOLBAR-TEXT      = '插入行'.
**  LS_TOOLBAR-QUICKINFO = '插入行'.
**  LS_TOOLBAR-CHECKED   = SPACE.
**  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*
** Normal Button
*  CLEAR LS_TOOLBAR.
*  LS_TOOLBAR-FUNCTION  = 'B_LIST'.
*  LS_TOOLBAR-ICON      = ICON_BIW_REPORT_VIEW.
*  LS_TOOLBAR-BUTN_TYPE = '1'.
*  LS_TOOLBAR-DISABLED  = SPACE.
*  LS_TOOLBAR-TEXT      = '自定义下拉菜单'.
*  LS_TOOLBAR-QUICKINFO = '下拉菜单'.
*  LS_TOOLBAR-CHECKED   = SPACE.
*  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*
*ENDFORM.                    "ALV_TOOLBAR
  endmethod.


  method ZIF_CM_OOALV_EVENT~HANDLE_USER_COMMAND.

     PERFORM (ZIF_CM_OOALV_EVENT~USER_COMMAND_FORM) IN PROGRAM (GV_REPID) IF FOUND
                                  USING GV_GRID_NAME
                                        E_UCOMM.
*
*&---------------------------------------------------------------------*
*&      Form  ALV_USER_COMMAND
*&---------------------------------------------------------------------*
*       FORM 示例
*----------------------------------------------------------------------*
*      -->P_GRID_NM  text
*      -->E_UCOMM    text
*----------------------------------------------------------------------*
**FORM FRM_ALV_USER_COMMAND USING P_GRID_NM
**                            E_UCOMM LIKE SY-UCOMM.
*
**  CASE E_UCOMM .
**    WHEN '&INS'.
**    WHEN 'DUMMY'.
**    WHEN OTHERS.
**  ENDCASE.
**ENDFORM.                    "handle_before_ucomm

  endmethod.


  method ZIF_CM_OOALV_EVENT~PRINT_TOP_OF_PAGE.

  PERFORM (ZIF_CM_OOALV_EVENT~TOP_OF_PAGE_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME.


**&---------------------------------------------------------------------*
**&      Form  ALV_TOP_OF_PAGE
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NAME  text
**----------------------------------------------------------------------*
*FORM FRM_ALV_TOP_OF_PAGE USING P_GRID_NAME.
*
*
*ENDFORM.                    "ALV_TOP_OF_PAGE

  endmethod.
ENDCLASS.
