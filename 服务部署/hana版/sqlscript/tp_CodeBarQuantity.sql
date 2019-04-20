
/****** Object:  UserDefinedTableType dbo.tp_CodeBarQuantity    Script Date: 2018/12/2 15:06:38 ******/
CREATE  TYPE tp_CodeBarQuantity AS TABLE(
	"ItemCode" nvarchar(30) NULL,
	"Quantity" decimal(22, 6) NULL
);


