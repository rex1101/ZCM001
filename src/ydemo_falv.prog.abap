*&---------------------------------------------------------------------*
* Program Name     : ZALV
* Program Purpose  : ALV报表模版
* Author           : Ding Daxin
* Date Written     : 2013/05/06
* Note             : N/A
*&---------------------------------------------------------------------*
REPORT YDEMO_FALV NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*    Type Pool declarations
*----------------------------------------------------------------------*
TYPE-POOLS: SLIS .

*----------------------------------------------------------------------*
*    Table definition
*----------------------------------------------------------------------*
TABLES: SFLIGHT .

*&---------------------------------------------------------------------*
*    Type definition
*&---------------------------------------------------------------------*
*-- Output
TYPES: BEGIN OF TY_OUT.
        INCLUDE TYPE likp.
TYPES: END OF TY_OUT.

*&---------------------------------------------------------------------*
*    Data Description
*&---------------------------------------------------------------------*
"-- Output
DATA: GT_OUT TYPE TABLE OF TY_OUT.

* Variables for ALV
DATA: GS_LAYO TYPE LVC_S_LAYO "Layout structure
    , GT_FCAT TYPE LVC_T_FCAT "Field Catalog Table
    , GT_SORT TYPE LVC_T_SORT "Sort Criteria Table
    , GT_EVTS TYPE LVC_T_EVTS "Events Table
    , GT_EXCL TYPE SLIS_T_EXTAB "LVC_T_EXCL "Excluding Table
    .

*----------------------------------------------------------------------*
*    Constants Description
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*    PARAMETERS & SELECT-OPTIONS
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_CARRID FOR SFLIGHT-CARRID.
SELECT-OPTIONS: S_CONNID FOR SFLIGHT-CONNID.
SELECTION-SCREEN END OF BLOCK B1.

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

*AT SELECTION-SCREEN ON VALUE-REQUEST
*AT SELECTION-SCREEN ON HELP-REQUEST

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
ENDFORM.                    " FRM_INITIALIZE_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_SELECT_DATA
*&---------------------------------------------------------------------*
*       Select data from database
*----------------------------------------------------------------------*
FORM FRM_SELECT_DATA .
  SELECT *
    FROM LIKP UP TO 200 ROWS
    INTO TABLE GT_OUT
   WHERE KUNAG = '1*' .
ENDFORM.                    " FRM_SELECT_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_PROCESS_DATA
*&---------------------------------------------------------------------*
*       Process selected data
*----------------------------------------------------------------------*
FORM FRM_PROCESS_DATA .

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

  PERFORM FRM_SHOW_ALV.   "Display ALV List
ENDFORM.                    " FRM_OUTPUT_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_BUILD_FCAT
*&---------------------------------------------------------------------*
*       Build Field Catalog Table
*----------------------------------------------------------------------*
FORM FRM_BUILD_FCAT .
  REFRESH: GT_FCAT.
*  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*    EXPORTING
*      I_STRUCTURE_NAME = 'SFLIGHT'
*    CHANGING
*      CT_FIELDCAT      = GT_FCAT.

  PERFORM FRM_ADD_FIELD USING:
        'CARRID'      '航线承运人' ,
        'CONNID'      '航班号码' ,
        'FLDATE'      '航班日期' ,
        'PRICE'       '航空运费' ,
        'CURRENCY'    '货币' ,
        'PLANETYPE'   '飞机类型' ,
        'SEATSMAX'    '最大容量' ,
        'SEATSOCC'    '占据的座位' ,
        'PAYMENTSUM'  '当前预定总数' .
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
                         I_REPTEXT TYPE REPTEXT.
  DATA: LS_FCAT TYPE LVC_S_FCAT.
  LS_FCAT-TABNAME   = 'GT_OUT'.
  LS_FCAT-REF_TABLE = 'SFLIGHT'.
  LS_FCAT-FIELDNAME = I_FIELDNAME. "字段名称
  LS_FCAT-REF_FIELD = I_FIELDNAME. "字段名称
  LS_FCAT-REPTEXT   = I_REPTEXT.   "标题
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
    WHEN OTHERS.
  ENDCASE.

* 添加
  APPEND LS_FCAT TO GT_FCAT.
  CLEAR  LS_FCAT.
ENDFORM.                    " FRM_ADD_FIELD
*&---------------------------------------------------------------------*
*&      Form  FRM_BUILD_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_BUILD_SORT .
  REFRESH: GT_SORT.
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
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 4
    IMPORTING
      ET_EVENTS   = GT_EVTS.

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
  DATA: LV_TITLE TYPE LVC_TITLE,
        LS_VARIANT TYPE DISVARIANT.
*  LV_TITLE = SY-TITLE.
  LS_VARIANT-REPORT = SY-REPID.

  CLEAR GS_LAYO.
  GS_LAYO-CWIDTH_OPT = 'X'.  "优化列宽度
  GS_LAYO-ZEBRA      = 'X'.  "可选行颜色, 间隔色带
  GS_LAYO-SEL_MODE   = ' '.  "选择模式 SPACE, 'A', 'B', 'C', 'D'
*  GS_LAYO-SMALLTITLE = 'X'.  "小标题

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_CALLBACK_PROGRAM       = SY-REPID
*     I_CALLBACK_PF_STATUS_SET = 'FRM_PF_STATUS_SET'
*     I_CALLBACK_USER_COMMAND  = 'FRM_USER_COMMAND'
      I_GRID_TITLE             = LV_TITLE
      I_SAVE                   = 'A'
      IS_VARIANT               = LS_VARIANT
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
