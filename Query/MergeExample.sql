MERGE Sales.Hamper AS TGT
USING (
	SELECT HamperID
		,BestCostIncGst AS BestCost
	FROM ImportSTG.Stocklist.Hamper
	) AS SRC
	ON TGT.HamperID = SRC.HamperID
WHEN MATCHED
	AND (
		TGT.BestCostStocklist <> SRC.BestCost
		OR TGT.BestCostStocklist IS NULL
		)
	THEN
		UPDATE
		SET TGT.BestCostStocklist = SRC.BestCost;