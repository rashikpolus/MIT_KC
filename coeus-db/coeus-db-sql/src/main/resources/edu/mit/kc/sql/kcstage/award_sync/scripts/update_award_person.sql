select ' Started UPDATE_AWARD_PERSONS ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
ls_award_number VARCHAR2(40);
li_count number;
CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,DECODE(r.ROLODEX_ID,null,ac.PERSON_ID,null) PERSON_ID,r.ROLODEX_ID,decode(ac.PRINCIPAL_INVESTIGATOR_FLAG,'Y','PI','N','COI') ROLE_CODE,ac.PERSON_NAME,ac.PRINCIPAL_INVESTIGATOR_FLAG,ac.NON_MIT_PERSON_FLAG,ac.FACULTY_FLAG,ac.CONFLICT_OF_INTEREST_FLAG,ac.PERCENTAGE_EFFORT,ac.FEDR_DEBR_FLAG,ac.FEDR_DELQ_FLAG,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER,ac.MULTI_PI_FLAG,ac.ACADEMIC_YEAR_EFFORT,ac.SUMMER_YEAR_EFFORT,ac.CALENDAR_YEAR_EFFORT FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER JOIN OSP$AWARD_INVESTIGATORS@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
left outer join ROLODEX r on ac.PERSON_ID=r.ROLODEX_ID
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
	
	        DELETE FROM AWARD_PERSONS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER THEN
		
            DELETE FROM AWARD_PERSONS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
    
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
			
		END IF;
	
       SELECT COUNT(AWARD_PERSON_ID) into li_count FROM AWARD_PERSONS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.SEQUENCE_NUMBER AND (PERSON_ID = r_award_comment.PERSON_ID or ROLODEX_ID = r_award_comment.PERSON_ID)and contact_role_code <> 'KP';
	   IF li_count=0 THEN
          INSERT INTO AWARD_PERSONS(AWARD_PERSON_ID,KEY_PERSON_PROJECT_ROLE,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,PERSON_ID,ROLODEX_ID,FULL_NAME,CONTACT_ROLE_CODE,ACADEMIC_YEAR_EFFORT,CALENDAR_YEAR_EFFORT,SUMMER_EFFORT,TOTAL_EFFORT,FACULTY_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	      VALUES(SEQUENCE_AWARD_ID.NEXTVAL,null,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,r_award_comment.PERSON_ID,r_award_comment.ROLODEX_ID,r_award_comment.PERSON_NAME,r_award_comment.ROLE_CODE,r_award_comment.ACADEMIC_YEAR_EFFORT,r_award_comment.CALENDAR_YEAR_EFFORT,r_award_comment.SUMMER_YEAR_EFFORT,r_award_comment.PERCENTAGE_EFFORT,r_award_comment.FACULTY_FLAG,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,SYS_GUID());
       END IF;
exception
when others then
	dbms_output.put_line('Error in update of AWARD_PERSONS. AWARD_NUMBER,SEQUENCE_NUMBER'||r_award_comment.AWARD_NUMBER||','||r_award_comment.SEQUENCE_NUMBER||'-'||sqlerrm);
end;
	
END LOOP;
CLOSE c_award_comment;
END;
/
select ' Ended UPDATE_AWARD_PERSONS ' from dual
/