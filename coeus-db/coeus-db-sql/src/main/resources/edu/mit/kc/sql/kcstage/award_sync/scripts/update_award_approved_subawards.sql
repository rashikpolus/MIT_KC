select ' Started UPDATE_AWARD_APPROVED_SUBAWARDS ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
ls_award_number VARCHAR2(40);

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.SUBCONTRACTOR_NAME,o.ORGANIZATION_ID,ac.AMOUNT,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
INNER  JOIN OSP$AWARD_APPROVED_SUBCONTRACT@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
left outer join ORGANIZATION o on ac.SUBCONTRACTOR_NAME=o.ORGANIZATION_NAME 
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
	
	   IF ls_award_number IS NULL THEN

             DELETE FROM AWARD_APPROVED_SUBAWARDS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.KUALI_SEQUENCE_NUMBER;
             ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.KUALI_SEQUENCE_NUMBER;
   
  
        ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.KUALI_SEQUENCE_NUMBER THEN
  
             DELETE FROM AWARD_APPROVED_SUBAWARDS WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND SEQUENCE_NUMBER=r_award_comment.KUALI_SEQUENCE_NUMBER;
             ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.KUALI_SEQUENCE_NUMBER;

        END IF;

        INSERT INTO AWARD_APPROVED_SUBAWARDS( AWARD_APPROVED_SUBAWARD_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ORGANIZATION_NAME,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ORGANIZATION_ID,OBJ_ID)
	    VALUES(SEQ_AWARD_APPROVED_SUBAWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.SEQUENCE_NUMBER,r_award_comment.SUBCONTRACTOR_NAME,r_award_comment.AMOUNT,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,r_award_comment.ORGANIZATION_ID,SYS_GUID());
    
exception
when others then
	dbms_output.put_line('Error in update of AWARD_APPROVED_SUBAWARDS. AWARD_NUMBER,SEQUENCE_NUMBER'||r_award_comment.AWARD_NUMBER||','||r_award_comment.SEQUENCE_NUMBER||'-'||sqlerrm);
end;	
	
END LOOP;
CLOSE c_award_comment;
END;
/
select ' Ended UPDATE_AWARD_APPROVED_SUBAWARDS ' from dual
/