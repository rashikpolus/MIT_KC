select ' Started UPDATE_AWARD_SPECIAL_REVIEW ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
ls_award_number VARCHAR2(40);

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.SPECIAL_REVIEW_NUMBER,ac.SPECIAL_REVIEW_CODE,ac.APPROVAL_TYPE_CODE,ac.PROTOCOL_NUMBER,ac.APPLICATION_DATE,ac.APPROVAL_DATE,ac.COMMENTS,ac.UPDATE_USER,ac.UPDATE_TIMESTAMP FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER JOIN OSP$AWARD_SPECIAL_REVIEW@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
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
	
	        DELETE FROM AWARD_SPECIAL_REVIEW WHERE AWARD_ID=r_award_comment.AWARD_ID;
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER THEN
		
            DELETE FROM AWARD_SPECIAL_REVIEW WHERE AWARD_ID=r_award_comment.AWARD_ID;
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.SEQUENCE_NUMBER;
			
		END IF;

       INSERT INTO AWARD_SPECIAL_REVIEW(AWARD_SPECIAL_REVIEW_ID,EXPIRATION_DATE,AWARD_ID,VER_NBR,SPECIAL_REVIEW_NUMBER,SPECIAL_REVIEW_CODE,APPROVAL_TYPE_CODE,PROTOCOL_NUMBER,APPLICATION_DATE,APPROVAL_DATE,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
	   VALUES(SEQ_AWARD_SPECIAL_REVIEW_ID.NEXTVAL,null,r_award_comment.AWARD_ID,1,r_award_comment.SPECIAL_REVIEW_NUMBER,r_award_comment.SPECIAL_REVIEW_CODE,r_award_comment.APPROVAL_TYPE_CODE,r_award_comment.PROTOCOL_NUMBER,r_award_comment.APPLICATION_DATE,r_award_comment.APPROVAL_DATE,r_award_comment.UPDATE_USER,r_award_comment.UPDATE_TIMESTAMP,SYS_GUID());

exception
when others then
	dbms_output.put_line('Error in update of AWARD_SPECIAL_REVIEW. AWARD_NUMBER,SEQUENCE_NUMBER'||r_award_comment.AWARD_NUMBER||','||r_award_comment.SEQUENCE_NUMBER||'-'||sqlerrm);
end;    
	
END LOOP;
CLOSE c_award_comment;
END;
/
select ' Ended UPDATE_AWARD_SPECIAL_REVIEW ' from dual
/