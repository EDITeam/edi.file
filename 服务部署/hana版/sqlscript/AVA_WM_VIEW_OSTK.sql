
/*
名称：视图-AVA_WM_VIEW_OSTK
作者：AVA产品部
日期：2018-8-15
逻辑：手机app中展示库存任务。
注意1：优家中，采购入库任务不允许展示供应商名称和采购单价。
        ,'上海优家供应商' as BpName, --T1."CardName" "BpName",--优家要求不显示供应商名称
注意2：优家中，销售订单的下工序单据是应收发票，所以，视图中直接赋值是13（"TargetType"），如果下工序是销售交货，应改为15。
注意3：库存任务与库存汇报要求是一对一
--------------------------------------
Vic 2018-9-5：草稿中新增总数量
*/
CREATE VIEW "AVA_WM_VIEW_OSTK"
AS
SELECT * ,'' "SchCode" FROM
(

/*-------------------------采购订单---------------------------------*/
         SELECT N'SHYJ' as "CompanyName" --注意：命名影响与SAP的同步单据的接口
		  ,T0."DocEntry" "ObjectKey", 'R' "TransType",
                N'采购订单(收货)' "Annotated",
                T0."ObjType" "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as "BpName", --T1."CardName" "BpName",--优家要求不显示供应商名称
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" as "DocStatus",'20' "TargetType",T0."U_ReporterId" "ReporterId"
         FROM "OPOR" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		  inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and T0."ObjType" = T2."DocType"
         WHERE  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'') = 'R'
         UNION ALL
/*-------------------------库存转储申请---------------------------------*/
         SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'T' "TransType" ,
                N'库存转储申请（转储）' "Annotated",
                T0."ObjType" "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as  "BpName",
                T0."DocDate",T0."DocDueDate",T0."CreateDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",'67' "TargetType",T0."U_ReporterId"
         FROM "OWTQ" T0
		   inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and T0."ObjType" = T2."DocType"
         WHERE  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
         UNION ALL
/*-------------------------销售订单---------------------------------*/
         SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'I' "TransType",
                N'销售订单(发货)' "Annotated",
                T0."ObjType" "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as "BpName",
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",'13' "TargetType",T0."U_ReporterId"
         FROM "ORDR" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
			    inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and T0."ObjType" = T2."DocType"
         WHERE  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified",'') = 'R'
         UNION ALL
/*-------------------------销售退货（草稿）---------------------------------*/
         SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'R' "TransType",
                 N'销售退货草稿(收货)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as "BpName",
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
			inner join AVA_WM_VIEW_OSRP T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
         WHERE T0."ObjType" = '16' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'  				
		 UNION ALL
/*-------------------------应收发票（草稿）---------------------------------*/
         SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'R' "TransType",
                 N'应收发票草稿(交货)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as "BpName",
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		    inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
         WHERE T0."ObjType" = '13' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
/*-------------------------库存收货（草稿）---------------------------------*/
 union all
 SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'R' "TransType",
                 N'库存收货草稿(收货)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                IFNULL(T0."CardCode",'') "BpCode"
				,T0."CardName"
				as "BpName",
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		   inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
         WHERE T0."ObjType" = '59' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
/*-------------------------库存发货（草稿）---------------------------------*/
 union all
 SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'R' "TransType",
                 N'库存发货草稿(发货)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                IFNULL(T0."CardCode",'') "BpCode"
				,T0."CardName"
				as "BpName",
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		   inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
         WHERE T0."ObjType" = '60' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
/*-------------------------销售交货（草稿）---------------------------------*/
UNION ALL
        SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'I' "TransType",
                 N'销售交货草稿(发货)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as "BpName",
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		   inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
         WHERE T0."ObjType" = '15' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
/*-------------------------采购收货（草稿）---------------------------------*/
UNION ALL
        SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'R' "TransType",
                 N'采购收货草稿(收货)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as BpName, --T1."CardName" "BpName",--优家要求不显示供应商名称
				T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		   inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
		 WHERE T0."ObjType" = '20' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
/*-------------------------采购退货（草稿）---------------------------------*/
 union all
 SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'R' "TransType",
                 N'采购退货草稿(发货)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as BpName, --T1."CardName" "BpName",--优家要求不显示供应商名称
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		    inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
         WHERE T0."ObjType" = '21' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
/*-------------------------库存转储（草稿）---------------------------------*/
 union all
 SELECT N'SHYJ' as "CompanyName" , T0."DocEntry" "ObjectKey",'R' "TransType",
                 N'库存转储草稿(转储)' "Annotated",
                concat('112-' ,T0."ObjType") "DocType",T0."DocEntry" "DocEntry",
                T0."CardCode" "BpCode"
				,T0."CardName"
				as "BpName",
                T0."DocDate" "DocDate",T0."DocDueDate" "DocDueDate",T0."TaxDate" "TaxDate",
                CAST(T0."Comments" as NTEXT) "Remarks",T0."Ref1",T0."Ref2",T2."DocStatus" "DocStatus",T0."ObjType" "TargetType",T0."U_ReporterId"
         FROM "ODRF" T0 LEFT JOIN "OCRD" T1 ON T0."CardCode" = T1."CardCode"
		   inner join ava_wm_view_osrp T2 on T0."DocEntry" = T2."DocEntry" and  concat('112-' ,T0."ObjType") = T2."DocType"
         WHERE T0."ObjType" = '67' AND  T0."DocStatus"='O' AND IFNULL(T0."U_Sanctified", '') = 'R'
) T0



