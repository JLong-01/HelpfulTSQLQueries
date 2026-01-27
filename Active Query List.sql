--Connect to a db engine, select a DB, then run this query to see all queries running

USE MyDB;

SELECT
    r.session_id,
	r.percent_complete,
    st.text AS batch_text,
    qp.query_plan AS 'XML Plan',
    r.start_time,
    r.status,
    r.total_elapsed_time,
    r.cpu_time,
    DB_NAME(r.database_id) AS database_name
FROM
    sys.dm_exec_requests AS r
CROSS APPLY
    sys.dm_exec_sql_text(r.sql_handle) AS st
CROSS APPLY
    sys.dm_exec_query_plan(r.plan_handle) AS qp
--WHERE
--    r.status = 'running'
ORDER BY
    r.total_elapsed_time DESC;

