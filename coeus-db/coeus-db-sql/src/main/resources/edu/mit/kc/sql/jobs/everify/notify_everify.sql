set heading off;
set echo off;
var li_ret number;
spool /opt/kc/jobs/everify/logs/notify_everify.log

exec :li_ret := kc_e_verify_notif_pkg.fn_gen_e_verify_emails;

spool off;
commit;
exit;
