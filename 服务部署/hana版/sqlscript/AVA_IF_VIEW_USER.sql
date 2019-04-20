
CREATE VIEW "AVA_IF_VIEW_USER"
AS
SELECT  "USERID" AS "id", "U_MobileUserId" AS "user_name", "PASSWORD", 
        ifnull("U_IME",'N') AS "is_mobile_user", "U_MobilePassword" AS "mobile_password",
        1 "companyId",ifnull("U_Is_Supper",'N') as "is_supper"
FROM    "OUSR" AS t0 where t0."U_IME" = 'Y'
