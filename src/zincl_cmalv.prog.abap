*&---------------------------------------------------------------------*
*&  包含文件              ZINCL_CMALV
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_ALV_INSTANCE
*&---------------------------------------------------------------------*
*       获取ALV实例
*----------------------------------------------------------------------*
* example:
*  data: lr_alv type ref to cl_gui_alv_grid.
** 获取ALV instance
*  perform frm_get_alv_instance changing lr_alv.
*----------------------------------------------------------------------*
FORM FRM_GET_ALV_INSTANCE CHANGING ER_ALV TYPE REF TO CL_GUI_ALV_GRID .
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = ER_ALV.
ENDFORM.                    " FRM_GET_ALV_INSTANCE
*&---------------------------------------------------------------------*
*&      Form  FRM_SELECT_ALL
*&---------------------------------------------------------------------*
*       全选(已考虑筛选情况)
*----------------------------------------------------------------------*
* example:
* perform frm_select_all using gt_output 'CHKBOX' is_selfield.
*----------------------------------------------------------------------*
FORM FRM_SELECT_ALL USING IT_TABLE TYPE INDEX TABLE "表
                          I_FNAME TYPE LVC_FNAME "checkbox字段名称
                          IS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: LT_ENTRIES TYPE LVC_T_FIDX. "筛选的条目
  FIELD-SYMBOLS: <FS_LINE>. "行
  FIELD-SYMBOLS: <F_BOX>.   "选择字段

* 取被筛选的条目
  PERFORM FRM_GET_FILTERED_ENTRIES CHANGING LT_ENTRIES.

* 根据筛选项,确定行选择
  LOOP AT IT_TABLE ASSIGNING <FS_LINE>.
    ASSIGN COMPONENT I_FNAME OF STRUCTURE <FS_LINE> TO <F_BOX>.
    READ TABLE LT_ENTRIES TRANSPORTING NO FIELDS
                          WITH TABLE KEY TABLE_LINE = SY-TABIX.
    IF SY-SUBRC EQ 0. "被筛选
      <F_BOX> = ''.
    ELSE.
      <F_BOX> = 'X'.
    ENDIF.
  ENDLOOP.
* 刷新显示
  IS_SELFIELD-REFRESH = 'X'.
ENDFORM.                    " FRM_SELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  FRM_DESELECT_ALL
*&---------------------------------------------------------------------*
*       取消选择
*----------------------------------------------------------------------*
* example:
* perform frm_deselect_all using gt_output 'CHKBOX' is_selfield.
*----------------------------------------------------------------------*
FORM FRM_DESELECT_ALL USING IT_TABLE TYPE INDEX TABLE "表
                            I_FNAME TYPE LVC_FNAME "checkbox字段名称
                            IS_SELFIELD TYPE SLIS_SELFIELD.
  FIELD-SYMBOLS: <FS_LINE>. "行
  FIELD-SYMBOLS: <F_BOX>.   "选择字段
  LOOP AT IT_TABLE ASSIGNING <FS_LINE>.
    ASSIGN COMPONENT I_FNAME OF STRUCTURE <FS_LINE> TO <F_BOX>.
    <F_BOX> = ''.
  ENDLOOP.
* 刷新显示
  IS_SELFIELD-REFRESH = 'X'.
ENDFORM.                    " FRM_DESELECT_ALL
*&---------------------------------------------------------------------*
*&      Form  FRM_SELECT_CELL
*&---------------------------------------------------------------------*
*       选择单元格
*----------------------------------------------------------------------*
*      -->IT_TABLE  text
*      -->I_BFNAME   text
*      -->I_CFNAME   text
*      -->IS_SELFIELD  text
*----------------------------------------------------------------------*
FORM FRM_SELECT_CELL USING IT_TABLE TYPE INDEX TABLE "表
                            I_BFNAME TYPE LVC_FNAME "checkbox字段名称
                            I_CFNAME TYPE LVC_FNAME "单元格样式字段名称
                            IS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: LT_ENTRIES TYPE LVC_T_FIDX. "筛选的条目
  FIELD-SYMBOLS: <FS_LINE>, "行
                 <F_BOX>.   "选择字段
  FIELD-SYMBOLS: <FT_STYL> TYPE LVC_T_STYL.
  DATA: LS_STYLE TYPE LVC_S_STYL.

* 取被筛选的条目
  PERFORM FRM_GET_FILTERED_ENTRIES CHANGING LT_ENTRIES.

* 根据筛选项,确定行选择
  LOOP AT IT_TABLE ASSIGNING <FS_LINE>.
    ASSIGN COMPONENT I_BFNAME OF STRUCTURE <FS_LINE> TO <F_BOX>.
    READ TABLE LT_ENTRIES TRANSPORTING NO FIELDS
                          WITH TABLE KEY TABLE_LINE = SY-TABIX.
    IF SY-SUBRC EQ 0. "被筛选
      <F_BOX> = ''.
    ELSE.
      ASSIGN COMPONENT I_CFNAME OF STRUCTURE <FS_LINE> TO <FT_STYL>.
      READ TABLE <FT_STYL> INTO LS_STYLE WITH KEY FIELDNAME = I_BFNAME.
      IF SY-SUBRC EQ 0. "找得到样式, 如果不是不可编辑,选择
        IF LS_STYLE-STYLE <> CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          <F_BOX> = 'X'.
        ENDIF.
      ELSE. "找不到样式,就是可编辑的
        <F_BOX> = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.
* 刷新显示
  IS_SELFIELD-REFRESH = 'X'.
ENDFORM.                    " FRM_SELECT_CELL
*&---------------------------------------------------------------------*
*&      Form  FRM_DISABLED_CELL
*&---------------------------------------------------------------------*
*       单元格不可编辑
*----------------------------------------------------------------------*
*      -->I_FNAME   text
*      -->IT_STYL  text
*----------------------------------------------------------------------*
FORM FRM_DISABLED_CELL USING I_FNAME TYPE LVC_FNAME
                    CHANGING MT_STYL TYPE LVC_T_STYL.
  DATA: LS_STYLE TYPE LVC_S_STYL.
  LS_STYLE-FIELDNAME = I_FNAME.
  LS_STYLE-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
  INSERT LS_STYLE INTO TABLE MT_STYL.
  CLEAR LS_STYLE.
ENDFORM.                    " FRM_DISABLED_CELL
*&---------------------------------------------------------------------*
*&      Form  FRM_COLOR_CELL
*&---------------------------------------------------------------------*
*       单元格设置颜色
*----------------------------------------------------------------------*
*      -->I_FNAME   字段名称
*      -->I_COL     颜色
*      -->I_INT     强化
*      -->I_INV     相反
*      -->I_NOKEYC  覆盖码颜色
*      -->MT_SCOL   颜色表
*----------------------------------------------------------------------*
FORM FRM_COLOR_CELL USING    I_FNAME  TYPE LVC_FNAME
                             I_COL    TYPE LVC_COL
                             I_INT    TYPE LVC_INT
                             I_INV    TYPE LVC_INV
                             I_NOKEYC TYPE LVC_NOKEYC
                    CHANGING MT_SCOL  TYPE LVC_T_SCOL.
  DATA: LS_SCOL TYPE LVC_S_SCOL.
  LS_SCOL-FNAME     = I_FNAME.
  LS_SCOL-COLOR-COL = I_COL.    "标准色代码 ( 1-7 )
  LS_SCOL-COLOR-INT = I_INT.    "背景颜色 反转颜色启用/关闭 1/0
  LS_SCOL-COLOR-INV = I_INV.    "前景字体 增强颜色启用/关闭 1/0
  LS_SCOL-NOKEYCOL  = I_NOKEYC. "覆盖关键字颜色
  APPEND LS_SCOL TO MT_SCOL.
  CLEAR LS_SCOL.
ENDFORM.                    " FRM_COLOR_CELL
*&---------------------------------------------------------------------*
*&      Form  FRM_CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*       检查数据变化
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_CHECK_CHANGED_DATA .
  DATA: LR_ALV TYPE REF TO CL_GUI_ALV_GRID.
* 获取ALV instance
  PERFORM FRM_GET_ALV_INSTANCE CHANGING LR_ALV.
* 检查数据变化
  IF LR_ALV IS NOT INITIAL.
    CALL METHOD LR_ALV->CHECK_CHANGED_DATA .
  ENDIF.
ENDFORM.                    " FRM_CHECK_CHANGED_DATA
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_FILTERED_ENTRIES
*&---------------------------------------------------------------------*
*       取被筛选的条目
*----------------------------------------------------------------------*
*      <--ET_ENTRIES  text
*----------------------------------------------------------------------*
FORM FRM_GET_FILTERED_ENTRIES  CHANGING ET_ENTRIES TYPE LVC_T_FIDX.
  DATA: LR_ALV TYPE REF TO CL_GUI_ALV_GRID.
* 获取ALV instance
  PERFORM FRM_GET_ALV_INSTANCE CHANGING LR_ALV.
* 获取被筛选的条目
  IF LR_ALV IS NOT INITIAL.
    CALL METHOD LR_ALV->GET_FILTERED_ENTRIES
      IMPORTING
        ET_FILTERED_ENTRIES = ET_ENTRIES.
  ENDIF.
ENDFORM.                    " FRM_GET_FILTERED_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  FRM_GET_SELECTED_CELLS
*&---------------------------------------------------------------------*
*       取选中的单元格
*----------------------------------------------------------------------*
*      <--ET_CELL  text
*----------------------------------------------------------------------*
FORM FRM_GET_SELECTED_CELLS  CHANGING ET_CELL TYPE LVC_T_CELL.
  DATA: LR_ALV TYPE REF TO CL_GUI_ALV_GRID.
* 获取ALV instance
  PERFORM FRM_GET_ALV_INSTANCE CHANGING LR_ALV.
* 获取被筛选的条目
  IF LR_ALV IS NOT INITIAL.
    CALL METHOD LR_ALV->GET_SELECTED_CELLS
      IMPORTING
        ET_CELL = ET_CELL.
  ENDIF.
ENDFORM.                    " FRM_GET_SELECTED_CELLS
*&---------------------------------------------------------------------*
*&      Form  FRM_CHANGED_DATA_TO_TABLE
*&---------------------------------------------------------------------*
*       将修改的值保存到内表
*----------------------------------------------------------------------*
* example:
*  PERFORM FRM_CHANGED_DATA_TO_TABLE USING ER_ACDP->MT_GOOD_CELLS
*                                 CHANGING GT_OUT.
*----------------------------------------------------------------------*
FORM FRM_CHANGED_DATA_TO_TABLE USING IT_MODI TYPE LVC_T_MODI "已修改单元格
                              CHANGING MTAB TYPE INDEX TABLE. "内表
  DATA: LS_MODI TYPE LVC_S_MODI.
  FIELD-SYMBOLS: <FS_LINE>, "行
                 <F_VALUE>.   "选择字段

* 将修改的值保存到内存
  LOOP AT IT_MODI INTO LS_MODI.
    READ TABLE MTAB ASSIGNING <FS_LINE> INDEX LS_MODI-ROW_ID.
    CHECK SY-SUBRC EQ 0.
    ASSIGN COMPONENT LS_MODI-FIELDNAME OF STRUCTURE <FS_LINE> TO <F_VALUE>.
    <F_VALUE> = LS_MODI-VALUE.
  ENDLOOP.
ENDFORM.                    " FRM_CHANGED_DATA_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  FRM_ALV_REFRESH_NO_SCROLL
*&---------------------------------------------------------------------*
*       ALV刷新,滚动条不动
*----------------------------------------------------------------------*
* example:
*  PERFORM FRM_ALV_REFRESH_NO_SCROLL USING LR_ALV.
*----------------------------------------------------------------------*
FORM FRM_ALV_REFRESH_NO_SCROLL
       USING IR_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LS_ROW_NO   TYPE LVC_S_ROID,
        LS_ROW_INFO TYPE LVC_S_ROW,
        LS_COL_INFO TYPE LVC_S_COL.

* 读取滚动条信息
  CALL METHOD IR_ALV->GET_SCROLL_INFO_VIA_ID
    IMPORTING
      ES_ROW_NO   = LS_ROW_NO
      ES_ROW_INFO = LS_ROW_INFO
      ES_COL_INFO = LS_COL_INFO.
* 刷新显示
  CALL METHOD IR_ALV->REFRESH_TABLE_DISPLAY.
* 设置原滚动条物料
  CALL METHOD IR_ALV->SET_SCROLL_INFO_VIA_ID
    EXPORTING
      IS_ROW_NO   = LS_ROW_NO
      IS_ROW_INFO = LS_ROW_INFO
      IS_COL_INFO = LS_COL_INFO.
ENDFORM.                    " FRM_CHANGED_DATA_TO_TABLE
*&---------------------------------------------------------------------*
*&      Form  FRM_ALV_COL_OPTIMIZE
*&---------------------------------------------------------------------*
*       调整到最佳宽度
*----------------------------------------------------------------------*
* example:
*  PERFORM FRM_ALV_COL_OPTIMIZE USING LR_ALV.
*----------------------------------------------------------------------*
FORM FRM_ALV_COL_OPTIMIZE
       USING IR_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA: L_UCOMM TYPE SYUCOMM VALUE '&OPT'.
  CALL METHOD IR_ALV->SET_FUNCTION_CODE
    CHANGING
      C_UCOMM = L_UCOMM.
ENDFORM.                    " FRM_ALV_COL_OPTIMIZE
*&---------------------------------------------------------------------*
*&      Form  FRM_ALV_REFRESH_OPTIMIZE
*&---------------------------------------------------------------------*
*       ALV刷新并调整到最佳宽度
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_ALV_REFRESH_OPTIMIZE .
  DATA: LR_ALV TYPE REF TO CL_GUI_ALV_GRID.
* 获取ALV instance
  PERFORM FRM_GET_ALV_INSTANCE CHANGING LR_ALV.
* 刷新
  PERFORM FRM_ALV_REFRESH_NO_SCROLL USING LR_ALV.
* 调整到最佳宽度
  PERFORM FRM_ALV_COL_OPTIMIZE USING LR_ALV.
ENDFORM.                    " FRM_ALV_REFRESH_OPTIMIZE

*&---------------------------------------------------------------------*
*&      Form  SUB_SEARCH_HELP_ALVDEafult
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SUB_SEARCH_HELP_ALVDEAFULT CHANGING LS_VARIANT TYPE DISVARIANT LV_VARIANT TYPE DISVARIANT-VARIANT.

  LS_VARIANT-REPORT = SY-CPROG.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT = LS_VARIANT
      I_SAVE     = 'A'
    IMPORTING
      ES_VARIANT = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND  = 2.

  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    LV_VARIANT = LS_VARIANT-VARIANT.
  ENDIF.

ENDFORM.                    "SUB_SEARCH_HELP_ALVDEafult
