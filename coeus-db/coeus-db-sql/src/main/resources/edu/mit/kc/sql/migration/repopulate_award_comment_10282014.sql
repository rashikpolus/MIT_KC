truncate table AWARD_COMMENT
/
drop table OSP$AWARD_COMMENTS
/
declare
	li_count number;
begin
     select count(*) into li_count from user_tables where table_name='OSP$AWARD_COMMENTS';
     if li_count=0 then
       execute immediate('CREATE TABLE OSP$AWARD_COMMENTS(
							MIT_AWARD_NUMBER	VARCHAR2(10),
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
  select MIT_AWARD_NUMBER,
  SEQUENCE_NUMBER,
  COMMENT_CODE,
  CHECKLIST_PRINT_FLAG,
  COMMENTS,
  UPDATE_TIMESTAMP,
  UPDATE_USER
  FROM OSP$AWARD_COMMENTS@coeus.kuali;
r_comment c_comment%rowtype;

begin
	select count(mit_award_number) into li_count from OSP$AWARD_COMMENTS;
	if li_count = 0 then

		open c_comment;
		loop
		fetch c_comment into r_comment;
		exit when c_comment%NOTFOUND;   

		INSERT INTO OSP$AWARD_COMMENTS(
		  MIT_AWARD_NUMBER,
		  SEQUENCE_NUMBER,
		  COMMENT_CODE,
		  CHECKLIST_PRINT_FLAG,
		  COMMENTS,
		  UPDATE_TIMESTAMP,
		  UPDATE_USER
		)
		  values( r_comment.MIT_AWARD_NUMBER,
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
update  OSP$AWARD_COMMENTS set AWARD_NUMBER = replace(MIT_AWARD_NUMBER,'-','-00')
/
commit
/
ALTER TABLE OSP$AWARD_COMMENTS MODIFY ( COMMENTS CLOB )
/
CREATE INDEX osp$AWARD_COMMENT_I1 on OSP$AWARD_COMMENTS(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_CODE)
/
ALTER TABLE OSP$AWARD_COMMENTS ADD CONSTRAINT OSP$AWARD_COMMENTSPK PRIMARY KEY (MIT_AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_CODE)
/
INSERT INTO AWARD_COMMENT(AWARD_COMMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_TYPE_CODE,CHECKLIST_PRINT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
select SEQ_AWARD_COMMENT_ID.NEXTVAL,t2.AWARD_ID,t1.AWARD_NUMBER,t1.SEQUENCE_NUMBER,t1.comment_code,t1.checklist_print_flag,t1.update_timestamp,t1.update_user,1,sys_guid() 
FROM OSP$AWARD_COMMENTS t1 
inner join AWARD t2 on t1.award_number = t2.award_number and t1.sequence_number = t2.sequence_number
/
CREATE INDEX AWARD_COMMENT_I1 ON AWARD_COMMENT(AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_TYPE_CODE)
/
------------------------------------------------------------------------------------------------------
DECLARE
li_count number(4,0);
ls_award_number VARCHAR2(12);
li_seq number(4,0);
ls_mitaward_number VARCHAR2(12);
ls_coeus_comment_typ	NUMBER(3,0);

CURSOR c_awd IS
SELECT AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER FROM AWARD
ORDER BY AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER;
r_awd c_awd%ROWTYPE;

CURSOR c_awd_comment(as_awd varchar2,as_seq number) IS
SELECT AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_TYPE_CODE,CHECKLIST_PRINT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,COMMENTS FROM AWARD_COMMENT
WHERE AWARD_NUMBER=as_awd AND SEQUENCE_NUMBER=(SELECT MAX(ac.SEQUENCE_NUMBER) FROM AWARD_COMMENT ac WHERE ac.AWARD_NUMBER=as_awd AND ac.SEQUENCE_NUMBER<as_seq);
r_awd_comment c_awd_comment%ROWTYPE;


BEGIN

IF c_awd%ISOPEN THEN
CLOSE c_awd;
END IF;
OPEN c_awd;
LOOP
FETCH c_awd INTO r_awd;
EXIT WHEN c_awd% NOTFOUND;

ls_award_number:=r_awd.AWARD_NUMBER;
li_seq:=r_awd.SEQUENCE_NUMBER;

if li_seq <> 1 then

	IF c_awd_comment%ISOPEN THEN
	CLOSE c_awd_comment;
	END IF;
	OPEN c_awd_comment(ls_award_number,li_seq);
	LOOP
	FETCH c_awd_comment INTO r_awd_comment;
	EXIT WHEN c_awd_comment% NOTFOUND;

	SELECT COUNT(*) INTO li_count FROM AWARD_COMMENT WHERE AWARD_NUMBER=r_awd.AWARD_NUMBER AND SEQUENCE_NUMBER=r_awd.SEQUENCE_NUMBER  AND COMMENT_TYPE_CODE=r_awd_comment.COMMENT_TYPE_CODE;

	IF li_count=0 THEN

		INSERT INTO AWARD_COMMENT(AWARD_COMMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_TYPE_CODE,CHECKLIST_PRINT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
		VALUES(SEQ_AWARD_COMMENT_ID.NEXTVAL,r_awd.AWARD_ID,r_awd.AWARD_NUMBER,r_awd.SEQUENCE_NUMBER,r_awd_comment.COMMENT_TYPE_CODE,r_awd_comment.CHECKLIST_PRINT_FLAG,r_awd_comment.UPDATE_TIMESTAMP,r_awd_comment.UPDATE_USER,1,SYS_GUID());

		
	
	END IF;

	END LOOP;
	CLOSE c_awd_comment;
	
end if;
	
END LOOP;
CLOSE c_awd;
END;
/
--------------------------------------------------------------------------------------------------------------------------
ALTER TABLE OSP$AWARD_COMMENTS DROP CONSTRAINT OSP$AWARD_COMMENTSPK
/
DROP INDEX osp$AWARD_COMMENT_I1
/
commit
/
CREATE INDEX osp$AWARD_COMMENT_I1 on OSP$AWARD_COMMENTS(AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_CODE)
/
ALTER TABLE OSP$AWARD_COMMENTS ADD CONSTRAINT OSP$AWARD_COMMENTSPK PRIMARY KEY (AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_CODE)
/
DECLARE
li_commit_count NUMBER;
ll_comment clob;
CURSOR c_awd IS
SELECT AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_TYPE_CODE FROM AWARD_COMMENT ;
r_awd c_awd%ROWTYPE;

BEGIN

IF c_awd%ISOPEN THEN
CLOSE c_awd;
END IF;
OPEN c_awd;
LOOP
FETCH c_awd INTO r_awd;
EXIT WHEN c_awd% NOTFOUND;
	
        
         begin
            select a1.COMMENTS into ll_comment
            from OSP$AWARD_COMMENTS a1
            where a1.AWARD_NUMBER = r_awd.AWARD_NUMBER
            and  a1.SEQUENCE_NUMBER = (   SELECT MAX(a.SEQUENCE_NUMBER)
                          FROM OSP$AWARD_COMMENTS a WHERE a.COMMENT_CODE = r_awd.COMMENT_TYPE_CODE
                          AND a.AWARD_NUMBER = r_awd.AWARD_NUMBER 
                          AND a.SEQUENCE_NUMBER <= r_awd.SEQUENCE_NUMBER
                        )
            and  a1.COMMENT_CODE = r_awd.COMMENT_TYPE_CODE;
            
        exception      
        when no_data_found then      
        ll_comment := null;
        end;
		
				UPDATE /*+ index(award_comment AWARD_COMMENT_I1) */ AWARD_COMMENT 
				SET COMMENTS = ll_comment
				WHERE AWARD_NUMBER = r_awd.AWARD_NUMBER 
				AND SEQUENCE_NUMBER = r_awd.SEQUENCE_NUMBER
				AND COMMENT_TYPE_CODE = r_awd.COMMENT_TYPE_CODE; 
		
		
	li_commit_count:= li_commit_count + 1;
	
	if li_commit_count = 1000 then
		li_commit_count:=0;    
		commit;
	end if;
	
END LOOP;
CLOSE c_awd;
END;
/
commit
/