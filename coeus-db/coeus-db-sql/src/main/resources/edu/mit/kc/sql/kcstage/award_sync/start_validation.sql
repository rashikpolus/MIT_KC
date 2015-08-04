Spool logs/validation_error.log;
set feedback off;
set heading off;
set term on;
set serveroutput on;
select 'Started Validation, start time: '|| localtimestamp from dual;
@award_sync_validation.sql
@institute_proposal_sync_validation.sql
@dev_proposal_sync_validation.sql
@budget_sync_validation.sql
select 'Completed Validation, end time: '|| localtimestamp from dual;
Spool Off;
Set define On;
Set feedback On;