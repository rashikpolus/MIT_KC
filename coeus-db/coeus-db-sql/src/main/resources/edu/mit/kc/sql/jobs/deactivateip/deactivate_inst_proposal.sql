declare
ls_run_date varchar2(10);
li_return pls_integer;
begin
ls_run_date := fn_kc_deactivate_inst_prop;
li_return := fn_send_deactivated_ip_list(ls_run_date);
end;
/
exit
/
