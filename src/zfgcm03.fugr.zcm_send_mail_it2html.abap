FUNCTION ZCM_SEND_MAIL_IT2HTML.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_W3HEAD) TYPE  ZCM_SEND_MAIL_W3HEAD_TY
*"     REFERENCE(IS_TABLE_HEAD) TYPE  W3HEAD
*"  TABLES
*"      ET_HTML STRUCTURE  W3HTML
*"      IT_TABLE
*"----------------------------------------------------------------------


  DATA:    T_HEADER  TYPE STANDARD TABLE OF W3HEAD WITH HEADER LINE,  "Header
           T_FIELDS  TYPE STANDARD TABLE OF W3FIELDS WITH HEADER LINE,    "Fields
           T_HTML    TYPE STANDARD TABLE OF W3HTML,                          "Html
           WA_HEADER TYPE W3HEAD,
           W_HEAD    TYPE W3HEAD.

  DATA: LS_W3HEAD TYPE W3HEAD.

* 赋值
  GFT_GLOBE_MAIL_FACT[] = IT_W3HEAD[].


  LOOP AT GFT_GLOBE_MAIL_FACT INTO LS_W3HEAD.

    "标题行设置
    CALL FUNCTION 'WWW_ITAB_TO_HTML_HEADERS'
      EXPORTING
        FIELD_NR = LS_W3HEAD-NR
        TEXT     = LS_W3HEAD-TEXT
        FGCOLOR  = LS_W3HEAD-FG_COLOR
        BGCOLOR  = LS_W3HEAD-BG_COLOR
      TABLES
        HEADER   = T_HEADER.

    CALL FUNCTION 'WWW_ITAB_TO_HTML_LAYOUT'
      EXPORTING
        FIELD_NR = LS_W3HEAD-NR
        FGCOLOR  = 'black'
        SIZE     = '3'
      TABLES
        FIELDS   = T_FIELDS.
    CLEAR:LS_W3HEAD.
  ENDLOOP.

  MOVE-CORRESPONDING IS_TABLE_HEAD TO WA_HEADER.

*-Preparing the HTML from Intenal Table
  REFRESH T_HTML.
  CALL FUNCTION 'WWW_ITAB_TO_HTML'
    EXPORTING
      TABLE_HEADER = WA_HEADER
    TABLES
      HTML         = ET_HTML
      FIELDS       = T_FIELDS
      ROW_HEADER   = T_HEADER
      ITABLE       = IT_TABLE.




ENDFUNCTION.
