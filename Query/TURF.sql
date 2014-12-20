-- ==============================
-- Parameters
-- ==============================
DECLARE @iterations INT
SELECT @iterations = 0 -- 0 for all products 


-- ==============================
-- Create temp tables
-- ==============================
CREATE TABLE #Data(
	CustomerID int NOT NULL
	,ProductName varchar(100) NOT NULL
	,Quantity decimal(18,9)	NOT NULL
	,Weights decimal(18,9) NOT NULL
);

CREATE TABLE #SelectedProducts(
	ProductName varchar(100) NOT NULL
	,CustomersAdded int NOT NULL
);

CREATE TABLE #Results(
	V1 int NOT NULL
	,V2 int NOT NULL
	,V3 int NOT NULL
	,V4 int NOT NULL
	,V5 int NOT NULL
	,V6 int NOT NULL
	,V7 int NOT NULL
	,V8 int NOT NULL
	,V9 int NOT NULL
	,V10 int NOT NULL
);


-- ==============================
-- Define the dataset and insert
-- ==============================
INSERT INTO #Data
(CustomerID, ProductName, Quantity, Weights)
SELECT CustomerID
	,CatalogueName + '-' + CAST(ISNULL(PageNumber, 0) AS varchar(4))
	,SUM(OrderQuantity) AS Quantity
	,1
FROM Sales.OrderHampersView
WHERE CampaignYear = 2014
	AND BrandName = 'Chrisco AU'
	--AND CatalogueName IN ('Hamper 2014', 'Home and Living 2014', 'Family Christmas Gifts 2014')
	--AND PageNumber IS NOT NULL
	AND Price > 0
	AND IsCancelled = 0
GROUP BY CustomerID
	,CatalogueName
	,PageNumber;

-- Create indexes
CREATE INDEX IX_Data_ProductName ON #Data (ProductName) INCLUDE (CustomerID, Quantity, Weights)
CREATE INDEX IX_Data_CustomerID ON #Data (CustomerID) INCLUDE (ProductName, Quantity, Weights)
CREATE INDEX IX_SelectedProducts_ProductName ON #SelectedProducts (ProductName)

-- Change iterations to all if 0
IF @iterations = 0
	SELECT @iterations = COUNT(DISTINCT ProductName) FROM #Data;


-- ==============================
-- Perform TURF
-- ==============================
DECLARE @counter INT = 0;
WHILE (@counter <= @iterations)
BEGIN
	-- qryap_Add_Product
	INSERT INTO #SelectedProducts 
	(ProductName, CustomersAdded)
	SELECT TOP 1 NBP.ProductName
		,NBP.CustomersAdded
	FROM (
		-- Next best products
		SELECT ProductName
			,SUM(Weights) AS CustomersAdded
		FROM #Data
		WHERE CustomerID NOT IN (
			-- Selected members
			SELECT CustomerID
			FROM #Data
			INNER JOIN #SelectedProducts ON #Data.ProductName = #SelectedProducts.ProductName
		)
		GROUP BY ProductName
	) AS NBP
	ORDER BY NBP.CustomersAdded DESC
	;

	-- qryap_Add_Results
	INSERT INTO #Results
	(V1,V2,V3,V4,V5,V6,V7,V8,V9,V10)
	SELECT 
		SUM(CASE WHEN Quantity >= 1 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 2 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 3 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 4 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 5 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 6 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 7 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 8 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 9 THEN 1 ELSE 0 END)
		,SUM(CASE WHEN Quantity >= 10 THEN 1 ELSE 0 END)
	FROM (
		-- Selected members
		SELECT CustomerID
			,SUM(Quantity) AS [Quantity]
		FROM #Data
		INNER JOIN #SelectedProducts ON #Data.ProductName = #SelectedProducts.ProductName
		GROUP BY CustomerID
	) AS SM;
	PRINT @counter
	SET @counter = @counter + 1;
END

-- ==============================
-- Results
-- ==============================
SELECT * FROM #SelectedProducts;
SELECT * FROM #Results;
SELECT COUNT(DISTINCT CustomerID) AS TotalCustomers FROM #Data;

-- ==============================
-- Clean Up
-- ==============================
DROP TABLE #Data;
DROP TABLE #SelectedProducts;
DROP TABLE #Results;