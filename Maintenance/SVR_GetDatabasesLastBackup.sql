SELECT @@Servername AS ServerName
	,d.NAME AS DBName
	,MAX(b.backup_finish_date) AS LastBackupCompleted
FROM sys.databases d
LEFT OUTER JOIN msdb..backupset b ON b.database_name = d.NAME
	AND b.[type] = 'D'
GROUP BY d.NAME
ORDER BY d.NAME;