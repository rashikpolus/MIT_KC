select ' Started BUDGET  ' from dual
/
DECLARE
li_ver_nbr number(8):=1;
li_seq_budget_id number(12);
ls_document_number varchar2(40);
li_version_number number(3);
ll_bgt_justi_long long;
ll_bgt_justi_clob clob;
li_doc_typ_id NUMBER(19,0); 
ls_doc_hdr_stat_cd VARCHAR2(1):='F';
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
ls_doc_nbr VARCHAR2(40);
li_count_eps_prop_bud_ext number;
li_count_bud_doc number;
li_count_bud number;
ls_update_user	VARCHAR2(60);
ls_proposal_number VARCHAR2(12);
ls_organization VARCHAR2(8);
ls_organization_name VARCHAR2(60);
ls_hierarchy_proposal_number varchar2(12):=null;
ls_hide_in_hierarchy  char(1):='n';
ls_rte_brch_id VARCHAR2(40);
ls_rte_node_id VARCHAR2(40);
ls_rte_node_instn_id VARCHAR2(40);
ls_doc_typ_id VARCHAR2(40);
ls_prncpl_id krim_prncpl_t.PRNCPL_ID%type;
li_seq_sub_awd_bgt_att_id NUMBER(12,0);
ls_budget_status eps_proposal.proposal_number%type;

CURSOR c_budget IS 
SELECT t1.PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.ON_OFF_CAMPUS_FLAG,t1.START_DATE,END_DATE,t1.TOTAL_COST,t1.TOTAL_DIRECT_COST,
t1.TOTAL_INDIRECT_COST,t1.COST_SHARING_AMOUNT,t1.UNDERRECOVERY_AMOUNT,t1.RESIDUAL_FUNDS,t1.TOTAL_COST_LIMIT,t1.OH_RATE_CLASS_CODE,
t1.OH_RATE_TYPE_CODE,t1.COMMENTS,t1.FINAL_VERSION_FLAG,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,t1.UR_RATE_CLASS_CODE,t1.MODULAR_BUDGET_FLAG,
t1.TOTAL_DIRECT_COST_LIMIT,t1.SUBMIT_COST_SHARING_FLAG 
FROM OSP$BUDGET@coeus.kuali t1 
inner join TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;

r_budget c_budget%ROWTYPE;

BEGIN
IF c_budget%ISOPEN THEN
CLOSE c_budget;
END IF;

  OPEN c_budget; 
  LOOP 
  FETCH c_budget INTO r_budget;
  EXIT WHEN c_budget%NOTFOUND;
  
  select to_number(r_budget.PROPOSAL_NUMBER) into ls_proposal_number from dual;
  li_version_number:=r_budget.VERSION_NUMBER;
  
  
		begin
			select bj.BUDGET_JUSTIFICATION into ll_bgt_justi_long from OSP$BUDGET_JUSTIFICATION@coeus.kuali bj where bj.proposal_number=r_budget.PROPOSAL_NUMBER and bj.version_number=r_budget.VERSION_NUMBER; 
			select to_char(ll_bgt_justi_long) into ll_bgt_justi_clob from dual;
		exception when others then
			ll_bgt_justi_clob:=null;
		end;
  /* Commented this now obsolete
  select count(DOCUMENT_NUMBER) into li_count_bud_doc from BUDGET_DOCUMENT 
  where PARENT_DOCUMENT_KEY in (select document_number from eps_proposal where proposal_number = ls_proposal_number )
  and   VER_NBR = li_version_number;
  */
	select count(t1.budget_id) into li_count_bud_doc  from budget t1 
	inner join eps_proposal_budget_ext t2 on t1.budget_id = t2.budget_id
	where t2.proposal_number = ls_proposal_number
	and t1.version_number = li_version_number; 
  
  
  
 ------------ I N S E R T 
    if li_count_bud_doc = 0 then 
	
	  
		SELECT KREW_DOC_HDR_S.NEXTVAL INTO ls_doc_nbr FROM DUAL;
		SELECT SEQ_BUDGET_ID.NEXTVAL INTO li_seq_budget_id FROM DUAL;
		SELECT SEQ_SUB_AWD_BGT_ATT_ID.NEXTVAL INTO li_seq_sub_awd_bgt_att_id FROM DUAL;
		

		BEGIN
			
			
			begin
				SELECT DOCUMENT_NUMBER INTO ls_document_number  FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_proposal_number;
			exception
			when others then
			dbms_output.put_line('Error in PROPOSAL_NUMBER:'||ls_proposal_number||'and the error is'||substr(sqlerrm,1,100));
			end;
			
			INSERT INTO BUDGET_DOCUMENT(DOCUMENT_NUMBER,PARENT_DOCUMENT_KEY,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,PARENT_DOCUMENT_TYPE_CODE,OBJ_ID,BUDGET_DELETED)
			VALUES(ls_doc_nbr,ls_document_number,li_version_number,r_budget.UPDATE_TIMESTAMP,r_budget.UPDATE_USER,'PRDV',SYS_GUID(),'N');
			  
			INSERT INTO BUDGET(BUDGET_ID,BUDGET_JUSTIFICATION,ON_OFF_CAMPUS_FLAG,VERSION_NUMBER,DOCUMENT_NUMBER,START_DATE,END_DATE,TOTAL_COST,TOTAL_DIRECT_COST,TOTAL_INDIRECT_COST,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,RESIDUAL_FUNDS,TOTAL_COST_LIMIT,OH_RATE_CLASS_CODE,OH_RATE_TYPE_CODE,COMMENTS,FINAL_VERSION_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,UR_RATE_CLASS_CODE,MODULAR_BUDGET_FLAG,VER_NBR,OBJ_ID,TOTAL_DIRECT_COST_LIMIT,SUBMIT_COST_SHARING,PARENT_DOCUMENT_TYPE_CODE)
			VALUES(li_seq_budget_id,ll_bgt_justi_clob,r_budget.ON_OFF_CAMPUS_FLAG,li_version_number,ls_doc_nbr,r_budget.START_DATE,r_budget.END_DATE,r_budget.TOTAL_COST,r_budget.TOTAL_DIRECT_COST,r_budget.TOTAL_INDIRECT_COST,r_budget.COST_SHARING_AMOUNT,r_budget.UNDERRECOVERY_AMOUNT,r_budget.RESIDUAL_FUNDS,r_budget.TOTAL_COST_LIMIT,r_budget.OH_RATE_CLASS_CODE,r_budget.OH_RATE_TYPE_CODE,r_budget.COMMENTS,r_budget.FINAL_VERSION_FLAG,r_budget.UPDATE_TIMESTAMP,r_budget.UPDATE_USER,r_budget.UR_RATE_CLASS_CODE,r_budget.MODULAR_BUDGET_FLAG,li_ver_nbr,SYS_GUID(),r_budget.TOTAL_DIRECT_COST_LIMIT,r_budget.SUBMIT_COST_SHARING_FLAG,'PRDV');
			
			INSERT INTO BUDGET_SUB_AWARDS(SUB_AWARD_NUMBER, ORGANIZATION_ID, SUB_AWARD_STATUS_CODE, SUB_AWARD_XFD_FILE_NAME, COMMENTS,XFD_UPDATE_USER, XFD_UPDATE_TIMESTAMP, TRANSLATION_COMMENTS, XML_UPDATE_USER, XML_UPDATE_TIMESTAMP
            , UPDATE_TIMESTAMP, UPDATE_USER , VER_NBR, OBJ_ID
            , BUDGET_ID, HIERARCHY_PROPOSAL_NUMBER, HIDE_IN_HIERARCHY
            , SUB_AWARD_XFD_FILE, SUB_AWARD_XML_FILE, NAMESPACE, FORM_NAME) 
			SELECT SUB_AWARD_NUMBER,			
			(SELECT ORGANIZATION_ID  FROM ORGANIZATION_MAPPING WHERE SUBAWARD_ORGANIZATION_NAME = TEMP_BUD_SUB_AWD.ORGANIZATION_NAME AND rownum=1),			
			SUB_AWARD_STATUS_CODE, nvl(SUB_AWARD_XFD_FILE_NAME,'dummy'),COMMENTS,XFD_UPDATE_USER,XFD_UPDATE_TIMESTAMP,TRANSLATION_COMMENTS,XML_UPDATE_USER,XML_UPDATE_TIMESTAMP
			,UPDATE_TIMESTAMP, UPDATE_USER,1,SYS_GUID()
			,li_seq_budget_id,ls_hierarchy_proposal_number,ls_hide_in_hierarchy
			,nvl(SUB_AWARD_XFD_FILE,EMPTY_BLOB()) SUB_AWARD_XFD_FILE,SUB_AWARD_XML_FILE,NAMESPACE,FORM_NAME FROM TEMP_BUD_SUB_AWD
			WHERE PROPOSAL_NUMBER=r_budget.PROPOSAL_NUMBER AND VERSION_NUMBER=r_budget.VERSION_NUMBER;
			
			INSERT INTO BUDGET_SUB_AWARD_FILES(SUB_AWARD_NUMBER, SUB_AWARD_XFD_FILE_NAME, UPDATE_TIMESTAMP, UPDATE_USER,  SUB_AWARD_XFD_FILE, SUB_AWARD_XML_FILE
            ,VER_NBR,OBJ_ID,BUDGET_ID) 
			SELECT t1.SUB_AWARD_NUMBER,nvl(t1.SUB_AWARD_XFD_FILE_NAME,'dummy'),t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,nvl(t1.SUB_AWARD_XFD_FILE,EMPTY_BLOB()),t1.SUB_AWARD_XML_FILE,
			1, SYS_GUID(),li_seq_budget_id FROM TEMP_BUD_SUB_AWD t1
			WHERE t1.PROPOSAL_NUMBER=r_budget.PROPOSAL_NUMBER AND t1.VERSION_NUMBER=r_budget.VERSION_NUMBER;
			
			INSERT INTO BUDGET_SUB_AWARD_ATT(SUB_AWARD_ATTACHMENT_ID,SUB_AWARD_NUMBER,CONTENT_ID,CONTENT_TYPE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,BUDGET_ID,ATTACHMENT,OBJ_ID)
			SELECT li_seq_sub_awd_bgt_att_id,SUB_AWARD_NUMBER,CONTENT_ID,CONTENT_TYPE,UPDATE_TIMESTAMP,UPDATE_USER ,1,li_seq_budget_id,ATTACHMENT,SYS_GUID() FROM TEMP_BUD_SUB_AWD_ATT
			WHERE PROPOSAL_NUMBER=r_budget.PROPOSAL_NUMBER AND VERSION_NUMBER=r_budget.VERSION_NUMBER;
            
			begin
				select BUDGET_STATUS into ls_budget_status FROM EPS_PROPOSAL 
				WHERE PROPOSAL_NUMBER = to_number(r_budget.PROPOSAL_NUMBER);				
			exception
			when others then
				ls_budget_status := 'C';
			end;	
			
			INSERT INTO EPS_PROPOSAL_BUDGET_EXT(BUDGET_ID,FINAL_VERSION_FLAG,HIERARCHY_HASH_CODE,PROPOSAL_NUMBER,STATUS_CODE)
			VALUES(li_seq_budget_id,r_budget.FINAL_VERSION_FLAG,NULL,to_number(r_budget.PROPOSAL_NUMBER),ls_budget_status);

			INSERT INTO TEMP_BUDGET_MAIN(BUDGET_ID,BUDGET_DOC_NUM,BUDGET_VER_NUM,PROPOSAL_DOC_NUM,PROPOSAL_NUM)
			VALUES(li_seq_budget_id,ls_doc_nbr,li_version_number,ls_document_number,r_budget.PROPOSAL_NUMBER);

	
			SELECT KREW_RTE_NODE_S.NEXTVAL INTO ls_rte_brch_id FROM DUAL;
			SELECT KREW_RTE_NODE_S.NEXTVAL INTO ls_rte_node_id FROM DUAL;
			SELECT KREW_RTE_NODE_S.NEXTVAL INTO ls_rte_node_instn_id FROM DUAL;
			select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='BudgetDocument';
			
			begin
			select PRNCPL_ID into ls_prncpl_id from KRIM_PRNCPL_T where lower(PRNCPL_NM) = LOWER(r_budget.UPDATE_USER);
			exception
			when others then
				ls_prncpl_id := 'unknownuser';
			end;
			
			
			INSERT INTO KREW_DOC_HDR_T(DOC_HDR_ID,DOC_TYP_ID,DOC_HDR_STAT_CD,RTE_LVL,STAT_MDFN_DT,CRTE_DT,APRV_DT,FNL_DT,RTE_STAT_MDFN_DT,TTL,APP_DOC_ID,DOC_VER_NBR,INITR_PRNCPL_ID,VER_NBR,RTE_PRNCPL_ID,DTYPE,OBJ_ID,APP_DOC_STAT,APP_DOC_STAT_MDFN_DT)
			VALUES(ls_doc_nbr,ls_doc_typ_id,'F',0,sysdate,sysdate,sysdate,null,sysdate,('BudgetDocument - '||ls_doc_nbr),null,1,ls_prncpl_id,1,null,null,sys_guid(),null,null);
			

			INSERT INTO KRNS_DOC_HDR_T(DOC_HDR_ID,OBJ_ID,VER_NBR,FDOC_DESC,ORG_DOC_HDR_ID,TMPL_DOC_HDR_ID,EXPLANATION)
			values(ls_doc_nbr,SYS_GUID(),1,ls_proposal_number,NULL,NULL,NULL);
					
			  
			INSERT INTO KREW_DOC_HDR_CNTNT_T(DOC_HDR_ID,DOC_CNTNT_TXT)
			VALUES(ls_doc_nbr,null);
			
			INSERT INTO KREW_RTE_BRCH_T(RTE_BRCH_ID,NM,PARNT_ID,INIT_RTE_NODE_INSTN_ID,SPLT_RTE_NODE_INSTN_ID,JOIN_RTE_NODE_INSTN_ID,VER_NBR)
			VALUES(ls_rte_brch_id,'PRIMARY',NULL,NULL,NULL,NULL,1);
			

			INSERT INTO KREW_RTE_NODE_T(RTE_NODE_ID,DOC_TYP_ID,NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,FNL_APRVR_IND,MNDTRY_RTE_IND,ACTVN_TYP,BRCH_PROTO_ID,VER_NBR,CONTENT_FRAGMENT,GRP_ID,NEXT_DOC_STAT)
			VALUES(ls_rte_node_id,ls_doc_typ_id,'Initiated','org.kuali.rice.kew.engine.node.InitialNode',null,null,0,0,'P',null,1,null,null,null);
			
			
			INSERT INTO KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,DOC_HDR_ID,RTE_NODE_ID,BRCH_ID,PROC_RTE_NODE_INSTN_ID,ACTV_IND,CMPLT_IND,INIT_IND,VER_NBR)
			VALUES(ls_rte_node_instn_id,ls_doc_nbr,ls_rte_node_id,ls_rte_brch_id,NULL,1,0,0,1);

			INSERT INTO KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,RTE_NODE_INSTN_ID)
			VALUES(ls_doc_nbr,ls_rte_node_instn_id);

			INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
			VALUES(KREW_ACTN_RQST_S.NEXTVAL,NULL,'C',ls_doc_nbr,NULL,'A',-3,ls_prncpl_id,NULL,NULL,NULL,'U',0,NULL,0,ls_rte_node_instn_id,NULL,1,
			SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1	,0,NULL,NULL);
			
			INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
			VALUES( KREW_ACTN_TKN_S.NEXTVAL,ls_doc_nbr,ls_prncpl_id,NULL,'S',SYSDATE,1,NULL,1,1,NULL);
			
			
		EXCEPTION   
		WHEN OTHERS THEN                   
			dbms_output.put_line('Error in BUDGET , proposal number '||r_budget.PROPOSAL_NUMBER||substr(sqlerrm,1,200));			
		END;
		
 ------------ U P D A T E		
else

	UPDATE BUDGET SET 
	BUDGET_JUSTIFICATION = ll_bgt_justi_clob,
	ON_OFF_CAMPUS_FLAG = r_budget.ON_OFF_CAMPUS_FLAG,
	START_DATE	= r_budget.START_DATE,
	END_DATE	= r_budget.END_DATE	,
	TOTAL_COST	= r_budget.TOTAL_COST,
	TOTAL_DIRECT_COST = r_budget.TOTAL_DIRECT_COST,
	TOTAL_INDIRECT_COST 	= r_budget.TOTAL_INDIRECT_COST,
	COST_SHARING_AMOUNT = r_budget.COST_SHARING_AMOUNT,
	UNDERRECOVERY_AMOUNT = r_budget.UNDERRECOVERY_AMOUNT,
	RESIDUAL_FUNDS = r_budget.RESIDUAL_FUNDS,
	TOTAL_COST_LIMIT = r_budget.TOTAL_COST_LIMIT,
	OH_RATE_CLASS_CODE = r_budget.OH_RATE_CLASS_CODE,
	OH_RATE_TYPE_CODE = r_budget.OH_RATE_TYPE_CODE,
	COMMENTS = r_budget.COMMENTS,
	FINAL_VERSION_FLAG = r_budget.FINAL_VERSION_FLAG,
	UPDATE_TIMESTAMP = r_budget.UPDATE_TIMESTAMP,
	UPDATE_USER = r_budget.UPDATE_USER,
	UR_RATE_CLASS_CODE = r_budget.UR_RATE_CLASS_CODE,
	MODULAR_BUDGET_FLAG = r_budget.MODULAR_BUDGET_FLAG,
	TOTAL_DIRECT_COST_LIMIT = r_budget.TOTAL_DIRECT_COST_LIMIT,
	SUBMIT_COST_SHARING = r_budget.SUBMIT_COST_SHARING_FLAG
	WHERE   DOCUMENT_NUMBER in (
								select DOCUMENT_NUMBER from BUDGET_DOCUMENT 
								where PARENT_DOCUMENT_KEY in (select document_number from eps_proposal where proposal_number = ls_proposal_number )
								and   VER_NBR = li_version_number
							   );
	/*
	UPDATE EPS_PROPOSAL_BUDGET_EXT
	SET FINAL_VERSION_FLAG = r_budget.FINAL_VERSION_FLAG
	WHERE   BUDGET_ID in (SELECT BUDGET_ID FROM BUDGET WHERE DOCUMENT_NUMBER IN(
							select DOCUMENT_NUMBER from BUDGET_DOCUMENT
							where PARENT_DOCUMENT_KEY in (select document_number from eps_proposal where proposal_number = ls_proposal_number )
							and   VER_NBR = li_version_number)
						   );
	*/
	
	begin
		select BUDGET_STATUS into ls_budget_status FROM EPS_PROPOSAL 
		WHERE PROPOSAL_NUMBER = ls_proposal_number;		
	exception
	when others then
		ls_budget_status := 'C';
	end;	
	
	UPDATE EPS_PROPOSAL_BUDGET_EXT
	SET FINAL_VERSION_FLAG = r_budget.FINAL_VERSION_FLAG,
	STATUS_CODE = ls_budget_status
	WHERE BUDGET_ID IN (
		select t1.budget_id  from budget t1 
		inner join eps_proposal_budget_ext t2 on t1.budget_id = t2.budget_id
		where t2.proposal_number = ls_proposal_number
		and t1.version_number = li_version_number);

		
		
			
	
	
end if;



END LOOP;
CLOSE c_budget;     

END;
/
select ' Ended BUDGET  ' from dual
/