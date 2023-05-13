*&---------------------------------------------------------------------*
*&  包括                ZINCL_CMDOI
*&---------------------------------------------------------------------*
*
*TYPES: BEGIN OF TY_HIDE,
*         BEG_ROWS TYPE I,
*         END_ROWS TYPE I,
*       END OF TY_HIDE.
*
*DATA: GT_HIDE TYPE TABLE OF TY_HIDE.
*&---------------------------------------------------------------------*
*&      Form  FRM_DOI_CHECK
*&---------------------------------------------------------------------*
*       DOI Support 检查
*----------------------------------------------------------------------*
FORM FRM_DOI_CHECK .
  DATA: L_HAS_ACTIVEX TYPE C.
  CALL FUNCTION 'GUI_HAS_ACTIVEX'
    IMPORTING
      RETURN = L_HAS_ACTIVEX.
  IF L_HAS_ACTIVEX IS INITIAL.
    MESSAGE E007(DEMOOFFICEINTEGRATIO).
  ENDIF.
ENDFORM.                    " FRM_DOI_CHECK
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_BDS_URL
*&---------------------------------------------------------------------*
*       Fetch Document URL
*----------------------------------------------------------------------*
*      -->I_CLSNAM  Class name
*      -->I_CLSTYP  Class type
*      -->I_TYPEID  Object key
*      -->I_FILENA  File name
*      <--E_URL     Document URL
*----------------------------------------------------------------------*
FORM FRM_GET_BDS_URL  USING I_CLSNAM TYPE BDS_CLSNAM
                            I_CLSTYP TYPE BDS_CLSTYP
                            I_TYPEID TYPE BDS_TYPEID
                            I_FILENA TYPE BDS_FILENA
                   CHANGING E_URL    TYPE BDS_URI.

* Business Document Set
  DATA: LR_BDS  TYPE REF TO CL_BDS_DOCUMENT_SET.
* Signature Table
  DATA: LT_SIGNAT TYPE TABLE OF BAPISIGNAT,
        LS_SIGNAT TYPE BAPISIGNAT.
* Component Table
  DATA: LT_COMPON TYPE TABLE OF BAPICOMPON,
        LS_COMPON TYPE BAPICOMPON.
* URI Table
  DATA: LT_URIS TYPE TABLE OF BAPIURI,
        LS_URIS TYPE BAPIURI.

* Create a Business Document Set
  CREATE OBJECT LR_BDS.

* Fetch Information on Documents
  CALL METHOD LR_BDS->GET_INFO
    EXPORTING
      CLASSNAME       = I_CLSNAM
      CLASSTYPE       = I_CLSTYP
      OBJECT_KEY      = I_TYPEID
    CHANGING
      COMPONENTS      = LT_COMPON
      SIGNATURE       = LT_SIGNAT
    EXCEPTIONS
      NOTHING_FOUND   = 1
      ERROR_KPRO      = 2
      INTERNAL_ERROR  = 3
      PARAMETER_ERROR = 4
      NOT_AUTHORIZED  = 5
      NOT_ALLOWED     = 6
      OTHERS          = 7.

* Filter Signature Table
  READ TABLE LT_COMPON INTO LS_COMPON
                       WITH KEY COMP_ID = I_FILENA.
  IF SY-SUBRC EQ 0.
    DELETE LT_SIGNAT WHERE DOC_COUNT <> LS_COMPON-DOC_COUNT.
  ENDIF.

* Return Document by Transferring URL
  CALL METHOD LR_BDS->GET_WITH_URL
    EXPORTING
      CLASSNAME  = I_CLSNAM
      CLASSTYPE  = I_CLSTYP
      OBJECT_KEY = I_TYPEID
    CHANGING
      URIS       = LT_URIS
      SIGNATURE  = LT_SIGNAT.

* Return URL
  READ TABLE LT_URIS INTO LS_URIS INDEX 1.
  E_URL = LS_URIS-URI.

* Free objects
  FREE LR_BDS.
ENDFORM.                    " FRM_GET_BDS_URL
*&---------------------------------------------------------------------*
*&      Form  FRM_CREATE_DOI_OBJECTS
*&---------------------------------------------------------------------*
*       Create DOI Objects and Open a document
*----------------------------------------------------------------------*
*      -->I_URL            Document URL
*      -->I_INPLACE        Run Excel in-place
*      -->I_SHOW_TOOLBARS  Show Toolbars
**      -->I_PROTECT        Protect Document
*      -->ER_CONTROL       Container Control
*      -->ER_PROXY         General Document
*      <--ER_SPREADSHEET   Spreadsheet
*----------------------------------------------------------------------*
FORM FRM_CREATE_DOI_OBJECTS
        USING    I_URL           TYPE BDS_URI
                 I_INPLACE       TYPE C
                 I_SHOW_TOOLBARS TYPE C
*                 I_PROTECT       TYPE C
        CHANGING ER_CONTROL      TYPE REF TO I_OI_CONTAINER_CONTROL
                 ER_PROXY        TYPE REF TO I_OI_DOCUMENT_PROXY
                 ER_SPREADSHEET  TYPE REF TO I_OI_SPREADSHEET.

* Creates and Initializes the Document Container Control
  PERFORM FRM_INIT_CONTROL USING    I_INPLACE
                                    I_SHOW_TOOLBARS
                           CHANGING ER_CONTROL.

* Creates a Proxy Instance for Document Management
  PERFORM FRM_GET_DOCUMENT_PROXY USING ER_CONTROL CHANGING ER_PROXY.

* Open a document saved in business document service
  PERFORM FRM_OPEN_DOCUMENT USING    ER_PROXY
                                     I_URL
                            CHANGING ER_SPREADSHEET.
ENDFORM.                   "FRM_CREATE_DOI_OBJECTS
*&---------------------------------------------------------------------*
*&      Form  FRM_INIT_CONTROL
*&---------------------------------------------------------------------*
*       Creates and Initializes the Document Container Control
*----------------------------------------------------------------------*
*      <--ER_CONTROL  Document Container Control
*----------------------------------------------------------------------*
FORM FRM_INIT_CONTROL
       USING    I_INPLACE       TYPE C
                I_SHOW_TOOLBARS TYPE C
       CHANGING ER_CONTROL TYPE REF TO I_OI_CONTAINER_CONTROL.

* Error Object
  DATA: LR_ERROR TYPE REF TO I_OI_ERROR.

* Creates a Container Control Instance
  CALL METHOD C_OI_CONTAINER_CONTROL_CREATOR=>GET_CONTAINER_CONTROL
    IMPORTING
      CONTROL = ER_CONTROL
      ERROR   = LR_ERROR.

* Triggers Error Display for Error
  CALL METHOD LR_ERROR->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.

* Creates and Initializes the Control
  CALL METHOD ER_CONTROL->INIT_CONTROL
    EXPORTING
      R3_APPLICATION_NAME      = SY-REPID
      INPLACE_ENABLED          = I_INPLACE "Run Excel in-place
      INPLACE_RESIZE_DOCUMENTS = 'X'
      INPLACE_SCROLL_DOCUMENTS = 'X'
      INPLACE_SHOW_TOOLBARS    = I_SHOW_TOOLBARS
      PARENT                   = CL_GUI_CONTAINER=>SCREEN0
      REGISTER_ON_CLOSE_EVENT  = 'X'
      REGISTER_ON_CUSTOM_EVENT = 'X'
      NO_FLUSH                 = 'X'
    IMPORTING
      ERROR                    = LR_ERROR
    EXCEPTIONS
      JAVABEANNOTSUPPORTED     = 1
      OTHERS                   = 2.

* Triggers Error Display for Error
  CALL METHOD LR_ERROR->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.

  FREE LR_ERROR.
ENDFORM.                    " FRM_INIT_CONTROL
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_DOCUMENT_PROXY
*&---------------------------------------------------------------------*
*       Creates a Proxy Instance for Document Management
*----------------------------------------------------------------------*
*      -->IR_CONTROL  Document Container Control
*      <--ER_PROXY    General Document
*----------------------------------------------------------------------*
FORM FRM_GET_DOCUMENT_PROXY
        USING    IR_CONTROL TYPE REF TO I_OI_CONTAINER_CONTROL
        CHANGING ER_PROXY   TYPE REF TO I_OI_DOCUMENT_PROXY.

* Error Object
  DATA: LR_ERROR TYPE REF TO I_OI_ERROR.

* Creates a Proxy Instance for Document Management
  CALL METHOD IR_CONTROL->GET_DOCUMENT_PROXY
    EXPORTING
      DOCUMENT_TYPE  = 'Excel.Sheet'
      NO_FLUSH       = 'X'
    IMPORTING
      DOCUMENT_PROXY = ER_PROXY
      ERROR          = LR_ERROR.

* Triggers Error Display for Error
  CALL METHOD LR_ERROR->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE LR_ERROR.
ENDFORM.                    " FRM_GET_DOCUMENT_PROXY
*&---------------------------------------------------------------------*
*&      Form  FRM_OPEN_DOCUMENT
*&---------------------------------------------------------------------*
*       Open a document saved in business document service
*----------------------------------------------------------------------*
*      -->IR_PROXY        General Document
*      -->I_URL           BDS URL
*      <--ER_SPREADSHEET  Spreadsheet
*----------------------------------------------------------------------*
FORM FRM_OPEN_DOCUMENT
       USING    IR_PROXY       TYPE REF TO I_OI_DOCUMENT_PROXY
                I_URL          TYPE BDS_URI
       CHANGING ER_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET .

* Error Object
  DATA: LR_ERROR TYPE REF TO I_OI_ERROR.

* Open a document saved in business document service
  CALL METHOD IR_PROXY->OPEN_DOCUMENT
    EXPORTING
      OPEN_INPLACE = 'X'
      DOCUMENT_URL = I_URL.

* Returns a Spreadsheet Instance
  CALL METHOD IR_PROXY->GET_SPREADSHEET_INTERFACE
    EXPORTING
      NO_FLUSH        = 'X'
    IMPORTING
      SHEET_INTERFACE = ER_SPREADSHEET
      ERROR           = LR_ERROR.
* Triggers Error Display for Error
  CALL METHOD LR_ERROR->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE LR_ERROR.

* Activate Sheet1
  CALL METHOD ER_SPREADSHEET->SELECT_SHEET
    EXPORTING
      NO_FLUSH = SPACE
      NAME     = 'Sheet1'
    IMPORTING
      ERROR    = LR_ERROR.

* Triggers Error Display for Error
  CALL METHOD LR_ERROR->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE LR_ERROR.
ENDFORM.                    " FRM_OPEN_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  FRM_SAVE_COPY_AS
*&---------------------------------------------------------------------*
*       Saves Document Locally
*----------------------------------------------------------------------*
*      -->IR_PROXY     General Document
*      -->I_FILE_NAME  Default File Name
*----------------------------------------------------------------------*
FORM FRM_SAVE_COPY_AS  USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                             I_FILE_NAME TYPE CLIKE.
  DATA: L_FILENA  TYPE BDS_FILENA,
        L_RETCODE TYPE SOI_RET_STRING.

* Shows a File Save Dialog
  PERFORM FRM_DOI_FILE_SAVE_DIALOG
            USING    I_FILE_NAME
                     'Excel Files (*.xls)|*.xls'
            CHANGING L_FILENA.

  CHECK NOT L_FILENA IS INITIAL.



* Saves Document Locally
  CALL METHOD IR_PROXY->SAVE_COPY_AS
    EXPORTING
      FILE_NAME   = L_FILENA
      PROMPT_USER = SPACE
    IMPORTING
      RETCODE     = L_RETCODE.
  IF L_RETCODE EQ 'OK'.
    MESSAGE S398(00) WITH '文件已保存至：' L_FILENA.
  ENDIF.
ENDFORM.                    " FRM_SAVE_COPY_AS
*&---------------------------------------------------------------------*
*&      Form  FRM_DOI_FILE_SAVE_DIALOG
*&---------------------------------------------------------------------*
*       Shows a File Save Dialog
*       定义File Type Filter,最后一个为默认的显示,与DEFAULT_EXTENSION无关
* 'All Files (*.*)|*.*|Excel Files (*.xls)|*.xls|Word files(*.doc)|*.doc'
*----------------------------------------------------------------------*
*      -->I_DEFAULT_FILE_NAME   Default File Name
*      -->I_FILE_FILTER         File Type Filter
*      <--E_FULLPATH            Path + File Name
*----------------------------------------------------------------------*
FORM FRM_DOI_FILE_SAVE_DIALOG  USING I_DEFAULT_FILE_NAME TYPE CLIKE
                                     I_FILE_FILTER TYPE CLIKE
                            CHANGING E_FULLPATH TYPE CLIKE.
  DATA: L_DEFAULT_FILE_NAME TYPE STRING,
        L_FILE_FILTER TYPE STRING,
        L_FILENAME    TYPE STRING,
        L_PATH        TYPE STRING,
        L_FULLPATH    TYPE STRING.

* Set values
  L_DEFAULT_FILE_NAME = I_DEFAULT_FILE_NAME.
  L_FILE_FILTER       = I_FILE_FILTER.
  CLEAR E_FULLPATH.

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

  E_FULLPATH = L_FULLPATH.
ENDFORM.                    " FRM_DOI_FILE_SAVE_DIALOG
*&---------------------------------------------------------------------*
*&      Form  FRM_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  FRM_DOI_PRINT  General Document
*----------------------------------------------------------------------*
FORM FRM_DOI_PRINT USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY.
  DATA: L_RETCODE TYPE SOI_RET_STRING.
* 打印
  CALL METHOD IR_PROXY->PRINT_DOCUMENT
    EXPORTING
      NO_FLUSH    = ' '
      PROMPT_USER = 'X'
    IMPORTING
      RETCODE     = L_RETCODE.
*  BREAK-POINT.
ENDFORM.                    " FRM_DOI_PRINT
*&---------------------------------------------------------------------*
*&      Form  FRM_HIDE_ROWS
*&---------------------------------------------------------------------*
*       Hide Rows
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*      -->I_BEG_ROWS      Begin Rows
*      -->I_END_ROWS      End Rows
*----------------------------------------------------------------------*
FORM FRM_HIDE_ROWS  USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
                           I_BEG_ROWS TYPE I
                           I_END_ROWS TYPE I .
* Range Name
  DATA: L_NAME(128) TYPE C,
        L_ROWS TYPE I.

*  DATA: LS_HIDE TYPE TY_HIDE.
*  LS_HIDE-BEG_ROWS = I_BEG_ROWS.
*  LS_HIDE-END_ROWS = I_END_ROWS.
*  APPEND LS_HIDE TO GT_HIDE.
*  CLEAR LS_HIDE.

  L_ROWS = I_END_ROWS - I_BEG_ROWS + 1.

* Get unique range name
  PERFORM FRM_GET_RANGE_NAME USING 'hid' 1 I_BEG_ROWS CHANGING L_NAME.

* Get a Range Based on its Dimensions
  CALL METHOD IR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = L_NAME
      NO_FLUSH = 'X'
      TOP      = I_BEG_ROWS
      LEFT     = 1
      ROWS     = L_ROWS
      COLUMNS  = 1.

* Hide Rows
  CALL METHOD IR_SPREADSHEET->HIDE_ROWS
    EXPORTING
      NAME     = L_NAME
      NO_FLUSH = SPACE.
ENDFORM.                    " FRM_HIDE_ROWS
*&---------------------------------------------------------------------*
*&      Form  FRM_SHOW_ROWS
*&---------------------------------------------------------------------*
*       Show Rows
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*      -->I_BEG_ROWS      Begin Rows
*      -->I_END_ROWS      End Rows
*----------------------------------------------------------------------*
FORM FRM_SHOW_ROWS  USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
                           I_BEG_ROWS TYPE I
                           I_END_ROWS TYPE I .
* Range Name
  DATA: L_NAME(128) TYPE C,
        L_ROWS TYPE I.

  L_ROWS = I_END_ROWS - I_BEG_ROWS + 1.

* Get unique range name
  PERFORM FRM_GET_RANGE_NAME USING 'shw' 1 I_BEG_ROWS CHANGING L_NAME.

* Get a Range Based on its Dimensions
  CALL METHOD IR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = L_NAME
      NO_FLUSH = 'X'
      TOP      = I_BEG_ROWS
      LEFT     = 1
      ROWS     = L_ROWS
      COLUMNS  = 1.

* Show Rows
  CALL METHOD IR_SPREADSHEET->SHOW_ROWS
    EXPORTING
      NAME     = L_NAME
      NO_FLUSH = SPACE.
ENDFORM.                    " FRM_SHOW_ROWS
*&---------------------------------------------------------------------*
*&      Form  FRM_DELETE_ROWS
*&---------------------------------------------------------------------*
*       Delete rows
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*      -->I_BEG_ROWS      Begin Rows
*      -->I_END_ROWS      End Rows
*----------------------------------------------------------------------*
FORM FRM_DELETE_ROWS  USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
                            I_BEG_ROWS TYPE I
                            I_END_ROWS TYPE I .
* Range Name
  DATA: L_NAME(128) TYPE C,
        L_ROWS TYPE I.

* Ranges
  DATA: LT_RANGES TYPE SOI_RANGE_LIST,
        LS_RANGES TYPE SOI_RANGE_ITEM.

  L_ROWS = I_END_ROWS - I_BEG_ROWS + 1.

* Get unique range name
  PERFORM FRM_GET_RANGE_NAME USING 'del' 1 I_BEG_ROWS CHANGING L_NAME.

* Get a Range Based on its Dimensions
  CALL METHOD IR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = L_NAME
      NO_FLUSH = 'X'
      TOP      = I_BEG_ROWS
      LEFT     = 1
      ROWS     = L_ROWS
      COLUMNS  = 256.

  LS_RANGES-NAME = L_NAME.
  APPEND LS_RANGES TO LT_RANGES.
  CLEAR LS_RANGES.

* Delete Content and Formatting of a Range
  CALL METHOD IR_SPREADSHEET->DELETE_CONTENT_RANGES
    EXPORTING
      NO_FLUSH = 'X'
      RANGES   = LT_RANGES.
ENDFORM.                    " FRM_DELETE_ROWS
*&---------------------------------------------------------------------*
*&      Form  FRM_DELETE_RANGE
*&---------------------------------------------------------------------*
*       Delete the definition of one range
*       The contents of the range are not deleted.
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*      -->I_NAME          Range name
*----------------------------------------------------------------------*
FORM FRM_DELETE_RANGE USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
                             I_NAME.
  DATA: LT_RANGES TYPE SOI_RANGE_LIST,
        LS_RANGES TYPE SOI_RANGE_ITEM.

  LS_RANGES-NAME = I_NAME.
  APPEND LS_RANGES TO LT_RANGES.
  CLEAR LS_RANGES.

* Deletes Entire Ranges
  CALL METHOD IR_SPREADSHEET->DELETE_RANGES
    EXPORTING
      NO_FLUSH = 'X'
      RANGES   = LT_RANGES.
ENDFORM.                    " FRM_DELETE_RANGE
*&---------------------------------------------------------------------*
*&      Form  FRM_DELETE_ALL_RANGES
*&---------------------------------------------------------------------*
*       Delete the definitions of all ranges in the worksheet.
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*----------------------------------------------------------------------*
FORM FRM_DELETE_ALL_RANGES
        USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET.

  DATA: LT_RANGES TYPE SOI_RANGE_LIST.
  DATA: L_ERROR TYPE REF TO I_OI_ERROR,
        L_RETCODE TYPE SOI_RET_STRING.
* Returns a table of all ranges with their sizes
  CALL METHOD IR_SPREADSHEET->GET_RANGES_NAMES
    EXPORTING
      NO_FLUSH = ' '
      UPDATING = -1
    IMPORTING
      ERROR    = L_ERROR
      RETCODE  = L_RETCODE
      RANGES   = LT_RANGES.

  DELETE LT_RANGES WHERE NAME CP '*Print_Titles'.

* Deletes Entire Ranges
  CALL METHOD IR_SPREADSHEET->DELETE_RANGES
    EXPORTING
      NO_FLUSH = 'X'
      RANGES   = LT_RANGES.
ENDFORM.                    " FRM_DELETE_ALL_RANGES
*&---------------------------------------------------------------------*
*&      Form  FRM_SET_CELL_VALUE
*&---------------------------------------------------------------------*
*       Insert a cell and set the cell's value
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*      -->I_TOP           Top Left-Hand Corner
*      -->I_LEFT          Top Left-Hand Corner
*      -->I_VALUE         Cell Value
*----------------------------------------------------------------------*
FORM FRM_SET_CELL_VALUE
        USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
              I_TOP   TYPE I
              I_LEFT  TYPE I
              I_VALUE.

* Range Name
  DATA: L_NAME(128).
  DATA: LT_RANGES TYPE SOI_RANGE_LIST   ,
        LT_VALUES TYPE SOI_GENERIC_TABLE.

* Get unique range name
  PERFORM FRM_GET_RANGE_NAME USING 'cel' I_LEFT I_TOP CHANGING L_NAME.
* Add range to range list
  PERFORM FRM_ADD_TO_RANGE_LIST  USING 1 1 L_NAME CHANGING LT_RANGES.
* Add value to DOI value table
  PERFORM FRM_ADD_TO_VALUE_TABLE USING 1 1 I_VALUE CHANGING LT_VALUES.

* Get a Range Based on its Dimensions
  CALL METHOD IR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NO_FLUSH = 'X'
      NAME     = L_NAME
      LEFT     = I_LEFT
      TOP      = I_TOP
      ROWS     = 1
      COLUMNS  = 1.

* Set the Data for a Range
  CALL METHOD IR_SPREADSHEET->SET_RANGES_DATA
    EXPORTING
      RANGES   = LT_RANGES
      CONTENTS = LT_VALUES
      NO_FLUSH = 'X'.
ENDFORM.                    " FRM_SET_CELL_VALUE
*&---------------------------------------------------------------------*
*&      Form  FRM_ADD_TO_VALUE_TABLE
*&---------------------------------------------------------------------*
*       Add value to DOI value table
*----------------------------------------------------------------------*
*      -->I_ROW      Row
*      -->I_COLUMN   Column
*      -->I_VALUE    Value
*      <--MT_VALUES  Value table
*----------------------------------------------------------------------*
FORM FRM_ADD_TO_VALUE_TABLE  USING    I_ROW    TYPE I
                                      I_COLUMN TYPE I
                                      I_VALUE
                             CHANGING MT_VALUES TYPE SOI_GENERIC_TABLE.
  DATA: LS_VALUES TYPE SOI_GENERIC_ITEM.

*  CHECK I_VALUE IS NOT INITIAL.

  LS_VALUES-ROW    = I_ROW.
  LS_VALUES-COLUMN = I_COLUMN.
  WRITE I_VALUE TO LS_VALUES-VALUE.
*  LS_VALUES-VALUE  = I_VALUE.
  SHIFT LS_VALUES-VALUE LEFT DELETING LEADING SPACE.
  APPEND LS_VALUES TO MT_VALUES.
  CLEAR LS_VALUES.
ENDFORM.                    " FRM_ADD_TO_VALUE_TABLE
*&---------------------------------------------------------------------*
*&      Form  FRM_ADD_TO_RANGE_LIST
*&---------------------------------------------------------------------*
*       Add range to DOI range list
*----------------------------------------------------------------------*
*      -->I_ROW      Row
*      -->I_COLUMN   Column
*      -->I_NAME     Range Name
*      <--MT_RANGES  Range List
*----------------------------------------------------------------------*
FORM FRM_ADD_TO_RANGE_LIST  USING    I_ROW    TYPE I
                                     I_COLUMN TYPE I
                                     I_NAME
                            CHANGING MT_RANGES TYPE SOI_RANGE_LIST.
  DATA: LS_RANGES TYPE SOI_RANGE_ITEM.

  LS_RANGES-NAME    = I_NAME  .
  LS_RANGES-ROWS    = I_ROW   .
  LS_RANGES-COLUMNS = I_COLUMN.
  APPEND LS_RANGES TO MT_RANGES.
  CLEAR LS_RANGES.
ENDFORM.                    " FRM_ADD_TO_RANGE_LIST
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_RANGE_NAME
*&---------------------------------------------------------------------*
*       Get unique range name
*----------------------------------------------------------------------*
*      -->I_NAME    Prefix
*      -->I_TOP     Top Left-Hand Corner
*      -->I_LEFT    Top Left-Hand Corner
*      <--E_NAME    Range Name
*----------------------------------------------------------------------*
FORM FRM_GET_RANGE_NAME  USING    I_NAME TYPE CLIKE
                                  I_TOP  TYPE I
                                  I_LEFT TYPE I
                         CHANGING E_NAME.
* Range Name
  DATA: L_LEFT TYPE STRING,
        L_TOP  TYPE STRING.
  L_LEFT = I_LEFT.
  L_TOP  = I_TOP .

* Get unique name
  CONCATENATE I_NAME
              '_'
              L_LEFT
              '_'
              L_TOP
         INTO E_NAME.
  CONDENSE E_NAME NO-GAPS.
ENDFORM.                    " FRM_GET_RANGE_NAME
*&---------------------------------------------------------------------*
*&      Form  FRM_INSERT_TABLE_RANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*      -->I_TOP           Top Left-Hand Corner
*      -->I_LEFT          Top Left-Hand Corner
*      -->IT_TABLE        Data Table
*      -->I_BEG_COLUMN    Begin Column
*      -->I_END_COLUMN    End Column
*----------------------------------------------------------------------*
FORM FRM_INSERT_TABLE_RANGE
       USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
             I_TOP  TYPE I
             I_LEFT TYPE I
             IT_TABLE TYPE INDEX TABLE
             I_BEG_COLUMN TYPE I
             I_END_COLUMN TYPE I.

  DATA: L_NAME(128) TYPE C,
        L_ROWS    TYPE I,
        L_COLUMNS TYPE I.

  DATA: LT_RANGES TYPE SOI_RANGE_LIST,
        LT_VALUES TYPE SOI_GENERIC_TABLE.

  DATA: L_INDEX TYPE I.
  FIELD-SYMBOLS: <FS_LINE> TYPE ANY,
                 <F_VALUE> TYPE ANY.

* Check
  IF I_BEG_COLUMN > I_END_COLUMN.
    MESSAGE '开始列不能大于结束列' TYPE 'A'.
  ENDIF.

* Get Dimensions Parameters
  DESCRIBE TABLE IT_TABLE LINES L_ROWS.
  L_COLUMNS = I_END_COLUMN - I_BEG_COLUMN + 1.

* Get unique range name
  PERFORM FRM_GET_RANGE_NAME USING 'tab' I_LEFT I_TOP CHANGING L_NAME.

* Get a Range Based on its Dimensions'
  CALL METHOD IR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = L_NAME
      NO_FLUSH = 'X'
      LEFT     = I_LEFT
      TOP      = I_TOP
      ROWS     = L_ROWS
      COLUMNS  = L_COLUMNS.

* Add range to range list
  PERFORM FRM_ADD_TO_RANGE_LIST USING    L_ROWS
                                         L_COLUMNS
                                         L_NAME
                                CHANGING LT_RANGES.

* Add value to DOI value table
  L_INDEX = I_END_COLUMN - I_BEG_COLUMN + 1.
  LOOP AT IT_TABLE ASSIGNING <FS_LINE>.
    L_ROWS    = SY-TABIX.
    L_COLUMNS = 1.
    L_INDEX = I_BEG_COLUMN.
    WHILE L_INDEX <= I_END_COLUMN.
      ASSIGN COMPONENT L_INDEX OF STRUCTURE <FS_LINE> TO <F_VALUE>.
      PERFORM FRM_ADD_TO_VALUE_TABLE USING    L_ROWS
                                              L_COLUMNS
                                              <F_VALUE>
                                     CHANGING LT_VALUES.
      L_COLUMNS = L_COLUMNS + 1.
      L_INDEX   = L_INDEX + 1.
    ENDWHILE.
  ENDLOOP.

* Set the Data for a Range
  CALL METHOD IR_SPREADSHEET->SET_RANGES_DATA
    EXPORTING
      RANGES   = LT_RANGES
      CONTENTS = LT_VALUES
      NO_FLUSH = 'X'.

ENDFORM.                    " FRM_INSERT_TABLE_RANGE
*&---------------------------------------------------------------------*
*&      Form  FRM_UNPROTECT_NAME
*&---------------------------------------------------------------------*
*       根据范围名称取消保护
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  Spreadsheet
*      <--I_NAME          Range Name
*----------------------------------------------------------------------*
FORM FRM_UNPROTECT_NAME
  USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
        I_NAME TYPE CLIKE.

  CALL METHOD IR_SPREADSHEET->PROTECT_RANGE
    EXPORTING
      NO_FLUSH = SPACE
      NAME     = I_NAME
      PROTECT  = SPACE.
ENDFORM.                    " FRM_UNPROTECT_NAME
*&---------------------------------------------------------------------*
*&      Form  FRM_UNPROTEC_RANGE
*&---------------------------------------------------------------------*
*       取消保护范围
*----------------------------------------------------------------------*
*      -->P_11     text
*----------------------------------------------------------------------*
FORM FRM_UNPROTEC_RANGE
  USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
        I_TOP  TYPE I
        I_LEFT TYPE I
        I_ROWS TYPE I
        I_COLUMNS TYPE I.

  DATA: L_NAME(128) TYPE C.
* 插入空范围
  PERFORM FRM_INSERT_EMPTY_RANGE USING IR_SPREADSHEET 5 2 3 4
                              CHANGING L_NAME.
* 取消保护范围
  CALL METHOD IR_SPREADSHEET->PROTECT_RANGE
    EXPORTING
      NO_FLUSH = SPACE
      NAME     = L_NAME
      PROTECT  = SPACE.
ENDFORM.                    " FRM_UNPROTEC_RANGE
*&---------------------------------------------------------------------*
*&      Form  FRM_INSERT_EMPTY_RANGE
*&---------------------------------------------------------------------*
*       插入空范围
*----------------------------------------------------------------------*
*      -->IR_SPREADSHEET  text
*      -->I_TOP        text
*      -->I_LEFT       text
*      -->I_ROWS       text
*      -->I_COLUMNS    text
*      <--E_NAME       text
*----------------------------------------------------------------------*
FORM FRM_INSERT_EMPTY_RANGE
        USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
              I_TOP  TYPE I
              I_LEFT TYPE I
              I_ROWS TYPE I
              I_COLUMNS TYPE I
        CHANGING E_NAME.

* Get unique range name
  PERFORM FRM_GET_RANGE_NAME USING 'emp' I_LEFT I_TOP CHANGING E_NAME.

* Get a Range Based on its Dimensions'
  CALL METHOD IR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = E_NAME
      NO_FLUSH = 'X'
      LEFT     = I_LEFT
      TOP      = I_TOP
      ROWS     = I_ROWS
      COLUMNS  = I_COLUMNS.
ENDFORM.                    " FRM_INSERT_EMPTY_RANGE
**&---------------------------------------------------------------------*
**&      Form  FRM_NEXT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
*FORM FRM_NEXT
*       USING IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET.
*  DATA: LT_RANGES TYPE SOI_RANGE_LIST.
*
*** 取消预留行
**  DATA: LS_HIDE TYPE TY_HIDE.
**  LOOP AT GT_HIDE INTO LS_HIDE.
**    PERFORM FRM_SHOW_ROWS USING IR_SPREADSHEET
**                                LS_HIDE-BEG_ROWS
**                                LS_HIDE-END_ROWS.
**  ENDLOOP.
*
** Returns a table of all ranges with their sizes
*  CALL METHOD IR_SPREADSHEET->GET_RANGES_NAMES
*    EXPORTING
*      NO_FLUSH = ' '
*      UPDATING = -1
*    IMPORTING
*      RANGES   = LT_RANGES.
*
*  DELETE LT_RANGES WHERE NAME CP '*Print_Titles'.
*
*  CALL METHOD IR_SPREADSHEET->DELETE_CONTENT_RANGES
*    EXPORTING
*      NO_FLUSH = 'X'
*      RANGES   = LT_RANGES.
*
** Deletes Entire Ranges
*  CALL METHOD IR_SPREADSHEET->DELETE_RANGES
*    EXPORTING
*      NO_FLUSH = 'X'
*      RANGES   = LT_RANGES.
*ENDFORM.                    " FRM_NEXT
*&---------------------------------------------------------------------*
*&      Form  FRM_COPY_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  IR_PROXY    General Document
*  -->  I_PARAM     Parameters
*----------------------------------------------------------------------*
FORM FRM_COPY_TEMPLATE USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                             I_PARAM .
  PERFORM FRM_EXECUTE_MACRO1 USING IR_PROXY '模块1.copy' I_PARAM.
ENDFORM.                    " FRM_COPY_TEMPLATE
*&---------------------------------------------------------------------*
*&      Form  FRM_EXECUTE_MACRO
*&---------------------------------------------------------------------*
*       执行宏(无参数)
*----------------------------------------------------------------------*
*      -->IR_PROXY  General Document
*      -->I_MACRO   Macro Name
*----------------------------------------------------------------------*
FORM FRM_EXECUTE_MACRO USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                               I_MACRO.
* 执行宏
  CALL METHOD IR_PROXY->EXECUTE_MACRO
    EXPORTING
      MACRO_STRING = I_MACRO
      NO_FLUSH     = 'X'.
ENDFORM.                    " FRM_EXECUTE_MACRO
*&---------------------------------------------------------------------*
*&      Form  FRM_EXECUTE_MACRO1
*&---------------------------------------------------------------------*
*       执行宏(单一参数)
*----------------------------------------------------------------------*
*      -->IR_PROXY  General Document
*      -->I_MACRO   Macro Name
*      -->I_PARAM1  参数1
*----------------------------------------------------------------------*
FORM FRM_EXECUTE_MACRO1 USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                               I_MACRO
                               I_PARAM1 .
* 执行宏
  CALL METHOD IR_PROXY->EXECUTE_MACRO
    EXPORTING
      MACRO_STRING = I_MACRO
      NO_FLUSH     = 'X'
      PARAM1       = I_PARAM1
      PARAM_COUNT  = 1.
ENDFORM.                    " FRM_EXECUTE_MACRO1
*&---------------------------------------------------------------------*
*&      Form  FRM_EXECUTE_MACRO1
*&---------------------------------------------------------------------*
*       执行宏(两个参数)
*----------------------------------------------------------------------*
*      -->IR_PROXY  General Document
*      -->I_MACRO   Macro Name
*      -->I_PARAM1  参数1
*      -->I_PARAM2  参数2
*----------------------------------------------------------------------*
FORM FRM_EXECUTE_MACRO2 USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                               I_MACRO
                               I_PARAM1
                               I_PARAM2 .
* 执行宏
  CALL METHOD IR_PROXY->EXECUTE_MACRO
    EXPORTING
      MACRO_STRING = I_MACRO
      NO_FLUSH     = 'X'
      PARAM1       = I_PARAM1
      PARAM2       = I_PARAM2
      PARAM_COUNT  = 2.
ENDFORM.                    " FRM_EXECUTE_MACRO2
*&---------------------------------------------------------------------*
*&      Form  FRM_EXECUTE_MACRO3
*&---------------------------------------------------------------------*
*       执行宏(三个参数)
*----------------------------------------------------------------------*
*      -->IR_PROXY  General Document
*      -->I_MACRO   Macro Name
*      -->I_PARAM1  参数1
*      -->I_PARAM2  参数2
*      -->I_PARAM3  参数3
*----------------------------------------------------------------------*
FORM FRM_EXECUTE_MACRO3 USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                               I_MACRO
                               I_PARAM1
                               I_PARAM2
                               I_PARAM3 .
* 执行宏
  CALL METHOD IR_PROXY->EXECUTE_MACRO
    EXPORTING
      MACRO_STRING = I_MACRO
      NO_FLUSH     = 'X'
      PARAM1       = I_PARAM1
      PARAM2       = I_PARAM2
      PARAM3       = I_PARAM3
      PARAM_COUNT  = 3.
ENDFORM.                    " FRM_EXECUTE_MACRO3
*&---------------------------------------------------------------------*
*&      Form  FRM_EXECUTE_MACRO4
*&---------------------------------------------------------------------*
*       执行宏(四个参数)
*----------------------------------------------------------------------*
*      -->IR_PROXY  General Document
*      -->I_MACRO   Macro Name
*      -->I_PARAM1  参数1
*      -->I_PARAM2  参数2
*      -->I_PARAM3  参数3
*      -->I_PARAM4  参数4
*----------------------------------------------------------------------*
FORM FRM_EXECUTE_MACRO4 USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                               I_MACRO
                               I_PARAM1
                               I_PARAM2
                               I_PARAM3
                               I_PARAM4 .
* 执行宏
  CALL METHOD IR_PROXY->EXECUTE_MACRO
    EXPORTING
      MACRO_STRING = I_MACRO
      NO_FLUSH     = 'X'
      PARAM1       = I_PARAM1
      PARAM2       = I_PARAM2
      PARAM3       = I_PARAM3
      PARAM4       = I_PARAM4
      PARAM_COUNT  = 4.
ENDFORM.                    " FRM_EXECUTE_MACRO4
*&---------------------------------------------------------------------*
*&      Form  FRM_DEL_LAST_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IR_PROXY  General Document
*      -->I_PAGE    页数
*      -->I_ROWS    每页多少行
*----------------------------------------------------------------------*
FORM FRM_DEL_LAST_PRINT
       USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
             I_PAGE TYPE I
             I_ROWS TYPE I.
  DATA: L_ROWS TYPE I,
        L_STR TYPE STRING.

  CHECK I_PAGE > 0.

  L_ROWS = I_PAGE * I_ROWS.
  L_STR  = L_ROWS.
  CONCATENATE '1:' L_STR INTO L_STR.

  PERFORM FRM_EXECUTE_MACRO1 USING IR_PROXY '模块1.del' L_STR.
ENDFORM.                    " FRM_DEL_LAST_PRINT
*&---------------------------------------------------------------------*
*&      Form  FRM_CONT_PRINT
*&---------------------------------------------------------------------*
*       连续打印
*----------------------------------------------------------------------*
*  -->  IR_PROXY          General Document
*  -->  IR_SPREADSHEET    Spreadsheet
*  -->  T_LINES         Print Group by Lines
*----------------------------------------------------------------------*
FORM FRM_CONT_PRINT
       USING IR_PROXY       TYPE REF TO I_OI_DOCUMENT_PROXY
             IR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET
             IT_LINES       TYPE INT4_TABLE.

  DATA: LS_LINES TYPE INT4.

  DATA: L_TOP TYPE I,
        L_STR TYPE STRING,
        L_PAR TYPE STRING.

  LOOP AT IT_LINES INTO LS_LINES.
    L_STR = L_TOP + 1.
    L_TOP = L_TOP + LS_LINES.
    L_PAR = L_TOP.
*-- 填充指定行的数据
    CONCATENATE L_STR ':' L_PAR INTO L_PAR.
    CONDENSE L_PAR NO-GAPS.
    PERFORM FRM_EXECUTE_MACRO1 USING IR_PROXY '模块2.copy' L_PAR.
*-- 打印
    CALL METHOD IR_SPREADSHEET->PRINT
      EXPORTING
        NAME = 'Sheet3'.
*-- 删除填充行
    L_PAR  = LS_LINES.
    CONCATENATE '1:' L_PAR INTO L_PAR.
    CONDENSE L_PAR NO-GAPS.
    PERFORM FRM_EXECUTE_MACRO1 USING IR_PROXY '模块2.del' L_PAR.
  ENDLOOP.

ENDFORM.                    " FRM_CONT_PRINT
*&---------------------------------------------------------------------*
*&      Form  FRM_SAVE_COPY_AS
*&---------------------------------------------------------------------*
*       Saves Document Locally
*----------------------------------------------------------------------*
*      -->IR_PROXY     General Document
*      -->I_FILE_NAME  Default File Name
*----------------------------------------------------------------------*
FORM FRM_SAVE_COPY2INTABLE  USING IR_PROXY TYPE REF TO I_OI_DOCUMENT_PROXY
                            CHANGING LT_TABLES TYPE SOLIX_TAB.
  DATA: L_FILENA  TYPE BDS_FILENA,
        L_RETCODE TYPE SOI_RET_STRING,
        L_SIZE TYPE I.
*  DATA:LT_TABLES TYPE TABLE OF SOLIX. SOLIX_TAB
  DATA:   V_XATTACH TYPE XSTRING,
        LV_MID       TYPE STRING.

  CONSTANTS: C_MIMETYPE TYPE CHAR64
                         VALUE 'APPLICATION/MSEXCEL;charset=utf-16le'.


* Saves Document Locally
  CALL METHOD IR_PROXY->SAVE_DOCUMENT_TO_TABLE
*    EXPORTING
*      FILE_NAME      = L_FILENA
*      PROMPT_USER    = SPACE
    IMPORTING
      RETCODE        = L_RETCODE
    CHANGING
      DOCUMENT_TABLE = LT_TABLES
      DOCUMENT_SIZE = L_SIZE
      .
*
*
*  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
*    EXPORTING
*      INPUT_LENGTH        = L_SIZE
**                    FIRST_LINE          = 0
**                    LAST_LINE           = 0
**                    MIMETYPE            = ' '
*                  IMPORTING
*     TEXT_BUFFER         = LV_MID
**                    OUTPUT_LENGTH       =
*    TABLES
*      BINARY_TAB          = LT_TABLES
**                  EXCEPTIONS
**                    FAILED              = 1
**                    OTHERS              = 2
*            .
*  IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
*    EXPORTING
*      TEXT     = LV_MID
*      MIMETYPE = C_MIMETYPE
*    IMPORTING
*      BUFFER   = V_XATTACH
*    EXCEPTIONS
*      FAILED   = 1
*      OTHERS   = 2.
*
**  Add the file header for utf-16le.             .
*  IF SY-SUBRC = 0.
*    CONCATENATE CL_ABAP_CHAR_UTILITIES=>BYTE_ORDER_MARK_LITTLE
*                V_XATTACH INTO V_XATTACH IN BYTE MODE.
*  ENDIF.
*
*  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*    EXPORTING
*      BUFFER     = V_XATTACH
*    TABLES
*      BINARY_TAB = LT_TABLES.
*


ENDFORM.                    " FRM_SAVE_COPY_AS
