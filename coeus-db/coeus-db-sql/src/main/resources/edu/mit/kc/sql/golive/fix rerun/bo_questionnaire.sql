TRUNCATE TABLE QUESTIONNAIRE_USAGE;
TRUNCATE TABLE QUESTIONNAIRE_ANSWER;
TRUNCATE TABLE QUESTIONNAIRE_QUESTIONS;

ALTER TABLE QUESTIONNAIRE_ANSWER DISABLE CONSTRAINT FK_QUESTIONNAIRE_ANS_COMP_ID ;
TRUNCATE TABLE QUESTIONNAIRE_ANSWER_HEADER;
ALTER TABLE QUESTIONNAIRE_ANSWER ENABLE CONSTRAINT FK_QUESTIONNAIRE_ANS_COMP_ID ;


ALTER TABLE QUESTIONNAIRE_USAGE DISABLE CONSTRAINT FK_QUESTIONNAIRE_USAGE ;
ALTER TABLE QUESTIONNAIRE_QUESTIONS DISABLE CONSTRAINT FK_QUESTIONNAIRE_QUESTIONNAIRE ;
ALTER TABLE QUESTIONNAIRE_ANSWER_HEADER DISABLE CONSTRAINT FK_QUESTIONNAIRE_QID ;
TRUNCATE TABLE QUESTIONNAIRE;
ALTER TABLE QUESTIONNAIRE_USAGE ENABLE CONSTRAINT FK_QUESTIONNAIRE_USAGE ;
ALTER TABLE QUESTIONNAIRE_QUESTIONS ENABLE CONSTRAINT FK_QUESTIONNAIRE_QUESTIONNAIRE ;
ALTER TABLE QUESTIONNAIRE_ANSWER_HEADER ENABLE CONSTRAINT FK_QUESTIONNAIRE_QID ;



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
		 
			
			
         INSERT INTO QUESTIONNAIRE_USAGE(QUESTIONNAIRE_USAGE_ID,MODULE_ITEM_CODE,MODULE_SUB_ITEM_CODE,QUESTIONNAIRE_REF_ID_FK,QUESTIONNAIRE_SEQUENCE_NUMBER,QUESTIONNAIRE_LABEL,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,IS_MANDATORY,RULE_ID)                   
		 VALUES(li_questionnaire_usg_id,r_usage.MODULE_ITEM_CODE,r_usage.MODULE_SUB_ITEM_CODE,li_questionnaire_ref_id,r_usage.VERSION_NUMBER,r_usage.QUESTIONNAIRE_LABEL,r_usage.UPDATE_TIMESTAMP,r_usage.UPDATE_USER,li_ver_nbr,sys_guid(),r_usage.IS_MANDATORY,r_usage.RULE_ID);
		 
		 		
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

update questionnaire_questions set condition_flag='N',condition_value=null where condition_type='10' and QUESTIONNAIRE_REF_ID_FK in 
    (select questionnaire_ref_id from questionnaire where questionnaire_id in('5'))
/

update questionnaire_questions set rule_id=null where rule_id='0'
/

update questionnaire_usage set is_mandatory = 'N' where QUESTIONNAIRE_REF_ID_FK in 
    (select questionnaire_ref_id from questionnaire where questionnaire_id in('1','2','3','4','5'))
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

-- coeus sub module code for "IRBProtocol(COI)" is 2 where as KC has 3
update questionnaire_usage set module_sub_item_code = 3 where module_item_code = 8 and module_sub_item_code = 2
/
update questionnaire_answer_header set module_sub_item_code = 3 where module_item_code = 8 and module_sub_item_code = 2
/

-- coeus sub module code for "Annual(COI)" is 3 where as KC has 14
update questionnaire_usage set module_sub_item_code = 14 where module_item_code = 8 and module_sub_item_code = 3
/
update questionnaire_answer_header set module_sub_item_code = 14 where module_item_code = 8 and module_sub_item_code = 3
/

-- coeus sub module code for "Award(COI)" is 5 where as KC has 1
update questionnaire_usage set module_sub_item_code = 1 where module_item_code = 8 and module_sub_item_code = 5
/
update questionnaire_answer_header set module_sub_item_code = 1 where module_item_code = 8 and module_sub_item_code = 5
/

-- coeus sub module code for "Travel(COI)" is 8 where as KC has 15
update questionnaire_usage set module_sub_item_code = 15 where module_item_code = 8 and module_sub_item_code = 8
/
update questionnaire_answer_header set module_sub_item_code = 15 where module_item_code = 8 and module_sub_item_code = 8
/

declare
	li_qnr  questionnaire.questionnaire_id%type  := 5;

begin
	-- questionnaire branching issue fix

	update questionnaire_questions set condition_value = 'Y' 
	where condition_value is null
	and questionnaire_ref_id_fk in (select questionnaire_ref_id from questionnaire where questionnaire_id = li_qnr);



end;
/
UPDATE QUESTIONNAIRE_USAGE 
SET MODULE_SUB_ITEM_CODE = 2
WHERE QUESTIONNAIRE_REF_ID_FK IN(SELECT QUESTIONNAIRE_REF_ID FROM QUESTIONNAIRE WHERE QUESTIONNAIRE_ID in ( 1,2,3,4 ) )
/

------- insert QNR5
delete from  questionnaire t1 where t1.QUESTIONNAIRE_ID = 5
and not exists ( select t2.questionnaire_ref_id_fk from questionnaire_questions t2 
where t1.questionnaire_ref_id = t2.questionnaire_ref_id_fk )
/
ALTER TABLE QUESTIONNAIRE_QUESTIONS DISABLE CONSTRAINT FK_QUEST_QUESTIONS_COND_TYPE ;          
TRUNCATE TABLE QUESTIONNAIRE_CONDITION_TYPE;
INSERT INTO QUESTIONNAIRE_CONDITION_TYPE(QUEST_CONDITION_TYPE_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT QUEST_CONDITION_TYPE_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID FROM BOOT_CONDITION_TYPE;
ALTER TABLE QUESTIONNAIRE_QUESTIONS ENABLE CONSTRAINT FK_QUEST_QUESTIONS_COND_TYPE ; 

DECLARE
	li_question_ref_id NUMBER(12);
	li_seq NUMBER(4);
	li_question NUMBER(12);
	li_sequence NUMBER(4);
	li_question_ref NUMBER(12);
	li_ques_ref NUMBER(12);
	li_num NUMBER;
	
	CURSOR c_questionnaire IS 
	SELECT QUESTIONNAIRE_REF_ID,QUESTIONNAIRE_ID,SEQUENCE_NUMBER,NAME,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,IS_FINAL,FILE_NAME,TEMPLATE,DOCUMENT_NUMBER 
	FROM BOOT_QUESTIONNAIRE WHERE QUESTIONNAIRE_ID = 5;
	r_questionnaire c_questionnaire%ROWTYPE;

BEGIN
IF c_questionnaire%ISOPEN THEN
CLOSE c_questionnaire;
END IF;
OPEN c_questionnaire;
LOOP
FETCH c_questionnaire INTO r_questionnaire;
EXIT WHEN c_questionnaire%NOTFOUND;

	SELECT SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_question_ref_id FROM DUAL;

	SELECT max(SEQUENCE_NUMBER) into li_seq FROM QUESTIONNAIRE WHERE QUESTIONNAIRE_ID=r_questionnaire.QUESTIONNAIRE_ID;
	  if li_seq is null then
		li_seq := 1;
	  else
	   li_seq := li_seq + 1;
	  end if;
  
	INSERT INTO QUESTIONNAIRE(QUESTIONNAIRE_REF_ID,QUESTIONNAIRE_ID,SEQUENCE_NUMBER,NAME,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,IS_FINAL,VER_NBR,OBJ_ID,FILE_NAME,TEMPLATE,DOCUMENT_NUMBER)
	VALUES(li_question_ref_id,r_questionnaire.QUESTIONNAIRE_ID,li_seq,r_questionnaire.NAME,r_questionnaire.DESCRIPTION,sysdate,user,r_questionnaire.IS_FINAL,1,SYS_GUID(),r_questionnaire.FILE_NAME,r_questionnaire.TEMPLATE,NULL);

END LOOP;
CLOSE c_questionnaire;
END;
/

DECLARE
	li_question_ref_id NUMBER(12);
	li_seq NUMBER(4);
	li_question NUMBER(12);
	li_sequence NUMBER(4);
	li_question_ref NUMBER(12);
	li_ques_ref NUMBER(12);
	li_num NUMBER;
	li_count NUMBER;
	li_qnr_ref_id QUESTIONNAIRE.QUESTIONNAIRE_REF_ID%type;
	
	CURSOR c_quest_questions IS
	SELECT a.QUESTIONNAIRE_QUESTIONS_ID,b.QUESTIONNAIRE_ID,b.SEQUENCE_NUMBER,a.QUESTIONNAIRE_REF_ID_FK,a.QUESTION_REF_ID_FK,a.QUESTION_NUMBER,a.PARENT_QUESTION_NUMBER,a.CONDITION_FLAG,a.CONDITION_TYPE,a.CONDITION_VALUE,a.UPDATE_TIMESTAMP,a.UPDATE_USER,a.QUESTION_SEQ_NUMBER,a.RULE_ID
	FROM  BOOT_QUESTIONNAIRE_QUESTIONS a INNER JOIN BOOT_QUESTIONNAIRE b ON a.QUESTIONNAIRE_REF_ID_FK = b.QUESTIONNAIRE_REF_ID
	WHERE b.QUESTIONNAIRE_ID = 5;
	r_quest_questions c_quest_questions%ROWTYPE;

BEGIN
	IF c_quest_questions%ISOPEN THEN
	CLOSE c_quest_questions;
	END IF;
	OPEN c_quest_questions;
	LOOP
	FETCH c_quest_questions INTO r_quest_questions;
	EXIT WHEN c_quest_questions%NOTFOUND;
    li_num:=1;

	BEGIN
		SELECT QUESTION_ID,SEQUENCE_NUMBER INTO li_question,li_sequence FROM BOOT_QUESTION WHERE QUESTION_REF_ID = r_quest_questions.QUESTION_REF_ID_FK;

		SELECT count(question_ref_id) INTO li_count FROM QUESTION WHERE QUESTION_ID = li_question AND SEQUENCE_NUMBER = li_sequence;

		if li_count = 0 then
			SELECT  SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL INTO li_question_ref FROM DUAL; 
		
			INSERT INTO QUESTION(QUESTION_REF_ID,QUESTION_ID,SEQUENCE_NUMBER,SEQUENCE_STATUS,QUESTION,STATUS,GROUP_TYPE_CODE,QUESTION_TYPE_ID,LOOKUP_CLASS,LOOKUP_RETURN,DISPLAYED_ANSWERS,MAX_ANSWERS,ANSWER_MAX_LENGTH,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,DOCUMENT_NUMBER)
			SELECT li_question_ref,a.QUESTION_ID,a.SEQUENCE_NUMBER,a.SEQUENCE_STATUS,a.QUESTION,a.STATUS,a.GROUP_TYPE_CODE,a.QUESTION_TYPE_ID,a.LOOKUP_CLASS,a.LOOKUP_RETURN,a.DISPLAYED_ANSWERS,a.MAX_ANSWERS,a.ANSWER_MAX_LENGTH,sysdate,user,1,sys_guid(),null
			FROM BOOT_QUESTION a WHERE a.QUESTION_REF_ID = r_quest_questions.QUESTION_REF_ID_FK;
		
		
		else
			SELECT QUESTION_REF_ID INTO li_question_ref FROM QUESTION WHERE QUESTION_ID = li_question AND SEQUENCE_NUMBER = li_sequence;
		
		end if;
	 
	EXCEPTION
	WHEN OTHERS THEN
	--li_question_ref := r_quest_questions.QUESTION_REF_ID_FK;
   dbms_output.put_line('QUESTION_ID is missing in QUESTIONNAIRE_QUESTION for QUESTION_REF_ID: '||r_quest_questions.QUESTION_REF_ID_FK);
   li_num:=0;
	END;
	IF li_num<>0 THEN	
	BEGIN
		SELECT t1.QUESTIONNAIRE_REF_ID into li_qnr_ref_id FROM QUESTIONNAIRE t1
		WHERE t1.QUESTIONNAIRE_ID = r_quest_questions.QUESTIONNAIRE_ID
		AND t1.SEQUENCE_NUMBER = ( SELECT max(t2.SEQUENCE_NUMBER)
                              FROM QUESTIONNAIRE t2
                              WHERE t2.QUESTIONNAIRE_ID = t1.QUESTIONNAIRE_ID
                          );
	
		INSERT INTO QUESTIONNAIRE_QUESTIONS(QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_REF_ID_FK,QUESTION_NUMBER,PARENT_QUESTION_NUMBER,CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,UPDATE_TIMESTAMP,UPDATE_USER,QUESTION_SEQ_NUMBER,VER_NBR,OBJ_ID,RULE_ID)
		VALUES(SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,li_qnr_ref_id,li_question_ref,r_quest_questions.QUESTION_NUMBER,r_quest_questions.PARENT_QUESTION_NUMBER,r_quest_questions.CONDITION_FLAG,r_quest_questions.CONDITION_TYPE,r_quest_questions.CONDITION_VALUE,sysdate,user,r_quest_questions.QUESTION_SEQ_NUMBER,1,SYS_GUID(),r_quest_questions.RULE_ID);
		
	EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('QUESTIONNAIRE_REF_ID_FK:'||li_qnr_ref_id||', Error is '||sqlerrm);
	END;
 END IF;

END LOOP;
CLOSE c_quest_questions;
END;
/
declare
	li_questionnaire_usg_id number;
	li_qnr_sequence questionnaire.sequence_number%type;
	li_qnr_ref_id  questionnaire.questionnaire_ref_id%type;
	ls_qnr_nm questionnaire.name%type;
	li_count NUMBER;
begin

  SELECT max(t2.SEQUENCE_NUMBER) into li_qnr_sequence FROM questionnaire t2 WHERE t2.questionnaire_id = 5;
   
  SELECT t1.questionnaire_ref_id into li_qnr_ref_id FROM questionnaire t1
      WHERE t1.questionnaire_id = 5
      AND t1.sequence_number = ( SELECT max(t2.sequence_number)
                                FROM questionnaire t2
                                WHERE t2.questionnaire_id = t1.questionnaire_id
                            );
                            
  select count(questionnaire_usage_id) into li_count
  from questionnaire_usage
  where module_item_code = 3
  and   module_sub_item_code = 0
  and   questionnaire_ref_id_fk = li_qnr_ref_id
  and is_mandatory =  'N'
  and   rule_id is null;
 
  if li_count = 0 then
 
       INSERT INTO QUESTIONNAIRE_USAGE(
       QUESTIONNAIRE_USAGE_ID,
       MODULE_ITEM_CODE,
       MODULE_SUB_ITEM_CODE,
       QUESTIONNAIRE_REF_ID_FK,
       QUESTIONNAIRE_SEQUENCE_NUMBER,
       RULE_ID,
       QUESTIONNAIRE_LABEL,
       UPDATE_TIMESTAMP,
       UPDATE_USER,
       VER_NBR,
       OBJ_ID,
       IS_MANDATORY
       )
       SELECT
       SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL, 
       3,
       0,
       li_qnr_ref_id,
       li_qnr_sequence,
       RULE_ID,
       QUESTIONNAIRE_LABEL,
       sysdate,
       user,
       1,
       sys_guid(),
       'N' 
       FROM BOOT_QUESTIONNAIRE_USAGE;
   
 end if;
  
 end; 
 /
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

	

end;
/
UPDATE QUESTION SET LOOKUP_CLASS = 'org.kuali.coeus.common.framework.rolodex.NonOrganizationalRolodex' WHERE LOOKUP_CLASS = 'org.kuali.kra.bo.NonOrganizationalRolodex'
/
UPDATE QUESTION SET LOOKUP_CLASS = 'org.kuali.coeus.common.framework.org.Organization' WHERE LOOKUP_CLASS = 'org.kuali.kra.bo.Organization'
/
UPDATE QUESTIONNAIRE
SET IS_FINAL='N'
WHERE QUESTIONNAIRE_ID = 5
/
UPDATE QUESTIONNAIRE
SET IS_FINAL='Y'
WHERE QUESTIONNAIRE_REF_ID IN (
SELECT t1.QUESTIONNAIRE_REF_ID FROM QUESTIONNAIRE t1
WHERE t1.QUESTIONNAIRE_ID = 5
AND t1.SEQUENCE_NUMBER = ( SELECT max(t2.SEQUENCE_NUMBER)
FROM QUESTIONNAIRE t2
WHERE t2.QUESTIONNAIRE_ID = t1.QUESTIONNAIRE_ID
))
/
commit
/						  
update question set LOOKUP_CLASS = 'org.kuali.coeus.common.framework.custom.arg.ArgValueLookup'  where LOOKUP_CLASS  ='org.kuali.kra.bo.ArgValueLookup'
/
commit
/
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
------- insert QNR5
ALTER TABLE QUESTION_EXPLANATION ENABLE CONSTRAINT FK_QUESTION_EXPLANATION ;
ALTER TABLE QUESTIONNAIRE_QUESTIONS ENABLE CONSTRAINT FK_QUESTIONNAIRE_QUESTIONS ;
ALTER TABLE QUESTIONNAIRE_ANSWER ENABLE CONSTRAINT FK_QUESTIONNAIRE_ANS_QID ;
select ' End time of QUESTION MODULE is '|| localtimestamp from dual
/
  