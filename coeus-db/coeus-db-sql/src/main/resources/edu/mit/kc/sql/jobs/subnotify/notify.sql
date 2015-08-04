set heading off;
set echo off;
var li_ret number;

exec :li_ret := pkg_sub_notifications.fn_sub_end_prior_notification;
exec :li_ret := pkg_sub_notifications.fn_sub_end_after_notification;

spool off;
commit;
exit;