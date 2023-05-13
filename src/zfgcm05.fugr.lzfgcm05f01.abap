*&---------------------------------------------------------------------*
*&  Include           LZFGCM05F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_CREATE_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_CHECK_CREATE_ALV.

  CREATE OBJECT GO_CONT
    EXPORTING
      CONTAINER_NAME = 'GO_CONT'.

  CREATE OBJECT GO_GRID
    EXPORTING
      I_PARENT = GO_CONT.


  CREATE OBJECT GO_EVT_REC
    EXPORTING
      E_OBJECT_TEXT = 'GO_GRID'.


  SET HANDLER GO_EVT_REC->HANDLE_TOOLBAR       FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_DOUBLE_CLICK  FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_HOTSPOT_CLICK FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_BUTTON_CLICK  FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_USER_COMMAND  FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_AFTER_USER_COMMAND  FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_DATA_CHANGED  FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_DATA_CHANGED_FINISHED  FOR GO_GRID.
  SET HANDLER GO_EVT_REC->HANDLE_CONTEXT_MENU  FOR GO_GRID.

  CALL METHOD GO_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.


  CALL METHOD GO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

* ## ## ##
IF GV_FUNCTION = GC_UP..
  PERFORM ALV_EX_TOOLBAR USING 'GT_EXCLUDE'.
ENDIF.

* LAYOUT
  PERFORM ALV_LAYOUT_INIT USING '' 'X' CHANGING GS_LAYOUT.      "EDIT, COLOR
  GS_LAYOUT-ZEBRA      = 'X'.         "#### ###,### ##

*
* First Display
  CALL METHOD GO_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE[]
*      I_DEFAULT            = 'X'            "#### #### ####
*      I_SAVE               = 'A'            "######.
      IS_VARIANT           = GS_VARIANT
    CHANGING
      IT_OUTTAB            = GT_GLOBE_TABLE
*      IT_SORT              = PT_SORT[]
      IT_FIELDCATALOG      = GT_FCAT[].
*
  CALL METHOD CL_GUI_CONTROL=>SET_FOCUS
    EXPORTING
      CONTROL = GO_GRID.

  CALL METHOD CL_GUI_CFW=>FLUSH.
*  GV_RUNNED = 'X'.

ENDFORM.                    "FRM_CHECK_CREATE_ALV
*&---------------------------------------------------------------------*
*&      Form  frm_refresh_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ICL_ALVGRID  text
*----------------------------------------------------------------------*
FORM FRM_REFRESH_OOALV.
  DATA: LS_STBL TYPE LVC_S_STBL,
        LR_GRID TYPE REF TO CL_GUI_ALV_GRID.

*  CHECK GV_RUNNED = 'X'.
  "稳定刷新
  LS_STBL-ROW = ABAP_TRUE.  "基于行的稳定刷新
  LS_STBL-COL = ABAP_TRUE.  "基于列稳定刷新

  CALL METHOD GO_GRID->SET_FRONTEND_FIELDCATALOG
    EXPORTING
      IT_FIELDCATALOG = GT_FCAT[].

  CALL METHOD GO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STBL.

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      CNTL_ERROR        = 2.

ENDFORM.                    "frm_refresh_alv


*&---------------------------------------------------------------------*
*&      Form  FRM_BUILD_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_BUILD_FCAT .

  DATA: LT_FCAT TYPE LVC_T_FCAT. "存放列表的名称
  DATA: LS_FCAT TYPE LVC_S_FCAT. "存放列表的名称
  DATA:LV_REPTEXT TYPE REPTEXT.


  REFRESH: GT_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = GV_FCAT_STR
    CHANGING
      CT_FIELDCAT            = LT_FCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.



  LOOP AT LT_FCAT INTO LS_FCAT.
    IF LS_FCAT-FIELDNAME = 'ICONNAME'.
      LS_FCAT-OUTPUTLEN = 3.
*      LS_FCAT-SYMBOL = 'X'.
*      LS_FCAT-ICON = 'X'.
      LS_FCAT-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
      LS_FCAT-REPTEXT = 'Button'.
    ENDIF.
    APPEND LS_FCAT TO GT_FCAT.

    CLEAR:LS_FCAT.
  ENDLOOP.

  DELETE GT_FCAT WHERE FIELDNAME = 'BUFFER'.

ENDFORM.                    " FRM_BUILD_FCAT


*&---------------------------------------------------------------------*
*&      Form  frm_download_files
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM FRM_DOWNLOAD_FILES USING ES_OUT TYPE ZCM_ATTACHMENT_LIST.

  DATA: BEGIN OF XTAB255 OCCURS 0,
      X(255) TYPE X,"一个字节需使用两个十六进制字符来表示
    END OF XTAB255.

  DATA: LV_FILENAME TYPE LOCALFILE.
  DATA: FILENAME TYPE STRING.

  DATA : LT_ROW   TYPE TABLE OF LVC_S_ROID.
  DATA : LS_ROW   TYPE  LVC_S_ROID.
  DATA: LS_OUTTAB TYPE ZCM_LOG_OUTPUT.


  DATA:LT_DATATAB      TYPE TABLE OF SSFDATA,
        LS_DATATAB TYPE SSFDATA.

  DATA:LV_FILE_LENGTH    TYPE I.
  DATA: LT_ZCMT0003 TYPE TABLE OF ZCMT0003,
        LS_ZCMT0003 TYPE ZCMT0003.
  DATA: L_ID TYPE C LENGTH 66.
  DATA : REF_CONT TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
         REF_HTML TYPE REF TO CL_GUI_HTML_VIEWER.
  DATA: LT_ZCMT0007 TYPE TABLE OF ZCMT0007,
        LS_ZCMT0007 TYPE ZCMT0007.


  DATA: L_DEFAULT_FILE_NAME TYPE STRING,
        L_FILE_FILTER TYPE STRING,
        L_FILENAME    TYPE STRING,
        L_PATH        TYPE STRING,
        L_FULLPATH    TYPE STRING.


  L_DEFAULT_FILE_NAME = ES_OUT-FILENAME.
*  L_FILE_FILTER = ES_OUT-EXTENSION.
  CONCATENATE '.' ES_OUT-EXTENSION INTO L_FILE_FILTER.
  LV_FILE_LENGTH = ES_OUT-BUFFER.

  CONCATENATE  GV_GLOBE_UUID ES_OUT-LOG_TYPE ES_OUT-INTERFACE_CLASS ES_OUT-BUZEI INTO L_ID RESPECTING BLANKS. "001 = ZCMT003-BUZEI

  IMPORT  FT_RETURN = LT_DATATAB
  FROM DATABASE ZCMT0003(RT) TO LS_ZCMT0003
  ID L_ID.




* Shows a File Save Dialog
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
*     WINDOW_TITLE         = ''
      DEFAULT_FILE_NAME    = L_DEFAULT_FILE_NAME
      FILE_FILTER          = L_FILE_FILTER
      INITIAL_DIRECTORY    = L_PATH
      PROMPT_ON_OVERWRITE  = SPACE
    CHANGING
      FILENAME             = L_FILENAME
      PATH                 = L_PATH
      FULLPATH             = L_FULLPATH
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.


  CONCATENATE L_FULLPATH L_FILE_FILTER INTO FILENAME.


  "注意：虽然是原生态下载，但这里生成的文件在字节数上会多于源文本，并且字节数是255的整数倍，因为在上传的过程中使用的是xtab255类型的内表，当最后一行不满255个字节时，也会在后面补上直到255个字节，但补的都是00这样的字节，所以文件大小还是有区别的，但经过测试pdf与mp3在码流后面补00字节好像没有什么影响唯独是文件大小变大了。但如果是TXT文件，打开后发现多了很多空格（按理来说也是什么也没有，因为空格的ASCII码为32，但后面补的是00字节）
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      BIN_FILESIZE = LV_FILE_LENGTH
      FILENAME     = FILENAME
      FILETYPE     = 'BIN'
    TABLES
      DATA_TAB     = LT_DATATAB.


ENDFORM.                    "frm_download_files
