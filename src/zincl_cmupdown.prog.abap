*&---------------------------------------------------------------------*
*&  包含文件              ZINCL_CMUPDOWN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_F4_FILENAME
*&---------------------------------------------------------------------*
*       文件f4帮助
*----------------------------------------------------------------------*
*      <-- E_FILE  text
*----------------------------------------------------------------------*
FORM FRM_F4_FILENAME CHANGING E_FILE TYPE IBIPPARMS-PATH.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = E_FILE.
ENDFORM.                    " FRM_F4_FILENAME
*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_FILE_EXIST
*&---------------------------------------------------------------------*
*       检查模板是否存在
*----------------------------------------------------------------------*
*  -->  I_FILENAME   文件名
*  <--  E_EXIST  是否存在
*----------------------------------------------------------------------*
FORM FRM_CHECK_FILE_EXIST USING I_FILENAME TYPE CLIKE
                       CHANGING E_EXIST.

  DATA: L_FILE TYPE STRING.
  L_FILE = I_FILENAME.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = L_FILE
    RECEIVING
      RESULT               = E_EXIST
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      OTHERS               = 5.
ENDFORM.                    "FRM_CHECK_FILE_EXIST
*&---------------------------------------------------------------------*
*&      Form  FRM_DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*       下载模版
*----------------------------------------------------------------------*
*  -->  I_OBJID      模版对象名称
*  -->  I_FILENAME  下载文件名
*----------------------------------------------------------------------*
FORM FRM_DOWNLOAD_TEMPLATE USING I_OBJID    TYPE WWWDATATAB-OBJID
                                 I_FILENAME TYPE RLGRAP-FILENAME.
  DATA: L_EXIST TYPE ABAP_BOOL.
  DATA: L_MSG TYPE STRING.
  DATA: L_RC LIKE SY-SUBRC.
  DATA: LS_WWWDATA TYPE WWWDATATAB.

* 判断文件是否存在
  PERFORM FRM_CHECK_FILE_EXIST USING I_FILENAME CHANGING L_EXIST.

* 模版已存在
  IF L_EXIST = ABAP_TRUE.
    CONCATENATE '模版' I_FILENAME '已存在!' INTO L_MSG.
    MESSAGE L_MSG TYPE 'S' DISPLAY LIKE 'W'.
  ELSE.
* 不存在,下载模版
    LS_WWWDATA-RELID = 'MI'.
    LS_WWWDATA-OBJID = I_OBJID.
    CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
      EXPORTING
        KEY         = LS_WWWDATA
        DESTINATION = I_FILENAME
      IMPORTING
        RC          = L_RC.
    IF L_RC <> 0.
      MESSAGE '下载模版失败!' TYPE 'E'.
    ELSE.
      CONCATENATE '成功下载模版,下载目录:' I_FILENAME INTO L_MSG.
      MESSAGE L_MSG TYPE 'S'.
    ENDIF.
  ENDIF.
ENDFORM.                    " download_template
*&---------------------------------------------------------------------*
*&      Form  FRM_EXCEL_TO_ITAB
*&---------------------------------------------------------------------*
*       EXCEL上传到内表
*----------------------------------------------------------------------*
*      <--ET_UPLOAD  text
*----------------------------------------------------------------------*
FORM FRM_EXCEL_TO_ITAB USING I_FILENAME  TYPE RLGRAP-FILENAME
                              I_BEGIN_COL TYPE I
                              I_BEGIN_ROW TYPE I
                              I_END_COL   TYPE I
                              I_END_ROW   TYPE I
                     CHANGING ET_UPLOAD TYPE ZCM_ALSMEX_TABLINE_TY.

* 清除之前的数据
  CLEAR ET_UPLOAD[].

* 检查文件是否存在
  DATA: L_EXIST TYPE ABAP_BOOL.
  DATA: L_MSG TYPE STRING.

  PERFORM FRM_CHECK_FILE_EXIST USING I_FILENAME CHANGING L_EXIST.

  IF L_EXIST <> ABAP_TRUE.
    CONCATENATE '上传文件' I_FILENAME '不存在!' INTO L_MSG.
    MESSAGE L_MSG TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

* 显示进度
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      TEXT = '正在处理中,请等待... '.

* 读取上传文件内的数据
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                = I_FILENAME
      I_BEGIN_COL             = I_BEGIN_COL
      I_BEGIN_ROW             = I_BEGIN_ROW
      I_END_COL               = I_END_COL
      I_END_ROW               = I_END_ROW
    TABLES
      INTERN                  = ET_UPLOAD
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.
  IF SY-SUBRC <> 0.
    CONCATENATE '文件' I_FILENAME '上传不成功,请检查!' INTO L_MSG.
    MESSAGE L_MSG TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " FRM_EXCEL_TO_ITAB
