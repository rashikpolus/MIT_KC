CREATE TABLE MISSING_AWARD_BUDGET (
AWARD_NUMBER VARCHAR2(12),
SEQUENCE_NUMBER NUMBER(4),
FROM_SEQUENCE NUMBER(4),
COPY_BUDGET_ID NUMBER(12),
NEW_BUDGET_ID  NUMBER(12)
)
/
INSERT INTO MISSING_AWARD_BUDGET(AWARD_NUMBER,SEQUENCE_NUMBER,FROM_SEQUENCE)
select a0.award_number , a0.sequence_number, a1.sequence_number as from_sequence  
from  award a0
inner join
(
    select t0.award_number , max(t0.sequence_number) sequence_number from 
    (
    select t1.award_number , t1.sequence_number
    from award t1 inner join award_budget_ext t2 on t1.award_id = t2.award_id
    ) t0 group by t0.award_number order by t0.award_number
) a1 
on a0.award_number = a1.award_number and a0.sequence_number > a1.sequence_number
ORDER by a0.award_number , a0.sequence_number
/
commit
/
UPDATE missing_award_budget t1 SET t1.copy_budget_id = ( SELECT budget_id from award_budget_ext 
														 where award_id in ( select award_id from award 
																			 where award_number = t1.award_number 
																			 and sequence_number = t1.from_sequence)
																		   )
/
commit
/																		   
declare
	li_budget_id BUDGET.BUDGET_ID%type;
	li_award AWARD.AWARD_ID%type;
	cursor c_data is
	select AWARD_NUMBER,SEQUENCE_NUMBER,FROM_SEQUENCE,COPY_BUDGET_ID FROM MISSING_AWARD_BUDGET;
	r_data c_data%rowtype;
begin
	open c_data;
	loop;
	fetch c_data into r_data;
	exit when c_data%notfound;
		

		BEGIN
			
			SELECT KREW_DOC_HDR_S.NEXTVAL INTO ls_doc_nbr FROM DUAL;			
			SELECT SEQ_BUDGET_ID.NEXTVAL INTO li_seq_budget_id FROM DUAL;
			
						
			SELECT budget_id into li_budget_id from award_budget_ext 
			where award_id in (select award_id from award where award_number = r_data.award_number and sequence_number = r_data.sequence_number);
			 
						
			begin
			
				SELECT DOCUMENT_NUMBER,AWARD_ID INTO ls_document_number , 
				FROM AWARD 
				WHERE AWARD_NUMBER = r_data.award_number
				AND SEQUENCE_NUMBER = r_data.sequence_number;
			exception
			when others then
			dbms_output.put_line('Error in  AWARD, AWARD_NUMBER:'||r_data.award_number||'SEQUENCE_NUMBER '||r_data.sequence_number||' and the error is'||substr(sqlerrm,1,100));
			end;
			
			INSERT INTO BUDGET_DOCUMENT(DOCUMENT_NUMBER,PARENT_DOCUMENT_KEY,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,PARENT_DOCUMENT_TYPE_CODE,OBJ_ID,BUDGET_DELETED)
			SELECT ls_doc_nbr, ls_document_number, ver_nbr, update_timestamp, update_user, parent_document_type_code, sys_guid(), budget_deleted
			FROM BUDGET_DOCUMENT WHERE DOCUMENT_NUMBER in ( SELECT DOCUMENT_NUMBER FROM BUDGET WHERE BUDGET_ID = c_data.copy_budget_id );
			
					  
			INSERT INTO BUDGET(BUDGET_ID,BUDGET_JUSTIFICATION,ON_OFF_CAMPUS_FLAG,VERSION_NUMBER,DOCUMENT_NUMBER,START_DATE,END_DATE,
			TOTAL_COST,TOTAL_DIRECT_COST,TOTAL_INDIRECT_COST,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,RESIDUAL_FUNDS,TOTAL_COST_LIMIT,
			OH_RATE_CLASS_CODE,OH_RATE_TYPE_CODE,COMMENTS,FINAL_VERSION_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,UR_RATE_CLASS_CODE,
			MODULAR_BUDGET_FLAG,VER_NBR,OBJ_ID,TOTAL_DIRECT_COST_LIMIT,SUBMIT_COST_SHARING,PARENT_DOCUMENT_TYPE_CODE)
			SELECT li_seq_budget_id,BUDGET_JUSTIFICATION,ON_OFF_CAMPUS_FLAG,VERSION_NUMBER,ls_doc_nbr,START_DATE,END_DATE,TOTAL_COST,
			TOTAL_DIRECT_COST,TOTAL_INDIRECT_COST,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,RESIDUAL_FUNDS,TOTAL_COST_LIMIT,OH_RATE_CLASS_CODE,
			OH_RATE_TYPE_CODE,COMMENTS,FINAL_VERSION_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,UR_RATE_CLASS_CODE,MODULAR_BUDGET_FLAG,VER_NBR,
			sys_guid(),TOTAL_DIRECT_COST_LIMIT,SUBMIT_COST_SHARING,PARENT_DOCUMENT_TYPE_CODE			
			FROM BUDGET WHERE BUDGET_ID = c_data.copy_budget_id;
			
			INSERT INTO AWARD_BUDGET_EXT(BUDGET_ID,AWARD_BUDGET_STATUS_CODE,AWARD_BUDGET_TYPE_CODE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,
			OBLIGATED_AMOUNT,BUDGET_INITIATOR,DESCRIPTION,DOCUMENT_NUMBER,OBJ_ID,AWARD_ID)	
			SELECT li_seq_budget_id,AWARD_BUDGET_STATUS_CODE,AWARD_BUDGET_TYPE_CODE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,
			OBLIGATED_AMOUNT,BUDGET_INITIATOR,DESCRIPTION,DOCUMENT_NUMBER,SYS_GUID(),li_award
			FROM AWARD_BUDGET_EXT WHERE BUDGET_ID = c_data.copy_budget_id;
						
			
			UPDATE MISSING_AWARD_BUDGET SET NEW_BUDGET_ID = li_seq_budget_id
			WHERE AWARD_NUMBER = r_data.award_number
			AND SEQUENCE_NUMBER = r_data.sequence_number;
			
				
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
			values(ls_doc_nbr,SYS_GUID(),1,r_data.award_number,NULL,NULL,NULL);
					
			  
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
	
	end loop;
	close c_data;
	

end;
/

