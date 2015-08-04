set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
select 'insert development proposal: '|| localtimestamp from dual;
@scripts/insert_eps_proposal.sql
@scripts/update_eps_proposal.sql
select 'Completed development proposal: '|| localtimestamp from dual;
select 'insert budget proposal: '|| localtimestamp from dual;
@scripts/budget.sql
@scripts/subaward_data_management.sql
@scripts/budget_periods.sql
@scripts/budget_modular.sql
@scripts/budget_modular_idc.sql
@scripts/budget_persons.sql
@scripts/budget_details.sql
@scripts/budget_pers_details.sql
@scripts/budget_project_income.sql
@scripts/eps_prop_cost_sharing.sql
@scripts/eps_prop_rates.sql
@scripts/eps_prop_idc.sql
select 'Completed budget : '|| localtimestamp from dual;
/