*&---------------------------------------------------------------------*
*&  Include           YOALV_PBO
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*  MODULE STATUS_9000 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.

  CLEAR: GT_EX_UCOMM, GT_EX_UCOMM[].

  SET PF-STATUS '9000' EXCLUDING GT_EX_UCOMM[].
  SET TITLEBAR '9000'.

ENDMODULE.                    "STATUS_9000 OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO_9000  OUTPUT
*&---------------------------------------------------------------------*
MODULE PBO_9000 OUTPUT.


  IF GO_GRID IS INITIAL .
    PERFORM FRM_CREATE_ALV.
  ELSE.
    PERFORM FRM_ALV_REFRESH USING GO_GRID GT_FCAT[] 'F'.

  ENDIF.



ENDMODULE.                 " PBO_0100  OUTPUT
