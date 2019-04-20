alter PROCEDURE "AVA_SP_BATCH_PARSE_CODEBAR"(
in codebarlist  tp_codebarlist , --条码对象集合参数  xml/json格式
in BaseType varchar(20) ,
in BaseEntry int ,
out code nvarchar(8) ,
out message nvarchar(200) )
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
as


begin
code := 0;
message := 'OK';
-------------------------------------------------------------------------------------------------------------- ---------------
	--select code = '0',message = 'OK' from dummy;
	--SELECT @code as Code,@message as Message
	--set @code = '-100020' set @message = N'meesage'
	--set @code = '0' set @message = N'ok'
--------------------------------------------
/*
说明：一个汇报允许多次汇报，所以批量扫描结果匹配时，要考虑已经保存的结果。
注意：存在销售BOM的情况
*/
--------------------------------------------

/*
--测试：
 @codebars tp_codebarlist
	insert into @codebars(CodeBar,BaseLine,ItemCode,Quantity)
	values('046-F|8|8|100',-1,'046-F',50)
	insert into @codebars(CodeBar,BaseLine,ItemCode,Quantity)
	values('046-F|8|8|100',-1,'046-F',10)
	insert into @codebars(CodeBar,BaseLine,ItemCode,Quantity)
	values('054|8|8|100',-1,'054',80)
	insert into @codebars(CodeBar,BaseLine,ItemCode,Quantity)
	values('064|8|8|100',-1,'064',160)
exec  [dbo].[AVA_SP_BATCH_PARSE_CODEBAR] @codebars,'112-20',4033,'',''

declare @codebars tp_codebarlist
	insert into @codebars(CodeBar,BaseLine,ItemCode,Quantity)
	values('056',-1,'056',8)
exec  [dbo].[AVA_SP_BATCH_PARSE_CODEBAR] @codebars,'112-20',4062,'',''
*/

--------------------------------------------------------------------------------------
end



