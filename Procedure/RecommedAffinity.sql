-- =============================================
-- Author:		Matthew Yap
-- Create date: 2014-12-02
-- Description:	Simple query for recommending products using affinity pair rankings
-- =============================================

/*
Affinity (Jaccard similarity) is defined as:
	A(i,j) = sup({i,j})/(sup({i}) + sup({j}) - sup({i,j}))

The support sup(X) of an itemset X is defined as the proportion of transactions in the data set which contain the itemset

In this implementation, a transaction is a customer, i.e. all products in all orders for a customer is 1 transaction regardless of status of order
*/

-- Create and populate transaction data set
CREATE TABLE #Transactions (
	TransactionID INT NOT NULL
	,ProductID INT NOT NULL
);

INSERT INTO #Transactions
(TransactionID, ProductID)
SELECT DISTINCT O.CustomerID
	,PV.ProductID
FROM dbo.Nop_OrderProductVariant AS OPV
INNER JOIN dbo.Nop_ProductVariant AS PV ON OPV.ProductVariantID = PV.ProductVariantId
INNER JOIN dbo.Nop_Order AS O ON OPV.OrderId = O.OrderID;

CREATE INDEX IX_Transactions_TransactionID ON #Transactions (TransactionID);
CREATE INDEX IX_Transactions_ProductID ON #Transactions (ProductID);

-- Count unique transactions
DECLARE @transactions INT
SELECT @transactions = COUNT(DISTINCT TransactionID) FROM #Transactions;

WITH supij -- sup(i,j)
AS (
	SELECT t1.ProductID
		,t2.ProductID AS RecProductID
		,SUM(1.0) / @transactions AS sup
	FROM #Transactions AS t1
	INNER JOIN #Transactions AS t2 ON t1.TransactionID = t2.TransactionID
	WHERE t1.ProductID <> t2.ProductID
	GROUP BY t1.ProductID
		,t2.ProductID
	)
	,sup -- sup(i) and sup(j)
AS (
	SELECT ProductID
		,SUM(1.0) / @transactions AS sup
	FROM #Transactions
	GROUP BY ProductID
	)
SELECT supij.ProductID
	,supij.RecProductID
	--,P1.Name AS BaseName
	--,P2.Name AS RecName
	,supij.sup / (supi.sup + supj.sup - supij.sup) AS [Affinity]
	,ROW_NUMBER() OVER(PARTITION BY supij.ProductID ORDER BY supij.sup / (supi.sup + supj.sup - supij.sup) DESC, RecProductID) AS [AffinityRank]
FROM supij
INNER JOIN sup AS supi ON supij.ProductID = supi.ProductID
INNER JOIN sup AS supj ON supij.RecProductID = supj.ProductID
--INNER JOIN dbo.Nop_Product AS P1 ON supij.ProductId = P1.ProductId
--INNER JOIN dbo.Nop_Product AS P2 ON supij.RecProductID = P2.ProductId

-- Clean up
DROP TABLE #Transactions;