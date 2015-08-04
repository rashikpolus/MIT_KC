declare
	li_qnr  questionnaire.questionnaire_id%type  := 5;

begin
	-- questionnaire branching issue fix

	update questionnaire_questions set condition_value = 'Y' 
	where condition_value is null
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr);

commit;

end;
/