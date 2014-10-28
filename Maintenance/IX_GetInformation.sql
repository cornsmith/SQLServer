WITH CTE as (
			SELECT		ic.[index_id] + ic.[object_id] AS [IndexId],t.[name] AS [TableName]
						,i.[name] AS [IndexName],c.[name] as [ColumnName],i.[type_desc]
						,i.[is_primary_key],i.[is_unique]
			FROM  [sys].[indexes] i 
			INNER JOIN [sys].[index_columns] ic 
					ON	i.[index_id]	=	ic.[index_id]
					AND	i.[object_id]	=	ic.[object_id]
			INNER JOIN [sys].[columns] c
					ON	ic.[column_id]	=	c.[column_id]
					AND	i.[object_id]	=	c.[object_id]
			INNER JOIN [sys].[tables] t
					ON	i.[object_id] = t.[object_id]
)
SELECT	c.[TableName],c.[IndexName],c.[type_desc],c.[is_primary_key],c.[is_unique]
		,STUFF( ( SELECT ','+ a.[ColumnName] FROM CTE a WHERE c.[IndexId] = a.[IndexId] FOR XML PATH('')),1 ,1, '') AS [Columns]
FROM	CTE c
GROUP	BY c.[IndexId],c.[TableName],c.[IndexName],c.[type_desc],c.[is_primary_key],c.[is_unique]
ORDER	BY c.[TableName] ASC,c.[is_primary_key] DESC;