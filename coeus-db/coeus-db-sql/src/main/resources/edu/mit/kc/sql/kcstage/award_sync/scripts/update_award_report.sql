select ' Started UPDATE_AWARD_REP_TERMS_RECNT ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
ls_award_number varchar2(40);
li_award_reports_id NUMBER(12,0);
li_count number;
ls_distribution_code VARCHAR2(3);
CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.REPORT_CLASS_CODE,ac.REPORT_CODE,ac.FREQUENCY_CODE,ac.FREQUENCY_BASE_CODE,ac.OSP_DISTRIBUTION_CODE,ac.CONTACT_TYPE_CODE,ac.ROLODEX_ID,ac.DUE_DATE,ac.NUMBER_OF_COPIES,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER JOIN OSP$AWARD_REPORT_TERMS@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
WHERE t.FEED_TYPE='C'
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

select count(OSP_DISTRIBUTION_CODE) into li_count FROM DISTRIBUTION WHERE OSP_DISTRIBUTION_CODE=r_award_comment.OSP_DISTRIBUTION_CODE;
  IF li_count=0 THEN
    ls_distribution_code:=-1;
	ELSE
	  ls_distribution_code:=r_award_comment.OSP_DISTRIBUTION_CODE;
  END IF;
 
 if ls_distribution_code = -1 then
	ls_distribution_code := null;
 end if;
 
 
 select SEQUENCE_AWARD_ID.NEXTVAL into li_award_reports_id from dual;
	
	     IF ls_award_number is null THEN
		 
		     DELETE FROM AWARD_REP_TERMS_RECNT WHERE AWARD_REPORT_TERMS_ID in (SELECT AWARD_REPORT_TERMS_ID FROM AWARD_REPORT_TERMS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number);
	         DELETE FROM AWARD_REPORT_TERMS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
	         
	           ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
		   
		 ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER THEN
		 
		      DELETE FROM AWARD_REP_TERMS_RECNT WHERE AWARD_REPORT_TERMS_ID in (SELECT AWARD_REPORT_TERMS_ID FROM AWARD_REPORT_TERMS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number);
	          DELETE FROM AWARD_REPORT_TERMS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
	         
		       ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
			   
		 END IF;  
begin

       INSERT INTO AWARD_REPORT_TERMS(AWARD_REPORT_TERMS_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	   VALUES(li_award_reports_id,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,r_award_comment.REPORT_CLASS_CODE,r_award_comment.REPORT_CODE,r_award_comment.FREQUENCY_CODE,r_award_comment.FREQUENCY_BASE_CODE,ls_distribution_code,r_award_comment.DUE_DATE,1,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,SYS_GUID());
	   
	   INSERT INTO AWARD_REP_TERMS_RECNT(AWARD_REP_TERMS_RECNT_ID,CONTACT_ID,AWARD_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID) 
       VALUES(SEQ_AWARD_REP_TERMS_RECNT_ID.NEXTVAL,null,li_award_reports_id,r_award_comment.CONTACT_TYPE_CODE,r_award_comment.ROLODEX_ID,r_award_comment.NUMBER_OF_COPIES,1,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,SYS_GUID());

exception
when others then
dbms_output.put_line('Error in "update_award_report.sql" '||r_award_comment.award_number||','||r_award_comment.Kuali_sequence_number||','||ls_distribution_code||' - '||sqlerrm);
continue;
end;	   
	
END LOOP;
CLOSE c_award_comment;
END;
/
select ' Ended UPDATE_AWARD_REP_TERMS_RECNT ' from dual
/