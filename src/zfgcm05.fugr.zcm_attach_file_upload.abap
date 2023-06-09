FUNCTION ZCM_ATTACH_FILE_UPLOAD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_ZCMT0007) TYPE  ZCMT0007
*"----------------------------------------------------------------------


  DATA: L_FILENAME TYPE RLGRAP-FILENAME.

    PERFORM FRM_FILE_OPEN_DIALOG USING '文件选择' '文件选择'
                                                   'Excel Files (*.xls)|*.xls'
                                                   L_FILENAME.



  DATA:LT_DATATAB      TYPE TABLE OF SSFDATA,
        LS_DATATAB TYPE SSFDATA.
  DATA: CTAB255 TYPE STANDARD TABLE OF SOLISTI1 .

  DATA: LV_PATH TYPE DBMSGORA-FILENAME.
  DATA: LV_STRING TYPE STRING.
  DATA: LV_FILENAME TYPE SDBAH-ACTID.
  DATA: LV_EXTENSION TYPE SDBAD-FUNCT.
  DATA: LV_BIN_FILESIZE TYPE I.
  DATA: LV_BUFFER       TYPE CHAR20.
  DATA: LV_BUZEI       TYPE CHAR3.

  DATA: L_ID TYPE C LENGTH 66.
  DATA: LV_RELID TYPE INDX_RELID.

  DATA: LT_ZCMT0004 TYPE TABLE OF ZCMT0004,
        LS_ZCMT0004 TYPE ZCMT0004.

  DATA: LS_ZCMT0003 TYPE ZCMT0003.
  DATA: LS_ZCMT0002 TYPE ZCMT0002.


  LV_PATH = L_FILENAME.
  LV_STRING = L_FILENAME.


  CALL FUNCTION 'SPLIT_FILENAME'
    EXPORTING
      LONG_FILENAME  = LV_PATH
    IMPORTING
      PURE_FILENAME  = LV_FILENAME
      PURE_EXTENSION = LV_EXTENSION.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME        = LV_STRING
      FILETYPE        = 'BIN'
    IMPORTING
      FILELENGTH      = LV_BIN_FILESIZE
    TABLES
      DATA_TAB        = LT_DATATAB
    EXCEPTIONS
      FILE_OPEN_ERROR = 1
      FILE_READ_ERROR = 2
      INVALID_TYPE    = 3
      NO_BATCH        = 4
      OTHERS          = 5.


  LV_BUFFER = LV_BIN_FILESIZE.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    LEAVE PROGRAM.
  ENDIF.

  DATA: LT_ZCMT0007 TYPE TABLE OF ZCMT0007,
    LS_ZCMT0007 TYPE ZCMT0007.

  LS_ZCMT0007-UUID = IS_ZCMT0007-UUID.
  LS_ZCMT0007-LOG_TYPE = IS_ZCMT0007-LOG_TYPE.
  LS_ZCMT0007-INTERFACE_CLASS = IS_ZCMT0007-INTERFACE_CLASS.
  LS_ZCMT0007-BUZEI = IS_ZCMT0007-BUZEI.
  LS_ZCMT0007-FILENAME = LV_FILENAME."
  LS_ZCMT0007-EXTENSION = LV_EXTENSION."
  LS_ZCMT0007-BUFFER = LV_BIN_FILESIZE."
  APPEND LS_ZCMT0007 TO LT_ZCMT0007.
  MODIFY ZCMT0007 FROM TABLE LT_ZCMT0007.

  CONCATENATE  LS_ZCMT0007-UUID LS_ZCMT0007-LOG_TYPE LS_ZCMT0007-INTERFACE_CLASS LS_ZCMT0007-BUZEI  INTO L_ID RESPECTING BLANKS.

  EXPORT FT_RETURN = LT_DATATAB
  TO DATABASE ZCMT0003(RT)
    FROM LS_ZCMT0003
  ID L_ID.





ENDFUNCTION.
