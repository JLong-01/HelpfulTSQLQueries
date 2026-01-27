-- This query looks at all of the indexes in the current database and provides usage as well as fragmentation statistics to help
-- with maintenance operations of the database.

-- NOTE: on databases with large tables this query can take quite some time to run, and it can be a bit of a resource hog, so
-- it's recommended not to run during peak hours until you have a feel for resource demand on your environment.

-- Lots of good stuff can be found at https://www.sqlshack.com/gathering-sql-server-indexes-statistics-and-usage-information/



/* Show SQL server restart time, this is when the index usage counts reset */
SELECT sqlserver_start_time FROM sys.dm_os_sys_info;


/* Select the database and start preparing the index analysis report */
USE MyDatabase;

SELECT  
	'ALTER INDEX' as 'QS1'
	,'[' + dbindexes.[name] + ']' as 'Index'
	,'ON' as 'QS2'
	,'[' + dbtables.[name] + ']' as 'Table'
	,CASE 
		WHEN indexstats.avg_fragmentation_in_percent > 30
			THEN 'REBUILD WITH (FILLFACTOR = 85, ONLINE = ON)' 
		WHEN indexstats.avg_fragmentation_in_percent > 5 
			THEN 'REORGANIZE'
		ELSE ''
		END as 'QS3'
	,indexstats.avg_fragmentation_in_percent
	,indexstats.page_count
	,indexstats.index_type_desc
	,indexstats.alloc_unit_type_desc
	,dbindexes.fill_factor
	,dbindexes.is_disabled
	,dbschemas.[name] as 'Schema'
	--,SUM(PS.[used_page_count]) * 8 IndexSizeKB
	,IXUS.user_seeks AS NumOfSeeks
	,IXUS.user_scans AS NumOfScans
	,IXUS.user_lookups AS NumOfLookups
	,IXUS.user_updates AS NumOfUpdates
	,IXUS.user_seeks + IXUS.user_scans + IXUS.user_lookups AS SumAllReads
	,IXUS.last_user_seek AS LastSeek
	,IXUS.last_user_scan AS LastScan
	,IXUS.last_user_lookup AS LastLookup
	,IXUS.last_user_update AS LastUpdate
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
	INNER JOIN sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
	INNER JOIN sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
	INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id] AND indexstats.index_id = dbindexes.index_id
	LEFT JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.[index_id] = indexstats.index_id AND IXUS.[OBJECT_ID] = dbtables.[object_id]
	--INNER JOIN sys.dm_db_partition_stats PS on PS.[object_id] = dbtables.[object_id]
WHERE indexstats.database_id = DB_ID()
	--AND indexstats.avg_fragmentation_in_percent > 5
	AND indexstats.index_type_desc <> 'HEAP'
	AND indexstats.alloc_unit_type_desc <> 'LOB_DATA'
ORDER BY indexstats.avg_fragmentation_in_percent desc
