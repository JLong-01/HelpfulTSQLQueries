/* Progress checks for what indexes are still disabled, when disabling indexes to do a large data refresh and then re-enabling them. */
	
-- without metrics, no deadlocks
SELECT
    i.name AS IndexName, i.index_id, i.type_desc, 
	o.name AS TableName
FROM sys.indexes AS i
    inner join sys.objects AS o on o.object_id = i.object_id
WHERE i.is_disabled = 1
ORDER BY
    o.name,
    i.name
	
-- with metrics, gets deadlocked
SELECT
    i.name AS IndexName, i.index_id, i.type_desc, 
    o.name AS TableName, 
    IXUS.*
FROM sys.indexes AS i
    inner join sys.objects AS o on o.object_id = i.object_id
    LEFT JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.[index_id] = i.index_id AND IXUS.[OBJECT_ID] = o.[object_id]
WHERE i.is_disabled = 1
ORDER BY
    o.name,
    i.name