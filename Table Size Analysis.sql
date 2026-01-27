-- Run this query on a database to see a list of all tables, along with their disk space usage details.  This is helpful for cases where
-- pages are heavily fragmented, resulting in effectively wasted space.  This query also checks if the table is stored in a clustered index
-- or as a heap, and provides a command to rebuild the table accordingly.

-- NOTE: this query can take some time to run on large tables and causes locks, so it is recommended not to run during peak hours.

SET NOCOUNT ON;

-- Create a temporary table to store the results
CREATE TABLE #SpaceUsedResults (
    name NVARCHAR(128),
    rows BIGINT,
    reserved VARCHAR(50),
    data VARCHAR(50),
    index_size VARCHAR(50),
    unused VARCHAR(50),
    unusedNumeric INT,
    tableType VARCHAR(9),
    consolidationQuery VARCHAR(1000)
);

-- Declare a cursor to iterate through all user tables
DECLARE @TableName NVARCHAR(128);
DECLARE table_cursor CURSOR FOR
SELECT name
FROM sys.tables
WHERE is_ms_shipped = 0; -- Exclude system tables

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @TableName;

-- Loop through each table and execute sp_spaceused, inserting results into the temp table
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #SpaceUsedResults (name, rows, reserved, data, index_size, unused)
    EXEC sp_spaceused @TableName;

    -- Check if table is clustered or heap:
    DECLARE 
        @NumClusteredIndexes INT = (
            SELECT COUNT(*) 
            FROM sys.objects o 
            JOIN sys.partitions p ON p.object_id = o.object_id
            WHERE
                o.is_ms_shipped = 0 AND o.type = 'U' AND o.name = @TableName AND p.index_id = 1 -- index_id 0 is heap, index_id 1 is clustered, index_id > 1 is non-clustered
        ),
        @ClusteredIndexName VARCHAR(255) = (
            SELECT i.name
            FROM sys.tables AS t
            JOIN sys.indexes AS i ON t.object_id = i.object_id
            WHERE i.type = 1 AND t.name = @TableName
        );

    UPDATE #SpaceUsedResults 
        SET tableType = CASE WHEN @NumClusteredIndexes = 1 THEN 'Clustered' WHEN @NumClusteredIndexes = 0 THEN 'Heap' WHEN @NumClusteredIndexes > 1 THEN 'ERROR' END 
        WHERE [name] = @TableName;
    UPDATE #SpaceUsedResults
        SET consolidationQuery = (CASE
            WHEN @NumClusteredIndexes = 1 THEN CONCAT('ALTER INDEX ', @ClusteredIndexName, ' ON ', @TableName, ' REBUILD  WITH (ONLINE = ON);')
            WHEN @NumClusteredIndexes = 0 THEN CONCAT('ALTER TABLE ', @TableName, ' REBUILD;')
        END)
        WHERE [name] = @TableName;

    FETCH NEXT FROM table_cursor INTO @TableName;
END;

CLOSE table_cursor;
DEALLOCATE table_cursor;

UPDATE #SpaceUsedResults SET unusedNumeric = LEFT(unused, LEN(unused)-2)

-- Select all data from the temporary table
SELECT *
FROM #SpaceUsedResults
ORDER BY unusedNumeric DESC;

-- Drop the temporary table
DROP TABLE #SpaceUsedResults;
