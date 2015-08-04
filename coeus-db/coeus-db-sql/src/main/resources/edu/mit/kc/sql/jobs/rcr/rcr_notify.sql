set heading off;
set echo off;
var li_ret number;

exec :li_ret := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(1);
exec :li_ret := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(2);
exec :li_ret := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(3);
exec :li_ret := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(4);
exec :li_ret := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(5);

commit;
exit;