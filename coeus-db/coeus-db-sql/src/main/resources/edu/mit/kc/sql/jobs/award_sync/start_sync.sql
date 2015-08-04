Spool logs/sync_error.log;
set feedback off;
set heading off;
set term on;
set serveroutput on;
select 'Started syncing, start time: '|| localtimestamp from dual;
@sync_bo.sql
@initial_setup.sql
@sync_award.sql
@sync_dev_budget.sql
@sync_ip.sql
commit;
@send_notification.sql
select 'Completed syncing, end time: '|| localtimestamp from dual;
Spool Off;
Set define On;
Set feedback On;
exit
/

