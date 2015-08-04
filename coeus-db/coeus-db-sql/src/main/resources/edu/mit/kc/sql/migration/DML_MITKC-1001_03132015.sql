drop table OSP$AWARD_SPECIAL_REVIEW
/
declare
	li_count number;
begin
     select count(*) into li_count from user_tables where table_name='OSP$AWARD_SPECIAL_REVIEW';
     if li_count=0 then
       execute immediate('CREATE TABLE OSP$AWARD_SPECIAL_REVIEW(
							                    MIT_AWARD_NUMBER	VARCHAR2(12),
                                  SEQUENCE_NUMBER	NUMBER(4,0),
                                  SPECIAL_REVIEW_NUMBER	NUMBER(3,0),
                                  SPECIAL_REVIEW_CODE	NUMBER(3,0),
                                  APPROVAL_TYPE_CODE	NUMBER(3,0),
                                  PROTOCOL_NUMBER	VARCHAR2(20),
                                  APPLICATION_DATE	DATE,
                                  APPROVAL_DATE	DATE,
                                  COMMENTS	LONG,
                                  UPDATE_USER	VARCHAR2(8),
                                  UPDATE_TIMESTAMP	DATE
							                    )');
	    commit;

     end if;
end;
/

declare
	li_count number;
cursor c_comment is
  select MIT_AWARD_NUMBER,
         SEQUENCE_NUMBER,
         SPECIAL_REVIEW_NUMBER,
         SPECIAL_REVIEW_CODE,
         APPROVAL_TYPE_CODE,
         PROTOCOL_NUMBER,
         APPLICATION_DATE,
         APPROVAL_DATE,
         COMMENTS,
         UPDATE_USER,
         UPDATE_TIMESTAMP
  FROM OSP$AWARD_SPECIAL_REVIEW@coeus.kuali;
r_comment c_comment%rowtype;

begin
	select count(mit_award_number) into li_count from OSP$AWARD_SPECIAL_REVIEW;
	if li_count = 0 then

		open c_comment;
		loop
		fetch c_comment into r_comment;
		exit when c_comment%NOTFOUND; 
    
    INSERT INTO OSP$AWARD_SPECIAL_REVIEW(
         MIT_AWARD_NUMBER,
         SEQUENCE_NUMBER,
         SPECIAL_REVIEW_NUMBER,
         SPECIAL_REVIEW_CODE,
         APPROVAL_TYPE_CODE,
         PROTOCOL_NUMBER,
         APPLICATION_DATE,
         APPROVAL_DATE,
         COMMENTS,
         UPDATE_USER,
         UPDATE_TIMESTAMP
		)
		  values( r_comment.MIT_AWARD_NUMBER,
		  r_comment.SEQUENCE_NUMBER,
		  r_comment.SPECIAL_REVIEW_NUMBER,
		  r_comment.SPECIAL_REVIEW_CODE,
      r_comment.APPROVAL_TYPE_CODE,
      r_comment.PROTOCOL_NUMBER,
      r_comment.APPLICATION_DATE,
      r_comment.APPROVAL_DATE,
		  r_comment.COMMENTS,
		  r_comment.UPDATE_USER,
		  r_comment.UPDATE_TIMESTAMP);
		  
		end loop;
		close c_comment;
		
	end if;
		
end;
/
update  OSP$AWARD_SPECIAL_REVIEW set MIT_AWARD_NUMBER =replace(MIT_AWARD_NUMBER,'-','-00')
/
commit
/
ALTER TABLE OSP$AWARD_SPECIAL_REVIEW MODIFY ( COMMENTS CLOB )
/
CREATE INDEX OSP$AWARD_SPECIAL_REVIEW_I1 on OSP$AWARD_SPECIAL_REVIEW(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,SPECIAL_REVIEW_CODE)
/
ALTER TABLE OSP$AWARD_SPECIAL_REVIEW ADD CONSTRAINT OSP$AWARD_SPECIAL_REVIEWPK PRIMARY KEY (MIT_AWARD_NUMBER,SEQUENCE_NUMBER,SPECIAL_REVIEW_NUMBER,SPECIAL_REVIEW_CODE)
/
declare
cursor c_update is
select AWARD_NUMBER,CHANGE_AWARD_NUMBER from KC_MIG_AWARD_CONV;
r_update c_update%rowtype;
begin
open c_update;
loop
fetch c_update into r_update;
exit when c_update%notfound;
update OSP$AWARD_SPECIAL_REVIEW  set MIT_AWARD_NUMBER = r_update.CHANGE_AWARD_NUMBER where MIT_AWARD_NUMBER = r_update.AWARD_NUMBER;
commit;
end loop;
close c_update;
end;
/ 
DECLARE
ls_awd_number varchar2(12);
li_seq number(4,0);
li_award_special number(12,0);
li_count number;
CURSOR c_award IS
SELECT AWARD_NUMBER,SEQUENCE_NUMBER,AWARD_ID FROM AWARD ORDER BY AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER;
r_award c_award%ROWTYPE;

CURSOR c_amt_info(as_mit varchar2,as_seq number) IS
select MIT_AWARD_NUMBER,SEQUENCE_NUMBER,SPECIAL_REVIEW_NUMBER,SPECIAL_REVIEW_CODE,APPROVAL_TYPE_CODE,PROTOCOL_NUMBER,APPLICATION_DATE,APPROVAL_DATE,COMMENTS,UPDATE_USER,UPDATE_TIMESTAMP FROM OSP$AWARD_SPECIAL_REVIEW
where MIT_AWARD_NUMBER=as_mit and SEQUENCE_NUMBER=(select max(au.SEQUENCE_NUMBER) from OSP$AWARD_SPECIAL_REVIEW au where au.MIT_AWARD_NUMBER=OSP$AWARD_SPECIAL_REVIEW.MIT_AWARD_NUMBER and au.SEQUENCE_NUMBER<=as_seq)
ORDER BY MIT_AWARD_NUMBER,SEQUENCE_NUMBER;
r_amt_info c_amt_info%ROWTYPE;

BEGIN

IF c_award%ISOPEN THEN 
CLOSE c_award;
END IF;
OPEN c_award;
LOOP
FETCH c_award INTO r_award;
EXIT WHEN c_award%NOTFOUND;

ls_awd_number:=r_award.AWARD_NUMBER;
li_seq:=r_award.SEQUENCE_NUMBER;

IF c_amt_info%ISOPEN THEN
CLOSE c_amt_info;
END IF;
OPEN c_amt_info(ls_awd_number,li_seq);
LOOP
FETCH c_amt_info INTO r_amt_info;
EXIT WHEN c_amt_info%NOTFOUND;



select count(AWARD_ID) into li_count from AWARD_SPECIAL_REVIEW where AWARD_ID=r_award.AWARD_ID and  SPECIAL_REVIEW_NUMBER=r_amt_info.SPECIAL_REVIEW_NUMBER and SPECIAL_REVIEW_CODE=r_amt_info.SPECIAL_REVIEW_CODE;

if li_count = 0 then

select SEQ_AWARD_SPECIAL_REVIEW_ID.NEXTVAL into li_award_special from dual;

INSERT INTO AWARD_SPECIAL_REVIEW(AWARD_SPECIAL_REVIEW_ID,EXPIRATION_DATE,AWARD_ID,VER_NBR,COMMENTS,SPECIAL_REVIEW_NUMBER,SPECIAL_REVIEW_CODE,APPROVAL_TYPE_CODE,PROTOCOL_NUMBER,APPLICATION_DATE,APPROVAL_DATE,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
VALUES(li_award_special,null,r_award.AWARD_ID,1,r_amt_info.COMMENTS,r_amt_info.SPECIAL_REVIEW_NUMBER,r_amt_info.SPECIAL_REVIEW_CODE,r_amt_info.APPROVAL_TYPE_CODE,r_amt_info.PROTOCOL_NUMBER,r_amt_info.APPLICATION_DATE,r_amt_info.APPROVAL_DATE,r_amt_info.UPDATE_USER,r_amt_info.UPDATE_TIMESTAMP,sys_guid());

end if;

end loop;
close c_amt_info;
end loop;
close c_award;
end;
/