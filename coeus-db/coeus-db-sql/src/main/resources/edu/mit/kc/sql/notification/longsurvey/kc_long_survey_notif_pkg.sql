SET DEFINE OFF;
CREATE OR REPLACE package kc_long_survey_notif_pkg as
function fn_gen_long_survey_compl_notif(
      as_negotiation_number in NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type,
                                                    as_survey_responseid in
      varchar2)return number;
function fn_gen_long_survey_notif (as_negotiation_number in NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type,
						as_negotiation_id  in NEGOTIATION.negotiation_id%type,
            ai_AgrementTypeCode in NEGOTIATION.NEGOTIATION_AGREEMENT_TYPE_ID%type) return number;
function fn_update_long_survey_notif 
(AS_NEG_ID IN VARCHAR2  
, AS_PI_ID IN VARCHAR2  
, AS_SURVEY_ID IN VARCHAR2  
, AS_NEG_CLOSE_DATE IN DATE
, AS_NOTIFIED_FLAG IN VARCHAR2
, AS_NOTIFICATION_DATE IN DATE
) return number;
function FN_UPDATE_LONG_SURVEY_OPT_OUT
	(AS_PI_ID IN LONG_SURVEY_OPT_OUT.PI_ID%TYPE)
return number;

end;
/
CREATE OR REPLACE package body  kc_long_survey_notif_pkg as

FUNCTION fn_gen_long_survey_compl_notif (
      as_negotiation_number in NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type,
                                                    as_survey_responseid in
      varchar2)
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
ls_message_status char(1);


ls_recipients           varchar2(2000);
ls_Allrecipients           varchar2(2000);


ls_recipient            varchar2(8);
ls_email_address        KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
li_notification_typ_id NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%type := null;
ls_PIId                 PROPOSAL_LOG.PI_ID%type;
ls_PiName               VARCHAR2(120);
ls_PiLastName           KRIM_ENTITY_NM_T.LAST_NM%type;
ls_SponsorCode          PROPOSAL_LOG.SPONSOR_CODE%type;
ls_Title                PROPOSAL_LOG.TITLE%type;
ls_NegotiatorName       VARCHAR2(120);

li_AgrementTypeCode     NEGOTIATION_AGREEMENT_TYPE.NEGOTIATION_AGRMNT_TYPE_CODE%type;
ls_AgrementType         NEGOTIATION_AGREEMENT_TYPE.DESCRIPTION%type;

ls_SponsorName          SPONSOR.SPONSOR_NAME%type;

ls_PIEmail              KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_UnitNo               UNIT.UNIT_NUMBER%type;
ls_UnitName               UNIT.UNIT_NAME%type;
li_ntfctn_id NUMBER(12);
ldt_StartDate           NEGOTIATION.NEGOTIATION_START_DATE%type;
ls_StartDate               varchar2(50);
ls_doc NOTIFICATION.DOCUMENT_NUMBER%TYPE;
li_pos                      number;
li_NotifCount               number;
ls_emailid                  varchar2(200);
ls_SurvserResponseID        varchar2(200);
ls_Question                 varchar2(2000);
ls_Answer                   varchar2(2000);
ls_NegotEmail                  KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
li_notification_is_active PLS_INTEGER;

cursor cur_survey_response is
        select QUESTION_DESC, ANSWER
        from NOVI_LONG_SURVEY_RESP s
        where S.SURVEYRESPONSEID = ls_SurvserResponseID
        order by pageindex, questionindex;

BEGIN



        SELECT pl.PI_ID, pl.PI_NAME, pl.TITLE, pl.SPONSOR_CODE, pl.SPONSOR_NAME, U.UNIT_NUMBER, U.UNIT_NAME
        INTO ls_PIId, ls_PiName, ls_Title, ls_SponsorCode, ls_SponsorName, ls_UnitNo, ls_UnitName
        FROM PROPOSAL_LOG pl,unit u
        WHERE PROPOSAL_NUMBER = as_negotiation_number
        and PL.LEAD_UNIT = U.UNIT_NUMBER;



    select trim(kee.EMAIL_ADDR),ke.LAST_NM
    into ls_PIEmail, ls_PiLastName
    from KRIM_PRNCPL_T p,KRIM_ENTITY_NM_T ke,KRIM_ENTITY_EMAIL_T kee
    where p.ENTITY_ID=ke.ENTITY_ID 
	AND p.ENTITY_ID=kee.ENTITY_ID
	AND P.PRNCPL_ID = ls_PIId;

    select ke.LAST_NM||','||ke.FIRST_NM, n.NEGOTIATION_START_DATE, trim(kee.EMAIL_ADDR)
    into ls_NegotiatorName, ldt_StartDate, ls_NegotEmail
    from negotiation n, KRIM_PRNCPL_T p,KRIM_ENTITY_NM_T ke,KRIM_ENTITY_EMAIL_T kee
    where p.ENTITY_ID=ke.ENTITY_ID 
	and p.ENTITY_ID=kee.ENTITY_ID
   and N.ASSOCIATED_DOCUMENT_ID =  as_negotiation_number
    and N.NEGOTIATOR_PERSON_ID = P.PRNCPL_ID;
    
    if ldt_StartDate is not null then
        ls_StartDate := to_char(ldt_StartDate, 'mm/dd/yyyy');
    else
        ls_StartDate := '';
    end if;
    
   
    ls_recipients := 'negn-ind-sat@mit.edu' ;
    ls_recipients := ls_recipients || ',' || ls_NegotEmail;
    ls_Allrecipients := ls_recipients;
        
    ls_SurvserResponseID := as_survey_responseid;

	  li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,5,'500');
	  
	  if li_notification_is_active = 1 then
	  
		open cur_survey_response; 
        loop
        FETCH cur_survey_response INTO  ls_Question, ls_Answer;
        EXIT WHEN cur_survey_response%NOTFOUND;

        ls_message_status:='Y';
		 
		select notification_type_id into li_notification_typ_id from notification_type where module_code=5 and action_code=500;	

                    	
		   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,5,500,mail_subject,mail_message);
		   mail_message := replace(mail_message,'{NEGOTIATION_NUMBER}',as_negotiation_number );	
		   mail_message := replace(mail_message,'{PI_NAME}',ls_PiName);
		   mail_message := replace(mail_message,'{UNIT_NUMBER}',ls_UnitNo );	
		   mail_message := replace(mail_message,'{UNIT_NAME}',ls_UnitName);			   
		   mail_message := replace(mail_message, '{SPONSOR_CODE}',ls_SponsorCode );		   
		   mail_message := replace(mail_message, '{SPONSOR_NAME}',ls_SponsorName );			   
		   mail_message := replace(mail_message, '{TITLE}',ls_Title );
		   mail_message := replace(mail_message, '{FULL_NAME}',ls_NegotiatorName );	
		   mail_message := replace(mail_message, '{START_DATE}',ls_StartDate );
		   mail_message := replace(mail_message, '{QUESTION_DESC}',ls_Question );		
		   mail_message := replace(mail_message, '{ANSWER}',ls_Answer );				   
               
        end loop;

       close cur_survey_response;
	   BEGIN
			KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipients,NULL,NULL,mail_subject,mail_message); 
	   EXCEPTION
	   WHEN OTHERS THEN
	   ls_message_status:='N';
	   END; 
				
	  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Long Survey Notification',mail_message);
	  
	  if li_ntfctn_id <>  -1 then 
		  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_recipients,ls_message_status);
	  end if;   	            

	end if;
	
    return 1;

    EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20101, 'Error Generating Email. ' || SQLERRM
      );
        return 1;
END fn_gen_long_survey_compl_notif;


FUNCTION fn_gen_long_survey_notif (as_negotiation_number in NEGOTIATION.ASSOCIATED_DOCUMENT_ID%type,
									as_negotiation_id  in NEGOTIATION.negotiation_id%type,
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
			
								
				li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Long Survey Notification',mail_message);
				if li_ntfctn_id <>  -1 then 
				  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_recipient,ls_message_status);
				end if;   	            
	   
		end if;
				--select negotiation_id into li_negotiation from NEGOTIATION WHERE ASSOCIATED_DOCUMENT_ID=as_negotiation_number;
				
				Insert into LONG_SURVEY_NOTIF
			   (LONG_SURVEY_NOTIF_ID,NEGOTIATION_ID, PI_ID, NEGOTIATION_CLOSE_DATE, NOTIFIED_FLAG, NOTIFICATION_DATE, SURVEY_COMPLETION_DATE, SURVEY_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
				Values
				(SEQ_LONG_SURVEY_NOTIF_ID.nextval,as_negotiation_id, ls_PIId, sysdate, 'Y', sysdate, null, null,sysdate,user,1,SYS_GUID());

    
    
    return 1;

    EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20101, 'Error Generating Email. ' || SQLERRM );
        return 1;
END fn_gen_long_survey_notif;

FUNCTION fn_update_long_survey_notif 
(
  AS_NEG_ID IN VARCHAR2  
, AS_PI_ID IN VARCHAR2  
, AS_SURVEY_ID IN VARCHAR2  
, AS_NEG_CLOSE_DATE IN DATE
, AS_NOTIFIED_FLAG IN VARCHAR2
, AS_NOTIFICATION_DATE IN DATE
) RETURN NUMBER AS 

var_count number;

BEGIN

select count(*) into var_count from LONG_SURVEY_NOTIF where PI_ID = AS_PI_ID and NEGOTIATION_ID = AS_NEG_ID;

if var_count = 0 then
insert into LONG_SURVEY_NOTIF (LONG_SURVEY_NOTIF_ID,NEGOTIATION_ID, pi_id, negotiation_close_date, notified_flag, notification_date, survey_id, SURVEY_COMPLETION_DATE)
values(SEQ_LONG_SURVEY_NOTIF_ID.nextval,AS_NEG_ID , AS_PI_ID, AS_NEG_CLOSE_DATE, AS_NOTIFIED_FLAG, AS_NOTIFICATION_DATE,  AS_SURVEY_ID, SYSDATE);
else 
update LONG_SURVEY_NOTIF set 
SURVEY_COMPLETION_DATE = SYSDATE,
SURVEY_ID = AS_SURVEY_ID
where PI_ID = AS_PI_ID and NEGOTIATION_ID = AS_NEG_ID;
end if;

commit;
	return 0;
  
END fn_update_long_survey_notif;

FUNCTION FN_UPDATE_LONG_SURVEY_OPT_OUT
	(AS_PI_ID IN LONG_SURVEY_OPT_OUT.PI_ID%TYPE)
return number IS
	li_rc	number;
  pi_count number;
  ret number; 
BEGIN
  
  select count(*) into pi_count from long_survey_opt_out where PI_ID = AS_PI_ID;
  
  if pi_count = 0 then
	insert into LONG_SURVEY_OPT_OUT (PI_ID, SURVEY_OPTOUT_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	values(AS_PI_ID ,SYSDATE,SYSDATE,USER,1,SYS_GUID());
  ret := 0;
  else
  ret := 1;
  end if;
  
	return ret;

END FN_UPDATE_LONG_SURVEY_OPT_OUT;

end;
/