FUNCTION-POOL ZFGCM03.                      "MESSAGE-ID ..

DATA: G_CALLBACK_PROGRAM       TYPE SY-REPID,
      G_CALLBACK_USER_COMMAND  TYPE FORMNAME.
DATA: GO_LOG_UPDATE TYPE REF TO ZCL_CM_CUSTOM_LOG .
DATA: GFT_GLOBE_MAIL_FACT TYPE ZCM_SEND_MAIL_W3HEAD_TY."HTML/Excel Head Line
DATA: GFT_RECIPIENTS TYPE TABLE OF ADR6. "Received Mail List
DATA: GS_GLOBE_MAIL_CONF TYPE ZCM_SENDMAIL_IMPORT."Send Mail Contral Parameters
DATA: GV_GLOBE_MAIL_NAME_STRU TYPE DD02L-TABNAME."Send Mail Contral Parameters
FIELD-SYMBOLS: <GLB_INTERNAL_TABLE> TYPE STANDARD TABLE.
* INCLUDE LZFGCM03D...                       " Local class definition