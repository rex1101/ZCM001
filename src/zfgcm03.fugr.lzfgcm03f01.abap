*&---------------------------------------------------------------------*
*&  Include           LZFGCM03F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZINCEMAILT_HTML
*&---------------------------------------------------------------------*
FORM FRM_CLERA_MAIL_GLOBE_VARIABLE.
  CLEAR:GS_GLOBE_MAIL_CONF.
  REFRESH:GFT_GLOBE_MAIL_FACT[],GFT_RECIPIENTS[].
ENDFORM.                    "frm_clera_mail_globe_Variable
*&---------------------------------------------------------------------*
*&      Form  frm_creat_html_p
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CREAT_HTML_P USING   IS_ROW TYPE W3_HTML
                      CHANGING ET_HTML TYPE W3HTMLTAB.


  DATA:LS_HTML TYPE W3HTML.

  CONCATENATE '<p>' IS_ROW '<br>' ' ' INTO LS_HTML SEPARATED BY SPACE.

  APPEND LS_HTML TO ET_HTML.

ENDFORM.                    "frm_creat_html_p
*&---------------------------------------------------------------------*
*&      Form  FRM_CREAT_HTML_BBODY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ET_HTML    text
*----------------------------------------------------------------------*
FORM FRM_CREAT_HTML_BBODY CHANGING ET_HTML TYPE W3HTMLTAB.

  DATA:LS_HTML TYPE W3HTML.

  CLEAR LS_HTML.

  LS_HTML = '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:xfa="http://www.xfa.org/schema/xfa-template/2.1/"><head></head>'.

  APPEND LS_HTML TO ET_HTML.



  CLEAR LS_HTML.

  LS_HTML = '<body>'.

  APPEND LS_HTML TO ET_HTML.

ENDFORM.                    "FRM_CREAT_HTML_BBODY

*&---------------------------------------------------------------------*
*&      Form  FRM_CREAT_HTML_EBODY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ET_HTML    text
*----------------------------------------------------------------------*
FORM FRM_CREAT_HTML_EBODY CHANGING ET_HTML TYPE W3HTMLTAB.

  DATA:LS_HTML TYPE W3HTML.
  CLEAR LS_HTML.

  CONCATENATE '<br>Regards</p></body>' '</html>' INTO LS_HTML SEPARATED BY SPACE.

  APPEND LS_HTML TO ET_HTML.

ENDFORM.                    "FRM_CREAT_HTML_EBODY
