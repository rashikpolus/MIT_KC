select Coeus_Award_Template_Count,KC_Award_Template_Count from
(select count(*) Coeus_Award_Template_Count from OSP$TEMPLATE_COMMENTS@coeus.kuali)a, 
(select count(*) KC_Award_Template_Count from AWARD_TEMPLATE_COMMENTS)b;


select count(*) from osp$unit@coeus.kuali

select count(*) from osp$SPONSOR_HIERARCHY@coeus.kuali

select max(to_number(proposal_number)) from osp$eps_proposal@coeus.kuali

select max(to_number(proposal_number)) from eps_proposal

select 

select max(FEED_ID)  from SAP_FEED_DETAILS


create user anish_a identified by anishR0cks;
create role KC_VIEW;
grant select any table to KC_VIEW;
grant KC_VIEW to anish_a;
grant create session to anish_a;

select count(*) from award_attachment

select count(*) from attachment_file

select count(*) from osp$award_documents@coeus.kuali

ALTER TABLE AWARD_ATTACHMENT ENABLE CONSTRAINT FK_AWARD_ATTACHMENT_TYPE

ALTER TABLE AWARD_ATTACHMENT ENABLE CONSTRAINT FK_AW_ATT_AWARD

ALTER TABLE AWARD_ATTACHMENT ADD CONSTRAINT FK_ATTACHMENT_FILE FOREIGN KEY (FILE_ID) REFERENCES ATTACHMENT_FILE(FILE_ID)

ALTER TABLE PROTOCOL_ATTACHMENT_PROTOCOL DISABLE CONSTRAINT FK_PA_PROTOCOL_FILE
/
ALTER TABLE PROTOCOL_ATTACHMENT_PERSONNEL DISABLE CONSTRAINT FK_PA_PERSONNEL_FILE
/
delete from ATTACHMENT_FILE where FILE_ID in ( select FILE_ID from PROTOCOL_ATTACHMENT_PERSONNEL )
/
commit
/
delete from PROTOCOL_ATTACHMENT_PERSONNEL
/
commit
/
select count(*) from PROTOCOL_ATTACHMENT_PROTOCOL


delete from ATTACHMENT_FILE where FILE_ID in ( select FILE_ID from PROTOCOL_ATTACHMENT_PROTOCOL )


select count(*) from narrative_attachment where file_data_id not in (select id from file_data)

select count(*) from file_data

select count(*) from eps_prop_person_bio_attachment where file_data_id not in (select id from file_data)

select count(*)  from file_data a, narrative_attachment b 
where b.file_data_id = a.id

select file_data_id from  narrative_attachment


select id from file_data where id in ('15280F02B7A7C00CE0537C2C091220FE')
update krms_agenda_t set actv ='Y'



select distinct t1.rule_id, t1.module_item_code, t1.module_sub_item_code, t2.questionnaire_id, t2.sequence_number
 from questionnaire_usage@KC_STAG_DB_LINK t1
 inner join questionnaire@KC_STAG_DB_LINK t2 on t1.questionnaire_ref_id_fk = t2.questionnaire_ref_id
 where t1.rule_id is not null
 and t2.sequence_number in ( select max(s1.sequence_number) from questionnaire@KC_STAG_DB_LINK s1
                             where s1.questionnaire_id = t2.questionnaire_id );
                             
                             
                             
                             
update krms_agenda_t set actv ='Y'
                             
                             
update questionnaire_usage set rule_id=null                             
                             
                             
select * from document_access where doc_hdr_id in (select document_number from eps_proposal where proposal_number = '1027')

select distinct role_nm from document_access
                             

update document_access set role_nm = 'Approver Document Level' where role_nm='Approver'
/
alter table document_access drop constraint UQ_DOCUMENT_ACCESS1
commit;
update document_access set role_nm = 'Aggregator Document Level' where role_nm='Aggregator'

update krim_role_t set role_nm='Approver Document Level' where role_nm='approver Document Level'


update eps_proposal_budget_ext set status_code='1' where status_code='C'
update eps_proposal_budget_ext set status_code='2' where status_code='I'

select count(*) from sap_feed_details

UPDATE sap_feed_details SET award_number = replace(award_number,'-','-00');

sap_budget_feed_batch_list SET no_of_records = li_no_of_records  WHERE sap_budget_feed_batch_id = li_sap_budget_feed_batch_id;

select count(*) from 

select count(*) from budget_details where cost_element='422121'

update krms_term_parm_t set nm='Sponsor Type Code' where nm='Sponsor Code'

update krms_term_parm_t set nm='Unit Number' where nm='Lead Unit Number'

select * from krms_term_parm_t where nm='CompetitionId'

update krms_term_parm_t set nm='Sponsor Type Code' where nm='CompetitionId'

select * from krms_term_parm_t where nm='Fellowship Codes' and val is null

update krms_term_parm_t set nm='Unit Number' where nm='Fellowship Codes' and val is null

update questionnaire_usage set rule_id='10094' where QUESTIONNAIRE_REF_ID_FK='444161'

select questionnaire_label, rule_id from questionnaire_usage@kc_stag_db_link where rule_id is not null

select KRMS_TERM_S.nextval from dual;

select * from krms_agenda_t
 where typ_id = 'KC1004';
 
 update krms_agenda_t set actv='Y'
 
 select * from question where question_id = '103'
 
 update question set question_id = '143' where question='Have lobbying activities been conducted on behalf of this proposal? Disclosure of Lobbying Activities (GPG, Chapter II.C.1.e)'

 update question set question_id = '144' where question like 'Select a Funding Mechanism'

 update eps_prop_person a 
 set (LAST_NOTIFICATION, CERTIFIED_BY) =(select LAST_NOTIFICATION_DATE, CERTIFIED_BY from osp$eps_prop_person@coeus.kuali b
 where a.proposal_number=to_number(b.proposal_number) and a.person_id=b.person_id and a.rolodex_id is null)
 where exists
   (select LAST_NOTIFICATION_DATE, CERTIFIED_BY from osp$eps_prop_person@coeus.kuali b
 where a.proposal_number=to_number(b.proposal_number) and a.person_id=b.person_id and a.rolodex_id is null);
 
 
 DECLARE
li_count number;
cursor c_update is
select proposal_number, person_id, proposal_number || '|' || to_char(prop_person_number) mod_key
       from eps_prop_person where person_id is not null;

r_update c_update%ROWTYPE;
BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

update QUESTIONNAIRE_ANSWER_HEADER a set MODULE_ITEM_KEY = r_update.mod_key
where module_item_code = '3' and module_item_key = r_update.proposal_number and module_sub_item_key = r_update.person_id;

END LOOP;
CLOSE c_update;
END;
/

update krew_usr_optn_t set val=null where prsn_optn_id in ('NOTIFY_ACKNOWLEDGE','NOTIFY_COMPLETE','NOTIFY_FYI')
/
select * from krew_usr_optn_t where prsn_optn_id='NOTIFY_FYI' and val is not null
/
update eps_proposal a set final_budget_id = 
    (select budget_id from eps_proposal_budget_ext where proposal_number=a.proposal_number and 
                    final_version_flag='Y' and status_code='1') 
/
insert into document_nextvalue (document_number,property_name,next_value,update_user,update_timestamp,obj_id,ver_nbr,document_next_value_type)
(select b.document_number,'SPECIAL_REVIEW_NUMBER',max(nvl(special_review_number,0))+1,user,sysdate,sys_guid(),1,'DOC'
    from award_special_review a,award b where a.award_id=b.award_id group by a.award_id,b.document_number)
 

create index IDX_EPS_PROP_PERSON_BIO_ATCH on EPS_PROP_PERSON_BIO_ATTACHMENT (FILE_DATA_ID);        

create index IDX_NARRATIVE_ATTACHMENT on NARRATIVE_ATTACHMENT (FILE_DATA_ID);        

update time_and_money_document a set award_number=(select ROOT_AWARD_NUMBER from award_hierarchy b where b.award_number=a.award_number)

update krcr_parm_t set val ='10,15' where parm_nm = 'SAP_AWD_BUD_FEED_STATUS';

update protocol_attachment_protocol set status_cd = '2'

update protocol_attachment_protocol a set PROTOCOL_ID_FK = 
  (select protocol_id from protocol where protocol_number=a.protocol_number and sequence_number=a.sequence_number)
  
update eps_proposal p
  set create_user = (select prncpl_nm from krim_prncpl_t a,krew_doc_hdr_t b 
                      where a.prncpl_id=b.INITR_PRNCPL_ID and b.doc_hdr_id = p.document_number),
      create_timestamp = (select CRTE_DT from krew_doc_hdr_t b where b.doc_hdr_id = p.document_number)
      where  create_user is null
      
update award_budget_ext a set award_budget_status_code = '14' where budget_id in ('148673','148674','148675','148676','146054')

update wl_current_load a set complexity= (select fn_get_complexity(a.proposal_number) from dual) where complexity is null

Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-PD','Document','PROPOSAL_TYPE_CODE_SUPPLEMENT',sys_guid(),1,'CONFG','4','A','Proposal Type:PreProposal','KUALI')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-S2S','All','PROPOSAL_TYPE_CODE_SUPPLEMENT',sys_guid(),1,'CONFG','@{#param("KC-PD", "Document", "PROPOSAL_TYPE_CODE_SUPPLEMENT")}','A','s2sCode corresponding to Proposal Type:Supplement','KUALI')
/
alter table BUDGET_DETAILS modify LINE_ITEM_NUMBER NUMBER (6,0)
/
alter table BUDGET_DETAILS_CAL_AMTS modify LINE_ITEM_NUMBER NUMBER (6,0)
/
alter table BUDGET_PERSONNEL_DETAILS modify LINE_ITEM_NUMBER NUMBER (6,0)
/
alter table BUDGET_PERSONNEL_CAL_AMTS modify LINE_ITEM_NUMBER NUMBER (6,0)
/
alter table BUDGET_RATE_AND_BASE modify LINE_ITEM_NUMBER NUMBER (6,0)
/
