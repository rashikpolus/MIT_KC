set heading off;
set echo off;
var li_ret number;

exec :li_ret := fn_refresh_award_hold_message;

commit;
exit;
