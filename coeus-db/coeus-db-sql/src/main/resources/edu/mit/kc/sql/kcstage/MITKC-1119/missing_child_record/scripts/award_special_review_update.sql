alter table AWARD_SPECIAL_REVIEW drop column  COMMENTS
/
commit
/
alter table AWARD_SPECIAL_REVIEW ADD ( COMMENTS LONG )
/
commit
/
ALTER INDEX	AWARD_SPECIAL_REVIEWP1	REBUILD;
commit;
/
declare
li_seq number(4);
ls_award_number VARCHAR2(12);
li_award_id NUMBER(22,0);
l_tmp LONG;
ls_comment CLOB;

CURSOR c_special IS
SELECT a.MIT_AWARD_NUMBER,a.SEQUENCE_NUMBER,a.SPECIAL_REVIEW_NUMBER,a.SPECIAL_REVIEW_CODE,a.APPROVAL_TYPE_CODE,a.PROTOCOL_NUMBER,a.APPLICATION_DATE,a.APPROVAL_DATE,a.COMMENTS,a.UPDATE_USER,a.UPDATE_TIMESTAMP
FROM OSP$AWARD_SPECIAL_REVIEW@coeus.kuali a
inner join REFRESH_AWARD ts on a.MIT_AWARD_NUMBER=ts.MIT_AWARD_NUMBER and a.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER;
r_special c_special%ROWTYPE;

BEGIN
IF c_special%ISOPEN THEN
CLOSE c_special;
END IF;
OPEN c_special;
LOOP
FETCH c_special into r_special;
EXIT WHEN c_special%NOTFOUND;

	begin
	ls_award_number:=replace(r_special.MIT_AWARD_NUMBER,'-','-00');
	li_seq := r_special.SEQUENCE_NUMBER;
	
	select AWARD_ID into li_award_id from AWARD where AWARD_NUMBER=ls_award_number and SEQUENCE_NUMBER=li_seq;	
	
	UPDATE AWARD_SPECIAL_REVIEW
	SET COMMENTS = r_special.COMMENTS
	where AWARD_ID = li_award_id
	and SPECIAL_REVIEW_NUMBER = r_special.SPECIAL_REVIEW_NUMBER;
	
	exception
	when others then
	dbms_output.put_line('Error while fetching AWARD_ID using AWARD_NUMBER:'||ls_award_number||' and SEQUENCE_NUMBER:'||li_seq||'and error is:'||sqlerrm);
	end;

END LOOP;
CLOSE c_special;
END;
/
commit
/
ALTER TABLE AWARD_SPECIAL_REVIEW MODIFY ( COMMENTS CLOB )
/
commit
/
ALTER INDEX	AWARD_SPECIAL_REVIEWP1	REBUILD;
commit;
/
