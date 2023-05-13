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

*&---------------------------------------------------------------------*
*    Data Description
*&---------------------------------------------------------------------*
"-- Output
DATA: GT_OUT TYPE TABLE OF TY_OUT,
      GS_OUT TYPE TY_OUT.


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
