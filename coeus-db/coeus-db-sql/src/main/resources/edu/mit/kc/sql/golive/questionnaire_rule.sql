declare
cursor c_data is
 select distinct t1.rule_id, t1.module_item_code, t1.module_sub_item_code, t2.questionnaire_id, t2.sequence_number
 from questionnaire_usage@KC_STAG_DB_LINK t1
 inner join questionnaire@KC_STAG_DB_LINK t2 on t1.questionnaire_ref_id_fk = t2.questionnaire_ref_id
 where t1.rule_id is not null
 and t2.sequence_number in ( select max(s1.sequence_number) from questionnaire@KC_STAG_DB_LINK s1
                             where s1.questionnaire_id = t2.questionnaire_id );
r_data c_data%rowtype;

begin

  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
    begin
      update questionnaire_usage t1
      set t1.rule_id = r_data.rule_id  
      where t1.module_item_code = r_data.module_item_code
      and t1.module_sub_item_code = r_data.module_sub_item_code
      and t1.questionnaire_ref_id_fk in ( select t2.questionnaire_ref_id from questionnaire t2
                                          where t2.questionnaire_id = r_data.questionnaire_id 
                                          and t2.sequence_number = ( select max(s1.sequence_number) 
                                                                     from questionnaire s1
                                                                     where s1.questionnaire_id =  r_data.questionnaire_id ) 
                                         );
    
    exception
    when others then
	 dbms_output.put_line(' Exception occoured, questionnaire is '||r_data.questionnaire_id||'. Error is '||sqlerrm);    
    end;
  
  end loop;
  close c_data;

end;
/
commit
/
declare
cursor c_data is
 select distinct t1.rule_id, t1.Question_number, t2.questionnaire_id, t2.sequence_number
 from questionnaire_questions@KC_STAG_DB_LINK t1
 inner join questionnaire@KC_STAG_DB_LINK t2 on t1.questionnaire_ref_id_fk = t2.questionnaire_ref_id
 where t1.rule_id is not null
 and t2.sequence_number in ( select max(s1.sequence_number) from questionnaire@KC_STAG_DB_LINK s1
                             where s1.questionnaire_id = t2.questionnaire_id );
r_data c_data%rowtype;

begin

  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
    begin
      update questionnaire_questions t1
      set t1.rule_id = r_data.rule_id  
      where t1.question_number = r_data.question_number     
      and t1.questionnaire_ref_id_fk in ( select t2.questionnaire_ref_id from questionnaire t2
                                          where t2.questionnaire_id = r_data.questionnaire_id 
                                          and t2.sequence_number = ( select max(s1.sequence_number) 
                                                                     from questionnaire s1
                                                                     where s1.questionnaire_id =  r_data.questionnaire_id ) 
                                         );
    
    exception
    when others then
    dbms_output.put_line(' Exception occoured, questionnaire is '||r_data.questionnaire_id||'. Error is '||sqlerrm);    
    end;
  
  end loop;
  close c_data;

end;
/
commit
/
