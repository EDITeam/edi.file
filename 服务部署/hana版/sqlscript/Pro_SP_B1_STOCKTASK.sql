

CREATE PROCEDURE [dbo].[AVA_SP_B1_STOCKTASK]    --������app���������ص�SAP B1������ӡ�����ʱ����
(@object_type nvarchar(20)               --ҵ�񵥾�����
,@list_of_cols_val_tab_del nvarchar(255) --DocEntry
,@transaction_type nvarchar(1)           --���ݶ������ͣ�������ӡ����µȣ�
,@error  int			    	         -- Result (0 for no error)
,@error_message nvarchar (200)           -- Error string to be displayed
)
AS
BEGIN		
-------------------------------------------------------------------------------
/*
���ƣ��Ӵ洢���̿���-������app���������ص�SAP B1������ӡ�����ʱ����
���ߣ�Vic
���ڣ�2018-8-19
��Ҫ��������SAP B1�ı�׼�洢�����У�SBO_SP_TransactionNotification������SAP����ִ��ʱ�����ô˳���
�߼���������Ϊ��������´������app������ʼ����


--������app���������ص�SAP B1������ӡ�����ʱ����
if @object_type in ('4','17','15','16','13','14','22','20','21','18','112') 
Begin
EXEC AVA_SP_B1_STOCKTASK @object_type,@list_of_cols_val_tab_del,@transaction_type,@error,@error_message
End
*/
--��ʼ**********************************************************************

--112�ݸ壨20�ɹ��ջ���21�ɹ��˻���15���۽�����16�����˻���13Ӧ�շ�Ʊ��14���Ʊ��59����ջ���60��淢�������ת������67���ת����
--22�ɹ����������ת�����󡢿��ת����17���۶���
--������������ӡ�����ʱ
if @object_type ='4' and @transaction_type in('A','U')
Begin
--4001���������� ���벻�����ظ�
	  if exists(select * from OITM T0 INNER JOIN OITM T1 ON T0.U_CodeBar=T1.U_CodeBar 
	            where T0.ItemCode=@list_of_cols_val_tab_del 
			      and T0.ItemCode<>T1.ItemCode
				  and isnull(T0.U_CodeBar,'')<>''
	            )
			 begin
			   select @error=4001
			   select @error_message=N'��ʾ:�ֿ����벻�����ظ�.[����������]��̨'
			   select @error, @error_message
			   return
			 end
--4001���������� ���벻�����ظ�
	  if exists(select * from OITM T0 INNER JOIN OITM T1 ON T0.U_VstoreCodeBar=T1.U_VstoreCodeBar 
	            where T0.ItemCode=@list_of_cols_val_tab_del 
			      and T0.ItemCode<>T1.ItemCode
				  and isnull(T0.U_VstoreCodeBar,'')<>''
	            )
			 begin
			   select @error=4002
			   select @error_message=N'��ʾ:�������벻�����ظ�.[����������]��̨'
			   select @error, @error_message
			   return
			 end
End
--***�ݸ���Ӹ���ʱ***--
--112 �ݸ� ��Ӹ���ʱ
IF @Object_Type='112' and @transaction_type in('A','U')
BEGIN
--67���ת���ݸ� 
   If exists(select * from ODRF U0  where U0.[DocEntry]=@list_of_cols_val_tab_del 
             and U0.[ObjType] ='67' 
		     and U0.DocStatus='O'
			 and U0.U_Sanctified='R'--����������´�״̬
		   )--ֻ����δ��ݸ�
	Begin
--6701���ת���ݸ� �Զ���д�ֶΣ�SrvGpPrcnt����ë���ٷֱ�(��ֵΪ0�������Զ�ͬ�����ɹ�)
	 update U0  set SrvGpPrcnt=0 from ODRF U0  where U0.[DocEntry]=@list_of_cols_val_tab_del 
--6702���ת���ݸ� ���ӱ�ֿ�Ҫһ��
	  if exists(select * from ODRF T0 INNER JOIN DRF1 T1 ON T1.DocEntry=T0.DocEntry 
	            where T0.[DocEntry]=@list_of_cols_val_tab_del 
			      and (T0.Filler<>T1.FromWhsCod or T0.ToWhsCode<>T1.WhsCode )
	            )
			 begin
			   select @error=1126702
			   select @error_message=N'��ʾ:���ӱ�ֿ�Ҫһ��.[���ת����ݸ�]��̨'
			   select @error, @error_message
			   return
			 end
	End
END
--20�ɹ��ջ� ���ʱ
IF @Object_Type='20' and @transaction_type ='A'
BEGIN
--���������ż��ǲݸ���ϸ��Ҫһ�� ������ͻ��벻һ�£��������������������٣��������òݸ壬�������Ϲ��򵥾ݣ�����ɹ�������
--��ע�⣺��������ǲɹ���SAP�����ǻ��ڲݸ���ȫ�����ģ�������㱨�����һ�£�
--��������ǲݸ壬��Ҫ��������㱨���Ҫһ��
  if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM OPDN T0 INNER JOIN PDN1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --ɸѡ������ϣ��������ۻ�ɹ�BOM�����
				   and T0.U_Sanctified='R' --�������״̬=�´�
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from OPDN where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE   U0.draftKey>0--���ڲݸ崴��
			   And  U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��				 
             )
        begin 
           select @error=2090
           select @error_message=N'��ʾ:�������񣨲ݸ���ϸ��Ҫһ��'
		               +ISNULL(
							(SELECT top 1 '�ݰ�:'+isnull(cast(U0.draftKey as  nvarchar),'')
							     +';����:'+U0.ItemCode
							     +';�ƻ�:'+cast(cast(U0.Quantity as int)as nvarchar)
								 +';ʵ��:'+cast(cast(isnull(U1.Quantity,0) as int)as nvarchar)
								 +';���:'+cast(cast(U0.Quantity-isnull(U1.Quantity,0) as int)as nvarchar)
							 FROM       
							  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
							   FROM OPDN T0 INNER JOIN PDN1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				             WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --ɸѡ������ϣ��������ۻ�ɹ�BOM�����
							   and T0.U_Sanctified='R' --�������״̬=�´�
							   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
							   )U0
							 LEFT JOIN 
								(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
								 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
								 Where R0.DocEntry=(select U_WM_DocEntry from OPDN where [DocEntry] =@list_of_cols_val_tab_del) 
								 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
								 )U1
							  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
						WHERE  U0.draftKey>0--���ڲݸ崴��
						   And  U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��	
						 )
							  ,'XXX')
		                         +'.[�ɹ��ջ�]��̨'
           SELECT @error ,@error_message 
           RETURN
        end 
END

--21�ɹ��˻� ���ʱ
IF @Object_Type='21' and @transaction_type ='A'
BEGIN
--���������ż��ǲݸ���ϸ��Ҫһ�� 
  if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM ORPD T0 INNER JOIN RPD1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --ɸѡ������ϣ��������ۻ�ɹ�BOM�����
				     and T0.U_Sanctified='R' --�������״̬=�´�
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from ORPD where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE  U0.draftKey>0--���ڲݸ崴��
			   And U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��				 
             )
        begin 
           select @error=2190
           select @error_message=N'��ʾ:�������񣨲ݸ���ϸ��Ҫһ�� '
		               +ISNULL(
							(SELECT top 1 '�ݰ�:'+isnull(cast(U1."BaseEntry" as nvarchar),'')+';����:'+ISNULL(U0.ItemCode,U1.ItemCode )
							 FROM       
							  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
							   FROM ORPD T0 INNER JOIN RPD1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				               WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --ɸѡ������ϣ��������ۻ�ɹ�BOM�����
							     and T0.U_Sanctified='R' --�������״̬=�´�
							   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
							   )U0
							 LEFT JOIN 
								(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
								 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
								 Where R0.DocEntry=(select U_WM_DocEntry from ORPD where [DocEntry] =@list_of_cols_val_tab_del) 
								 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
								 )U1
							  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
						WHERE  U0.draftKey>0--���ڲݸ崴��
						   And U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��				 
						 )
							  ,'XXX')
		                         +'.[�ɹ��˻�]��̨'
           SELECT @error ,@error_message 
           RETURN
        end 
END
--13Ӧ�շ�Ʊ ���ʱ
IF @Object_Type='13' and @transaction_type ='A'
BEGIN
--���������ż��ǲݸ���ϸ��Ҫһ�� 
  if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --ɸѡ������ϣ��������ۻ�ɹ�BOM�����
				   and T0.U_Sanctified='R' --�������״̬=�´�
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from OINV where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE  U0.draftKey>0--���ڲݸ崴��
			   And U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��				 
             )
        begin 
           select @error=1390
           select @error_message=N'��ʾ:�������񣨲ݸ���ϸ��Ҫһ�� '
		               +ISNULL(
							(SELECT top 1 '�ݰ�:'+isnull(cast(U1."BaseEntry" as nvarchar),'')+';����:'+ISNULL(U0.ItemCode,U1.ItemCode )
							 FROM       
							  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
							   FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				               WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --ɸѡ������ϣ��������ۻ�ɹ�BOM�����
							   and T0.U_Sanctified='R' --�������״̬=�´�
							   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
							   )U0
							 LEFT JOIN 
								(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
								 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
								 Where R0.DocEntry=(select U_WM_DocEntry from OINV where [DocEntry] =@list_of_cols_val_tab_del) 
								 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
								 )U1
							  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
						WHERE  U0.draftKey>0--���ڲݸ崴��
						   And U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��				 
						 )
							  ,'XXX')
		                         +'.[Ӧ�շ�Ʊ]��̨'
           SELECT @error ,@error_message 
           RETURN
        end 
END
--14���Ʊ ���ʱ
IF @Object_Type='14' and @transaction_type ='A'
BEGIN
--���������ż��ǲݸ���ϸ��Ҫһ�� 
    if exists(Select * From        
                  (SELECT T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode,SUM(T1.Quantity) as Quantity 
			       FROM ORIN T0 INNER JOIN RIN1 T1 ON T0.DocEntry=T1.DocEntry INNER JOIN OITM M0 ON T1.ItemCode=M0.ItemCode 
				   WHERE T0.[DocEntry] =@list_of_cols_val_tab_del And M0.InvntItem='Y' --ɸѡ������ϣ��������ۻ�ɹ�BOM�����
				   and T0.U_Sanctified='R' --�������״̬=�´�
				   GROUP BY T0.draftKey,T0.U_WM_DocEntry,T1.ItemCode
				   )U0
			     LEFT JOIN 
					(Select R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode",sum(R1."Quantity") as Quantity
					 From AVA_WM_OSRP R0 LEFT JOIN AVA_WM_SRP1 R1 ON R0.DocEntry=R1.DocEntry
					 Where R0.DocEntry=(select U_WM_DocEntry from ORIN where [DocEntry] =@list_of_cols_val_tab_del) 
					 Group by R0."DocEntry",R0."BaseType",R0."BaseEntry",R1."ItemCode"
					 )U1
                  ON U0.U_WM_DocEntry=U1.DocEntry And U0.ItemCode=U1.ItemCode
			WHERE  U0.draftKey>0--���ڲݸ崴��
			   And U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��				 
             )
        begin 
           select @error=1490
           select @error_message=N'��ʾ:�������񣨲ݸ���ϸ��Ҫһ�� '
		               +ISNULL(
							(SELECT top 1 '�ݰ�:'+isnull(cast(U1."BaseEntry" as nvarchar),'')
							     +';����:'+U0.ItemCode
								 +';�ƻ�:'+cast(cast(U0.Quantity as int)as nvarchar)
								 +';ʵ��:'+cast(cast(U1.Quantity as int)as nvarchar)
								 +';���:'+cast(cast(U0.Quantity-isnull(U1.Quantity,0) as int)as nvarchar)
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
						WHERE  U0.draftKey>0--���ڲݸ崴��
						   And U0.Quantity<>isnull(U1.Quantity,0)--������������������һ��				 
						 )
							  ,'XXX')
		                         +'.[Ӧ�մ���]��̨'
           SELECT @error ,@error_message 
           RETURN
        end 
END

--���� **********************************************************************
END



GO


