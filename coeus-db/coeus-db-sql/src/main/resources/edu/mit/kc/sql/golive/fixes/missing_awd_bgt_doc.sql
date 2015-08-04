set serveroutput on;
CREATE TABLE TMP_AWD_BGT_MISSING_DOC(
BUDGET_ID       NUMBER(12),
DOCUMENT_NUMBER VARCHAR2(40)  
)
/
declare 
	ls_rte_node_id NUMBER(19,0);
	ls_rte_brch_id NUMBER(19,0);
	ls_rte_node_instn_id NUMBER(19,0);	
	ls_doc_typ_id varchar2(40);
	ls_doc_nbr BUDGET_DOCUMENT.DOCUMENT_NUMBER%type;
	ls_prncpl_id VARCHAR2(40);
	ls_doc_status VARCHAR2(1) := 'S';
cursor c_awd_bug_doc is
	select t1.budget_id,t1.update_timestamp,t1.update_user,t1.budget_initiator
	from award_budget_ext t1 where t1.DOCUMENT_NUMBER is null;
	r_awd_bug_doc c_awd_bug_doc%rowtype;
begin

     if c_awd_bug_doc%isopen then
	    close c_awd_bug_doc;
	 end if;
	 
	 open c_awd_bug_doc;
	 loop
	 fetch c_awd_bug_doc into r_awd_bug_doc;
	 exit when c_awd_bug_doc%notfound;
	 BEGIN
			
			SELECT KREW_DOC_HDR_S.NEXTVAL INTO ls_doc_nbr FROM DUAL;
			
			INSERT INTO TMP_AWD_BGT_MISSING_DOC(BUDGET_ID,DOCUMENT_NUMBER)
			VALUES(r_awd_bug_doc.budget_id,ls_doc_nbr);		
			
			INSERT INTO BUDGET_DOCUMENT(DOCUMENT_NUMBER,PARENT_DOCUMENT_KEY,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,PARENT_DOCUMENT_TYPE_CODE,
			OBJ_ID,BUDGET_DELETED)
			VALUES(ls_doc_nbr,null,1,r_awd_bug_doc.update_timestamp,r_awd_bug_doc.update_user,null,sys_guid(),null);
								  
			UPDATE	award_budget_ext set DOCUMENT_NUMBER = ls_doc_nbr
			WHERE budget_id = r_awd_bug_doc.budget_id;
			
			UPDATE	budget set DOCUMENT_NUMBER = ls_doc_nbr
			WHERE budget_id = r_awd_bug_doc.budget_id;
			
			--- KREW TABLE STARTED	
			SELECT KREW_RTE_NODE_S.NEXTVAL INTO ls_rte_brch_id FROM DUAL;
			SELECT KREW_RTE_NODE_S.NEXTVAL INTO ls_rte_node_id FROM DUAL;
			SELECT KREW_RTE_NODE_S.NEXTVAL INTO ls_rte_node_instn_id FROM DUAL;
			select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM = 'AwardBudgetDocument';			
			
			ls_prncpl_id := r_awd_bug_doc.budget_initiator;	
			
			INSERT INTO KREW_DOC_HDR_T(DOC_HDR_ID,DOC_TYP_ID,DOC_HDR_STAT_CD,RTE_LVL,STAT_MDFN_DT,CRTE_DT,APRV_DT,FNL_DT,RTE_STAT_MDFN_DT,TTL,APP_DOC_ID,DOC_VER_NBR,INITR_PRNCPL_ID,VER_NBR,RTE_PRNCPL_ID,DTYPE,OBJ_ID,APP_DOC_STAT,APP_DOC_STAT_MDFN_DT)
			VALUES(ls_doc_nbr,ls_doc_typ_id,ls_doc_status,0,sysdate,sysdate,sysdate,null,sysdate,('Award BudgetDocument - '||ls_doc_nbr),null,1,ls_prncpl_id,1,null,null,sys_guid(),null,null);
			
			INSERT INTO KRNS_DOC_HDR_T(DOC_HDR_ID,OBJ_ID,VER_NBR,FDOC_DESC,ORG_DOC_HDR_ID,TMPL_DOC_HDR_ID,EXPLANATION)
			values(ls_doc_nbr,SYS_GUID(),1,r_awd_bug_doc.budget_id,NULL,NULL,NULL);			
			  
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

			INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,
			RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
			VALUES(KREW_ACTN_RQST_S.NEXTVAL,NULL,'C',ls_doc_nbr,NULL,'A',-3,ls_prncpl_id,NULL,NULL,NULL,'U',0,NULL,0,ls_rte_node_instn_id,NULL,1,
			SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1	,0,NULL,NULL);
			
			INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
			VALUES( KREW_ACTN_TKN_S.NEXTVAL,ls_doc_nbr,ls_prncpl_id,NULL,'S',SYSDATE,1,NULL,1,1,NULL);
			
		--- KREW TABLE END	
		EXCEPTION   
		WHEN OTHERS THEN                   
			dbms_output.put_line('Error occoured , proposal number '||r_awd_bug_doc.budget_id||substr(sqlerrm,1,200));			
		END;
	 	 		
	 end loop;
	 close c_awd_bug_doc;
end;
/