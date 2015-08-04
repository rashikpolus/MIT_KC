create or replace
FUNCTION fn_inactive_users_pfeed return number IS

/*******************************************************************
This procedure generates emails listing all persons whose user names where set
to NULL during the feed process.
Once Emails are generated, this function does the actual updates
to set Active indicator in krim_prncpl_t table to 'N'
but not in warehouse_person table

This function should be called from person feed script
********************************************************************/

ls_mailhost 			VARCHAR2(100) ;
mail_conn 				utl_smtp.connection;
mesg 					clob;
crlf 					VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
tab 					varchar2(1) := chr(9);

ls_Sender				varchar2(256) ;
ls_ReplyToId			varchar2(256) ;

li_Count				number;
ls_PersonID				VARCHAR2(40);
ls_UserName				VARCHAR2(100);
ls_FullName				VARCHAR2(200);
li_CoeusUSerCount		number;
ls_TestMailReceiver     varchar2(256); 
li_mail_send 			CHAR(1);
li_notification_typ_id NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%type;
ls_message_status char(1);
li_ntfctn_id NUMBER(12);
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_notification_is_active PLS_INTEGER;


cursor cur_inactive_person  is
	select p.prncpl_id,p.prncpl_nm,(e.last_nm||','||e.first_nm) as full_name
		from krim_prncpl_t p,krim_entity_nm_t e
    where p.entity_id=e.entity_id
		and p.prncpl_id in (select prncpl_id as person_id
										from krim_prncpl_t
										minus
								 		select person_id
								 		from warehouse_person)
		and p.prncpl_nm is not null;
    

BEGIN

	select count(person_id)
		into li_count
		from warehouse_person;

	if li_count < 1 then
	   return 0;
    end if;

	
	--mesg := mesg || '' || crlf || crlf ;

	--mesg := mesg || '-----------------------------------------------------------------------------' || CHR( 13 ) ||
	--				'<p>Following Kerberos IDs were set as Inactive from person feed.<p>'  ||  CHR( 13 ) ||
	--				'-----------------------------------------------------------------------------' ||  CHR( 13 ) ;
	--mesg := mesg ||  CHR( 13 ) ||  CHR( 13 );
li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,6,'557');
if li_notification_is_active = 1 then
  	   
	open cur_inactive_person;
	loop
		fetch cur_inactive_person into
			ls_PersonId, ls_UserName, ls_FullName;
		exit when cur_inactive_person%NOTFOUND;	
		
		        
	           
		       select notification_type_id into li_notification_typ_id from notification_type where module_code=6 and action_code=557;
			   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,6,557,mail_subject,mail_message);
		        mail_message := replace(mail_message,'{PERSON_ID}',ls_PersonId);	
		        mail_message := replace(mail_message,'{USER_NAME}',ls_UserName);
                mail_message := replace(mail_message,'{FULL_NAME}',ls_FullName );	

			  -- mesg := mesg|| '<p>'||CHR( 13 ) ||'*** KC User *** '|| ls_PersonId ||tab || ls_UserName ||tab || ls_FullName;		
        
	end loop;
	close cur_inactive_person;

	BEGIN
		select VAL into ls_TestMailReceiver
		from KRCR_PARM_T
		where PARM_NM = 'KC_DEFAULT_EMAIL_RECIPIENT'
		AND  nmspc_cd ='KC-GEN';
	EXCEPTION
	WHEN OTHERS THEN
	raise_application_error(-20101, 'Error Generating Email. Parameter KC_DEFAULT_EMAIL_RECIPIENT not found in parameter table' );
	END;

	--mail_subject := as_Subject;
	
	--mail_message := mesg;
	BEGIN
			KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_TestMailReceiver,NULL,NULL,mail_subject,mail_message); 
	   EXCEPTION
	   WHEN OTHERS THEN
	   ls_message_status:='N';
	   END; 
	   
	   li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Person Feed',mail_message);
	  
	  if li_ntfctn_id <>  -1 then 
		  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_TestMailReceiver,ls_message_status);
	  end if;   	        

end if;	  
	
	update krim_person_document_t
	set ACTV_IND = 'N' 
	where prncpl_id in (select prncpl_id as person_id
										from krim_person_document_t
										minus
								 		select person_id
								 		from warehouse_person)
	and prncpl_id not in ( select prncpl_id from person_inactive_exception )
	and prncpl_nm is not null;
	
	update krim_prncpl_t
	set ACTV_IND = 'N'
	where prncpl_id in (select prncpl_id as  person_id
										from krim_prncpl_t
										minus
								 		select person_id
								 		from warehouse_person)
	and prncpl_id not in ( select prncpl_id from person_inactive_exception )								 		
	and prncpl_nm is not null;
  
	return 0;

END;
/
