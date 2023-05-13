*----------------------------------------------------------------------*
***INCLUDE LZCM_DOIO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  IF NOT G_CALLBACK_PF_STATUS_SET IS INITIAL.
    PERFORM (G_CALLBACK_PF_STATUS_SET)
            IN PROGRAM (G_CALLBACK_PROGRAM)
            IF FOUND.
  ELSE.
    CLEAR OK_CODE.
    SET PF-STATUS 'PS0100' .
    SET TITLEBAR  'TT0100' WITH G_TITLE.
  ENDIF.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE DISPLAY_0100 OUTPUT.
  IF GF_INITIALIZED IS INITIAL.
    GF_INITIALIZED = 'X'.
  ELSE.
    RETURN.
  ENDIF.
* Document URL
  DATA: L_URL TYPE BDS_URI.

* Fetch Document URL
  PERFORM FRM_GET_BDS_URL USING G_CLSNAM
                                G_CLSTYP
                                G_TYPEID
                                G_FILENA
                       CHANGING L_URL.

* 创建基本对象
  PERFORM FRM_CREATE_DOI_OBJECTS USING    L_URL
                                          GS_OPTIONS-INPLACE_ENABLED
                                          GS_OPTIONS-INPLACE_SHOW_TOOLBARS
                                 CHANGING GR_CONTROL
                                          GR_PROXY
                                          GR_SPREADSHEET.

* Callback
  IF NOT G_CALLBACK_FILL_DATA IS INITIAL.
    PERFORM (G_CALLBACK_FILL_DATA)
            IN PROGRAM (G_CALLBACK_PROGRAM)
            USING GR_CONTROL
                  GR_PROXY
                  GR_SPREADSHEET
            IF FOUND.
  ENDIF.

* Protect
  IF GS_OPTIONS-PROTECT_DOCUMENT EQ 'X'.
    CALL METHOD GR_SPREADSHEET->PROTECT
      EXPORTING
        PROTECT = 'X'.
  ENDIF.
ENDMODULE.                 " DISPLAY_0100  OUTPUT
