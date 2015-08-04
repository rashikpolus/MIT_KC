alter table PROPOSAL_SPECIAL_REVIEW drop column  COMMENTS
/
commit
/
alter table PROPOSAL_SPECIAL_REVIEW ADD ( COMMENTS LONG )
/
commit
/
ALTER INDEX	PROPOSAL_SPECIAL_REVIEWP1	REBUILD;
commit;
/
CREATE INDEX PROPOSAL_SP_COMMENT_I1 on PROPOSAL_SPECIAL_REVIEW(PROPOSAL_ID,SPECIAL_REVIEW_NUMBER)
/
commit
/
declare
li_commit_count number:=0;

cursor c_comment is
select t2.proposal_id,t2.proposal_number,t2.sequence_number,t1.SPECIAL_REVIEW_NUMBER,t1.comments 
from OSP$PROPOSAL_SPECIAL_REVIEW@coeus.kuali t1 inner join proposal t2
on t1.proposal_number = t2.proposal_number and t1.sequence_number = t2.sequence_number
WHERE t1.comments IS NOT NULL;
r_comment c_comment%ROWTYPE;

Begin

open c_comment;
loop
fetch c_comment into r_comment;
exit when c_comment%NOTFOUND;

  begin
   update /*+ index(PROPOSAL_SPECIAL_REVIEW PROPOSAL_SP_COMMENT_I1) */ PROPOSAL_SPECIAL_REVIEW  T1
   set T1.COMMENTS = r_comment.COMMENTS
   where T1.PROPOSAL_ID = r_comment.PROPOSAL_ID and T1.SPECIAL_REVIEW_NUMBER=r_comment.SPECIAL_REVIEW_NUMBER;
   li_commit_count:= li_commit_count + 1;
   exception
   when others then
   dbms_output.put_line('Error occoured !! where PROPOSAL_ID is '||r_comment.PROPOSAL_ID||' and error is  '||sqlerrm);
   end;
   
    if li_commit_count = 1000 then
		li_commit_count:=0;    
		commit;
	end if;
   
end loop;
close c_comment;
end;
/
declare
li_commit_count number:=0;

cursor c_comm is
select t1.PROPOSAL_ID,t1.SPECIAL_REVIEW_NUMBER,t1.COMMENTS,t2.PROPOSAL_NUMBER,t3.KUALI_SEQUENCE_NUMBER,t3.SEQUENC from PROPOSAL_SPECIAL_REVIEW t1 inner join PROPOSAL t2
ON t1.PROPOSAL_ID=t2.PROPOSAL_ID INNER JOIN TEMP_PROPOSAL_SPECIAL t3 ON t2.PROPOSAL_NUMBER=t3.PROPOSAL_NUMBER AND t2.SEQUENCE_NUMBER=t3.KUALI_SEQUENCE_NUMBER;
r_comm c_comm%ROWTYPE;

Begin

open c_comm;
loop
fetch c_comm into r_comm;
exit when c_comm%NOTFOUND;
begin
   update /*+ index(PROPOSAL_SPECIAL_REVIEW PROPOSAL_SP_COMMENT_I1) */ PROPOSAL_SPECIAL_REVIEW  T1
   set T1.COMMENTS = r_comm.COMMENTS
   where T1.PROPOSAL_ID = (SELECT PROPOSAL_ID FROM PROPOSAL WHERE PROPOSAL_NUMBER=r_comm.PROPOSAL_NUMBER AND SEQUENCE_NUMBER=r_comm.SEQUENC)and T1.SPECIAL_REVIEW_NUMBER=r_comm.SPECIAL_REVIEW_NUMBER;
   li_commit_count:= li_commit_count + 1;
   exception
   when others then
   dbms_output.put_line('Error occoured !! where PROPOSAL_ID is '||r_comm.PROPOSAL_ID||' and error is  '||sqlerrm);
   end;
   
    if li_commit_count = 1000 then
		li_commit_count:=0;    
		commit;
	end if;
   
end loop;
close c_comm;
end;
/
commit
/	
ALTER TABLE PROPOSAL_SPECIAL_REVIEW MODIFY ( COMMENTS CLOB )
/
commit
/
DROP INDEX PROPOSAL_SP_COMMENT_I1
/
ALTER INDEX	PROPOSAL_SPECIAL_REVIEWP1	REBUILD
/
commit
/