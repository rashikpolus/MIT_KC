select ' Started UPDATE_AWARD_SPONSOR_TERM ' from dual
/
DECLARE
li_cust_id NUMBER(12,0);
ls_award_number VARCHAR2(40);

CURSOR c_award_comment IS
SELECT ac.AWARD_ID,ac.AWARD_NUMBER,ac.SEQUENCE_NUMBER kuali_sequence_number,a.MIT_AWARD_NUMBER,a.SEQUENCE_NUMBER,a.SPONSOR_TERM_ID,a.UPDATE_TIMESTAMP,a.UPDATE_USER FROM AWARD ac INNER JOIN 
TEMP_TAB_TO_SYNC_AWARD t ON ac.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND ac.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER INNER JOIN (
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_EQUIPMENT_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.EQUIPMENT_APPROVAL_CODE = st.sponsor_term_code and 1 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_DOCUMENT_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.REFERENCED_DOCUMENT_CODE = st.sponsor_term_code and 6 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_INVENTION_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.INVENTION_CODE = st.sponsor_term_code and 2 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_PRIOR_APPROVAL_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.PRIOR_APPROVAL_CODE = st.sponsor_term_code and 3 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_PROPERTY_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.PROPERTY_CODE = st.sponsor_term_code and 4 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_PUBLICATION_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.PUBLICATION_CODE = st.sponsor_term_code and 5 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_RIGHTS_IN_DATA_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.RIGHTS_IN_DATA_CODE = st.sponsor_term_code and 7 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_SUBCONTRACT_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.SUBCONTRACT_APPROVAL_CODE = st.sponsor_term_code and 8 = st.sponsor_term_type_code
UNION
SELECT aet.MIT_AWARD_NUMBER,aet.SEQUENCE_NUMBER,st.SPONSOR_TERM_ID,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER FROM OSP$AWARD_TRAVEL_TERMS@coeus.kuali aet
left outer join SPONSOR_TERM st on aet.TRAVEL_RESTRICTION_CODE = st.sponsor_term_code and 9 = st.sponsor_term_type_code)a ON t.MIT_AWARD_NUMBER=a.MIT_AWARD_NUMBER and t.SEQUENCE_NUMBER=a.SEQUENCE_NUMBER
WHERE t.FEED_TYPE='C'
ORDER BY ac.AWARD_NUMBER,ac.SEQUENCE_NUMBER;
r_award_comment c_award_comment%ROWTYPE;

BEGIN
IF c_award_comment%ISOPEN THEN
CLOSE c_award_comment;
END IF;
OPEN c_award_comment;
LOOP
FETCH c_award_comment INTO r_award_comment;
EXIT WHEN c_award_comment%NOTFOUND;


    
	
	   IF ls_award_number is null THEN
	
	      DELETE FROM AWARD_SPONSOR_TERM WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
		  
          ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
       
	   ELSIF ls_award_number<>r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number THEN 
	   
	      DELETE FROM AWARD_SPONSOR_TERM WHERE AWARD_NUMBER=r_award_comment.AWARD_NUMBER and SEQUENCE_NUMBER=r_award_comment.Kuali_sequence_number;
          ls_award_number:=r_award_comment.AWARD_NUMBER||r_award_comment.Kuali_sequence_number;
		  
	   END IF;
	   

         INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
         VALUES(SEQ_AWARD_SPONSOR_TERM.NEXTVAL,r_award_comment.AWARD_ID,r_award_comment.AWARD_NUMBER,r_award_comment.Kuali_sequence_number,r_award_comment.SPONSOR_TERM_ID,r_award_comment.UPDATE_TIMESTAMP,r_award_comment.UPDATE_USER,1,SYS_GUID());

	
END LOOP;
CLOSE c_award_comment;
END;
/
select ' Ended UPDATE_AWARD_SPONSOR_TERM ' from dual
/