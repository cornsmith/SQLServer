-- =============================================
-- Author:		Matthew Yap
-- Create date: 20131014
-- Description:	Perform action on all indexes on DB
-- =============================================
CREATE PROCEDURE [dbo].[usp_IDX_Action_All]
	@schema varchar(20) = "dbo",
	@action varchar(20) = "REBUILD"
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql AS VARCHAR(MAX) = '';

	SELECT @sql = @sql + 'ALTER INDEX ' + I.[name] + ' ON  ' + @schema + '.' + O.[name] + ' ' + @action + ';' + CHAR(13) + CHAR(10)
	FROM sys.indexes AS I
	INNER JOIN sys.objects AS O ON I.object_id = O.object_id
	WHERE I.type_desc = 'NONCLUSTERED'
		AND O.type_desc = 'USER_TABLE';

	EXEC(@sql);
END
