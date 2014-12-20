SELECT *
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
  'Excel 12.0 Xml; HDR=YES; IMEX=1;
   Database=C:\DataFiles\EmployeeData1.xlsx',
   [vEmployee$]);