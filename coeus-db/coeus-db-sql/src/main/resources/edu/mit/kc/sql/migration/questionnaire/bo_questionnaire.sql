DECLARE
li_quest_ref_id NUMBER(12,0);
li_ver_nbr number:=1;
li_questionnaire_ref_id number;
li_questionnaire_usg_id number;
li_questionnaire_seq_num number;
li_rule_id NUMBER(6,0):= null;
li_qnr_cid number;
li_questionnaire_ans_id number;
li_condition_type VARCHAR2(3);
li_condition VARCHAR2(50);
li_questionnaire_quest_id number;
li_qnr_quest_ref_id number;
ls_module_item_key VARCHAR2(20);
 li_count_qnr number;
 li_count_qnr_qst number;
 li_count_qnr_usg number;
 li_count_qnr_ans number;
 li_count_qnr_ans_hdr number;    
ls_condition_value	VARCHAR2(2000);
li_condtion_check number;

li_got_exception BOOLEAN; 

CURSOR c_questionnaire IS
SELECT * FROM TEMP_QUESTIONNAIRE;
r_questionnaire c_questionnaire%ROWTYPE;

CURSOR c_usage IS
SELECT * FROM OSP$QUESTIONNAIRE_USAGE@coeus.kuali;
r_usage c_usage%ROWTYPE;

CURSOR c_ansHeader IS
SELECT * FROM OSP$QUESTIONNAIRE_ANS_HEADER@coeus.kuali;
r_ansHeader c_ansHeader%ROWTYPE;

CURSOR c_ans IS
SELECT * FROM OSP$QUESTIONNAIRE_ANSWERS@coeus.kuali ;
r_ans c_ans%ROWTYPE;

CURSOR c_qnr IS
SELECT QUESTIONNAIRE_ID,QUESTION_NUMBER,QUESTIONNAIRE_VERSION_NUMBER,QUESTION_ID,PARENT_QUESTION_NUMBER,CONDITION_FLAG,CONDITION
,CONDITION_VALUE,UPDATE_TIMESTAMP,UPDATE_USER,QUESTION_SEQ_NUMBER,QUESTION_VERSION_NUMBER,RULE_ID 
FROM OSP$QUESTIONNAIRE_QUESTIONS@coeus.kuali ;
r_qnr c_qnr%ROWTYPE; 

BEGIN

		  
	  ---------------------------------questionnaire-----------------------------------------------           
				 IF c_questionnaire%ISOPEN THEN
					CLOSE c_questionnaire;
				 END IF;
				 
				 OPEN c_questionnaire;
				 LOOP
				 FETCH c_questionnaire INTO r_questionnaire;
				 EXIT WHEN c_questionnaire%NOTFOUND;                    
				  SELECT  SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_questionnaire_ref_id FROM DUAL;                                       
				  li_questionnaire_seq_num:= r_questionnaire.VERSION_NUMBER; 
				 
				 INSERT INTO QUESTIONNAIRE(QUESTIONNAIRE_REF_ID,QUESTIONNAIRE_ID,SEQUENCE_NUMBER,NAME,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,IS_FINAL,VER_NBR,OBJ_ID,FILE_NAME,TEMPLATE,DOCUMENT_NUMBER)
				 VALUES(li_questionnaire_ref_id,r_questionnaire.QUESTIONNAIRE_ID,li_questionnaire_seq_num,r_questionnaire.NAME,r_questionnaire.DESCRIPTION,r_questionnaire.UPDATE_TIMESTAMP,r_questionnaire.UPDATE_USER,r_questionnaire.IS_FINAL,li_ver_nbr,SYS_GUID(),r_questionnaire.FILE_NAME,r_questionnaire.TEMPLATE,NULL);
				  END LOOP;
				 CLOSE c_questionnaire;
				 commit;
  ---------------------------------questionnaire question----------------------------------------------
				
		  IF c_qnr%ISOPEN THEN
			  CLOSE c_qnr;
		   END IF;               
		   OPEN c_qnr;
		   LOOP
		   FETCH c_qnr INTO r_qnr;
		   EXIT WHEN c_qnr%NOTFOUND;
			ls_condition_value:=r_qnr.CONDITION_VALUE;
			li_condition := UPPER(TRIM(r_qnr.CONDITION));              
				  IF li_condition='CONTAINS' THEN
				   li_condition_type:='1';
				  ELSIF  li_condition='BEGIN WITH' THEN
				   li_condition_type:='2';
				  ELSIF  li_condition='ENDS WITH' THEN
				 li_condition_type:='3';
				  ELSIF  li_condition='EQUAL TO' THEN
				 li_condition_type:='7';
				  ELSIF  li_condition='NOT EQUAL' THEN
				 li_condition_type:='8';
				  ELSIF  li_condition='GREATER THAN' THEN
				 li_condition_type:='10';
				  ELSIF  li_condition='LESS THAN' THEN
				 li_condition_type:='5';
				  ELSIF  li_condition='GREATER THAN EQUAL' THEN
				 li_condition_type:='9';
				  ELSIF  li_condition='LESS THAN EQUAL' THEN
				 li_condition_type:='6';
					END IF;                        
					if li_condition_type='7' then
					begin
					li_condtion_check:=to_number(ls_condition_value);                         
					exception when others then
					li_condition_type:='4';
					end;
					end if;                        
					if li_condition_type='8' then
					begin
					li_condtion_check:=to_number(ls_condition_value);                         
					exception when others then
					li_condition_type:='4';
					end;
					end if;
					
					
			SELECT  SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_questionnaire_quest_id FROM DUAL;                 
		  li_got_exception := false;
      
      begin
    	 SELECT QUESTION_REF_ID INTO li_quest_ref_id FROM QUESTION WHERE QUESTION_ID=r_qnr.QUESTION_ID AND SEQUENCE_NUMBER=r_qnr.QUESTION_VERSION_NUMBER;                 
		  exception when others then
       li_got_exception := true;
       dbms_output.put_line('while iserting QUESTIONNAIRE_QUESTIONS , error while fetching QUESTION_REF_ID. where QUESTION_ID and SEQUENCE_NUMBER '||r_qnr.QUESTION_ID||' , '||r_qnr.QUESTION_VERSION_NUMBER);
      end;
      
       begin
         select QUESTIONNAIRE_REF_ID into li_questionnaire_ref_id  from QUESTIONNAIRE  where QUESTIONNAIRE_ID=r_qnr.QUESTIONNAIRE_ID and SEQUENCE_NUMBER=r_qnr.QUESTIONNAIRE_VERSION_NUMBER;               
		   exception when others then
       li_got_exception := true;
       dbms_output.put_line('while iserting QUESTIONNAIRE_QUESTIONS , error while fetching QUESTIONNAIRE_REF_ID. where QUESTIONNAIRE_ID and SEQUENCE_NUMBER '||r_qnr.QUESTIONNAIRE_ID||' , '||r_qnr.QUESTIONNAIRE_VERSION_NUMBER);
       end;
      
      if li_got_exception = false then
       
       INSERT INTO QUESTIONNAIRE_QUESTIONS(QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_REF_ID_FK,QUESTION_NUMBER,PARENT_QUESTION_NUMBER,CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,UPDATE_TIMESTAMP,UPDATE_USER,QUESTION_SEQ_NUMBER,VER_NBR,OBJ_ID,RULE_ID)
		   VALUES(li_questionnaire_quest_id,li_questionnaire_ref_id,li_quest_ref_id,r_qnr.QUESTION_NUMBER,r_qnr.PARENT_QUESTION_NUMBER,r_qnr.CONDITION_FLAG,li_condition_type,r_qnr.CONDITION_VALUE,r_qnr.UPDATE_TIMESTAMP,r_qnr.UPDATE_USER,r_qnr.QUESTION_SEQ_NUMBER,li_ver_nbr,SYS_GUID(),r_qnr.RULE_ID);               
     
     end if;
			 
       END LOOP; 
		   CLOSE c_qnr;
				
		   commit;
 --------------------------------usage-------------------------------------------------------------------------------
 
				IF c_usage%ISOPEN THEN
					CLOSE c_usage;
				 END IF;
				 
				 OPEN c_usage;
				 LOOP
				 FETCH c_usage INTO r_usage;
				 EXIT WHEN c_usage%NOTFOUND;                
				  SELECT  SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_questionnaire_usg_id FROM DUAL;
          
        li_got_exception := false;
        
        begin  
				  select QUESTIONNAIRE_REF_ID into li_questionnaire_ref_id  from QUESTIONNAIRE  where QUESTIONNAIRE_ID=r_usage.QUESTIONNAIRE_ID and SEQUENCE_NUMBER=r_usage.VERSION_NUMBER;                     
				exception when others then
         li_got_exception := true;
         dbms_output.put_line('while iserting QUESTIONNAIRE_USAGE , error while fetching QUESTIONNAIRE_REF_ID. where QUESTIONNAIRE_ID and SEQUENCE_NUMBER '||r_usage.QUESTIONNAIRE_ID||' , '||r_usage.VERSION_NUMBER);
        end;
        
        if li_got_exception = false then
		 
			
			
         INSERT INTO QUESTIONNAIRE_USAGE(QUESTIONNAIRE_USAGE_ID,MODULE_ITEM_CODE,MODULE_SUB_ITEM_CODE,QUESTIONNAIRE_REF_ID_FK,QUESTIONNAIRE_SEQUENCE_NUMBER,RULE_ID,QUESTIONNAIRE_LABEL,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,IS_MANDATORY)                   
		 VALUES(li_questionnaire_usg_id,r_usage.MODULE_ITEM_CODE,r_usage.MODULE_SUB_ITEM_CODE,li_questionnaire_ref_id,r_usage.VERSION_NUMBER,li_rule_id,r_usage.QUESTIONNAIRE_LABEL,r_usage.UPDATE_TIMESTAMP,r_usage.UPDATE_USER,li_ver_nbr,sys_guid(),r_usage.IS_MANDATORY);
		 
		 		
        end if;
        
         END LOOP;
				 CLOSE c_usage;
				 commit;
	 ---------------------------------questionnaire ans header---------------------------------------------------------------------------------------------------            
		   
		   
				IF c_ansHeader%ISOPEN THEN
					CLOSE c_ansHeader;
				 END IF;                     
				 OPEN c_ansHeader;
				 LOOP
				 FETCH c_ansHeader INTO r_ansHeader;
				 EXIT WHEN c_ansHeader%NOTFOUND;                     
				 IF r_ansHeader.MODULE_ITEM_CODE=3 THEN
				 select to_number(r_ansHeader.MODULE_ITEM_KEY) into ls_module_item_key from dual;
				 else
				 ls_module_item_key:=r_ansHeader.MODULE_ITEM_KEY;
				 end if;                 
												 
				  li_qnr_cid:=r_ansHeader.QUESTIONNAIRE_COMPLETION_ID;   
          li_got_exception := false;
        begin  
				   select QUESTIONNAIRE_REF_ID into li_questionnaire_ref_id  from QUESTIONNAIRE  where QUESTIONNAIRE_ID=r_ansHeader.QUESTIONNAIRE_ID and SEQUENCE_NUMBER=r_ansHeader.QUESTIONNAIRE_VERSION_NUMBER;                     
			  exception when others then
         li_got_exception := true;
         dbms_output.put_line('while iserting QUESTIONNAIRE_ANSWER_HEADER , error while fetching QUESTIONNAIRE_REF_ID. where QUESTIONNAIRE_ID and SEQUENCE_NUMBER '||r_usage.QUESTIONNAIRE_ID||' , '||r_usage.VERSION_NUMBER);
        end;
        
         if li_got_exception = false then
				  INSERT INTO QUESTIONNAIRE_ANSWER_HEADER(QUESTIONNAIRE_ANSWER_HEADER_ID,QUESTIONNAIRE_REF_ID_FK,MODULE_ITEM_CODE,MODULE_ITEM_KEY,MODULE_SUB_ITEM_CODE,MODULE_SUB_ITEM_KEY,QUESTIONNAIRE_COMPLETED_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)    
				  VALUES(li_qnr_cid,li_questionnaire_ref_id,r_ansHeader.MODULE_ITEM_CODE,ls_module_item_key,r_ansHeader.MODULE_SUB_ITEM_CODE,r_ansHeader.MODULE_SUB_ITEM_KEY,r_ansHeader.QUESTIONNAIRE_COMPLETED_FLAG,r_ansHeader.UPDATE_TIMESTAMP,r_ansHeader.UPDATE_USER,li_ver_nbr,sys_guid());
				 end if;
         
          END LOOP;          
				 CLOSE c_ansHeader;
				 commit;
			 ---------------------------------questionnaire answer---------------------------------------------------------------------------------------------------     
				 
						  IF c_ans%ISOPEN THEN
						  CLOSE c_ans;
						   END IF;
						   
						   OPEN c_ans;
						   LOOP
						   FETCH c_ans INTO r_ans;
						   EXIT WHEN c_ans%NOTFOUND;    
							SELECT  SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_questionnaire_ans_id FROM DUAL;       
						   SELECT QUESTION_REF_ID INTO li_quest_ref_id FROM QUESTION WHERE QUESTION_ID=r_ans.QUESTION_ID AND SEQUENCE_NUMBER=r_ans.QUESTION_VERSION_NUMBER;               
			
          li_got_exception := false;
            begin
              select QUESTIONNAIRE_REF_ID_FK into li_questionnaire_ref_id  from QUESTIONNAIRE_ANSWER_HEADER  where QUESTIONNAIRE_ANSWER_HEADER_ID=r_ans.QUESTIONNAIRE_COMPLETION_ID;    
            exception when others then
             li_got_exception := true;
             dbms_output.put_line('while iserting QUESTIONNAIRE_ANSWER , error while fetching QUESTIONNAIRE_REF_ID_FK. where QUESTIONNAIRE_ANSWER_HEADER_ID '||r_ans.QUESTIONNAIRE_COMPLETION_ID);
            end;
            
          begin     
              select QUESTIONNAIRE_QUESTIONS_ID  into li_qnr_quest_ref_id from QUESTIONNAIRE_QUESTIONS where QUESTIONNAIRE_REF_ID_FK=li_questionnaire_ref_id  and QUESTION_NUMBER=r_ans.QUESTION_NUMBER;
          exception when others then
           li_got_exception := true;
           dbms_output.put_line('while iserting QUESTIONNAIRE_ANSWER , error while fetching QUESTIONNAIRE_QUESTIONS_ID. where QUESTIONNAIRE_REF_ID_FK and QUESTION_NUMBER '||li_questionnaire_ref_id||' , '||r_ans.QUESTION_NUMBER);
          end;
          
          if li_got_exception = false then
						   INSERT INTO  QUESTIONNAIRE_ANSWER(QUESTIONNAIRE_ANSWER_ID,QUESTIONNAIRE_AH_ID_FK,QUESTION_REF_ID_FK,QUESTION_NUMBER,ANSWER_NUMBER,ANSWER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,QUESTIONNAIRE_QUESTIONS_ID_FK,OBJ_ID)
						   VALUES(li_questionnaire_ans_id,r_ans.QUESTIONNAIRE_COMPLETION_ID,li_quest_ref_id,r_ans.QUESTION_NUMBER,r_ans.ANSWER_NUMBER,r_ans.ANSWER,r_ans.UPDATE_TIMESTAMP,r_ans.UPDATE_USER,li_ver_nbr,li_qnr_quest_ref_id,SYS_GUID());
					end if;	  
              
               END LOOP;
						   CLOSE c_ans;      
commit;						   
 dbms_output.put_line(CHR(10));          
 dbms_output.put_line('Successfully completed QUESTIONNAIRE Module');
 
select count(QUESTIONNAIRE_REF_ID) into li_count_qnr from QUESTIONNAIRE;
select count(QUESTIONNAIRE_QUESTIONS_ID) into li_count_qnr_qst from QUESTIONNAIRE_QUESTIONS;
select count(QUESTIONNAIRE_USAGE_ID) into li_count_qnr_usg from QUESTIONNAIRE_USAGE;
select count(QUESTIONNAIRE_ANSWER_HEADER_ID) into li_count_qnr_ans_hdr from QUESTIONNAIRE_ANSWER_HEADER;
select count(QUESTIONNAIRE_ANSWER_ID) into li_count_qnr_ans from QUESTIONNAIRE_ANSWER;
dbms_output.put_line('------------------Row Counts----------------');
dbms_output.put_line('QUESTIONNAIRE : '||li_count_qnr);
dbms_output.put_line('QUESTIONNAIRE_QUESTIONS : '||li_count_qnr_qst);
dbms_output.put_line('QUESTIONNAIRE_USAGE : '||li_count_qnr_usg);
dbms_output.put_line('QUESTIONNAIRE_ANSWER_HEADER : '||li_count_qnr_ans_hdr);
dbms_output.put_line('QUESTIONNAIRE_ANSWER : '||li_count_qnr_ans);  

END;
/
-- Questionnaire Questions, rule id and condition_type are not populating correctly
update questionnaire_questions set rule_id='KC141' where rule_id='320'
/
update questionnaire_questions set rule_id='KC142' where rule_id='321'
/
update questionnaire_questions set rule_id='KC143' where rule_id='322'
/
update questionnaire_questions set rule_id='KC144' where rule_id='323'
/
update questionnaire_questions set rule_id='KC145' where rule_id='324'
/
update questionnaire_questions set rule_id='KC146' where rule_id='325'
/
update questionnaire_questions set rule_id='KC147' where rule_id='326'
/
update questionnaire_questions set rule_id='KC148' where rule_id='327'
/
update questionnaire_questions set rule_id='KC149' where rule_id='328'
/
update questionnaire_questions set rule_id='KC150' where rule_id='329'
/
update questionnaire_questions set rule_id='KC151' where rule_id='330'
/
commit
/
update questionnaire_questions set condition_flag='N',condition_value=null where condition_type='10' and QUESTIONNAIRE_REF_ID_FK in 
    (select questionnaire_ref_id from questionnaire where questionnaire_id in('5'))
/
commit;
update questionnaire_questions set rule_id=null where rule_id='0'
/
commit
/
update questionnaire_usage set is_mandatory = 'N' where QUESTIONNAIRE_REF_ID_FK in 
    (select questionnaire_ref_id from questionnaire where questionnaire_id in('1','2','3','4','5'))
/
commit;
/
-- Questionnaire Questions, rule id and condition_type are not populating correctly
-- coeus sub module code for "Proposal Person Certification" is 6 where as KC has 3
update questionnaire_usage set module_sub_item_code = 3 where module_item_code = 3 and module_sub_item_code = 6
/
update questionnaire_answer_header set module_sub_item_code = 3 where module_item_code = 3 and module_sub_item_code = 6
/
-- coeus sub module code for "Proposal(COI)" is 1 where as KC has 2
update questionnaire_usage set module_sub_item_code = 2 where module_item_code = 8 and module_sub_item_code = 1
/
update questionnaire_answer_header set module_sub_item_code = 2 where module_item_code = 8 and module_sub_item_code = 1
/
commit;
/
-- coeus sub module code for "IRBProtocol(COI)" is 2 where as KC has 3
update questionnaire_usage set module_sub_item_code = 3 where module_item_code = 8 and module_sub_item_code = 2
/
update questionnaire_answer_header set module_sub_item_code = 3 where module_item_code = 8 and module_sub_item_code = 2
/
commit;
/
-- coeus sub module code for "Annual(COI)" is 3 where as KC has 14
update questionnaire_usage set module_sub_item_code = 14 where module_item_code = 8 and module_sub_item_code = 3
/
update questionnaire_answer_header set module_sub_item_code = 14 where module_item_code = 8 and module_sub_item_code = 3
/
commit;
/
-- coeus sub module code for "Award(COI)" is 5 where as KC has 1
update questionnaire_usage set module_sub_item_code = 1 where module_item_code = 8 and module_sub_item_code = 5
/
update questionnaire_answer_header set module_sub_item_code = 1 where module_item_code = 8 and module_sub_item_code = 5
/
commit;
/
-- coeus sub module code for "Travel(COI)" is 8 where as KC has 15
update questionnaire_usage set module_sub_item_code = 15 where module_item_code = 8 and module_sub_item_code = 8
/
update questionnaire_answer_header set module_sub_item_code = 15 where module_item_code = 8 and module_sub_item_code = 8
/
commit;
/
select ' End time of QUESTION MODULE is '|| localtimestamp from dual
/
  