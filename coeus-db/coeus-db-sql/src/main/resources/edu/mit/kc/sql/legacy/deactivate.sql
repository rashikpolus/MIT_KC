set heading off;
set echo off;
var ls_ret varchar2(10);
spool /home/coeus/deactivateip/deactivate.log
set lin 200;


exec :ls_ret := fn_deactivate_inst_prop;

select 'Deactivate script run on ' || :ls_ret  from dual;


select 'List of Proposals Deactivated ' from dual;
select  PROPOSAL_NUMBER || ' - ' ||  TITLE
from temp_deactivated_ip;

spool off;
commit;
exit;