interface ZIF_CM_OOALV_EVENT
  public .



  data DATA_CHANGED_FORM type STRING .
  data DATA_CHANGED_FINISHED_FORM type STRING .
  data DOUBLE_CLICK_FORM type STRING .
  data HOTSPOT_CLICK_FORM type STRING .
  data TOP_OF_PAGE_FORM type STRING .
  data ON_F4_FORM type STRING .
  data TOOLBAR_FORM type STRING .
  data BEFORE_USER_COMMAND_FORM type STRING .
  data USER_COMMAND_FORM type STRING .
  data AFTER_USER_COMMAND_FORM type STRING .
  data BUTTON_CLICK_FORM type STRING .
  data CONTEXT_MENU_FORM type STRING .
  data MENU_BUTTON_FORM type STRING .

  methods HANDLE_DATA_CHANGED
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_BEFORE
      !E_ONF4_AFTER
      !E_UCOMM .
  methods HANDLE_DATA_CHANGED_FINISHED
    for event DATA_CHANGED_FINISHED of CL_GUI_ALV_GRID
    importing
      !E_MODIFIED
      !ET_GOOD_CELLS .
  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
  methods HANDLE_HOTSPOT_CLICK
    for event HOTSPOT_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW_ID
      !E_COLUMN_ID
      !ES_ROW_NO .
  methods PRINT_TOP_OF_PAGE
    for event PRINT_TOP_OF_PAGE of CL_GUI_ALV_GRID .
  methods HANDLE_ON_F4
    for event ONF4 of CL_GUI_ALV_GRID
    importing
      !SENDER
      !E_FIELDNAME
      !E_FIELDVALUE
      !ES_ROW_NO
      !ER_EVENT_DATA
      !ET_BAD_CELLS
      !E_DISPLAY .
  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_INTERACTIVE .
  methods HANDLE_BEFORE_USER_COMMAND
    for event BEFORE_USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods HANDLE_USER_COMMAND
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods HANDLE_AFTER_USER_COMMAND
    for event AFTER_USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM
      !E_SAVED
      !E_NOT_PROCESSED .
  methods HANDLE_BUTTON_CLICK
    for event BUTTON_CLICK of CL_GUI_ALV_GRID
    importing
      !ES_COL_ID
      !ES_ROW_NO .
  methods HANDLE_CONTEXT_MENU
    for event CONTEXT_MENU_REQUEST of CL_GUI_ALV_GRID
    importing
      !E_OBJECT .
  methods HANDLE_MENU_BUTTON
    for event MENU_BUTTON of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_UCOMM .
  methods FREE .
endinterface.
