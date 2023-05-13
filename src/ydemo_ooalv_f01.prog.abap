*&---------------------------------------------------------------------*
*&  Include           YOALV_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_SET_DEFAULT_VALUE
*&---------------------------------------------------------------------*
*       Set default value of screen fields
*----------------------------------------------------------------------*
FORM FRM_SET_DEFAULT_VALUE .

ENDFORM.                    " FRM_SET_DEFAULT_VALUE
*&---------------------------------------------------------------------*
*&      Form  FRM_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Set screen fields attribute
*----------------------------------------------------------------------*
FORM FRM_MODIFY_SCREEN .

ENDFORM.                    " FRM_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  FRM_INPUT_CHECK
*&---------------------------------------------------------------------*
*       Selection screen input check
*----------------------------------------------------------------------*
FORM FRM_INPUT_CHECK .


ENDFORM.                    " FRM_INPUT_CHECK
*&---------------------------------------------------------------------*
*&      Form  FRM_INITIALIZE_DATA
*&---------------------------------------------------------------------*
*       Initialize data
*----------------------------------------------------------------------*
FORM FRM_INITIALIZE_DATA .
  REFRESH: GT_OUT .
  GV_FCAT_STR = 'SFLIGHT'.
*  GV_TDFIND = SY-CPROG.
ENDFORM.                    " FRM_INITIALIZE_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_SELECT_DATA
*&---------------------------------------------------------------------*
*       Select data from database
*----------------------------------------------------------------------*
FORM FRM_SELECT_DATA .

  DATA: LS_OUT TYPE TY_OUT.
  SELECT *
    FROM SFLIGHT UP TO 200 ROWS
    INTO CORRESPONDING FIELDS OF TABLE GT_OUT
    .

ENDFORM.                    " FRM_SELECT_DATA

*&---------------------------------------------------------------------*
*&      Form  FRM_BUILD_FCAT
*&---------------------------------------------------------------------*
*       Build Field Catalog Table
*----------------------------------------------------------------------*
FORM FRM_BUILD_FCAT .

  DATA: LT_FCAT TYPE LVC_T_FCAT. "存放列表的名称
  DATA: LS_FCAT TYPE LVC_S_FCAT. "存放列表的名称
  DATA:LV_REPTEXT TYPE REPTEXT.
  DATA:LV_TEXT TYPE NATXT.
  REFRESH: GT_FCAT.

  RANGES: R_EX_FIELDNAME FOR SPERSFCAT-FIELDNAME.
  R_EX_FIELDNAME-SIGN = 'I'.
  R_EX_FIELDNAME-OPTION = 'EQ'.
  R_EX_FIELDNAME-LOW = 'ROWCOLOR'.
  APPEND R_EX_FIELDNAME.
  R_EX_FIELDNAME-LOW = 'CHBOX'.
  APPEND R_EX_FIELDNAME.
  R_EX_FIELDNAME-LOW = 'MSG'.
  APPEND R_EX_FIELDNAME.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = GV_FCAT_STR
    CHANGING
      CT_FIELDCAT            = LT_FCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  DELETE LT_FCAT WHERE FIELDNAME IN R_EX_FIELDNAME.

  LOOP AT LT_FCAT INTO LS_FCAT.
    CLEAR:LV_REPTEXT.
    CONCATENATE LS_FCAT-SCRTEXT_M LV_TEXT  INTO LS_FCAT-REPTEXT.

    CONCATENATE LS_FCAT-SCRTEXT_S LV_TEXT  INTO LS_FCAT-SCRTEXT_S.
    CONCATENATE LS_FCAT-SCRTEXT_M LV_TEXT  INTO LS_FCAT-SCRTEXT_M.
    CONCATENATE LS_FCAT-SCRTEXT_L LV_TEXT  INTO LS_FCAT-SCRTEXT_L.
    PERFORM FRM_ADD_FIELD USING: LS_FCAT-FIELDNAME  LS_FCAT-REPTEXT LS_FCAT-SCRTEXT_S LS_FCAT-SCRTEXT_M LS_FCAT-SCRTEXT_L.
  ENDLOOP.
ENDFORM.                    " FRM_BUILD_FCAT
*&---------------------------------------------------------------------*
*&      Form  FRM_ADD_FIELD
*&---------------------------------------------------------------------*
*       添加Field Catalog字段
*----------------------------------------------------------------------*
*  -->  I_FIELDNAME     字段名称
*  <--  I_REPTEXT       标题
*----------------------------------------------------------------------*
FORM FRM_ADD_FIELD USING I_FIELDNAME TYPE LVC_FNAME
                         I_REPTEXT TYPE REPTEXT
                         I_SCRTEXT_S TYPE SCRTEXT_S
                         I_SCRTEXT_M TYPE SCRTEXT_M
                         I_SCRTEXT_L TYPE SCRTEXT_L
                         .
  DATA:LV_TEXT TYPE MESSAGE.
  CHECK I_FIELDNAME <> 'MANDT'.
  DATA: LS_FCAT TYPE LVC_S_FCAT.
  LS_FCAT-TABNAME   = 'GT_OUT'.
*  LS_FCAT-REF_TABLE = 'SFLIGHT'.
  LS_FCAT-FIELDNAME = I_FIELDNAME. "字段名称
  LS_FCAT-REF_FIELD = I_FIELDNAME. "字段名称
  LS_FCAT-REPTEXT   = I_REPTEXT.   "标题
  LS_FCAT-SCRTEXT_S   = I_SCRTEXT_S.   "标题
  LS_FCAT-SCRTEXT_M   = I_SCRTEXT_M.   "标题
  LS_FCAT-SCRTEXT_L   = I_SCRTEXT_L.   "标题
*  LS_FCAT-LZERO     = ''.          "输出前导零
*  LS_FCAT-NO_ZERO   = ''.          "隐藏零
*  LS_FCAT-NO_SIGN   = ''.          "抑制符号
*  LS_FCAT-EMPHASIZE = 'C310'.      "列颜色
*  LS_FCAT-CHECKBOX  = ''.          "作为复选框输出
*  LS_FCAT-DECIMALS  = 0.           "小数位数

* 特殊处理(仅改变显示样式,不应涉及逻辑)
  CASE I_FIELDNAME.
    WHEN 'SEATSOCC'.
      LS_FCAT-NO_ZERO = 'X'.
      LS_FCAT-EMPHASIZE = 'C310'."列颜色
      LS_FCAT-DO_SUM = 'X'.
      LS_FCAT-DO_SUM = 'X'.
    WHEN 'CARRID'.
      LS_FCAT-F4AVAILABL = 'X'.
    WHEN OTHERS.
  ENDCASE.

  IF LS_FCAT-FIELDNAME(4) = 'OLD_'.

    CALL FUNCTION 'RP_READ_T100'
      EXPORTING
        ARBGB = 'ZCM001PM'
        MSGNR = 004
        SPRSL = SY-LANGU
      IMPORTING
        TEXT  = LV_TEXT.

    CONCATENATE LV_TEXT LS_FCAT-REPTEXT INTO LS_FCAT-REPTEXT.
  ENDIF.

* 添加
  APPEND LS_FCAT TO GT_FCAT.
  CLEAR  LS_FCAT.
ENDFORM.                    " FRM_ADD_FIELD
*&---------------------------------------------------------------------*
*&      Form  frm_create_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CREATE_ALV.


  CHECK GO_CONT IS INITIAL.

  G_CPROG = SY-CPROG.
  CREATE OBJECT GO_CONT
    EXPORTING
      CONTAINER_NAME = 'GO_CONT'.

  CREATE OBJECT GO_GRID
    EXPORTING
      I_PARENT = GO_CONT.

* ###
  CREATE OBJECT GO_EVT_REC
    EXPORTING
      E_OBJECT_TEXT = 'GO_GRID'.

  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED                 FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_DATA_CHANGED_FINISHED        FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_DOUBLE_CLICK                 FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_HOTSPOT_CLICK                FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~PRINT_TOP_OF_PAGE                   FOR GO_GRID.

  PERFORM REGISTER_F4_PBO CHANGING GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_ON_F4                        FOR GO_GRID.

  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_TOOLBAR                      FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_BEFORE_USER_COMMAND          FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_USER_COMMAND                 FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_AFTER_USER_COMMAND           FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_BUTTON_CLICK                 FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_CONTEXT_MENU                 FOR GO_GRID.
  SET HANDLER GO_EVT_REC->ZIF_CM_OOALV_EVENT~HANDLE_MENU_BUTTON                  FOR GO_GRID.
*
**则只有执行下一操作时才会触发handle_data_changed，比如点保存、删除
*    CALL METHOD g_alv_grid->register_edit_event
*      EXPORTING
*        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*
*    CALL METHOD g_alv_grid->register_edit_event
*      EXPORTING
*        i_event_id = cl_gui_alv_grid=>mc_evt_enter.


* LAYOUT
  PERFORM FRM_ALV_LAYOUT_INIT CHANGING GS_LAYOUT.      "EDIT, COLOR

  PERFORM FRM_BUILD_FCAT. "Field Catalog Table

* First Display
  CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
      I_DEFAULT            = ' '            "#### #### ####
      I_SAVE               = 'A'            "######.
      IS_VARIANT           = GS_VARIANT
    CHANGING
      IT_OUTTAB            = GT_OUT[]
      IT_FIELDCATALOG      = GT_FCAT[].


ENDFORM.                    "frm_create_alv
