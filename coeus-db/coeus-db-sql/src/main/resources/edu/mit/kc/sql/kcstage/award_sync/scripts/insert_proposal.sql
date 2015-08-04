select ' Started PROPOSAL ' from dual
/
declare
li_count number;
begin
select count(*) into li_count from user_tables where table_name='TEMP_KREW_SYNC';
if li_count>0 then
execute immediate('drop table TEMP_KREW_SYNC');
end if;
end;
/
create table TEMP_KREW_SYNC(
DOCUMENT_NUMBER VARCHAR2(40),
RTE_BRCH_ID VARCHAR2(40),
RTE_NODE_ID VARCHAR2(40),
RTE_NODE_INSTN_ID VARCHAR2(40),
MODULE VARCHAR2(20))
/
DECLARE
li_ver_nbr NUMBER(8):=1;
li_proposal_id NUMBER(12,0);
ls_document_number VARCHAR2(40);
ls_unit_number VARCHAR2(8);
--ls_fiscal_year CHAR(4);
ls_proposal_sequence VARCHAR2(10):='ARCHIVED';
li_ip_review   NUMBER(12,0);
li_ip_review_join_id NUMBER(12,0);
ls_current_account_number VARCHAR2(100);
ls_curr_acc_num VARCHAR2(7);
ls_app_doc_stat VARCHAR2(64):=null;
ls_cfda_num VARCHAR2(7);
ls_person_id VARCHAR2(40);
ls_initial_contract_admin	VARCHAR2(40);
li_new_seq NUMBER(4,0):=0;
ls_proposal_number VARCHAR2(8);
li_krew_rnt_brch NUMBER(19,0);
li_krew_rnt_node NUMBER(19,0);
li_krew_rne_node_instn NUMBER(19,0);
ls_doc_typ_id VARCHAR2(40);
ls_prncpl_id VARCHAR2(40);
li_loop number;
li_commit_count number:=0;

CURSOR c_proposal IS
SELECT OSP$PROPOSAL.PROPOSAL_NUMBER,OSP$PROPOSAL.SEQUENCE_NUMBER,SPONSOR_PROPOSAL_NUMBER,PROPOSAL_TYPE_CODE,CURRENT_ACCOUNT_NUMBER,TITLE,SPONSOR_CODE,ROLODEX_ID,NOTICE_OF_OPPORTUNITY_CODE,GRAD_STUD_HEADCOUNT,
GRAD_STUD_PERSON_MONTHS,TYPE_OF_ACCOUNT,ACTIVITY_TYPE_CODE,REQUESTED_START_DATE_INITIAL,REQUESTED_START_DATE_TOTAL,REQUESTED_END_DATE_INITIAL,REQUESTED_END_DATE_TOTAL,TOTAL_DIRECT_COST_INITIAL,TOTAL_DIRECT_COST_TOTAL,TOTAL_INDIRECT_COST_INITIAL,TOTAL_INDIRECT_COST_TOTAL,NUMBER_OF_COPIES,DEADLINE_DATE,DEADLINE_TYPE,MAIL_BY,MAIL_TYPE,MAIL_ACCOUNT_NUMBER,SUBCONTRACT_FLAG,COST_SHARING_INDICATOR,IDC_RATE_INDICATOR,SPECIAL_REVIEW_INDICATOR,STATUS_CODE,UPDATE_TIMESTAMP,UPDATE_USER,SCIENCE_CODE_INDICATOR,NSF_CODE,PRIME_SPONSOR_CODE,CREATE_TIMESTAMP,INITIAL_CONTRACT_ADMIN,IP_REVIEW_REQ_TYPE_CODE,
REVIEW_SUBMISSION_DATE,REVIEW_RECEIVE_DATE,REVIEW_RESULT_CODE,IP_REVIEWER,IP_REVIEW_ACTIVITY_INDICATOR,REPLACE(trim(current_award_number),'-','-00') as CURRENT_AWARD_NUMBER,CFDA_NUMBER,OPPORTUNITY,AWARD_TYPE_CODE,KEY_PERSON_INDICATOR
FROM OSP$PROPOSAL@coeus.kuali INNER JOIN TEMP_TAB_TO_SYNC_IP t on OSP$PROPOSAL.PROPOSAL_NUMBER = t.PROPOSAL_NUMBER 
and OSP$PROPOSAL.SEQUENCE_NUMBER = t.SEQUENCE_NUMBER
WHERE t.FEED_TYPE='N' 
order by OSP$PROPOSAL.PROPOSAL_NUMBER,OSP$PROPOSAL.SEQUENCE_NUMBER;
r_proposal c_proposal%ROWTYPE;


BEGIN

IF c_proposal%ISOPEN THEN
CLOSE c_proposal;
END IF;

OPEN c_proposal;
li_loop:=0;
LOOP
FETCH c_proposal INTO r_proposal;
EXIT WHEN c_proposal%NOTFOUND;
ls_proposal_number:=r_proposal.PROPOSAL_NUMBER;

	BEGIN
	SELECT t1.UNIT_NUMBER INTO ls_unit_number FROM OSP$PROPOSAL_UNITS@coeus.kuali t1 WHERE t1.LEAD_UNIT_FLAG='Y' AND t1.PROPOSAL_NUMBER=r_proposal.PROPOSAL_NUMBER 
	AND t1.SEQUENCE_NUMBER = (	select max(t2.SEQUENCE_NUMBER) from OSP$PROPOSAL_UNITS@coeus.kuali t2
								where t2.PROPOSAL_NUMBER = t1.PROPOSAL_NUMBER 
								and   t2.SEQUENCE_NUMBER <= r_proposal.SEQUENCE_NUMBER
							 );

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	ls_unit_number:=NULL;
	END;

	li_new_seq := r_proposal.SEQUENCE_NUMBER;

	SELECT SEQ_PROPOSAL_PROPOSAL_ID.NEXTVAL INTO li_proposal_id FROM DUAL;
	SELECT SEQ_IP_REVIEW_ID.NEXTVAL INTO li_ip_review FROM DUAL;
	SELECT KREW_DOC_HDR_S.NEXTVAL INTO ls_document_number FROM DUAL;

	ls_person_id:=r_proposal.IP_REVIEWER;          

	ls_initial_contract_admin:=r_proposal.INITIAL_CONTRACT_ADMIN;         

	BEGIN
	INSERT INTO IP_REVIEW(IP_REVIEW_ID,PROPOSAL_NUMBER,SEQUENCE_NUMBER,IP_REVIEW_REQ_TYPE_CODE,REVIEW_SUBMISSION_DATE,REVIEW_RECEIVE_DATE,REVIEW_RESULT_CODE,IP_REVIEWER,IP_REVIEW_SEQUENCE_STATUS,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	VALUES(li_ip_review,r_proposal.PROPOSAL_NUMBER,li_new_seq,r_proposal.IP_REVIEW_REQ_TYPE_CODE,r_proposal.REVIEW_SUBMISSION_DATE,r_proposal.REVIEW_RECEIVE_DATE,r_proposal.REVIEW_RESULT_CODE,ls_person_id,ls_proposal_sequence,r_proposal.UPDATE_TIMESTAMP,r_proposal.UPDATE_USER,li_ver_nbr,SYS_GUID());
	EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('ERROR IN IP_REVIEW,PROPOSAL_NUMBER:'||r_proposal.PROPOSAL_NUMBER||'-'||sqlerrm);
	END;

	ls_cfda_num:=r_proposal.CFDA_NUMBER;  

	if  ls_cfda_num IS NOT NULL then         
	select substr(trim(ls_cfda_num),1,2)||'.'||substr(trim(ls_cfda_num),3) into ls_cfda_num from dual;
	end if;


	BEGIN
		ls_current_account_number:=r_proposal.CURRENT_ACCOUNT_NUMBER;
		SELECT SUBSTR(trim(ls_current_account_number),1,7)INTO ls_curr_acc_num FROM DUAL;

		INSERT INTO PROPOSAL(PROPOSAL_ID,DOCUMENT_NUMBER,CREATE_TIMESTAMP,MAIL_DESCRIPTION,PROPOSAL_SEQUENCE_STATUS,FISCAL_MONTH,FISCAL_YEAR,LEAD_UNIT_NUMBER,PROPOSAL_NUMBER,SPONSOR_PROPOSAL_NUMBER,SEQUENCE_NUMBER,PROPOSAL_TYPE_CODE,CURRENT_ACCOUNT_NUMBER,TITLE,SPONSOR_CODE,ROLODEX_ID,NOTICE_OF_OPPORTUNITY_CODE,GRAD_STUD_HEADCOUNT,GRAD_STUD_PERSON_MONTHS,TYPE_OF_ACCOUNT,ACTIVITY_TYPE_CODE,REQUESTED_START_DATE_INITIAL,REQUESTED_START_DATE_TOTAL,REQUESTED_END_DATE_INITIAL,REQUESTED_END_DATE_TOTAL,TOTAL_DIRECT_COST_INITIAL,TOTAL_DIRECT_COST_TOTAL,TOTAL_INDIRECT_COST_INITIAL,TOTAL_INDIRECT_COST_TOTAL,NUMBER_OF_COPIES,DEADLINE_DATE,DEADLINE_TYPE,MAIL_BY,MAIL_TYPE,MAIL_ACCOUNT_NUMBER,SUBCONTRACT_FLAG,COST_SHARING_INDICATOR,IDC_RATE_INDICATOR,SPECIAL_REVIEW_INDICATOR,STATUS_CODE,SCIENCE_CODE_INDICATOR,NSF_CODE,PRIME_SPONSOR_CODE,INITIAL_CONTRACT_ADMIN,IP_REVIEW_ACTIVITY_INDICATOR,CURRENT_AWARD_NUMBER,CFDA_NUMBER,OPPORTUNITY,UPDATE_TIMESTAMP,UPDATE_USER,AWARD_TYPE_CODE,VER_NBR,OBJ_ID)
		VALUES(li_proposal_id,ls_document_number,r_proposal.CREATE_TIMESTAMP, NULL,ls_proposal_sequence,NULL,NULL,ls_unit_number,r_proposal.PROPOSAL_NUMBER,r_proposal.SPONSOR_PROPOSAL_NUMBER,li_new_seq,r_proposal.PROPOSAL_TYPE_CODE,ls_curr_acc_num,r_proposal.TITLE,r_proposal.SPONSOR_CODE,r_proposal.ROLODEX_ID,r_proposal.NOTICE_OF_OPPORTUNITY_CODE,r_proposal.GRAD_STUD_HEADCOUNT,r_proposal.GRAD_STUD_PERSON_MONTHS,r_proposal.TYPE_OF_ACCOUNT,r_proposal.ACTIVITY_TYPE_CODE,r_proposal.REQUESTED_START_DATE_INITIAL,r_proposal.REQUESTED_START_DATE_TOTAL,r_proposal.REQUESTED_END_DATE_INITIAL,r_proposal.REQUESTED_END_DATE_TOTAL,r_proposal.TOTAL_DIRECT_COST_INITIAL,r_proposal.TOTAL_DIRECT_COST_TOTAL,r_proposal.TOTAL_INDIRECT_COST_INITIAL,r_proposal.TOTAL_INDIRECT_COST_TOTAL,r_proposal.NUMBER_OF_COPIES,r_proposal.DEADLINE_DATE,r_proposal.DEADLINE_TYPE,r_proposal.MAIL_BY,r_proposal.MAIL_TYPE,r_proposal.MAIL_ACCOUNT_NUMBER,r_proposal.SUBCONTRACT_FLAG,r_proposal.COST_SHARING_INDICATOR,r_proposal.IDC_RATE_INDICATOR,r_proposal.SPECIAL_REVIEW_INDICATOR,r_proposal.STATUS_CODE,r_proposal.SCIENCE_CODE_INDICATOR,r_proposal.NSF_CODE,r_proposal.PRIME_SPONSOR_CODE,ls_initial_contract_admin,r_proposal.IP_REVIEW_ACTIVITY_INDICATOR,r_proposal.CURRENT_AWARD_NUMBER,ls_cfda_num,r_proposal.OPPORTUNITY,r_proposal.UPDATE_TIMESTAMP,r_proposal.UPDATE_USER,r_proposal.AWARD_TYPE_CODE,li_ver_nbr,SYS_GUID());
		
		--INSERT INTO SYNC_AWARD_LOG(feed_id,execution_date) VALUES(r_award.feed_id,sysdate);

	EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('ERROR IN PROPOSAL,PROPOSAL_NUMBER:'||r_proposal.PROPOSAL_NUMBER||'SEQUENCE_NUMBER:'||r_proposal.SEQUENCE_NUMBER||'-'||sqlerrm);
	END;
	select max(to_number(DOC_TYP_ID)) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='InstitutionalProposalDocument';
	        
			begin
			select p.prncpl_id into ls_prncpl_id  from KRIM_PRNCPL_T p where LOWER(p.PRNCPL_NM)=LOWER(r_proposal.UPDATE_USER);
			exception
			when others then
			ls_prncpl_id:='unknownuser';
			end;
	
	INSERT INTO INSTITUTE_PROPOSAL_DOCUMENT(DOCUMENT_NUMBER,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	VALUES(ls_document_number,1,r_proposal.UPDATE_TIMESTAMP,r_proposal.UPDATE_USER,sys_guid());
	
	INSERT INTO PROPOSAL_IP_REVIEW_JOIN(PROPOSAL_IP_REVIEW_JOIN_ID,PROPOSAL_ID,IP_REVIEW_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	VALUES(SEQ_PROPOSAL_IP_REVIEW_JOIN_ID.NEXTVAL,li_proposal_id,li_ip_review,r_proposal.UPDATE_TIMESTAMP,r_proposal.UPDATE_USER,1,sys_guid());
	
	INSERT INTO KREW_DOC_HDR_T(DOC_HDR_ID,DOC_TYP_ID,DOC_HDR_STAT_CD,RTE_LVL,STAT_MDFN_DT,CRTE_DT,APRV_DT,FNL_DT,RTE_STAT_MDFN_DT,TTL,APP_DOC_ID,DOC_VER_NBR,INITR_PRNCPL_ID,VER_NBR,RTE_PRNCPL_ID,DTYPE,OBJ_ID,APP_DOC_STAT,APP_DOC_STAT_MDFN_DT)
    VALUES(ls_document_number,ls_doc_typ_id,'F',0,sysdate,r_proposal.UPDATE_TIMESTAMP,sysdate,NULL,sysdate,('InstitutionalProposalDocument'||'-'||r_proposal.PROPOSAL_NUMBER),NULL,1,ls_prncpl_id,1,NULL,NULL,SYS_GUID(),NULL,NULL);
	
	INSERT INTO KRNS_DOC_HDR_T(DOC_HDR_ID,OBJ_ID,VER_NBR,FDOC_DESC,ORG_DOC_HDR_ID,TMPL_DOC_HDR_ID,EXPLANATION)
	VALUES(ls_document_number,SYS_GUID(),1,r_proposal.PROPOSAL_NUMBER,NULL,NULL,NULL);
	
	INSERT INTO KREW_DOC_HDR_CNTNT_T(DOC_HDR_ID)
	VALUES(ls_document_number);
	
	select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_brch from dual ; 
	select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_node from dual ;
	select KREW_RTE_NODE_S.NEXTVAL into li_krew_rne_node_instn from dual ;
	
	INSERT INTO KREW_RTE_BRCH_T(RTE_BRCH_ID,NM,PARNT_ID,INIT_RTE_NODE_INSTN_ID,SPLT_RTE_NODE_INSTN_ID,JOIN_RTE_NODE_INSTN_ID,VER_NBR)
	VALUES(li_krew_rnt_brch,'PRIMARY',NULL,NULL,NULL,NULL,1);
	
	INSERT INTO KREW_RTE_NODE_T(RTE_NODE_ID,DOC_TYP_ID,NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,FNL_APRVR_IND,MNDTRY_RTE_IND,ACTVN_TYP,BRCH_PROTO_ID,VER_NBR,CONTENT_FRAGMENT,GRP_ID,NEXT_DOC_STAT)
	VALUES(li_krew_rnt_node,ls_doc_typ_id,'Initiated','org.kuali.rice.kew.engine.node.InitialNode',null,null,0,	0,'P',null,1,null,null,null);
	
	INSERT INTO KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,RTE_NODE_INSTN_ID)
	VALUES(ls_document_number,li_krew_rne_node_instn);
	
	INSERT INTO KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,DOC_HDR_ID,RTE_NODE_ID,BRCH_ID,PROC_RTE_NODE_INSTN_ID,ACTV_IND,CMPLT_IND,INIT_IND,VER_NBR)
	VALUES(li_krew_rne_node_instn,ls_document_number,li_krew_rnt_node,li_krew_rnt_brch,NULL,1,0,0,1);

	INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
    VALUES(KREW_ACTN_RQST_S.NEXTVAL,NULL,'C',ls_document_number,NULL,'A',-3,ls_prncpl_id,NULL,NULL,NULL,'U',0,NULL,0,li_krew_rne_node_instn,NULL,1,SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1,0,NULL,NULL);
	
	INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
    VALUES(KREW_ACTN_TKN_S.NEXTVAL,ls_document_number,ls_prncpl_id,NULL,'S',SYSDATE,1,NULL,1,1,NULL);

	INSERT INTO TEMP_KREW_SYNC(DOCUMENT_NUMBER,RTE_BRCH_ID,RTE_NODE_ID,RTE_NODE_INSTN_ID,MODULE)
	VALUES(ls_document_number,li_krew_rnt_brch,li_krew_rnt_node,li_krew_rne_node_instn,'IP');

	INSERT INTO TEMP_SEQ_LOG(MODULE,MODULE_ID,MODULE_ITEM_KEY,MIT_SEQUENCE_NUMBER,KUALI_SEQUENCE_NUMBER,CHANGED)
	VALUES('IP',li_proposal_id,r_proposal.PROPOSAL_NUMBER,r_proposal.SEQUENCE_NUMBER,li_new_seq,'N'); 

END LOOP;
CLOSE c_proposal;

dbms_output.put_line('Completed PROPOSAL  AND ITS INDICATOR TABLES!!!');
END;
/
/*
---------- KREW START----------------------------------
select ' Start time of PROPOSAL KREW TABLES  is '|| localtimestamp from dual
/
INSERT INTO INSTITUTE_PROPOSAL_DOCUMENT(DOCUMENT_NUMBER,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
select DOCUMENT_NUMBER,1,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() 
from proposal inner join temp_tab_to_sync_ip on proposal.proposal_number = temp_tab_to_sync_ip.proposal_number 
and proposal.sequence_number = temp_tab_to_sync_ip.sequence_number  
WHERE temp_tab_to_sync_ip.FEED_TYPE='N' ;
commit;
INSERT INTO PROPOSAL_IP_REVIEW_JOIN(PROPOSAL_IP_REVIEW_JOIN_ID,PROPOSAL_ID,IP_REVIEW_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
select SEQ_PROPOSAL_IP_REVIEW_JOIN_ID.NEXTVAL,p.PROPOSAL_ID,ip.IP_REVIEW_ID,p.UPDATE_TIMESTAMP,p.UPDATE_USER,1,sys_guid()
from PROPOSAL p 
inner join IP_REVIEW ip on p.PROPOSAL_NUMBER=ip.PROPOSAL_NUMBER and p.SEQUENCE_NUMBER=ip.SEQUENCE_NUMBER
inner join temp_tab_to_sync_ip on p.proposal_number = temp_tab_to_sync_ip.proposal_number and p.sequence_number = temp_tab_to_sync_ip.sequence_number
WHERE temp_tab_to_sync_ip.FEED_TYPE='N' ;     
commit;
/
declare
ls_doc_typ_id VARCHAR2(40);
begin  --UMB added max(DOC_TYP_ID) below
select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='InstitutionalProposalDocument';
INSERT INTO KREW_DOC_HDR_T(DOC_HDR_ID,DOC_TYP_ID,DOC_HDR_STAT_CD,RTE_LVL,STAT_MDFN_DT,CRTE_DT,APRV_DT,FNL_DT,RTE_STAT_MDFN_DT,TTL,APP_DOC_ID,DOC_VER_NBR,INITR_PRNCPL_ID,VER_NBR,RTE_PRNCPL_ID,DTYPE,OBJ_ID,APP_DOC_STAT,APP_DOC_STAT_MDFN_DT)
select a.document_number,ls_doc_typ_id,'F',0,sysdate,a.UPDATE_TIMESTAMP,sysdate,NULL,sysdate,('InstitutionalProposalDocument'||'-'||a.PROPOSAL_NUMBER) TTL,NULL,1,nvl(p.PRNCPL_ID,'unknownuser'),1,NULL,NULL,SYS_GUID(),NULL,NULL
from PROPOSAL a inner join temp_tab_to_sync_ip on a.proposal_number = temp_tab_to_sync_ip.proposal_number and a.sequence_number = temp_tab_to_sync_ip.sequence_number
left outer join KRIM_PRNCPL_T p on p.PRNCPL_NM=LOWER(a.UPDATE_USER)
WHERE temp_tab_to_sync_ip.FEED_TYPE='N' ;         
commit;
end ;
/
INSERT INTO KRNS_DOC_HDR_T(DOC_HDR_ID,OBJ_ID,VER_NBR,FDOC_DESC,ORG_DOC_HDR_ID,TMPL_DOC_HDR_ID,EXPLANATION)
select a.document_number,SYS_GUID(),1,a.PROPOSAL_NUMBER,NULL,NULL,NULL 
from PROPOSAL a 
inner join temp_tab_to_sync_ip on a.proposal_number = temp_tab_to_sync_ip.proposal_number and a.sequence_number = temp_tab_to_sync_ip.sequence_number
WHERE temp_tab_to_sync_ip.FEED_TYPE='N' ;  
commit;
INSERT INTO KREW_DOC_HDR_CNTNT_T(DOC_HDR_ID,DOC_CNTNT_TXT)
select a.document_number,NULL from PROPOSAL a
inner join temp_tab_to_sync_ip t on a.proposal_number = t.proposal_number and a.sequence_number = t.sequence_number
WHERE t.FEED_TYPE='N'; 
commit;
INSERT INTO KREW_RTE_BRCH_T(RTE_BRCH_ID,NM,PARNT_ID,INIT_RTE_NODE_INSTN_ID,SPLT_RTE_NODE_INSTN_ID,JOIN_RTE_NODE_INSTN_ID,VER_NBR)
select RTE_BRCH_ID,'PRIMARY',NULL,NULL,NULL,NULL,1 from TEMP_KREW_SYNC where MODULE='IP' ;
commit;
/
declare
ls_doc_typ_id VARCHAR2(40);
begin  --UMB added max(DOC_TYP_ID) below
select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='InstitutionalProposalDocument';
INSERT INTO KREW_RTE_NODE_T(RTE_NODE_ID,DOC_TYP_ID,NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,FNL_APRVR_IND,MNDTRY_RTE_IND,ACTVN_TYP,BRCH_PROTO_ID,VER_NBR,CONTENT_FRAGMENT,GRP_ID,NEXT_DOC_STAT)
select RTE_NODE_ID,ls_doc_typ_id,'Initiated','org.kuali.rice.kew.engine.node.InitialNode',null,null,0,	0,'P',null,1,null,null,null from TEMP_KREW_SYNC where MODULE='IP' ;
commit;
end ;
/
INSERT INTO KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,RTE_NODE_INSTN_ID)
select DOCUMENT_NUMBER,RTE_NODE_INSTN_ID from TEMP_KREW_SYNC where MODULE='IP' ;
commit;
INSERT INTO KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,DOC_HDR_ID,RTE_NODE_ID,BRCH_ID,PROC_RTE_NODE_INSTN_ID,ACTV_IND,CMPLT_IND,INIT_IND,VER_NBR)
select RTE_NODE_INSTN_ID,DOCUMENT_NUMBER,RTE_NODE_ID,RTE_BRCH_ID,NULL,1,0,0,1 from TEMP_KREW_SYNC where MODULE='IP' ;
commit;
INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
select KREW_ACTN_RQST_S.NEXTVAL,NULL,'C',k.DOC_HDR_ID,NULL,'A',-3,k.INITR_PRNCPL_ID,NULL,NULL,NULL,'U',0,NULL,0,t.RTE_NODE_INSTN_ID,NULL,1,SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1	,0,NULL,NULL from KREW_DOC_HDR_T k inner join TEMP_KREW_SYNC t on k.DOC_HDR_ID=t.DOCUMENT_NUMBER where k.TTL like 'InstitutionalProposalDocument%' AND t.MODULE='IP' ;
commit;
INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
select KREW_ACTN_TKN_S.NEXTVAL,k.DOC_HDR_ID,k.INITR_PRNCPL_ID,NULL,'S',SYSDATE,1,NULL,1,1,NULL from KREW_DOC_HDR_T k inner join TEMP_KREW_SYNC t on k.DOC_HDR_ID=t.DOCUMENT_NUMBER where k.TTL like 'InstitutionalProposalDocument%' AND t.MODULE='IP' ;
commit
/
*/
declare
ls_doc_typ_id VARCHAR2(40);
li_need_insert number;
cursor c_prop is
select t1.proposal_number , t1.sequence_number
from 
(
  select a.proposal_number , max(a.sequence_number) sequence_number 
  from proposal a 
  group by a.proposal_number
) t1 inner join temp_tab_to_sync_ip t2 on t1.proposal_number = t2.proposal_number and t1.sequence_number = t2.sequence_number
WHERE t2.FEED_TYPE='N'; 
r_prop c_prop%ROWTYPE;
begin
li_need_insert := 1;
begin --UMB added max() below  
select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='InstitutionalProposalDocument';
exception
when others then
li_need_insert := 0;
end;
if li_need_insert = 1 then
open c_prop;
loop
fetch c_prop into r_prop;
exit when c_prop%notfound;

update IP_REVIEW set IP_REVIEW_SEQUENCE_STATUS = 'ACTIVE' where proposal_number =  r_prop.proposal_number and sequence_number =  r_prop.sequence_number;
update PROPOSAL set PROPOSAL_SEQUENCE_STATUS = 'ACTIVE' where proposal_number =  r_prop.proposal_number and sequence_number =  r_prop.sequence_number;

commit;

end loop;
close c_prop;
end if;
end;
/
declare
li_doc number(10);
li_proposal_max number(10);
ls_query VARCHAR2(400);
li_num NUMBER;
begin

SELECT MAX(PROPOSAL_NUMBER) INTO li_proposal_max FROM PROPOSAL;
select SEQ_PROPOSAL_NUMBER.NEXTVAL into li_num from dual;
li_proposal_max:= li_proposal_max - li_num;
ls_query:='alter sequence SEQ_PROPOSAL_NUMBER increment by '||li_proposal_max;      
execute immediate(ls_query);  

end;
/
select SEQ_PROPOSAL_NUMBER.NEXTVAL from dual
/
alter sequence SEQ_PROPOSAL_NUMBER increment by 1
/ 
select ' Ended PROPOSAL KREW TABLES  ' from dual
/
---------- KREW ENDS ----------------------------------
select ' Ended PROPOSAL ' from dual
/