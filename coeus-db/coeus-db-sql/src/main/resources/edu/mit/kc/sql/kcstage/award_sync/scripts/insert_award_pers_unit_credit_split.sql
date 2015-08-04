select ' Started AWARD_PERS_UNIT_CRED_SPLITS ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
ls_award_number VARCHAR2(40) := null;

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.PERSON_ID,ac.UNIT_NUMBER,ac.INV_CREDIT_TYPE_CODE,ac.CREDIT,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
LEFT OUTER JOIN OSP$AWARD_UNIT_CREDIT_SPLIT@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER 
WHERE ac.SEQUENCE_NUMBER=(SELECT MAX(SEQUENCE_NUMBER) FROM OSP$AWARD_UNIT_CREDIT_SPLIT@coeus.kuali WHERE MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER)
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

begin
select award_person_unit_id into li_award_pers_unit_id from award_person_units a 
inner join award_persons ap ON a.award_person_id=ap.award_person_id 
where ap.award_number=r_award_comment.award_number and ap.sequence_number=r_award_comment.Kuali_sequence_number
and ap.PERSON_ID=r_award_comment.PERSON_ID OR ap.ROLODEX_ID=r_award_comment.PERSON_ID and ap.contact_role_code <> 'KP';

exception
when others then
dbms_output.put_line('Error in "insert_award_pers_unit_credit_split.sql" '||r_award_comment.award_number||','||r_award_comment.Kuali_sequence_number||','||r_award_comment.PERSON_ID||' - '||sqlerrm);
continue;
end;
   
   BEGIN

    IF r_award_comment.MIT_AWARD_NUMBER IS NULL THEN
	
	   IF ls_award_number is null THEN
	
	        INSERT INTO AWARD_PERS_UNIT_CRED_SPLITS(APU_CREDIT_SPLIT_ID,AWARD_PERSON_UNIT_ID,INV_CREDIT_TYPE_CODE,CREDIT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	        SELECT SEQUENCE_AWARD_ID.NEXTVAL,li_award_pers_unit_id,INV_CREDIT_TYPE_CODE,CREDIT,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM AWARD_PERS_UNIT_CRED_SPLITS
            WHERE AWARD_PERSON_UNIT_ID=(SELECT MAX(aw.AWARD_PERSON_UNIT_ID) FROM award_person_units aw where aw.AWARD_PERSON_UNIT_ID<li_award_pers_unit_id);
    
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number THEN
		
		    INSERT INTO AWARD_PERS_UNIT_CRED_SPLITS(APU_CREDIT_SPLIT_ID,AWARD_PERSON_UNIT_ID,INV_CREDIT_TYPE_CODE,CREDIT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	        SELECT SEQUENCE_AWARD_ID.NEXTVAL,li_award_pers_unit_id,INV_CREDIT_TYPE_CODE,CREDIT,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM AWARD_PERS_UNIT_CRED_SPLITS
            WHERE AWARD_PERSON_UNIT_ID=(SELECT MAX(aw.AWARD_PERSON_UNIT_ID) FROM award_person_units aw where aw.AWARD_PERSON_UNIT_ID<li_award_pers_unit_id);
    
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
			
		END IF;
		
	ELSE
	

       INSERT INTO AWARD_PERS_UNIT_CRED_SPLITS(APU_CREDIT_SPLIT_ID,AWARD_PERSON_UNIT_ID,INV_CREDIT_TYPE_CODE,CREDIT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	   VALUES(SEQUENCE_AWARD_ID.NEXTVAL,li_award_pers_unit_id,r_award_comment.INV_CREDIT_TYPE_CODE,r_award_comment.CREDIT,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,SYS_GUID());
    
	END IF;	
	
	EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('Error in "insert_award_pers_unit_credit_split.sql" '||r_award_comment.award_number||','||r_award_comment.Kuali_sequence_number||','||r_award_comment.PERSON_ID||','||r_award_comment.INV_CREDIT_TYPE_CODE||' - '||sqlerrm);
	END;
	
END LOOP;
CLOSE c_award_comment;
END;
/	
select ' Ended AWARD_PERS_UNIT_CRED_SPLITS ' from dual
/