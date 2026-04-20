/*
This is to create a linkage so that users with a specific Entra role can login to an Azure SQL database.  This should be executeed in the context of the database.  

The general intended purpose when writing this was for existing Entra entities (system identities as well as users in specific groups) should be able to access SQL databases by being granted roles via PIM or some similar methodology.
*/

USE DatabaseName;

CREATE USER [Reading-Role] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [Reading-Role];

CREATE USER [Writing-Role] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [Writing-Role];
ALTER ROLE db_datawriter ADD MEMBER [Writing-Role];
