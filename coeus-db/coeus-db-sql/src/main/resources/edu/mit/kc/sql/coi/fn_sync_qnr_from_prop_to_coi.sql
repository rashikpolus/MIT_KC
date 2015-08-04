create or replace function fn_sync_qnr_from_prop_to_coi(
as_proposal in OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_ITEM_KEY@COEUS.KUALI%type,
as_person_id in OSP$QUESTIONNAIRE_ANS_HEADER.MODULE_SUB_ITEM_KEY@COEUS.KUALI%type,
as_user_id in OSP$USER.USER_ID@COEUS.KUALI%type,
as_actype in char) return number
is
ls_discl_num   NUMBER(10,0);
ls_discl_number	VARCHAR2(10);
ls_sequence_number OSP$COI_DISCLOSURE.SEQUENCE_NUMBER@COEUS.KUALI%type;
ls_qnr_id OSP$QUESTIONNAIRE.QUESTIONNAIRE_ID@COEUS.KUALI%type;
ls_mod_sub_item_cd questionnaire_answer_header.module_sub_item_code%type;
li_return NUMBER;
begin


if as_actype = 'I' then
    begin
		select COI_DISCLOSURE_NUMBER  into ls_discl_number   FROM OSP$COI_DISCLOSURE@COEUS.KUALI CD
		WHERE PERSON_ID = as_person_id   
		AND ROWNUM = 1;
		
		SELECT max(SEQUENCE_NUMBER) into ls_sequence_number FROM OSP$COI_DISCLOSURE@COEUS.KUALI WHERE COI_DISCLOSURE_NUMBER = ls_discl_number;
		ls_sequence_number := ls_sequence_number + 1;
		
	exception
	when others then
		select SEQ_COI_DISCLOSURE_NUMBER.nextval@COEUS.KUALI	into ls_discl_num from dual;
		ls_discl_number := LTRIM(TO_CHAR(ls_discl_num, '0000000000'));
		ls_sequence_number := 1;
	end ;	

else
		
	begin	
        select cd.COI_DISCLOSURE_NUMBER,cd.SEQUENCE_NUMBER INTO ls_discl_number,ls_sequence_number from OSP$COI_DISCLOSURE@COEUS.KUALI cd
        where  cd.PERSON_ID = as_person_id  
		and cd.MODULE_ITEM_KEY = as_proposal;
	exception
	when others then
		return -1;
	end;

end if;

	begin
		  SELECT  QNR.QUESTIONNAIRE_ID INTO ls_qnr_id      
		  FROM OSP$QUESTIONNAIRE@COEUS.KUALI QNR, OSP$QUESTIONNAIRE_USAGE@COEUS.KUALI QU
		  WHERE QNR.QUESTIONNAIRE_ID = QU.QUESTIONNAIRE_ID
		  AND QNR.VERSION_NUMBER = QU.VERSION_NUMBER
		  AND QNR.IS_FINAL = 'Y'
		  AND QU.MODULE_ITEM_CODE = 8
		  AND QU.MODULE_SUB_ITEM_CODE = 1          
		  AND ( QU.RULE_ID = 0 OR QU.RULE_ID IS NULL )
		  AND  rownum = 1;

		  SELECT DECODE(PROP_PERSON_ROLE_ID,'PI',4,'COI',5,6) into ls_mod_sub_item_cd
		  FROM EPS_PROP_PERSON
		  WHERE PROPOSAL_NUMBER = as_proposal
		  AND PERSON_ID = as_person_id;
		  
		  li_return := fn_copy_qnr_from_ppc_to_coi(ls_discl_number,ls_sequence_number,ls_qnr_id,as_proposal,as_person_id,ls_mod_sub_item_cd,as_actype);
	
	exception
	when others then
		return -1;
	end;
	
  return li_return;


end;
/

