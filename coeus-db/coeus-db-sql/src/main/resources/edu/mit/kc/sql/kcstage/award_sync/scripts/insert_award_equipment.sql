select ' Started AWARD_APPROVED_EQUIPMENT ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
ls_award_number VARCHAR2(40) := null;

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.ITEM,ac.VENDOR,ac.MODEL,ac.AMOUNT,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
LEFT OUTER JOIN OSP$AWARD_APPROVED_EQUIPMENT@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=ac.SEQUENCE_NUMBER
WHERE t.FEED_TYPE = 'N'
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
    IF r_award_comment.MIT_AWARD_NUMBER IS NULL THEN
	
	   IF ls_award_number is null THEN
	
	       INSERT INTO AWARD_APPROVED_EQUIPMENT(AWARD_APPROVED_EQUIPMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	       SELECT SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM AWARD_APPROVED_EQUIPMENT
           WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and 	SEQUENCE_NUMBER=(SELECT MAX(aw.SEQUENCE_NUMBER) FROM AWARD_APPROVED_EQUIPMENT aw where aw.AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND aw.SEQUENCE_NUMBER<r_award_comment.Kuali_sequence_number);
        
		   ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number THEN
		
		   INSERT INTO AWARD_APPROVED_EQUIPMENT(AWARD_APPROVED_EQUIPMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	       SELECT SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM AWARD_APPROVED_EQUIPMENT
           WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and 	SEQUENCE_NUMBER=(SELECT MAX(aw.SEQUENCE_NUMBER) FROM AWARD_APPROVED_EQUIPMENT aw where aw.AWARD_NUMBER=r_award_comment.AWARD_NUMBER AND aw.SEQUENCE_NUMBER<r_award_comment.Kuali_sequence_number);
        
		   ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		   
		END IF;   
  
	ELSE	

      INSERT INTO AWARD_APPROVED_EQUIPMENT(AWARD_APPROVED_EQUIPMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	  VALUES(SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,r_award_comment.ITEM,r_award_comment.VENDOR,r_award_comment.MODEL,r_award_comment.AMOUNT,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,SYS_GUID());

	END IF;	
	
exception
when others then
	dbms_output.put_line('ERROR IN AWARD_APPROVED_EQUIPMENT. AWARD_NUMBER,SEQUENCE_NUMBER'||r_award_comment.AWARD_NUMBER||','||r_award_comment.Kuali_sequence_number||'-'||sqlerrm);
end;		
	
	
END LOOP;
CLOSE c_award_comment;
END;
/	
select ' Ended AWARD_APPROVED_EQUIPMENT ' from dual
/