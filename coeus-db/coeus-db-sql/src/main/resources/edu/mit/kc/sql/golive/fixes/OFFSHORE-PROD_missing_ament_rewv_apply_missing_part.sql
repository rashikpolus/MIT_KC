set serveroutput on;
declare
li_action_id number(12);
li_protocol_id number(12);
li_submission_id number(12);
li_reviewer_id number(12);
li_count number(4);
cursor c_protocol_submission is
	select pa.proto_amend_ren_number,pa.protocol_number,pa.sequence_number,ps.protocol_id,ps.SUBMISSION_ID,ps.submission_number
	from TMP_MISSING_AMEND_RENW_PROTO pa inner join protocol_submission ps
	on  pa.protocol_number = ps.protocol_number and pa.sequence_number = ps.sequence_number
	order by ps.protocol_number,ps.sequence_number,ps.submission_number;
r_protocol_submission  c_protocol_submission%rowtype;

begin
if c_protocol_submission%isopen then
close c_protocol_submission;
end if;
open c_protocol_submission;
loop
fetch c_protocol_submission into r_protocol_submission;
exit when c_protocol_submission%notfound;

	begin
     select protocol_id into li_protocol_id from protocol where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0;
	 select submission_id into li_submission_id from protocol_submission where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0 and submission_number = r_protocol_submission.submission_number;
	exception 
	when others then 
		dbms_output.put_line('Exception in submission_id ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
		continue;
	end;

	begin
	 select protocol_reviewer_id into li_reviewer_id from protocol_reviewers where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0 and submission_number = r_protocol_submission.submission_number;
	exception
	when others then 
		li_reviewer_id := null;
	end;
	 
	 select count(protocol_id_fk) into li_count from comm_schedule_minutes where protocol_id_fk = li_protocol_id and submission_id_fk = li_submission_id;
	if li_count = 0 then
       
	   begin
		   insert into comm_schedule_minutes(comm_schedule_minutes_id,final_flag,reviewer_id_fk,schedule_id_fk,protocol_id_fk,entry_number,minute_entry_type_code,submission_id_fk,private_comment_flag,protocol_contingency_code,minute_entry,update_timestamp,update_user,ver_nbr,obj_id,protocol_onln_rvw_fk,comm_schedule_act_items_id_fk,create_user,create_timestamp)
		   select seq_meeting_id.nextval,final_flag,li_reviewer_id,schedule_id_fk,li_protocol_id,entry_number,minute_entry_type_code,li_submission_id,private_comment_flag,protocol_contingency_code,minute_entry,update_timestamp,update_user,1,sys_guid(),protocol_onln_rvw_fk,comm_schedule_act_items_id_fk,create_user,create_timestamp
		   from comm_schedule_minutes
		   where protocol_id_fk = r_protocol_submission.protocol_id 
		   and submission_id_fk = r_protocol_submission.SUBMISSION_ID;
	   exception
       when others then
       dbms_output.put_line('Exception in comm_schedule_minutes ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
	end if;
	
end loop;
close c_protocol_submission;
end;
/
