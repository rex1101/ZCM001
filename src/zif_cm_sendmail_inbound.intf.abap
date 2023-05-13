interface ZIF_CM_SENDMAIL_INBOUND
  public .


  data GO_SAVE_LOG_UPDATE type ref to ZCL_CM_CUSTOM_LOG .
  data GO_SEND_REQUEST type ref to CL_BCS .
  class-data GS_MAIL_CONF type ZCM_SENDMAIL_IMPORT .
  data GT_HTML_HEADER_FACT type ZCM_SEND_MAIL_W3HEAD_TY .
  data GS_HTML_DEADER type W3HEAD .
  class-data GT_ATTACHMENTS type RMPS_T_POST_CONTENT .
  class-data GT_RECIPIENTS type ISU_ADR6_TAB .
  class-data GT_HTML_BODY type W3HTMLTAB .
  class-data GV_STRUCTURE_N type DD02L-TABNAME .

  methods MT_GET_SEND_ADDRESS
    exporting
      !SENDER_ADD type AD_SMTPADR .
  methods MT_GET_REC_ADDRESS
    importing
      value(IV_PRO) type PROGRAMM
      value(IV_PARA1) type PARA1 optional
      value(IV_PARA2) type PARA2 optional
      value(IV_PARA3) type PARA3 optional
      value(IV_PARA4) type PARA4 optional .
  methods MT_SET_IT2HTMLHEADER_FACT
    importing
      !IV_STR_NAME type DD02L-TABNAME
      !IV_FG_COLOR type WWWCOLOR default 'YELLOW'
      !IV_BG_COLOR type WWWCOLOR default 'GREEN' .
  methods MT_SET_IT2HTMLBODY
    importing
      value(IT_TABLE) type STANDARD TABLE .
  methods MT_SET_IT2BINTAB
    importing
      value(IT_TABLE) type STANDARD TABLE
      !IV_FILE_NAME type RSBFILENAME
      !IV_FILE_TYPE type HAP_ATTACHMENT_TYPE .
  methods MT_SET_HTML_HEADER .
  methods MT_CREATE_HTML_BODY
    importing
      !IT_TABLE type STANDARD TABLE
      !IT_HTML_BODY type SOLI_TAB optional .
  methods MT_CREAT_HTML_BBODY .
  methods MT_CREAT_HTML_P
    importing
      !BODY_MSG type W3_HTML .
  methods MT_CREAT_HTML_EBODY .
  methods MT_PAPER_SEND_MAIL .
  methods MT_SEND_MAIL
    exporting
      value(E_RESULT) type CHAR1 .
  methods MT_SIMPLE_SEND_MAIL
    importing
      !LFT_HTML_OUT type ANY TABLE
      !STRUCTURE_NAME type DD02L-TABNAME
      !SUBJECT type SO_OBJ_DES
      !LFT_HTML_BODY type SOLI_TAB optional .
  methods FREE .
endinterface.
