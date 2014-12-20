EXEC sp_helpdb;

--OR
EXEC sp_Databases;

--OR
SELECT @@SERVERNAME AS SERVER
	,NAME AS DBName
	,recovery_model_Desc AS RecoveryModel
	,Compatibility_level AS CompatiblityLevel
	,create_date
	,state_desc
FROM sys.databases
ORDER BY NAME;

--OR
SELECT @@SERVERNAME AS SERVER
	,d.NAME AS DBName
	,create_date
	,compatibility_level
	,m.physical_name AS FileName
FROM sys.databases d
JOIN sys.master_files m ON d.database_id = m.database_id
WHERE m.[type] = 0 -- data files only
ORDER BY d.NAME;