-- ���㱨��׼���ƴ洢����
-- ע�⣺���ؽ����code��message���ֶ����Ʊ���Ϊ "errorCode"�� "message"������ǰ�ζ�ȡ��Ϣ��ʧ��
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
--�����㱨����Ӹ���ʱ
/*
IF :object_type = 'AVA_WM_STOCKREPORT' and (:transaction_type = N'A' or :transaction_type = N'U')
Then
 --10003Լ�������㱨��Ӹ���ʱ���Զ�����ҵ��������(��������ҵ��ҵ���������а������ѻ㱨����)
   
END if;
*/
----------------------------------------------------------------------------------------------------

select :errorCode as "errorCode" ,:message as "message" from dummy;
end ;





