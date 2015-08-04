create or replace FUNCTION fn_gen_nda_survey_compl_notif (
      as_nda_number in NDA.NDA_NUMBER%type,
      as_PIId  in NDA.PERSON_ID%type,
      as_Title in NDA.TITLE%type,
      as_OrgName in NDA.ORGANIZATION_NAME%type,
      as_survey_responseid in  NDA.SURVEY_ID%type)
return number IS

crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
ls_recipients           varchar2(2000);
ls_Allrecipients           varchar2(2000);
ls_PiName               VARCHAR2(100);
ls_PiLastName           VARCHAR2(100);
ls_PIEmail             KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_SurveyResponseID         NOVI_NDA_SURVEY_RESP.SURVEYRESPONSEID%type;
ls_Answer                   NOVI_NDA_SURVEY_RESP.ANSWER%type;
li_Count                    number;
li_Count2                    number;
ls_message_status char(1);
li_notification_is_active PLS_INTEGER;
li_notification_type_id notification_type.notification_type_id% type := null;
cursor cur_survey_response is
        select QUESTION_DESC, ANSWER
        from NOVI_NDA_SURVEY_RESP s
        where S.SURVEYRESPONSEID = ls_SurveyResponseID
        and S.QUESTION_DESC = 'Describe the purpose(s) for this disclosure of confidential information:'
        order by pageindex, questionindex;

BEGIN

    ls_SurveyResponseID := as_survey_responseid;
  
	select distinct  trim(t1.email_addr)  , t3.last_nm , (t3.last_nm||', '|| t3.first_nm) as FULL_NAME
	into ls_PIEmail, ls_PiLastName, ls_PiName
	from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
	inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
	where t2.prncpl_id = as_PIID
	and  t1.dflt_ind = 'Y';   	
	
     select count(ANSWER)
     into li_Count
     from NOVI_NDA_SURVEY_RESP s
     where S.SURVEYRESPONSEID = ls_SurveyResponseID
     and S.QUESTION_DESC = '(R) Describe the purpose(s) for this disclosure of confidential information:';
                            
     
     if li_Count > 1 then
      --    If more than one checkbox is checked, and one is A, F or G, default send to amsiegel@mit.edu.
      --    If more than one checkbox is checked and A, F and G are NOT checked, default send to jsaucier@mit.edu.

         select count(ANSWER)
         into li_Count2
         from NOVI_NDA_SURVEY_RESP s
         where S.SURVEYRESPONSEID = ls_SurveyResponseID
         and S.QUESTION_DESC = '(R) Describe the purpose(s) for this disclosure of confidential information:'
         and answer in ('To enable discussions that could lead to a research collaboration',
                        'To enable MIT to obtain proprietary data and/or information that will be used in my group''s research**',
                        'Other purpose not listed above');
         
         if li_Count2 > 0 then
            ls_recipients := 'nda-request@mit.edu' ;
         else
            ls_recipients := 'ogc-nda-request@mit.edu' ;
         end if;
     
     
     elsif li_Count = 1 then
     
        select ANSWER
         into ls_Answer
         from NOVI_NDA_SURVEY_RESP s
         where S.SURVEYRESPONSEID = ls_SurveyResponseID
         and S.QUESTION_DESC = '(R) Describe the purpose(s) for this disclosure of confidential information:';
         
         if ls_Answer = 'To enable discussions that could lead to a research collaboration' then
            ls_recipients := 'nda-request@mit.edu' ;
            
         elsif ls_Answer = 'To enable discussions that could lead to development of an educational collaboration or development of new course materials' then
            ls_recipients := 'ogc-nda-request@mit.edu' ;
            
         elsif ls_Answer = 'To allow the outside organization to evaluate MIT technology (patented inventions and or copyrighted works and software) for potential licensing' then
            ls_recipients := 'tlo-nda-request@mit.edu' ;
            
         elsif ls_Answer = 'To allow MIT to evaluate equipment or software for purchase, loan or acquisition' then
            ls_recipients := 'ogc-nda-request@mit.edu' ;
            
         elsif ls_Answer = 'To allow MIT to disclose confidential data and or information to the other party in connection with an agreement for that party to provide services to MIT' then
            ls_recipients := 'ogc-nda-request@mit.edu' ;
            
         elsif ls_Answer = 'To enable MIT to obtain proprietary data and/or information that will be used in my group''s research**' then
            ls_recipients := 'nda-request@mit.edu' ;
            
         elsif ls_Answer = 'Other purpose not listed above' then
            ls_recipients := 'nda-request@mit.edu' ;
            
         else
            ls_recipients := 'kc-dev-team@mit.edu' ;
            
         end if;
         
     else
        ls_recipients := 'kc-dev-team@mit.edu' ;
     end if;
       
    
    ls_recipients := ls_recipients || ',' || ls_PIEmail;
    ls_Allrecipients := ls_recipients;
	
    li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,101,'501');
	if li_notification_is_active = 1 then
	begin
			   ls_message_status:='Y'; 
			   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,101,501,mail_subject,mail_message);
			   mail_subject := replace(mail_subject,'{NDA_NUMBER}',as_nda_number );				
			   mail_message := replace(mail_message, '{NDA_NUMBER}',as_nda_number );				   
			   mail_message := replace(mail_message, '{PI_NAME}',ls_PiName );	
			   mail_message := replace(mail_message, '{ORG_NAME}',as_OrgName );			
			   mail_message := replace(mail_message, '{TITLE}',as_Title );		
			   mail_message := replace(mail_message, '{SURVEY_RESPONSE_ID}',trim(ls_SurveyResponseID)  );				   
			   KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_Allrecipients,NULL,NULL,mail_subject,mail_message);	
				
	exception
	when others then
				ls_message_status:='N'; 		 
	end;   			
				
	li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'NDA Survey Completion report',mail_message);
	if li_ntfctn_id <>  -1 then 
	  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_recipients,ls_message_status);
	  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_PIEmail,ls_message_status);	
	end if;   			
	
	end if;	
	
    return 1;

    EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20101, 'Error Generating NDA Email. ' || SQLERRM
      );
        return 1;
END;
/