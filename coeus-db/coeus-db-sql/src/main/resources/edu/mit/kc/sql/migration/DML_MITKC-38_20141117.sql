CREATE INDEX REPORT_I ON award_report_terms(REPORT_CLASS_CODE)
/
CREATE INDEX AWARD_REP_TERM_I2 ON award_report_terms(AWARD_REPORT_TERMS_ID, REPORT_CLASS_CODE)
/
ALTER TABLE award_rep_terms_recnt DISABLE CONSTRAINT FK1_AWARD_REP_TERMS_RECNT;
ALTER TABLE award_report_terms DISABLE CONSTRAINT AWARD_REPORT_TERMSP1;
ALTER TABLE award_report_terms DISABLE CONSTRAINT FK10_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms DISABLE CONSTRAINT FK11_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms DISABLE CONSTRAINT FK3_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms DISABLE CONSTRAINT FK8_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms DISABLE CONSTRAINT FK9_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms DISABLE CONSTRAINT FK_AWARD_REPORT_TERMS;
DELETE  from  award_rep_terms_recnt
where award_report_terms_id in (select award_report_terms_id  from  award_report_terms where report_class_code= '7');
commit;
DELETE  from  award_report_terms where report_class_code= '7';
commit;
ALTER TABLE award_report_terms ENABLE CONSTRAINT AWARD_REPORT_TERMSP1;
ALTER TABLE award_rep_terms_recnt ENABLE CONSTRAINT FK1_AWARD_REP_TERMS_RECNT;
ALTER TABLE award_report_terms ENABLE CONSTRAINT FK10_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms ENABLE CONSTRAINT FK11_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms ENABLE CONSTRAINT FK3_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms ENABLE CONSTRAINT FK8_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms ENABLE CONSTRAINT FK9_AWARD_REPORT_TERMS;
ALTER TABLE award_report_terms ENABLE CONSTRAINT FK_AWARD_REPORT_TERMS
/
DECLARE
ls_report_code VARCHAR2(3);
ls_report_code_1 VARCHAR2(3);

BEGIN

SELECT REPORT_CODE INTO ls_report_code FROM REPORT WHERE DESCRIPTION='Non-competing Continuation';
SELECT REPORT_CODE INTO ls_report_code_1  FROM REPORT WHERE DESCRIPTION='Competing Renewal';

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
          t2.award_id,
          t2.award_number,
          t2.sequence_number,
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
inner join award t2 on t2.award_number = replace(t1.mit_award_number,'-','-00') and t2.sequence_number=t1.sequence_number
where t1.non_competing_cont_prpsl_due is not null;


commit;

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
          t2.award_id,
          t2.award_number,
          t2.sequence_number,
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
inner join award t2 on t2.award_number = replace(t1.mit_award_number,'-','-00') and t2.sequence_number=t1.sequence_number
where t1.competing_renewal_prpsl_due is not null;

END;
/
UPDATE AWARD_REPORT_TERMS
SET FREQUENCY_BASE_CODE=-1
WHERE FREQUENCY_BASE_CODE IS NULL
AND FREQUENCY_CODE IS NOT NULL
/
commit
/
update AWARD_REPORT_TERMS set OSP_DISTRIBUTION_CODE = null where OSP_DISTRIBUTION_CODE = -1
/
commit
/