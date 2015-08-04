/*
Script to refresh WH schema in KC database.
This script will be executed as a cron job from osp-award.mit.edu server
*/
 
 
--Refresh WHOSP_AWARD
 
var li_ret number;
exec :li_ret := fn_load_wh_osp_award;
 
commit;
exit;