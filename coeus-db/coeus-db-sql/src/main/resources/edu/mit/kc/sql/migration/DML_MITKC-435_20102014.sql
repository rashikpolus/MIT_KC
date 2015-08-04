set serveroutput on;
declare
	li_count number;
cursor c_kp is 
select a.mit_award_number,a.sequence_number,a.key_person_indicator from osp$award@coeus.kuali a
where a.key_person_indicator  = 'N0';
r_kp c_kp%rowtype;

begin

if c_kp%isopen then
close c_kp;
end if;
open c_kp;
loop
fetch c_kp into r_kp;
exit when c_kp%notfound;

	select count(mit_award_number) into li_count from osp$award_key_persons@coeus.kuali where mit_award_number=r_kp.mit_award_number and sequence_number=r_kp.sequence_number; 

	if li_count=0 then

		delete from award_persons where award_number=replace(r_kp.mit_award_number,'-','-00') and sequence_number=r_kp.sequence_number and contact_role_code='KP';
		--dbms_output.put_line('Deleted mit award number '||r_kp.mit_award_number||', sequence number '||r_kp.sequence_number);

	end if;
		dbms_output.put_line('Number of awards deleted while cleaning up key person table with NO indicator : '||li_count);

end loop;
close c_kp;
end;
/
declare
	li_count number;

cursor c_kp is 
select a.mit_award_number,a.sequence_number,a.key_person_indicator from osp$award@coeus.kuali a
inner join kc_mig_award_conv k on a.mit_award_number=replace(k.award_number,'-00','-')
where a.key_person_indicator = 'N0';
r_kp c_kp%rowtype;

begin

if c_kp%isopen then
close c_kp;
end if;
	open c_kp;
	loop
	fetch c_kp into r_kp;
	exit when c_kp%notfound;

		select count(mit_award_number) into li_count from osp$award_key_persons@coeus.kuali where mit_award_number=r_kp.mit_award_number and sequence_number=r_kp.sequence_number;

		if li_count=0 then

		delete from award_persons where award_number=replace(r_kp.mit_award_number,'-','-00') and sequence_number=r_kp.sequence_number  and contact_role_code='KP';
		dbms_output.put_line('Deleted mit award number '||r_kp.mit_award_number||', sequence number '||r_kp.sequence_number);
		end if;
		dbms_output.put_line('Number of awards deleted while cleaning up key person table with NO indicator : '||li_count);

	end loop;
	close c_kp;

end;
/
--proposal_modue
declare
	li_count number;

cursor c_kp is 
select a.proposal_number,a.sequence_number,a.key_person_indicator from osp$proposal@coeus.kuali a 
where a.key_person_indicator = 'N0';
r_kp c_kp%rowtype;

begin

if c_kp%isopen then
close c_kp;
end if;
	open c_kp;
	loop
	fetch c_kp into r_kp;
	exit when c_kp%notfound;

		select count(proposal_number) into li_count from osp$proposal_key_persons@coeus.kuali where proposal_number=r_kp.proposal_number and sequence_number=r_kp.sequence_number;

		if li_count=0 then

		delete from proposal_persons where proposal_number=r_kp.proposal_number and sequence_number=r_kp.sequence_number  and contact_role_code='KP';
		--dbms_output.put_line('Deleted proposal number '||r_kp.proposal_number||', sequence number '||r_kp.sequence_number);
		end if;
		dbms_output.put_line('Number of proposal deleted while cleaning up key person table with NO indicator : '||li_count);

	end loop;
	close c_kp;
end;
/
commit
/
