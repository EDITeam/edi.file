

create FUNCTION "AVA_SP_SpitString"
( 
string nvarchar(2000),--被分的字符串 
sp nvarchar(100) --分隔符 
) 
RETURNS 
 TABLE 
( 
id int, 
string nvarchar(2000),
inx int,
str1 nvarchar(2000) 
) 
AS 
BEGIN 
/*
declare @count int --计数 
set @count=0 
declare @index int 
declare @one nvarchar(2000)--取下来的一节 
set @index=Charindex(@sp,@string) 
while(@index>0) 
begin 
set @one=left(@string,@index-1) 
set @count=@count+1
insert into @_strings (id,string,inx,str1) values(@count,@one,@index,@string) 
set @string=right(@string,len(@string)-@index) 
set @index=Charindex(@sp,@string) 
end 
insert into @_strings (id,string,inx,str1) values(@count+1,@string,@index,@one) 
RETURN 
*/
RETURN 
	select 1 as id,'abc' as string,2 as inx,'sdss' as str1 from dummy;
END;



