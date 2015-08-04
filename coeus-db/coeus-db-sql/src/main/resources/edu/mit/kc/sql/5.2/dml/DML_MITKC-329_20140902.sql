TRUNCATE TABLE AWARD_CLOSEOUT;
commit;

declare
li_count number;
begin

     select count(*) into li_count from user_tables where table_name='OSP$AWARD_CLOSEOUT';
     if li_count=0 then
       execute immediate('CREATE TABLE OSP$AWARD_CLOSEOUT( 
   	                     "MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	                     "SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	                     "FINAL_INV_SUBMISSION_DATE" DATE, 
	                     "FINAL_TECH_SUBMISSION_DATE" DATE, 
	                     "FINAL_PATENT_SUBMISSION_DATE" DATE, 
	                     "FINAL_PROP_SUBMISSION_DATE" DATE, 
	                     "ARCHIVE_LOCATION" VARCHAR2(50 BYTE), 
	                     "CLOSEOUT_DATE" DATE, 
	                     "UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	                     "UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE)');
	    commit;

 

     end if;
     select count(*) into li_count from user_tables where table_name='OSP$AWARD_AMOUNT_INFO';
     if li_count=0 then
       execute immediate('CREATE TABLE OSP$AWARD_AMOUNT_INFO(
                         "MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
                         "SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
                         "AMOUNT_SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
                         "ANTICIPATED_TOTAL_AMOUNT" NUMBER(12,2), 
                         "ANT_DISTRIBUTABLE_AMOUNT" NUMBER(12,2), 
                         "FINAL_EXPIRATION_DATE" DATE, 
                         "CURRENT_FUND_EFFECTIVE_DATE" DATE, 
                         "AMOUNT_OBLIGATED_TO_DATE" NUMBER(12,2), 
                         "OBLI_DISTRIBUTABLE_AMOUNT" NUMBER(12,2), 
                         "OBLIGATION_EXPIRATION_DATE" DATE, 
                         "TRANSACTION_ID" VARCHAR2(10 BYTE), 
                         "ENTRY_TYPE" CHAR(1 BYTE), 
                         "EOM_PROCESS_FLAG" CHAR(1 BYTE), 
                         "UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
                         "UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
                         "ANTICIPATED_CHANGE" NUMBER(12,2), 
                         "OBLIGATED_CHANGE" NUMBER(12,2), 
                         "OBLIGATED_CHANGE_DIRECT" NUMBER(12,2), 
                         "OBLIGATED_CHANGE_INDIRECT" NUMBER(12,2), 
                         "ANTICIPATED_CHANGE_DIRECT" NUMBER(12,2), 
                         "ANTICIPATED_CHANGE_INDIRECT" NUMBER(12,2), 
                         "ANTICIPATED_TOTAL_DIRECT" NUMBER(12,2), 
                         "ANTICIPATED_TOTAL_INDIRECT" NUMBER(12,2), 
                         "OBLIGATED_TOTAL_DIRECT" NUMBER(12,2), 
                         "OBLIGATED_TOTAL_INDIRECT" NUMBER(12,2))');
	
	

      

     end if;
end;
/
  DECLARE
  li_count number;
  BEGIN
  
  SELECT COUNT(*) into li_count FROM OSP$AWARD_CLOSEOUT;
  
  IF li_count=0 THEN
      
       insert into OSP$AWARD_CLOSEOUT(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,FINAL_INV_SUBMISSION_DATE,FINAL_TECH_SUBMISSION_DATE,FINAL_PATENT_SUBMISSION_DATE,
       FINAL_PROP_SUBMISSION_DATE,ARCHIVE_LOCATION,CLOSEOUT_DATE,UPDATE_TIMESTAMP,UPDATE_USER)
       select MIT_AWARD_NUMBER,SEQUENCE_NUMBER,FINAL_INV_SUBMISSION_DATE,FINAL_TECH_SUBMISSION_DATE,FINAL_PATENT_SUBMISSION_DATE,
       FINAL_PROP_SUBMISSION_DATE,ARCHIVE_LOCATION,CLOSEOUT_DATE,UPDATE_TIMESTAMP,UPDATE_USER from OSP$AWARD_CLOSEOUT@coeus.kuali;

       execute immediate('CREATE INDEX OSP$AWARD_CLOSEOUT_I ON OSP$AWARD_CLOSEOUT (MIT_AWARD_NUMBER, SEQUENCE_NUMBER)');
       
       
 END IF; 
 
SELECT COUNT(*) into li_count FROM OSP$AWARD_AMOUNT_INFO;
  
  IF li_count=0 THEN 
       insert into OSP$AWARD_AMOUNT_INFO(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,AMOUNT_SEQUENCE_NUMBER,ANTICIPATED_TOTAL_AMOUNT,ANT_DISTRIBUTABLE_AMOUNT,FINAL_EXPIRATION_DATE,
       CURRENT_FUND_EFFECTIVE_DATE,AMOUNT_OBLIGATED_TO_DATE,OBLI_DISTRIBUTABLE_AMOUNT,OBLIGATION_EXPIRATION_DATE,TRANSACTION_ID,ENTRY_TYPE,EOM_PROCESS_FLAG,UPDATE_TIMESTAMP,
       UPDATE_USER,ANTICIPATED_CHANGE,OBLIGATED_CHANGE,OBLIGATED_CHANGE_DIRECT,OBLIGATED_CHANGE_INDIRECT,ANTICIPATED_CHANGE_DIRECT,ANTICIPATED_CHANGE_INDIRECT,
       ANTICIPATED_TOTAL_DIRECT,ANTICIPATED_TOTAL_INDIRECT,OBLIGATED_TOTAL_DIRECT,OBLIGATED_TOTAL_INDIRECT)
       select MIT_AWARD_NUMBER,SEQUENCE_NUMBER,AMOUNT_SEQUENCE_NUMBER,ANTICIPATED_TOTAL_AMOUNT,ANT_DISTRIBUTABLE_AMOUNT,FINAL_EXPIRATION_DATE,
       CURRENT_FUND_EFFECTIVE_DATE,AMOUNT_OBLIGATED_TO_DATE,OBLI_DISTRIBUTABLE_AMOUNT,OBLIGATION_EXPIRATION_DATE,TRANSACTION_ID,ENTRY_TYPE,EOM_PROCESS_FLAG,UPDATE_TIMESTAMP,
       UPDATE_USER,ANTICIPATED_CHANGE,OBLIGATED_CHANGE,OBLIGATED_CHANGE_DIRECT,OBLIGATED_CHANGE_INDIRECT,ANTICIPATED_CHANGE_DIRECT,ANTICIPATED_CHANGE_INDIRECT,
       ANTICIPATED_TOTAL_DIRECT,ANTICIPATED_TOTAL_INDIRECT,OBLIGATED_TOTAL_DIRECT,OBLIGATED_TOTAL_INDIRECT
       from OSP$AWARD_AMOUNT_INFO@coeus.kuali;

       execute immediate('CREATE INDEX OSP$AWARD_AMOUNT_INFO_I ON OSP$AWARD_AMOUNT_INFO (MIT_AWARD_NUMBER, SEQUENCE_NUMBER)');

       execute immediate('CREATE INDEX OSP$AWARD_AMOUNT_INFO_I2 ON OSP$AWARD_AMOUNT_INFO(MIT_AWARD_NUMBER, SEQUENCE_NUMBER,AMOUNT_SEQUENCE_NUMBER)'); 
       
  END IF;
  
END;
/
DECLARE
ll_due_date	DATE;
ls_multiple	CHAR(1):='N';
li_award_id	NUMBER(22,0);
li_ver_nbr NUMBER:=1;
ls_awd_number VARCHAR2(12);
li_seq NUMBER(4,0);
li_commit_count number:=0;
CURSOR c_awd_closout IS
SELECT a.AWARD_ID,a.AWARD_NUMBER,a.SEQUENCE_NUMBER KUALI_SEQUENCE_NUMBER,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.FINAL_INV_SUBMISSION_DATE,ac.FINAL_TECH_SUBMISSION_DATE,ac.FINAL_PATENT_SUBMISSION_DATE,
ac.FINAL_PROP_SUBMISSION_DATE,ac.ARCHIVE_LOCATION,ac.CLOSEOUT_DATE,a.UPDATE_TIMESTAMP,a.UPDATE_USER FROM AWARD a LEFT OUTER JOIN OSP$AWARD_CLOSEOUT ac ON a.AWARD_NUMBER=replace(ac.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER;
r_awd_closout c_awd_closout%ROWTYPE;
BEGIN
IF c_awd_closout%ISOPEN THEN
CLOSE c_awd_closout;
END IF;
OPEN c_awd_closout;
LOOP
FETCH c_awd_closout INTO r_awd_closout;
EXIT WHEN c_awd_closout%NOTFOUND;


begin
SELECT FINAL_EXPIRATION_DATE INTO  ll_due_date FROM OSP$AWARD_AMOUNT_INFO where MIT_AWARD_NUMBER =r_awd_closout.MIT_AWARD_NUMBER AND 
SEQUENCE_NUMBER=r_awd_closout.SEQUENCE_NUMBER AND AMOUNT_SEQUENCE_NUMBER=(SELECT MAX(am.AMOUNT_SEQUENCE_NUMBER) from OSP$AWARD_AMOUNT_INFO am where
am.MIT_AWARD_NUMBER=r_awd_closout.MIT_AWARD_NUMBER AND am.SEQUENCE_NUMBER=r_awd_closout.SEQUENCE_NUMBER);
exception when others then
ll_due_date:=null;
end;


INSERT INTO AWARD_CLOSEOUT(AWARD_CLOSEOUT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,CLOSEOUT_REPORT_CODE,CLOSEOUT_REPORT_NAME,DUE_DATE,FINAL_SUBMISSION_DATE,MULTIPLE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(SEQ_AWARD_AWARD_CLOSEOUT.nextval,r_awd_closout.AWARD_ID,r_awd_closout.AWARD_NUMBER,r_awd_closout.KUALI_SEQUENCE_NUMBER,'1','Financial',NULL,null,ls_multiple,r_awd_closout.UPDATE_TIMESTAMP,r_awd_closout.UPDATE_USER,li_ver_nbr,SYS_GUID());


INSERT INTO AWARD_CLOSEOUT(AWARD_CLOSEOUT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,CLOSEOUT_REPORT_CODE,CLOSEOUT_REPORT_NAME,DUE_DATE,FINAL_SUBMISSION_DATE,MULTIPLE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(SEQ_AWARD_AWARD_CLOSEOUT.nextval,r_awd_closout.AWARD_ID,r_awd_closout.AWARD_NUMBER,r_awd_closout.KUALI_SEQUENCE_NUMBER,'2','Property',NULL,r_awd_closout.FINAL_PROP_SUBMISSION_DATE,ls_multiple,r_awd_closout.UPDATE_TIMESTAMP,r_awd_closout.UPDATE_USER,li_ver_nbr,SYS_GUID());

INSERT INTO AWARD_CLOSEOUT(AWARD_CLOSEOUT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,CLOSEOUT_REPORT_CODE,CLOSEOUT_REPORT_NAME,DUE_DATE,FINAL_SUBMISSION_DATE,MULTIPLE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(SEQ_AWARD_AWARD_CLOSEOUT.nextval,r_awd_closout.AWARD_ID,r_awd_closout.AWARD_NUMBER,r_awd_closout.KUALI_SEQUENCE_NUMBER,'4','Technical',NULL,r_awd_closout.FINAL_TECH_SUBMISSION_DATE,ls_multiple,r_awd_closout.UPDATE_TIMESTAMP,r_awd_closout.UPDATE_USER,li_ver_nbr,SYS_GUID());

INSERT INTO AWARD_CLOSEOUT(AWARD_CLOSEOUT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,CLOSEOUT_REPORT_CODE,CLOSEOUT_REPORT_NAME,DUE_DATE,FINAL_SUBMISSION_DATE,MULTIPLE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(SEQ_AWARD_AWARD_CLOSEOUT.nextval,r_awd_closout.AWARD_ID,r_awd_closout.AWARD_NUMBER,r_awd_closout.KUALI_SEQUENCE_NUMBER,'3','Patent',NULL,r_awd_closout.FINAL_PATENT_SUBMISSION_DATE,ls_multiple,r_awd_closout.UPDATE_TIMESTAMP,r_awd_closout.UPDATE_USER,li_ver_nbr,SYS_GUID());

INSERT INTO AWARD_CLOSEOUT(AWARD_CLOSEOUT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,CLOSEOUT_REPORT_CODE,CLOSEOUT_REPORT_NAME,DUE_DATE,FINAL_SUBMISSION_DATE,MULTIPLE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(SEQ_AWARD_AWARD_CLOSEOUT.nextval,r_awd_closout.AWARD_ID,r_awd_closout.AWARD_NUMBER,r_awd_closout.KUALI_SEQUENCE_NUMBER,'6','Invoice',ll_due_date,r_awd_closout.FINAL_INV_SUBMISSION_DATE,ls_multiple,r_awd_closout.UPDATE_TIMESTAMP,r_awd_closout.UPDATE_USER,li_ver_nbr,SYS_GUID());
if li_commit_count =1000 then
li_commit_count:=0;
commit;
end if;
END LOOP;
CLOSE c_awd_closout;
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('Error occured Mit Award  number and Sequence Number is '||r_awd_closout.MIT_AWARD_NUMBER||' , '||r_awd_closout.SEQUENCE_NUMBER||' . '||sqlerrm);
dbms_output.put_line('Completed AWARD_CLOSEOUT!!!');
END;
/
DROP TABLE OSP$AWARD_CLOSEOUT
/
DROP TABLE OSP$AWARD_AMOUNT_INFO
/