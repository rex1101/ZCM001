class ZCL_CM_OOALV_EVENT_HANDLER definition
  public
  final
  create public .

public section.

  interfaces ZIF_CM_OOALV_EVENT .

  methods CONSTRUCTOR
  importing
      !IO_ALV type ref to CL_GUI_ALV_GRID
      !I_REPID type PROGNAME default SY-CPROG
      !I_DATACHANGED_FORM type STRING optional
      !I_DATACHANGED_FINISHED_FORM type STRING optional
      !I_DOUBLE_CLICK_FORM type STRING optional
      !I_HOTSPOT_FORM type STRING optional
      !I_PRINT_TOP_OF_PAGE type STRING optional
      !I_F4_FORM type STRING optional
      !I_TOOLBAR_FORM type STRING optional
      !I_BEFORE_UCOMM_FORM type STRING optional
      !I_USER_COMMAND_FORM type STRING optional
      !I_AFTER_UCOMM_FORM type STRING optional
      !I_BUTTON_CLICK_FORM type STRING optional
      !I_CONTEXT_MENU_FORM type STRING optional
      !I_MENU_BUTTON_FORM type STRING optional
      !I_ALV_DRAG_FORM type STRING optional
      !I_ALV_DROP_FORM type STRING optional.
protected section.
private section.

  data GV_REPID type PROGNAME .
  data GV_GRID_NAME type CHAR30 .
  data GV_GRID type ref to CL_GUI_ALV_GRID .
ENDCLASS.



CLASS ZCL_CM_OOALV_EVENT_HANDLER IMPLEMENTATION.


  method CONSTRUCTOR.
  endmethod.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_AFTER_USER_COMMAND.

    PERFORM (ZIF_CM_OOALV_EVENT~AFTER_USER_COMMAND_FORM) IN PROGRAM (GV_REPID) IF FOUND
                                USING GV_GRID_NAME
                                      E_UCOMM
                                      E_SAVED
                                      E_NOT_PROCESSED
                                      GV_GRID.

 DATA: LS_STBL TYPE LVC_S_STBL,
       L_SOFT_REFRESH.
**  "稳定刷新
  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新

  CALL METHOD GV_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STBL
      I_SOFT_REFRESH = L_SOFT_REFRESH.

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2.

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
*                                  E_NOT_PROCESSED
*                                  ER_ALV TYPE REF TO CL_GUI_ALV_GRID .
                                   .

* DATA: LS_STBL TYPE LVC_S_STBL,
*       L_SOFT_REFRESH.
***  "稳定刷新
*  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
*  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新
*
*  CALL METHOD ER_ALV->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      IS_STABLE      = LS_STBL
*      I_SOFT_REFRESH = L_SOFT_REFRESH.
*
*  CALL METHOD CL_GUI_CFW=>FLUSH
*    EXCEPTIONS
*      CNTL_SYSTEM_ERROR = 1
*      CNTL_ERROR        = 2.

*ENDFORM.                    " ALV_AFTER_USER_COMMAND

ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_ALV_ONDRAG.

  PERFORM (ZIF_CM_OOALV_EVENT~ALV_DRAG_FORM) IN PROGRAM (GV_REPID) IF FOUND
                          USING GV_GRID_NAME
                                    E_ROW
                                    E_COLUMN
                                    ES_ROW_NO
                                    E_DRAGDROPOBJ.









**&---------------------------------------------------------------------*
**&      Form  FRM_ALV_ONDRAG
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NAME  text
**      -->PS_COL_ID    text
**      -->PS_ROW_NO    text
**----------------------------------------------------------------------*
*FORM FRM_ALV_ONDRAG USING P_GRID_NAME
*                            E_ROW TYPE LVC_S_ROW
*                            E_COLUMN TYPE LVC_S_COL
*                            ES_ROW_NO TYPE LVC_S_ROID
*                            E_DRAGDROPOBJ TYPE REF TO CL_DRAGDROPOBJECT.
*
*  BREAK SUNHM.
*  DATA : DATAOBJ  TYPE  REF  TO LCL_DRAGDROP ,
*              LINE  TYPE SFLIGHT .
** Read dragged row
*  READ  TABLE GT_OUT  INDEX E_ROW-INDEX  INTO  LINE .
** create and fill dataobject for events ONDROP
*  CREATE OBJECT DATAOBJ .
** Remembering row index to move a line
*  MOVE E_ROW-INDEX  TO DATAOBJ->INDEX .
** store the dragged line.
*  READ  TABLE GT_OUT  INTO DATAOBJ->WA INDEX E_ROW-INDEX .
** Assigning data object to the refering event parameter
*  E_DRAGDROPOBJ->OBJECT = DATAOBJ .
*
*ENDFORM.                    "ALV_BUTTON_CLICK
ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_ALV_ONDROP.


  PERFORM (ZIF_CM_OOALV_EVENT~ALV_DROP_FORM) IN PROGRAM (GV_REPID) IF FOUND
                            USING GV_GRID_NAME
                                      E_ROW
                                      E_COLUMN
                                      ES_ROW_NO
                                      E_DRAGDROPOBJ.





**&---------------------------------------------------------------------*
**&      Form  FRM_ALV_ONDROP
**&---------------------------------------------------------------------*
**       Form Demo
**----------------------------------------------------------------------*
**      -->P_GRID_NAME  text
**      -->PS_COL_ID    text
**      -->PS_ROW_NO    text
**----------------------------------------------------------------------*
*FORM FRM_ALV_ONDROP USING P_GRID_NAME
*                            E_ROW TYPE LVC_S_ROW
*                            E_COLUMN TYPE LVC_S_COL
*                            ES_ROW_NO TYPE LVC_S_ROID
*                            E_DRAGDROPOBJ TYPE REF TO CL_DRAGDROPOBJECT.
*  BREAK SUNHM.
*  DATA: DATAOBJ TYPE REF TO LCL_DRAGDROP,
*            DROP_INDEX TYPE I,
*            STABLE TYPE LVC_S_STBL.
** Refresh Alv Grid Control without scrolling
*  STABLE-ROW = 'X'.
*  STABLE-COL = 'X'.
** Catch-Statement to ensure the drag&drop-Operation is aborted properly.
*  CATCH SYSTEM-EXCEPTIONS MOVE_CAST_ERROR = 1.
*    DATAOBJ ?= E_DRAGDROPOBJ->OBJECT.
*    DELETE GT_OUT INDEX DATAOBJ->INDEX.
*    INSERT DATAOBJ->WA INTO GT_OUT INDEX E_ROW-INDEX.
***Refreshing the ALV
*    CALL METHOD GO_OOALV->MT_REFRESH_OO_ALV.
*  ENDCATCH.
*  IF SY-SUBRC <> 0.
** If anything went wrong aborting the drag and drop operation:
*    CALL METHOD E_DRAGDROPOBJ->ABORT.
*  ENDIF.
*
*ENDFORM.                    "ALV_BUTTON_CLICK
*
ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_BEFORE_USER_COMMAND.


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

ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_BUTTON_CLICK.


    PERFORM (ZIF_CM_OOALV_EVENT~BUTTON_CLICK_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                        ES_COL_ID
                                        ES_ROW_NO.

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

ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_CONTEXT_MENU.


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

ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED.


  PERFORM (ZIF_CM_OOALV_EVENT~DATA_CHANGED_FORM) IN PROGRAM (GV_REPID) IF FOUND
                              USING GV_GRID_NAME
                                      ER_DATA_CHANGED
                                      E_ONF4
                                      E_ONF4_BEFORE
                                      E_ONF4_AFTER
                                      E_UCOMM.

  DATA: LS_STBL TYPE LVC_S_STBL,
        L_SOFT_REFRESH.
**  "稳定刷新
  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新

  CALL METHOD GV_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STBL
      I_SOFT_REFRESH = L_SOFT_REFRESH.

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2.

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

*  BREAK SUNHM.
*  DATA: LS_DATA   TYPE  LVC_S_MODI.
*  FIELD-SYMBOLS: <FS_OUT> TYPE TY_OUT.
*
*  IF E_ONF4 = 'X' AND E_ONF4_BEFORE = 'X' AND E_ONF4_AFTER = ''.
*    EXIT.
*  ENDIF.
*
*  LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO LS_DATA .
*    CASE LS_DATA-FIELDNAME.
*      WHEN 'WRBTR'.
*        READ TABLE GT_OUT ASSIGNING <FS_OUT> INDEX LS_DATA-ROW_ID.
*
**        CALL METHOD ER_DATA_CHANGED->ADD_PROTOCOL_ENTRY
**          EXPORTING
**            I_MSGID     = 'OO'
**            I_MSGTY     = 'E'
**            I_MSGNO     = '000'
**            I_MSGV1     = '权限重复'
**            I_FIELDNAME = LS_DATA-FIELDNAME
**            I_ROW_ID    = LS_DATA-ROW_ID
**            I_TABIX     = LS_DATA-TABIX.
*
*        <FS_OUT>-WRBTR = LS_DATA-VALUE.
**      WHEN .
*      WHEN OTHERS.
*    ENDCASE.
*
*  ENDLOOP.

*
*ENDFORM.                    "ALV_DATA_CHANGED


ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED_FINISHED.


    PERFORM (ZIF_CM_OOALV_EVENT~DATA_CHANGED_FINISHED_FORM) IN PROGRAM (GV_REPID) IF FOUND
                                USING GV_GRID_NAME
                                      E_MODIFIED
                                      ET_GOOD_CELLS
                                      GV_GRID
                                      .


 DATA: LS_STBL TYPE LVC_S_STBL,
       L_SOFT_REFRESH.
**  "稳定刷新
  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新

  CALL METHOD GV_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STBL
      I_SOFT_REFRESH = L_SOFT_REFRESH.

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2.

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
*                                     ET_GOOD_CELLS TYPE LVC_T_MODI
*                                     ER_ALV TYPE REF TO CL_GUI_ALV_GRID .
*                                      .
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
* DATA: LS_STBL TYPE LVC_S_STBL,
*       L_SOFT_REFRESH.
***  "稳定刷新
*  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
*  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新
*
*  CALL METHOD ER_ALV->REFRESH_TABLE_DISPLAY
*    EXPORTING
*      IS_STABLE      = LS_STBL
*      I_SOFT_REFRESH = L_SOFT_REFRESH.
*
*  CALL METHOD CL_GUI_CFW=>FLUSH
*    EXCEPTIONS
*      CNTL_SYSTEM_ERROR = 1
*      CNTL_ERROR        = 2.

*
*ENDFORM.                    "ALV_DATA_CHANGED_FINISHED

ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_DOUBLE_CLICK.


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
ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_HOTSPOT_CLICK.


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

ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_MENU_BUTTON.


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

ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_ON_F4.


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
ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_TOOLBAR.


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
ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~HANDLE_USER_COMMAND.

    PERFORM (ZIF_CM_OOALV_EVENT~USER_COMMAND_FORM) IN PROGRAM (GV_REPID) IF FOUND
                                   USING GV_GRID_NAME
                                         E_UCOMM.



  DATA: LS_STBL TYPE LVC_S_STBL,
        L_SOFT_REFRESH.
**  "稳定刷新
  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新

  CALL METHOD GV_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = LS_STBL
      I_SOFT_REFRESH = L_SOFT_REFRESH.

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2.

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


ENDMETHOD.


METHOD ZIF_CM_OOALV_EVENT~PRINT_TOP_OF_PAGE.


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
ENDMETHOD.
ENDCLASS.
