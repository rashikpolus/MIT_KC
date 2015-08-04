create or replace function fn_copy_qnr_from_ppc_to_coi(as_disclosure_number in OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_ITEM_KEY@COEUS.KUALI%type,
as_sequence in OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_SUB_ITEM_KEY@COEUS.KUALI%type,
as_qnr_id in OSP$QUESTIONNAIRE_ANS_HEADER.QUESTIONNAIRE_ID@COEUS.KUALI%type,
as_proposal in OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_ITEM_KEY@COEUS.KUALI%type,
as_person_id in OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_SUB_ITEM_KEY@COEUS.KUALI%type,
as_module_sub_item_cd in questionnaire_answer_header.module_sub_item_code%type,
as_actype in char) return number 
is
ls_qst_id VARCHAR2(250);
ls_qnr_comp_id VARCHAR2(10);
li_ver_nbr NUMBER(3,0);
li_coi_module_itm_cd	NUMBER(3,0) := 8;
li_coi_module_sub_itm_cd	NUMBER(3,0) := 2;
li_qnr_complete_id VARCHAR2(10);
li_question_number	NUMBER(6,0);
li_return number;
li_compt_id_count number;
cursor c_update(c_qst_id VARCHAR2) is 
  select qa.ANSWER_NUMBER,q.QUESTION_ID,qa.ANSWER,qa.UPDATE_USER,q.SEQUENCE_NUMBER as QUESTION_VERSION_NUMBER
  from questionnaire_answer_header qah
  inner join questionnaire_answer qa on qa.questionnaire_ah_id_fk = qah.questionnaire_answer_header_id
  inner join question q on q.question_ref_id = qa.question_ref_id_fk  
  inner join questionnaire qnr on qnr.questionnaire_ref_id = qah.questionnaire_ref_id_fk
  and   qah.module_item_key = as_proposal
  and   qah.module_sub_item_key = as_person_id
  and   qah.module_sub_item_code = as_module_sub_item_cd 
  and   qah.module_item_code = 3
  and   qah.questionnaire_completed_flag = 'Y'
  and   q.question_id in (select regexp_substr(c_qst_id,'[^,]+', 1, level) from dual connect by regexp_substr(c_qst_id, '[^,]+', 1, level) is not null)
  and   qnr.sequence_number in (select max(s1.sequence_number) from questionnaire s1 where s1.questionnaire_id = qnr.questionnaire_id);  
r_update c_update%rowtype;
BEGIN
  li_return:=1;
  
		BEGIN
			select value
			into ls_qst_id
			from osp$parameter@COEUS.KUALI
			where parameter = rtrim(ltrim('PROP_PERSON_COI_CERTIFY_QID'));
		EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		  ls_qst_id := '';
		END;  
    
	  begin
	   SELECT MAX(VERSION_NUMBER) INTO li_ver_nbr from OSP$QUESTIONNAIRE@COEUS.KUALI where QUESTIONNAIRE_ID = as_qnr_id and is_final = 'Y';
	  exception
	  when others then
	  return 0;
	  end;  
  
  IF as_actype = 'I' THEN
  
                SELECT SEQ_QNR_COMPLETION_ID.NEXTVAL@COEUS.KUALI INTO ls_qnr_comp_id from dual;  
                INSERT INTO OSP$QUESTIONNAIRE_ANS_HEADER@COEUS.KUALI(QUESTIONNAIRE_COMPLETION_ID,MODULE_ITEM_CODE,MODULE_ITEM_KEY,MODULE_SUB_ITEM_CODE,MODULE_SUB_ITEM_KEY,QUESTIONNAIRE_ID,UPDATE_TIMESTAMP,UPDATE_USER,QUESTIONNAIRE_COMPLETED_FLAG,QUESTIONNAIRE_VERSION_NUMBER)
                VALUES(ls_qnr_comp_id,li_coi_module_itm_cd,as_disclosure_number,li_coi_module_sub_itm_cd,as_sequence,as_qnr_id,SYSDATE,USER,'Y',li_ver_nbr);
                
                INSERT INTO OSP$QUESTIONNAIRE_ANSWERS@COEUS.KUALI(QUESTIONNAIRE_COMPLETION_ID,QUESTION_NUMBER,ANSWER_NUMBER,QUESTION_ID,ANSWER,UPDATE_TIMESTAMP,UPDATE_USER,QUESTION_VERSION_NUMBER)
				  select ls_qnr_comp_id,qq.QUESTION_NUMBER,qa.ANSWER_NUMBER,q.QUESTION_ID,qa.ANSWER,qa.UPDATE_TIMESTAMP,qa.UPDATE_USER,q.SEQUENCE_NUMBER as QUESTION_VERSION_NUMBER				
				  from questionnaire_answer_header qah
				  inner join questionnaire_answer qa on qa.questionnaire_ah_id_fk = qah.questionnaire_answer_header_id
				  inner join question q on q.question_ref_id = qa.question_ref_id_fk  
				  inner join questionnaire qnr on qnr.questionnaire_ref_id = qah.questionnaire_ref_id_fk
				  inner join questionnaire_questions qq on qq.questionnaire_ref_id_fk = qnr.questionnaire_ref_id
								and qq.question_ref_id_fk = q.question_ref_id								
				  and   qah.module_item_key = as_proposal
				  and   qah.module_sub_item_key = as_person_id
				  and   qah.module_sub_item_code = as_module_sub_item_cd 
				  and   qah.module_item_code = 3
				  and   qah.questionnaire_completed_flag = 'Y'
				  and   q.question_id in (select regexp_substr(ls_qst_id,'[^,]+', 1, level) from dual connect by regexp_substr(ls_qst_id, '[^,]+', 1, level) is not null)
				  and   qnr.sequence_number in (select max(s1.sequence_number) from questionnaire s1 where s1.questionnaire_id = qnr.questionnaire_id);  
	                                            
  ELSIF as_actype = 'U' THEN   
  
                select count(qah.QUESTIONNAIRE_COMPLETION_ID) into li_compt_id_count from OSP$QUESTIONNAIRE_ANS_HEADER@COEUS.KUALI qah 
                where qah.MODULE_ITEM_CODE = li_coi_module_itm_cd 
                and MODULE_ITEM_KEY = as_disclosure_number
                and qah.MODULE_SUB_ITEM_CODE = li_coi_module_sub_itm_cd 
                and qah.MODULE_SUB_ITEM_KEY = as_sequence 
                and qah.QUESTIONNAIRE_ID = as_qnr_id
                and qah.questionnaire_version_number = (select max(questionnaire_version_number) from osp$questionnaire_ans_header@COEUS.KUALI 
                                                        where module_item_key = qah.module_item_key
                                                        and   module_sub_item_key = qah.module_sub_item_key
                                                        and   module_sub_item_code = qah.module_sub_item_code 
                                                        and   module_item_code = qah.module_item_code
                                                        and   questionnaire_completed_flag = qah.questionnaire_completed_flag); 
                if li_compt_id_count = 1 then
                     select qah.QUESTIONNAIRE_COMPLETION_ID into li_qnr_complete_id from OSP$QUESTIONNAIRE_ANS_HEADER@COEUS.KUALI qah 
                      where qah.MODULE_ITEM_CODE = li_coi_module_itm_cd 
                      and MODULE_ITEM_KEY = as_disclosure_number
                      and qah.MODULE_SUB_ITEM_CODE = li_coi_module_sub_itm_cd 
                      and qah.MODULE_SUB_ITEM_KEY = as_sequence 
                      and qah.QUESTIONNAIRE_ID = as_qnr_id
                      and qah.questionnaire_version_number = (select max(questionnaire_version_number) from osp$questionnaire_ans_header@COEUS.KUALI
                                                              where module_item_key = qah.module_item_key
                                                              and   module_sub_item_key = qah.module_sub_item_key
                                                              and   module_sub_item_code = qah.module_sub_item_code 
                                                              and   module_item_code = qah.module_item_code
                                                              and   questionnaire_completed_flag = qah.questionnaire_completed_flag);    
                   
             
                      OPEN c_update(ls_qst_id);
                      LOOP
                      fetch c_update into r_update;
                      exit when c_update%notfound;      
                              begin 
                              select  QUESTION_NUMBER into li_question_number from OSP$QUESTIONNAIRE_QUESTIONS@COEUS.KUALI where QUESTIONNAIRE_ID = as_qnr_id  and QUESTION_ID =r_update.QUESTION_ID
                                    and QUESTIONNAIRE_VERSION_NUMBER =   (SELECT MAX(QUESTIONNAIRE_VERSION_NUMBER)               
                                           FROM OSP$QUESTIONNAIRE_ANS_HEADER@COEUS.KUALI
                                           WHERE OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_ITEM_CODE = li_coi_module_itm_cd
                                            AND OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_ITEM_KEY = as_disclosure_number
                                            AND OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_SUB_ITEM_CODE = li_coi_module_sub_itm_cd
                                            AND OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_SUB_ITEM_KEY = as_sequence
                                            AND OSP$QUESTIONNAIRE_ANS_HEADER.QUESTIONNAIRE_ID = as_qnr_id); 
                             
                              update OSP$QUESTIONNAIRE_ANSWERS@COEUS.KUALI SET ANSWER = r_update.ANSWER
                              where QUESTIONNAIRE_COMPLETION_ID = li_qnr_complete_id
                                  and QUESTION_NUMBER = li_question_number
                                  and ANSWER_NUMBER = r_update.ANSWER_NUMBER
                                  and QUESTION_ID = r_update.QUESTION_ID;
                              exception
                              when others then
                              li_return:=0;
                              end;      
                      end loop;
                      close c_update;
                    end if;  
      
  END IF; 
  
  RETURN li_return;
  
END;
/