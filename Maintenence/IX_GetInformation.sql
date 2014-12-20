WITH CTE
AS (
	SELECT IC.index_id + IC.object_id AS IndexId
		,T.name AS TableName
		,I.name AS IndexName
		,C.name AS ColumnName
		,I.type_desc
		,I.is_primary_key
		,I.is_unique
		,SCHEMA_NAME(T.schema_id) AS SchemaName
	FROM sys.indexes AS I
	INNER JOIN sys.index_columns AS IC ON I.index_id = IC.index_id
		AND I.object_id = IC.object_id
	INNER JOIN sys.columns AS C ON IC.column_id = C.column_id
		AND I.object_id = C.object_id
	INNER JOIN sys.tables AS T ON I.object_id = T.object_id
	)
SELECT @@SERVERNAME AS ServerName
	,DB_NAME() AS DBName
	,C.SchemaName
	,C.TableName
	,C.IndexName
	,C.type_desc AS IndexType
	,C.is_primary_key AS IsPrimaryKey
	,C.is_unique AS IsUnique
	,STUFF((
			SELECT ',' + a.ColumnName
			FROM CTE a
			WHERE C.IndexId = a.IndexId
			FOR XML PATH('')
			), 1, 1, '') AS Columns
FROM CTE AS C
GROUP BY C.SchemaName
	,C.IndexId
	,C.TableName
	,C.IndexName
	,C.type_desc
	,C.is_primary_key
	,C.is_unique
ORDER BY C.TableName ASC
	,C.is_primary_key DESC;