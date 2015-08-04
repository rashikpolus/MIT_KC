select ' Started UPDATE_AWARD_PERSON_CREDIT_SPLITS ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
ls_award_number VARCHAR2(40);

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.PERSON_ID,ac.INV_CREDIT_TYPE_CODE,ac.CREDIT,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER JOIN OSP$AWARD_PER_CREDIT_SPLIT@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
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

select award_person_id into li_award_pers_unit_id from award_persons 
where award_number=r_award_comment.award_number and sequence_number=r_award_comment.Kuali_sequence_number
and (PERSON_ID = r_award_comment.PERSON_ID or ROLODEX_ID = r_award_comment.PERSON_ID)and contact_role_code <> 'KP';

begin
 	
	   IF ls_award_number is null THEN
	
	        DELETE FROM AWARD_PERSON_CREDIT_SPLITS WHERE AWARD_PERSON_ID in(select award_person_id  from award_persons where award_number=r_award_comment.award_number and sequence_number=r_award_comment.Kuali_sequence_number);
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER THEN
		
		    DELETE FROM AWARD_PERSON_CREDIT_SPLITS WHERE AWARD_PERSON_ID in(select award_person_id  from award_persons where award_number=r_award_comment.award_number and sequence_number=r_award_comment.Kuali_sequence_number);
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
			
		END IF;
	
   
       INSERT INTO AWARD_PERSON_CREDIT_SPLITS(AWARD_PERSON_CREDIT_SPLIT_ID,AWARD_PERSON_ID,INV_CREDIT_TYPE_CODE,CREDIT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	   VALUES(SEQUENCE_AWARD_ID.NEXTVAL,li_award_pers_unit_id,r_award_comment.INV_CREDIT_TYPE_CODE,r_award_comment.CREDIT,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,SYS_GUID());

exception
when others then
	dbms_output.put_line('Error in update of AWARD_PERSON_CREDIT_SPLITS. AWARD_NUMBER,SEQUENCE_NUMBER'||r_award_comment.AWARD_NUMBER||','||r_award_comment.SEQUENCE_NUMBER||'-'||sqlerrm);
end;	    
	
END LOOP;
CLOSE c_award_comment;
END;
/
select ' Ended UPDATE_AWARD_PERSON_CREDIT_SPLITS ' from dual
/