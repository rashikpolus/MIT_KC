select * from TEMP_TAB_TO_SYNC_AWARD where mit_award_number='018061-001'

select * from osp$sap_feed_details@coeus.kuali where mit_award_number='022969-001' and sequence_number=7

select document_number,lead_unit_number from AWARD where award_number='022969-00001' and sequence_number=7

select * from krew_doc_hdr_t where doc_hdr_id='618246'

select * from version_history where seq_owner_version_name_field='awardNumber' and seq_owner_version_name_value='022969-00001'

select * from sync_award_log where feed_id='688319'

select * from award_persons where award_number='000310-00001' and sequence_number=3 and person_id='900028768'

select * from award_persons where award_number='022002-00001' and sequence_number=12 and person_id='900057398'

select * from unit where unit_number='402000'

select * from award where lead_unit_number is null

select award_number,sequence_number,person_id from award_persons
      where person_id is not null
      group by  award_number,sequence_number,person_id,contact_role_code  HAVING count(award_number) > 1
      
select award_number,sequence_number,rolodex_id from award_persons
      where rolodex_id is not null
      group by  award_number,sequence_number,rolodex_id,contact_role_code  HAVING count(award_number) > 1
      
update award set lead_unit_number='402000' where award_number='022969-00001' and sequence_number=7

SELECT UNIT_NUMBER FROM AWARD_PERSON_UNITS
    WHERE LEAD_UNIT_FLAG='Y' AND AWARD_NUMBER='022969-00001'
          AND SEQUENCE_NUMBER=7;