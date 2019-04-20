create row table "SBO_LDK_TEST"."AVA_WM_SRP2"( "DocEntry" INTEGER not null,
	 "LineId" INTEGER not null,
	 "Object" NVARCHAR (50) null,
	 "ItemCode" NVARCHAR (50) null,
	 "BarCode" NVARCHAR (50) not null,
	 "BatchNumber" NVARCHAR (50) null,
	 "SerialNumber" NVARCHAR (50) null,
	 "Quantity" DECIMAL (19,6) null,
	 "InDate" Date,
	 "PrdDate" date,
	 "ExpDate" date,
	 "Remarks" NVARCHAR (255) null)
	 