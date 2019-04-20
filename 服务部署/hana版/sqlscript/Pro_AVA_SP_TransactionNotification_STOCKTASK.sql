-- 库存汇报标准控制存储过程
-- 注意：返回结果的code和message的字段名称必须为 "errorCode"和 "message"；否则前段读取信息会失败
create PROCEDURE "AVA_SP_TransactionNotification_STOCKTASK" (
in object_type nvarchar(30), 				-- SBO Object Type
in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete
in num_of_cols_in_key int,
in list_of_key_cols_tab_del nvarchar(255),
in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
 errorCode  int;			-- Result (0 for no error)
 message nvarchar (200);		-- Error string to be displayed
 sbo_count int;
begin

-- Return values
 errorCode := 0;
 message  := N'Ok';

 sbo_count := 0;

--------------------------------------------------------------------------------------------------------------------------------
--	ADD	YOUR	CODE	HERE
--《库存汇报》添加更新时
/*
IF :object_type = 'AVA_WM_STOCKREPORT' and (:transaction_type = N'A' or :transaction_type = N'U')
Then
 --10003约束：库存汇报添加更新时，自动更新业务伙伴名称(库存任务的业务业务伙伴名称中包含：已汇报数量)
   
END if;
*/
----------------------------------------------------------------------------------------------------

select :errorCode as "errorCode" ,:message as "message" from dummy;
end ;





