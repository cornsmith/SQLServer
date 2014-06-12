WITH IndexSchema
AS (
	SELECT i.object_id
		,i.index_id
		,i.NAME
		,(
			SELECT CASE key_ordinal WHEN 0 THEN NULL ELSE QUOTENAME(column_id, '(') END
			FROM sys.index_columns ic
			WHERE ic.object_id = i.object_id
				AND ic.index_id = i.index_id
			ORDER BY key_ordinal
				,column_id
			FOR XML PATH('')
			) AS index_columns_keys
	FROM sys.tables t
	INNER JOIN sys.indexes i ON t.object_id = i.object_id
	WHERE i.type_desc IN (
			'CLUSTERED'
			,'NONCLUSTERED'
			,'HEAP'
			)
	)
SELECT QUOTENAME(DB_NAME()) AS database_name
	,QUOTENAME(OBJECT_SCHEMA_NAME(is1.object_id)) + '.' + QUOTENAME(OBJECT_NAME(is1.object_id)) AS object_name
	,STUFF((
			SELECT ', ' + c.NAME
			FROM sys.index_columns ic
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			WHERE ic.object_id = is1.object_id
				AND ic.index_id = is1.index_id
			ORDER BY ic.key_ordinal
				,ic.column_id
			FOR XML PATH('')
			), 1, 2, '') AS index_columns
	,STUFF((
			SELECT ', ' + c.NAME
			FROM sys.index_columns ic
			INNER JOIN sys.columns c ON ic.object_id = c.object_id
				AND ic.column_id = c.column_id
			WHERE ic.object_id = is1.object_id
				AND ic.index_id = is1.index_id
				AND ic.is_included_column = 1
			ORDER BY ic.column_id
			FOR XML PATH('')
			), 1, 2, '') AS included_columns
	,is1.NAME AS index_name
	,is2.NAME AS duplicate_index_name
FROM IndexSchema is1
INNER JOIN IndexSchema is2 ON is1.object_id = is2.object_id
	AND is1.index_id > is2.index_id
	AND (
		is1.index_columns_keys LIKE is2.index_columns_keys + '%'
		AND is2.index_columns_keys LIKE is2.index_columns_keys + '%'
		)
GROUP BY is1.object_id
	,is1.NAME
	,is2.NAME
	,is1.index_id