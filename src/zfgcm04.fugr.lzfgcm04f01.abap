*&---------------------------------------------------------------------*
*&  包含                LZCM_DOIF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_INITIALIZE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_INITIALIZE_DATA .
  CLEAR: GF_INITIALIZED.
  CLEAR: G_CLSNAM, G_CLSTYP, G_TYPEID, G_FILENA.
  CLEAR: G_TITLE, GS_OPTIONS.
  CLEAR: G_CALLBACK_PROGRAM,       G_CALLBACK_FILL_DATA,
         G_CALLBACK_PF_STATUS_SET, G_CALLBACK_USER_COMMAND.

* Initialize options
  GS_OPTIONS-INPLACE_ENABLED          = 'X'.
  GS_OPTIONS-INPLACE_RESIZE_DOCUMENTS = 'X'.
  GS_OPTIONS-INPLACE_SCROLL_DOCUMENTS = 'X'.
  GS_OPTIONS-INPLACE_SHOW_TOOLBARS    = SPACE.
  GS_OPTIONS-PROTECT_DOCUMENT         = 'X'.
ENDFORM.                    " FRM_INITIALIZE_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_LEAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_LEAVE .
  CALL METHOD GR_PROXY->CLOSE_DOCUMENT .
  CALL METHOD GR_CONTROL->DESTROY_CONTROL.
  CLEAR: GR_SPREADSHEET, GR_PROXY, GR_CONTROL.
  LEAVE TO SCREEN 0.
ENDFORM.                    " FRM_LEAVE
*&---------------------------------------------------------------------*
*&      Form  FRM_DOI_NEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_DOI_NEXT .
  DATA: L_NO_NEXT TYPE FLAG.
  IF NOT G_CALLBACK_NEXT IS INITIAL.
    PERFORM (G_CALLBACK_NEXT)
            IN PROGRAM (G_CALLBACK_PROGRAM)
            USING GR_CONTROL
                  GR_PROXY
                  GR_SPREADSHEET
            CHANGING L_NO_NEXT
            IF FOUND.
    IF L_NO_NEXT EQ 'X'.
      MESSAGE '没有下一个' TYPE 'W'.
    ENDIF.
  ELSE. "没有回调函数,直接退出
    PERFORM FRM_LEAVE.
  ENDIF.
ENDFORM.                    " FRM_DOI_NEXT
*&---------------------------------------------------------------------*
*&      Form  FRM_DIRECT_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_DIRECT_PRINT .
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
ENDFORM.                    " FRM_DIRECT_PRINT
