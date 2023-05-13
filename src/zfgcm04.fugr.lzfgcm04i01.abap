*&---------------------------------------------------------------------*
*&  Include           LZFGCM04I01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZCM_DOII01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  DATA: L_UCOMM TYPE SY-UCOMM.
  L_UCOMM = OK_CODE.
  CLEAR OK_CODE.

  IF NOT G_CALLBACK_USER_COMMAND IS INITIAL.
    PERFORM (G_CALLBACK_USER_COMMAND)
            IN PROGRAM (G_CALLBACK_PROGRAM)
            USING L_UCOMM
            IF FOUND.
  ELSE.
    CASE L_UCOMM.
      WHEN 'SAVE'. "另存为
        PERFORM FRM_SAVE_COPY_AS USING GR_PROXY G_FILENA.
      WHEN 'PRINT'. "打印
        PERFORM FRM_DOI_PRINT USING GR_PROXY.
        IF GS_OPTIONS-DIRECT_PRINT EQ 'B'.
          PERFORM FRM_LEAVE.
        ENDIF.
      WHEN 'NEXT'. "下一个
        PERFORM FRM_DOI_NEXT.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.



* Super Command for leave
  IF L_UCOMM EQ 'BACK' OR
     L_UCOMM EQ 'EXIT' OR
     L_UCOMM EQ 'CANC' .
    PERFORM FRM_LEAVE.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
