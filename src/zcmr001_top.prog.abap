*&---------------------------------------------------------------------*
*&  Include           ZBDC_TOP
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&  Include           ZCON_GET_BDCTABLE_TOP
*&---------------------------------------------------------------------*

TABLES:D0100,BDC_RECORD.

DATA: GV_GLOBE_CTU_PARAMS TYPE CTU_PARAMS.
DATA: GV_GLOBE_BDC_NAME TYPE APQI-GROUPID.
DATA: GV_GLOBE_BDC_TCODE TYPE TCODE.
DATA: GV_GLOBE_BDC_EXCEL_COLUMN TYPE I.
DATA: GV_GLOBE_LOG_WADATA TYPE SYCHAR512.

DATA: GT_GLOBE_BDC_TAB TYPE BDCDATA_TAB.
DATA: GT_GLOBE_BDC_TAB_FIELD TYPE BDCDATA_TAB.
DATA: GT_GLOBE_BDC_FCAT TYPE LVC_T_FCAT."是Table Type
DATA: GT_GLOBE_BDC_RETURN TYPE TABLE OF BAPIRET2.

FIELD-SYMBOLS: <DYN_GLOBE_TABLE> TYPE TABLE.


* Definenation GLOBE BDC Variables
*INCLUDE ZCON_GET_BDCTABLE_TOP.

*----------------------------------------------------------------------*
* TABLE DECLARATION                                                    *
*----------------------------------------------------------------------*
TABLES: SSCRFIELDS,APQI."选择屏幕-新增按钮
*----------------------------------------------------------------------*
* TYPE-POOLS                                                           *
*----------------------------------------------------------------------*
TYPE-POOLS: SLIS,VRM,TRUXS.

*----------------------------------------------------------------------*
* SELECTION-SCREEN                                                     *
*----------------------------------------------------------------------*

SELECTION-SCREEN: FUNCTION KEY 1. "Button Key 1
SELECTION-SCREEN: FUNCTION KEY 2. "Button Key 2
SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
PARAMETERS: P_GRPID TYPE APQI-GROUPID OBLIGATORY .
PARAMETERS: P_DISP TYPE CTU_PARAMS-DISMODE OBLIGATORY DEFAULT 'N' . "Processing Mode
PARAMETERS: P_UPD TYPE CTU_PARAMS-UPDMODE OBLIGATORY DEFAULT 'A' .

PARAMETERS: P_COMMIT TYPE CTU_PARAMS-RACOMMIT AS CHECKBOX."Cont After Commit

SELECTION-SCREEN SKIP 1."换行
SELECTION-SCREEN END OF BLOCK B1.
