*&---------------------------------------------------------------------*
*&  Include           YOALV_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.

  CLEAR G_OKCD.
  G_OKCD = G_UCOM.
  CLEAR G_UCOM.

  CASE G_OKCD.
    WHEN 'EXEC'.             "##
    WHEN 'REV'.
    WHEN 'MANUAL'.
    WHEN 'ALV_DBL_CLK'."OO event DOUBLE_CLICK
    WHEN 'RELOAD'."OO event DOUBLE_CLICK
      PERFORM FRM_ALV_RELOAD.
  ENDCASE.
ENDMODULE.                    "USER_COMMAND_9000 INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_9000 INPUT.

  CLEAR G_OKCD.
  G_OKCD = G_UCOM.
  CLEAR G_UCOM.

  CASE G_OKCD.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM FRM_ALV_FREE.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " EXIT_0100  INPUT
