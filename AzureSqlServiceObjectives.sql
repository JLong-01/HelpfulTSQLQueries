-- This query allows programatically determining the resources of an Azure SQL database.
-- For databases using a dedicated vcore model, it shows the service level
-- For databases using the DTU model, it shows the current DTU level
-- NOTE: it shows the current official state of the database, if it's level is scaling, there's no call-out for that

SELECT
    database_id AS DatabaseId,
    edition AS Edition,
    service_objective AS ServiceObjective,
    elastic_pool_name AS ElasticPoolName
FROM
    sys.database_service_objectives;