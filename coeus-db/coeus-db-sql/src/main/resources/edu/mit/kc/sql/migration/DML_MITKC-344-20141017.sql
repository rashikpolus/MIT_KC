UPDATE award_report_tracking t1
SET t1.preparer_name = ( select t2.prncpl_nm from krim_prncpl_t t2 where t2.prncpl_id = t1.preparer_id)
where exists ( select t3.prncpl_nm from krim_prncpl_t t3 where t3.prncpl_id = t1.preparer_id )
/
