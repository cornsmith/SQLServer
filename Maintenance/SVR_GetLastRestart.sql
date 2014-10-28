-- Note the tempdb system database is recreated every time the server restarts
-- Thus this is one method to tell when the database server was last restarted
SELECT  @@Servername AS ServerName ,
        create_date AS ServerStarted ,
        DATEDIFF(s, create_date, GETDATE()) / 86400.0 AS DaysRunning ,
        DATEDIFF(s, create_date, GETDATE()) AS SecondsRunnig
FROM    sys.databases
WHERE   name = 'tempdb';