
	 
	 
/****** Object:  UserDefinedTableType dbo.tp_CodeBarResult    Script Date: 2018/12/2 15:07:05 ******/
CREATE TYPE tp_CodeBarResult AS TABLE(
	"BaseLine" int NOT NULL,
	"ItemCode" nvarchar(50) NOT NULL,
	"Quantity" decimal(22, 6) NOT NULL,
	"CodeBar" nvarchar(600) NOT NULL,
	"Price" decimal(22, 6) NULL,
	"BatchNum" nvarchar(30) NULL,
	"SerialNum" nvarchar(30) NULL,
 "InDate" Date,
 "PrdDate" date,
 "ExpDate" date,
	"Remarks" nvarchar(255) NULL
);
