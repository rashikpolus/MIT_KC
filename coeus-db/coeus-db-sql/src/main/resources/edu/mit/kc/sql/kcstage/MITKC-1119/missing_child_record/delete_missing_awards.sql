CREATE TABLE REFRESH_AWARD(
AWARD_ID NUMBER(12,0),
MIT_AWARD_NUMBER VARCHAR2(12),
SEQUENCE_NUMBER NUMBER(4,0))  
/
INSERT INTO REFRESH_AWARD(AWARD_ID,MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
select distinct a0.award_id,a0.award_number,a0.sequence_number from award a0 ,(
select t1.award_number,t1.sequence_number from award t1 
left outer join version_history t2 on t1.award_number = t2.seq_owner_version_name_value
and t1.sequence_number = t2.seq_owner_seq_number
where t2.seq_owner_version_name_value is null) a1
where a0.award_number = a1.award_number
and a0.sequence_number >=a1.sequence_number
order by a0.award_number,a0.sequence_number
/
alter table AWARD_AMOUNT_TRANSACTION disable constraint FK_AWARD_AMOUNT_TRANSACTION3
/
alter table PENDING_TRANSACTIONS disable constraint PENDING_TRANSACTIONS_FK
/
alter table TRANSACTION_DETAILS  disable constraint FK_TRANSACTION_DETAILS3
/
declare

cursor c_del is
select award_id,MIT_AWARD_NUMBER as award_number,sequence_number from refresh_award;
r_del c_del%rowtype;

begin
if c_del%isopen then
close c_del;
end if;
open c_del;
loop
fetch c_del into r_del;
exit when c_del%notfound;


delete from AWARD_UNIT_CONTACTS where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_TRANSFERRING_SPONSOR where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_SPONSOR_TERM where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_SPONSOR_CONTACTS where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_EXEMPT_NUMBER where award_special_review_id in(select AWARD_SPECIAL_REVIEW_ID from AWARD_SPECIAL_REVIEW where award_id = r_del.award_id);
delete from AWARD_SPECIAL_REVIEW where award_id = r_del.award_id;
delete from AWARD_SCIENCE_KEYWORD where award_id = r_del.award_id;
delete from AWARD_REPORT_TRACKING where award_report_term_id in(select award_report_terms_id from AWARD_REPORT_TERMS where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_REPORT_NOTIFICATION_SENT where award_report_term_id in(select award_report_terms_id from AWARD_REPORT_TERMS where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_REP_TERMS_RECNT where award_report_terms_id in(select award_report_terms_id from AWARD_REPORT_TERMS where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_REPORT_TERMS where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_PERS_UNIT_CRED_SPLITS where award_person_unit_id in(select AWARD_PERSON_UNIT_ID from AWARD_PERSON_UNITS where award_person_id in(select AWARD_PERSON_ID from AWARD_PERSONS where award_number = r_del.award_number and sequence_number = r_del.sequence_number));
delete from AWARD_PERSON_UNITS where award_person_id in(select AWARD_PERSON_ID from AWARD_PERSONS where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_PERSON_CREDIT_SPLITS where award_person_id in(select AWARD_PERSON_ID from AWARD_PERSONS where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_PERSON_CONFIRM where award_person_id in(select AWARD_PERSON_ID from AWARD_PERSONS where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_PERSON_REMOVE where award_person_id in(select AWARD_PERSON_ID from AWARD_PERSONS where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_PERSONS where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_PAYMENT_SCHEDULE where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_NOTEPAD where award_id = r_del.award_id;
delete from AWARD_IDC_RATE where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_FUNDING_PROPOSALS where award_id = r_del.award_id;
delete from AWARD_CUSTOM_DATA where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_COST_SHARE where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_COMMENT where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_CLOSEOUT where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_ATTACHMENT where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_APPROVED_SUBAWARDS where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_APPROVED_FOREIGN_TRAVEL where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_APPROVED_EQUIPMENT where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from AWARD_AMT_FNA_DISTRIBUTION where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from TIME_AND_MONEY_DOCUMENT where award_number = r_del.award_number and document_number in(select tnm_document_number from transaction_details where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_AMOUNT_TRANSACTION where award_number = r_del.award_number and transaction_id in(select tnm_document_number from transaction_details where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from AWARD_AMOUNT_INFO where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from PENDING_TRANSACTIONS where source_award_number = r_del.award_number and document_number in(select tnm_document_number from transaction_details where award_number = r_del.award_number and sequence_number = r_del.sequence_number);
delete from TRANSACTION_DETAILS where award_number = r_del.award_number and sequence_number = r_del.sequence_number;
delete from VERSION_HISTORY where seq_owner_version_name_value = r_del.award_number and seq_owner_seq_number = r_del.sequence_number;

end loop;
close c_del;
end;
/
delete from AWARD_AMOUNT_TRANSACTION where transaction_id not in (select document_number from TIME_AND_MONEY_DOCUMENT)
/
alter table AWARD_AMOUNT_TRANSACTION enable constraint FK_AWARD_AMOUNT_TRANSACTION3
/
delete from PENDING_TRANSACTIONS where document_number not in (select document_number from TIME_AND_MONEY_DOCUMENT)
/
alter table PENDING_TRANSACTIONS enable constraint PENDING_TRANSACTIONS_FK
/
alter table TRANSACTION_DETAILS  enable constraint FK_TRANSACTION_DETAILS3
/
update REFRESH_AWARD
set MIT_AWARD_NUMBER=replace(MIT_AWARD_NUMBER,'-00','-')
/
commit
/