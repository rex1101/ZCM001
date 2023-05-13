FUNCTION ZCM_GET_BDC_RFC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(NAME) TYPE  APQI-GROUPID
*"     VALUE(DESTINATION) TYPE  RFCDEST OPTIONAL
*"  EXPORTING
*"     VALUE(CTU_PARAMS) TYPE  CTU_PARAMS
*"     VALUE(TCODE) TYPE  TCODE
*"  TABLES
*"      BDC_TAB STRUCTURE  BDCDATA OPTIONAL
*"      BDC_FCAT TYPE  LVC_T_FCAT OPTIONAL
*"      BDC_TAB_FIELD STRUCTURE  BDCDATA OPTIONAL
*"----------------------------------------------------------------------



  IF DESTINATION IS INITIAL.
    CALL FUNCTION 'ZCM_GET_BDC'
      EXPORTING
        NAME          = NAME
      IMPORTING
        CTU_PARAMS    = CTU_PARAMS
        TCODE         = TCODE
      TABLES
        BDC_TAB       = BDC_TAB
        BDC_FCAT      = BDC_FCAT
        BDC_TAB_FIELD = BDC_TAB_FIELD
        .
  ELSE.
    CALL FUNCTION 'ZCM_GET_BDC' DESTINATION DESTINATION
      EXPORTING
        NAME          = NAME
      IMPORTING
        CTU_PARAMS    = CTU_PARAMS
        TCODE         = TCODE
      TABLES
        BDC_TAB       = BDC_TAB
        BDC_FCAT      = BDC_FCAT
        BDC_TAB_FIELD = BDC_TAB_FIELD
        .

  ENDIF.




ENDFUNCTION.
