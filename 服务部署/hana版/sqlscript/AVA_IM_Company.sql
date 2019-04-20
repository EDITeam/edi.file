CREATE TABLE "AVA_IF_COMPANY"(
	"companyId" int NOT NULL,
	"parentId" int NULL,
	"companyName" nvarchar(50) NOT NULL,
	"shortName" varchar(50) NULL
 );
CREATE INDEX PK_Company ON AVA_IF_COMPANY("companyId")