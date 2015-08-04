select ' Started UPDATE_AWARD_SCIENCE_KEYWORD ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
ls_award_number VARCHAR2(40);

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.SCIENCE_CODE,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER JOIN OSP$AWARD_SCIENCE_CODE@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
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
	
	        DELETE FROM AWARD_SCIENCE_KEYWORD WHERE AWARD_ID=r_award_comment.AWARD_ID;
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER THEN
		
            DELETE FROM AWARD_SCIENCE_KEYWORD WHERE AWARD_ID=r_award_comment.AWARD_ID;
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
			
		END IF;
	
       INSERT INTO AWARD_SCIENCE_KEYWORD(AWARD_SCIENCE_KEYWORD_ID,AWARD_ID,VER_NBR,SCIENCE_KEYWORD_CODE,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	   VALUES(SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,1,r_award_comment.SCIENCE_CODE,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,SYS_GUID());
    
exception
when others then
	dbms_output.put_line('Error in update of AWARD_SCIENCE_KEYWORD. AWARD_NUMBER,SEQUENCE_NUMBER'||r_award_comment.AWARD_NUMBER||','||r_award_comment.SEQUENCE_NUMBER||'-'||sqlerrm);
end;
	
END LOOP;
CLOSE c_award_comment;
END;
/
select ' Ended UPDATE_AWARD_SCIENCE_KEYWORD ' from dual
/