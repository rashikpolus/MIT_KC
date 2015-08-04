DROP TABLE OSP$EPS_PROP_YNQ
/
CREATE TABLE OSP$EPS_PROP_YNQ(
PROPOSAL_NUMBER	VARCHAR2(8),
QUESTION_ID	VARCHAR2(4),
ANSWER	CHAR(1),
EXPLANATION	LONG,
REVIEW_DATE	DATE,
UPDATE_TIMESTAMP	DATE,
UPDATE_USER	VARCHAR2(8)
)
/
declare
	li_count number;
cursor c_ynq is
SELECT	PROPOSAL_NUMBER,
	QUESTION_ID,
	ANSWER,
	EXPLANATION,
	REVIEW_DATE,
	UPDATE_TIMESTAMP,
	UPDATE_USER
  FROM OSP$EPS_PROP_YNQ@coeus.kuali;
r_ynq c_ynq%rowtype;

begin
	select count(PROPOSAL_NUMBER) into li_count from OSP$EPS_PROP_YNQ;
	if li_count = 0 then

		open c_ynq;
		loop
		fetch c_ynq into r_ynq;
		exit when c_ynq%NOTFOUND;   

		INSERT INTO OSP$EPS_PROP_YNQ(
		    PROPOSAL_NUMBER,
			QUESTION_ID,
			ANSWER,
			EXPLANATION,
			REVIEW_DATE,
			UPDATE_TIMESTAMP,
			UPDATE_USER
		)
		  values(  r_ynq.PROPOSAL_NUMBER,
			r_ynq.QUESTION_ID,
			r_ynq.ANSWER,
			r_ynq.EXPLANATION,
			r_ynq.REVIEW_DATE,
			r_ynq.UPDATE_TIMESTAMP,
			r_ynq.UPDATE_USER);
		  
		end loop;
		close c_ynq;
		
	end if;
		
end;
/

commit
/
ALTER TABLE OSP$EPS_PROP_YNQ MODIFY ( EXPLANATION CLOB )
/
CREATE INDEX OSP$EPS_PROP_YNQ_I1 on OSP$EPS_PROP_YNQ(PROPOSAL_NUMBER,QUESTION_ID)
/
DELETE FROM EPS_PROP_YNQ WHERE PROPOSAL_NUMBER in (SELECT to_number(proposal_number) from osp$eps_prop_ynq@coeus.kuali)
/
commit
/
insert into EPS_PROP_YNQ(PROPOSAL_NUMBER,QUESTION_ID,ANSWER,EXPLANATION,REVIEW_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,SORT_ID)
select to_number(PROPOSAL_NUMBER) ,QUESTION_ID,ANSWER,EXPLANATION,REVIEW_DATE,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID(),
ROW_NUMBER() OVER (PARTITION BY PROPOSAL_NUMBER ORDER BY PROPOSAL_NUMBER) SORT_ID from OSP$EPS_PROP_YNQ
/
commit
/
declare
l_tmp long;
ls_expl CLOB;
li_count_org_ynq number;
li_commit_count number:=0;

CURSOR c_data is
	SELECT proposal_number,update_timestamp,update_user from osp$eps_proposal@coeus.kuali;
r_data c_data%rowtype;

li_sort_id NUMBER(12);
BEGIN	
	open c_data;
	loop
	fetch c_data into r_data;
	exit when c_data%notfound;
		BEGIN
			select nvl(max(sort_id),1) into li_sort_id from eps_prop_ynq where proposal_number = to_number(r_data.proposal_number);
		
			insert into EPS_PROP_YNQ(PROPOSAL_NUMBER,QUESTION_ID,ANSWER,EXPLANATION,REVIEW_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,SORT_ID)
			select to_number(r_data.proposal_number), t1.QUESTION_ID, null, null,null,r_data.update_timestamp,r_data.update_user,1,sys_guid(),(li_sort_id + rownum)
			from YNQ t1 
			left outer join osp$eps_prop_ynq t2 on t2.proposal_number = r_data.proposal_number and t1.question_id = t2.question_id
			WHERE t2.question_id is null
			and UPPER(t1.QUESTION_TYPE) = UPPER('P')
			and t1.status = 'A'
			and upper(t1.group_name) = upper('Proposal Questions');
		
		EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line('Exception occoured Missing YNQ '||sqlerrm);
		END;	
		
	end loop;
	close c_data;
	

END; 
/