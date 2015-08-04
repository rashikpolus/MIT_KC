set heading off;
set echo off;
var li_ret number;

exec :li_ret := pkg_cac_feed.fn_cacapp;

commit;
exit;