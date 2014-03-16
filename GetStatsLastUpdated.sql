select OBJECT_NAME(s.object_id ) object
   ,s.name
   ,STATS_DATE(s.object_id ,s.stats_id) StatsDate
   ,s.auto_created
   ,s.filter_definition
   ,s.has_filter
   ,s.no_recompute
   ,s.user_created
   ,stuff((select ','+col.name  
   from sys.stats_columns sc
   join sys.columns col on sc.column_id = col.column_id
                       and sc.object_id = col.object_id
   where sc.stats_id = s.stats_id
      and sc.object_id = s.object_id
   for xml path ('')),1,1,'') cols
from sys.stats s 
inner join sys.tables t
on s.object_id = t.object_id
where  t.type = 'U'