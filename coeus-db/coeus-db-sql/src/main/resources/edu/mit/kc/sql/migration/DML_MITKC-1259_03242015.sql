DECLARE
li_commit_count NUMBER;
ll_comment clob;
CURSOR c_awd IS
SELECT t1.award_special_review_id ,t2.AWARD_NUMBER,t2.SEQUENCE_NUMBER, t1.AWARD_ID, t1.SPECIAL_REVIEW_NUMBER 
FROM AWARD_SPECIAL_REVIEW t1 INNER JOIN AWARD t2 on t1.AWARD_ID = t2.AWARD_ID ;
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
		from OSP$AWARD_SPECIAL_REVIEW a1
		where a1.MIT_AWARD_NUMBER = r_awd.AWARD_NUMBER
		and  a1.SEQUENCE_NUMBER = (   SELECT MAX(a.SEQUENCE_NUMBER)
		FROM OSP$AWARD_SPECIAL_REVIEW a WHERE a.SPECIAL_REVIEW_NUMBER = r_awd.SPECIAL_REVIEW_NUMBER
		AND a.MIT_AWARD_NUMBER = r_awd.AWARD_NUMBER 
		AND a.SEQUENCE_NUMBER <= r_awd.SEQUENCE_NUMBER
		)
		and  a1.SPECIAL_REVIEW_NUMBER = r_awd.SPECIAL_REVIEW_NUMBER;

	exception      
	when no_data_found then      
	ll_comment := null;
	end;

	UPDATE  AWARD_SPECIAL_REVIEW 
	SET COMMENTS = ll_comment
	WHERE award_special_review_id = r_awd.award_special_review_id; 


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