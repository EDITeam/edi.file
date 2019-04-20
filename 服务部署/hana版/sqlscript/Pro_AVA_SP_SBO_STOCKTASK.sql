create PROCEDURE AVA_SP_SBO_STOCKTASK(
    in object_type NVARCHAR(20) , 				-- SBO Object Type
    in transaction_type NCHAR(1),					-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
    in num_of_cols_in_key INT,
    in list_of_key_cols_tab_del NVARCHAR(255),
    in list_of_cols_val_tab_del NVARCHAR(255))
LANGUAGE SQLSCRIPT 
SQL SECURITY INVOKER
as 
WM_DocEntry int;
BEGIN
	
	 WM_DocEntry := 0;
	IF :transaction_type = 'A' --只处理单据生成添加
	THEN
		--应收发票
		IF :object_type = '13'
		THEN
			select "U_WM_DocEntry" into WM_DocEntry from OINV where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;

		--销售交货
		IF :object_type = '15'
		THEN
			select "U_WM_DocEntry" into WM_DocEntry from ODLN where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;

		--销售退货
		IF :object_type = '16'
		THEN
			select "U_WM_DocEntry" into WM_DocEntry from ORDN where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;

		--采购收获

		IF :object_type = '20'
		THEN
			select "U_WM_DocEntry" into WM_DocEntry from OPDN where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;

		--采购退货
		IF :object_type = '21'
		THEN
			select "U_WM_DocEntry" into WM_DocEntry from ORPD where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;
		--收获
		IF :object_type = '59'
		THEN
			select "U_WM_DocEntry" into WM_DocEntry from OIGN where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;

		--发货
		IF :object_type = '60'
		THEN
			select "U_WM_DocEntry" into WM_DocEntry from OIGE where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;

		--库存转储
		IF :object_type = '67'
		THEN
			select  "U_WM_DocEntry" into WM_DocEntry from OWTR where "DocEntry" =  :list_of_cols_val_tab_del;
		END IF;

		IF :WM_DocEntry > 0
		THEN
			Update AVA_WM_OSRP set "DocStatus" = 'C',"B1DocEntry" =  :list_of_cols_val_tab_del where "DocEntry" =  :WM_DocEntry;
			Update AVA_WM_SRP1 set "LineStatus" = 'C' where "DocEntry" =  :WM_DocEntry;
		END IF;
	END IF;
END


