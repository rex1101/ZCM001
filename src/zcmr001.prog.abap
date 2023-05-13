***********************************************************************
* PROGRAM NAME        : ZCMR001
* PROGRAM PURPOSE     : Batch data communication
* AUTHOR              : Sunhm
* DATA WRITTEN        : 2020-11-15
* NOTE                : N/A
***********************************************************************
*   DATE     |    MOD     | INITIAL  |         DESCRIPTION
*----------+------------+----------+----------------------------------*
* 2021-05-15 | DEVK901966| REX.SUN   | INITIAL PROGRAM CREATION
***********************************************************************

REPORT ZCMR001 MESSAGE-ID MS.

INCLUDE ZCMR001_TOP.           "Definenation Golble Variables
INCLUDE ZINCL_CMALV.
INCLUDE ZINCL_CMUPDOWN.
INCLUDE ZINCL_CMFRONTEND.
INCLUDE ZINCL_CMDOI.
INCLUDE ZCMR001_F01.  " process bdc from excel
INCLUDE ZCMR001_F02.  "download excel
INCLUDE ZCMR001_F03.

*----------------------------------------------------------------------*
* INITIALIZATION                                                       *
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM FRM_SET_DEFAULT_VALUE. "Set default value

AT SELECTION-SCREEN OUTPUT.
  PERFORM FRM_MODIFY_SCREEN.      "Set screen fields attribute

AT SELECTION-SCREEN.
  PERFORM FRM_INPUT_CHECK.        "Selection screen input check
  PERFORM FRM_USER_COMMAND.       "User command
*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*

START-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  FRM_SET_DEFAULT_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_SET_DEFAULT_VALUE .
  CONCATENATE ICON_TREND_DOWN: '下载模版' INTO SSCRFIELDS-FUNCTXT_01.
  CONCATENATE ICON_TREND_UP:   '上传数据' INTO SSCRFIELDS-FUNCTXT_02.

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

  AUTHORITY-CHECK OBJECT 'ZCMR001'
           ID 'BDCGROUPID' FIELD P_GRPID.
  IF SY-SUBRC <> 0.
    MESSAGE E408 WITH 'ZCMR001'.
  ENDIF.

ENDFORM.                    " FRM_INPUT_CHECK
*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_USER_COMMAND .
  DATA: L_FILENAME TYPE RLGRAP-FILENAME.

  PERFORM FRM_CLEAR_GLOBE_BDC_VAR.

  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'. "Download Template
      PERFORM FRM_SELECT_BDC_INFO.
      PERFORM FRM_DOWNLOAD_BDC_TEMPLATE .
    WHEN 'FC02'. "Upload Template
      PERFORM FRM_FILE_OPEN_DIALOG USING '文件选择' P_GRPID
                                               'Excel Files (*.xls)|*.xls'
                                               L_FILENAME.
      IF L_FILENAME IS NOT INITIAL.
        PERFORM FRM_UPLOAD_DATA USING L_FILENAME.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " FRM_USER_COMMAND
