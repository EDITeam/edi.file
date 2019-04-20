

CREATE PROCEDURE [dbo].[AVA_SP_B1_STOCKTASK]    --与条码app库存任务相关的SAP B1单据添加、更新时控制
(@object_type nvarchar(20)               --业务单据类型
,@list_of_cols_val_tab_del nvarchar(255) --DocEntry
,@transaction_type nvarchar(1)           --单据动作类型（比如添加、更新等）
,@error  int			    	         -- Result (0 for no error)
,@error_message nvarchar (200)           -- Error string to be displayed
)
AS
BEGIN		
-------------------------------------------------------------------------------
/*
名称：子存储过程控制-与条码app库存任务相关的SAP B1单据添加、更新时控制
作者：Vic
日期：2018-8-19
概要：加载在SAP B1的标准存储过程中（SBO_SP_TransactionNotification），当SAP对象执行时，调用此程序。
逻辑：如果标记为库存任务下达（给条码app），则开始控制


--与条码app库存任务相关的SAP B1单据添加、更新时控制
if @object_type in ('4','17','15','16','13','14','22','20','21','18','112') 
Begin
EXEC AVA_SP_B1_STOCKTASK @object_type,@list_of_cols_val_tab_del,@transaction_type,@error,@error_message
End
*/
--开始**********************************************************************

--112草稿（20采购收货、21采购退货、15销售交货、16销售退货、13应收发票、14贷项发票、59库存收货、60库存发货、库存转储请求、67库存转储）
--22采购订单、库存转储请求、库存转储、17销售订单
--物料主数据添加、更新时
if @object_type ='4' and @transaction_type in('A','U')
Begin
--4001物料主数据 条码不允许重复
	  if exists(select * from OITM T0 INNER JOIN OITM T1 ON T0.U_CodeBar=T1.U_CodeBar 
	            where T0.ItemCode=@list_of_cols_val_tab_del 
			      and T0.ItemCode<>T1.ItemCode
				  and isnull(T0.U_CodeBar,'')<>''
	            )
			 begin
			   select @error=4001
			   select @error_message=N'提示:仓库条码不允许重复.[物料主数据]后台'
			   select @error, @error_message
			   return
			 end
--4001物料主数据 条码不允许重复
	  if exists(select * from OITM T0 INNER JOIN OITM T1 ON T0.U_VstoreCodeBar=T1.U_VstoreCodeBar 
	            where T0.ItemCode=@list_of_cols_val_tab_del 
			      and T0.ItemCode<>T1.ItemCode
				  and isnull(T0.U_VstoreCodeBar,'')<>''
	            )
			 begin
			   select @error=4002
			   select @error_message=N'提示:销售条码不允许重复.[物料主数据]后台'
			   select @error, @error_message
			   return
			 end
End
--***草稿添加更新时***--
--112 草稿 添加更新时
IF @Object_Type='112' and @transaction_type in('A','U')
BEGIN
--67库存转储草稿 
   If exists(select * from ODRF U0  where U0.[DocEntry]=@list_of_cols_val_tab_del 
             and U0.[ObjType] ='67' 
		     and U0.DocStatus='O'
			 and U0.U_Sanctified='R'--库存任务是下达状态
		   )--只考虑未清草稿
	Begin
--6701库存转储草稿 自动返写字段：SrvGpPrcnt服务毛利百分比(赋值为0，否则自动同步不成功)
	 update U0  set SrvGpPrcnt=0 from ODRF U0  where U0.[DocEntry]=@list_of_cols_val_tab_del 
--6702库存转储草稿 主从表仓库要一致
	  if exists(select * from ODRF T0 INNER JOIN DRF1 T1 ON T1.DocEntry=T0.DocEntry 
	            where T0.[DocEntry]=@list_of_cols_val_tab_del 
			      and (T0.Filler<>T1.FromWhsCod or T0.ToWhsCode<>T1.WhsCode )
	            )
			 begin
			   select @error=1126702
			   select @error_message=N'提示:主从表仓库要一致.[库存转储存草稿]后台'
			   select @error, @error_message
			   return
			 end
	End
END
--20采购收货 添加时
IF @Object_Type='20' and @transaction_type ='A'
BEGIN
--与库存任务（优家是草稿明细）要一致 （如果客户想不一致（比如数量比任务数量少），不能用草稿，必须用上工序单据，比如采购订单）
--（注意：如果任务是采购，SAP单据是基于草稿完全创建的，可能与汇报结果不一致）
--如果任务是草稿，则要求任务与汇报结果要一致
  if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM OPDN T0 INNER JOIN PDN1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --筛选库存物料，考虑销售或采购BOM的情况
				   and T0.U_Sanctified='R' --库存任务状态=下达
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from OPDN where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE   U0.draftKey>0--基于草稿创建
			   And  U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致				 
             )
        begin 
           select @error=2090
           select @error_message=N'提示:与库存任务（草稿明细）要一致'
		               +ISNULL(
							(SELECT top 1 '草案:'+isnull(cast(U0.draftKey as  nvarchar),'')
							     +';物料:'+U0.ItemCode
							     +';计划:'+cast(cast(U0.Quantity as int)as nvarchar)
								 +';实际:'+cast(cast(isnull(U1.Quantity,0) as int)as nvarchar)
								 +';差额:'+cast(cast(U0.Quantity-isnull(U1.Quantity,0) as int)as nvarchar)
							 FROM       
							  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
							   FROM OPDN T0 INNER JOIN PDN1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				             WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --筛选库存物料，考虑销售或采购BOM的情况
							   and T0.U_Sanctified='R' --库存任务状态=下达
							   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
							   )U0
							 LEFT JOIN 
								(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
								 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
								 Where R0.DocEntry=(select U_WM_DocEntry from OPDN where [DocEntry] =@list_of_cols_val_tab_del) 
								 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
								 )U1
							  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
						WHERE  U0.draftKey>0--基于草稿创建
						   And  U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致	
						 )
							  ,'XXX')
		                         +'.[采购收货]后台'
           SELECT @error ,@error_message 
           RETURN
        end 
END

--21采购退货 添加时
IF @Object_Type='21' and @transaction_type ='A'
BEGIN
--与库存任务（优家是草稿明细）要一致 
  if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM ORPD T0 INNER JOIN RPD1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --筛选库存物料，考虑销售或采购BOM的情况
				     and T0.U_Sanctified='R' --库存任务状态=下达
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from ORPD where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE  U0.draftKey>0--基于草稿创建
			   And U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致				 
             )
        begin 
           select @error=2190
           select @error_message=N'提示:与库存任务（草稿明细）要一致 '
		               +ISNULL(
							(SELECT top 1 '草案:'+isnull(cast(U1."BaseEntry" as nvarchar),'')+';物料:'+ISNULL(U0.ItemCode,U1.ItemCode )
							 FROM       
							  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
							   FROM ORPD T0 INNER JOIN RPD1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				               WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --筛选库存物料，考虑销售或采购BOM的情况
							     and T0.U_Sanctified='R' --库存任务状态=下达
							   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
							   )U0
							 LEFT JOIN 
								(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
								 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
								 Where R0.DocEntry=(select U_WM_DocEntry from ORPD where [DocEntry] =@list_of_cols_val_tab_del) 
								 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
								 )U1
							  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
						WHERE  U0.draftKey>0--基于草稿创建
						   And U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致				 
						 )
							  ,'XXX')
		                         +'.[采购退货]后台'
           SELECT @error ,@error_message 
           RETURN
        end 
END
--13应收发票 添加时
IF @Object_Type='13' and @transaction_type ='A'
BEGIN
--与库存任务（优家是草稿明细）要一致 
  if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --筛选库存物料，考虑销售或采购BOM的情况
				   and T0.U_Sanctified='R' --库存任务状态=下达
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from OINV where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE  U0.draftKey>0--基于草稿创建
			   And U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致				 
             )
        begin 
           select @error=1390
           select @error_message=N'提示:与库存任务（草稿明细）要一致 '
		               +ISNULL(
							(SELECT top 1 '草案:'+isnull(cast(U1."BaseEntry" as nvarchar),'')+';物料:'+ISNULL(U0.ItemCode,U1.ItemCode )
							 FROM       
							  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
							   FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				               WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --筛选库存物料，考虑销售或采购BOM的情况
							   and T0.U_Sanctified='R' --库存任务状态=下达
							   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
							   )U0
							 LEFT JOIN 
								(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
								 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
								 Where R0.DocEntry=(select U_WM_DocEntry from OINV where [DocEntry] =@list_of_cols_val_tab_del) 
								 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
								 )U1
							  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
						WHERE  U0.draftKey>0--基于草稿创建
						   And U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致				 
						 )
							  ,'XXX')
		                         +'.[应收发票]后台'
           SELECT @error ,@error_message 
           RETURN
        end 
END
--14贷项发票 添加时
IF @Object_Type='14' and @transaction_type ='A'
BEGIN
--与库存任务（优家是草稿明细）要一致 
    if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM ORIN T0 INNER JOIN RIN1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --筛选库存物料，考虑销售或采购BOM的情况
				   and T0.U_Sanctified='R' --库存任务状态=下达
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from ORIN where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE  U0.draftKey>0--基于草稿创建
			   And U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致				 
             )
        begin 
           select @error=1490
           select @error_message=N'提示:与库存任务（草稿明细）要一致 '
		               +ISNULL(
							(SELECT top 1 '草案:'+isnull(cast(U1."BaseEntry" as nvarchar),'')
							     +';物料:'+U0.ItemCode
								 +';计划:'+cast(cast(U0.Quantity as int)as nvarchar)
								 +';实际:'+cast(cast(U1.Quantity as int)as nvarchar)
								 +';差额:'+cast(cast(U0.Quantity-isnull(U1.Quantity,0) as int)as nvarchar)
							 FROM       
							  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
							   FROM ORIN T0 INNER JOIN RIN1 T1 ON T0.DocEntry=T1.DocEntry 
							   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del
							   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
							   )U0
							 LEFT JOIN 
								(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
								 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
								 Where R0.DocEntry=(select U_WM_DocEntry from ORIN where [DocEntry] =@list_of_cols_val_tab_del) 
								 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
								 )U1
							  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
						WHERE  U0.draftKey>0--基于草稿创建
						   And U0.Quantity<>isnull(U1.Quantity,0)--任务数量与结果数量不一致				 
						 )
							  ,'XXX')
		                         +'.[应收贷项]后台'
           SELECT @error ,@error_message 
           RETURN
        end 
END

--结束 **********************************************************************
END



GO


