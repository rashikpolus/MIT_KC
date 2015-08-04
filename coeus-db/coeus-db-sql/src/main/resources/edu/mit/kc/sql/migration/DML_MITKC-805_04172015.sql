declare
ls_protocol_number varchar2(20);
li_seq number(4,0);
li_submission_id number(12,0);

cursor c_protocol is
select distinct p.PROTOCOL_ID,p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER from PROTOCOL p inner join TEMP_SEQ_LOG t
on p.PROTOCOL_ID = t.MODULE_ID
left outer join PROTOCOL_SUBMISSION s 
on p.PROTOCOL_NUMBER = s.PROTOCOL_NUMBER and p.SEQUENCE_NUMBER = s.SEQUENCE_NUMBER
where s.PROTOCOL_NUMBER is null and p.SEQUENCE_NUMBER<> 0 
order by p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER;
r_protocol c_protocol%rowtype;


begin
    if c_protocol%isopen then
        close c_protocol;
	end if;
    open c_protocol;
    loop
    fetch c_protocol into r_protocol;
    exit when c_protocol%notfound;
    
      ls_protocol_number := r_protocol.PROTOCOL_NUMBER;
      li_seq := r_protocol.SEQUENCE_NUMBER;
        
                begin
		             insert into PROTOCOL_SUBMISSION(SUBMISSION_ID,
					                                 PROTOCOL_NUMBER,
													 SEQUENCE_NUMBER,
													 SUBMISSION_NUMBER,
													 SCHEDULE_ID,
													 COMMITTEE_ID,
													 PROTOCOL_ID,
													 SCHEDULE_ID_FK,
													 COMMITTEE_ID_FK,
													 SUBMISSION_TYPE_CODE,
													 SUBMISSION_TYPE_QUAL_CODE,
													 SUBMISSION_STATUS_CODE,
													 PROTOCOL_REVIEW_TYPE_CODE,
													 SUBMISSION_DATE,
													 COMMENTS,
													 YES_VOTE_COUNT,
													 NO_VOTE_COUNT,
													 ABSTAINER_COUNT,
													 VOTING_COMMENTS,
													 UPDATE_TIMESTAMP,
													 UPDATE_USER,
													 VER_NBR,
													 OBJ_ID,
													 RECUSED_COUNT,
													 IS_BILLABLE,
													 COMM_DECISION_MOTION_TYPE_CODE)
		                                      select SEQ_PROTOCOL_ID.NEXTVAL,
											         r_protocol.PROTOCOL_NUMBER,
													 r_protocol.SEQUENCE_NUMBER,
													 SUBMISSION_NUMBER,
													 SCHEDULE_ID,
													 COMMITTEE_ID,
													 r_protocol.PROTOCOL_ID,
													 SCHEDULE_ID_FK,
													 COMMITTEE_ID_FK,
													 SUBMISSION_TYPE_CODE,
													 SUBMISSION_TYPE_QUAL_CODE,
													 SUBMISSION_STATUS_CODE,
													 PROTOCOL_REVIEW_TYPE_CODE,
													 SUBMISSION_DATE,
													 COMMENTS,
													 YES_VOTE_COUNT,
													 NO_VOTE_COUNT,
													 ABSTAINER_COUNT,
													 VOTING_COMMENTS,
													 UPDATE_TIMESTAMP,
													 UPDATE_USER,
													 1,
													 sys_guid(),
													 RECUSED_COUNT,
													 IS_BILLABLE,
													 COMM_DECISION_MOTION_TYPE_CODE
											    from PROTOCOL_SUBMISSION
												where PROTOCOL_NUMBER = ls_protocol_number 
												and SEQUENCE_NUMBER = (select MAX(ps.SEQUENCE_NUMBER) from PROTOCOL_SUBMISSION ps 
                                                where PROTOCOL_NUMBER = ls_protocol_number and SEQUENCE_NUMBER<li_seq);	
												
				exception
                when others then
                  dbms_output.put_line('PROTOCOL_NUMBER: '||ls_protocol_number||' SEQUENCE_NUMBER: '||li_seq);	
				  
                end;
				
	end loop;
	close c_protocol;
	
end;
/
commit
/
declare
ls_protocol_number varchar2(20);
li_seq number(4,0);
li_submission_id number(12,0);
li_submission_doc_id number(12,0);

cursor c_protocol is
select distinct p.PROTOCOL_ID,p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER from PROTOCOL p inner join TEMP_SEQ_LOG t
on p.PROTOCOL_ID = t.MODULE_ID
left outer join PROTOCOL_SUBMISSION_DOC s 
on p.PROTOCOL_NUMBER = s.PROTOCOL_NUMBER and p.SEQUENCE_NUMBER = s.SEQUENCE_NUMBER
where s.PROTOCOL_NUMBER is null and p.SEQUENCE_NUMBER<> 0 
order by p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER;
r_protocol c_protocol%rowtype;

cursor c_submission(as_proto varchar2,as_seq number) is
select SUBMISSION_DOC_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,PROTOCOL_ID,SUBMISSION_ID_FK,DOCUMENT_ID,FILE_NAME,DOCUMENT,
UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,DESCRIPTION,CONTENT_TYPE from PROTOCOL_SUBMISSION_DOC
where PROTOCOL_NUMBER = as_proto and SEQUENCE_NUMBER = (select MAX(ps.SEQUENCE_NUMBER) from PROTOCOL_SUBMISSION_DOC ps 
where PROTOCOL_NUMBER = as_proto and SEQUENCE_NUMBER<as_seq);
r_submission c_submission%rowtype;

begin
    if c_protocol%isopen then
        close c_protocol;
	end if;
    open c_protocol;
    loop
    fetch c_protocol into r_protocol;
    exit when c_protocol%notfound;
    
      ls_protocol_number := r_protocol.PROTOCOL_NUMBER;
      li_seq := r_protocol.SEQUENCE_NUMBER;
        
        if c_submission%isopen then
           close c_submission;
        end if;
        open c_submission(ls_protocol_number,li_seq);
		loop
		fetch c_submission into r_submission;
		exit when c_submission%notfound;
		     
			 select SEQ_PROTOCOL_ID.nextval into li_submission_doc_id from DUAL;
			begin 
			 select SUBMISSION_ID into li_submission_id from PROTOCOL_SUBMISSION where PROTOCOL_NUMBER=ls_protocol_number 
			 and SEQUENCE_NUMBER=li_seq and SUBMISSION_NUMBER=r_submission.SUBMISSION_NUMBER;
			exception
            when others then
              continue;
            end; 
			
		    begin
		     insert into PROTOCOL_SUBMISSION_DOC(SUBMISSION_DOC_ID,
			                                     PROTOCOL_NUMBER,
												 SEQUENCE_NUMBER,
												 SUBMISSION_NUMBER,
												 PROTOCOL_ID,
												 SUBMISSION_ID_FK,
												 DOCUMENT_ID,
												 FILE_NAME,
												 DOCUMENT,
												 UPDATE_TIMESTAMP,
												 UPDATE_USER,
												 VER_NBR,
												 OBJ_ID,
												 DESCRIPTION,
												 CONTENT_TYPE)
										  values(li_submission_doc_id,
			                                     r_protocol.PROTOCOL_NUMBER,
												 r_protocol.SEQUENCE_NUMBER,
												 r_submission.SUBMISSION_NUMBER,
												 r_protocol.PROTOCOL_ID,
												 li_submission_id,
												 r_submission.DOCUMENT_ID,
												 r_submission.FILE_NAME,
												 r_submission.DOCUMENT,
												 r_submission.UPDATE_TIMESTAMP,
												 r_submission.UPDATE_USER,
												 1,
												 sys_guid(),
												 r_submission.DESCRIPTION,
												 r_submission.CONTENT_TYPE);
												 
			exception
            when others then
                dbms_output.put_line('PROTOCOL_NUMBER: '||ls_protocol_number||' SEQUENCE_NUMBER: '||li_seq);	
				  
            end;			
												 
		end loop;
		close c_submission;
		
    end loop;
	close c_protocol;
	
end;
/
commit
/		
declare
ls_protocol_number varchar2(20);
li_seq number(4,0);
li_submission_id number(12,0);
li_protocol_action_id number(12,0);

cursor c_protocol is
select distinct p.PROTOCOL_ID,p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER from PROTOCOL p inner join TEMP_SEQ_LOG t
on p.PROTOCOL_ID = t.MODULE_ID
left outer join PROTOCOL_ACTIONS s 
on p.PROTOCOL_NUMBER = s.PROTOCOL_NUMBER and p.SEQUENCE_NUMBER = s.SEQUENCE_NUMBER
where s.PROTOCOL_NUMBER is null and p.SEQUENCE_NUMBER<> 0 
order by p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER;
r_protocol c_protocol%rowtype;

cursor c_submission(as_proto varchar2,as_seq number) is
select PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,ACTION_ID,PROTOCOL_ACTION_TYPE_CODE,PROTOCOL_ID,SUBMISSION_ID_FK,
COMMENTS,ACTION_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ACTUAL_ACTION_DATE,OBJ_ID,PREV_SUBMISSION_STATUS_CODE,SUBMISSION_TYPE_CODE,
PREV_PROTOCOL_STATUS_CODE,FOLLOWUP_ACTION_CODE from PROTOCOL_ACTIONS
where PROTOCOL_NUMBER = as_proto and SEQUENCE_NUMBER = (select MAX(ps.SEQUENCE_NUMBER) from PROTOCOL_ACTIONS ps 
where PROTOCOL_NUMBER = as_proto and SEQUENCE_NUMBER<as_seq);
r_submission c_submission%rowtype;

begin
    if c_protocol%isopen then
        close c_protocol;
	end if;
    open c_protocol;
    loop
    fetch c_protocol into r_protocol;
    exit when c_protocol%notfound;
    
      ls_protocol_number := r_protocol.PROTOCOL_NUMBER;
      li_seq := r_protocol.SEQUENCE_NUMBER;
        
        if c_submission%isopen then
           close c_submission;
        end if;
        open c_submission(ls_protocol_number,li_seq);
		loop
		fetch c_submission into r_submission;
		exit when c_submission%notfound;
		
		         select SEQ_PROTOCOL_ID.NEXTVAL into li_protocol_action_id from DUAL;
				 begin
				 select SUBMISSION_ID into li_submission_id from PROTOCOL_SUBMISSION where PROTOCOL_NUMBER=ls_protocol_number 
				 and SEQUENCE_NUMBER=li_seq and SUBMISSION_NUMBER=r_submission.SUBMISSION_NUMBER;
				 exception
				 when others then
				 continue;
				 end;
				
				begin
			     insert into PROTOCOL_ACTIONS(PROTOCOL_ACTION_ID,
				                              PROTOCOL_NUMBER,
											  SEQUENCE_NUMBER,
											  SUBMISSION_NUMBER,
											  ACTION_ID,
											  PROTOCOL_ACTION_TYPE_CODE,
											  PROTOCOL_ID,
											  SUBMISSION_ID_FK,
											  COMMENTS,
											  ACTION_DATE,
											  UPDATE_TIMESTAMP,
											  UPDATE_USER,
											  VER_NBR,
											  ACTUAL_ACTION_DATE,
											  OBJ_ID,
											  PREV_SUBMISSION_STATUS_CODE,
											  SUBMISSION_TYPE_CODE,
											  PREV_PROTOCOL_STATUS_CODE,
											  FOLLOWUP_ACTION_CODE)
									   values(li_protocol_action_id,
				                              r_protocol.PROTOCOL_NUMBER,
											  r_protocol.SEQUENCE_NUMBER,
											  r_submission.SUBMISSION_NUMBER,
											  r_submission.ACTION_ID,
											  r_submission.PROTOCOL_ACTION_TYPE_CODE,
											  r_protocol.PROTOCOL_ID,
											  li_submission_id,
											  r_submission.COMMENTS,
											  r_submission.ACTION_DATE,
											  r_submission.UPDATE_TIMESTAMP,
											  r_submission.UPDATE_USER,
											  1,
											  r_submission.ACTUAL_ACTION_DATE,
											  sys_guid(),
											  r_submission.PREV_SUBMISSION_STATUS_CODE,
											  r_submission.SUBMISSION_TYPE_CODE,
											  r_submission.PREV_PROTOCOL_STATUS_CODE,
											  r_submission.FOLLOWUP_ACTION_CODE);
											  
		        exception
                when others then
                    dbms_output.put_line('PROTOCOL_NUMBER: '||ls_protocol_number||' SEQUENCE_NUMBER: '||li_seq);	
				  
                end;

		end loop;
		close c_submission;
		
    end loop;
	close c_protocol;
	
end;
/
commit
/
declare
ls_protocol_number varchar2(20);
li_seq number(4,0);
li_submission_id number(12,0);
li_reviewer_id number(12,0);

cursor c_protocol is
select distinct p.PROTOCOL_ID,p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER from PROTOCOL p inner join TEMP_SEQ_LOG t
on p.PROTOCOL_ID = t.MODULE_ID
left outer join PROTOCOL_REVIEWERS s 
on p.PROTOCOL_NUMBER = s.PROTOCOL_NUMBER and p.SEQUENCE_NUMBER = s.SEQUENCE_NUMBER
where s.PROTOCOL_NUMBER is null and p.SEQUENCE_NUMBER<> 0 
order by p.PROTOCOL_NUMBER,p.SEQUENCE_NUMBER;
r_protocol c_protocol%rowtype;

cursor c_submission(as_proto varchar2,as_seq number) is
select PROTOCOL_ID,SUBMISSION_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,PERSON_ID,NON_EMPLOYEE_FLAG,
REVIEWER_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER,ROLODEX_ID from PROTOCOL_REVIEWERS
where PROTOCOL_NUMBER = as_proto and SEQUENCE_NUMBER = (select MAX(ps.SEQUENCE_NUMBER) from PROTOCOL_REVIEWERS ps 
where PROTOCOL_NUMBER = as_proto and SEQUENCE_NUMBER<as_seq);
r_submission c_submission%rowtype;

begin
    if c_protocol%isopen then
        close c_protocol;
	end if;
    open c_protocol;
    loop
    fetch c_protocol into r_protocol;
    exit when c_protocol%notfound;
    
      ls_protocol_number := r_protocol.PROTOCOL_NUMBER;
      li_seq := r_protocol.SEQUENCE_NUMBER;
        
        if c_submission%isopen then
           close c_submission;
        end if;
        open c_submission(ls_protocol_number,li_seq);
		loop
		fetch c_submission into r_submission;
		exit when c_submission%notfound;
		
		      select SEQ_PROTOCOL_ID.nextval into li_reviewer_id from DUAL;
			  begin
                 select SUBMISSION_ID into li_submission_id from PROTOCOL_SUBMISSION where PROTOCOL_NUMBER=ls_protocol_number 
				 and SEQUENCE_NUMBER=li_seq and SUBMISSION_NUMBER=r_submission.SUBMISSION_NUMBER;
              exception
              when others then
              continue;
              end;
			  
			begin  
			  insert into PROTOCOL_REVIEWERS(PROTOCOL_REVIEWER_ID,
			                                 PROTOCOL_ID,
											 SUBMISSION_ID_FK,
											 PROTOCOL_NUMBER,
											 SEQUENCE_NUMBER,
											 SUBMISSION_NUMBER,
											 PERSON_ID,
											 NON_EMPLOYEE_FLAG,
											 REVIEWER_TYPE_CODE,
											 UPDATE_TIMESTAMP,
											 UPDATE_USER,
											 VER_NBR,
											 OBJ_ID,
											 ROLODEX_ID)
									  values(li_reviewer_id,
			                                 r_protocol.PROTOCOL_ID,
											 li_submission_id,
											 r_protocol.PROTOCOL_NUMBER,
											 r_protocol.SEQUENCE_NUMBER,
											 r_submission.SUBMISSION_NUMBER,
											 r_submission.PERSON_ID,
											 r_submission.NON_EMPLOYEE_FLAG,
											 r_submission.REVIEWER_TYPE_CODE,
											 r_submission.UPDATE_TIMESTAMP,
											 r_submission.UPDATE_USER,
											 1,
											 sys_guid(),
											 r_submission.ROLODEX_ID);
											 
			exception
            when others then
                dbms_output.put_line('PROTOCOL_NUMBER: '||ls_protocol_number||' SEQUENCE_NUMBER: '||li_seq);	
				  
            end;								 
		    

		end loop;
		close c_submission;
		
    end loop;
	close c_protocol;
	
end;
/
commit
/