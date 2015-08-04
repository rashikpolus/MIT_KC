create or replace
FUNCTION fn_gen_kp_coi_notification(as_person_id in award_persons.PERSON_ID%type,
        as_mit_award_number in AWARD.AWARD_NUMBER%type,
        li_Coi_Complete in number,
        li_Training_Complete in number,
        li_NeedsCoi in Number,
        li_isPCK number )
return number IS




ls_TestMailReceiver    varchar2(256);
ls_recipients          varchar2(2000);
ls_PerName             VARCHAR2(100);
ls_PerEmail            KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_PerFirstName        VARCHAR2(100);
ls_PerLastName         VARCHAR2(100);

ls_LeadUnit             UNIT.UNIT_NUMBER%type;
ls_LeadUnitName         UNIT.UNIT_NAME%type;
ls_Account              AWARD.ACCOUNT_NUMBER%type;
ls_PIName               award_persons.full_name%type;

mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
li_notification_type_id notification_type.notification_type_id% type := null;
ls_document_number award.document_number% type;
li_mail_send CHAR(1);
li_notification_is_active PLS_INTEGER;
BEGIN

    BEGIN
        select VAL  into ls_TestMailReceiver
        from KRCR_PARM_T
        where PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS'
		AND  nmspc_cd ='KC-GEN';
        
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20101, 'Error Generating Email. Parameter CMS_TEST_MAIL_RECEIVE_ID not found in parameter table' );
            return -1;
    END;

     begin

			select distinct t3.first_nm , t3.last_nm , (t3.last_nm||', '|| t3.first_nm) , t1.email_addr
			into ls_PerFirstName, ls_PerLastName, ls_PerName, ls_PerEmail
			from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
			inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
			where t2.prncpl_id = as_person_id
			and  t1.dflt_ind = 'Y';

         exception
            when others then
                ls_PerEmail := ls_TestMailReceiver;
        end;


     if (ls_PerEmail is null) or (length(ls_PerEmail) = 0) then
            ls_PerEmail := ls_TestMailReceiver;
     end if;

    begin

			select
			t1.account_number,
			t2.full_name,
			t4.unit_number,
			t5.unit_name
			into ls_Account, ls_PIName, ls_LeadUnit, ls_LeadUnitName
		   from award t1 inner join award_persons t2 on t1.award_id = t2.award_id
		   inner join award_person_units t4 on t2.award_person_id = t4.award_person_id
		   inner join unit t5 on t4.unit_number = t5.unit_number
		   where t1.award_number = as_mit_award_number
		   and t2.contact_role_code = 'PI'
		   and t1.sequence_number = (select max(s1.sequence_number) from award s1 where s1.award_number = t1.award_number)
		   and  t4.lead_unit_flag = 'Y';

    exception
        when others then
            ls_Account := ' ';
            ls_PIName := ' ';
            ls_LeadUnit := ' ';
            ls_LeadUnitName := ' ';
    end;

		ls_recipients := ls_PerEmail;


        if (li_NeedsCoi = 0) and  (li_isPCK = 1) then
			
			select NOTIFICATION_TYPE_ID into li_notification_type_id from NOTIFICATION_TYPE where module_code = 1 and action_code = 602;
			li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,1,'602');			
			KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,1,602,mail_subject,mail_message);
			mail_message := replace(mail_message, '{PI_NAME}',ls_PIName );
            mail_message := replace(mail_message, '{LEAD_UNIT}',ls_LeadUnit );
			mail_message := replace(mail_message, '{LEAD_UNIT_NAME}',ls_LeadUnitName );
			mail_message := replace(mail_message, '{AWARD_NUMBER}',as_mit_award_number );
			mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_Account );

        else
            select NOTIFICATION_TYPE_ID into li_notification_type_id from NOTIFICATION_TYPE where module_code = 1 and action_code = 603;
			li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,1,'603');
			KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,1,603,mail_subject,mail_message);
            mail_message := replace(mail_message, '{PI_NAME}',ls_PIName );
            mail_message := replace(mail_message, '{LEAD_UNIT}',ls_LeadUnit );
			mail_message := replace(mail_message, '{LEAD_UNIT_NAME}',ls_LeadUnitName );
			mail_message := replace(mail_message, '{AWARD_NUMBER}',as_mit_award_number );
			mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_Account );

           if li_Coi_Complete <> 1 then
                mail_message := mail_message || '<p>Please complete your Annual/Master Conflict of Interest Disclosure.  Instructions can be found at <br/>http://coi.mit.edu/research/how-to-disclose-in-coeus ';
           end if;

             if li_Training_Complete <> 1 then
                mail_message := mail_message || '<p>Please complete your training; it will take approximately 1-1 1/2 hours and can be completed in multiple sessions.  Details for how to access the training can be found at <br/>http://coi.mit.edu/research/sponsor-specific-guidelines/nih/training-requirements-for-phs-investigators';
           end if;
        end if;
	
	if li_notification_is_active = 1 then
		-- appending subject
		if (li_NeedsCoi = 0) and  (li_isPCK = 1) then
             mail_subject := mail_subject||' - COI Disclosure Required' ;
        else

            if (li_Coi_Complete <> 1) AND (li_Training_Complete <> 1) THEN
                mail_subject := mail_subject||' - Disclosure & Training Required';

            elsif (li_Coi_Complete <> 1) THEN
                mail_subject := mail_subject||' - Disclosure Required';

            elsif (li_Training_Complete <> 1) THEN
               mail_subject := mail_subject||' - Training Required';

            END IF;
        end if;
		-- appending subject

	-- sending email start
		li_mail_send := 'Y';
		begin
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_recipients,null,NULL,mail_subject,mail_message);

		exception
		when others then
			li_mail_send := 'N';
		end;
	-- sending email end

	-- KC entry
			begin
					li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'KP Notification',mail_message);
					KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_recipients,li_mail_send);

			exception
			when others then
				null;
			end;
	-- KC entry

	end if;
	
    return 1;

    EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20101, 'Error Generating Email. ' || SQLERRM );
        return 1;
END;
/