set heading off;
set echo off;
var li_ret number;

exec :li_ret := fn_load_rcr_data_from_wh;

commit;

spool off;
exit;
