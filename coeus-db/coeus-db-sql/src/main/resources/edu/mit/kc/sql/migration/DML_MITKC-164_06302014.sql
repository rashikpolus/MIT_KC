declare
	li_qnr_PI  questionnaire.questionnaire_id%type  := 501;
	li_qnr_COI  questionnaire.questionnaire_id%type := 503;
	li_qnr_KP  questionnaire.questionnaire_id%type  := 502;
begin

	--PI
	update questionnaire_usage set module_sub_item_code = 4 
	where module_item_code = 3
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr_PI);

	update questionnaire_answer_header set module_sub_item_code = 4 
	where module_item_code = 3
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr_PI);

	--COI

	update questionnaire_usage set module_sub_item_code = 5 
	where module_item_code = 3
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr_COI);

	update questionnaire_answer_header set module_sub_item_code = 5 
	where module_item_code = 3
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr_COI);

	--KP

	update questionnaire_usage set module_sub_item_code = 6 
	where module_item_code = 3
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr_KP);

	update questionnaire_answer_header set module_sub_item_code = 6 
	where module_item_code = 3
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr_KP);

	commit;

end;
/