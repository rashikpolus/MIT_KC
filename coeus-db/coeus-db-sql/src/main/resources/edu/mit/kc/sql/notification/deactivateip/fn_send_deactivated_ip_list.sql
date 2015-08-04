create or replace
FUNCTION fn_send_deactivated_ip_list ( as_run_date IN VARCHAR2) 
return number IS

mesg 					clob;
ls_MailReceiver     varchar2(256); 
li_notification_typ_id NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%type;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   CLOB ;
li_notification_is_active PLS_INTEGER;
cursor c_proposal_list is
select proposal_number,title FROM temp_deactivated_ip;
r_proposal_list c_proposal_list%rowtype;

li_count pls_integer := 0;
BEGIN

	li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,2,'575');
	if li_notification_is_active = 1 then

		BEGIN
			select VAL into ls_MailReceiver
			from KRCR_PARM_T
			where PARM_NM = 'KC_DEFAULT_EMAIL_RECIPIENT'
			AND  nmspc_cd ='KC-GEN';
		EXCEPTION
		WHEN OTHERS THEN
		raise_application_error(-20101, 'Error Generating Email. Parameter KC_DEFAULT_EMAIL_RECIPIENT not found in parameter table' );
		END;
		
		select notification_type_id into li_notification_typ_id from notification_type where module_code = 2 and action_code = 575;
	    KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,2,575,mail_subject,mail_message);
		mesg := '';	
		open  c_proposal_list;
        loop
            fetch c_proposal_list into r_proposal_list;
            EXIT WHEN c_proposal_list%NOTFOUND;
            mesg := mesg || '<tr>
                    <td>' || r_proposal_list.proposal_number || '</td>
                    <td>' || r_proposal_list.title  || '</td>
                   </tr>';
            
            li_count := li_count + 1;
        end loop;
		close c_proposal_list;		
		mail_message := replace(mail_message, '{LIST}',mesg );
		mail_message := mail_message ||'</br></br><b> TOTAL </b>'||li_count||' Proposals';		
		mail_subject := mail_subject ||' - '||	as_run_date;
		 
		BEGIN
			KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_MailReceiver,NULL,NULL,mail_subject,mail_message); 
	    EXCEPTION
	    WHEN OTHERS THEN
	    raise_application_error(-20100,'Database error occured while attempting to send list of deactivated Inst proposal list ' || substr(sqlerrm(sqlcode),1,200));
	    return 0;
      END; 
	   
end if;	 
return 1;

END;
/