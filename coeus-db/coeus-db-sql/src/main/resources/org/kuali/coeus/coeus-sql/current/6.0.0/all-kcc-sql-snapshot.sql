set define off 
/
select 'running kcc dml snapshot' from dual
/
@mit_kc_patch_snapshot.sql
commit
/
EXIT
/
