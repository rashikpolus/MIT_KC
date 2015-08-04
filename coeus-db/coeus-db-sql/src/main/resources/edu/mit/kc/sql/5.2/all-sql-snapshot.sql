select 'running ddl snapshot' from dual
/
@all-ddl-snapshot.sql
/
select 'running dml snapshot' from dual
/
@all-dml-snapshot.sql
/
commit
/
EXIT;