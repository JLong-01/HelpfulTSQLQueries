-- Helpful for when full data refreshes are needed and foreign key constraints are in the way of truncating the table.
-- Handle wiht care, as disabling the constraint and doing a refresh with anything that won't conform to the constraint will
-- cause future errors you'll need to clean up.

/* Checking if constraints are trusted and enabled Constraints */
SELECT o.name AS TableName, o2.name AS ForeignTableName, fk.name AS ConstraintName, fk.is_not_trusted, fk.is_disabled
FROM sys.foreign_keys AS fk
    INNER JOIN sys.objects AS o ON fk.parent_object_id = o.object_id
    INNER JOIN sys.objects AS o2 ON fk.referenced_object_id = o2.object_id
WHERE fk.name = 'my_foreign_key_id';

/* Disabling Constraints */
ALTER TABLE MyTableName
NOCHECK CONSTRAINT FK_MyTableName_KeyName;

/* Re-enabling constraints */
-- The additional "WITH CHECK" parameter says to flag it as trusted
ALTER TABLE MyTableName
WITH CHECK
CHECK CONSTRAINT FK_MyTableName_KeyName;