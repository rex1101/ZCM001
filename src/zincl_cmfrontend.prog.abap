*&---------------------------------------------------------------------*
*&  包含文件              ZINCL_CMFRONTEND
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_UPLOAD_DOWNLOAD_PATH
*&---------------------------------------------------------------------*
*       Returns the upload/download paths
*----------------------------------------------------------------------*
*      <--E_UPLOAD_PATH  text
*      <--E_DOWN_PATH  text
*----------------------------------------------------------------------*
FORM FRM_GET_UPLOAD_DOWNLOAD_PATH  CHANGING E_UPLOAD_PATH TYPE CLIKE
                                            E_DOWN_PATH   TYPE CLIKE.
  DATA: L_UPLOAD_PATH TYPE STRING,
        L_DOWN_PATH   TYPE STRING.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_UPLOAD_DOWNLOAD_PATH
    CHANGING
      UPLOAD_PATH                 = L_UPLOAD_PATH
      DOWNLOAD_PATH               = L_DOWN_PATH
    EXCEPTIONS
      CNTL_ERROR                  = 1
      ERROR_NO_GUI                = 2
      NOT_SUPPORTED_BY_GUI        = 3
      GUI_UPLOAD_DOWNLOAD_PATH    = 4
      UPLOAD_DOWNLOAD_PATH_FAILED = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
    E_UPLOAD_PATH = L_UPLOAD_PATH.
    E_DOWN_PATH   = L_DOWN_PATH.
  ENDIF.
ENDFORM.                    " FRM_GET_UPLOAD_DOWNLOAD_PATH
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_UPLOAD_PATH
*&---------------------------------------------------------------------*
*       Return the upload path
*----------------------------------------------------------------------*
*      <--E_UPLOAD_PATH  text
*----------------------------------------------------------------------*
FORM FRM_GET_UPLOAD_PATH  CHANGING E_UPLOAD_PATH TYPE CLIKE.
  DATA: L_DOWN_PATH TYPE STRING.
  PERFORM FRM_GET_UPLOAD_DOWNLOAD_PATH CHANGING E_UPLOAD_PATH
                                                L_DOWN_PATH.
ENDFORM.                    " FRM_GET_UPLOAD_PATH
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_DOWNLOAD_PATH
*&---------------------------------------------------------------------*
*       Return the download path
*----------------------------------------------------------------------*
*      <--E_DOWN_PATH  text
*----------------------------------------------------------------------*
FORM FRM_GET_DOWNLOAD_PATH  CHANGING E_DOWN_PATH TYPE CLIKE.
  DATA: L_UPLOAD_PATH TYPE STRING.
  PERFORM FRM_GET_UPLOAD_DOWNLOAD_PATH CHANGING L_UPLOAD_PATH
                                                E_DOWN_PATH.
ENDFORM.                    " FRM_GET_DOWNLOAD_PATH
*&---------------------------------------------------------------------*
*&      Form  FRM_FILE_SAVE_DIALOG
*&---------------------------------------------------------------------*
*       Shows a File Save Dialog
*       定义File Type Filter,最后一个为默认的显示,与DEFAULT_EXTENSION无关
* 'All Files (*.*)|*.*|Excel Files (*.xls)|*.xls|Word files(*.doc)|*.doc'
*----------------------------------------------------------------------*
*      -->I_DEFAULT_FILE_NAME   Default File Name
*      -->I_FILE_FILTER         File Type Filter
*      -->I_OVERWRITE           Prompt Overwrite File
*      <--E_FULLPATH            Path + File Name
*----------------------------------------------------------------------*
FORM FRM_FILE_SAVE_DIALOG
       USING    I_WINDOW_TITLE TYPE CLIKE
                I_DEFAULT_FILE_NAME TYPE CLIKE
                I_FILE_FILTER TYPE CLIKE
                I_OVERWRITE TYPE FLAG
       CHANGING E_FULLPATH TYPE CLIKE.

  DATA: L_WINDOW_TITLE      TYPE STRING,
        L_DEFAULT_FILE_NAME TYPE STRING,
        L_FILE_FILTER TYPE STRING,
        L_FILENAME    TYPE STRING,
        L_PATH        TYPE STRING,
        L_FULLPATH    TYPE STRING,
        L_USER_ACTION TYPE I.

* Set values
  L_WINDOW_TITLE      = I_WINDOW_TITLE.
  L_DEFAULT_FILE_NAME = I_DEFAULT_FILE_NAME.
  L_FILE_FILTER       = I_FILE_FILTER.

* Shows a File Save Dialog
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE         = L_WINDOW_TITLE
      DEFAULT_EXTENSION    = SPACE
      DEFAULT_FILE_NAME    = L_DEFAULT_FILE_NAME
      FILE_FILTER          = L_FILE_FILTER
      INITIAL_DIRECTORY    = L_PATH
      PROMPT_ON_OVERWRITE  = I_OVERWRITE
    CHANGING
      FILENAME             = L_FILENAME
      PATH                 = L_PATH
      FULLPATH             = L_FULLPATH
      USER_ACTION          = L_USER_ACTION
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.

* Clear fullpath if cancel
  IF L_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
    CLEAR E_FULLPATH.
  ELSE.
    E_FULLPATH = L_FULLPATH.
  ENDIF.
ENDFORM.                    " FRM_FILE_SAVE_DIALOG
*&---------------------------------------------------------------------*
*&      Form  FRM_FILE_OPEN_DIALOG
*&---------------------------------------------------------------------*
*       Displays a File Open Dialog
*       定义File Type Filter,最后一个为默认的显示,与DEFAULT_EXTENSION无关
* 'All Files (*.*)|*.*|Excel Files (*.xls)|*.xls|Word files(*.doc)|*.doc'
*----------------------------------------------------------------------*
*      -->I_WINDOW_TITLE        Title Of File Open Dialog
*      -->I_DEFAULT_FILE_NAME   Default File Name
*      -->I_FILE_FILTER         File Type Filter
*      -->I_MULTISELECTION      Multiple selections poss.
*      <--E_FULLPATH            Path + File Name
*----------------------------------------------------------------------*
FORM FRM_FILE_OPEN_DIALOG
       USING    I_WINDOW_TITLE TYPE CLIKE
                I_DEFAULT_FILE_NAME TYPE CLIKE
                I_FILE_FILTER TYPE CLIKE
*                I_MULTISELECTION TYPE FLAG
       CHANGING E_FULLPATH TYPE CLIKE.

  DATA: L_WINDOW_TITLE      TYPE STRING,
        L_DEFAULT_FILE_NAME TYPE STRING,
        L_FILE_FILTER TYPE STRING,
        LT_FILETABLE  TYPE FILETABLE,
        LS_FILETABLE  TYPE FILE_TABLE,
        L_RC          TYPE I,
        L_USER_ACTION TYPE I.

* Set values
  L_WINDOW_TITLE      = I_WINDOW_TITLE.
  L_DEFAULT_FILE_NAME = I_DEFAULT_FILE_NAME.
  L_FILE_FILTER       = I_FILE_FILTER.

* Displays a File Open Dialog
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = L_WINDOW_TITLE
      DEFAULT_EXTENSION       = SPACE
      DEFAULT_FILENAME        = L_DEFAULT_FILE_NAME
      FILE_FILTER             = L_FILE_FILTER
      WITH_ENCODING           = SPACE
      INITIAL_DIRECTORY       = SPACE "
      MULTISELECTION          = SPACE "I_MULTISELECTION
    CHANGING
      FILE_TABLE              = LT_FILETABLE
      RC                      = L_RC
      USER_ACTION             = L_USER_ACTION
*     FILE_ENCODING           =
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
* Clear fullpath if cancel
  IF L_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
    CLEAR E_FULLPATH.
  ELSE.
    READ TABLE LT_FILETABLE INTO LS_FILETABLE INDEX 1.
    E_FULLPATH = LS_FILETABLE-FILENAME.
  ENDIF.
ENDFORM.                    " FRM_FILE_OPEN_DIALOG
