select ' Started update PROPOSAL_ADMIN_DETAILS ' from dual
/
declare
li_count number;
cursor cur_ip is
	select t.proposal_number,t.sequence_number
	from TEMP_TAB_TO_SYNC_IP t
	WHERE t.feed_type = 'C';
rec_ip cur_ip%rowtype;	

begin

open cur_ip;
loop
fetch cur_ip into rec_ip;
exit when cur_ip%notfound;

select count(*) into li_count from (

	select 
	to_number(pa.DEV_PROPOSAL_NUMBER),pa.DATE_SUBMITTED_BY_DEPT,pa.DATE_RETURNED_TO_DEPT,pa.DATE_APPROVED_BY_OSP,
	pa.DATE_SUBMITTED_TO_AGENCY,pa.INST_PROP_CREATE_DATE,pa.INST_PROP_CREATE_USER,pa.SIGNED_BY,pa.SUBMISSION_TYPE
	from PROPOSAL_ADMIN_DETAILS pa inner join proposal p on p.proposal_id = pa.INST_PROPOSAL_ID
	where p.proposal_number = rec_ip.proposal_number
	and   p.sequence_number	= rec_ip.sequence_number

	minus

	select
	to_number(pa.DEV_PROPOSAL_NUMBER),pa.DATE_SUBMITTED_BY_DEPT,pa.DATE_RETURNED_TO_DEPT,pa.DATE_APPROVED_BY_OSP,
	pa.DATE_SUBMITTED_TO_AGENCY,pa.INST_PROP_CREATE_DATE,pa.INST_PROP_CREATE_USER,pa.SIGNED_BY,pa.SUBMISSION_TYPE
	from OSP$PROPOSAL_ADMIN_DETAILS@coeus.kuali pa
	where pa.INST_PROPOSAL_NUMBER = rec_ip.proposal_number
	and   pa.INST_PROP_SEQUENCE_NUMBER	= rec_ip.sequence_number
);

	if li_count > 0 then

		delete from PROPOSAL_ADMIN_DETAILS where INST_PROPOSAL_ID in (
						select p.proposal_id from proposal p
						where p.proposal_number = rec_ip.proposal_number
						and   p.sequence_number	= rec_ip.sequence_number
		);
		commit;
		INSERT INTO PROPOSAL_ADMIN_DETAILS(PROPOSAL_ADMIN_DETAIL_ID,DEV_PROPOSAL_NUMBER,INST_PROPOSAL_ID,DATE_SUBMITTED_BY_DEPT,DATE_RETURNED_TO_DEPT,DATE_APPROVED_BY_OSP,DATE_SUBMITTED_TO_AGENCY,INST_PROP_CREATE_DATE,INST_PROP_CREATE_USER,SIGNED_BY,SUBMISSION_TYPE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
		SELECT SEQ_PROPOSAL_ADMIN_DETAILS_ID.NEXTVAL,to_number(pa.DEV_PROPOSAL_NUMBER),p.proposal_id,pa.DATE_SUBMITTED_BY_DEPT,pa.DATE_RETURNED_TO_DEPT,
		pa.DATE_APPROVED_BY_OSP,pa.DATE_SUBMITTED_TO_AGENCY,pa.INST_PROP_CREATE_DATE,pa.INST_PROP_CREATE_USER,pa.SIGNED_BY,pa.SUBMISSION_TYPE,
		p.update_timestamp,p.update_user,1,SYS_GUID()
		FROM OSP$PROPOSAL_ADMIN_DETAILS@coeus.kuali pa,PROPOSAL p 
		where pa.INST_PROPOSAL_NUMBER = p.proposal_number
		and pa.INST_PROP_SEQUENCE_NUMBER = p.sequence_number
		and pa.INST_PROPOSAL_NUMBER = rec_ip.proposal_number
		and pa.INST_PROP_SEQUENCE_NUMBER	= rec_ip.sequence_number;			

	end if;



end loop;
close cur_ip;

commit;
end;
/
select ' Ended Update PROPOSAL_ADMIN_DETAILS ' from dual
/