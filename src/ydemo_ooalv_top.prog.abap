*&---------------------------------------------------------------------*
*&  Include           YOALV_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: SLIS,SSCR,ICON.
*----------------------------------------------------------------------*
*    Table definition
*----------------------------------------------------------------------*
TABLES: SFLIGHT .

*&---------------------------------------------------------------------*
*    Type definition
*&---------------------------------------------------------------------*
*-- Output
TYPES: BEGIN OF TY_OUT.
INCLUDE TYPE SFLIGHT.
*"单元格控制、行颜色、单元格颜色
TYPES: FIELDCOL  TYPE SLIS_T_SPECIALCOL_ALV, "单元格颜色控制
       CELLSTYLE TYPE LVC_T_STYL, "单元格样式
       ROWCOLOR  TYPE CHAR4,      "单元格行颜色
       CHBOX     TYPE CHECK_BOX,  "选择
       MSG       TYPE BAPI_MSG.   "信息
TYPES: END OF TY_OUT.


*DATA: BEGIN OF GT_OUT2 OCCURS 0.
*        INCLUDE STRUCTURE SFLIGHT.
**"单元格控制、行颜色、单元格颜色
*DATA: FIELDCOL  TYPE SLIS_T_SPECIALCOL_ALV, "单元格颜色控制
*       CELLSTYLE TYPE LVC_T_STYL, "单元格样式
*       ROWCOLOR  TYPE CHAR4,      "单元格行颜色
*       CHBOX     TYPE CHECK_BOX,  "选择
*       MSG       TYPE BAPI_MSG.   "信息
*DATA: END OF GT_OUT2.

*&---------------------------------------------------------------------*
*    Data Description
*&---------------------------------------------------------------------*
"-- Output
DATA: GT_OUT TYPE TABLE OF TY_OUT,
      GS_OUT TYPE TY_OUT.

**INCLUDE YDEMO_OOALV_ALV."OO Event AVL Defined

DATA: G_CPROG LIKE SY-CPROG.
DATA: G_OKCD  LIKE SY-UCOMM,
      G_UCOM  LIKE SY-UCOMM,
      G_ERROR.
DATA: GV_FCAT_STR TYPE DD02L-TABNAME.
DATA: GO_GUI_CONT      TYPE REF TO CL_GUI_CONTAINER,
      GO_CONT          TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      GO_GRID          TYPE REF TO CL_GUI_ALV_GRID,
      GO_EDITOR        TYPE REF TO CL_GUI_TEXTEDIT,
      GO_EVT_REC       TYPE REF TO ZCL_CM_OOALV_EVENT_HANDLER,
      GS_LAYOUT        TYPE LVC_S_LAYO,
      GT_FCAT          TYPE LVC_T_FCAT WITH HEADER LINE,
      GT_SORT          TYPE LVC_T_SORT WITH HEADER LINE,
      GT_ALV_F4        TYPE LVC_T_F4   WITH HEADER LINE,
      GS_STABLE        TYPE LVC_S_STBL,
      GS_VARIANT       TYPE DISVARIANT,
      GT_EXCLUDE       TYPE UI_FUNCTIONS WITH HEADER LINE,
      GT_EX_UCOMM      TYPE TABLE OF SY-UCOMM WITH HEADER LINE.


*&---------------------------------------------------------------------*
*    PARAMETERS & SELECT-OPTIONS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*    PARAMETERS & SELECT-OPTIONS
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_CARRID FOR SFLIGHT-CARRID.
SELECT-OPTIONS: S_CONNID FOR SFLIGHT-CONNID.
SELECT-OPTIONS: S_PLANET FOR SFLIGHT-PLANETYPE.
PARAMETER:P_CALLD   NO-DISPLAY.  "程序调用时候的标志
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
