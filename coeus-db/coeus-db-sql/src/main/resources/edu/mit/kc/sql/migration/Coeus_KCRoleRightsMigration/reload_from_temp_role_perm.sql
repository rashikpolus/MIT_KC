Spool logs/errorFromReload.log;
set feedback off;
set heading off;
set term on;
set serveroutput on;
@scripts/truncate_and_apply_bootstrap.sql
commit;
@scripts/syncing_role_rights.sql
@scripts/load_coeus_user_roles.sql
@scripts/add_role_perm_manually.sql
@scripts/document_access_irb.sql
@scripts/document_access_eps.sql
@scripts/document_access_iacuc.sql
commit;
Spool Off;
Set define On;
Set feedback On;