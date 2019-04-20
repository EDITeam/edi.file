
CREATE view "AVA_WM_VIEW_OSRP" as
select "DocEntry","DocType",
case when t0."Quantity" > ifnull(t1."Quantity",0) and ifnull(t1."Quantity",0) > 0 then 'E'
when  ifnull(t1."Quantity",0) = 0 then 'O'
else 'C'
end as "DocStatus"
 from 
(select "DocEntry","DocType",sum("Quantity") as "Quantity" from "AVA_WM_VIEW_STK1"  
group by "DocEntry","DocType") as T0
left join 
(select "BaseEntry","BaseType",Sum("Quantity")as "Quantity" from "AVA_WM_VIEW_SRP1" t1 
group by "BaseEntry","BaseType") as T1
on T0."DocEntry" = t1."BaseEntry" and t0."DocType" = t1."BaseType"


