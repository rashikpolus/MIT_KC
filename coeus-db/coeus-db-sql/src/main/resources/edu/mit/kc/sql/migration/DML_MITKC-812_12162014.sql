delete from questionnaire_answer_header
where questionnaire_answer_header_id in (
select t1.questionnaire_answer_header_id from  questionnaire_answer_header t1
left outer join questionnaire_answer t2 on t1.questionnaire_answer_header_id = t2.questionnaire_ah_id_fk
where t2.questionnaire_ah_id_fk is null
and t1.questionnaire_ref_id_fk in ( select questionnaire_ref_id from questionnaire where questionnaire_id = 5 and is_final = 'N' )
)
/
commit
/
