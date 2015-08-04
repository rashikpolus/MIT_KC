delete from AWARD_PERSON_UNITS where award_person_id in 
  (select award_person_id from award_persons where award_number='022457-00001' and sequence_number > 4);
  
delete from AWARD_PERSONS where award_number='022457-00001' and sequence_number > 4;

delete from AWARD_REP_TERMS_RECNT where award_report_terms_id in 
    (select AWARD_REPORT_TERMS_ID from AWARD_REPORT_TERMS where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_REPORT_TERMS where award_number='022457-00001' and sequence_number > 4;

delete from AWARD_SPECIAL_REVIEW where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_BUDGET_LIMIT where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_ATTACHMENT where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_COMMENT where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_CLOSEOUT where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_CUSTOM_DATA where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_FUNDING_PROPOSALS where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from AWARD_IDC_RATE where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from award_key_pers_removed where award_id in 
      (select award_id from award where award_number='022457-00001' and sequence_number > 4);

delete from award where award_number='022457-00001' and sequence_number > 4;

delete from version_history where SEQ_OWNER_VERSION_NAME_VALUE='022457-00001' and seq_owner_seq_number > 4;

update version_history set version_status='ACTIVE' where SEQ_OWNER_VERSION_NAME_VALUE='022457-00001' and seq_owner_seq_number =4;

update award set award_sequence_status = 'ACTIVE' where award_number='022457-00001' and sequence_number = 4;

select document_number from award where award_number='022457-00001' and sequence_number = 4;
