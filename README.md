# HelpfulTSQLQueries
Transact-SQL (MS SQL) queries to aid in administering databases and general maintenance operations.

## Synopsis
These are queries that I use in my own database administration and I wanted to share for other people to utilize, draw ideas from, as well as possibly pass along recommendations for updates in my own maintenance operations.

The three primarily used queries are:
- Active Query List.sql
- Index Analysis - By Database.sql
- Table Size Analysis.sql

As these are intended for maintenance, it is highly recommended not to test in production environments.  Many of them are resource hogs, so running them during off-hours is also advised.

## The Main Queries

### Active Query List.sql
Get a list of all the queries currently executing, along with the PIDs needed for deadlocked queries that need to be killed or for killing long-running queries causing performance issues.

### Index Analysis - By Database.sql
Prepares a report of all indexes on a database, big data points including:
- A query for rebuilding the index (including fill-factor if need be), or re-organizing it, depending on the fragmentation percentage.
- The fragmentation percentage
- The number of pages dedicated to storing the index
- Read/Write usage on each index
- Other helpful things
Note that this can take a while to run on large tables, so please use caution when running in production or during high usage hours.

### Table Size Analysis.sql
Loops through all tables in a database and generates a report on each table's storage optimization, big data points including:
- Table name
- Row count
- KB of storage reserved for table data
- KB of storage reserved for index data
- KB of storage page files effectively unused (also includes fill-factor space, so if your tables utilize fill-factor, keep in mind that this will create some unused space)
- A query based on analyzing if the table is stored in a cluster or heap, showing how to rebuild the table to cleanup excess unused space (NOTE: this can be a resource intensive operation, test with caution).

## Secondary Queries

### AzureSqlServiceObjectives.sql
For the current Azure database, output the service tier (for DTUs or vCore model), helpful for when automation is needed to change DTU levels or something like that based on other stimuli.  For instance, a self-service utility where a developer can submit a request for DTUs to be increased in a dev or QA environment, and the hypothetical application can display the current DTU level along with the requested level.

### ForeignKey Control.sql
A query used when doing bulk data reloads on tables with foreign key constraints that would normally object to truncate commands.  This disables those constraints, lets you truncate the table and reload data, and then re-enable the constraints after.  This should be used with caution as if the table doesn't conform to the constraints, re-enabling the constraints will fail.

### Index Analysis - By Table.sql
A lighter version of the "By Database" derivative.  Included here for archival purposes, although generally if I need a report on a single table I'll run the full database report but change the line:

`FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats`

to

`FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('MyTableName'), NULL, NULL, NULL) AS indexstats`

so that the query only runs on the one table.

### Index Analysis - Rebuild Progress.sql
Helpful when you're reloading a large table, disabled all of the indexes on the table, have a rebuild running on all of the indexes, and need to see how many of the indexes are still disabled.

NOTE: There's two derivatives in this set.
- One that is intended for initial analysis and looks at usage stat metrics, which means it would get blocked by active rebuilds on a given table
- One that does not look at usage metrics so it can be run even while rebuilds are underway