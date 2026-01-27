/* By table */

USE FordNA;

SELECT a.index_id, 
    NAME,
    index_type_desc,
    avg_fragmentation_in_percent, 
    fragment_count, 
    avg_fragment_size_in_pages 
FROM sys.Dm_db_index_physical_stats(Db_id('FordNA'), Object_id('CEIM_MotorcraftInventory'), NULL, NULL, NULL) AS a 
    INNER JOIN sys.indexes b ON a.object_id = b.object_id AND a.index_id = b.index_id 