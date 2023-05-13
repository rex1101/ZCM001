*&---------------------------------------------------------------------*
*&  Include           YOALV_ALV
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* LOCAL CLASSES: Definition
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.

    DATA: G_OBJECT_TEXT TYPE CHAR30.

    INTERFACES ZIF_CM_OOALV_EVENT .
    METHODS: CONSTRUCTOR
               IMPORTING E_OBJECT_TEXT TYPE C.
ENDCLASS.                    "LCL_EVENT_RECEIVER2 DEFINITION

DATA: G_CPROG LIKE SY-CPROG.
DATA: G_OKCD  LIKE SY-UCOMM,
      G_UCOM  LIKE SY-UCOMM,
      G_ERROR.
DATA: GV_FCAT_STR TYPE DD02L-TABNAME.
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

*----------------------------------------------------------------------*
* LOCAL CLASSES: Implementation
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

  METHOD CONSTRUCTOR.
    CALL METHOD SUPER->CONSTRUCTOR.
    G_OBJECT_TEXT = E_OBJECT_TEXT.
  ENDMETHOD.                    "CONSTRUCTOR
  METHOD ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED.
    PERFORM FRM_ALV_DATA_CHANGED IN PROGRAM (G_CPROG) IF FOUND
                                  USING G_OBJECT_TEXT
                                        ER_DATA_CHANGED
                                        E_ONF4
                                        E_ONF4_BEFORE
                                        E_ONF4_AFTER
                                        E_UCOMM.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED
  METHOD ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED_FINISHED.
    PERFORM FRM_ALV_DATA_CHANGED_FINISHED IN PROGRAM (G_CPROG) IF FOUND
                                           USING G_OBJECT_TEXT
                                                 E_MODIFIED
                                                 ET_GOOD_CELLS.
  ENDMETHOD.                    "HANDLE_DATA_CHANGED_FINISHED
  METHOD ZIF_CM_OOALV_EVENT~HANDLE_DOUBLE_CLICK.
    PERFORM FRM_ALV_DOUBLE_CLICK IN PROGRAM (G_CPROG) IF FOUND
                                  USING G_OBJECT_TEXT
                                        E_ROW
                                        E_COLUMN
                                        ES_ROW_NO.
  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_HOTSPOT_CLICK.
    PERFORM FRM_ALV_HOTSPOTE_CLICK IN PROGRAM (G_CPROG) IF FOUND
                                  USING G_OBJECT_TEXT
                                        E_ROW_ID
                                        E_COLUMN_ID
                                        ES_ROW_NO.
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD ZIF_CM_OOALV_EVENT~PRINT_TOP_OF_PAGE.
    PERFORM FRM_ALV_TOP_OF_PAGE IN PROGRAM (G_CPROG) IF FOUND
                                 USING G_OBJECT_TEXT.
  ENDMETHOD.                    "PRINT_TOP_OF_PAGE

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_ON_F4.
    PERFORM FRM_ALV_ON_F4 IN PROGRAM (G_CPROG) IF FOUND
                           USING G_OBJECT_TEXT
                                 SENDER
                                 E_FIELDNAME
                                 E_FIELDVALUE
                                 ES_ROW_NO
                                 ER_EVENT_DATA
                                 ET_BAD_CELLS
                                 E_DISPLAY.
  ENDMETHOD.                    "HANDLE_ON_F4

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_TOOLBAR.
    PERFORM FRM_ALV_TOOLBAR IN PROGRAM (G_CPROG) IF FOUND
                             USING G_OBJECT_TEXT
                                   E_OBJECT
                                   E_INTERACTIVE.
  ENDMETHOD.                    "HANDLE_TOOLBAR

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_BEFORE_USER_COMMAND.
    PERFORM FRM_ALV_BEFORE_USER_COMMAND IN PROGRAM (G_CPROG) IF FOUND
                                         USING G_OBJECT_TEXT
                                               E_UCOMM.
  ENDMETHOD.                    "HANDLE_BEFORE_USER_COMMAND

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_USER_COMMAND.
    PERFORM FRM_ALV_USER_COMMAND IN PROGRAM (G_CPROG) IF FOUND
                                  USING G_OBJECT_TEXT
                                        E_UCOMM.
  ENDMETHOD.                    "HANDLE_USER_COMMAND

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_AFTER_USER_COMMAND.
    PERFORM FRM_ALV_AFTER_USER_COMMAND IN PROGRAM (G_CPROG) IF FOUND
                                        USING G_OBJECT_TEXT
                                              E_UCOMM
                                              E_SAVED
                                              E_NOT_PROCESSED.
  ENDMETHOD.                    "HANDLE_AFTER_USER_COMMAND

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_BUTTON_CLICK.
    PERFORM FRM_ALV_BUTTON_CLICK IN PROGRAM (G_CPROG) IF FOUND
                                  USING G_OBJECT_TEXT
                                        ES_COL_ID
                                        ES_ROW_NO.
  ENDMETHOD.                    "HANDLE_BUTTON_CLICK

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_CONTEXT_MENU.
    PERFORM FRM_ALV_CONTEXT_MENU IN PROGRAM (G_CPROG) IF FOUND
                                  USING G_OBJECT_TEXT
                                        E_OBJECT.
  ENDMETHOD.                    "HANDLE_CONTEXT_MENU

  METHOD ZIF_CM_OOALV_EVENT~HANDLE_MENU_BUTTON.
    PERFORM FRM_ALV_MENU_BUTTON IN PROGRAM (G_CPROG) IF FOUND
                                  USING G_OBJECT_TEXT
                                        E_OBJECT
                                        E_UCOMM.
  ENDMETHOD.                    "HANDLE_CONTEXT_MENU

  METHOD ZIF_CM_OOALV_EVENT~FREE.
    CLEAR:G_OBJECT_TEXT.
  ENDMETHOD.                    "free

ENDCLASS. "LCL_EVENT_RECEIVER IMPLEMENTATION



*&---------------------------------------------------------------------*
*&      Form  ALV_DATA_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM        text
*      -->ER_DATA_CHANGED  text
*      -->E_ONF4           text
*      -->E_ONF4_BEFORE    text
*      -->E_ONF4_AFTER     text
*      -->E_UCOMM          text
*----------------------------------------------------------------------*
FORM FRM_ALV_DATA_CHANGED USING P_GRID_NM
                            ER_DATA_CHANGED TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                            E_ONF4
                            E_ONF4_BEFORE
                            E_ONF4_AFTER
                            E_UCOMM.

*  DATA: LT_DATA   TYPE  LVC_T_MODI,
*        LS_DATA   TYPE  LVC_S_MODI.
*  FIELD-SYMBOLS: <FS_OUT> TYPE TY_OUT.
*
*  IF E_ONF4 = 'X' AND E_ONF4_BEFORE = 'X' AND E_ONF4_AFTER = ''.
*    EXIT.
*  ENDIF.
*
*
**  lT_DATA = ER_DATA_CHANGED->MT_MOD_CELLS.
*  LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO LS_DATA .
*    READ TABLE GT_OUT ASSIGNING <FS_OUT> INDEX LS_DATA-ROW_ID.
*  ENDLOOP.

ENDFORM.                    "ALV_DATA_CHANGED

*&---------------------------------------------------------------------*
*&      Form  ALV_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NAME    text
*      -->E_MODIFIED     text
*      -->ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM FRM_ALV_DATA_CHANGED_FINISHED USING P_GRID_NAME
                                     E_MODIFIED    TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.
*
*  DATA: LS_MODI TYPE LVC_S_MODI.
*  DATA: LS_OUT TYPE TY_OUT.
*
*  IF E_MODIFIED = ''. EXIT. ENDIF.
*
*  LOOP AT ET_GOOD_CELLS INTO LS_MODI.
*
*    READ TABLE GT_OUT INTO LS_OUT INDEX LS_MODI-ROW_ID.
*    IF SY-SUBRC <> 0.
*      MESSAGE E899(MM) WITH 'IT READ ERROR'.
*    ENDIF.
*
*    MODIFY GT_OUT FROM LS_OUT.
*
*  ENDLOOP.
*
*  PERFORM FRM_ALV_REFRESH USING GO_GRID GT_FCAT[] 'F'.

ENDFORM.                    "ALV_DATA_CHANGED_FINISHED

*&---------------------------------------------------------------------*
*&      Form  ALV_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM  text
*      -->P_ROW      text
*      -->P_COL      text
*----------------------------------------------------------------------*
FORM FRM_ALV_DOUBLE_CLICK USING P_GRID_NM
                            P_ROW TYPE LVC_S_ROW
                            P_COL TYPE LVC_S_COL
                            P_COL_N TYPE LVC_S_ROID.
*  BREAK SUNHM.
** ## PAI # ### # ##
*  CALL METHOD CL_GUI_CFW=>SET_NEW_OK_CODE
*    EXPORTING
*      NEW_CODE = 'ALV_DBL_CLK'.
*

*  DATA:LS_OUT TYPE TY_OUT.
*  READ TABLE GT_OUT INTO LS_OUT INDEX P_COL_N-ROW_ID.
*  IF P_COL-FIELDNAME = ''.
*  ENDIF.

ENDFORM.                    "ALV_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  FRM_ALV_HOTSPOTE_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM  text
*      -->P_ROW      text
*      -->P_COL      text
*----------------------------------------------------------------------*
FORM FRM_ALV_HOTSPOTE_CLICK USING P_GRID_NM
                            P_ROW TYPE LVC_S_ROW
                            P_COL TYPE LVC_S_COL
                            P_COL_N TYPE LVC_S_ROID.


*  <HOTSPOTE Parameters--begin>
*  LS_FCAT-fieldname = 'ICONNAME'.
*  LS_FCAT-HOTSPOTE = 'X'.
*  <HOTSPOTE Parameters--end>

*  DATA:LS_OUT TYPE TY_OUT.
*  READ TABLE GT_OUT INTO LS_OUT INDEX P_COL_N-ROW_ID. " 判断行号
*  CASE P_COL-FIELDNAME = ''. " 判断列名
*    WHEN 'NAME1'.
*    WHEN 'ZICON'.         "
*    WHEN OTHERS.
*  ENDCASE.
  BREAK SUNHM.


ENDFORM.                    "ALV_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NAME  text
*----------------------------------------------------------------------*
FORM FRM_ALV_TOP_OF_PAGE USING P_GRID_NAME.


ENDFORM.                    "ALV_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  ALV_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM      text
*      -->PO_SENDER      text
*      -->P_FIELDNAME    text
*      -->P_FIELDVALUE   text
*      -->PS_ROW_NO      text
*      -->PO_EVENT_DATA  text
*      -->PT_BAD_CELLS   text
*      -->P_DISPLAY      text
*----------------------------------------------------------------------*
FORM FRM_ALV_ON_F4  USING P_GRID_NM
                   PO_SENDER      TYPE REF TO CL_GUI_ALV_GRID
                   P_FIELDNAME    TYPE LVC_FNAME
                   P_FIELDVALUE   TYPE LVC_VALUE
                   PS_ROW_NO      TYPE LVC_S_ROID
                   PO_EVENT_DATA  TYPE REF TO CL_ALV_EVENT_DATA
                   PT_BAD_CELLS   TYPE LVC_T_MODI
                   P_DISPLAY      TYPE CHAR01.


*  <F4 Parameters--begin>
*  LS_FCAT-fieldname = 'ICONNAME'.
*  LS_FCAT-F4AVAILABL = 'X'.
*  <F4 Parameters--end>
  BREAK SUNHM.
  CASE  P_FIELDNAME.
    WHEN 'CARRID'.
      PERFORM FRM_F4_CARRID   USING P_FIELDNAME PS_ROW_NO PO_EVENT_DATA.
    WHEN OTHERS.
  ENDCASE.

  PERFORM FRM_ALV_REFRESH USING GO_GRID GT_FCAT[] 'F'.

ENDFORM.                    "FRM_ALV_ON_F4

*&---------------------------------------------------------------------*
*&      Form  ALV_TOOLBAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM      text
*      -->E_OBJECT       text
*      -->E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM FRM_ALV_TOOLBAR USING P_GRID_NM
                       E_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                       E_INTERACTIVE.


  DATA: LS_TOOLBAR TYPE STB_BUTTON.
*
** Seperator
*  LS_TOOLBAR-FUNCTION  = 'DUMMY'.
*  LS_TOOLBAR-BUTN_TYPE = '3'.
*  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
*
** Normal Button
*  CLEAR LS_TOOLBAR.
*  LS_TOOLBAR-FUNCTION  = '&INS'.
*  LS_TOOLBAR-ICON      = ICON_INSERT_ROW.
*  LS_TOOLBAR-BUTN_TYPE = '0'.
*  LS_TOOLBAR-DISABLED  = SPACE.
*  LS_TOOLBAR-TEXT      = '插入行'.
*  LS_TOOLBAR-QUICKINFO = '插入行'.
*  LS_TOOLBAR-CHECKED   = SPACE.
*  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* Normal Button
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION  = 'B_LIST'.
  LS_TOOLBAR-ICON      = ICON_BIW_REPORT_VIEW.
  LS_TOOLBAR-BUTN_TYPE = '1'.
  LS_TOOLBAR-DISABLED  = SPACE.
  LS_TOOLBAR-TEXT      = '自定义下拉菜单'.
  LS_TOOLBAR-QUICKINFO = '下拉菜单'.
  LS_TOOLBAR-CHECKED   = SPACE.
  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

ENDFORM.                    "ALV_TOOLBAR
*&---------------------------------------------------------------------*
*&      Form  ALV_BEFORE_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM  text
*      -->E_UCOMM    text
*----------------------------------------------------------------------*
FORM FRM_ALV_BEFORE_USER_COMMAND USING P_GRID_NM
                                   E_UCOMM LIKE SY-UCOMM.

ENDFORM.                    "ALV_BEFORE_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  ALV_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM  text
*      -->E_UCOMM    text
*----------------------------------------------------------------------*
FORM FRM_ALV_USER_COMMAND USING P_GRID_NM
                            E_UCOMM LIKE SY-UCOMM.

*  CASE E_UCOMM .
*    WHEN '&INS'.
*    WHEN 'DUMMY'.
*    WHEN OTHERS.
*  ENDCASE.

ENDFORM.                    "ALV_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_AFTER_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NM        text
*      -->E_UCOMM          text
*      -->E_SAVED          text
*      -->E_NOT_PROCESSED  text
*----------------------------------------------------------------------*
FORM FRM_ALV_AFTER_USER_COMMAND USING P_GRID_NM
                                  E_UCOMM LIKE SY-UCOMM
                                  E_SAVED
                                  E_NOT_PROCESSED.

ENDFORM.                    " ALV_AFTER_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_BUTTON_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NAME  text
*      -->PS_COL_ID    text
*      -->PS_ROW_NO    text
*----------------------------------------------------------------------*
FORM FRM_ALV_BUTTON_CLICK USING P_GRID_NAME
                            PS_COL_ID TYPE LVC_S_COL
                            PS_ROW_NO TYPE LVC_S_ROID.

*  <Botton Parameters--begin>
*  LS_OUT-ICONNAME = ICON_EXPORT."/Internal Table field value/
*  LS_FCAT-FIELDNAME = 'ICONNAME'.
*  LS_FCAT-OUTPUTLEN = 3.
*  LS_FCAT-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
*  LS_FCAT-REPTEXT = 'Button'.
*  <Botton Parameters--end>
  DATA: LS_OUT TYPE TY_OUT.
  READ TABLE GT_OUT INTO LS_OUT INDEX PS_ROW_NO-ROW_ID .


ENDFORM.                    "ALV_BUTTON_CLICK
*&---------------------------------------------------------------------*
*&      Form  FRM_ALV_CONTEXT_MENU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NAME  text
*      -->P_OBJECT     text
*----------------------------------------------------------------------*
FORM FRM_ALV_CONTEXT_MENU USING P_GRID_NAME
                            P_OBJECT TYPE REF TO CL_CTMENU
                            .
  BREAK SUNHM.

**------ 上下文菜单实现 -------
*  CALL METHOD cl_ctmenu=>load_gui_status
*    EXPORTING
*      program = sy-repid"SY-REPID指的是本程序
*      status  = 'CONTEXT_MENUS'"定义的上下文菜单id
*      menu    = P_OBJECT.
*

  "N个菜单就调用N次method.
  CALL METHOD P_OBJECT->ADD_FUNCTION
    EXPORTING
      FCODE = '&DEL1'
      TEXT  = '删除1'.

  "N个菜单就调用N次method.
  CALL METHOD P_OBJECT->ADD_FUNCTION
    EXPORTING
      FCODE = '&DEL2'
      TEXT  = '删除2'.


ENDFORM.                    "ALV_BUTTON_CLICK
*&---------------------------------------------------------------------*
*&      Form  FRM_ALV_MENU_BUTTON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GRID_NAME  text
*      -->P_OBJECT     text
*----------------------------------------------------------------------*
FORM FRM_ALV_MENU_BUTTON USING P_GRID_NAME
                            P_OBJECT TYPE REF TO CL_CTMENU
                            E_UCOMM LIKE SY-UCOMM
                            .
  BREAK SUNHM.
  IF E_UCOMM = 'B_LIST'.
    CALL METHOD P_OBJECT->ADD_FUNCTION
      EXPORTING
        ICON  = ICON_DISPLAY
        FCODE = 'B_SUM'
        TEXT  = '显示 ALV 总数'.
  ENDIF.

ENDFORM.                    "ALV_BUTTON_CLICK
*&---------------------------------------------------------------------*
*&      Form  ALV_GET_CURSOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_GRID    text
*      -->P_ROW_ID   text
*      -->P_COL_NM   text
*----------------------------------------------------------------------*
FORM FRM_ALV_GET_CURSOR USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID
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

ENDFORM.                    "ALV_GET_CURSOR
*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EDIT     text
*      -->P_COLOR    text
*      -->PS_LAYOUT  text
*----------------------------------------------------------------------*
FORM FRM_ALV_LAYOUT_INIT CHANGING PS_LAYOUT TYPE LVC_S_LAYO.

  CLEAR PS_LAYOUT.

  PS_LAYOUT-DETAILINIT = 'X'.        "Detail## NULL### ###
  PS_LAYOUT-SEL_MODE   = 'D'.        "Selection mode(A,B,C,D)
  PS_LAYOUT-NO_ROWINS  = 'X'.
  PS_LAYOUT-NO_ROWMOVE = 'X'.
  PS_LAYOUT-SMALLTITLE = 'X'.
  PS_LAYOUT-ZEBRA = 'X'.
  PS_LAYOUT-STYLEFNAME = 'CELLTAB'.  "Input/Output ##
  PS_LAYOUT-CTAB_FNAME = 'CELLCOL'.  "Color ##


  PS_LAYOUT-INFO_FNAME = 'CELLINF'.    "### ##

  GS_VARIANT-REPORT    = SY-REPID.    "Default Variant Set



  IF PS_LAYOUT-NO_TOOLBAR = ''.
    PERFORM ALV_EX_TOOLBAR USING 'GT_EXCLUDE'.
  ENDIF.


ENDFORM.                    "ALV_LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  ALV_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_GRID    text
*      -->PT_FCAT    text
*      -->P_GB       text
*----------------------------------------------------------------------*
FORM FRM_ALV_REFRESH USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
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
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT.
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


ENDFORM.                    "ALV_REFRESH
*&---------------------------------------------------------------------*
*&      Form  ALV_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_ALV_RELOAD.

  PERFORM FRM_ALV_REFRESH USING GO_GRID GT_FCAT[] 'F'.
** CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    "ALV_RELOAD
*&---------------------------------------------------------------------*
*&      Form  ALV_RELOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_ALV_FREE.

  IF GO_GRID IS NOT INITIAL.
    CALL METHOD GO_GRID->FREE.
  ENDIF.

  IF GO_GUI_CONT IS NOT INITIAL.
    CALL METHOD GO_GUI_CONT->FREE.
  ENDIF.

  IF GO_CONT IS NOT INITIAL.
    CALL METHOD GO_CONT->FREE.
  ENDIF.

  IF GO_EDITOR IS NOT INITIAL.
    CALL METHOD GO_EDITOR->FREE.
  ENDIF.
  IF GO_EVT_REC IS NOT INITIAL.
*    CALL METHOD GO_EVT_REC->FREE.
  ENDIF.

  CLEAR: GO_GUI_CONT,
         GO_CONT,
         GO_EDITOR,
         GO_EVT_REC,
         GO_GRID.

  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.                    "ALV_RELOAD
*&---------------------------------------------------------------------*
*&      Form  ALV_SET_CURSOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_GRID    text
*      -->P_ROWID    text
*      -->P_COLNM    text
*----------------------------------------------------------------------*
FORM FRM_ALV_SET_CURSOR USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
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

ENDFORM.                    "ALV_SET_CURSOR
*&---------------------------------------------------------------------*
*&      Form  ALV_SET_DDLB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_GRID    text
*      -->PT_DRAL    text
*----------------------------------------------------------------------*
FORM FRM_ALV_SET_DDLB USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
*                        PT_DROP TYPE        LVC_T_DROP.
                        PT_DRAL TYPE        LVC_T_DRAL.

  CALL METHOD PO_GRID->SET_DROP_DOWN_TABLE
    EXPORTING
*      IT_DROP_DOWN =       PT_DROP[].
      IT_DROP_DOWN_ALIAS = PT_DRAL[].

ENDFORM.                    "ALV_SET_DDLB
*&---------------------------------------------------------------------*
*&      Form  ALV_SET_MARK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_GRID    text
*      -->PT_ITAB    text
*----------------------------------------------------------------------*
FORM FRM_ALV_SET_MARK USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
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

ENDFORM.                    "ALV_SET_MARK
*&---------------------------------------------------------------------*
*&      Form  ALV_SET_SEL_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_GRID    text
*      -->P_ROW      text
*----------------------------------------------------------------------*
FORM FRM_ALV_SET_SEL_ROW USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
                           P_ROW.

  DATA: LT_ROW TYPE LVC_T_ROW WITH HEADER LINE.

  LT_ROW-INDEX = P_ROW.
  APPEND LT_ROW.

  CALL METHOD PO_GRID->SET_SELECTED_ROWS
    EXPORTING
      IT_INDEX_ROWS = LT_ROW[].
*      IT_ROW_NO                =
*      IS_KEEP_OTHER_SELECTIONS = 'X'.

ENDFORM.                    "ALV_SET_SEL_ROW
*&---------------------------------------------------------------------*
*&      Form  ALV_USER_COMM_FILTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PO_GRID    text
*      -->PT_FCAT    text
*      -->P_FNAME    text
*      -->P_VAL      text
*----------------------------------------------------------------------*
FORM FRM_ALV_USER_COMM_FILTER USING PO_GRID TYPE REF TO CL_GUI_ALV_GRID
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

  PERFORM FRM_ALV_REFRESH USING PO_GRID PT_FCAT[] 'A'.

ENDFORM.                    "ALV_USER_COMM_FILTER

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
   USING: CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL,      "## ####
    CL_GUI_ALV_GRID=>MC_FC_DETAIL,            "####
    CL_GUI_ALV_GRID=>MC_FC_REFRESH,           "Refresh

    CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           "### ####
    CL_GUI_ALV_GRID=>MC_FC_LOC_COPY,          "### ##
    CL_GUI_ALV_GRID=>MC_MB_PASTE,
    CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         "### ####
    CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW, "Paste new Row
    CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO,          "####

    CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    "# ##
    CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    "# ##
    CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    "# ##
    CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      "# ##

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

    CL_GUI_ALV_GRID=>MC_MB_FILTER,
    CL_GUI_ALV_GRID=>MC_FC_FILTER,            "Set ##
    CL_GUI_ALV_GRID=>MC_FC_DELETE_FILTER,     "Del ##

    CL_GUI_ALV_GRID=>MC_FC_SUM,               "Sum
    CL_GUI_ALV_GRID=>MC_FC_MINIMUM,           "Min
    CL_GUI_ALV_GRID=>MC_FC_MAXIMUM,           "Max
    CL_GUI_ALV_GRID=>MC_FC_AVERAGE,           "##
    CL_GUI_ALV_GRID=>MC_FC_AUF,               "####&AUF
    CL_GUI_ALV_GRID=>MC_FC_SUBTOT,            "Sub Sum

    CL_GUI_ALV_GRID=>MC_FC_PRINT,             "###
    CL_GUI_ALV_GRID=>MC_FC_PRINT_BACK,
    CL_GUI_ALV_GRID=>MC_FC_PRINT_PREV,

    CL_GUI_ALV_GRID=>MC_MB_EXPORT,            "
    CL_GUI_ALV_GRID=>MC_FC_DATA_SAVE,         "Export
    CL_GUI_ALV_GRID=>MC_FC_WORD_PROCESSOR,    "##
    CL_GUI_ALV_GRID=>MC_FC_PC_FILE,           "####
    CL_GUI_ALV_GRID=>MC_FC_SEND,              "Send
    CL_GUI_ALV_GRID=>MC_FC_TO_OFFICE,         "Office
    CL_GUI_ALV_GRID=>MC_FC_CALL_ABC,          "ABC##
    CL_GUI_ALV_GRID=>MC_FC_HTML,              "HTML

    CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT,      "####
    CL_GUI_ALV_GRID=>MC_FC_CURRENT_VARIANT,   "##
    CL_GUI_ALV_GRID=>MC_FC_SAVE_VARIANT,      "##
    CL_GUI_ALV_GRID=>MC_FC_MAINTAIN_VARIANT,  "Vari##

    CL_GUI_ALV_GRID=>MC_FC_COL_OPTIMIZE,      "Optimize
    CL_GUI_ALV_GRID=>MC_FC_SEPARATOR,         "###
    CL_GUI_ALV_GRID=>MC_FC_SELECT_ALL,        "####
    CL_GUI_ALV_GRID=>MC_FC_DESELECT_ALL,      "####
    CL_GUI_ALV_GRID=>MC_FC_COL_INVISIBLE,     "#####
    CL_GUI_ALV_GRID=>MC_FC_FIX_COLUMNS,       "####
    CL_GUI_ALV_GRID=>MC_FC_UNFIX_COLUMNS,     "######
    CL_GUI_ALV_GRID=>MC_FC_AVERAGE,           "Average         '&AVERAGE'

    CL_GUI_ALV_GRID=>MC_FC_F4,
    CL_GUI_ALV_GRID=>MC_FC_HELP,
    CL_GUI_ALV_GRID=>MC_FC_CALL_ABC,          "               '&ABC'
    CL_GUI_ALV_GRID=>MC_FC_CALL_CHAIN,
    CL_GUI_ALV_GRID=>MC_FC_BACK_CLASSIC,
    CL_GUI_ALV_GRID=>MC_FC_CALL_CRBATCH,
    CL_GUI_ALV_GRID=>MC_FC_CALL_CRWEB,
    CL_GUI_ALV_GRID=>MC_FC_CALL_LINEITEMS,
    CL_GUI_ALV_GRID=>MC_FC_CALL_MASTER_DATA,
    CL_GUI_ALV_GRID=>MC_FC_CALL_MORE,
    CL_GUI_ALV_GRID=>MC_FC_CALL_REPORT,
    CL_GUI_ALV_GRID=>MC_FC_CALL_XINT,
    CL_GUI_ALV_GRID=>MC_FC_CALL_XXL,
    CL_GUI_ALV_GRID=>MC_FC_EXPCRDATA,
    CL_GUI_ALV_GRID=>MC_FC_EXPCRDESIG,
    CL_GUI_ALV_GRID=>MC_FC_EXPCRTEMPL,
    CL_GUI_ALV_GRID=>MC_FC_EXPMDB,
    CL_GUI_ALV_GRID=>MC_FC_EXTEND,
    CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,

    CL_GUI_ALV_GRID=>MC_FC_REPREP,
    CL_GUI_ALV_GRID=>MC_FC_TO_REP_TREE.

ENDFORM.                    " ALV_EX_TOOLBAR

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
*&      Form  REGISTER_F4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GS_ALV     text
*----------------------------------------------------------------------*
FORM REGISTER_F4_PBO CHANGING PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LT_F4 TYPE LVC_T_F4 .
  DATA LS_F4 TYPE LVC_S_F4 .
  CLEAR LS_F4 .

  LS_F4-FIELDNAME = 'CARRID'.
  LS_F4-REGISTER  = 'X' .
  LS_F4-GETBEFORE = 'X'.
  LS_F4-CHNGEAFTER = 'X'.
  INSERT LS_F4 INTO TABLE LT_F4 .
  CLEAR LS_F4 .
  CALL METHOD PO_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].

ENDFORM.                    "ALV_EXCLUDE_TB_1
*&---------------------------------------------------------------------*
*&      Form  FRM_F4_CARRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_FLDNM   text
*      -->IS_ROW     text
*      -->IRF_EVT    text
*----------------------------------------------------------------------*
FORM FRM_F4_CARRID   USING IV_FLDNM TYPE LVC_FNAME
                            IS_ROW   TYPE LVC_S_ROID
                            IRF_EVT  TYPE REF TO CL_ALV_EVENT_DATA.


  DATA:BEGIN OF LT_SFLIGHT OCCURS 0,
        CARRID TYPE SFLIGHT-CARRID,
        CONNID TYPE SFLIGHT-CONNID,
      END OF LT_SFLIGHT.
  DATA:LT_RETURN TYPE TABLE OF DDSHRETVAL WITH HEADER LINE.


  SELECT CARRID
         CONNID
  INTO TABLE LT_SFLIGHT
  FROM SFLIGHT.

  DELETE ADJACENT DUPLICATES FROM LT_SFLIGHT.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD         = 'CARRID'            "lt内表里面的字段
      DYNPPROG         = SY-REPID
      DYNPNR           = SY-DYNNR
      DYNPROFIELD      = 'CARRID'            "画面上绑定字段
      VALUE_ORG        = 'S'
      CALLBACK_PROGRAM = SY-REPID
    TABLES
      VALUE_TAB        = LT_SFLIGHT           "需要显示帮助的值S内表
      RETURN_TAB       = LT_RETURN          "返回值
    EXCEPTIONS
      PARAMETER_ERROR  = 1
      NO_VALUES_FOUND  = 2
      OTHERS           = 3.

  IF SY-SUBRC = 0.
    READ TABLE LT_RETURN INDEX 1.
    IF SY-SUBRC = 0  AND LT_RETURN-FIELDVAL IS NOT INITIAL.

    ENDIF.
  ENDIF.



ENDFORM.                    "FRM_F4_CARRID
