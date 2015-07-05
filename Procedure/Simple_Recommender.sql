-- ======================================================================
-- Author:		Matthew Yap
-- Description:	Simple query for recommending products using 
--				affinity pair rankings
-- ======================================================================

/*
Affinity (Jaccard similarity) is defined as:
	A(i,j) = sup({i,j}) / (sup({i}) + sup({j}) - sup({i,j}))

The support sup(X) of an itemset X is defined as the proportion of all itemsets in the dataset which contain the itemset
*/

DECLARE @Products BIGINT = 3000
DECLARE @Orders BIGINT = 400000
DECLARE @PdtsPerOrder INT = 10

-- Create and populate dataset
SELECT DISTINCT SalesOrderID
	,ProductID
INTO #SalesOrder
FROM (
	SELECT n % @Orders + 1 AS SalesOrderID
		,ABS(CAST(NEWID() AS binary(6)) % @Products) + 1 AS ProductID
	FROM (
		SELECT TOP (@Orders * @PdtsPerOrder) n = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
		FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2
	) AS Nums
) AS SalesOrders;

-- Create indexes
CREATE INDEX IX_SalesOrder_SalesOrderID ON #SalesOrder (SalesOrderID);
CREATE INDEX IX_SalesOrder_ProductID ON #SalesOrder (ProductID);

-- Count unique itemsets
DECLARE @itemsets INT
SELECT @itemsets = COUNT(DISTINCT SalesOrderID) FROM #SalesOrder;

WITH supij -- sup(i,j)
AS (
	SELECT t1.ProductID
		,t2.ProductID AS RecProductID
		,SUM(1.0) / @itemsets AS sup
	FROM #SalesOrder AS t1
	INNER JOIN #SalesOrder AS t2 ON t1.SalesOrderID = t2.SalesOrderID
	WHERE t1.ProductID <> t2.ProductID
	GROUP BY t1.ProductID
		,t2.ProductID
	)
	,sup -- sup(i) and sup(j)
AS (
	SELECT ProductID
		,SUM(1.0) / @itemsets AS sup
	FROM #SalesOrder
	GROUP BY ProductID
	)
SELECT supij.ProductID
	,supij.RecProductID
	,supij.sup / (supi.sup + supj.sup - supij.sup) AS [Affinity]
	,ROW_NUMBER() OVER(PARTITION BY supij.ProductID ORDER BY supij.sup / (supi.sup + supj.sup - supij.sup) DESC, RecProductID) AS [AffinityRank]
FROM supij
INNER JOIN sup AS supi ON supij.ProductID = supi.ProductID
INNER JOIN sup AS supj ON supij.RecProductID = supj.ProductID;

-- Clean up
DROP TABLE #SalesOrder;