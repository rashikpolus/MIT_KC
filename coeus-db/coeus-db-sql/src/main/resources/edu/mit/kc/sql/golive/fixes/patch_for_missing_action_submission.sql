declare
li_submission_id number(12);
li_protocol_id number(12);
li_count number;
li_cnt number;
li_submission_number number(4,0); 
cursor c_protocol_submission is
select distinct a.proto_amend_ren_number,a.protocol_number,a.sequence_number,b.submission_number 
from TMP_MISSING_AMEND_RENW_PROTO a
inner join
(
  select distinct p.protocol_number,p.sequence_number,p.submission_number from protocol_actions p left outer join protocol_submission s
  on p.protocol_number = s.protocol_number and p.sequence_number = s.sequence_number and p.submission_number = s.submission_number 
  where s.protocol_number is null
) b
on a.protocol_number = b.protocol_number
and a.sequence_number = b.sequence_number
and ( b.submission_number  is null or b.submission_number = 0 );
r_protocol_submission c_protocol_submission%rowtype;

begin
if c_protocol_submission%isopen then
close c_protocol_submission;
end if;
open c_protocol_submission;
loop
fetch c_protocol_submission into r_protocol_submission;
exit when c_protocol_submission%notfound; 

		begin	
			select protocol_id  into li_protocol_id from protocol where protocol_number = r_protocol_submission.proto_amend_ren_number
			and sequence_number = 0;
			
		exception
		when others then  
			dbms_output.put_line('Exception in fetching protocol_id protocol ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
		end;
	  
	    li_submission_id := null;
			
		if r_protocol_submission.submission_number is null then
				select count(protocol_number) into li_cnt from protocol_actions 
				where protocol_number = r_protocol_submission.proto_amend_ren_number
				and sequence_number = 0 
				and submission_number is null;
				
		else
				select count(protocol_number) into li_cnt from protocol_actions 
				where protocol_number = r_protocol_submission.proto_amend_ren_number
				and sequence_number = 0 
				and submission_number = 0;
				
		end if;
	
     
		if li_cnt = 0 then
			
			if r_protocol_submission.submission_number is null then
					begin
					
						insert into protocol_actions(protocol_action_id,protocol_number,sequence_number,submission_number,action_id,protocol_action_type_code,
						protocol_id,
						submission_id_fk,comments,action_date,update_timestamp,update_user,ver_nbr,actual_action_date,obj_id,prev_submission_status_code,
						submission_type_code,prev_protocol_status_code,followup_action_code)
						select seq_protocol_id.nextval,r_protocol_submission.proto_amend_ren_number,0,submission_number,action_id,protocol_action_type_code,
						li_protocol_id,li_submission_id,comments,action_date,update_timestamp,update_user,ver_nbr,actual_action_date,obj_id,prev_submission_status_code,
						submission_type_code,prev_protocol_status_code,followup_action_code
						from protocol_actions
						where protocol_number = r_protocol_submission.protocol_number
						and sequence_number = r_protocol_submission.sequence_number
						and submission_number is null;
						
					exception
					when others then
						dbms_output.put_line('Exception in protocol_actions ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
					end;
			
			else
					begin
					
						insert into protocol_actions(protocol_action_id,protocol_number,sequence_number,submission_number,action_id,protocol_action_type_code,protocol_id,
						submission_id_fk,comments,action_date,update_timestamp,update_user,ver_nbr,actual_action_date,obj_id,prev_submission_status_code,submission_type_code,
						prev_protocol_status_code,followup_action_code)
						select seq_protocol_id.nextval,r_protocol_submission.proto_amend_ren_number,0,submission_number,action_id,protocol_action_type_code,
						li_protocol_id,li_submission_id,comments,action_date,update_timestamp,update_user,ver_nbr,actual_action_date,obj_id,prev_submission_status_code,
						submission_type_code,prev_protocol_status_code,followup_action_code
						from protocol_actions
						where protocol_number = r_protocol_submission.protocol_number
						and sequence_number = r_protocol_submission.sequence_number
						and submission_number = 0;
						
					exception
					when others then
					dbms_output.put_line('Exception in protocol_actions ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
					end;
			
			
			end if;
			
		
		
			
		
		end if;
	

	
end loop;
close c_protocol_submission;
end;
/
declare
li_action_id number(12);
li_protocol_id number(12);
li_submission_id number(12);
li_count number;
li_cnt number;
	cursor c_protocol_submission is
	select  pa.proto_amend_ren_number,pa.protocol_number,pa.sequence_number,ps.submission_number,ps.action_id
	from TMP_MISSING_AMEND_RENW_PROTO pa inner join protocol_actions ps
	on  pa.protocol_number = ps.protocol_number and pa.sequence_number = ps.sequence_number
	where (ps.submission_number  = 0 or ps.submission_number  is  null )
	order by ps.protocol_number,ps.sequence_number,ps.submission_number,ps.action_id;
r_protocol_submission  c_protocol_submission%rowtype;

begin
if c_protocol_submission%isopen then
close c_protocol_submission;
end if;
open c_protocol_submission;
loop
fetch c_protocol_submission into r_protocol_submission;
exit when c_protocol_submission%notfound;

	
	 
      select count(protocol_number) into li_cnt from protocol_correspondence where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0 and action_id = r_protocol_submission.action_id;

	  if li_cnt = 0 then
	 
	
	 
		  begin
		    select protocol_id  into li_protocol_id from protocol where protocol_number = r_protocol_submission.proto_amend_ren_number
			and sequence_number = 0;
      
		  exception
		  when others then
			 dbms_output.put_line('Exception in protocol ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
		  end;

			begin
			select min(protocol_action_id) into li_action_id from protocol_actions where protocol_number = r_protocol_submission.proto_amend_ren_number
			and sequence_number = 0 and nvl(submission_number,-1) = nvl(r_protocol_submission.submission_number,-1)  
			and action_id = r_protocol_submission.action_id and protocol_id = li_protocol_id;
			
			exception
			  when others then
			dbms_output.put_line('Exception in protocol_action_id ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
				continue;
			end;
    
		if li_action_id is not null then
			 begin
				 insert into protocol_correspondence(id,protocol_number,sequence_number,action_id,protocol_id,action_id_fk,proto_corresp_type_code,final_flag,update_timestamp,update_user,ver_nbr,correspondence,obj_id,create_timestamp,create_user,final_flag_timestamp)
				 select seq_protocol_id.nextval,r_protocol_submission.proto_amend_ren_number,0,action_id,li_protocol_id,li_action_id,proto_corresp_type_code,final_flag,update_timestamp,update_user,1,correspondence,sys_guid(),create_timestamp,create_user,final_flag_timestamp
				 from protocol_correspondence
				 where protocol_number = r_protocol_submission.protocol_number
				 and sequence_number = r_protocol_submission.sequence_number;
				 and action_id = r_protocol_submission.action_id;
			 exception
			 when others then
			 dbms_output.put_line('Exception in protocol_correspondence ,for PROTO_AMEND_REN_NUMBER :'||r_protocol_submission.proto_amend_ren_number||'SUBMISSION_NUMBER:'||r_protocol_submission.submission_number||'action_id:'||r_protocol_submission.action_id||', Error is '||sqlerrm);
			 end;
		end if;  
	 
	 end if;
	 

end loop;
close c_protocol_submission;
end;
/
declare
li_action_id number(12);
li_protocol_id number(12);
li_submission_id number(12):= null;
li_reviewer_id number(12) := null;
li_count number(4);
cursor c_protocol_submission is
	select distinct p.protocol_id,s.proto_amend_ren_number from protocol p inner join TMP_MISSING_AMEND_RENW_PROTO s
	on p.protocol_number = s.protocol_number
	and p.sequence_number = s.sequence_number
	inner join comm_schedule_minutes c
	on p.protocol_id = c.protocol_id_fk
	where c.submission_id_fk is null;
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
	exception 
	when others then 
		dbms_output.put_line('Exception in submission_id ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
		continue;
	end;
	
    select count(protocol_id_fk) into li_count from comm_schedule_minutes where protocol_id_fk = li_protocol_id and submission_id_fk is null;
	if li_count = 0 then
       
	   begin
		   insert into comm_schedule_minutes(comm_schedule_minutes_id,final_flag,reviewer_id_fk,schedule_id_fk,protocol_id_fk,entry_number,
		   minute_entry_type_code,submission_id_fk,private_comment_flag,protocol_contingency_code,minute_entry,update_timestamp,update_user,ver_nbr,
		   obj_id,protocol_onln_rvw_fk,comm_schedule_act_items_id_fk,create_user,create_timestamp)
		   select seq_meeting_id.nextval,final_flag,li_reviewer_id,schedule_id_fk,li_protocol_id,entry_number,minute_entry_type_code,li_submission_id,
		   private_comment_flag,protocol_contingency_code,minute_entry,update_timestamp,update_user,1,sys_guid(),protocol_onln_rvw_fk,
		   comm_schedule_act_items_id_fk,create_user,create_timestamp
		   from comm_schedule_minutes
		   where protocol_id_fk = r_protocol_submission.protocol_id 
		   and submission_id_fk is null;
	   exception
       when others then
       dbms_output.put_line('Exception in comm_schedule_minutes ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
	end if;
	
end loop;
close c_protocol_submission;
end;
/