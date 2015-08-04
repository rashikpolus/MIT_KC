create index TRANSACTION_DETAILS_IDX on 
TRANSACTION_DETAILS(tnm_document_number)
/

create index AWARD_AMOUNT_TRANSACTION_IDX on 
AWARD_AMOUNT_TRANSACTION(TRANSACTION_ID)
/

create index BUDGET_PER_DET_RB_IDX on 
BUDGET_PER_DET_RATE_AND_BASE(BUDGET_PERSONNEL_DETAILS_ID)
/

create index BUDGET_PERS_CAL_AMTS_IDX on 
BUDGET_PERSONNEL_CAL_AMTS(BUDGET_PERSONNEL_DETAILS_ID)
/

create index BUDGET_RATE_AND_BASE_IDX on 
BUDGET_RATE_AND_BASE(BUDGET_DETAILS_ID)
/

CREATE INDEX BUDGET_DETAILS_CAL_AMTS_IDX
   ON BUDGET_DETAILS_CAL_AMTS (BUDGET_DETAILS_ID)
/

CREATE INDEX PROTOCOL_PERSONS_IDX
   ON PROTOCOL_PERSONS (PROTOCOL_ID)
/

CREATE INDEX BUDGET_PER_DETAILS_IDX
   ON BUDGET_PERSONNEL_DETAILS (BUDGET_DETAILS_ID)
/

CREATE INDEX AWARD_AMOUNT_INFO_IDX
   ON AWARD_AMOUNT_INFO (TNM_DOCUMENT_NUMBER)
/

CREATE INDEX AWARD_SPONSOR_CONTACTS_IDX
   ON AWARD_SPONSOR_CONTACTS (AWARD_ID)
/

CREATE INDEX PROTOCOL_SUBMISSION_IDX
   ON PROTOCOL_SUBMISSION (PROTOCOL_ID)
/

CREATE INDEX PROTOCOL_ACTIONS_IDX
   ON PROTOCOL_ACTIONS (PROTOCOL_ID)
/

CREATE INDEX COMM_SCHEDULE_MINUTES_IDX
   ON COMM_SCHEDULE_MINUTES (SUBMISSION_ID_FK)
/

CREATE INDEX PROTO_CORRESP_IDX
   ON PROTOCOL_CORRESPONDENCE (ACTION_ID_FK)
/

CREATE INDEX PROTO_AMEND_RENEWAL_IDX
   ON PROTO_AMEND_RENEWAL (PROTOCOL_ID)
/

CREATE INDEX PROTOCOL_SUBMISSION_IDX1
   ON PROTOCOL_SUBMISSION (SCHEDULE_ID_FK)
/

CREATE INDEX PROTOCOL_PERSONS_IDX1
   ON PROTOCOL_PERSONS (PROTOCOL_ID,PROTOCOL_PERSON_ROLE_ID)
/

CREATE INDEX AWARD_PERSON_UNITS_IDX1
   ON AWARD_PERSON_UNITS (AWARD_PERSON_ID)
/

CREATE INDEX BUDGET_DETAILS_IDX1
   ON BUDGET_DETAILS (BUDGET_PERIOD_NUMBER)
/

create index PROTOCOL_SUBMISSION_IDX2 on 
PROTOCOL_SUBMISSION(PROTOCOL_NUMBER)
/

ALTER TABLE TIME_AND_MONEY_DOCUMENT add (
   TIME_AND_MONEY_DOC_STATUS varchar2(10) default 'PENDING' not null
)
/

create index TIME_MONEY_DOC_STATUS_IDX on 
TIME_AND_MONEY_DOCUMENT(AWARD_NUMBER, TIME_AND_MONEY_DOC_STATUS)
/

update time_and_money_document doc set time_and_money_doc_status = 'CANCELED' 
where document_number in (select doc_hdr_id from 
  krew_doc_hdr_t where doc_hdr_id = doc.document_number and doc_hdr_stat_cd in ('X', 'D'))
/

update time_and_money_document doc set time_and_money_doc_status = 'PENDING' where document_number in (select doc_hdr_id from 
  krew_doc_hdr_t where doc_hdr_id = doc.document_number and doc_hdr_stat_cd in ('I', 'S', 'R', 'E'));
  
update time_and_money_document doc set time_and_money_doc_status = 'ARCHIVED' where document_number in (select doc_hdr_id from 
  krew_doc_hdr_t where doc_hdr_id = doc.document_number and doc_hdr_stat_cd in ('P', 'F'))
/

update time_and_money_document doc set time_and_money_doc_status = 'ACTIVE' 
  where document_number = 
    (select max(document_number) from time_and_money_document doc2 
      where time_and_money_doc_status = 'ARCHIVED' and doc.award_number = doc2.award_number)
/

        



