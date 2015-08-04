select ' Started UPDATE_AWARD_SPONSOR_CONTACTS ' from dual
/
DECLARE

li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
ls_award_number VARCHAR2(40);

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.CONTACT_TYPE_CODE,ac.ROLODEX_ID,FN_GET_FULL_NAME(r.FIRST_NAME,r.MIDDLE_NAME,r.LAST_NAME) FULL_NAME,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER JOIN OSP$AWARD_CONTACT@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
LEFT OUTER JOIN ROLODEX r ON ac.ROLODEX_ID=r.ROLODEX_ID
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

begin

	   IF ls_award_number is null THEN
	
	          DELETE FROM AWARD_SPONSOR_CONTACTS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
              ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number THEN
		
              DELETE FROM AWARD_SPONSOR_CONTACTS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
              ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
			
		END IF;
	

       INSERT INTO AWARD_SPONSOR_CONTACTS(AWARD_SPONSOR_CONTACT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ROLODEX_ID,FULL_NAME,CONTACT_ROLE_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	   VALUES(SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,r_award_comment.ROLODEX_ID,r_award_comment.FULL_NAME,r_award_comment.CONTACT_TYPE_CODE,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,SYS_GUID());

exception
when others then
	dbms_output.put_line('Error in update of AWARD_SPONSOR_CONTACTS. AWARD_NUMBER,SEQUENCE_NUMBER'||r_award_comment.AWARD_NUMBER||','||r_award_comment.Kuali_sequence_number||'-'||sqlerrm);
end; 
 
	
END LOOP;
CLOSE c_award_comment;
END;

/
select ' Ended UPDATE_AWARD_SPONSOR_CONTACTS ' from dual
/