SELECT OBJECT_NAME(s.OBJECT_ID) as objectname
,i.name as indexname
,i.index_id
,user_seeks+user_scans+user_lookups as reads
,user_updates as writes
,p.rows
FROM sys.dm_db_index_usage_stats s join sys.indexes i
ON i.index_id = s.index_id and s.OBJECT_ID = i.OBJECT_ID
join sys.partitions p on p.index_id = s.index_id and s.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY (s.OBJECT_ID, 'IsUserTable') = 1
AND s.database_id = DB_ID()
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
AND p.ROWS > 10000
ORDER BY reads, rows desc