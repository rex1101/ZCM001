FUNCTION ZCM_GET_BDC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(NAME) TYPE  APQI-GROUPID
*"  EXPORTING
*"     VALUE(CTU_PARAMS) TYPE  CTU_PARAMS
*"     VALUE(TCODE) TYPE  TCODE
*"  TABLES
*"      BDC_TAB STRUCTURE  BDCDATA OPTIONAL
*"      BDC_FCAT TYPE  LVC_T_FCAT OPTIONAL
*"      BDC_TAB_FIELD STRUCTURE  BDCDATA OPTIONAL
*"----------------------------------------------------------------------


  DATA: ITAB_APQI LIKE APQI OCCURS   0 WITH HEADER LINE.

  PERFORM FRM_CLEAR_GLOBE_BDC_VAR.

  CALL FUNCTION 'BDC_OBJECT_SELECT'
    EXPORTING
      NAME    = NAME
    TABLES
      APQITAB = ITAB_APQI
    EXCEPTIONS
      OTHERS  = 1.

  IF SY-SUBRC <> 0.
    MESSAGE A604 WITH 'BDC_OBJECT_SELECT' SY-SUBRC.
  ENDIF.

  READ TABLE ITAB_APQI INDEX 1.
  CHECK SY-SUBRC = 0.
  PERFORM FRM_GET_RECORD USING  ITAB_APQI-QID
                                ITAB_APQI-GROUPID
                                SPACE
                                GV_GLOBE_BDC_TCODE
                       CHANGING BDC_TAB[]
                                GV_GLOBE_CTU_PARAMS
                            .

  PERFORM FRM_BUILD_FCAT TABLES BDC_TAB.
  CTU_PARAMS = GV_GLOBE_CTU_PARAMS.
  BDC_FCAT[] = GT_GLOBE_BDC_FCAT[].
  BDC_TAB_FIELD[] = GT_GLOBE_BDC_TAB_FIELD[].
  TCODE = GV_GLOBE_BDC_TCODE.




ENDFUNCTION.
