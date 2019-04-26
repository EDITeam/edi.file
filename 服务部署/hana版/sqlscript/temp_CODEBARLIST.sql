
CREATE global temporary TABLE  CODEBARLIST (
	"Id" nvarchar(36) not null,
	"CodeBar" nvarchar(600) NULL,
	"BaseLine" int NULL,
	"ItemCode" nvarchar(30) NULL,
	"Quantity" decimal(22, 6) NULL,
	"QtyPlan" decimal(22, 6) NULL,
	"Remark" nvarchar(200) NULL
);