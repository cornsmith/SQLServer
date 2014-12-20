SELECT CustomerID
	,Hamper, Home, Toys, Travel, Total
FROM (
	SELECT CustomerID
		,Score
		,ScoreTypeName
	FROM Customers.ScoreType AS ST
	INNER JOIN Customers.CustomerScore AS CS
		ON CS.ScoreTypeID = ST.ScoreTypeID
	WHERE CampaignYear = Sales.ufn_CurrentOrderYear()
) AS SourceTable
PIVOT (
	AVG(Score)
	FOR ScoreTypeName IN (Hamper, Home, Toys, Travel, Total)
) AS PivotTable;