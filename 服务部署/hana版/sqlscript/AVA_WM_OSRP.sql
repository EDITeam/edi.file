CREATE TABLE "AVA_WM_OSRP"(
	"CompanyName" nvarchar(20) NOT NULL,
	"DocEntry" int NOT NULL,
	"DocNum" int NULL,
	"Period" int NULL,
	"Object" varchar(30) NULL,
	"Transfered" nvarchar(1) NULL,
	"CreateDate" datetime NULL,
	"CreateTime" smallint NULL,
	"UpdateDate" datetime NULL,
	"UpdateTime" smallint NULL,
	"Creator" int NULL,
	"Updator" int NULL,
	"DocStatus" varchar(1) NOT NULL,
	"DocDate" datetime NULL,
	"DocDueDate" datetime NULL,
	"TaxDate" datetime NULL,
	"Ref1" nvarchar(100) NULL,
	"Ref2" nvarchar(200) NULL,
	"Remarks" nvarchar(200) NULL,
	"B1DocEntry" int NULL,
	"BydUUID" nvarchar(36) NULL,
	"CusType" nvarchar(8) NULL,
	"TransType" varchar(1) NULL,
	"BpCode" nvarchar(20) NULL,
	"BpName" nvarchar(100) NULL,
	"BaseType" nvarchar(30) NOT NULL,
	"BaseEntry" int NOT NULL,
	"IsDelete" varchar(1) DEFAULT 'N',
	"CodeBar" nvarchar(255) NULL,
	"CodeBar2" nvarchar(255) NULL,
	"CodeBar3" nvarchar(255) NULL,
	"TargetType" nvarchar(30) NULL
);
CREATE INDEX KAVA_WM_OSRP ON AVA_WM_OSRP("DocEntry");



