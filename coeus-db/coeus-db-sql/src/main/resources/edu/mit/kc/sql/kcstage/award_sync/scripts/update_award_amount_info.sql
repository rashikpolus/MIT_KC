select ' Started UPDATE_AWARD_AMOUNT_INFO ' from dual
/
DECLARE
li_ver_nbr NUMBER(8):=1;
li_amt_info_id NUMBER(12);
li_award_id NUMBER(22);
ls_tnm_document_number VARCHAR2(40 );
li_transaction_detail NUMBER(10,0);
li_transaction NUMBER(10,0):=null;
ls_comments VARCHAR2(2000);
ls_source_award VARCHAR2(12);
ls_processed_flag CHAR(1);
li_commit_count number:=0;
ls_transaction_detail_type	VARCHAR2(12):='PRIMARY';
ls_trans_det_comment VARCHAR2(200 BYTE):='Initial Time And Money creation transaction';
ls2_transaction_detail_type	VARCHAR2(12):='INTERMEDIATE';
ls2_trans_det_comment VARCHAR2(200 BYTE):='Single Node Money Transaction';
li_originating_award_version NUMBER(4):=NULL;
ls_award_number VARCHAR2(12);
li_seq_info NUMBER(4);
ls_mit_awd_number varchar2(12);
li_mit_seq NUMBER(4);
li_transaction_type NUMBER(3,0);
ll_date DATE;
ls_comment VARCHAR2(2000);
ls_doc_typ_id VARCHAR2(40);
li_RTE_BRCH_ID  VARCHAR2(12);
li_rte_node VARCHAR2(12);
li_rte_node_instn_t VARCHAR2(12);
li_action_taken VARCHAR2(12);
li_action_rqst VARCHAR2(12);
li_prncpl_id VARCHAR2(12);
ls_transaction NUMBER(10,0);
li_cnt number;
CURSOR c_award IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD ts on a.AWARD_NUMBER=replace(ts.MIT_AWARD_NUMBER,'-','-00') and a.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER 
where ts.FEED_TYPE = 'C'
ORDER BY a.AWARD_NUMBER,a.SEQUENCE_NUMBER;
r_award c_award%ROWTYPE;

CURSOR c_amt_info(as_mit varchar2,as_seq number) IS
SELECT MIT_AWARD_NUMBER,SEQUENCE_NUMBER,AMOUNT_SEQUENCE_NUMBER,ANTICIPATED_TOTAL_AMOUNT,ANT_DISTRIBUTABLE_AMOUNT,FINAL_EXPIRATION_DATE,CURRENT_FUND_EFFECTIVE_DATE,AMOUNT_OBLIGATED_TO_DATE,OBLI_DISTRIBUTABLE_AMOUNT,OBLIGATION_EXPIRATION_DATE,TRANSACTION_ID,ENTRY_TYPE,EOM_PROCESS_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,ANTICIPATED_CHANGE,OBLIGATED_CHANGE,OBLIGATED_CHANGE_DIRECT,OBLIGATED_CHANGE_INDIRECT,ANTICIPATED_CHANGE_DIRECT,ANTICIPATED_CHANGE_INDIRECT,ANTICIPATED_TOTAL_DIRECT,ANTICIPATED_TOTAL_INDIRECT,OBLIGATED_TOTAL_DIRECT,OBLIGATED_TOTAL_INDIRECT FROM OSP$AWARD_AMOUNT_INFO
where MIT_AWARD_NUMBER=as_mit and SEQUENCE_NUMBER =(
select max(aw.sequence_number) from OSP$AWARD_AMOUNT_INFO aw where  aw.mit_award_number=OSP$AWARD_AMOUNT_INFO.mit_award_number and aw.sequence_number<=as_seq)
ORDER BY MIT_AWARD_NUMBER,SEQUENCE_NUMBER,AMOUNT_SEQUENCE_NUMBER;
r_amt_info c_amt_info%ROWTYPE;

BEGIN

IF c_award%ISOPEN THEN 
CLOSE c_award;
END IF;
OPEN c_award;
LOOP
FETCH c_award INTO r_award;
EXIT WHEN c_award%NOTFOUND;

	
	ls_mit_awd_number := REPLACE(r_award.AWARD_NUMBER,'-00','-');
	li_mit_seq := r_award.SEQUENCE_NUMBER;

	begin
	SELECT AWARD_ID INTO li_award_id FROM AWARD WHERE AWARD_NUMBER = r_award.AWARD_NUMBER AND SEQUENCE_NUMBER = r_award.SEQUENCE_NUMBER;
	exception
	when others then
	dbms_output.put_line('AWARD_NUMBER:'||ls_award_number||'SEQUENCE_NUMBER:'||li_seq_info);
	end;

IF c_amt_info%ISOPEN THEN
CLOSE c_amt_info;
END IF;
OPEN c_amt_info(ls_mit_awd_number,li_mit_seq);
LOOP
FETCH c_amt_info INTO r_amt_info;
EXIT WHEN c_amt_info%NOTFOUND;

	li_seq_info := r_amt_info.SEQUENCE_NUMBER;
	li_originating_award_version := li_seq_info;
	ls_source_award:='000000-00000';

	ls_award_number := REPLACE(r_amt_info.MIT_AWARD_NUMBER,'-','-00');
	
	select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='TimeAndMoneyDocument';
	SELECT KREW_DOC_HDR_S.NEXTVAL INTO  li_transaction FROM DUAL;
	SELECT PRNCPL_ID into li_prncpl_id FROM KRIM_PRNCPL_T WHERE lower(prncpl_nm)=lower(r_amt_info.UPDATE_USER);
	SELECT TRANSACTION_TYPE_CODE,NOTICE_DATE,COMMENTS INTO li_transaction_type,ll_date,ls_comment FROM OSP$AWARD_AMOUNT_TRANSACTION WHERE MIT_AWARD_NUMBER=r_amt_info.MIT_AWARD_NUMBER AND TRANSACTION_ID=r_amt_info.TRANSACTION_ID;
	SELECT KREW_RTE_NODE_S.NEXTVAL INTO li_RTE_BRCH_ID FROM DUAL;
	SELECT KREW_RTE_NODE_S.NEXTVAL INTO li_rte_node FROM DUAL;
	SELECT KREW_RTE_NODE_S.NEXTVAL INTO li_rte_node_instn_t FROM DUAL;
	select KREW_ACTN_TKN_S.NEXTVAL INTO li_action_taken FROM DUAL;
	select KREW_ACTN_RQST_S.NEXTVAL INTO li_action_rqst FROM DUAL;
	
	INSERT INTO TIME_AND_MONEY_DOCUMENT(DOCUMENT_NUMBER,AWARD_NUMBER,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	VALUES(li_transaction,ls_award_number,1,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,SYS_GUID());
	
	INSERT INTO KREW_DOC_HDR_T(DOC_HDR_ID,DOC_TYP_ID,DOC_HDR_STAT_CD,RTE_LVL,STAT_MDFN_DT,CRTE_DT,APRV_DT,FNL_DT,RTE_STAT_MDFN_DT,TTL,APP_DOC_ID,DOC_VER_NBR,INITR_PRNCPL_ID,VER_NBR,RTE_PRNCPL_ID,DTYPE,OBJ_ID,APP_DOC_STAT,APP_DOC_STAT_MDFN_DT)
    VALUES(li_transaction,ls_doc_typ_id,'F',0,sysdate,sysdate,sysdate,null,sysdate,('KC TimeAndMoney - '||ls_award_number),null,1, nvl(li_prncpl_id,'unknownUser'),1,null,null,sys_guid(),null,null);
	
	INSERT INTO KRNS_DOC_HDR_T(DOC_HDR_ID,OBJ_ID,VER_NBR,FDOC_DESC,ORG_DOC_HDR_ID,TMPL_DOC_HDR_ID,EXPLANATION)
    VALUES(li_transaction,SYS_GUID(),1,ls_award_number,NULL,NULL,NULL); 
	
	INSERT INTO KREW_DOC_HDR_CNTNT_T(DOC_HDR_ID,DOC_CNTNT_TXT)
    VALUES(li_transaction,NULL);
	
	INSERT INTO KREW_RTE_BRCH_T(RTE_BRCH_ID,NM,PARNT_ID,INIT_RTE_NODE_INSTN_ID,SPLT_RTE_NODE_INSTN_ID,JOIN_RTE_NODE_INSTN_ID,VER_NBR)
    VALUES(li_RTE_BRCH_ID,'PRIMARY',NULL,NULL,NULL,NULL,1);
	
	INSERT INTO KREW_RTE_NODE_T(RTE_NODE_ID,DOC_TYP_ID,NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,FNL_APRVR_IND,MNDTRY_RTE_IND,ACTVN_TYP,BRCH_PROTO_ID,VER_NBR,CONTENT_FRAGMENT,GRP_ID,NEXT_DOC_STAT)
    VALUES(li_rte_node,ls_doc_typ_id,'Initiated','org.kuali.rice.kew.engine.node.InitialNode',null,null,0,0,'P',null,1,null,null,null);

    INSERT INTO KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,DOC_HDR_ID,RTE_NODE_ID,BRCH_ID,PROC_RTE_NODE_INSTN_ID,ACTV_IND,CMPLT_IND,INIT_IND,VER_NBR)
    VALUES(li_rte_node_instn_t,li_transaction,li_rte_node,li_RTE_BRCH_ID,NULL,1,0,0,1);

    INSERT INTO KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,RTE_NODE_INSTN_ID)
    VALUES(li_transaction,li_rte_node_instn_t); 

	INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
    VALUES(li_action_rqst,NULL,'C',li_transaction,NULL,'A',-3,li_prncpl_id,NULL,NULL,NULL,'U',0,NULL,0,li_rte_node_instn_t,NULL,1,SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1	,0,NULL,NULL);

    INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
    VALUES(li_action_taken,li_transaction,li_prncpl_id,NULL,'S',SYSDATE,1,NULL,1,1,NULL);
	
	INSERT INTO AWARD_AMOUNT_TRANSACTION(AWARD_AMOUNT_TRANSACTION_ID,AWARD_NUMBER,TRANSACTION_ID,TRANSACTION_TYPE_CODE,NOTICE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
    VALUES(SEQ_AWARD_AMOUNT_TRANS_ID.NEXTVAL,ls_award_number,li_transaction,li_transaction_type,ll_date,ls_comment,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,1,SYS_GUID());
--SELECT SEQ_TRANSACTION_ID.NEXTVAL INTO li_transaction FROM DUAL;
--li_transaction:=null;


IF li_transaction is not null then
	begin
	select count(TRANSACTION_ID) into li_cnt from OSP$AWARD_AMOUNT_INFO
		where MIT_AWARD_NUMBER=r_amt_info.MIT_AWARD_NUMBER and SEQUENCE_NUMBER=r_amt_info.SEQUENCE_NUMBER and AMOUNT_SEQUENCE_NUMBER =r_amt_info.AMOUNT_SEQUENCE_NUMBER;
    if li_cnt=1 then
		select TRANSACTION_ID into ls_transaction  from OSP$AWARD_AMOUNT_INFO
		where MIT_AWARD_NUMBER=r_amt_info.MIT_AWARD_NUMBER and SEQUENCE_NUMBER=r_amt_info.SEQUENCE_NUMBER and AMOUNT_SEQUENCE_NUMBER = r_amt_info.AMOUNT_SEQUENCE_NUMBER;
    end if;
	--In TRANSACTION_DETAILS table ,col  TRANSACTION_ID has been set to ZERO because there is no pending transaction
	if r_amt_info.AMOUNT_SEQUENCE_NUMBER !=1 then

			SELECT SEQ_TRANSACTION_DETAIL_ID.NEXTVAL INTO li_transaction_detail FROM DUAL;
			INSERT INTO TRANSACTION_DETAILS(TRANSACTION_DETAIL_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TRANSACTION_ID,TNM_DOCUMENT_NUMBER,COMMENTS,SOURCE_AWARD_NUMBER,DESTINATION_AWARD_NUMBER,OBLIGATED_AMOUNT,ANTICIPATED_AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,TRANSACTION_DETAIL_TYPE,OBLIGATED_DIRECT_AMOUNT,OBLIGATED_INDIRECT_AMOUNT,ANTICIPATED_DIRECT_AMOUNT,ANTICIPATED_INDIRECT_AMOUNT)
			VALUES(li_transaction_detail,ls_award_number,li_seq_info,ls_transaction,li_transaction,ls_trans_det_comment,ls_source_award,ls_award_number,r_amt_info.OBLIGATED_CHANGE,r_amt_info.ANTICIPATED_CHANGE,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,li_ver_nbr,SYS_GUID(),ls_transaction_detail_type,r_amt_info.OBLIGATED_CHANGE_DIRECT,r_amt_info.OBLIGATED_CHANGE_INDIRECT,r_amt_info.ANTICIPATED_CHANGE_DIRECT,r_amt_info.ANTICIPATED_CHANGE_INDIRECT);
			
			SELECT SEQ_TRANSACTION_DETAIL_ID.NEXTVAL INTO li_transaction_detail FROM DUAL;    
			INSERT INTO TRANSACTION_DETAILS(TRANSACTION_DETAIL_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TRANSACTION_ID,TNM_DOCUMENT_NUMBER,COMMENTS,SOURCE_AWARD_NUMBER,DESTINATION_AWARD_NUMBER,OBLIGATED_AMOUNT,ANTICIPATED_AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,TRANSACTION_DETAIL_TYPE,OBLIGATED_DIRECT_AMOUNT,OBLIGATED_INDIRECT_AMOUNT,ANTICIPATED_DIRECT_AMOUNT,ANTICIPATED_INDIRECT_AMOUNT)
			VALUES(li_transaction_detail,ls_award_number,li_seq_info,ls_transaction,li_transaction,ls2_trans_det_comment,ls_source_award,ls_award_number,r_amt_info.OBLIGATED_CHANGE,r_amt_info.ANTICIPATED_CHANGE,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,li_ver_nbr,SYS_GUID(),ls2_transaction_detail_type,r_amt_info.OBLIGATED_CHANGE_DIRECT,r_amt_info.OBLIGATED_CHANGE_INDIRECT,r_amt_info.ANTICIPATED_CHANGE_DIRECT,r_amt_info.ANTICIPATED_CHANGE_INDIRECT);
	end if;

	SELECT SEQ_TRANSACTION_DETAIL_ID.NEXTVAL INTO li_transaction_detail FROM DUAL;

	INSERT INTO TRANSACTION_DETAILS(TRANSACTION_DETAIL_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TRANSACTION_ID,TNM_DOCUMENT_NUMBER,COMMENTS,SOURCE_AWARD_NUMBER,DESTINATION_AWARD_NUMBER,OBLIGATED_AMOUNT,ANTICIPATED_AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,TRANSACTION_DETAIL_TYPE,OBLIGATED_DIRECT_AMOUNT,OBLIGATED_INDIRECT_AMOUNT,ANTICIPATED_DIRECT_AMOUNT,ANTICIPATED_INDIRECT_AMOUNT)
	VALUES(li_transaction_detail,ls_award_number,li_seq_info,ls_transaction,li_transaction,ls_trans_det_comment,ls_source_award,ls_award_number,r_amt_info.OBLIGATED_CHANGE,r_amt_info.ANTICIPATED_CHANGE,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,li_ver_nbr,SYS_GUID(),ls_transaction_detail_type,r_amt_info.OBLIGATED_CHANGE_DIRECT,r_amt_info.OBLIGATED_CHANGE_INDIRECT,r_amt_info.ANTICIPATED_CHANGE_DIRECT,r_amt_info.ANTICIPATED_CHANGE_INDIRECT);
	
	EXCEPTION
	WHEN OTHERS THEN 
	dbms_output.put_line('ERROR IN PENDING TRANSACTION_DETAILS,AWARD_NUMBER:'||r_amt_info.MIT_AWARD_NUMBER||'-'||sqlerrm);
	end;
END IF;

begin
	if r_amt_info.AMOUNT_SEQUENCE_NUMBER = 1 then
			SELECT SEQUENCE_AWARD_ID.NEXTVAL INTO li_amt_info_id FROM DUAL;
			INSERT INTO AWARD_AMOUNT_INFO(AWARD_AMOUNT_INFO_ID,ANTICIPATED_CHANGE_DIRECT,ANTICIPATED_CHANGE_INDIRECT,ANTICIPATED_TOTAL_DIRECT,ANTICIPATED_TOTAL_INDIRECT,OBLIGATED_TOTAL_DIRECT,OBLIGATED_TOTAL_INDIRECT,VER_NBR,TNM_DOCUMENT_NUMBER,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ANTICIPATED_TOTAL_AMOUNT,ANT_DISTRIBUTABLE_AMOUNT,FINAL_EXPIRATION_DATE,CURRENT_FUND_EFFECTIVE_DATE,AMOUNT_OBLIGATED_TO_DATE,OBLI_DISTRIBUTABLE_AMOUNT,OBLIGATION_EXPIRATION_DATE,TRANSACTION_ID,ENTRY_TYPE,EOM_PROCESS_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,ANTICIPATED_CHANGE,OBLIGATED_CHANGE,OBLIGATED_CHANGE_DIRECT,OBLIGATED_CHANGE_INDIRECT,OBJ_ID,ORIGINATING_AWARD_VERSION)
			VALUES(li_amt_info_id,null,null,0,0,0,0,li_ver_nbr,null,li_award_id,ls_award_number,li_seq_info,r_amt_info.ANTICIPATED_TOTAL_AMOUNT,r_amt_info.ANT_DISTRIBUTABLE_AMOUNT,r_amt_info.FINAL_EXPIRATION_DATE,r_amt_info.CURRENT_FUND_EFFECTIVE_DATE,r_amt_info.AMOUNT_OBLIGATED_TO_DATE,r_amt_info.OBLI_DISTRIBUTABLE_AMOUNT,r_amt_info.OBLIGATION_EXPIRATION_DATE,null,'N',r_amt_info.EOM_PROCESS_FLAG,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,null,null,null,null,SYS_GUID(),li_originating_award_version);
	end if;
			SELECT SEQUENCE_AWARD_ID.NEXTVAL INTO li_amt_info_id FROM DUAL;
			INSERT INTO AWARD_AMOUNT_INFO(AWARD_AMOUNT_INFO_ID,ANTICIPATED_CHANGE_DIRECT,ANTICIPATED_CHANGE_INDIRECT,ANTICIPATED_TOTAL_DIRECT,ANTICIPATED_TOTAL_INDIRECT,OBLIGATED_TOTAL_DIRECT,OBLIGATED_TOTAL_INDIRECT,VER_NBR,TNM_DOCUMENT_NUMBER,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ANTICIPATED_TOTAL_AMOUNT,ANT_DISTRIBUTABLE_AMOUNT,FINAL_EXPIRATION_DATE,CURRENT_FUND_EFFECTIVE_DATE,AMOUNT_OBLIGATED_TO_DATE,OBLI_DISTRIBUTABLE_AMOUNT,OBLIGATION_EXPIRATION_DATE,TRANSACTION_ID,ENTRY_TYPE,EOM_PROCESS_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,ANTICIPATED_CHANGE,OBLIGATED_CHANGE,OBLIGATED_CHANGE_DIRECT,OBLIGATED_CHANGE_INDIRECT,OBJ_ID,ORIGINATING_AWARD_VERSION)
			VALUES(li_amt_info_id,r_amt_info.ANTICIPATED_CHANGE_DIRECT,r_amt_info.ANTICIPATED_CHANGE_INDIRECT,r_amt_info.ANTICIPATED_TOTAL_DIRECT,r_amt_info.ANTICIPATED_TOTAL_INDIRECT,r_amt_info.OBLIGATED_TOTAL_DIRECT,r_amt_info.OBLIGATED_TOTAL_INDIRECT,li_ver_nbr,li_transaction,li_award_id,ls_award_number,li_seq_info,r_amt_info.ANTICIPATED_TOTAL_AMOUNT,r_amt_info.ANT_DISTRIBUTABLE_AMOUNT,r_amt_info.FINAL_EXPIRATION_DATE,r_amt_info.CURRENT_FUND_EFFECTIVE_DATE,r_amt_info.AMOUNT_OBLIGATED_TO_DATE,r_amt_info.OBLI_DISTRIBUTABLE_AMOUNT,r_amt_info.OBLIGATION_EXPIRATION_DATE,ls_transaction,r_amt_info.ENTRY_TYPE,r_amt_info.EOM_PROCESS_FLAG,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,r_amt_info.ANTICIPATED_CHANGE,r_amt_info.OBLIGATED_CHANGE,r_amt_info.OBLIGATED_CHANGE_DIRECT,r_amt_info.OBLIGATED_CHANGE_INDIRECT,SYS_GUID(),li_originating_award_version);

EXCEPTION
WHEN OTHERS THEN 
dbms_output.put_line('ERROR IN AWARD_AMOUNT_INFO,AWARD_NUMBER:'||r_amt_info.MIT_AWARD_NUMBER||'-'||sqlerrm);
end;
commit;
END LOOP;
CLOSE c_amt_info;
end loop;
close c_award;
INSERT INTO AWARD_AMT_FNA_DISTRIBUTION(AWARD_AMT_FNA_DISTRIBUTION_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,AMOUNT_SEQUENCE_NUMBER,BUDGET_PERIOD,START_DATE,END_DATE,DIRECT_COST,INDIRECT_COST,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,AWARD_AMOUNT_INFO_ID,OBJ_ID)
SELECT SEQ_AWARD_AMT_FNA_DSTRBTN_ID.NEXTVAL,a.AWARD_ID,FN_AWARD_NUMBER(ad.MIT_AWARD_NUMBER)AWARD_NUMBER,ad.SEQUENCE_NUMBER,ad.AMOUNT_SEQUENCE_NUMBER,ad.BUDGET_PERIOD,ad.START_DATE,ad.END_DATE,ad.DIRECT_COST,
ad.INDIRECT_COST,ad.UPDATE_TIMESTAMP,ad.UPDATE_USER,1,null AWARD_AMOUNT_INFO_ID,SYS_GUID() FROM OSP$AWARD_AMT_FNA_DISTRIBUTION ad inner join AWARD a on  a.AWARD_NUMBER=FN_AWARD_NUMBER(ad.MIT_AWARD_NUMBER) and a.SEQUENCE_NUMBER=ad.SEQUENCE_NUMBER 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD ts on a.AWARD_NUMBER=replace(ts.MIT_AWARD_NUMBER,'-','-00') and a.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER 
where ts.FEED_TYPE = 'C';
dbms_output.put_line('Completed AWARD_AMOUNT_INFO!!!');

END;
/
-- insert a row into AWARD_AMOUNT_INFO for those award in award master but no data in AWARD AMOUNT INFO
Insert into AWARD_AMOUNT_INFO (ANTICIPATED_CHANGE_DIRECT,ANTICIPATED_CHANGE_INDIRECT,ANTICIPATED_TOTAL_DIRECT,ANTICIPATED_TOTAL_INDIRECT,OBLIGATED_TOTAL_DIRECT,OBLIGATED_TOTAL_INDIRECT,VER_NBR,TNM_DOCUMENT_NUMBER,AWARD_AMOUNT_INFO_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ANTICIPATED_TOTAL_AMOUNT,ANT_DISTRIBUTABLE_AMOUNT,FINAL_EXPIRATION_DATE,CURRENT_FUND_EFFECTIVE_DATE,AMOUNT_OBLIGATED_TO_DATE,OBLI_DISTRIBUTABLE_AMOUNT,OBLIGATION_EXPIRATION_DATE,TRANSACTION_ID,ENTRY_TYPE,EOM_PROCESS_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,ANTICIPATED_CHANGE,OBLIGATED_CHANGE,OBLIGATED_CHANGE_DIRECT,OBLIGATED_CHANGE_INDIRECT,OBJ_ID,ORIGINATING_AWARD_VERSION) 
select null,null,0,0,0,0,0,null,SEQUENCE_AWARD_ID.NEXTVAL,a.award_id,a.award_number,1,0,0,sysdate,null,0,0,null,null,'N','N',sysdate,a.update_user,null,null,null,null,sys_guid(),1
from award a INNER JOIN TEMP_TAB_TO_SYNC_AWARD ts on a.AWARD_NUMBER=replace(ts.MIT_AWARD_NUMBER,'-','-00') and a.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER  
where a.award_id not in (select distinct award_id from award_amount_info) 
and ts.FEED_TYPE = 'C'
-- insert a row into AWARD_AMOUNT_INFO for those award in award master but no data in AWARD AMOUNT INFO
/
declare
cursor c_data is
SELECT a.TRANSACTION_ID,a.TNM_DOCUMENT_NUMBER,a.AWARD_NUMBER,'000000-00000'as DESTINATION_AWARD_NUMBER,a.OBLIGATED_CHANGE,a.ANTICIPATED_CHANGE,NULL,a.UPDATE_TIMESTAMP,a.UPDATE_USER,1,SYS_GUID(),a.OBLIGATED_TOTAL_DIRECT,a.OBLIGATED_TOTAL_INDIRECT,a.ANTICIPATED_TOTAL_DIRECT,a.ANTICIPATED_TOTAL_INDIRECT,'Y','N' 
FROM AWARD_AMOUNT_INFO a INNER JOIN TEMP_TAB_TO_SYNC_AWARD ts on a.AWARD_NUMBER=replace(ts.MIT_AWARD_NUMBER,'-','-00') and a.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER
WHERE AWARD_AMOUNT_INFO_ID in(SELECT MAX(AWARD_AMOUNT_INFO_ID) FROM AWARD_AMOUNT_INFO GROUP BY AWARD_NUMBER,SEQUENCE_NUMBER,TRANSACTION_ID) AND TNM_DOCUMENT_NUMBER IS NOT NULL
AND ts.FEED_TYPE = 'C';
r_data c_data%rowtype;

begin
open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;
begin
	INSERT INTO PENDING_TRANSACTIONS(TRANSACTION_ID,DOCUMENT_NUMBER,SOURCE_AWARD_NUMBER,DESTINATION_AWARD_NUMBER,OBLIGATED_AMOUNT,ANTICIPATED_AMOUNT,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,OBLIGATED_DIRECT_AMOUNT,OBLIGATED_INDIRECT_AMOUNT,ANTICIPATED_DIRECT_AMOUNT,ANTICIPATED_INDIRECT_AMOUNT,PROCESSED_FLAG,SINGLE_NODE_TRANS)
	VALUES( r_data.TRANSACTION_ID,r_data.TNM_DOCUMENT_NUMBER,r_data.AWARD_NUMBER,r_data.DESTINATION_AWARD_NUMBER,r_data.OBLIGATED_CHANGE,r_data.ANTICIPATED_CHANGE,NULL,r_data.UPDATE_TIMESTAMP,r_data.UPDATE_USER,1,SYS_GUID(),r_data.OBLIGATED_TOTAL_DIRECT,r_data.OBLIGATED_TOTAL_INDIRECT,r_data.ANTICIPATED_TOTAL_DIRECT,r_data.ANTICIPATED_TOTAL_INDIRECT,'Y','N');
	
exception
when others then
null;
end;
end loop;
close c_data;
end;
/
commit
/
select ' Ended UPDATE_AWARD_AMOUNT_INFO ' from dual
/