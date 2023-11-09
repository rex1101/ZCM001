*&---------------------------------------------------------------------*
* Program Name     : ZALV
* Program Purpose  : ALV测试
* Author           : SUN HUIMING
* Date Written     : 2014/12/04
* Note             : N/A
*&---------------------------------------------------------------------*
REPORT YDEMO_OOALV MESSAGE-ID YOALV.


INCLUDE YDEMO_OOALV_TOP."TOP
INCLUDE YDEMO_OOALV_I01."PAI Moudle
INCLUDE YDEMO_OOALV_O01."PBO Moudle
INCLUDE YDEMO_OOALV_F01."

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

  IF GT_OUT IS NOT INITIAL.
    CALL SCREEN 9000.
  ELSE.
    MESSAGE S001 DISPLAY LIKE 'E'.
  ENDIF.
