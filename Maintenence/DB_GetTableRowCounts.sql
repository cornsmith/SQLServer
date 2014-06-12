SELECT t.name
	,s.partition_number
	,s.row_count
FROM sys.dm_db_partition_stats AS s
	INNER JOIN sys.tables AS t ON t.[object_id] = s.[object_id]
GROUP BY t.name
	,s.partition_number
	,s.row_count;