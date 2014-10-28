EXEC sp_helpserver;

--OR
EXEC sp_linkedservers;

--OR
SELECT @@SERVERNAME AS SERVER
	,Server_Id AS LinkedServerID
	,NAME AS LinkedServer
	,Product
	,Provider
	,Data_Source
	,Modify_Date
FROM sys.servers
ORDER BY NAME;