DROP TABLE TMP_AWARD_ATTACHMENT_PROD;
CREATE TABLE TMP_AWARD_ATTACHMENT_PROD
   (AWARD_ATTACHMENT_ID NUMBER(12,0), 
	AWARD_ID NUMBER(22,0) NOT NULL ENABLE, 
	AWARD_NUMBER VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	SEQUENCE_NUMBER NUMBER(4,0) NOT NULL ENABLE, 
	TYPE_CODE VARCHAR2(3 BYTE) NOT NULL ENABLE, 
	DOCUMENT_ID NUMBER(4,0) NOT NULL ENABLE, 
	FILE_ID NUMBER(22,0) NOT NULL ENABLE, 
	DESCRIPTION VARCHAR2(200 BYTE), 
	VER_NBR NUMBER(8,0) DEFAULT 1 NOT NULL ENABLE, 
	UPDATE_TIMESTAMP DATE NOT NULL ENABLE, 
	UPDATE_USER VARCHAR2(60 BYTE) NOT NULL ENABLE); 
commit;
/
insert into TMP_AWARD_ATTACHMENT_PROD(AWARD_ATTACHMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TYPE_CODE,DOCUMENT_ID,FILE_ID,DESCRIPTION,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER)
select AWARD_ATTACHMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TYPE_CODE,DOCUMENT_ID,FILE_ID,DESCRIPTION,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER from AWARD_ATTACHMENT;
commit;
/
DECLARE
li_commit_count number:=0;
CURSOR c_awd IS
	SELECT AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER  from AWARD
	where AWARD_NUMBER in(SELECT AWARD_NUMBER FROM TMP_AWARD_ATTACHMENT_PROD)
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

	INSERT INTO award_attachment( AWARD_ATTACHMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TYPE_CODE,DOCUMENT_ID,FILE_ID,DESCRIPTION,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	SELECT SEQ_AWARD_ATTACHMENT_ID.NEXTVAL,r_awd.AWARD_ID,r_awd.AWARD_NUMBER,r_awd.SEQUENCE_NUMBER,TYPE_CODE,DOCUMENT_ID,FILE_ID,DESCRIPTION,1,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID()
	FROM TMP_AWARD_ATTACHMENT_PROD t1 
	WHERE t1.AWARD_NUMBER = r_awd.AWARD_NUMBER
	AND  t1.TYPE_CODE IN (	 SELECT DISTINCT t2.TYPE_CODE  FROM TMP_AWARD_ATTACHMENT_PROD t2 
								WHERE  t2.AWARD_NUMBER = r_awd.AWARD_NUMBER
								AND t2.SEQUENCE_NUMBER < r_awd.SEQUENCE_NUMBER );
				 
								 
	li_commit_count := li_commit_count + 1;
    if li_commit_count =1000 then
       li_commit_count:=0;
		commit;
    end if;							 
	
END LOOP;
CLOSE c_awd;
END;
/
commit
/
declare
li_award_attachment number(12);
li_commit_count number:=0;
cursor c_del is
select AWARD_ID,TYPE_CODE,DOCUMENT_ID,FILE_ID FROM AWARD_ATTACHMENT GROUP BY AWARD_ID,TYPE_CODE,DOCUMENT_ID,FILE_ID
HAVING COUNT(AWARD_ID)>1;
r_del c_del%rowtype;

begin
if c_del%isopen then
close c_del;
end if;
open c_del;
loop
fetch c_del into r_del;
exit when c_del%notfound;

select max(award_attachment_id) into li_award_attachment 
from award_attachment 
where award_id=r_del.award_id 
and type_code=r_del.type_code 
and document_id=r_del.document_id 
and file_id = r_del.file_id;

delete from award_attachment
where award_id=r_del.award_id 
and type_code=r_del.type_code 
and document_id=r_del.document_id 
and file_id = r_del.file_id
and award_attachment_id <> li_award_attachment;

	li_commit_count := li_commit_count + 1;
    if li_commit_count =1000 then
       li_commit_count:=0;
		commit;
    end if;	
end loop;
close c_del;
end;
/
commit
/