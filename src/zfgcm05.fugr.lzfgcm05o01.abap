*&---------------------------------------------------------------------*
*&  Include           LZFGCM05O01
*&---------------------------------------------------------------------*

 MODULE STATUS_9200 OUTPUT.


   SET PF-STATUS '9200' .
   SET TITLEBAR '9200'.

   IF GO_GRID IS INITIAL.
* 检查并创建ALV实例

     PERFORM FRM_BUILD_FCAT. "Field Catalog Table
     PERFORM FRM_CHECK_CREATE_ALV.
   ELSE.
     PERFORM FRM_REFRESH_OOALV .
   ENDIF.

 ENDMODULE.                    "STATUS_9388 OUTPUT
*----------------------------------------------------------------------*
*  MODULE STATUS_0100 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
 MODULE STATUS_0100 OUTPUT.


   SET PF-STATUS '0100' .
   SET TITLEBAR '0100'.


 ENDMODULE.                    "STATUS_9388 OUTPUT
