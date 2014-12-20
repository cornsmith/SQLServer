EXEC sp_tables;-- Note this method returns both table and views.

--OR
SELECT @@Servername AS ServerName
	,TABLE_CATALOG
	,TABLE_SCHEMA
	,TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

--OR
SELECT @@Servername AS ServerName
	,DB_NAME() AS DBName
	,o.NAME AS 'TableName'
	,o.[Type]
	,o.create_date
FROM sys.objects o
WHERE o.Type = 'U' -- User table
ORDER BY o.NAME;

--OR
SELECT @@Servername AS ServerName
	,DB_NAME() AS DBName
	,t.NAME AS TableName
	,t.[Type]
	,t.create_date
FROM sys.tables t
ORDER BY t.NAME;
GO


