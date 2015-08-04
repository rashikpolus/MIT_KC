CREATE OR REPLACE package kc_kp_notifications_pkg as
function fn_check_coi_hierarchy
  (as_award in AWARD.AWARD_NUMBER%TYPE )return number;
function fn_gen_kp_coi_notification(as_person_id in award_persons.PERSON_ID%type,
        as_mit_award_number in AWARD.AWARD_NUMBER%type,
        li_Coi_Complete in number,
        li_Training_Complete in number,
        li_NeedsCoi in Number,
        li_isPCK number ) return number;
function fn_get_awd_custom_data(as_award in AWARD_CUSTOM_DATA.AWARD_NUMBER%type,
as_custom custom_attribute.name%type) return number;

end;
/

CREATE OR REPLACE package body  kc_kp_notifications_pkg as

function fn_check_coi_hierarchy
  (as_award in AWARD.AWARD_NUMBER%TYPE )
return number is
/* check if sponsor or prime sponsor are in coi hierarchy
return -1 if not in hierarchy
return 1 if in no key persons hierarchy (kp do not need to do coi)
return 2 if in key persons hierarchy (kp need to do coi)
*/

ls_Sponsor  AWARD.SPONSOR_CODE%type;
ls_primesponsor AWARD.PRIME_SPONSOR_CODE%type;
li_count_nokp number;
li_count_kp   number;

begin

   begin

        select sponsor_code
        into ls_Sponsor
        from award
            where award_number = as_award
             and sequence_number = (select max(a.sequence_number)
                  from award a
                  where award.award_number = a.award_number);
    exception
        when others then
            raise_application_error(-20100, 'Error retrieveing sponsor code for award ' || as_award || ' ' ||
                                            SQLERRM);
            return -1;
    end;


    begin

        select PRIME_SPONSOR_CODE
        into ls_PrimeSponsor
        from award
            where award_number = as_award
             and sequence_number = (select max(a.sequence_number)
                  from award a
                  where award.award_number = a.award_number);
    exception
        when others then
            raise_application_error(-20100, 'Error retrieveing prime sponsor code for award ' || as_award || ' ' ||
                                            SQLERRM);
            return -1;
    end;

    SELECT COUNT(*)
     INTO   li_count_nokp
     FROM   SPONSOR_HIERARCHY
     where  hierarchy_name = 'COI Disclosures'
     and    sponsor_code IN ( ls_sponsor, ls_PrimeSponsor)
     and    upper(trim(level1) ) =  'COI DISCLOSURES NO KP';


     SELECT COUNT(*)
     INTO   li_count_kp
     FROM   SPONSOR_HIERARCHY
     where  hierarchy_name = 'COI Disclosures'
     and    sponsor_code IN ( ls_sponsor, ls_PrimeSponsor)
     and    upper(trim(level1) ) =   'COI DISCLOSURES WITH KP REQ' ;

     if (li_count_kp > 0) then
       return 2;
     elsif (li_count_nokp > 0) then
       return 1;
     else
       return -1;
     end if;

     end fn_check_coi_hierarchy;
	 
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
END fn_gen_kp_coi_notification;

function fn_get_awd_custom_data(as_award in AWARD_CUSTOM_DATA.AWARD_NUMBER%type,
as_custom custom_attribute.name%type) return number
is
ls_column_value VARCHAR2(2000);
li_return NUMBER:=1;
/*
possible return value
1 :- blank value / No data
2 :- PC
3 :- PCK
*/
begin

		select t3.value into ls_column_value
		   from  award_custom_data t3
		   where t3.award_number = 	as_award
		   and	 t3.sequence_number = (select max(s1.sequence_number) from award_custom_data s1 where s1.award_number = s1.award_number)
		   and   t3.custom_attribute_id = (select id from custom_attribute where name = as_custom);

if    trim(ls_column_value) = 'PC' then
      li_return := 2;
elsif trim(ls_column_value) = 'PCK' then
      li_return := 3;
else
      li_return := 1;
end if;

return li_return;

exception
when others then
return 1;
end fn_get_awd_custom_data;

end;
/