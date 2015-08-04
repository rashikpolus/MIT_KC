select ' Started AWARD_REPORT_TRACKING script ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
ls_award_number varchar2(40);
li_award_reports_id NUMBER(12,0);

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER AWARD_NUMBER,a.SEQUENCE_NUMBER SEQUENCE_NUMBER,a.AWARD_ID AWARD_ID,ap.PERSON_ID PERSON_ID,ap.ROLODEX_ID ROLODEX_ID,ap.full_name full_name,
apu.unit_number lead_unit_number,ac.REPORT_STATUS_CODE status_code,a.sponsor_code sponsor_code,a.sponsor_award_number sponsor_award_number,
a.title title,ac.REPORT_NUMBER REPORT_NUMBER,ac.REPORT_CLASS_CODE REPORT_CLASS_CODE,ac.REPORT_CODE REPORT_CODE,
ac.FREQUENCY_CODE FREQUENCY_CODE,ac.FREQUENCY_BASE_CODE FREQUENCY_BASE_CODE,ac.OSP_DISTRIBUTION_CODE OSP_DISTRIBUTION_CODE,
ac.FREQUENCY_BASE FREQUENCY_BASE,ac.DUE_DATE,ac.OVERDUE_COUNTER,ac.REPORT_STATUS_CODE,ac.ACTIVITY_DATE,ac.comments,ac.UPDATE_TIMESTAMP,
ac.UPDATE_USER,ac.NOTIFICATION_WINDOW,ac.NOTIFICATION_ID,ac.PERSON_ID as PREPARER_ID 
FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER JOIN AWARD_PERSONS ap on a.AWARD_NUMBER=ap.AWARD_NUMBER and a.SEQUENCE_NUMBER=ap.SEQUENCE_NUMBER
INNER JOIN AWARD_PERSON_UNITS apu on ap.AWARD_PERSON_ID=apu.AWARD_PERSON_ID 
INNER JOIN OSP$AWARD_REPORTING@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER 
WHERE a.sequence_number=(SELECT max(aw.sequence_number) FROM AWARD aw WHERE aw.AWARD_NUMBER=a.AWARD_NUMBER) and t.FEED_TYPE='N'
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
 
begin
 
 select MAX(AWARD_REPORT_TERMS_ID) into li_award_reports_id from AWARD_REPORT_TERMS 
 where AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.SEQUENCE_NUMBER
 AND REPORT_CLASS_CODE=r_award_comment.REPORT_CLASS_CODE AND REPORT_CODE=r_award_comment.REPORT_CODE 
 AND FREQUENCY_CODE=r_award_comment.FREQUENCY_CODE AND FREQUENCY_BASE_CODE=r_award_comment.FREQUENCY_BASE_CODE 
 AND OSP_DISTRIBUTION_CODE=r_award_comment.OSP_DISTRIBUTION_CODE;


 
exception
when others then

--dbms_output.put_line('Error in "insert_award_report_tracking.sql" '||r_award_comment.award_number||','||r_award_comment.SEQUENCE_NUMBER||','||r_award_comment.OSP_DISTRIBUTION_CODE||' - '||sqlerrm);

 select MAX(AWARD_REPORT_TERMS_ID) into li_award_reports_id from AWARD_REPORT_TERMS 
 where AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.SEQUENCE_NUMBER
 AND REPORT_CLASS_CODE=r_award_comment.REPORT_CLASS_CODE AND REPORT_CODE=r_award_comment.REPORT_CODE 
 AND FREQUENCY_CODE=r_award_comment.FREQUENCY_CODE AND FREQUENCY_BASE_CODE=r_award_comment.FREQUENCY_BASE_CODE 
 AND OSP_DISTRIBUTION_CODE=r_award_comment.OSP_DISTRIBUTION_CODE AND DUE_DATE=r_award_comment.DUE_DATE ;
 
continue;
end;
    
INSERT INTO AWARD_REPORT_TRACKING(AWARD_REPORT_TERM_ID,AWARD_NUMBER,PI_PERSON_ID,PI_ROLODEX_ID,PI_NAME,LEAD_UNIT_NUMBER,REPORT_CLASS_CODE,
REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,STATUS_CODE,BASE_DATE,DUE_DATE,ACTIVITY_DATE,OVERDUE,COMMENTS,
PREPARER_ID,PREPARER_NAME,SPONSOR_CODE,SPONSOR_AWARD_NUMBER,TITLE,LAST_UPDATE_USER,LAST_UPDATE_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_award_reports_id,r_award_comment.AWARD_NUMBER,r_award_comment.PERSON_ID,r_award_comment.ROLODEX_ID,r_award_comment.full_name,r_award_comment.lead_unit_number,r_award_comment.REPORT_CLASS_CODE,
r_award_comment.REPORT_CODE,r_award_comment.FREQUENCY_CODE,r_award_comment.FREQUENCY_BASE_CODE,r_award_comment.OSP_DISTRIBUTION_CODE,
r_award_comment.STATUS_CODE,null,r_award_comment.DUE_DATE,r_award_comment.ACTIVITY_DATE,
r_award_comment.OVERDUE_COUNTER,r_award_comment.COMMENTS,
r_award_comment.PREPARER_ID,null,r_award_comment.SPONSOR_CODE,r_award_comment.SPONSOR_AWARD_NUMBER,r_award_comment.TITLE,r_award_comment.UPDATE_USER,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,SYS_GUID());


	   
END LOOP;
CLOSE c_award_comment;
END;
/	
commit
/ 
UPDATE award_report_tracking t1
SET t1.preparer_name = ( select t2.prncpl_nm from krim_prncpl_t t2 where t2.prncpl_id = t1.preparer_id)
where exists ( select t3.prncpl_nm from krim_prncpl_t t3 where t3.prncpl_id = t1.preparer_id )
and t1.PREPARER_NAME  is null
/
commit
/
select ' Ended AWARD_REPORT_TRACKING ' from dual
/