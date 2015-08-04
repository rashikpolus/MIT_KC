
set heading off;
set echo off;
var li_ret number;
spool /home/coeus/coi/notify_coi.log

exec :li_ret := PKG_COI_NOTIFCATIONS.fn_send_notification(1);
exec :li_ret := PKG_COI_NOTIFCATIONS.fn_send_notification(2);
exec :li_ret := PKG_COI_NOTIFCATIONS.fn_send_notification(4);

spool off;
commit;
exit;
