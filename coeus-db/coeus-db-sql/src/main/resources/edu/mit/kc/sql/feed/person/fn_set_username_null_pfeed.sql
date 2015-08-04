create or replace
FUNCTION fn_set_username_null_pfeed ( as_EmailId IN VARCHAR2,
									as_Subject IN VARCHAR2) return number IS

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
mail_subject   			NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message  			clob;
li_ntfctn_id   			KREN_NTFCTN_T.NTFCTN_ID%TYPE;
li_mail_send 			CHAR(1);

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

	
	mesg := mesg || '' || crlf || crlf ;

	mesg := mesg || '-----------------------------------------------------------------------------' || CHR( 13 ) ||
					'<p>Following Kerberos IDs were set as Inactive from person feed.<p>'  ||  CHR( 13 ) ||
					'-----------------------------------------------------------------------------' ||  CHR( 13 ) ;
	mesg := mesg ||  CHR( 13 ) ||  CHR( 13 );
	
  	   
	open cur_inactive_person;
	loop
		fetch cur_inactive_person into
			ls_PersonId, ls_UserName, ls_FullName;
		exit when cur_inactive_person%NOTFOUND;	

			   mesg := mesg|| '<p>'||CHR( 13 ) ||'*** KC User *** '|| ls_PersonId ||tab || ls_UserName ||tab || ls_FullName;		
        
	end loop;
	close cur_inactive_person;

	BEGIN
		select VAL into ls_TestMailReceiver
		from KRCR_PARM_T
		where PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS'
		AND  nmspc_cd ='KC-GEN';
	EXCEPTION
	WHEN OTHERS THEN
	raise_application_error(-20101, 'Error Generating Email. Parameter EMAIL_NOTIFICATION_TEST_ADDRESS not found in parameter table' );
	END;

	mail_subject := as_Subject;
	
	mail_message := mesg;
	begin
		 KC_MAIL_GENERIC_PKG.SEND_MAIL(ls_TestMailReceiver,null,ls_TestMailReceiver,mail_subject,mail_message);
	exception
	when others then
		raise_application_error(-20000,  'Failed to send mail due to the following error: ' || sqlerrm);  
	end;
	
	
	update krim_person_document_t
	set ACTV_IND = 'N' 
	where prncpl_id in (select prncpl_id as person_id
										from krim_person_document_t
										minus
								 		select person_id
								 		from warehouse_person)
	and prncpl_nm not in ('admin','kr')
	and prncpl_nm is not null;
	
	update krim_prncpl_t
	set ACTV_IND = 'N'
	where prncpl_id in (select prncpl_id as  person_id
										from krim_prncpl_t
										minus
								 		select person_id
								 		from warehouse_person)
	and prncpl_nm not in ('admin','kr')								 		
	and prncpl_nm is not null;
  
	return 0;

END;
/