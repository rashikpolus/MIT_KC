set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
select 'insert bo: '|| localtimestamp from dual;
@scripts/insert_bo.sql
select 'Completed bo : '|| localtimestamp from dual;
/