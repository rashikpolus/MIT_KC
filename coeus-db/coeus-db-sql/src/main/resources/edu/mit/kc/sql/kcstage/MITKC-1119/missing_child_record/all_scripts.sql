set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
select 'started deleting awards: '|| localtimestamp from dual;
@delete_missing_awards.sql
select 'completed deleting_patch: '|| localtimestamp from dual;
select 'started award_sync_patch: '|| localtimestamp from dual;
@scripts/award_amount_transaction.sql
@scripts/award_attachment.sql
@scripts/award_closeout.sql
@scripts/award_comment.sql
@scripts/award_cost_share.sql
@scripts/award_custom_data.sql
@scripts/award_equipment.sql
@scripts/award_foriegn_trip.sql
@scripts/award_funding_proposal.sql
@scripts/award_key_persons.sql
@scripts/award_notepad.sql
@scripts/award_payment_schedule.sql
@scripts/award_persons.sql
@scripts/award_person_unit.sql
@scripts/award_per_credit_split.sql
@scripts/award_pers_unit_cred_split.sql
@scripts/award_payment_schedule.sql
@scripts/award_report_terms.sql
@scripts/award_report_tracking.sql
@scripts/award_science_code.sql
@scripts/award_special_review.sql
@scripts/award_special_review_update.sql
@scripts/award_sponsor_contact.sql
@scripts/award_sponsor_term.sql
@scripts/award_transferring_sponsor.sql
@scripts/award_unit_contacts.sql
@scripts/award_version_history.sql
@scripts/award_number_updation.sql
select 'Completed award_sync_patch : '|| localtimestamp from dual;
/