CREATE TABLE "AVA_IF_USERAUTH"(
	"user_id" int NULL,
	"auth_id" varchar(50) NULL,
	"auth_type" nvarchar(50) NULL,
	"auth_token" varchar(50) NOT NULL,
	"auth_expires" bigint NULL,
	"is_active" nchar(10) NULL
)
