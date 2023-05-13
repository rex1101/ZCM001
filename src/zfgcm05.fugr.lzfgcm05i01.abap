*&---------------------------------------------------------------------*
*&  Include           LZFGCM05I01
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_9200 INPUT.

  CASE G_OKCODE.
    WHEN 'CANCEL'.LEAVE TO SCREEN 0.
*  WHEN .
    WHEN OTHERS.
  ENDCASE.


ENDMODULE.                    "USER_COMMAND_9200 INPUT

*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  DATA: LS_ZCMT0007 TYPE ZCMT0007.
  BREAK SUNHM.
  CASE G_OKCODE.
    WHEN 'CANCEL'.LEAVE TO SCREEN 0.
    WHEN 'UP'.
      CALL FUNCTION 'ZCM_ATTACH_FILE_UPLOAD'
        EXPORTING
          IS_ZCMT0007 = GS_INSERT_ZCMT0007.

    WHEN OTHERS.
  ENDCASE.


ENDMODULE.                    "USER_COMMAND_9200 INPUT
