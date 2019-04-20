
CREATE view "AVA_WM_VIEW_SRP1" as 
select t0."BaseEntry","BaseLine",t0."BaseType",sum("Quantity") as "Quantity" from "AVA_WM_OSRP" t0 inner join AVA_WM_SRP1 t1 
on t0."DocEntry" = t1."DocEntry"
 where "IsDelete" = 'N'
group by t0."BaseEntry","BaseLine",t0."BaseType"


