select ' Started AWARD_SCIENCE_KEYWORD ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
li_award_pers_unit_id NUMBER(12,0);
li_award_id NUMBER(12,0);
ls_award_number VARCHAR2(40) := null;
li_seq NUMBER(4,0);

CURSOR c_award_comment IS
SELECT a.AWARD_NUMBER,a.SEQUENCE_NUMBER  Kuali_sequence_number,a.AWARD_ID,ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.SCIENCE_CODE,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER FROM AWARD a 
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
LEFT OUTER JOIN OSP$AWARD_SCIENCE_CODE@coeus.kuali ac ON t.MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER
WHERE ac.SEQUENCE_NUMBER=(select max(SEQUENCE_NUMBER) from OSP$AWARD_SCIENCE_CODE@coeus.kuali where MIT_AWARD_NUMBER=ac.MIT_AWARD_NUMBER)
AND t.FEED_TYPE = 'N'
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
    IF r_award_comment.sequence_number<>1 THEN
      li_seq:=r_award_comment.sequence_number - 1;
  
        BEGIN
	     select award_id into li_award_id from award where award_number=r_award_comment.AWARD_NUMBER and sequence_number=li_seq;
        EXCEPTION
	    WHEN OTHERS THEN
	     dbms_output.put_line('Error while fetching AWARD_ID using AWARD_NUMBER:'||r_award_comment.AWARD_NUMBER||' and SEQUENCE_NUMBER:'||li_seq||'and error is:'||sqlerrm);
	    END;
    END IF;

    IF r_award_comment.MIT_AWARD_NUMBER IS NULL THEN
	
	   IF ls_award_number is null THEN
	      IF r_award_comment.sequence_number<>1 THEN 
	         BEGIN
	        INSERT INTO AWARD_SCIENCE_KEYWORD(AWARD_SCIENCE_KEYWORD_ID,AWARD_ID,VER_NBR,SCIENCE_KEYWORD_CODE,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	        SELECT SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,1,SCIENCE_KEYWORD_CODE,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() FROM AWARD_SCIENCE_KEYWORD
          WHERE AWARD_ID=li_award_id;
           EXCEPTION
	         WHEN OTHERS THEN
	            dbms_output.put_line('Missing data in AWARD,AWARD_NUMBER/SEQUENCE NUMBER - AWARD_ID:'||r_award_comment.MIT_AWARD_NUMBER||' / '||li_seq||'-'||li_award_id||sqlerrm);
            END;
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		   
		ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number THEN
		       BEGIN
          INSERT INTO AWARD_SCIENCE_KEYWORD(AWARD_SCIENCE_KEYWORD_ID,AWARD_ID,VER_NBR,SCIENCE_KEYWORD_CODE,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	        SELECT SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,1,SCIENCE_KEYWORD_CODE,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() FROM AWARD_SCIENCE_KEYWORD
          WHERE AWARD_ID=li_award_id;
           EXCEPTION
	         WHEN OTHERS THEN
	            dbms_output.put_line('Missing data in AWARD,AWARD_NUMBER/SEQUENCE NUMBER - AWARD_ID:'||r_award_comment.MIT_AWARD_NUMBER||' / '||li_seq||'-'||li_award_id||sqlerrm);
           END;
    
            ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		 END IF;	
			
		END IF;
	
    ELSE
	
     BEGIN
     INSERT INTO AWARD_SCIENCE_KEYWORD(AWARD_SCIENCE_KEYWORD_ID,AWARD_ID,VER_NBR,SCIENCE_KEYWORD_CODE,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	   VALUES(SEQUENCE_AWARD_ID.NEXTVAL,r_award_comment.AWARD_ID,1,r_award_comment.SCIENCE_CODE,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,SYS_GUID());
    EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('Missing data in AWARD,AWARD_NUMBER/SEQUENCE NUMBER - AWARD_ID:'||r_award_comment.MIT_AWARD_NUMBER||' / '||li_seq||'-'||li_award_id||sqlerrm);
    END;
	END IF;	

END LOOP;
CLOSE c_award_comment;
END;
/	
select ' Ended AWARD_SCIENCE_KEYWORD script ' from dual
/