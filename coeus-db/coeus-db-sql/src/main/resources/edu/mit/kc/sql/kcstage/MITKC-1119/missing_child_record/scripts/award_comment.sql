DECLARE
li_count number(4,0);
ls_award_number VARCHAR2(12);
li_seq number(4,0);
ls_mitaward_number VARCHAR2(12);
ls_coeus_comment_typ	NUMBER(3,0);

CURSOR c_awd IS
SELECT t1.AWARD_ID,t1.AWARD_NUMBER,t1.SEQUENCE_NUMBER 
FROM AWARD t1 
INNER JOIN REFRESH_AWARD t2 ON t1.AWARD_NUMBER = replace(t2.MIT_AWARD_NUMBER,'-','-00') AND t1.SEQUENCE_NUMBER = t2.SEQUENCE_NUMBER
ORDER BY t1.AWARD_ID,t1.AWARD_NUMBER,t1.SEQUENCE_NUMBER;
r_awd c_awd%ROWTYPE;

CURSOR c_awd_comment(as_awd varchar2,as_seq number) IS
SELECT MIT_AWARD_NUMBER,
COMMENT_CODE,
SEQUENCE_NUMBER,
CHECKLIST_PRINT_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER
   FROM OSP$AWARD_COMMENTS@coeus.kuali
   WHERE ( OSP$AWARD_COMMENTS.MIT_AWARD_NUMBER = as_awd ) AND
         ( OSP$AWARD_COMMENTS.SEQUENCE_NUMBER IN ( SELECT MAX(A.SEQUENCE_NUMBER)
			FROM OSP$AWARD_COMMENTS A WHERE A.COMMENT_CODE = OSP$AWARD_COMMENTS. COMMENT_CODE
			AND A.MIT_AWARD_NUMBER = OSP$AWARD_COMMENTS. MIT_AWARD_NUMBER  AND
			A.SEQUENCE_NUMBER <= as_seq) ) ;
r_awd_comment c_awd_comment%ROWTYPE;


BEGIN

IF c_awd%ISOPEN THEN
CLOSE c_awd;
END IF;
OPEN c_awd;
LOOP
FETCH c_awd INTO r_awd;
EXIT WHEN c_awd% NOTFOUND;

ls_award_number:=replace(r_awd.AWARD_NUMBER,'-00','-');
li_seq:=r_awd.SEQUENCE_NUMBER;

if li_seq <> 1 then

	IF c_awd_comment%ISOPEN THEN
	CLOSE c_awd_comment;
	END IF;
	OPEN c_awd_comment(ls_award_number,li_seq);
	LOOP
	FETCH c_awd_comment INTO r_awd_comment;
	EXIT WHEN c_awd_comment% NOTFOUND;

	SELECT COUNT(*) INTO li_count FROM AWARD_COMMENT WHERE AWARD_NUMBER=r_awd.AWARD_NUMBER AND SEQUENCE_NUMBER=r_awd.SEQUENCE_NUMBER  AND COMMENT_TYPE_CODE=r_awd_comment.COMMENT_CODE;

	IF li_count=0 THEN

		INSERT INTO AWARD_COMMENT(AWARD_COMMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,COMMENT_TYPE_CODE,CHECKLIST_PRINT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
		VALUES(SEQ_AWARD_COMMENT_ID.NEXTVAL,r_awd.AWARD_ID,r_awd.AWARD_NUMBER,r_awd.SEQUENCE_NUMBER,r_awd_comment.COMMENT_CODE,r_awd_comment.CHECKLIST_PRINT_FLAG,r_awd_comment.UPDATE_TIMESTAMP,r_awd_comment.UPDATE_USER,1,SYS_GUID());

		
	
	END IF;

	END LOOP;
	CLOSE c_awd_comment;
	
end if;
	
END LOOP;
CLOSE c_awd;
END;
/
DECLARE
li_commit_count NUMBER;
ll_comment clob;
CURSOR c_awd IS
SELECT t1.AWARD_NUMBER,t1.SEQUENCE_NUMBER,t1.COMMENT_TYPE_CODE 
FROM AWARD_COMMENT t1 
INNER JOIN REFRESH_AWARD t2 ON t1.AWARD_NUMBER = replace(t2.MIT_AWARD_NUMBER,'-','-00') AND t1.SEQUENCE_NUMBER = t2.SEQUENCE_NUMBER;
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
            from OSP$AWARD_COMMENTS@coeus.kuali a1
            where replace(a1.MIT_AWARD_NUMBER,'-','-00') = r_awd.AWARD_NUMBER
            and  a1.SEQUENCE_NUMBER = (   SELECT MAX(a.SEQUENCE_NUMBER)
                          FROM OSP$AWARD_COMMENTS@coeus.kuali a WHERE a.COMMENT_CODE = r_awd.COMMENT_TYPE_CODE
                          AND replace(a.MIT_AWARD_NUMBER,'-','-00') = r_awd.AWARD_NUMBER 
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
	
	if li_commit_count = 100 then
		li_commit_count:=0;    
		commit;
	end if;
	
END LOOP;
CLOSE c_awd;
END;
/