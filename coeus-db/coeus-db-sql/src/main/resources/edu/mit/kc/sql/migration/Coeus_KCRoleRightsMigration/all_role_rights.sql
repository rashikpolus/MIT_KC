Spool logs/error.log;
set feedback off;
set heading off;
set term on;
set serveroutput on;
select 'Started role right migration.'|| localtimestamp from dual;
@scripts/ddl_role_rights.sql
select 'ddl_role_rights.sql started '|| localtimestamp from dual;
@scripts/kc_coeus_role_mapping.sql
select 'kc_coeus_role_mapping started '|| localtimestamp from dual;
@scripts/kc_coeus_right_mapping.sql
select 'kc_coeus_right_mapping started '|| localtimestamp from dual;
@scripts/role_bootstrap.sql
select 'role_bootstrap.sql started '|| localtimestamp from dual;
@scripts/perm_bootstrap.sql
select 'perm_bootstrap.sql started '|| localtimestamp from dual;
@scripts/role_perm_bootstrap.sql
select 'role_perm_bootstrap.sql started '|| localtimestamp from dual;
@scripts/truncate_and_apply_bootstrap.sql
select 'truncate_and_apply_bootstrap.sql started '|| localtimestamp from dual;
@scripts/kc_coeus_role_perm_mapping.sql
select 'kc_coeus_role_perm_mapping.sql started '|| localtimestamp from dual;
commit;
@scripts/syncing_role_rights.sql
select 'syncing_role_rights.sql started '|| localtimestamp from dual;
@scripts/load_coeus_user_roles.sql
select 'load_coeus_user_roles.sql started '|| localtimestamp from dual;
@scripts/add_role_perm_manually.sql
select 'add_role_perm_manually.sql started '|| localtimestamp from dual;
@scripts/document_access_irb.sql
select 'document_access_irb.sql started '|| localtimestamp from dual;
@scripts/document_access_eps.sql
select 'ddl_role_rights.sql started '|| localtimestamp from dual;
@scripts/document_access_iacuc.sql
select 'ddl_role_rights.sql started '|| localtimestamp from dual;
commit;
select 'completed role right migration.'|| localtimestamp from dual;
Spool Off;
Set define On;
Set feedback On;
EXIT
/