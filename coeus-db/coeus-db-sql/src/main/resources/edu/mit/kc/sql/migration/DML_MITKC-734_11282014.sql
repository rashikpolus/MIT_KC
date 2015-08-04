delete from award_rep_terms_recnt where award_report_terms_id in(
	select a.award_report_terms_id from award_report_terms a 
	inner join osp$award_report_terms@coeus.kuali ca 
	on a.award_number=replace(ca.mit_award_number,'-','-00') and a.sequence_number=ca.sequence_number
	where ca.contact_type_code=-1 and ca.rolodex_id=-1
)
and  contact_type_code=8 and rolodex_id=-1
/