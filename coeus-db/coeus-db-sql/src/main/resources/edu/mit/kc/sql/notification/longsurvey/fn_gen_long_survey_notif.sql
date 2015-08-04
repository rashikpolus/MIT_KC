create or replace
FUNCTION fn_gen_long_survey_notif (as_negotiation_number in NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type,
            ai_AgrementTypeCode in NEGOTIATION.NEGOTIATION_AGREEMENT_TYPE_ID%type)
return number IS


ls_mailhost         VARCHAR2(100) ;
mail_conn             utl_smtp.connection;
mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
tab                     varchar2(1) := chr(9);

ls_Sender                varchar2(256) ;
ls_MailMode                varchar2(2);
ls_TestMailReceiver    varchar2(256);
ls_ReplyToId            varchar2(256);
ls_DefaultDomain        varchar2(256);
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
li_notification_typ_id NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%type := null;
ls_recipients           varchar2(2000);
ls_Allrecipients           varchar2(2000);
li_negotiation  NEGOTIATION.NEGOTIATION_ID%type;

ls_recipient            varchar2(8);
ls_email_address        KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_PIId                PROPOSAL_LOG.PI_ID%type;
ls_PiName                VARCHAR2(120);
ls_PiLastName           KRIM_ENTITY_NM_T.LAST_NM%type;
ls_SponsorCode          PROPOSAL_LOG.SPONSOR_CODE%type;
ls_Title                PROPOSAL_LOG.TITLE%type;
li_ntfctn_id NUMBER(12);
ls_message_status char(1);
li_AgrementTypeCode     NEGOTIATION_AGREEMENT_TYPE.NEGOTIATION_AGRMNT_TYPE_CODE%type;
ls_AgrementType         NEGOTIATION_AGREEMENT_TYPE.DESCRIPTION%type;

ls_SponsorName          SPONSOR.SPONSOR_NAME%type;

ls_PIEmail              KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_doc NOTIFICATION.DOCUMENT_NUMBER%TYPE;
li_pos                      number;
li_NotifCount               number;
ls_emailid                  varchar2(200);
li_notification_is_active PLS_INTEGER;

BEGIN

    --check if a notification has been sent for this negotiation
    --if a notification was already sent, do not send another one.
            
        li_AgrementTypeCode := ai_AgrementTypeCode;
		
        
   begin
   
        select nt.DESCRIPTION
        into  ls_AgrementType
        from NEGOTIATION_AGREEMENT_TYPE nt
        where Nt.NEGOTIATION_AGRMNT_TYPE_ID = li_AgrementTypeCode;
   
	exception
	when others then
	ls_AgrementType := ' ' ;
   end;
   
    --get proposal information from IP first
   begin
        SELECT pi.PERSON_ID, pi.FULL_NAME, p.TITLE, p.SPONSOR_CODE, s.SPONSOR_NAME
        INTO ls_PIId, ls_PiName, ls_Title, ls_SponsorCode, ls_SponsorName
        FROM PROPOSAL p, PROPOSAL_PERSONS pi,sponsor s
        WHERE p.PROPOSAL_NUMBER = as_negotiation_number
        and P.SEQUENCE_NUMBER = ( select max(p2.sequence_number) from PROPOSAL p2 where P.PROPOSAL_NUMBER = P2.PROPOSAL_NUMBER)
        and P.PROPOSAL_NUMBER = PI.PROPOSAL_NUMBER
        and pi.SEQUENCE_NUMBER = ( select max(pi2.sequence_number) from PROPOSAL_PERSONS pi2   where Pi.PROPOSAL_NUMBER = Pi2.PROPOSAL_NUMBER) 
        and PI.CONTACT_ROLE_CODE in('PI')
        and P.SPONSOR_CODE = S.SPONSOR_CODE;
   exception
        when others then
            ls_PIId := null;
   end;
   
   if ls_PIId is null then
        BEGIN
            SELECT PI_ID, PI_NAME, TITLE, SPONSOR_CODE, SPONSOR_NAME
            INTO ls_PIId, ls_PiName, ls_Title, ls_SponsorCode, ls_SponsorName
            FROM PROPOSAL_LOG
            WHERE PROPOSAL_NUMBER = as_negotiation_number;
        END;
   end if;
   

		select trim(kee.EMAIL_ADDR),ke.LAST_NM
        into ls_PIEmail, ls_PiLastName
        from KRIM_PRNCPL_T p,KRIM_ENTITY_NM_T ke,KRIM_ENTITY_EMAIL_T kee
        where p.ENTITY_ID=ke.ENTITY_ID 
	    AND p.ENTITY_ID=kee.ENTITY_ID
	    AND P.PRNCPL_ID = ls_PIId;
  
                
            ls_recipients := ls_PIEmail ;
            ls_Allrecipients := ls_recipients;
			
		   ls_message_status:='Y';
		   
		li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,5,'501');
		if li_notification_is_active = 1 then
			
           select notification_type_id into li_notification_typ_id from notification_type where module_code=5 and action_code=501;
		   
           KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,5,501,mail_subject,mail_message);
		   mail_message := replace(mail_message,'{LAST_NAME}',ls_PiLastName );	
		   mail_message := replace(mail_message,'{AGREEMENT_TYPE}',ls_AgrementType);
           mail_message := replace(mail_message,'{SPONSOR_NAME}',ls_SponsorName );	
		   mail_message  := mail_message || crlf || crlf 
                || '<p><a href="http://coeus-dev1.mit.edu/NoviSurvey/n/LongitudinalSurvey.aspx?' || '&MIT_ID=' || ls_PIId
                || '&Negotiation_number=' || as_negotiation_number 
                || '&Response_ID=' || ls_PIId || as_negotiation_number 
                || '&Negotiation_Type=' || replace(ls_AgrementType, ' ', '%20') || '">'
                || '<b>Click here</a> to begin the survey</b>'
                || '<p>Sincerely,</p>'
                || '<p>Craig Newfield <p/>'
                || 'Assistant Director<br />'
                || 'Office of Sponsored Programs<br />'
                || 'Massachusetts Institute of Technology<br />'
                || 'O  1-617-253-3856<br />'
                || 'M  1-617-749-9679<br />'
                || 'F  1-617-253-4734<br />'
                || crlf || crlf  
                || crlf || crlf 
                || crlf || crlf  
                || crlf || crlf;
				
				BEGIN
					 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_Allrecipients,NULL,NULL,mail_subject,mail_message); 
				EXCEPTION
				WHEN OTHERS THEN
				ls_message_status:='N';
				END; 
				begin
					select document_number into ls_doc from NEGOTIATION where ASSOCIATED_DOCUMENT_ID=as_negotiation_number; 
				exception
				when others then
				ls_doc := null;
				end;
				
								
				li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Long Survey Notification',mail_message);
				if li_ntfctn_id <>  -1 then 
				  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_recipient,ls_message_status);
				end if;   
	            
	   end if;

				select negotiation_id into li_negotiation from NEGOTIATION WHERE ASSOCIATED_DOCUMENT_ID=as_negotiation_number;
				
				Insert into LONG_SURVEY_NOTIF
			   (LONG_SURVEY_NOTIF_ID,NEGOTIATION_ID, PI_ID, NEGOTIATION_CLOSE_DATE, NOTIFIED_FLAG, NOTIFICATION_DATE, SURVEY_COMPLETION_DATE, SURVEY_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
				Values
				(SEQ_LONG_SURVEY_NOTIF_ID.nextval,li_negotiation, ls_PIId, sysdate, 'Y', sysdate, null, null,sysdate,user,1,SYS_GUID());

    
    
    return 1;

    EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20101, 'Error Generating Email. ' || SQLERRM );
        return 1;
END;
/