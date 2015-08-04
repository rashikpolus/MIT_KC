set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
select 'insert Institute proposal: '|| localtimestamp from dual;
@scripts/insert_proposal.sql
@scripts/insert_proposal_admin_details.sql
@scripts/insert_proposal_version_history.sql
@scripts/update_proposal.sql
@scripts/update_proposal_admin_details.sql
select 'Completed Institute proposal : '|| localtimestamp from dual;
/