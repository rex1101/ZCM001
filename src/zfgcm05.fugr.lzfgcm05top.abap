FUNCTION-POOL ZFGCM05.                      "MESSAGE-ID ..

* INCLUDE LZFGCM05D...                       " Local class definition
DATA: GT_GLOBE_TABLE TYPE TABLE OF ZCM_ATTACHMENT_LIST.
DATA: GV_GLOBE_UUID TYPE SYSUUID_C.
DATA: GV_FUNCTION TYPE CHAR10.
CONSTANTS: GC_DOWN TYPE CHAR10 VALUE 'DOWN'.
CONSTANTS: GC_UP TYPE CHAR10 VALUE 'UP'.
DATA: GS_UPOPTIONS TYPE ZCM_DOIUPOPTS.
FIELD-SYMBOLS: <DYN_UPLOAD_TABLE> TYPE TABLE.
DATA: G_SCRN TYPE SCRADNUM VALUE '9200'.
DATA: GO_OOALV TYPE REF TO ZCL_CM_OO_ALV.
DATA: GS_INSERT_ZCMT0007 TYPE ZCMT0007.
