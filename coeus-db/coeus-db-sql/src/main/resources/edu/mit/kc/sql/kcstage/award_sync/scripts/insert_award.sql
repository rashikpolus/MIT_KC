select ' Started AWARD ' from dual
/
alter table award add constraint UQ_AWARD unique(AWARD_NUMBER,SEQUENCE_NUMBER)
/
alter table proposal add constraint UQ_PROPOSAL unique(PROPOSAL_NUMBER,SEQUENCE_NUMBER)
/
DECLARE
li_ver_nbr NUMBER(8):=1;
li_award_id NUMBER(22);
as_award_id NUMBER(22);
ll_closeout_date DATE;
ls_archive_location VARCHAR2(50 );
ls_transaction_type_cd  VARCHAR2(3 );
ll_notice_date DATE;
ls_cfda_number VARCHAR2(7);
li_loop number;
ls_doc_nbr VARCHAR2(40);
li_cfda_lenght PLS_INTEGER;
ls_hierarchy_sync_child varchar2(2):='N';
ls_award_number VARCHAR2(12);
li_new_seq NUMBER(4,0):=0;
ls_award_sequence_status VARCHAR2(10):='ACTIVE';
li_commit_count number:=0;
ls_lead_unit_num  VARCHAR2(8);
li_krew_rnt_brch NUMBER(19,0);
li_krew_rnt_node NUMBER(19,0);
li_krew_rne_node_instn NUMBER(19,0);
ls_awd_number VARCHAR2(20);
ls_proto VARCHAR2(20);
li_seq NUMBER(4);
li_count NUMBER;
ls_doc_typ_id VARCHAR2(40);
ls_prncpl_id VARCHAR2(40);

CURSOR c_award IS
SELECT t.feed_id,awh.ACTIVITY_TYPE_CODE ACTIVITY_TYPE_CODE,awh.AWARD_TYPE_CODE AWARD_TYPE_CODE,awh.PRIME_SPONSOR_CODE PRIME_SPONSOR_CODE,awh.CFDA_NUMBER CFDA_NUMBER,
awh.METHOD_OF_PAYMENT_CODE METHOD_OF_PAYMENT_CODE,awh.DFAFS_NUMBER DFAFS_NUMBER,awh.PRE_AWARD_AUTHORIZED_AMOUNT PRE_AWARD_AUTHORIZED_AMOUNT,
awh.PRE_AWARD_EFFECTIVE_DATE PRE_AWARD_EFFECTIVE_DATE,awh.PROCUREMENT_PRIORITY_CODE PROCUREMENT_PRIORITY_CODE,awh.PROPOSAL_NUMBER PROPOSAL_NUMBER,
awh.SPECIAL_EB_RATE_OFF_CAMPUS SPECIAL_EB_RATE_OFF_CAMPUS,awh.SPECIAL_EB_RATE_ON_CAMPUS SPECIAL_EB_RATE_ON_CAMPUS,awh.SUB_PLAN_FLAG SUB_PLAN_FLAG,
awh.BASIS_OF_PAYMENT_CODE BASIS_OF_PAYMENT_CODE,awh.ACCOUNT_TYPE_CODE ACCOUNT_TYPE_CODE,aw.MIT_AWARD_NUMBER MIT_AWARD_NUMBER,aw.SEQUENCE_NUMBER SEQUENCE_NUMBER,
aw.SPONSOR_CODE SPONSOR_CODE,aw.STATUS_CODE STATUS_CODE,aw.TEMPLATE_CODE TEMPLATE_CODE,aw.ACCOUNT_NUMBER ACCOUNT_NUMBER,
aw.APPRVD_EQUIPMENT_INDICATOR APPRVD_EQUIPMENT_INDICATOR,aw.APPRVD_FOREIGN_TRIP_INDICATOR APPRVD_FOREIGN_TRIP_INDICATOR,
aw.APPRVD_SUBCONTRACT_INDICATOR APPRVD_SUBCONTRACT_INDICATOR,aw.AWARD_EFFECTIVE_DATE AWARD_EFFECTIVE_DATE,aw.KEY_PERSON_INDICATOR,
aw.AWARD_EXECUTION_DATE AWARD_EXECUTION_DATE,aw.BEGIN_DATE BEGIN_DATE,aw.COST_SHARING_INDICATOR COST_SHARING_INDICATOR,aw.IDC_INDICATOR IDC_INDICATOR,
aw.MODIFICATION_NUMBER MODIFICATION_NUMBER,aw.NSF_CODE NSF_CODE,aw.PAYMENT_SCHEDULE_INDICATOR PAYMENT_SCHEDULE_INDICATOR,aw.SCIENCE_CODE_INDICATOR SCIENCE_CODE_INDICATOR,
aw.SPECIAL_REVIEW_INDICATOR SPECIAL_REVIEW_INDICATOR,aw.SPONSOR_AWARD_NUMBER SPONSOR_AWARD_NUMBER,aw.TRANSFER_SPONSOR_INDICATOR TRANSFER_SPONSOR_INDICATOR,
aw.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,awh.TITLE,aw.UPDATE_USER UPDATE_USER FROM OSP$AWARD@coeus.kuali aw LEFT OUTER JOIN  OSP$AWARD_HEADER@coeus.kuali awh ON awh.MIT_AWARD_NUMBER=aw.MIT_AWARD_NUMBER AND awh.SEQUENCE_NUMBER=aw.SEQUENCE_NUMBER INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aw.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER and aw.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER 
where t.FEED_TYPE = 'N'
order by aw.MIT_AWARD_NUMBER,aw.SEQUENCE_NUMBER;
r_award c_award%ROWTYPE;

BEGIN

IF c_award%ISOPEN THEN
CLOSE c_award;
END IF;


OPEN c_award;

li_loop:=0;
LOOP
FETCH c_award INTO r_award;
EXIT WHEN c_award%NOTFOUND;
	SELECT replace(r_award.MIT_AWARD_NUMBER,'-','-00') INTO ls_award_number FROM DUAL;
	li_new_seq := r_award.SEQUENCE_NUMBER;
	
	select count(award_number) into li_count from award where award_number = ls_award_number and sequence_number = li_new_seq;
	IF li_count=0 THEN

		BEGIN


			begin
			SELECT CLOSEOUT_DATE,ARCHIVE_LOCATION INTO ll_closeout_date,ls_archive_location FROM OSP$AWARD_CLOSEOUT WHERE MIT_AWARD_NUMBER=r_award.MIT_AWARD_NUMBER AND SEQUENCE_NUMBER=r_award.SEQUENCE_NUMBER;
			exception
			when no_data_found then
			ll_closeout_date:=null;
			ls_archive_location:=null;
			WHEN TOO_MANY_ROWS THEN    --UMB added next four lines
				ll_closeout_date:=null;
				ls_archive_location:=null;
				dbms_output.put_line('Closeout Too many rows: MIT_AWARD_NUMBER ' || r_award.MIT_AWARD_NUMBER || ', Seq: ' || r_award.SEQUENCE_NUMBER);
			end;
			
			begin
				SELECT TRANSACTION_TYPE_CODE,NOTICE_DATE INTO ls_transaction_type_cd,ll_notice_date FROM OSP$AWARD_AMOUNT_TRANSACTION WHERE mit_award_number=r_award.MIT_AWARD_NUMBER and TRANSACTION_ID=(
				select aai.TRANSACTION_ID from OSP$AWARD_AMOUNT_INFO aai where aai.mit_award_number=r_award.MIT_AWARD_NUMBER and aai.sequence_number= r_award.SEQUENCE_NUMBER
				and aai.AMOUNT_SEQUENCE_NUMBER=(select max(aa.AMOUNT_SEQUENCE_NUMBER) from OSP$AWARD_AMOUNT_INFO aa where aa.mit_award_number=aai.mit_award_number and aa.sequence_number=aai.sequence_number ));
			exception
			WHEN TOO_MANY_ROWS THEN   --UMB added next four lines
				   ls_transaction_type_cd:=null;
				   ll_notice_date:=null;
				   dbms_output.put_line('Award Too many rows: MIT_AWARD_NUMBER ' || r_award.MIT_AWARD_NUMBER || ', Seq: ' || r_award.SEQUENCE_NUMBER);
			when others then
				ls_transaction_type_cd:=null;
				ll_notice_date:=null;
			end;

			ls_cfda_number := r_award.CFDA_NUMBER;
			SELECT LENGTH(TRIM(ls_cfda_number)) INTO li_cfda_lenght  FROM DUAL;
			IF ls_cfda_number IS NOT NULL AND li_cfda_lenght >0 THEN
				SELECT SUBSTR(trim(ls_cfda_number),1,2)||'.'||SUBSTR(trim(ls_cfda_number),3)INTO ls_cfda_number FROM DUAL;
			END IF;

			BEGIN			
			    select b.unit_number INTO ls_lead_unit_num from osp$award_units@coeus.kuali b
				where b.lead_unit_flag = 'Y'
				and   b.mit_award_number = r_award.MIT_AWARD_NUMBER
				and   b.sequence_number = ( select max(s1.sequence_number) 
											from osp$award_units@coeus.kuali s1
											where s1.mit_award_number = r_award.MIT_AWARD_NUMBER
											and   s1.sequence_number <= r_award.SEQUENCE_NUMBER
										  )
				and rownum < 2;		
			
			EXCEPTION
			WHEN OTHERS THEN
			ls_lead_unit_num:=NULL;
			END;
			

			SELECT KREW_DOC_HDR_S.NEXTVAL INTO ls_doc_nbr FROM DUAL;
			INSERT INTO AWARD_DOCUMENT(DOCUMENT_NUMBER,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
			VALUES(ls_doc_nbr,1,r_award.UPDATE_TIMESTAMP,r_award.UPDATE_USER,SYS_GUID());
			
			select max(to_number(DOC_TYP_ID)) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='AwardDocument';
			begin
			select p.prncpl_id into ls_prncpl_id  from KRIM_PRNCPL_T p where LOWER(p.PRNCPL_NM)=LOWER(r_award.UPDATE_USER);
			exception
			when others then
			ls_prncpl_id:='unknownuser';
			end;


			SELECT SEQUENCE_AWARD_ID.NEXTVAL INTO li_award_id FROM DUAL;
			INSERT INTO AWARD(AWARD_ID,CLOSEOUT_DATE,TRANSACTION_TYPE_CODE,NOTICE_DATE,LEAD_UNIT_NUMBER,ACTIVITY_TYPE_CODE,AWARD_TYPE_CODE,PRIME_SPONSOR_CODE,CFDA_NUMBER,METHOD_OF_PAYMENT_CODE,DFAFS_NUMBER,PRE_AWARD_AUTHORIZED_AMOUNT,PRE_AWARD_EFFECTIVE_DATE,PROCUREMENT_PRIORITY_CODE,PROPOSAL_NUMBER,SPECIAL_EB_RATE_OFF_CAMPUS,SPECIAL_EB_RATE_ON_CAMPUS,SUB_PLAN_FLAG,TITLE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,PRE_AWARD_IN_AUTHORIZED_AMOUNT,ARCHIVE_LOCATION,PRE_AWARD_INST_EFFECTIVE_DATE,BASIS_OF_PAYMENT_CODE,DOCUMENT_NUMBER,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_CODE,STATUS_CODE,TEMPLATE_CODE,ACCOUNT_NUMBER,APPRVD_EQUIPMENT_INDICATOR,APPRVD_FOREIGN_TRIP_INDICATOR,APPRVD_SUBCONTRACT_INDICATOR,AWARD_EFFECTIVE_DATE,AWARD_EXECUTION_DATE,BEGIN_DATE,COST_SHARING_INDICATOR,IDC_INDICATOR,MODIFICATION_NUMBER,NSF_CODE,PAYMENT_SCHEDULE_INDICATOR,SCIENCE_CODE_INDICATOR,SPECIAL_REVIEW_INDICATOR,SPONSOR_AWARD_NUMBER,TRANSFER_SPONSOR_INDICATOR,ACCOUNT_TYPE_CODE,OBJ_ID,FIN_ACCOUNT_DOC_NBR,FIN_ACCOUNT_CREATION_DATE,HIERARCHY_SYNC_CHILD,FIN_CHART_OF_ACCOUNTS_CODE,AWARD_SEQUENCE_STATUS)
			VALUES(li_award_id,ll_closeout_date,ls_transaction_type_cd,ll_notice_date,ls_lead_unit_num,r_award.ACTIVITY_TYPE_CODE,r_award.AWARD_TYPE_CODE,r_award.PRIME_SPONSOR_CODE,ls_cfda_number,r_award.METHOD_OF_PAYMENT_CODE,r_award.DFAFS_NUMBER,r_award.PRE_AWARD_AUTHORIZED_AMOUNT,r_award.PRE_AWARD_EFFECTIVE_DATE,r_award.PROCUREMENT_PRIORITY_CODE,r_award.PROPOSAL_NUMBER,r_award.SPECIAL_EB_RATE_OFF_CAMPUS,r_award.SPECIAL_EB_RATE_ON_CAMPUS,r_award.SUB_PLAN_FLAG,r_award.TITLE,li_ver_nbr,r_award.UPDATE_TIMESTAMP,r_award.UPDATE_USER,r_award.PRE_AWARD_AUTHORIZED_AMOUNT,ls_archive_location,r_award.PRE_AWARD_EFFECTIVE_DATE,r_award.BASIS_OF_PAYMENT_CODE,ls_doc_nbr,ls_award_number,li_new_seq,r_award.SPONSOR_CODE,r_award.STATUS_CODE,r_award.TEMPLATE_CODE,substr(r_award.ACCOUNT_NUMBER,1,7),r_award.APPRVD_EQUIPMENT_INDICATOR,r_award.APPRVD_FOREIGN_TRIP_INDICATOR,r_award.APPRVD_SUBCONTRACT_INDICATOR,r_award.AWARD_EFFECTIVE_DATE,r_award.AWARD_EXECUTION_DATE,r_award.BEGIN_DATE,r_award.COST_SHARING_INDICATOR,r_award.IDC_INDICATOR,r_award.MODIFICATION_NUMBER,r_award.NSF_CODE,r_award.PAYMENT_SCHEDULE_INDICATOR,r_award.SCIENCE_CODE_INDICATOR,r_award.SPECIAL_REVIEW_INDICATOR,r_award.SPONSOR_AWARD_NUMBER,r_award.TRANSFER_SPONSOR_INDICATOR,r_award.ACCOUNT_TYPE_CODE,SYS_GUID(),NULL,NULL,ls_hierarchy_sync_child,NULL,ls_award_sequence_status);
			li_commit_count:= li_commit_count + 1;
			
			INSERT INTO KREW_DOC_HDR_T(DOC_HDR_ID,DOC_TYP_ID,DOC_HDR_STAT_CD,RTE_LVL,
            STAT_MDFN_DT,CRTE_DT,APRV_DT,FNL_DT,RTE_STAT_MDFN_DT,TTL,APP_DOC_ID,DOC_VER_NBR,
            INITR_PRNCPL_ID,VER_NBR,RTE_PRNCPL_ID,DTYPE,OBJ_ID,APP_DOC_STAT,APP_DOC_STAT_MDFN_DT)
			VALUES(ls_doc_nbr,ls_doc_typ_id,'F',0,sysdate,r_award.UPDATE_TIMESTAMP,sysdate,NULL,
            sysdate,('AwardDocument'||'-'||replace(r_award.MIT_AWARD_NUMBER,'-','-00')),NULL,1,ls_prncpl_id,1,
            NULL,NULL,SYS_GUID(),NULL,NULL);

			INSERT INTO KRNS_DOC_HDR_T(DOC_HDR_ID,OBJ_ID,VER_NBR,FDOC_DESC,ORG_DOC_HDR_ID,TMPL_DOC_HDR_ID,EXPLANATION)
			VALUES(ls_doc_nbr,sys_guid(),1,replace(r_award.MIT_AWARD_NUMBER,'-','-00'),NULL,NULL,NULL);
			
			INSERT INTO KREW_DOC_HDR_CNTNT_T(DOC_HDR_ID)
			VALUES(ls_doc_nbr);
		   
			INSERT INTO SYNC_AWARD_LOG(feed_id,execution_date) VALUES(r_award.feed_id,sysdate);

			BEGIN
			select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_brch from dual ; 
			select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_node from dual ;
			select KREW_RTE_NODE_S.NEXTVAL into li_krew_rne_node_instn from dual ;
			
			INSERT INTO KREW_RTE_BRCH_T(RTE_BRCH_ID,NM,PARNT_ID,INIT_RTE_NODE_INSTN_ID,SPLT_RTE_NODE_INSTN_ID,JOIN_RTE_NODE_INSTN_ID,VER_NBR)
			VALUES(li_krew_rnt_brch,'PRIMARY',NULL,NULL,NULL,NULL,1);
			
			INSERT INTO KREW_RTE_NODE_T(RTE_NODE_ID,DOC_TYP_ID,
                                        NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,
                                        FNL_APRVR_IND,MNDTRY_RTE_IND,
                                        ACTVN_TYP,BRCH_PROTO_ID,VER_NBR,
                                        CONTENT_FRAGMENT,GRP_ID,NEXT_DOC_STAT)
								VALUES(li_krew_rnt_node,ls_doc_typ_id,'Initiated','org.kuali.rice.kew.engine.node.InitialNode',
                                       null,null,0,0,'P',
                                       null,1,null,null,null);
									   
            INSERT INTO KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,RTE_NODE_INSTN_ID)
            VALUES(ls_doc_nbr,li_krew_rne_node_instn);
     			
            INSERT INTO KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,DOC_HDR_ID,RTE_NODE_ID,BRCH_ID,PROC_RTE_NODE_INSTN_ID,ACTV_IND,CMPLT_IND,INIT_IND,VER_NBR)
			VALUES(li_krew_rne_node_instn,ls_doc_nbr,li_krew_rnt_node,li_krew_rnt_brch,NULL,1,0,0,1);
			
			INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,
			RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,
			DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
			VALUES(KREW_ACTN_RQST_S.NEXTVAL,NULL,'C',ls_doc_nbr,NULL,'A',
			-3,ls_prncpl_id,NULL,NULL,NULL,'U',0,NULL,0,li_krew_rne_node_instn,NULL,
             1,SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1,0,NULL,NULL);
			 
			INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
			VALUES(KREW_ACTN_TKN_S.NEXTVAL,ls_doc_nbr,ls_prncpl_id,NULL,'S',SYSDATE,1,NULL,1,1,NULL);
			
			
			  
			EXCEPTION 
			WHEN OTHERS THEN     
			dbms_output.put_line('Error while inserting into KREW_DOC_HDR_T  '||r_award.MIT_AWARD_NUMBER||' and exception is '||substr(sqlerrm,1,200));
			END; 


		EXCEPTION
		WHEN OTHERS THEN
		dbms_output.put_line('Missing data in AWARD,AWARD_NUMBER/SEQUENCE NUMBER - AWARD_ID:'||r_award.MIT_AWARD_NUMBER||' / '||li_new_seq||'-'||li_award_id||sqlerrm);
		END;
commit;
END IF;

END LOOP;
CLOSE c_award;

END;
/
declare
li_doc number(10);
li_proposal_max number(10);
ls_query VARCHAR2(400);
li_num number;
begin
 
SELECT to_number(SUBSTR(MAX(AWARD_NUMBER),1,6)) INTO li_doc  FROM AWARD; 
SELECT SEQ_AWARD_AWARD_NUMBER.NEXTVAL into li_num  FROM DUAL;
li_doc:=li_doc - li_num;
execute immediate('alter sequence SEQ_AWARD_AWARD_NUMBER increment by '||li_doc);

end;
/
select SEQ_AWARD_AWARD_NUMBER.NEXTVAL from dual
/
alter sequence SEQ_AWARD_AWARD_NUMBER increment by 1
/
declare
ls_unit VARCHAR2(8);
cursor c_awd is
select award_number , sequence_number from award 
--where award_number =  '000842-00001'
order by 1,2;
r_awd c_awd%ROWTYPE;
begin
open c_awd;
loop
fetch c_awd into r_awd;
exit when c_awd%notfound;
/*
select aa.lead_unit_number into ls_unit from award aa where aa.award_number = r_awd.award_number
and aa.sequence_number = ( select min(sequence_number) from award where award_number = aa.award_number and sequence_number >= r_awd.sequence_number  and lead_unit_number is not null); 
dbms_output.put_line(r_awd.sequence_number ||'   '||ls_unit);
*/
update award a set a.lead_unit_number = (select aa.lead_unit_number from award aa where aa.award_number = r_awd.award_number
and aa.sequence_number = (select max(sequence_number) from award where award_number = aa.award_number and sequence_number <= r_awd.sequence_number  and lead_unit_number is not null)
)
where a.award_number = r_awd.award_number
and a.sequence_number = r_awd.sequence_number;

commit;
end loop;
close c_awd;
end;
/
select ' Ended AWARD ' from dual
/