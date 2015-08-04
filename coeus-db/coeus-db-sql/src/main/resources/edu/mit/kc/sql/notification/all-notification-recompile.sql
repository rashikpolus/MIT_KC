set define off;
select 'generic package' from dual;
@kc_mail_generic_pkg.sql

select 'CAC' from dual;
@cac/kc_cac_feed_pkg.sql

select 'CITI' from dual;
@citi/kc_package_citi.sql

select 'everify' from dual;
@everify/kc_e_verify_notif_pkg.sql

select 'kp_notification' from dual;
@kp_notification/kc_kp_notifications_pkg.sql
@kp_notification/t_kp_confirm_aft_insert_row.sql

select 'longsurvey' from dual;
@longsurvey/kc_long_survey_notif_pkg.sql
@longsurvey/t_negot_aft_update_row.sql
@longsurvey/t_long_survey_aft_update_row.sql

select 'nda' from dual;
@nda/fn_gen_nda_survey_compl_notif.sql
@nda/t_nda_survey_aft_update_row.sql

select 'rcr' from dual;
@rcr/fn_load_rcr_data_from_wh.sql
@rcr/kc_rcr_notifcations_pkg.sql
@rcr/t_per_train_aft_insert_row.sql
@rcr/t_per_train_aft_update_row.sql

select 'subaward' from dual;
@subaward/kc_sub_notifications_pkg.sql
@subaward/t_awd_appr_sub_bfr_in_row.sql
/
