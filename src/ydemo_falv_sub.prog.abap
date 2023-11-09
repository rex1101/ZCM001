*&---------------------------------------------------------------------*
* Program Name     : YFALV
* Program Purpose  : ALV DEMO
* Author           : SUN HUIMING
* Date Written     : 2014/12/04
* Note             : N/A
*&---------------------------------------------------------------------*
REPORT YDEMO_FALV_SUB NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*    Type Pool declarations
*----------------------------------------------------------------------*
TYPE-POOLS: SLIS,SSCR,ICON.
INCLUDE ZINCL_CMALV.
*----------------------------------------------------------------------*
*    Table definition
*----------------------------------------------------------------------*
TABLES: SFLIGHT .

DATA: GV_FCAT_STR TYPE DD02L-TABNAME.
DATA: GV_TDFIND TYPE RSEUV-TDFIND.

*&---------------------------------------------------------------------*
*    Type definition
*&---------------------------------------------------------------------*
*-- Output
TYPES: BEGIN OF TY_OUT.
        INCLUDE TYPE SFLIGHT.
        INCLUDE TYPE ZCM_ALVOUTPUT_CONTROL.
TYPES: END OF TY_OUT.

*&---------------------------------------------------------------------*
*    Data Description
*&---------------------------------------------------------------------*
"-- Output
DATA: GT_OUT TYPE TABLE OF TY_OUT,
      GS_OUT TYPE TY_OUT.

* Variables for ALV
DATA: GS_LAYO TYPE LVC_S_LAYO "Alv 全局属性
    , GS_VARIANT TYPE DISVARIANT
    , GT_FCAT TYPE LVC_T_FCAT "存放列表的名称
    , GT_SORT TYPE LVC_T_SORT "定义排序变量
    , GT_EVTS TYPE LVC_T_EVTS "注册事件
    , GT_EXCL TYPE SLIS_T_EXTAB "LVC_T_EXCL "Excluding Table
    .
DATA: GO_EVENT TYPE REF TO ZCL_CM_OOALV_EVENT_HANDLER.
DATA:GT_SAPLANE TYPE TABLE OF SAPLANE WITH HEADER LINE.

*&---------------------------------------------------------------------*
*    DYN screen definition
*&---------------------------------------------------------------------*
*-- Output
FIELD-SYMBOLS: <DYN_GLOBE_TABLE> TYPE TABLE.
DATA: GT_DYN_FCAT TYPE LVC_T_FCAT. "存放列表的名称
DATA: GO_DWALV TYPE REF TO ZCL_CM_OO_ALV.
DATA: GV_GRID_TITLE TYPE LVC_TITLE.
*----------------------------------------------------------------------*
*    Constants Description
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*    PARAMETERS & SELECT-OPTIONS
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_CARRID FOR SFLIGHT-CARRID.
SELECT-OPTIONS: S_CONNID FOR SFLIGHT-CONNID.
SELECT-OPTIONS: S_PLANET FOR SFLIGHT-PLANETYPE.

PARAMETER:P_CALLD   NO-DISPLAY.  "程序调用时候的标志
SELECTION-SCREEN END OF BLOCK B1.

SELECTION-SCREEN BEGIN OF BLOCK DISP WITH FRAME TITLE TEXT-002.
PARAMETERS: ALV_DEF LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK DISP.
*&---------------------------------------------------------------------*
*    INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
* Set default value of screen fields
  PERFORM FRM_SET_DEFAULT_VALUE.

*&---------------------------------------------------------------------*
*    AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
* Set screen fields attribute
  PERFORM FRM_MODIFY_SCREEN.

AT SELECTION-SCREEN.
* Selection screen input check
  PERFORM FRM_INPUT_CHECK.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR ALV_DEF.

AT SELECTION-SCREEN ON HELP-REQUEST FOR S_PLANET.
*  PERFORM SUB_SEARCH_HELP_ALVDEAFULT CHANGING GS_VARIANT ALV_DEF.

*   PERFORM SUB_SEARCH_HELP_PLANETYPE USING 'S_PLANETYPE-LOW'.

*&---------------------------------------------------------------------*
*    START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
* Initialize data
  PERFORM FRM_INITIALIZE_DATA.

* Select data from database
  PERFORM FRM_SELECT_DATA.

*&---------------------------------------------------------------------*
*    END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
* Process selected data
  PERFORM FRM_PROCESS_DATA.

* Output result to file or spool/screen
  PERFORM FRM_OUTPUT_DATA.


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
  REFRESH: GT_FCAT,GT_SORT,GT_EVTS,GT_EXCL,GT_SAPLANE.
  CLEAR:GV_FCAT_STR,GV_TDFIND.
  GV_FCAT_STR = 'SFLIGHT'.
  GV_TDFIND = SY-CPROG.
  GS_VARIANT-VARIANT = ALV_DEF.
*  SET LOCALE LANGUAGE '1'.
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
   WHERE CARRID IN S_CARRID
     AND CONNID IN S_CONNID
     AND PLANETYPE IN S_PLANET.

ENDFORM.                    " FRM_SELECT_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_PROCESS_DATA
*&---------------------------------------------------------------------*
*       Process selected data
*----------------------------------------------------------------------*
FORM FRM_PROCESS_DATA .

*  修改单元格颜色
*  PERFORM FRM_CHANGECOLOR.

ENDFORM.                    " FRM_PROCESS_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_OUTPUT_DATA
*&---------------------------------------------------------------------*
*       Output result to file or spool/screen
*----------------------------------------------------------------------*
FORM FRM_OUTPUT_DATA .

  PERFORM FRM_BUILD_FCAT. "Field Catalog Table
  PERFORM FRM_BUILD_SORT. "Sort Criteria Table
  PERFORM FRM_BUILD_EVTS. "Events Table
  PERFORM FRM_BUILD_EXCL. "Excluding Table
  IF P_CALLD = 'X'.
    EXPORT GT_OUT TO  MEMORY ID GV_TDFIND."G_MEMORY.
  ELSE.
    PERFORM FRM_SHOW_ALV.   "Display ALV List
  ENDIF.

ENDFORM.                    " FRM_OUTPUT_DATA
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
    PERFORM FRM_ADD_FIELD USING: LS_FCAT-FIELDNAME  LS_FCAT-REPTEXT LS_FCAT-SCRTEXT_S LS_FCAT-SCRTEXT_M LS_FCAT-SCRTEXT_L .
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
*&      Form  FRM_BUILD_SORT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM FRM_BUILD_SORT .
  REFRESH: GT_SORT.

*  DATA: LS_SORT LIKE LINE OF GT_SORT.
*  CLEAR LS_SORT.
*  LS_SORT-SPOS = '1'."优先顺序
*  LS_SORT-FIELDNAME = 'CARRID'.
*  LS_SORT-UP = 'X'."正序
**  LS_SORT-DOWN = 'X'."倒序
*  LS_SORT-SUBTOT = 'X'."是否小计 需要激活LS_FCAT-DO_SUM
*  APPEND LS_SORT TO GT_SORT.

ENDFORM.                    " FRM_BUILD_SORT
*&---------------------------------------------------------------------*
*&      Form  FRM_BUILD_EVTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_BUILD_EVTS .
  REFRESH: GT_EVTS.

*  FIELD-SYMBOLS: <FS_EVTS> TYPE LVC_S_EVTS.
*  DATA: LS_EVTS TYPE LVC_S_EVTS.
*  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
*    EXPORTING
*      I_LIST_TYPE = 4
*    IMPORTING
*      ET_EVENTS   = GT_EVTS.

*  READ TABLE GT_EVTS ASSIGNING <FS_EVTS>
*                     WITH KEY NAME = 'CALLER_EXIT'.
*  IF SY-SUBRC EQ 0.
*    <FS_EVTS>-FORM = 'FRM_CALLER_EXIT'.
*  ENDIF.
ENDFORM.                    " FRM_BUILD_EVTS
*&---------------------------------------------------------------------*
*&      Form  FRM_BUILD_EXCL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_BUILD_EXCL .
  APPEND CL_GUI_ALV_GRID=>MC_FC_LOC_CUT TO GT_EXCL.
ENDFORM.                    " FRM_BUILD_EXCL
*&---------------------------------------------------------------------*
*&      Form  FRM_SHOW_ALV
*&---------------------------------------------------------------------*
*       Display ALV List
*----------------------------------------------------------------------*
FORM FRM_SHOW_ALV .
  DATA: LV_TITLE   TYPE LVC_TITLE.

*  LV_TITLE = SY-TITLE.
  GS_VARIANT-REPORT = SY-REPID.

  CLEAR GS_LAYO.
  GS_LAYO-CWIDTH_OPT = 'X'.  "优化列宽度
  GS_LAYO-ZEBRA      = 'X'.  "可选行颜色, 间隔色带
  GS_LAYO-SEL_MODE   = ' '.  "选择模式 SPACE, 'A', 'B', 'C', 'D'
*  GS_LAYO-SMALLTITLE = 'X'.  "小标题

*  GS_LAYO-STYLEFNAME = 'CELLSTYLE'. "单元格样式
*  GS_LAYO-CTAB_FNAME = 'FIELDCOL'."单元格颜色修改
*  GS_LAYO-INFO_FNAME = 'ROWCOLOR'."行颜色修改

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_CALLBACK_PF_STATUS_SET = 'FRM_PF_STATUS_SET'
      I_CALLBACK_USER_COMMAND  = 'FRM_USER_COMMAND'
      I_GRID_TITLE             = LV_TITLE
      I_SAVE                   = 'A'
      IS_VARIANT               = GS_VARIANT
      IS_LAYOUT_LVC            = GS_LAYO
      IT_FIELDCAT_LVC          = GT_FCAT
      IT_SORT_LVC              = GT_SORT
      IT_EVENTS                = GT_EVTS
      IT_EXCLUDING             = GT_EXCL
    TABLES
      T_OUTTAB                 = GT_OUT
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " FRM_SHOW_ALV
*&---------------------------------------------------------------------*
*&      Form  FRM_PF_STATUS_SET_SGL
*&---------------------------------------------------------------------*
FORM FRM_PF_STATUS_SET USING PT_EXTAB TYPE SLIS_T_EXTAB.
* 设置工具栏
  SET PF-STATUS 'MAIN' EXCLUDING PT_EXTAB.
* 设置标题栏
  SET TITLEBAR 'MAIN'.
ENDFORM.                    "FRM_PF_STATUS_SET_SGL

*&---------------------------------------------------------------------*
*&      Form  FRM_CALLER_EXIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IS_DATA    text
*----------------------------------------------------------------------*
FORM FRM_CALLER_EXIT USING IS_DATA TYPE SLIS_DATA_CALLER_EXIT.


  DATA: LO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LO_GRID.


  "事件响应
  CREATE OBJECT GO_EVENT
    EXPORTING
      IO_ALV                      = LO_GRID
      I_REPID                     = SY-REPID
*      I_F4_FORM                   = 'FRM_ALV_ON_F4'
*      I_TOOLBAR_FORM              = 'FRM_ALV_TOOLBAR'
*      I_USER_COMMAND_FORM         = 'FRM_ALV_USER_COMMAND'
*      I_HOTSPOT_FORM              = 'FRM_ALV_HOTSPOTE_CLICK'
*      I_DATACHANGED_FORM          = 'FRM_ALV_DATA_CHANGED'
*      I_DATACHANGED_FINISHED_FORM = 'FRM_ALV_DATA_CHANGED_FINISHED'
*      I_BEFORE_UCOMM_FORM         = 'FRM_ALV_BEFORE_USER_COMMAND'
*      I_DOUBLE_CLICK_FORM         = 'FRM_ALV_DOUBLE_CLICK'
*      I_MENU_BUTTON_FORM          = 'FRM_ALV_MENU_BUTTON'
      .

* register enter event
  CALL METHOD LO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER
    EXCEPTIONS
      ERROR      = 1
      OTHERS     = 2.

ENDFORM.                    " FRM_CALLER_EXIT
*&---------------------------------------------------------------------*
FORM FRM_USER_COMMAND USING I_UCOMM LIKE SY-UCOMM
                            IS_SELFIELD TYPE SLIS_SELFIELD.

  DATA : LT_ROW   TYPE  LVC_T_ROID.

* 0. 数据不能为空
  CHECK GT_OUT[] IS NOT INITIAL.

* 1. 检查数据变化
  PERFORM FRM_CHECK_CHANGED_DATA.
  PERFORM FRM_GET_SELECTED_ROWS  CHANGING LT_ROW.

* 2. 处理
  CASE I_UCOMM.
    WHEN '&IC1'.  "下钻
      PERFORM FRM_DRILL_DOWN USING IS_SELFIELD.
    WHEN '&SLA'. "全选
*      PERFORM FRM_SELECT_CELL USING GT_OUT[] 'CHBOX' 'CELLSTYLE' IS_SELFIELD.
    WHEN '&DSA'. "全不选
*      PERFORM FRM_DESELECT_ALL USING GT_OUT[] 'CHBOX' IS_SELFIELD.
    WHEN '&EXE'. "保存

      PERFORM FRM_CLEAR_SUB_VAR.
      PERFORM FRM_BUILD_SUB_FCAT_DYN USING 'SFLIGHT'.
      PERFORM FRM_PROCESS_VALUE USING LT_ROW.
      PERFORM FRM_SHOW_DW.

    WHEN '&CSUB'. "保存
      PERFORM FRM_CLEAR_SUB_VAR.
    WHEN OTHERS.
  ENDCASE.

* 刷新显示
  IS_SELFIELD-REFRESH = 'X'.
ENDFORM.                    "FRM_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  FRM_DRILL_DOWN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IS_SELFIELD  text
*----------------------------------------------------------------------*
FORM FRM_DRILL_DOWN USING IS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: LS_OUT TYPE TY_OUT.

* 字段不为空
  CHECK IS_SELFIELD-VALUE IS NOT INITIAL.

  READ TABLE GT_OUT INTO LS_OUT INDEX IS_SELFIELD-TABINDEX.
  CHECK SY-SUBRC EQ 0.

  CASE IS_SELFIELD-FIELDNAME.
    WHEN 'VBELN'. "销售订单号
      SET PARAMETER ID 'AUN' FIELD IS_SELFIELD-VALUE.
      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " FRM_DRILL_DOWN


*&---------------------------------------------------------------------*
*&      Form  FRM_PROCESS_QUAN_COL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_PROCESS_VALUE USING ET_ROW TYPE LVC_T_ROID.


  DATA: LS_ROW TYPE LVC_S_ROID.
  DATA: LS_OUT TYPE TY_OUT.

  DATA:DY_LINE  TYPE REF TO DATA.  "行
  FIELD-SYMBOLS:<DYN_WA>.
  CREATE DATA DY_LINE LIKE LINE OF <DYN_GLOBE_TABLE>.   "动态内表
  ASSIGN DY_LINE->* TO <DYN_WA>.                  "内表对应的结构


  READ TABLE ET_ROW INTO LS_ROW INDEX 1.
  READ TABLE GT_OUT INTO LS_OUT INDEX LS_ROW-ROW_ID.

  LOOP AT GT_OUT INTO LS_OUT.
    MOVE-CORRESPONDING LS_OUT TO <DYN_WA>.
    COLLECT <DYN_WA> INTO <DYN_GLOBE_TABLE>.
    CLEAR:LS_OUT.
  ENDLOOP.

  GV_GRID_TITLE = 'TEST'.

ENDFORM.                    "FRM_PROCESS_QUAN_COL

*&---------------------------------------------------------------------*
*&      Form  FRM_CLEAR_SUB_VAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CLEAR_SUB_VAR.

  REFRESH: GT_DYN_FCAT[].
  UNASSIGN <DYN_GLOBE_TABLE>.

  IF GO_DWALV IS NOT INITIAL.
    CALL METHOD GO_DWALV->FREE.
  ENDIF.

  CALL METHOD CL_GUI_CFW=>FLUSH.
  FREE GO_DWALV.
  CLEAR:GV_GRID_TITLE.

ENDFORM.                    "FRM_CLEAR_SUB_VAR

*
*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_SHOW_DW ."USING E_UCOMM TYPE SY-UCOMM.

  CHECK <DYN_GLOBE_TABLE> IS ASSIGNED AND GT_DYN_FCAT[] IS NOT INITIAL.

  DATA LS_LAYOUT TYPE LVC_S_LAYO.
** Set Layout
  LS_LAYOUT-CWIDTH_OPT = 'X'.
  LS_LAYOUT-ZEBRA = 'X'.
  LS_LAYOUT-SMALLTITLE = 'X'.

*  LS_LAYOUT-GRID_TITLE = GV_GRID_TITLE.
*  LS_LAYOUT-NO_TOOLBAR = 'X'.
  DATA LT_EXCLUDE TYPE UI_FUNCTIONS.
  CALL METHOD ZCL_CM_OOALV_TOOLBAR_EXCLUDE=>MT_TOOLBAR_EXPORT
    IMPORTING
      ET_EXCLUDE = LT_EXCLUDE.

  CREATE OBJECT GO_DWALV.


  CALL METHOD GO_DWALV->MT_CREATE_OO_DW_ALV
    EXPORTING
      IV_REPID                    = SY-REPID
      IV_SCREEN_PERCENT           = 30
      IT_FIELDCAT                 = GT_DYN_FCAT[]
      IS_LAYOUT                   = LS_LAYOUT
      IT_EXCLUDE                  = LT_EXCLUDE
*      IV_DEFAULT_EX               = 'E'
*      I_STRUCTURE_NAME            = LV_FCATSTR
*      I_F4_FORM                   = 'FRM_ALV_ON_F4'
*      I_TOOLBAR_FORM              = 'FRM_ALV_TOOLBAR'
*      I_USER_COMMAND_FORM         = 'FRM_ALV_USER_COMMAND'
*      I_HOTSPOT_FORM              = 'FRM_ALV_HOTSPOTE_CLICK'
*      I_DATACHANGED_FORM          = 'FRM_ALV_DATA_CHANGED'
*      I_DATACHANGED_FINISHED_FORM = 'FRM_ALV_DATA_CHANGED_FINISHED'
*      I_BEFORE_UCOMM_FORM         = 'FRM_ALV_BEFORE_USER_COMMAND'
*      I_DOUBLE_CLICK_FORM         = 'FRM_ALV_DOUBLE_CLICK'
*      I_MENU_BUTTON_FORM          = 'FRM_ALV_MENU_BUTTON'
      CHANGING
        IT_DATA                     = <DYN_GLOBE_TABLE>
      .

ENDFORM.                    "FRM_CHECK_CREATE_ALV
*&---------------------------------------------------------------------*
*&      Form  FRM_BUILD_FCAT
*&---------------------------------------------------------------------*
*       Build Field Catalog Table
*----------------------------------------------------------------------*
FORM FRM_BUILD_SUB_FCAT_DYN USING EV_FCATSTR TYPE DD02L-TABNAME.

  DATA: LT_FCAT TYPE LVC_T_FCAT. "存放列表的名称
  DATA: LS_FCAT TYPE LVC_S_FCAT. "存放列表的名称
  DATA:LV_REPTEXT TYPE REPTEXT.
  DATA:LV_TEXT TYPE NATXT.
  REFRESH: GT_FCAT.


  DATA: DY_TABLE TYPE REF TO DATA.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = EV_FCATSTR
    CHANGING
      CT_FIELDCAT            = LT_FCAT[]
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.


*此方法用于构建动态内表，输入=构建的结构，输出=dy_table
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG = LT_FCAT[]
    IMPORTING
      EP_TABLE        = DY_TABLE.

  ASSIGN DY_TABLE->* TO <DYN_GLOBE_TABLE>.


  LOOP AT LT_FCAT INTO LS_FCAT.
    CLEAR:LV_REPTEXT.
    CONCATENATE LS_FCAT-SCRTEXT_M LV_TEXT  INTO LS_FCAT-REPTEXT.
    CONCATENATE LS_FCAT-SCRTEXT_S LV_TEXT  INTO LS_FCAT-SCRTEXT_S.
    CONCATENATE LS_FCAT-SCRTEXT_M LV_TEXT  INTO LS_FCAT-SCRTEXT_M.
    CONCATENATE LS_FCAT-SCRTEXT_L LV_TEXT  INTO LS_FCAT-SCRTEXT_L.
    PERFORM FRM_ADD_ALV_DYN_FIELD USING: LS_FCAT-FIELDNAME  LS_FCAT-REPTEXT LS_FCAT-SCRTEXT_S LS_FCAT-SCRTEXT_M LS_FCAT-SCRTEXT_L LS_FCAT-OUTPUTLEN LS_FCAT-INTLEN.

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
FORM FRM_ADD_ALV_DYN_FIELD USING I_FIELDNAME TYPE LVC_FNAME
                         I_REPTEXT TYPE REPTEXT
                         I_SCRTEXT_S TYPE SCRTEXT_S
                         I_SCRTEXT_M TYPE SCRTEXT_M
                         I_SCRTEXT_L TYPE SCRTEXT_L
                         I_OUTLEN TYPE LVC_OUTLEN
                         I_INTLEN TYPE INTLEN
                         .
  DATA:LV_TEXT TYPE MESSAGE.
  CHECK I_FIELDNAME <> 'MANDT'.
  DATA: LS_FCAT TYPE LVC_S_FCAT.
*  LS_FCAT-TABNAME   = '<DYN_GLOBE_TABLE>'.
*  LS_FCAT-REF_TABLE = 'SFLIGHT'.
  LS_FCAT-FIELDNAME = I_FIELDNAME. "字段名称
  LS_FCAT-REF_FIELD = I_FIELDNAME. "字段名称
  LS_FCAT-REPTEXT   = I_REPTEXT.   "标题
  LS_FCAT-SCRTEXT_S   = I_SCRTEXT_S.   "标题
  LS_FCAT-SCRTEXT_M   = I_SCRTEXT_M.   "标题
  LS_FCAT-SCRTEXT_L   = I_SCRTEXT_L.   "标题
  LS_FCAT-OUTPUTLEN   = I_OUTLEN.   "标题
  LS_FCAT-INTLEN      = I_INTLEN.   "标题
*  LS_FCAT-LZERO     = ''.          "输出前导零
*  LS_FCAT-NO_ZERO   = ''.          "隐藏零
*  LS_FCAT-NO_SIGN   = ''.          "抑制符号
*  LS_FCAT-EMPHASIZE = 'C310'.      "列颜色
*  LS_FCAT-CHECKBOX  = ''.          "作为复选框输出
*  LS_FCAT-DECIMALS  = 0.           "小数位数
*
** 特殊处理(仅改变显示样式,不应涉及逻辑)
*  CASE I_FIELDNAME.
*    WHEN 'SEATSOCC'.
*      LS_FCAT-NO_ZERO = 'X'.
*      LS_FCAT-EMPHASIZE = 'C310'."列颜色
*      LS_FCAT-DO_SUM = 'X'.
*      LS_FCAT-DO_SUM = 'X'.
*    WHEN 'CARRID'.
*      LS_FCAT-F4AVAILABL = 'X'.
*    WHEN OTHERS.
*  ENDCASE.

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
  APPEND LS_FCAT TO GT_DYN_FCAT.
  CLEAR  LS_FCAT.
ENDFORM.                    " FRM_ADD_FIELD
