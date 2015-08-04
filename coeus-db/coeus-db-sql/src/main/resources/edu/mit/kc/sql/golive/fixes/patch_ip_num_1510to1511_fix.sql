-- resetting the IP sequence to the maximum
declare
ls_max_val NUMBER(6,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(to_number(substr(PROPOSAL_NUMBER,-4))) into ls_max_val from proposal;
  if ls_max_val is null then
    ls_max_val := 0;
  end if;    
  select SEQ_INST_PROPOSAL_NUMBER.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence SEQ_INST_PROPOSAL_NUMBER increment by '||li_increment);
    select SEQ_INST_PROPOSAL_NUMBER.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence SEQ_INST_PROPOSAL_NUMBER increment by 1');
  end if;

end;
/
CREATE TABLE TMP_NEW_IP_GENERD_FOR_1510(
DOCUMENT_NUMBER           VARCHAR2(40) ,
OLD_PROPOSAL_NUMBER       VARCHAR2(8),
NEW_PROPOSAL_NUMBER VARCHAR2(8)
)
/
INSERT INTO TMP_NEW_IP_GENERD_FOR_1510(
DOCUMENT_NUMBER,
OLD_PROPOSAL_NUMBER,
NEW_PROPOSAL_NUMBER
)
SELECT DOCUMENT_NUMBER,PROPOSAL_NUMBER,('1511'||SEQ_INST_PROPOSAL_NUMBER.nextval)
FROM
(
  select distinct PROPOSAL_NUMBER,DOCUMENT_NUMBER 
  from proposal 
  where CREATE_TIMESTAMP >= '03-MAY-15'
  and substr(PROPOSAL_NUMBER,1,4) = '1510'
  and sequence_number=1
  order by PROPOSAL_NUMBER
)
/
ALTER TABLE PROPOSAL_UNIT_CREDIT_SPLIT DISABLE CONSTRAINT FK1_PROPOSAL_UNIT_CREDIT_SPLIT
/
ALTER TABLE PROPOSAL_SCIENCE_KEYWORD DISABLE CONSTRAINT FK_PROPOSAL_SCIENCE_KEYWORD
/
ALTER TABLE PROPOSAL_SPECIAL_REVIEW DISABLE CONSTRAINT FK_PROPOSAL_SPECIAL_REVIEW
/
ALTER TABLE PROPOSAL_NOTEPAD DISABLE CONSTRAINT FK_PROPOSAL_NOTEPAD
/
ALTER TABLE PROPOSAL_COMMENTS DISABLE CONSTRAINT FK_PROPOSAL_COMMENTS
/
ALTER TABLE PROPOSAL_ATTACHMENTS DISABLE CONSTRAINT FK_PROPOSAL_ATTACHMENTS
/
ALTER TABLE PROPOSAL_IP_REVIEW_JOIN DISABLE CONSTRAINT FK_PROPOSAL_ID
/
ALTER TABLE PROPOSAL_CUSTOM_DATA DISABLE CONSTRAINT FK_PROPOSAL_CUSTOM_DATA1
/
ALTER TABLE PROPOSAL_COST_SHARING DISABLE CONSTRAINT FK_PROPOSAL_COST_SHARING
/

UPDATE proposal t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_ATTACHMENTS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_ATTACHMENTS_DATA t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_COMMENTS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_COST_SHARING t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_CUSTOM_DATA t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/


UPDATE PROPOSAL_IDC_RATE t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_INV_CERTIFICATION t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_IP_REV_ACTIVITY t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_IP_REV_ACTIVITY t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_NOTEPAD t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_PERSONS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_SCIENCE_KEYWORD t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_UNITS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_UNIT_CREDIT_SPLIT t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE PROPOSAL_UNIT_CONTACTS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE WH_WL_PROP_REVIEW_DETAILS_EXT t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE WH_WL_PROPOSALS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/


UPDATE WL_PROP_REV_COMM_LAST_YEAR t1 SET t1.INST_PROPOSAL_NUMBER = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.INST_PROPOSAL_NUMBER)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.INST_PROPOSAL_NUMBER)
/

UPDATE WL_PROP_REVIEW_COMMENTS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

UPDATE WL_PROP_REVIEW_DETAILS t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/
UPDATE IP_REVIEW t1 SET t1.proposal_number = ( select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 
                                              where t2.old_proposal_number = t1.proposal_number)
WHERE EXISTS (select t2.new_proposal_number from tmp_new_ip_generd_for_1510 t2 where t2.old_proposal_number = t1.proposal_number)
/

ALTER TABLE PROPOSAL_UNIT_CREDIT_SPLIT ENABLE CONSTRAINT FK1_PROPOSAL_UNIT_CREDIT_SPLIT
/
ALTER TABLE PROPOSAL_SCIENCE_KEYWORD ENABLE CONSTRAINT FK_PROPOSAL_SCIENCE_KEYWORD
/
ALTER TABLE PROPOSAL_SPECIAL_REVIEW ENABLE CONSTRAINT FK_PROPOSAL_SPECIAL_REVIEW
/
ALTER TABLE PROPOSAL_NOTEPAD ENABLE CONSTRAINT FK_PROPOSAL_NOTEPAD
/
ALTER TABLE PROPOSAL_COMMENTS ENABLE CONSTRAINT FK_PROPOSAL_COMMENTS
/
ALTER TABLE PROPOSAL_ATTACHMENTS ENABLE CONSTRAINT FK_PROPOSAL_ATTACHMENTS
/
ALTER TABLE PROPOSAL_IP_REVIEW_JOIN ENABLE CONSTRAINT FK_PROPOSAL_ID
/
ALTER TABLE PROPOSAL_CUSTOM_DATA ENABLE CONSTRAINT FK_PROPOSAL_CUSTOM_DATA1
/
ALTER TABLE PROPOSAL_COST_SHARING ENABLE CONSTRAINT FK_PROPOSAL_COST_SHARING
/
-- Updating fiscal year and fiscal month if they are null( null was set from migrated data)
UPDATE proposal set fiscal_month = substr(proposal_number,3,2)
WHERE fiscal_month is null
/
UPDATE proposal set fiscal_year = to_char(to_date(substr(proposal_number,1,2)||'-01-01', 'RR-mm-dd'),'yyyy')
WHERE fiscal_year is null
/


