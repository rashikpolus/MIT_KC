declare
	li_count number;
begin
     select count(*) into li_count from user_tables where table_name='OSP$AWARD_COMMENTS_TMP';
     if li_count=0 then
       execute immediate('CREATE TABLE OSP$AWARD_COMMENTS_TMP(
                            AWARD_NUMBER	VARCHAR2(12),
							SEQUENCE_NUMBER	NUMBER(4,0),
							COMMENT_CODE	NUMBER(3,0),
							CHECKLIST_PRINT_FLAG	CHAR(1),
							COMMENTS	LONG,
							UPDATE_TIMESTAMP	DATE,
							UPDATE_USER	VARCHAR2(8)
							)');
	    commit;

     end if;
end;
/
declare
	li_count number;
cursor c_comment is
  select replace(MIT_AWARD_NUMBER,'-','-00') AWARD_NUMBER,
  SEQUENCE_NUMBER,
  COMMENT_CODE,
  CHECKLIST_PRINT_FLAG,
  COMMENTS,
  UPDATE_TIMESTAMP,
  UPDATE_USER
  FROM OSP$AWARD_COMMENTS@coeus.kuali
  WHERE MIT_AWARD_NUMBER  like '%-A%';
r_comment c_comment%rowtype;

begin
	select count(award_number) into li_count from OSP$AWARD_COMMENTS_TMP;
	if li_count = 0 then

		open c_comment;
		loop
		fetch c_comment into r_comment;
		exit when c_comment%NOTFOUND;  

      

		INSERT INTO OSP$AWARD_COMMENTS_TMP(
		  AWARD_NUMBER,
		  SEQUENCE_NUMBER,
		  COMMENT_CODE,
		  CHECKLIST_PRINT_FLAG,
		  COMMENTS,
		  UPDATE_TIMESTAMP,
		  UPDATE_USER
		)
		  values(r_comment.AWARD_NUMBER,
		  r_comment.SEQUENCE_NUMBER,
		  r_comment.COMMENT_CODE,
		  r_comment.CHECKLIST_PRINT_FLAG,
		  r_comment.COMMENTS,
		  r_comment.UPDATE_TIMESTAMP,
		  r_comment.UPDATE_USER);
		  
		end loop;
		close c_comment;
		
	end if;
		
end;
/	
DECLARE
cursor c_conv is
select k.AWARD_NUMBER,k.CHANGE_AWARD_NUMBER FROM KC_MIG_AWARD_CONV k
inner join OSP$AWARD_COMMENTS_TMP o
on k.AWARD_NUMBER = o.AWARD_NUMBER;
r_conv c_conv%rowtype;
BEGIN
if c_conv%isopen then
close c_conv;
end if;
open c_conv;
loop
fetch c_conv into r_conv;
exit when c_conv%notfound;

update OSP$AWARD_COMMENTS_TMP
set AWARD_NUMBER = r_conv.CHANGE_AWARD_NUMBER
where AWARD_NUMBER = r_conv.AWARD_NUMBER;

end loop;
close c_conv;
end;
/
ALTER TABLE OSP$AWARD_COMMENTS_TMP MODIFY ( COMMENTS CLOB )
/
CREATE INDEX OSP$AWARD_COMMENTS_TMP_I1 on OSP$AWARD_COMMENTS_TMP(AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_CODE)
/
CREATE INDEX OSP$AWARD_COMMENTS_TMP_I2 on OSP$AWARD_COMMENTS_TMP(AWARD_NUMBER,SEQUENCE_NUMBER)
/
ALTER TABLE OSP$AWARD_COMMENTS_TMP ADD CONSTRAINT OSP$AWARD_COMMENTS_TMPPK PRIMARY KEY (AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_CODE)
/
DECLARE
	li_count number(4,0);
	ls_award_number VARCHAR2(12);
	li_seq number(4,0);
	ls_mitaward_number VARCHAR2(12);
	ls_coeus_comment_typ	NUMBER(3,0);
CURSOR c_awd IS
	SELECT AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER 
	FROM AWARD
	WHERE AWARD_NUMBER in ( select distinct AWARD_NUMBER FROM OSP$AWARD_COMMENTS_TMP )
	ORDER BY AWARD_NUMBER,SEQUENCE_NUMBER;
	r_awd c_awd%ROWTYPE;
BEGIN

	IF c_awd%ISOPEN THEN
	CLOSE c_awd;
	END IF;
	
	OPEN c_awd;
	LOOP
	FETCH c_awd INTO r_awd;
	EXIT WHEN c_awd% NOTFOUND;
	
	select count(AWARD_NUMBER) into li_count from award_comment where AWARD_NUMBER = r_awd.AWARD_NUMBER and SEQUENCE_NUMBER = r_awd.SEQUENCE_NUMBER;
	
	if li_count=0 then	

		INSERT INTO award_comment( award_comment_id,award_id,award_number,sequence_number,comments,comment_type_code,checklist_print_flag,update_timestamp,
		update_user,ver_nbr,obj_id)
		SELECT seq_award_comment_id.NEXTVAL,r_awd.award_id,r_awd.award_number,r_awd.sequence_number,t1.comments,t1.comment_code,t1.checklist_print_flag,
		t1.update_timestamp,t1.update_user,1,sys_guid()
		FROM OSP$AWARD_COMMENTS_TMP t1 
		WHERE t1.AWARD_NUMBER = r_awd.AWARD_NUMBER
		AND  t1.SEQUENCE_NUMBER IN ( SELECT MAX(t2.SEQUENCE_NUMBER)FROM OSP$AWARD_COMMENTS_TMP t2 
									 WHERE t2.COMMENT_CODE = t1.COMMENT_CODE
									 AND   t2.AWARD_NUMBER = t1.AWARD_NUMBER 
									 AND   t2.SEQUENCE_NUMBER <= r_awd.SEQUENCE_NUMBER );
	end if;							 
								 
	
END LOOP;
CLOSE c_awd;
END;
/
commit
/
