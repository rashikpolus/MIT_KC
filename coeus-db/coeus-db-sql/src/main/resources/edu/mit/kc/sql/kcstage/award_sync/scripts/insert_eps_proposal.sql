declare
li_count number;
begin
  select  count(table_name) into li_count  from user_tables   where table_name = 'TEMP_LOOKUP_FOR_PROPOSAL';
  if li_count = 0 then
        execute immediate('CREATE TABLE TEMP_LOOKUP_FOR_PROPOSAL  (
                          PROPOSAL_NUMBER	        VARCHAR2(8),
						  DOCUMENT_NUMBER	VARCHAR2(40),
						  BUDGET_ID	NUMBER(12,0),
						  VERSION_NUMBER	NUMBER(12,0)                          
                          )');       
       
  end if;
end;
/
commit
/
select ' Start time of insert to EPS_PROPOSAL is ' from dual
/
DECLARE
ls_submit_flag CHAR(1):='N';
ls_is_hierarchy CHAR(1):='N';
ls_hierarchy_prop_num VARCHAR2(12):=null;
ls_hierarchy_hash_cd NUMBER(10,0):=null;
ls_hierarchy_bgt_typ CHAR(1);
li_child_type_code	NUMBER(3,0);
ls_hierarchy_orig_child VARCHAR2(12):=null;
ls_doc_nbr VARCHAR2(40);
li_ver_nbr number:=1;
li_loop_count number;
li_loop_error_count number;
-- KREW variables
li_doc_typ_id NUMBER(19,0); 
ls_doc_hdr_stat_cd VARCHAR2(1);
li_rte_lvl NUMBER(8,0):=0;
ll_stat_mdfn_dt DATE:=sysdate;
ll_crte_dt DATE:=sysdate;
ll_aprv_dt DATE:=sysdate;
ll_fnl_dt DATE:=null;
ll_rt_stat_mdfn_dt DATE:=sysdate;
ls_title VARCHAR2(255);
ls_app_doc_id VARCHAR2(255):=null;
li_doc_ver_nbr 	NUMBER(8,0):=1;
ls_initr_prncpl_id VARCHAR2(40);
li_krew_ver_nbr NUMBER(8,0):=1;
ls_rte_prncpl_id VARCHAR2(40):=null;
ls_dtype VARCHAR2(50):=null;
ls_app_doc_stat VARCHAR2(64):=null;
ls_app_doc_stat_mdfn_dt DATE:=null;
ls_proposal_num varchar2(20);
li_count_eps_proposal number;
li_count_eps_prop_doc number;
ls_proposal_type_cd VARCHAR2(3);
li_status_cd NUMBER(3,0);
ls_budget_status varchar2(2);
li_budget_status_cd number;
ls_cfda_num VARCHAR2(7);
li_commit_count number:=0;
li_krew_rnt_node NUMBER(19,0);
li_krew_rnt_brch NUMBER(19,0);
li_krew_rne_node_instn NUMBER(19,0);
li_krew_actn_rqst NUMBER(19,0);
li_krew_actn_tkn NUMBER(19,0);

li_hier_count number;
li_krew_rnt_node_active number;
li_krew_rnt_node_complt number;

CURSOR c_eps_proposal IS
SELECT OSP$EPS_PROPOSAL.* FROM OSP$EPS_PROPOSAL@coeus.kuali INNER JOIN TEMP_TAB_TO_SYNC_DEV t on OSP$EPS_PROPOSAL.PROPOSAL_NUMBER = t.PROPOSAL_NUMBER 
WHERE t.FEED_TYPE = 'N' ;
r_eps_proposal c_eps_proposal%ROWTYPE;

BEGIN
IF c_eps_proposal%ISOPEN THEN
CLOSE c_eps_proposal;
END IF;
OPEN c_eps_proposal;
li_loop_count:=0;
li_loop_error_count:=0;
execute immediate('ALTER TABLE EPS_PROPOSAL DISABLE CONSTRAINT EPS_PROPOSAL_FK1');
LOOP
FETCH c_eps_proposal INTO r_eps_proposal;
EXIT WHEN c_eps_proposal%NOTFOUND;

	select count(DOCUMENT_NUMBER) into li_count_eps_proposal from eps_proposal where proposal_number = to_number(r_eps_proposal.PROPOSAL_NUMBER);
	if li_count_eps_proposal > 0 then
		INSERT INTO SYNC_EPS_ALREADY_PRESENT(PROPOSAL_NUMBER) VALUES(r_eps_proposal.PROPOSAL_NUMBER);
		continue;
	
	end if;


SELECT KREW_DOC_HDR_S.NEXTVAL INTO ls_doc_nbr FROM DUAL;
INSERT INTO EPS_PROPOSAL_DOCUMENT(DOCUMENT_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,PROPOSAL_DELETED)
VALUES(ls_doc_nbr,r_eps_proposal.UPDATE_TIMESTAMP,r_eps_proposal.UPDATE_USER,li_ver_nbr,SYS_GUID(),'N');    

INSERT INTO TEMP_LOOKUP_FOR_PROPOSAL(PROPOSAL_NUMBER,DOCUMENT_NUMBER)
VALUES(to_number(r_eps_proposal.PROPOSAL_NUMBER),ls_doc_nbr);

BEGIN
SELECT  to_number(parent_proposal_number) INTO ls_hierarchy_prop_num FROM osp$eps_proposal_hierarchy@coeus.kuali WHERE child_proposal_number = (r_eps_proposal.PROPOSAL_NUMBER);
ls_is_hierarchy:='C';
EXCEPTION
WHEN OTHERS THEN	
SELECT  count(to_number(child_proposal_number)) INTO li_hier_count FROM osp$eps_proposal_hierarchy@coeus.kuali WHERE parent_proposal_number = (r_eps_proposal.PROPOSAL_NUMBER); 
ls_hierarchy_prop_num:=NULL;
ls_is_hierarchy:='N';
if li_hier_count > 0 then
ls_is_hierarchy := 'P';
end if;

END;    
--hierarchy budget type
BEGIN
SELECT  child_type_code INTO li_child_type_code FROM osp$eps_proposal_hierarchy@coeus.kuali WHERE child_proposal_number = (r_eps_proposal.PROPOSAL_NUMBER);
if   li_child_type_code=1 then
ls_hierarchy_bgt_typ:='B';
else
ls_hierarchy_bgt_typ:='P';
end if;     
EXCEPTION
WHEN OTHERS THEN
ls_hierarchy_bgt_typ:=NULL;   
END;    
-- proposal_type code
ls_proposal_type_cd := r_eps_proposal.PROPOSAL_TYPE_CODE;
/*
if    r_eps_proposal.PROPOSAL_TYPE_CODE=1 then
ls_proposal_type_cd:='1';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=3 then
ls_proposal_type_cd:='4';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=4 then
ls_proposal_type_cd:='5';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=5 then
ls_proposal_type_cd:='3';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=6 then
ls_proposal_type_cd:='2';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=9 then
ls_proposal_type_cd:='6';
end if; 
*/     
/*
mapping of coeus -Kc status code
				KC
4	Approved	13
3	Rejected	12
1	In Progress	1
2	Approval In Progress	2
5	Submitted	6
6	Post-Submission Approval	8
7	Post-Submission Rejection	9
8	Recalled	12
*/
	li_status_cd:=r_eps_proposal.CREATION_STATUS_CODE; 
	if    li_status_cd = 4 then li_status_cd := 13;
	elsif li_status_cd = 3 then li_status_cd := 12;
	elsif li_status_cd = 5 then li_status_cd := 6;
	elsif li_status_cd = 6 then li_status_cd := 8;
	elsif li_status_cd = 7 then li_status_cd := 9;
	elsif li_status_cd = 8 then li_status_cd := 12;
	end if;

	ls_cfda_num:=r_eps_proposal.CFDA_NUMBER;  

	if  ls_cfda_num IS NOT NULL then         
	select substr(trim(ls_cfda_num),1,2)||'.'||substr(trim(ls_cfda_num),3) into ls_cfda_num from dual;
	end if;

	BEGIN
	
	
	
	select to_number(r_eps_proposal.PROPOSAL_NUMBER) into ls_proposal_num from dual;    
	INSERT INTO EPS_PROPOSAL(PROPOSAL_NUMBER,SUBMIT_FLAG,IS_HIERARCHY,HIERARCHY_PROPOSAL_NUMBER,HIERARCHY_HASH_CODE,HIERARCHY_BUDGET_TYPE,PROGRAM_ANNOUNCEMENT_NUMBER,PROGRAM_ANNOUNCEMENT_TITLE,ACTIVITY_TYPE_CODE,REQUESTED_START_DATE_INITIAL,REQUESTED_START_DATE_TOTAL,REQUESTED_END_DATE_INITIAL,REQUESTED_END_DATE_TOTAL,DURATION_MONTHS,NUMBER_OF_COPIES,DEADLINE_DATE,DEADLINE_TYPE,MAILING_ADDRESS_ID,MAIL_BY,MAIL_TYPE,CARRIER_CODE_TYPE,CARRIER_CODE,MAIL_DESCRIPTION,MAIL_ACCOUNT_NUMBER,SUBCONTRACT_FLAG,NARRATIVE_STATUS,BUDGET_STATUS,OWNED_BY_UNIT,CREATE_TIMESTAMP,CREATE_USER,UPDATE_TIMESTAMP,UPDATE_USER,NSF_CODE,PRIME_SPONSOR_CODE,CFDA_NUMBER,AGENCY_PROGRAM_CODE,AGENCY_DIVISION_CODE,VER_NBR,DOCUMENT_NUMBER,PROPOSAL_TYPE_CODE,STATUS_CODE,CREATION_STATUS_CODE,BASE_PROPOSAL_NUMBER,CONTINUED_FROM,TEMPLATE_FLAG,ORGANIZATION_ID,PERFORMING_ORGANIZATION_ID,CURRENT_ACCOUNT_NUMBER,CURRENT_AWARD_NUMBER,TITLE,SPONSOR_CODE,SPONSOR_PROPOSAL_NUMBER,INTR_COOP_ACTIVITIES_FLAG,INTR_COUNTRY_LIST,OTHER_AGENCY_FLAG,NOTICE_OF_OPPORTUNITY_CODE,HIERARCHY_ORIG_CHILD_PROP_NBR,OBJ_ID,ANTICIPATED_AWARD_TYPE_CODE,PROPOSALNUMBER_GG,OPPORTUNITYID_GG)
	VALUES(ls_proposal_num,ls_submit_flag,ls_is_hierarchy,ls_hierarchy_prop_num,ls_hierarchy_hash_cd,ls_hierarchy_bgt_typ,r_eps_proposal.PROGRAM_ANNOUNCEMENT_NUMBER,r_eps_proposal.PROGRAM_ANNOUNCEMENT_TITLE,r_eps_proposal.ACTIVITY_TYPE_CODE,r_eps_proposal.REQUESTED_START_DATE_INITIAL,r_eps_proposal.REQUESTED_START_DATE_TOTAL,r_eps_proposal.REQUESTED_END_DATE_INITIAL,r_eps_proposal.REQUESTED_END_DATE_TOTAL,r_eps_proposal.DURATION_MONTHS,r_eps_proposal.NUMBER_OF_COPIES,r_eps_proposal.DEADLINE_DATE,r_eps_proposal.DEADLINE_TYPE,r_eps_proposal.MAILING_ADDRESS_ID,r_eps_proposal.MAIL_BY,r_eps_proposal.MAIL_TYPE,r_eps_proposal.CARRIER_CODE_TYPE,r_eps_proposal.CARRIER_CODE,r_eps_proposal.MAIL_DESCRIPTION,NULL,r_eps_proposal.SUBCONTRACT_FLAG,r_eps_proposal.NARRATIVE_STATUS,r_eps_proposal.BUDGET_STATUS,r_eps_proposal.OWNED_BY_UNIT,r_eps_proposal.CREATE_TIMESTAMP,r_eps_proposal.CREATE_USER,r_eps_proposal.UPDATE_TIMESTAMP,r_eps_proposal.UPDATE_USER,r_eps_proposal.NSF_CODE,r_eps_proposal.PRIME_SPONSOR_CODE,ls_cfda_num,r_eps_proposal.AGENCY_PROGRAM_CODE,r_eps_proposal.AGENCY_DIVISION_CODE,li_ver_nbr,ls_doc_nbr,ls_proposal_type_cd,li_status_cd,r_eps_proposal.CREATION_STATUS_CODE,r_eps_proposal.BASE_PROPOSAL_NUMBER,r_eps_proposal.CONTINUED_FROM,r_eps_proposal.TEMPLATE_FLAG,r_eps_proposal.ORGANIZATION_ID,r_eps_proposal.PERFORMING_ORGANIZATION_ID,r_eps_proposal.CURRENT_ACCOUNT_NUMBER,  REPLACE(trim(r_eps_proposal.CURRENT_AWARD_NUMBER),'-','-00'),SUBSTRB(r_eps_proposal.TITLE,1,150),r_eps_proposal.SPONSOR_CODE,r_eps_proposal.SPONSOR_PROPOSAL_NUMBER,r_eps_proposal.INTR_COOP_ACTIVITIES_FLAG,r_eps_proposal.INTR_COUNTRY_LIST,r_eps_proposal.OTHER_AGENCY_FLAG,r_eps_proposal.NOTICE_OF_OPPORTUNITY_CODE,ls_hierarchy_orig_child,SYS_GUID(),r_eps_proposal.AWARD_TYPE_CODE,null,null);

	EXCEPTION 
	WHEN OTHERS THEN
		dbms_output.put_line('Error while inserting proposal(EPS_PROPOSAL) '||r_eps_proposal.PROPOSAL_NUMBER||' and exception is '||substr(sqlerrm,1,200));
	END;


	select Max(DOC_TYP_ID) into li_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='ProposalDevelopmentDocument';


BEGIN     

	ll_crte_dt:=r_eps_proposal.CREATE_TIMESTAMP; 
	ls_title:='Proposal Development Document - '||ls_proposal_num;      
	begin
	select PRNCPL_ID into ls_initr_prncpl_id from  KRIM_PRNCPL_T where LOWER(PRNCPL_NM) = LOWER(r_eps_proposal.CREATE_USER);
	exception when others then
	ls_initr_prncpl_id:='unknownuser';
	end;         

	li_krew_rnt_node_active := 0;
	li_krew_rnt_node_complt := 1;

	IF    r_eps_proposal.CREATION_STATUS_CODE=1 OR r_eps_proposal.CREATION_STATUS_CODE=8 THEN 
	ls_doc_hdr_stat_cd:='S';
	li_krew_rnt_node_active := 1;
	li_krew_rnt_node_complt := 0;
	ELSIF r_eps_proposal.CREATION_STATUS_CODE=2 OR r_eps_proposal.CREATION_STATUS_CODE=3 OR r_eps_proposal.CREATION_STATUS_CODE=4 OR r_eps_proposal.CREATION_STATUS_CODE=5 THEN 
	ls_doc_hdr_stat_cd:='R';
	ELSIF r_eps_proposal.CREATION_STATUS_CODE=6 THEN 
	ls_doc_hdr_stat_cd:='P';
	ELSIF r_eps_proposal.CREATION_STATUS_CODE=7 THEN 
	ls_doc_hdr_stat_cd:='D';
	END IF; 

	ls_budget_status :=r_eps_proposal.BUDGET_STATUS; 
	if    ls_budget_status ='C' then
	li_budget_status_cd:=1;
	elsif ls_budget_status ='I' then
	li_budget_status_cd:=2;
	elsif ls_budget_status ='N' then
	li_budget_status_cd:=null;       
	else
	li_budget_status_cd:=null;
	end if;  

	INSERT INTO EPS_PROPOSAL_BUDGET_STATUS(PROPOSAL_NUMBER,BUDGET_STATUS_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	VALUES(to_number(r_eps_proposal.PROPOSAL_NUMBER),li_budget_status_cd,r_eps_proposal.UPDATE_TIMESTAMP,r_eps_proposal.UPDATE_USER,li_ver_nbr,SYS_GUID());

	INSERT INTO KREW_DOC_HDR_T(DOC_HDR_ID,DOC_TYP_ID,DOC_HDR_STAT_CD,RTE_LVL,STAT_MDFN_DT,CRTE_DT,APRV_DT,FNL_DT,RTE_STAT_MDFN_DT,TTL,APP_DOC_ID,DOC_VER_NBR,INITR_PRNCPL_ID,VER_NBR,RTE_PRNCPL_ID,DTYPE,OBJ_ID,APP_DOC_STAT,APP_DOC_STAT_MDFN_DT)
	VALUES(ls_doc_nbr,li_doc_typ_id,ls_doc_hdr_stat_cd,li_rte_lvl,ll_stat_mdfn_dt,ll_crte_dt,ll_aprv_dt,ll_fnl_dt,ll_rt_stat_mdfn_dt,ls_title,ls_app_doc_id,li_doc_ver_nbr,ls_initr_prncpl_id,li_krew_ver_nbr,ls_rte_prncpl_id,ls_dtype,sys_guid(),ls_app_doc_stat,ls_app_doc_stat_mdfn_dt);

	INSERT INTO KRNS_DOC_HDR_T(DOC_HDR_ID,OBJ_ID,VER_NBR,FDOC_DESC,ORG_DOC_HDR_ID,TMPL_DOC_HDR_ID,EXPLANATION)
	VALUES(ls_doc_nbr,SYS_GUID(),li_doc_ver_nbr,ls_proposal_num,NULL,NULL,NULL);

	INSERT INTO KREW_DOC_HDR_CNTNT_T(DOC_HDR_ID,DOC_CNTNT_TXT)
	VALUES(ls_doc_nbr,NULL);    


	---- KREW------------
	select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_brch from dual ;
	select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_node from dual ;
	select KREW_RTE_NODE_S.NEXTVAL into li_krew_rne_node_instn from dual ;
	select KREW_ACTN_RQST_S.NEXTVAL into li_krew_actn_rqst from dual ;
	select KREW_ACTN_TKN_S.NEXTVAL into li_krew_actn_tkn from dual ;

	INSERT INTO KREW_RTE_BRCH_T(RTE_BRCH_ID,NM,PARNT_ID,INIT_RTE_NODE_INSTN_ID,SPLT_RTE_NODE_INSTN_ID,JOIN_RTE_NODE_INSTN_ID,VER_NBR)
	VALUES(li_krew_rnt_brch,'PRIMARY',NULL,NULL,NULL,NULL,1);

	INSERT INTO KREW_RTE_NODE_T(RTE_NODE_ID,DOC_TYP_ID,NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,FNL_APRVR_IND,MNDTRY_RTE_IND,ACTVN_TYP,BRCH_PROTO_ID,VER_NBR,CONTENT_FRAGMENT,GRP_ID,NEXT_DOC_STAT)
	VALUES(li_krew_rnt_node,li_doc_typ_id,'Initiated','org.kuali.rice.kew.engine.node.InitialNode',null,null,0,0,'P',null,1,null,null,null);

	INSERT INTO KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,DOC_HDR_ID,RTE_NODE_ID,BRCH_ID,PROC_RTE_NODE_INSTN_ID,ACTV_IND,CMPLT_IND,INIT_IND,VER_NBR)
	VALUES(li_krew_rne_node_instn,ls_doc_nbr,li_krew_rnt_node,li_krew_rnt_brch,NULL,li_krew_rnt_node_active,li_krew_rnt_node_complt,0,1);

	INSERT INTO KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,RTE_NODE_INSTN_ID)
	VALUES(ls_doc_nbr,li_krew_rne_node_instn);


	INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
	VALUES(li_krew_actn_rqst,NULL,'C',ls_doc_nbr,NULL,'A',-3,ls_initr_prncpl_id,NULL,NULL,NULL,'U',0,NULL,0,li_krew_rne_node_instn,NULL,1,SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1	,0,NULL,NULL);

	INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
	VALUES(li_krew_actn_tkn,ls_doc_nbr,ls_initr_prncpl_id,NULL,'S',SYSDATE,1,NULL,1,1,NULL);	

	EXCEPTION 
	WHEN OTHERS THEN     
	dbms_output.put_line('Error while inserting into KREW_DOC_HDR_T  '||ls_proposal_num||' and exception is '||substr(sqlerrm,1,200));
	END; 
------------------- KREW-------------------- 

END LOOP;
CLOSE c_eps_proposal;  
execute immediate('ALTER TABLE EPS_PROPOSAL ENABLE CONSTRAINT EPS_PROPOSAL_FK1');

dbms_output.put_line(CHR(10)); 
dbms_output.put_line('Successfully inserted EPS_PROPOSAL and EPS_PROPOSAL_DOCUMENT ');
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('Error while inserting to EPS_PROPOSAL or EPS_PROPOSAL_DOCUMENT  and exception is '||substr(sqlerrm,1,200));
END;
/ 
DECLARE
ls_prncpl_nm VARCHAR2(100);
ls_mbr_id VARCHAR2(40);
ls_role_id VARCHAR2(40);

CURSOR c_doc IS
SELECT t1.proposal_number,t1.document_number
from eps_proposal t1 inner join temp_tab_to_sync_dev t2 on t1.proposal_number = t2.proposal_number 
where t2.feed_type = 'N' ;
r_doc c_doc%rowtype;

BEGIN

	IF c_doc%isopen THEN
	CLOSE c_doc;
	END IF;
	OPEN c_doc;
	LOOP
	FETCH c_doc INTO r_doc;
	EXIT WHEN c_doc%NOTFOUND;



			BEGIN
			select role_id into ls_role_id from krim_role_t where upper(role_nm)=upper('aggregator');

			select kt.mbr_id into ls_mbr_id from krim_role_mbr_t kt ,krim_role_mbr_attr_data_t kat
			where kt.role_mbr_id=kat.role_mbr_id
			and kt.role_id=ls_role_id
			and kat.attr_val=r_doc.proposal_number
			and rownum=1;
			EXCEPTION
			WHEN OTHERS THEN
			ls_mbr_id:=NULL;
			END;

			IF ls_mbr_id IS NOT NULL THEN
			select prncpl_nm into ls_prncpl_nm from krim_prncpl_t where prncpl_id=ls_mbr_id;
			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'aggregator',ls_prncpl_nm);
			ELSE

			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'aggregator',null);

			END IF;
			-----------------------------------------------------------

			BEGIN
			select role_id into ls_role_id from krim_role_t where upper(role_nm)=upper('budget Creator');
			select kt.mbr_id into ls_mbr_id from krim_role_mbr_t kt ,krim_role_mbr_attr_data_t kat
			where kt.role_mbr_id=kat.role_mbr_id
			and kt.role_id=ls_role_id
			and kat.attr_val=r_doc.proposal_number
			and rownum=1;
			EXCEPTION
			WHEN OTHERS THEN
			ls_mbr_id:=NULL;
			END;
			IF ls_mbr_id IS NOT NULL THEN

			select prncpl_nm into ls_prncpl_nm from krim_prncpl_t where prncpl_id=ls_mbr_id;
			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'budgetCreator',ls_prncpl_nm);

			ELSE

			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'budgetCreator',null);

			END IF;
			----------------------------------------------------------------------------------------------------------

			BEGIN
			select role_id into ls_role_id from krim_role_t where upper(role_nm)=upper('narrative Writer');
			select kt.mbr_id into ls_mbr_id from krim_role_mbr_t kt ,krim_role_mbr_attr_data_t kat
			where kt.role_mbr_id=kat.role_mbr_id
			and kt.role_id=ls_role_id
			and kat.attr_val=r_doc.proposal_number
			and rownum=1;
			EXCEPTION
			WHEN OTHERS THEN
			ls_mbr_id:=NULL;
			END;
			IF ls_mbr_id IS NOT NULL THEN

			select prncpl_nm into ls_prncpl_nm from krim_prncpl_t where prncpl_id=ls_mbr_id;
			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'narrativeWriter',ls_prncpl_nm);

			ELSE

			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'narrativeWriter',null);
			END IF;
			--------------------------------------------------------------------------------------------------

			BEGIN
			select role_id into ls_role_id from krim_role_t where upper(role_nm)=upper('viewer');
			select kt.mbr_id into ls_mbr_id from krim_role_mbr_t kt ,krim_role_mbr_attr_data_t kat
			where kt.role_mbr_id=kat.role_mbr_id
			and kt.role_id=ls_role_id
			and kat.attr_val=r_doc.proposal_number
			and rownum=1;
			EXCEPTION
			WHEN OTHERS THEN
			ls_mbr_id:=NULL;
			END;
			IF ls_mbr_id IS NOT NULL THEN

			select prncpl_nm into ls_prncpl_nm from krim_prncpl_t where prncpl_id=ls_mbr_id;
			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'viewer',ls_prncpl_nm);

			ELSE

			INSERT INTO KREW_DOC_HDR_EXT_T(DOC_HDR_EXT_ID,DOC_HDR_ID,KEY_CD,VAL)
			VALUES(KREW_DOC_HDR_S.NEXTVAL,r_doc.document_number,'viewer',null);
			END IF;

	END LOOP;
	CLOSE c_doc;
END;
/
declare
li_count number;
ls_proposal_max varchar2(12);
ls_question_max NUMBER(6,0);
ls_questionnaire_max NUMBER(6,0);
li_proposal_max number(10);
ls_query VARCHAR2(400);
li_num NUMBER;
begin

select max(to_number(proposal_number)) into ls_proposal_max from eps_proposal;
SELECT TO_NUMBER(ls_proposal_max) INTO li_proposal_max  FROM DUAL;
SELECT SEQ_PROPOSAL_NUMBER_KRA.NEXTVAL into li_num FROM DUAL;
li_proposal_max:=li_proposal_max - li_num;
ls_query:='alter sequence SEQ_PROPOSAL_NUMBER_KRA increment by '||li_proposal_max;      
execute immediate(ls_query);  

end;
/
select SEQ_PROPOSAL_NUMBER_KRA.NEXTVAL from dual
/
alter sequence SEQ_PROPOSAL_NUMBER_KRA increment by 1
/
select ' End time of insert to EPS_PROPOSAL is ' from dual
/
commit
/