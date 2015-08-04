declare
	li_questionnaire_usg_id number;
	li_qnr_sequence questionnaire.sequence_number%type;
	li_qnr_ref_id  questionnaire.questionnaire_ref_id%type;
	ls_qnr_nm questionnaire.name%type;
	li_count NUMBER;
begin

  SELECT max(t2.SEQUENCE_NUMBER) into li_qnr_sequence FROM questionnaire t2 WHERE t2.questionnaire_id = 5;
   
  SELECT t1.questionnaire_ref_id,t1.name into li_qnr_ref_id,ls_qnr_nm FROM questionnaire t1
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
       VALUES(
       SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL, 
       3,
       0,
       li_qnr_ref_id,
       li_qnr_sequence,
       null,
       ls_qnr_nm,
       sysdate,
       user,
       1,
       sys_guid(),
       'N' 
       );
   
 end if;
  
 end;
 /