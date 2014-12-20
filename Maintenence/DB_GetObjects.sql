-- In this example U is for tables.
-- Try swapping in one of the many other types.
SELECT *
FROM sys.objects
WHERE type = 'D';

/*
U = Table (user-defined)
V = View
AF = Aggregate function (CLR)
P = SQL Stored Procedure
TA = Assembly (CLR) DML trigger
C = CHECK constraint
PC = Assembly (CLR) stored-procedure
TF = SQL table-valued-function
D = DEFAULT (constraint or stand-alone)
PG = Plan guide
TR = SQL DML trigger
F = FOREIGN KEY constraint
PK = PRIMARY KEY constraint
TT = Table type
FN = SQL scalar function
R = Rule (old-style, stand-alone)
FS = Assembly (CLR) scalar-function
RF = Replication-filter-procedure
UQ = UNIQUE constraint
FT = Assembly (CLR) table-valued function
S = System base table
IF = SQL inline table-valued function
SN = Synonym
X = Extended stored procedure
IT = Internal table
SQ = Service queue
*/