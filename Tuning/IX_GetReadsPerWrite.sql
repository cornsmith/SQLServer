SELECT OBJECT_NAME(s.OBJECT_ID) AS objectname
	,i.NAME AS indexname
	,i.index_id
	,user_seeks + user_scans + user_lookups AS reads
	,user_updates AS writes
	,(user_seeks + user_scans + user_lookups) / ISNULL(NULLIF(user_updates, 0), 1) AS reads_per_write
	,p.rows
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i ON i.index_id = s.index_id
	AND s.OBJECT_ID = i.OBJECT_ID
JOIN sys.partitions p ON p.index_id = s.index_id
	AND s.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY(s.OBJECT_ID, 'IsUserTable') = 1
	AND s.database_id = DB_ID()
	AND i.type_desc = 'nonclustered'
	AND i.is_primary_key = 0
	AND i.is_unique_constraint = 0
	AND p.ROWS > 10000
ORDER BY reads
	,rows DESC
