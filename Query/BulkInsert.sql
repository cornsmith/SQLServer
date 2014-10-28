BULK INSERT 
   [ database_name . [ schema_name ] . | schema_name . ] [ table_name | view_name ] 
      FROM 'data_file' 
     [ WITH 
    ( 
   [ [ , ] BATCHSIZE = batch_size ] 
   [ [ , ] CHECK_CONSTRAINTS ] 
   [ [ , ] CODEPAGE = { 'ACP' | 'OEM' | 'RAW' | 'code_page' } ] 
   [ [ , ] DATAFILETYPE = 
      { 'char' | 'native'| 'widechar' | 'widenative' } ] 
   [ [ , ] FIELDTERMINATOR = 'field_terminator' ] 
   [ [ , ] FIRSTROW = first_row ] 
   [ [ , ] FIRE_TRIGGERS ] 
   [ [ , ] FORMATFILE = 'format_file_path' ] 
   [ [ , ] KEEPIDENTITY ] 
   [ [ , ] KEEPNULLS ] 
   [ [ , ] KILOBYTES_PER_BATCH = kilobytes_per_batch ] 
   [ [ , ] LASTROW = last_row ] 
   [ [ , ] MAXERRORS = max_errors ] 
   [ [ , ] ORDER ( { column [ ASC | DESC ] } [ ,...n ] ) ] 
   [ [ , ] ROWS_PER_BATCH = rows_per_batch ] 
   [ [ , ] ROWTERMINATOR = 'row_terminator' ] 
   [ [ , ] TABLOCK ] 
   [ [ , ] ERRORFILE = 'file_name' ] 
    )] 