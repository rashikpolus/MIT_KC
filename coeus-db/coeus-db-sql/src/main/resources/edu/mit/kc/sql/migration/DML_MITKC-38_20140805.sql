DELETE FROM REPORT WHERE DESCRIPTION='Non-competing Continuation'
/
DELETE FROM REPORT WHERE DESCRIPTION='Competing Renewal'
/
DELETE FROM VALID_CLASS_REPORT_FREQ WHERE REPORT_CLASS_CODE='7'
/
DECLARE
ls_report_code VARCHAR2(3);
ls_report_code_1 VARCHAR2(3);

BEGIN

INSERT INTO REPORT(REPORT_CODE,VER_NBR,DESCRIPTION,FINAL_REPORT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,ACTIVE_FLAG)
VALUES((select max(rownum)+1 from REPORT),1,'Non-competing Continuation','N',SYSDATE,'admin', SYS_GUID(),'Y');
commit;
INSERT INTO REPORT(REPORT_CODE,VER_NBR,DESCRIPTION,FINAL_REPORT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,ACTIVE_FLAG)
VALUES((select max(rownum)+1 from REPORT),1,'Competing Renewal','N',SYSDATE,'admin', SYS_GUID(),'Y');
commit;

SELECT REPORT_CODE INTO ls_report_code FROM REPORT WHERE DESCRIPTION='Non-competing Continuation';
SELECT REPORT_CODE INTO ls_report_code_1  FROM REPORT WHERE DESCRIPTION='Competing Renewal';

Insert into VALID_CLASS_REPORT_FREQ (VALID_CLASS_REPORT_FREQ_ID,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
select (select max(VALID_CLASS_REPORT_FREQ_ID) + 1 from VALID_CLASS_REPORT_FREQ) + rownum,
        '7',
        ls_report_code_1,
        t1.FREQUENCY_CODE,
        sysdate,
        'admin',
        0,
        SYS_GUID()
from 
(select distinct competing_renewal_prpsl_due as FREQUENCY_CODE    
      from osp$award_header@coeus.kuali t1
      where competing_renewal_prpsl_due is not null)t1;
      
  Insert into VALID_CLASS_REPORT_FREQ (VALID_CLASS_REPORT_FREQ_ID,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
select (select max(VALID_CLASS_REPORT_FREQ_ID) + 1 from VALID_CLASS_REPORT_FREQ) + rownum,
        '7',
        ls_report_code,
        t1.FREQUENCY_CODE,
        sysdate,
        'admin',
        0,
        SYS_GUID()
from     
      (select distinct non_competing_cont_prpsl_due as FREQUENCY_CODE        
      from osp$award_header@coeus.kuali t1
      where non_competing_cont_prpsl_due is not null)t1;
	  
	  INSERT INTO AWARD_REPORT_TERMS(
          AWARD_REPORT_TERMS_ID,
          AWARD_ID,
          AWARD_NUMBER,
          SEQUENCE_NUMBER,
          REPORT_CLASS_CODE,
          REPORT_CODE,
          FREQUENCY_CODE,
          FREQUENCY_BASE_CODE,
          OSP_DISTRIBUTION_CODE,
          DUE_DATE,
          VER_NBR,
          UPDATE_TIMESTAMP,
          UPDATE_USER,
          OBJ_ID
)
select 
          SEQUENCE_AWARD_ID.NEXTVAL,
          t2.module_id,
          t2.kuali_awd,
          t2.kuali_sequence_number,
          '7',--Proposals Due
          ls_report_code,--
          t1.non_competing_cont_prpsl_due,
          null,
          null,
          null,
          1,
          t1.update_timestamp,
          t1.update_user,
          sys_guid()
from osp$award_header@coeus.kuali t1
inner join TEMP_SEQ_LOG t2 on t2.module_item_key = t1.mit_award_number and t1.sequence_number = t2.mit_sequence_number
left outer join AWARD_REPORT_TERMS t3 on t3.award_id = t2.module_id and  t3.frequency_code = t1.non_competing_cont_prpsl_due and t3.report_class_code = '7'
where t1.non_competing_cont_prpsl_due is not null
and   t2.module = 'AWD'
and   t3.award_id is null;

commit;
/
INSERT INTO AWARD_REPORT_TERMS(
          AWARD_REPORT_TERMS_ID,
          AWARD_ID,
          AWARD_NUMBER,
          SEQUENCE_NUMBER,
          REPORT_CLASS_CODE,
          REPORT_CODE,
          FREQUENCY_CODE,
          FREQUENCY_BASE_CODE,
          OSP_DISTRIBUTION_CODE,
          DUE_DATE,
          VER_NBR,
          UPDATE_TIMESTAMP,
          UPDATE_USER,
          OBJ_ID
)
select 
          SEQUENCE_AWARD_ID.NEXTVAL,
          t2.module_id,
          t2.kuali_awd,
          t2.kuali_sequence_number,
          '7',--Proposals Due
          ls_report_code_1,--
          t1.competing_renewal_prpsl_due,
          null,
          null,
          null,
          1,
          t1.update_timestamp,
          t1.update_user,
          sys_guid()     
from osp$award_header@coeus.kuali t1
inner join TEMP_SEQ_LOG t2 on t2.module_item_key = t1.mit_award_number and t1.sequence_number = t2.mit_sequence_number
left outer join AWARD_REPORT_TERMS t3 on t3.award_id = t2.module_id and  t3.frequency_code = t1.competing_renewal_prpsl_due and t3.report_class_code = '7'
where t1.competing_renewal_prpsl_due is not null
and   t2.module = 'AWD'
and   t3.award_id is null;

      
      
END;
commit;
/