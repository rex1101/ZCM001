*&---------------------------------------------------------------------*
* Program Name     : YDEMO_OOFDALV
* Program Purpose  : Call Method OO Docking ALV Function Demo
* Author           : SUN HUIMING
* Date Written     : 2014/12/04
* Note             : N/A
*&---------------------------------------------------------------------*
REPORT  YDEMO_OOFDALV.

*----------------------------------------------------------------------*
*    Type Pool declarations
*----------------------------------------------------------------------*
TYPE-POOLS: SLIS,SSCR,ICON.
*INCLUDE ZINCL_CMALV.

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
    , GT_FCAT2 TYPE LVC_T_FCAT "存放列表的名称
    , GT_SORT TYPE LVC_T_SORT "定义排序变量
    , GT_EVTS TYPE LVC_T_EVTS "注册事件
    , GT_EXCL TYPE SLIS_T_EXTAB "LVC_T_EXCL "Excluding Table
    .

DATA:GT_SAPLANE TYPE TABLE OF SAPLANE WITH HEADER LINE.

DATA: GO_OOALV TYPE REF TO ZCL_CM_OO_ALV.
DATA: G_OKCD  LIKE SY-UCOMM.
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
*&      Form  FRM_OUTPUT_DATA
*&---------------------------------------------------------------------*
*       Output result to file or spool/screen
*----------------------------------------------------------------------*
FORM FRM_OUTPUT_DATA .
  PERFORM FRM_BUILD_FCAT. "Field Catalog Table
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
*  LS_FCAT-TABNAME   = 'GT_OUT'.
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

      WHEN 'PLANETYPE'.
        LS_FCAT-EDIT = 'X'.
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
*&      Form  FRM_SHOW_ALV
*&---------------------------------------------------------------------*
*       Display ALV List
*----------------------------------------------------------------------*
FORM FRM_SHOW_ALV .

  DATA: LO_DOCK TYPE REF TO CL_GUI_DOCKING_CONTAINER. "屏幕容器对象

  CREATE OBJECT GO_OOALV.


  "实例化屏幕容器
  CREATE OBJECT LO_DOCK
    EXPORTING
*     PARENT                      =
      REPID                       = SY-REPID                                                            "当前程序
      DYNNR                       = '9000'                                                               "屏幕编号
      SIDE                        = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_LEFT   "容器吸附左侧
      EXTENSION                   = 1300                                                              "ALV的宽度
*     STYLE                       =
*     LIFETIME                    = lifetime_default
*     CAPTION                     =
      METRIC                      = 0
*     RATIO                       = 100                                                                    "ALV的比率，优先级高于上面的EXTENSION
*     NO_AUTODEF_PROGID_DYNNR     =
*     NAME                        =
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  CALL METHOD GO_OOALV->MT_CREATE_OO_ALV
  EXPORTING
   IV_REPID                      = SY-CPROG
   IV_SCREEN                     = '9000'
   IV_DEFAULT_EX                 = 'X'
*   IS_LAYOUT                     =
   IT_FIELDCAT                   = GT_FCAT
*   IT_EXCLUDE                    =
   IV_SPLIT_NUMBER               = 1
   IV_SPLIT_CONTAINER            = LO_DOCK
*   IV_CONTAINER_NAME             = 'GO_CONT'
*   IV_VARIANT_HANDLE             = '1'
   I_F4_FORM                     = 'FRM_ALV_ON_F4'
   I_TOOLBAR_FORM                = 'FRM_ALV_TOOLBAR'
   I_USER_COMMAND_FORM           = 'FRM_ALV_USER_COMMAND'
   I_HOTSPOT_FORM                = 'FRM_ALV_HOTSPOTE_CLICK'
   I_DATACHANGED_FORM            = 'FRM_ALV_DATA_CHANGED'
   I_DATACHANGED_FINISHED_FORM   = 'FRM_ALV_DATA_CHANGED_FINISHED'
   I_BEFORE_UCOMM_FORM           = 'FRM_ALV_BEFORE_USER_COMMAND'
   I_DOUBLE_CLICK_FORM           = 'FRM_ALV_DOUBLE_CLICK'
   I_MENU_BUTTON_FORM            = 'FRM_ALV_MENU_BUTTON'
   CHANGING
    IT_DATA           = GT_OUT
    .

  CALL SCREEN 9000.


ENDFORM.                    " FRM_SHOW_ALV

*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'STATUS'.
  SET TITLEBAR 'TITLE'.
ENDMODULE.                    "status_9000 OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  CASE G_OKCD.
    WHEN 'EXIT' OR 'BACK'.
*      CALL METHOD GO_OOALV->FREE.
      LEAVE TO SCREEN 0.
    WHEN  'CANC'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
  CLEAR G_OKCD.
ENDMODULE.                    "user_command_9000 INPUT

**&---------------------------------------------------------------------*
**&      Form  SUB_SEARCH_HELP_VRTNR
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM SUB_SEARCH_HELP_PLANETYPE  USING  LV_FIELD TYPE DYNFNAM .
*  REFRESH GT_SAPLANE.
*  SELECT *
*    FROM SAPLANE
*    INTO TABLE GT_SAPLANE.
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      RETFIELD     = 'PLANETYPE'
*      DYNPPROG     = SY-REPID
*      DYNPNR       = SY-DYNNR
*      DYNPROFIELD  = LV_FIELD
**     STEPL        = 0
*      WINDOW_TITLE = '飞机类型'
*      VALUE_ORG    = 'S'
*    TABLES
*      VALUE_TAB    = GT_SAPLANE.
*ENDFORM.                    "SUB_SEARCH_HELP_PLANETYPE
*
**&---------------------------------------------------------------------*
**&      Form  SUB_SEARCH_HELP_ALVDEafult
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM SUB_SEARCH_HELP_ALVDEAFULT.
*
*  GS_VARIANT-REPORT = SY-CPROG.
*
*  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
*    EXPORTING
*      IS_VARIANT = GS_VARIANT
*      I_SAVE     = 'A'
*    IMPORTING
*      ES_VARIANT = GS_VARIANT
*    EXCEPTIONS
*      NOT_FOUND  = 2.
*  IF SY-SUBRC = 2.
*    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ELSE.
*    ALV_DEF = GS_VARIANT-VARIANT.
*  ENDIF.
*
*ENDFORM.                    "SUB_SEARCH_HELP_ALVDEafult

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

  CASE  P_FIELDNAME.
    WHEN 'CARRID'.
*      PERFORM FRM_F4_CARRID   USING P_FIELDNAME PS_ROW_NO PO_EVENT_DATA.
    WHEN OTHERS.
  ENDCASE.

*  PERFORM FRM_ALV_REFRESH USING GO_GRID GT_FCAT[] 'F'.

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
  BREAK SUNHM.
  CASE E_UCOMM .
    WHEN 'B_LIST'.
*      CALL METHOD GO_OOALV->MT_REFRESH_OO_ALV.
*    WHEN 'DUMMY'.
*    WHEN OTHERS.
  ENDCASE.

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

  IF E_UCOMM = 'B_LIST'.
    CALL METHOD P_OBJECT->ADD_FUNCTION
      EXPORTING
        ICON  = ICON_DISPLAY
        FCODE = 'B_SUM'
        TEXT  = '显示 ALV 总数'.
  ENDIF.

ENDFORM.                    "ALV_BUTTON_CLICK
