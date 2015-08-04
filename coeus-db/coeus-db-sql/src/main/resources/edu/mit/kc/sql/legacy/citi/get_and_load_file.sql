set heading off;
set echo off;
var li_ret number;
spool /home/coeus/citi/citiout.log
exec :li_ret := fn_populate_pers_training;

select * from osp$citi_error_log;

spool off;
commit;
exit;
