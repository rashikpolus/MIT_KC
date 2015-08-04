select ' Started AWARD_REPORT_TERMS,AWARD_REP_TERMS_RECNT ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
ls_award_number varchar2(40);
li_award_reports_id NUMBER(12,0);
li_seq number(4,0);
li_count number;
ls_distribution_code VARCHAR2(3);
CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.REPORT_CLASS_CODE,ac.REPORT_CODE,DECODE(ac.FREQUENCY_CODE,-1,NULL,ac.FREQUENCY_CODE) FREQUENCY_CODE,DECODE(ac.FREQUENCY_BASE_CODE,-1,NULL,ac.FREQUENCY_BASE_CODE) FREQUENCY_BASE_CODE,DECODE(ac.OSP_DISTRIBUTION_CODE,-1,NULL,ac.OSP_DISTRIBUTION_CODE) OSP_DISTRIBUTION_CODE,ac.CONTACT_TYPE_CODE,ac.ROLODEX_ID,ac.DUE_DATE,ac.NUMBER_OF_COPIES,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER 
FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
LEFT OUTER JOIN OSP$AWARD_REPORT_TERMS@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER
WHERE ac.SEQUENCE_NUMBER=(SELECT MAX(SEQUENCE_NUMBER) FROM OSP$AWARD_REPORT_TERMS@coeus.kuali WHERE MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER)
AND ac.CONTACT_TYPE_CODE <> -1
AND t.FEED_TYPE='N'
ORDER BY a.AWARD_NUMBER,a.SEQUENCE_NUMBER;
r_award_comment c_award_comment%ROWTYPE;

BEGIN
IF c_award_comment%ISOPEN THEN
CLOSE c_award_comment;
END IF;
OPEN c_award_comment;
LOOP
FETCH c_award_comment INTO r_award_comment;
EXIT WHEN c_award_comment%NOTFOUND;
 li_seq:=r_award_comment.Kuali_sequence_number;
 select count(OSP_DISTRIBUTION_CODE) into li_count FROM DISTRIBUTION WHERE OSP_DISTRIBUTION_CODE=r_award_comment.OSP_DISTRIBUTION_CODE;
  IF li_count=0 THEN
    ls_distribution_code:= null;
	ELSE
	  ls_distribution_code:=r_award_comment.OSP_DISTRIBUTION_CODE;
  END IF;
  IF ls_distribution_code = -1 Then
	ls_distribution_code := null;
  end if;
  
  IF li_seq=1 THEN
	 li_seq:=li_seq + 1;
  END IF;
 select SEQUENCE_AWARD_ID.NEXTVAL into li_award_reports_id from dual;

 begin
 
    IF r_award_comment.MIT_AWARD_NUMBER IS NULL THEN
	
	     IF ls_award_number is null THEN
		 
		     	
		 
	
	         INSERT INTO AWARD_REPORT_TERMS(AWARD_REPORT_TERMS_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	         SELECT li_award_reports_id,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,ls_distribution_code,DUE_DATE,1,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() FROM AWARD_REPORT_TERMS
           WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and 	SEQUENCE_NUMBER=(SELECT MAX(aw.SEQUENCE_NUMBER) FROM AWARD_REPORT_TERMS aw where aw.AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND aw.SEQUENCE_NUMBER<li_seq);
       
	         INSERT INTO AWARD_REP_TERMS_RECNT(AWARD_REP_TERMS_RECNT_ID,CONTACT_ID,AWARD_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID) 
           SELECT SEQ_AWARD_REP_TERMS_RECNT_ID.NEXTVAL,null,li_award_reports_id,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,1,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() FROM AWARD_REP_TERMS_RECNT
           WHERE AWARD_REPORT_TERMS_ID=(SELECT AWARD_REPORT_TERMS_ID FROM AWARD_REPORT_TERMS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and 	SEQUENCE_NUMBER=(SELECT MAX(aw.SEQUENCE_NUMBER) FROM AWARD_REPORT_TERMS aw where aw.AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND aw.SEQUENCE_NUMBER<li_seq)); 
           ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		   
		 ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number THEN
		 
		       INSERT INTO AWARD_REPORT_TERMS(AWARD_REPORT_TERMS_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	         SELECT li_award_reports_id,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,ls_distribution_code,DUE_DATE,1,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() FROM AWARD_REPORT_TERMS
           WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and 	SEQUENCE_NUMBER=(SELECT MAX(aw.SEQUENCE_NUMBER) FROM AWARD_REPORT_TERMS aw where aw.AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND aw.SEQUENCE_NUMBER<r_award_comment.Kuali_sequence_number);
       
	         INSERT INTO AWARD_REP_TERMS_RECNT(AWARD_REP_TERMS_RECNT_ID,CONTACT_ID,AWARD_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID) 
           SELECT SEQ_AWARD_REP_TERMS_RECNT_ID.NEXTVAL,null,li_award_reports_id,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,1,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() FROM AWARD_REP_TERMS_RECNT
           WHERE AWARD_REPORT_TERMS_ID=(SELECT AWARD_REPORT_TERMS_ID FROM AWARD_REPORT_TERMS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and 	SEQUENCE_NUMBER=(SELECT MAX(aw.SEQUENCE_NUMBER) FROM AWARD_REPORT_TERMS aw where aw.AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND aw.SEQUENCE_NUMBER<li_seq)); 
           ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		   
		 END IF;  
	   ELSE
	

       INSERT INTO AWARD_REPORT_TERMS(AWARD_REPORT_TERMS_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	   VALUES(li_award_reports_id,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,r_award_comment.REPORT_CLASS_CODE,r_award_comment.REPORT_CODE,r_award_comment.FREQUENCY_CODE,r_award_comment.FREQUENCY_BASE_CODE,ls_distribution_code,r_award_comment.DUE_DATE,1,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,SYS_GUID());
	   
	   INSERT INTO AWARD_REP_TERMS_RECNT(AWARD_REP_TERMS_RECNT_ID,CONTACT_ID,AWARD_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID) 
       VALUES(SEQ_AWARD_REP_TERMS_RECNT_ID.NEXTVAL,null,li_award_reports_id,r_award_comment.CONTACT_TYPE_CODE,r_award_comment.ROLODEX_ID,r_award_comment.NUMBER_OF_COPIES,1,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,SYS_GUID());
	END IF;	

exception
when others then
dbms_output.put_line('Error in "insert_award_report_terms.sql" '||r_award_comment.award_number||','||r_award_comment.Kuali_sequence_number||','||ls_distribution_code||' - '||sqlerrm);
continue;
end;
	
END LOOP;
CLOSE c_award_comment;
END;
/	
---------- Report class code 7 Start --------
DECLARE
ls_report_code VARCHAR2(3);
ls_report_code_1 VARCHAR2(3);

BEGIN

SELECT REPORT_CODE INTO ls_report_code FROM REPORT WHERE DESCRIPTION='Non-competing Continuation' and rownum = 1;
SELECT REPORT_CODE INTO ls_report_code_1  FROM REPORT WHERE DESCRIPTION='Competing Renewal' and rownum = 1;

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
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t3 ON t1.MIT_AWARD_NUMBER = t3.MIT_AWARD_NUMBER AND t1.SEQUENCE_NUMBER = t3.SEQUENCE_NUMBER
WHERE t3.FEED_TYPE = 'N'
and t1.non_competing_cont_prpsl_due is not null;

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
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t3 ON t1.MIT_AWARD_NUMBER = t3.MIT_AWARD_NUMBER AND t1.SEQUENCE_NUMBER = t3.SEQUENCE_NUMBER
WHERE t3.FEED_TYPE = 'N'
and t1.competing_renewal_prpsl_due is not null;

END;
/
commit
/
---------- Report class code 7 End --------

---------- Report class code 6 Start ------
DECLARE
ls_report_code VARCHAR2(3);
li_award_id NUMBER(12,0);
ls_award_number VARCHAR2(16);
li_award_report_terms_id NUMBER(12,0);
li_rolodex_id NUMBER(12,0):=100046;
ls_contact VARCHAR2(3);
ls_FREQUENCY_BASE_CODE FREQUENCY_BASE.FREQUENCY_BASE_CODE%type;

CURSOR c_invoice IS
SELECT t1.MIT_AWARD_NUMBER,t1.SEQUENCE_NUMBER,t1.PAYMENT_INVOICE_FREQ_CODE,t1.INVOICE_NUMBER_OF_COPIES,t1.FINAL_INVOICE_DUE 
FROM OSP$AWARD_HEADER t1
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t2 ON t1.MIT_AWARD_NUMBER = t2.MIT_AWARD_NUMBER AND t1.SEQUENCE_NUMBER = t2.SEQUENCE_NUMBER
WHERE t2.FEED_TYPE = 'N'
AND t1.PAYMENT_INVOICE_FREQ_CODE IS NOT NULL;
r_invoice c_invoice%ROWTYPE;

BEGIN
SELECT REPORT_CODE INTO ls_report_code FROM REPORT WHERE DESCRIPTION='Payment/Invoice Frequency';

--select FREQUENCY_BASE_CODE into ls_FREQUENCY_BASE_CODE from FREQUENCY_BASE where DESCRIPTION='As Required'

IF c_invoice%ISOPEN THEN
CLOSE c_invoice;
END IF;
OPEN c_invoice;
LOOP
FETCH c_invoice INTO r_invoice;
EXIT WHEN c_invoice%NOTFOUND;


  
  SELECT SEQUENCE_AWARD_ID.NEXTVAL INTO li_award_report_terms_id FROM DUAL;
  ls_award_number:=replace(r_invoice.MIT_AWARD_NUMBER,'-','-00');
  BEGIN
  SELECT AWARD_ID INTO li_award_id FROM AWARD WHERE AWARD_NUMBER=ls_award_number AND SEQUENCE_NUMBER=r_invoice.SEQUENCE_NUMBER;
  EXCEPTION
  WHEN OTHERS THEN
    BEGIN
	  SELECT CHANGE_AWARD_NUMBER into ls_award_number FROM KC_MIG_AWARD_CONV WHERE AWARD_NUMBER=ls_award_number;
	  SELECT AWARD_ID INTO li_award_id FROM AWARD WHERE AWARD_NUMBER=ls_award_number AND SEQUENCE_NUMBER=r_invoice.SEQUENCE_NUMBER;
	EXCEPTION
	WHEN OTHERS THEN
	  dbms_output.put_line(ls_award_number||' '||r_invoice.SEQUENCE_NUMBER);
	  CONTINUE;
	END;  
  
  END;


 INSERT INTO AWARD_REPORT_TERMS(AWARD_REPORT_TERMS_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
 VALUES(li_award_report_terms_id,li_award_id,ls_award_number,r_invoice.SEQUENCE_NUMBER,'6',ls_report_code,r_invoice.PAYMENT_INVOICE_FREQ_CODE,NULL,NULL,NULL,1,SYSDATE,'admin',SYS_GUID());
 
 SELECT CONTACT_TYPE_CODE INTO  ls_contact FROM CONTACT_TYPE WHERE DESCRIPTION='Payment Invoice Contact';
 
 
  IF  r_invoice.INVOICE_NUMBER_OF_COPIES IS NOT NULL THEN
  
    INSERT INTO AWARD_REP_TERMS_RECNT(AWARD_REP_TERMS_RECNT_ID,CONTACT_ID,AWARD_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	VALUES(SEQ_AWARD_REP_TERMS_RECNT_ID.NEXTVAL,NULL,li_award_report_terms_id,ls_contact,li_rolodex_id,r_invoice.INVOICE_NUMBER_OF_COPIES,1,SYSDATE,'admin',SYS_GUID());
   
  END IF;
  
END LOOP;
CLOSE c_invoice;
END;
/
DECLARE

ls_report_code_1 VARCHAR2(3);
li_award_id NUMBER(12,0);
ls_award_number VARCHAR2(16);
li_award_report_terms_id NUMBER(12,0);
li_rolodex_id NUMBER(12,0):=100046;
ll_date DATE;
ls_contact VARCHAR2(3);
li_due number;

CURSOR c_invoice IS
SELECT t1.MIT_AWARD_NUMBER,t1.SEQUENCE_NUMBER,t1.PAYMENT_INVOICE_FREQ_CODE,t1.INVOICE_NUMBER_OF_COPIES,t1.FINAL_INVOICE_DUE
FROM OSP$AWARD_HEADER t1
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t2 ON t1.MIT_AWARD_NUMBER = t2.MIT_AWARD_NUMBER AND t1.SEQUENCE_NUMBER = t2.SEQUENCE_NUMBER
WHERE t2.FEED_TYPE = 'N'
AND t1.FINAL_INVOICE_DUE IS NOT NULL;
r_invoice c_invoice%ROWTYPE;

BEGIN

SELECT REPORT_CODE INTO ls_report_code_1  FROM REPORT WHERE DESCRIPTION='Final Invoice Due';

IF c_invoice%ISOPEN THEN
CLOSE c_invoice;
END IF;
OPEN c_invoice;
LOOP
FETCH c_invoice INTO r_invoice;
EXIT WHEN c_invoice%NOTFOUND;

begin
li_due:=to_number(r_invoice.FINAL_INVOICE_DUE);
exception
when others then
li_due:=0;
end;
   
  IF r_invoice.INVOICE_NUMBER_OF_COPIES IS NOT NULL OR r_invoice.FINAL_INVOICE_DUE IS NOT NULL THEN
   
     
  
  SELECT SEQUENCE_AWARD_ID.NEXTVAL INTO li_award_report_terms_id FROM DUAL;
  BEGIN
  SELECT to_date(FINAL_EXPIRATION_DATE) INTO ll_date FROM OSP$AWARD_AMOUNT_INFO WHERE MIT_AWARD_NUMBER=r_invoice.MIT_AWARD_NUMBER AND SEQUENCE_NUMBER=r_invoice.SEQUENCE_NUMBER
  AND AMOUNT_SEQUENCE_NUMBER=(SELECT MAX(AMOUNT_SEQUENCE_NUMBER) FROM OSP$AWARD_AMOUNT_INFO WHERE MIT_AWARD_NUMBER=r_invoice.MIT_AWARD_NUMBER AND SEQUENCE_NUMBER=r_invoice.SEQUENCE_NUMBER);
  EXCEPTION
  WHEN OTHERS THEN
  ll_date:=NULL;
  END;
  
  if ll_date is not null then
  
   ll_date:= ll_date + li_due;
   
  end if; 
  
  ls_award_number:=replace(r_invoice.MIT_AWARD_NUMBER,'-','-00');
  BEGIN
  SELECT AWARD_ID INTO li_award_id FROM AWARD WHERE AWARD_NUMBER=ls_award_number AND SEQUENCE_NUMBER=r_invoice.SEQUENCE_NUMBER;
  EXCEPTION
  WHEN OTHERS THEN  
	  BEGIN
	  SELECT CHANGE_AWARD_NUMBER into ls_award_number FROM KC_MIG_AWARD_CONV WHERE AWARD_NUMBER=ls_award_number;
	  SELECT AWARD_ID INTO li_award_id FROM AWARD WHERE AWARD_NUMBER=ls_award_number AND SEQUENCE_NUMBER=r_invoice.SEQUENCE_NUMBER;
	  EXCEPTION
	  WHEN OTHERS THEN
	  dbms_output.put_line(ls_award_number||' '||r_invoice.SEQUENCE_NUMBER);
	  CONTINUE;
	  END;
  END;
SELECT CONTACT_TYPE_CODE INTO  ls_contact FROM CONTACT_TYPE WHERE DESCRIPTION='Payment Invoice Contact';
BEGIN
 INSERT INTO AWARD_REPORT_TERMS(AWARD_REPORT_TERMS_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
 VALUES(li_award_report_terms_id,li_award_id,ls_award_number,r_invoice.SEQUENCE_NUMBER,'6',ls_report_code_1,14,6,NULL,ll_date,1,SYSDATE,'admin',SYS_GUID());
 
 INSERT INTO AWARD_REP_TERMS_RECNT(AWARD_REP_TERMS_RECNT_ID,CONTACT_ID,AWARD_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
 VALUES(SEQ_AWARD_REP_TERMS_RECNT_ID.NEXTVAL,NULL,li_award_report_terms_id,ls_contact,li_rolodex_id,r_invoice.INVOICE_NUMBER_OF_COPIES,1,SYSDATE,'admin',SYS_GUID());
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('DUE_DATE:'||ll_date||'MIT_AWARD_NUMBER:'||r_invoice.MIT_AWARD_NUMBER||'SEQUENCE_NUMBER:'||r_invoice.SEQUENCE_NUMBER);
END;
END IF;  
END LOOP;
CLOSE c_invoice;
END;
/
---------- Report class code 6 End ------
select ' Ended AWARD_REPORT_TERMS,AWARD_REP_TERMS_RECNT ' from dual
/