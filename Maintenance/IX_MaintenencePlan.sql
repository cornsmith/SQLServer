DECLARE @MaxFragmentation TINYINT = 30
	--,@MinimumPages SMALLINT = 1000
	,@SQL NVARCHAR(max)
	,@ObjectName NVARCHAR(300)
	,@IndexName NVARCHAR(300)
	,@CurrentFragmentation DECIMAL(9, 6)
DECLARE @FragmentationState TABLE (
	SchemaName SYSNAME
	,TableName SYSNAME
	,object_id INT
	,IndexName SYSNAME
	,index_id INT
	,page_count BIGINT
	,avg_fragmentation_in_percent FLOAT
	,avg_page_space_used_in_percent FLOAT
	,type_desc VARCHAR(255)
	)

/* Collect Fragmentation Data */
INSERT INTO @FragmentationState
SELECT s.NAME AS SchemaName
	,t.NAME AS TableName
	,t.object_id
	,i.NAME AS IndexName
	,i.index_id
	,x.page_count
	,x.avg_fragmentation_in_percent
	,x.avg_page_space_used_in_percent
	,i.type_desc
FROM sys.dm_db_index_physical_stats(db_id(), NULL, NULL, NULL, 'SAMPLED') x
INNER JOIN sys.tables t ON x.object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.indexes i ON x.object_id = i.object_id
	AND x.index_id = i.index_id
WHERE x.index_id > 0
	AND alloc_unit_type_desc = 'IN_ROW_DATA'

/* Identify Fragmented Indexes */
DECLARE INDEX_CURSE CURSOR LOCAL FAST_FORWARD
FOR
SELECT QUOTENAME(x.SchemaName) + '.' + QUOTENAME(x.TableName)
	,CASE WHEN x.type_desc = 'CLUSTERED' THEN 'ALL' ELSE QUOTENAME(x.IndexName) END
	,x.avg_fragmentation_in_percent
FROM @FragmentationState x
LEFT OUTER JOIN @FragmentationState y ON x.object_id = y.object_id
	AND y.index_id = 1
WHERE (
		x.type_desc = 'CLUSTERED'
		AND y.type_desc = 'CLUSTERED'
		)
	OR y.index_id IS NULL
ORDER BY x.object_id
	,x.index_id

OPEN INDEX_CURSE

WHILE 1 = 1
BEGIN
	FETCH NEXT
	FROM INDEX_CURSE
	INTO @ObjectName
		,@IndexName
		,@CurrentFragmentation

	IF @@FETCH_STATUS <> 0
		BREAK

	SELECT @SQL = 'ALTER INDEX ' + @IndexName + ' ON ' + @ObjectName + CASE WHEN @CurrentFragmentation <= @MaxFragmentation THEN ' REORGANIZE;' ELSE ' REBUILD' + ';' END
	--PRINT @SQL
	EXEC sp_ExecuteSQL @SQL
END

CLOSE INDEX_CURSE
DEALLOCATE INDEX_CURSE