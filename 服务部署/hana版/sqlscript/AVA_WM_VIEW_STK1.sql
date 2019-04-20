/*
名称：视图-AVA_WM_VIEW_STK1
作者：AVA产品部
日期：2018-8-15
逻辑：手机app中展示库存任务。
注意1：优家中，采购入库任务不允许展示供应商名称和采购单价。
*/

CREATE VIEW "AVA_WM_VIEW_STK1"
AS
SELECT T0.* FROM
(

/*-------------------------销售退货（草稿）---------------------------------*/
       
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
              concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
               T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '16'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and concat('112-' , T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE  T1."LineStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
/*-------------------------应收发票（草稿）---------------------------------*/
          UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
               concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode"
			  ,T2."ItemName"  --上海优家新增
			  ,T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '13'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  concat('112-', T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE  T1."LineStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0 and T2."InvntItem"='Y' --筛选库存物料，比如销售BOM的情况
/*-------------------------库存收货（草稿）---------------------------------*/
          UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
               concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '59'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  concat('112-', T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
/*-------------------------库存发货（草稿）---------------------------------*/
          UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
               concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			    case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '60'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  concat('112-', T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
/*-------------------------销售交货（草稿）---------------------------------*/
          UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'I' AS "TransType",
               concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0)  "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '15'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  concat('112-', T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
/*-------------------------采购收货（草稿）---------------------------------*/
          UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
               concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName"  --上海优家新增
			  ,T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '20'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  concat('112-', T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
/*-------------------------采购收货（草稿）---------------------------------*/
				 UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
               concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '21'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  concat('112-', T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
/*-------------------------库存转储（草稿）---------------------------------*/
				 UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
               concat('112-', T0."ObjType") AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ODRF" T0 INNER JOIN "DRF1" T1 ON T0."DocEntry" = T1."DocEntry" AND T0."ObjType" = '67'
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  concat('112-', T0."ObjType") = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
) T0 left join OITM T1 on T0."ItemCode"=T1."ItemCode"
union all
/*-------------------------采购订单---------------------------------*/
         
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'R' AS "TransType",
              T0."ObjType" AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
              T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              null "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			 case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "OPOR" T0 INNER JOIN "POR1" T1 ON T0."DocEntry" = T1."DocEntry"
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  T0."ObjType" = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE  T1."LineStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0

/*-------------------------库存转储申请---------------------------------*/
          UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'T' AS "TransType",
              T0."ObjType" AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
               T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0)  "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				    when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				    else 'C' end as "LineStatus"
          FROM "OWTQ" T0 INNER JOIN "WTQ1" T1 ON T0."DocEntry" = T1."DocEntry"
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  T0."ObjType" = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE T1."LineStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0
/*-------------------------销售订单---------------------------------*/
          UNION ALL
          SELECT T0."DocEntry" "ObjectKey",T1."LineNum" "LineId",'I' AS "TransType",
              T0."ObjType" AS "DocType",T0."DocEntry" AS "DocEntry",T1."LineNum" AS "DocLine",
              T1."BaseType" "BaseType",T1."BaseEntry" "BaseEntry",T1."BaseLine" "BaseLine",
              NULL "BSType",NULL "BSEntry",NULL "BSLine",
              T1."ItemCode",T2."ItemName",T2."ManBtchNum",T2."ManSerNum",T2."InvntryUom",'1' "ScanType",
               T1."Price" "Price",T1."Currency" "Currency",0.0 "Rate",0.0 "LineTotal",
              T1."FromWhsCod" "FromWH",null "FromLC",T1."WhsCode" "ToWH",null "ToLC",
              NULL AS "Ref1",NULL AS "Ref2",
              IFNULL(T1."Quantity",0) "Quantity",IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) "OpenQuantity",
			   case when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) = IFNULL(T1."Quantity",0) then 'O'
				  when IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) < IFNULL(T1."Quantity",0) and
				  IFNULL(T1."Quantity",0) - IFNULL(T3."Quantity",0) > 0 then 'E'
				  else 'C' end as "LineStatus"
          FROM "ORDR" T0 INNER JOIN "RDR1" T1 ON T0."DocEntry" = T1."DocEntry"
                INNER JOIN "OITM" T2 ON T1."ItemCode" = T2."ItemCode"
				left join AVA_WM_VIEW_SRP1 t3 on T1."DocEntry" = T3."BaseEntry" and  T0."ObjType" = t3."BaseType" and t1."LineNum" = t3."BaseLine"
          WHERE T1."LineStatus"='O' AND IFNULL(T0."U_Sanctified",'R') = 'R' 
                 AND IFNULL(T1."Quantity",0) > 0





