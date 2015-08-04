CREATE OR REPLACE package kc_sub_notifications_pkg as
function fn_sub_end_prior_notification return number;
function fn_sub_end_after_notification return number;
function fn_gen_sub_award_notifications(as_AwardNUmber in AWARD_APPROVED_SUBAWARDS.AWARD_NUMBER%type,
     as_subcontractorName in AWARD_APPROVED_SUBAWARDS.ORGANIZATION_NAME%TYPE,
     ai_amount in AWARD_APPROVED_SUBAWARDS.AMOUNT%type,
     ai_type number ) return number;
end;
/
create or replace package body  kc_sub_notifications_pkg as

FUNCTION fn_gen_sub_award_notifications
(as_AwardNUmber in AWARD_APPROVED_SUBAWARDS.AWARD_NUMBER%type,
     as_subcontractorName in AWARD_APPROVED_SUBAWARDS.ORGANIZATION_NAME%TYPE,
     ai_amount in AWARD_APPROVED_SUBAWARDS.AMOUNT%type,
     ai_type number )
return number is
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
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;

 ls_message_status char(1);
ls_recipients           varchar2(2000);
ls_Allrecipients           varchar2(2000);

li_ntfctn_id NUMBER(12);
ls_recipient            varchar2(8);
ls_email_address        KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_emailid                  varchar2(200);

li_pos                      number;
ls_cc                   varchar2(100) := 'osp-research-subawards@mit.edu';
ls_doc NOTIFICATION.DOCUMENT_NUMBER%TYPE;
ls_account_num  AWARD.ACCOUNT_NUMBER%type;
ls_title        AWARD.TITLE%type;
ls_award_type   AWARD_TYPE.DESCRIPTION%type;
ls_other_email  KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_other_name   VARCHAR2(160);
ls_admin_email  KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_admin_name   VARCHAR2(160);
ls_sponsor_award_num    AWARD.SPONSOR_AWARD_NUMBER%type;
ls_unit_num     AWARD_PERSON_UNITS.UNIT_NUMBER%type;
ls_unit_name    UNIT.UNIT_NAME%type;
ls_PI_name      AWARD_PERSONS.FULL_NAME%type;
li_notification_typ_id NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%type:= null;
li_notification_is_active PLS_INTEGER;

BEGIN
    
BEGIN
		select ua.email_addr,uaa.email_addr,au.unit_number,u.unit_name,ap.full_name,ua.AO_full_name,uaa.other_full_name		
		into
		ls_admin_email ,
		ls_other_email  ,
		ls_unit_num   ,
		ls_unit_name ,
		ls_PI_name,
		ls_admin_name ,
		ls_other_name
		from award_person_units au 
		inner join award_persons ap on au.award_person_id= ap.award_person_id
		left outer join unit u on au.unit_number=u.unit_number
		left outer join (
				select b.unit_number,b.person_id,kee.email_addr,(ken.last_nm||','||ken.first_nm) as AO_full_name
				from unit_administrator b 
				inner join  krim_prncpl_t kp
				on kp.prncpl_id= b.person_id
				inner join krim_entity_nm_t ken
				on kp.entity_id= ken.entity_id
				inner join krim_entity_email_t kee
				on kp.entity_id= kee.entity_id
				where b.unit_administrator_type_code = 1
		)ua on u.unit_number=ua.unit_number
		left outer join (
			  select c.unit_number,c.person_id,keet.email_addr,(kent.LAST_NM||','||kent.first_nm) as other_full_name 
			  from unit_administrator c 
			  inner  join  krim_prncpl_t kpt
			  on kpt.prncpl_id= c.person_id
			  inner join krim_entity_nm_t kent
			  on kpt.entity_id= kent.entity_id
			  inner join krim_entity_email_t keet
			  on kpt.entity_id= keet.entity_id
			  where c.unit_administrator_type_code = 5
		)uaa on u.unit_number=uaa.unit_number
		inner join award a on a.award_id = ap.award_id
		inner join award_type at on a.award_type_code = at.award_type_code
		where ap.award_number = as_AwardNUmber
		and ap.sequence_number=(select max(sequence_number) from award_persons where award_number = as_AwardNUmber)
		and a.award_number = as_AwardNUmber
		and a.sequence_number = (select max(sequence_number)from award where award_number = as_AwardNUmber)
		and ap.CONTACT_ROLE_CODE = 'PI'
		and au.lead_unit_flag = 'Y';

EXCEPTION
WHEN OTHERS THEN
	ls_recipients := 'kc-notifications@mit.edu';
	ls_cc := 'osp-research-subawards@mit.edu';
	select au.unit_number,u.unit_name,ap.full_name 
	into 
	ls_unit_num , 
	ls_unit_name ,
	ls_PI_name
	from award_person_units au 
	inner join award_persons ap
	on au.award_person_id= ap.award_person_id
	left outer join unit u
	on au.unit_number=u.unit_number
	where ap.award_number=as_AwardNUmber
	and ap.sequence_number=(select max(sequence_number)
	from award_persons where award_number=as_AwardNUmber)
	and ap.CONTACT_ROLE_CODE='PI'
	and au.lead_unit_flag='Y';
END;

BEGIN
select  a.account_number,a.title,at.description,a.sponsor_award_number into ls_account_num,ls_title,ls_award_type,ls_sponsor_award_num  from award a 
left outer join award_type at on a.award_type_code=at.award_type_code
where award_number=as_AwardNUmber and sequence_number=(select max(sequence_number)
from award where award_number=as_AwardNUmber);
EXCEPTION
WHEN OTHERS THEN
null;
END;

   -- set recipients
   if (ls_other_email is NULL) or (length(trim(ls_other_email)) = 0 ) then
        if (ls_admin_email is NULL) or (length(trim(ls_admin_email)) = 0 ) then
           ls_recipients := 'kc-notifications@mit.edu';
        else
            ls_recipients :=  ls_admin_email;
        end if;
    else
        ls_recipients := ls_other_email;
   end if;
   
   if (ls_other_email is NULL) or (length(trim(ls_other_email)) = 0 ) then
        if (ls_admin_email is NULL) or (length(trim(ls_admin_email)) = 0 ) then
           ls_cc := 'osp-research-subawards@mit.edu';
        else
            ls_cc :=  ls_admin_email;
        end if;
    else
        ls_cc := ls_other_email;
   end if;

  select notification_type_id into li_notification_typ_id from notification_type where module_code=4 and action_code=501;
  select document_number into ls_doc from award where award_number=as_AwardNUmber 
  and sequence_number=(select max(sequence_number) from award where award_number=as_AwardNUmber); 

    if ai_type = 1 then
	
	     li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,4,'501');
	     if li_notification_is_active = 1 then  
         KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,501,mail_subject,mail_message);
		   mail_message := replace(mail_message,'{SUBCONTRACT_NAME}',as_subcontractorName );	
		   mail_message := replace(mail_message,'{AMOUNT}',trim(to_char(ai_amount, '$9,999,999,999.00')));
           mail_message := replace(mail_message,'{SPONSOR_AWARD_NUMBER}',ls_sponsor_award_num );	
		   mail_message := replace(mail_message,'{AWARD_TYPE}',ls_award_type);			   
		   mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_account_num );	
		   mail_message := replace(mail_message, '{TITLE}',ls_title );
           mail_message := replace(mail_message, '{PERSON_NAME}',ls_PI_name );	
		   mail_message := replace(mail_message, '{UNIT_NUMBER}',ls_unit_num );
		   mail_message := replace(mail_message, '{UNIT_NAME}',ls_unit_name );				   
		   BEGIN
			KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipients,ls_cc,NULL,mail_subject,mail_message); 
	   EXCEPTION
	   WHEN OTHERS THEN
	   ls_message_status:='N';
	   END; 
	 
	  
	  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
	  
	  if li_ntfctn_id <>  -1 then 
		  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_recipients,ls_message_status);
	  end if;
        end if;	  
        else
		 
         select notification_type_id into li_notification_typ_id from notification_type where module_code=4 and action_code=502; 
		 li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,4,'502');
	     if li_notification_is_active = 1 then
		  KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,502,mail_subject,mail_message);
		   mail_message := replace(mail_message,'{SUBCONTRACT_NAME}',as_subcontractorName );	
		   mail_message := replace(mail_message,'{AMOUNT}',trim(to_char(ai_amount, '$9,999,999,999.00')));
           mail_message := replace(mail_message,'{SPONSOR_AWARD_NUMBER}',ls_sponsor_award_num );	
		   mail_message := replace(mail_message,'{AWARD_TYPE}',ls_award_type);			   
		   mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_account_num );	
		   mail_message := replace(mail_message, '{TITLE}',ls_title );
           mail_message := replace(mail_message, '{PERSON_NAME}',ls_PI_name );	
		   mail_message := replace(mail_message, '{UNIT_NUMBER}',ls_unit_num );
		   mail_message := replace(mail_message, '{UNIT_NAME}',ls_unit_name );			   
		   --KC_MAIL_GENERIC_PKG.SEND_MAIL(ls_TraineeEmail,ls_PIEmail,NULL,mail_subject,mail_message);
		   BEGIN
			KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipients,ls_cc,NULL,mail_subject,mail_message); 
	   EXCEPTION
	   WHEN OTHERS THEN
	   ls_message_status:='N';
	   END; 
							   
	
	  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
	  
	  if li_ntfctn_id <>  -1 then 
		  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_recipients,ls_message_status);
	  end if;  
      end if;	  
    end if;
    
    
     return 1;

    EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20101, 'Error Generating Email. ' || SQLERRM );
        return 1;

END fn_gen_sub_award_notifications;	
				
                       



FUNCTION  fn_sub_end_prior_notification
RETURN NUMBER IS

li_Count            number;
li_cnt              number;
ls_account_num  AWARD.ACCOUNT_NUMBER%type;
ls_end_date   SUBAWARD.end_date%type;
ls_REQUISITIONER_email  VARCHAR2(200);
ls_other_email  KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
--ls_other_name   OSP$PERSON.FULL_NAME%type;
ls_admin_email  KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
--ls_admin_name   OSP$PERSON.FULL_NAME%type;
ls_sponsor_award_num    AWARD.SPONSOR_AWARD_NUMBER%type;
ls_po           SUBAWARD.PURCHASE_ORDER_NUM%type;
ls_sub_code     SUBAWARD.SUBAWARD_CODE%type;
ls_subawardee   ORGANIZATION.ORGANIZATION_NAME%type;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
ls_other_person_id VARCHAR2(40 BYTE);
ls_adm_person_id VARCHAR2(40 BYTE);
ls_requisitioner_id VARCHAR2(40 BYTE);
li_ntfctn_id NUMBER(12);
ls_doc NOTIFICATION.DOCUMENT_NUMBER%TYPE;
ls_person_id VARCHAR2(40);
ls_recipient               varchar2(200);
ls_requisitioner_note       varchar2(200) := 'There is no requisitioner email address.';
ls_recipient_note           varchar2(200) := 'There is no Other Individual to Notify/Administrative Officer email address.';
li_requisitioner            number;
li_recipient                number;
ls_cc_email                 varchar2(200) := 'osp-research-subawards@mit.edu';
ls_subject                  varchar2(600) := 'Subaward End Date in 30 Days' ;
ls_message_status CHAR(1);
mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
li_notification_typ_id NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%type:= null;
li_notification_is_active PLS_INTEGER;

cursor cur_end_prior is
   select S.SUBAWARD_CODE,  S.END_DATE , S.PURCHASE_ORDER_NUM,t.EMAIL_ADDR, O.ORGANIZATION_NAME,S.REQUISITIONER_ID 
    from SUBAWARD s,KRIM_PRNCPL_T p,KRIM_ENTITY_EMAIL_T t  ,ORGANIZATION o 
      where S.SEQUENCE_NUMBER in ( SELECT MAX(SEQUENCE_NUMBER)
         FROM SUBAWARD
            WHERE S.SUBAWARD_CODE = SUBAWARD.SUBAWARD_CODE)
         and  S.END_DATE  = trunc( sysdate) + 30
         and p.entity_id=t.entity_id
         and S.REQUISITIONER_ID = P.PRNCPL_ID (+)
         and s.ORGANIZATION_ID = O.ORGANIZATION_ID(+);
         
cursor cur_fund_source is 
select a.account_number,a.sponsor_award_number,DECODE(ua.unit_administrator_type_code,1,kee.email_addr,null) admin_mail,DECODE(ua.unit_administrator_type_code,5,kee.email_addr,null) other_mail,DECODE(ua.unit_administrator_type_code,1,kp.PRNCPL_ID,null) admin_person,DECODE(ua.unit_administrator_type_code,5,kp.PRNCPL_ID,null) other_person from
award_person_units au inner join
award_persons ap
on au.award_person_id= ap.award_person_id
inner join award a on
a.award_id=ap.award_id
inner join subaward_funding_source s on
a.award_id=s.award_id
left outer join unit_administrator ua
on au.unit_number=ua.unit_number
left outer  join  krim_prncpl_t kp
on kp.prncpl_id= ua.person_id
inner join krim_entity_nm_t ken
on kp.entity_id= ken.entity_id
inner join krim_entity_email_t kee
on kp.entity_id= kee.entity_id
where s.subaward_code=ls_sub_code
and s.SEQUENCE_NUMBER = (SELECT MAX(SEQUENCE_NUMBER)
FROM subaward_funding_source
WHERE s.subaward_code = subaward_funding_source.subaward_code)
and au.lead_unit_flag='Y'
and ua.unit_administrator_type_code in(1,5);
              
BEGIN
    
    
    begin
        select COUNT(SUBAWARD_CODE)
        into  li_Count
        from SUBAWARD s
        where S.SEQUENCE_NUMBER in ( SELECT MAX(SEQUENCE_NUMBER)
         FROM SUBAWARD
            WHERE S.SUBAWARD_CODE = SUBAWARD.SUBAWARD_CODE)
         and  S.END_DATE = trunc( sysdate) + 30;
        exception
            when NO_DATA_FOUND then
            li_Count := 0;
    end;
    
    if  li_Count > 0 then   
        open cur_end_prior;
    
         loop
            li_requisitioner :=1;
            fetch cur_end_prior into ls_sub_code, ls_end_date, ls_po,ls_REQUISITIONER_email,ls_subawardee,ls_requisitioner_id;
            exit when cur_end_prior%NOTFOUND;
            if ls_REQUISITIONER_email is null then
                ls_REQUISITIONER_email := 'kc-notifications@mit.edu';
                li_requisitioner := 0;
            end if;
			
			select count(subaward_code) into li_cnt from subaward_funding_source where subaward_code=ls_sub_code 
			and sequence_number=(select max(sequence_number) from subaward_funding_source where subaward_code=ls_sub_code);
			
            if  li_cnt = 1 then
            --dbms_output.put_line('no subcontract found 30 prior end_date.'); -- go to award
                open cur_fund_source;
                loop
                    li_recipient := 1;
                    
                    fetch cur_fund_source into ls_account_num,ls_sponsor_award_num,ls_other_email,ls_admin_email,ls_other_person_id,ls_adm_person_id;
                    exit when cur_fund_source%NOTFOUND;
                                        
                     -- set recipient      
                    if (ls_other_email is NULL) or (length(trim(ls_other_email)) = 0 ) then
                        if (ls_admin_email is NULL) or (length(trim(ls_admin_email)) = 0 ) then
                           ls_recipient := 'kc-notifications@mit.edu';
                           li_recipient :=0 ;
                        else
                            ls_recipient := ls_admin_email;
							ls_person_id:=ls_adm_person_id;
                        end if;
                    else
                        ls_recipient := ls_other_email;
						ls_person_id:=ls_other_person_id;
                    end if;
                    ls_message_status:='Y';
                    select notification_type_id into li_notification_typ_id from notification_type where module_code=4 and action_code=503;
					select document_number into ls_doc from subaward where subaward_code=ls_sub_code 
			        and sequence_number=(select max(sequence_number) from subaward_funding_source where subaward_code=ls_sub_code);
					li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,4,'503');
	                if li_notification_is_active = 1 then
                    if (li_requisitioner = 0 ) and (li_recipient = 0 ) then
					 ls_REQUISITIONER_email:=ls_REQUISITIONER_email||',' || ls_recipient;
					 
					    
                        KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,503,mail_subject,mail_message);
		                mail_message := replace(mail_message,'{ORGANIZATION_NAME}',ls_subawardee );	
		                mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));	
		                mail_message := replace(mail_message, '{PERCHASE_ORDER_NUM}',ls_po );	
		                mail_message := replace(mail_message, '{SPONSOR_AWARD_NUMBER}',ls_sponsor_award_num );
                        mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_account_num );
						BEGIN
		                KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_REQUISITIONER_email,ls_cc_email,NULL,mail_subject||'---'||ls_requisitioner_note ||'---'||ls_recipient_note,mail_message);
						EXCEPTION
						WHEN OTHERS THEN
						 ls_message_status:='N';
						 END;
					
						li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
						if li_ntfctn_id <>  -1 then 
						  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,'00000',ls_message_status);
						end if;
						
                    else
                        if (li_requisitioner = 1 ) and (li_recipient = 1 ) then
						    ls_REQUISITIONER_email:=ls_REQUISITIONER_email||',' || ls_recipient;
							
							li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,4,'502');
	                     
		                mail_message := replace(mail_message,'{ORGANIZATION_NAME}',ls_subawardee );	
		                mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));	
		                mail_message := replace(mail_message, '{PERCHASE_ORDER_NUM}',ls_po );	
		                mail_message := replace(mail_message, '{SPONSOR_AWARD_NUMBER}',ls_sponsor_award_num );
                        mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_account_num );
						BEGIN
		                KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_REQUISITIONER_email,ls_cc_email,NULL,mail_subject,mail_message);
						EXCEPTION
						WHEN OTHERS THEN
						 ls_message_status:='N';
						 END;
						
                         li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
						if li_ntfctn_id <>  -1 then 
						  KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_person_id,ls_message_status);
						end if;  
                       					
                        else
                            if  (li_requisitioner = 0 ) then
							  ls_REQUISITIONER_email:=ls_REQUISITIONER_email||',' || ls_recipient;
                              KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,503,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{ORGANIZATION_NAME}',ls_subawardee );	
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));	
		                      mail_message := replace(mail_message, '{PERCHASE_ORDER_NUM}',ls_po );	
		                      mail_message := replace(mail_message, '{SPONSOR_AWARD_NUMBER}',ls_sponsor_award_num );
                              mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_account_num );						
		                      BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_REQUISITIONER_email,ls_cc_email,NULL,mail_subject||'---' ||ls_requisitioner_note,mail_message);
                               EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END;
							  
							   li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
						       if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_person_id,ls_message_status);
						       end if;   							  
                            else
							    ls_REQUISITIONER_email:=ls_REQUISITIONER_email||',' || ls_recipient;
                                KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,503,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{ORGANIZATION_NAME}',ls_subawardee );	
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));	
		                      mail_message := replace(mail_message, '{PERCHASE_ORDER_NUM}',ls_po );	
		                      mail_message := replace(mail_message, '{SPONSOR_AWARD_NUMBER}',ls_sponsor_award_num );
                              mail_message := replace(mail_message, '{ACCOUNT_NUMBER}',ls_account_num );						
		                       BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_REQUISITIONER_email,ls_cc_email,NULL,mail_subject||'---' ||ls_requisitioner_note,mail_message);
                              EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END;
							 
							  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
							  if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_person_id,ls_message_status);
						       end if;   							  
                            end if;                     
                        end if;
                                              
                    
                    end if; 
                    end if;  
                     
                end loop;
                close cur_fund_source;
            else 
                 
            --no funding source info
                dbms_output.put_line('subcontract end in 30 days with no founding source.');  
                ls_recipient := 'kc-notifications@mit.edu';
				ls_REQUISITIONER_email:=ls_REQUISITIONER_email||',' || ls_recipient;
				select notification_type_id into li_notification_typ_id from notification_type where module_code=4 and action_code=504;
				             li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,4,'504');
	                        if li_notification_is_active = 1 then
                              KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,504,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{ORGANIZATION_NAME}',ls_subawardee );	
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));	
		                      mail_message := replace(mail_message, '{PERCHASE_ORDER_NUM}',ls_po );							
		                      BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_REQUISITIONER_email,ls_cc_email,NULL,mail_subject||'--- No funding source info',mail_message); 
                                EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END;
							
							  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
							  if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,'00000',ls_message_status);
						       end if; 
                            end if;							   
                
            end if;
        
        
         end loop; 
        close cur_end_prior;
        dbms_output.put_line('found 30 prior end_date subcontract' ||li_Count);
    else
        dbms_output.put_line('no subcontract found 30 prior end_date.');
    
    end if;
    
   



return 1;


END fn_sub_end_prior_notification;




FUNCTION  fn_sub_end_after_notification
RETURN NUMBER IS


li_Count            number;
li_c_count            number;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id NUMBER(12);
ls_doc NOTIFICATION.DOCUMENT_NUMBER%TYPE;
ls_account_num  AWARD.ACCOUNT_NUMBER%type;
ls_start_date   SUBAWARD.start_date%type;
ls_end_date   SUBAWARD.end_date%type;
ls_REQUISITIONER_email KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_ao_email KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_rolodex_email  ROLODEX.EMAIL_ADDRESS%type;
--ls_other_name   OSP$PERSON.FULL_NAME%type;
--ls_admin_email  OSP$PERSON.EMAIL_ADDRESS%type;
--ls_admin_name   OSP$PERSON.FULL_NAME%type;
--ls_sponsor_award_num    OSP$AWARD.SPONSOR_AWARD_NUMBER%type;
ls_po           SUBAWARD.PURCHASE_ORDER_NUM%type;
--ls_fs_indicator OSP$SUBCONTRACT.FUNDING_SOURCE_INDICATOR%type;
ls_sub_code     SUBAWARD.SUBAWARD_CODE%type;
--ls_subawardee   OSP$ORGANIZATION.ORGANIZATION_NAME%type;
ls_rolodex  NUMBER(6,0);
ls_rolodex_id NUMBER(6,0);
ls_anticipated_amount  SUBAWARD_AMOUNT_INFO.ANTICIPATED_AMOUNT%type;

ls_recipient               varchar2(200);
ls_requisitioner_note       varchar2(200) := 'There is no requisitioner email address.';
ls_recipient_note           varchar2(200) := 'There is no Contact email address.';
li_requisitioner            number;
li_recipient                number;
ls_cc_email                 varchar2(200) := 'osp-research-subawards-closeout@mit.edu ';
ls_subject                  varchar2(600) := 'Subaward from MIT Ended' ;
ls_message_status CHAR(1);
mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
li_notification_typ_id NOTIFICATION_TYPE.NOTIFICATION_TYPE_ID%type:= null;
li_notification_is_active PLS_INTEGER;

cursor cur_end_after is
   select distinct S.SUBAWARD_CODE, S.START_DATE,  S.END_DATE , S.PURCHASE_ORDER_NUM,e.EMAIL_ADDR, sai.ANTICIPATED_AMOUNT
    from SUBAWARD s,KRIM_PRNCPL_T P,KRIM_ENTITY_EMAIL_T e ,SUBAWARD_AMOUNT_INFO sai
      where S.SEQUENCE_NUMBER in ( SELECT MAX(SEQUENCE_NUMBER)
         FROM SUBAWARD
            WHERE S.SUBAWARD_CODE = SUBAWARD.SUBAWARD_CODE)
         and  S.END_DATE  + 30 = trunc( sysdate)
         and S.STATUS_CODE <> 15
         and S.REQUISITIONER_ID = P.PRNCPL_ID (+)
         and P.entity_id=e.entity_id
         and sai.SUBAWARD_CODE = S.SUBAWARD_CODE and sai.SEQUENCE_NUMBER = (SELECT MAX(SEQUENCE_NUMBER)
            FROM SUBAWARD_AMOUNT_INFO
            WHERE sai.SUBAWARD_CODE = SUBAWARD_AMOUNT_INFO.SUBAWARD_CODE);
         
cursor cur_contact is 
    select r.EMAIL_ADDRESS,r.ROLODEX_ID
    from SUBAWARD_CONTACT sc, ROLODEX r
    where sc.CONTACT_TYPE_CODE = 33 and sc.SUBAWARD_CODE = ls_sub_code and sc.SEQUENCE_NUMBER = (SELECT MAX(SEQUENCE_NUMBER)
         FROM SUBAWARD_CONTACT
        WHERE sc.SUBAWARD_CODE = SUBAWARD_CONTACT.SUBAWARD_CODE)
            and sc.ROLODEX_ID = r.ROLODEX_ID(+);
  
              
BEGIN
    
    
    begin
            select COUNT(SUBAWARD_CODE)
        into  li_Count
        from SUBAWARD s
        where S.SEQUENCE_NUMBER in ( SELECT MAX(SEQUENCE_NUMBER)
         FROM SUBAWARD
            WHERE S.SUBAWARD_CODE = SUBAWARD.SUBAWARD_CODE)
         and  S.END_DATE + 30 = trunc( sysdate) 
         and S.STATUS_CODE <> 15; --Sponsor MOD Required
        exception
            when NO_DATA_FOUND then
            li_Count := 0;
    end;
    
    if  li_Count > 0 then   
        open cur_end_after;
    
         loop
            li_requisitioner :=1;
            fetch cur_end_after into ls_sub_code, ls_start_date, ls_end_date, ls_po, ls_REQUISITIONER_email, ls_anticipated_amount;
            exit when cur_end_after%NOTFOUND;
            if (ls_REQUISITIONER_email is null)  or (length(trim(ls_REQUISITIONER_email)) = 0 ) then
                ls_REQUISITIONER_email := 'kc-mit@mit.edu';
                li_requisitioner := 0;
            end if;
            
            --if  SUBSTR(ls_fs_indicator, 1,1) = 'P' then
            --need check another counter here for contacter 
              begin
                    select COUNT(SUBAWARD_CODE)
                    into  li_c_count
                    from SUBAWARD_CONTACT sc
                    where SC.SUBAWARD_CODE = ls_sub_code and SC.SEQUENCE_NUMBER in ( SELECT MAX(SEQUENCE_NUMBER)
                     FROM SUBAWARD_CONTACT
                        WHERE SC.SUBAWARD_CODE = SUBAWARD_CONTACT.SUBAWARD_CODE)
                     and SC.CONTACT_TYPE_CODE = 33; --Subaward Ending Email Contact
                    exception
                        when NO_DATA_FOUND then
                        li_c_count := 0;
              end;
            
              if li_c_count > 0 then
            
            --dbms_output.put_line('no subcontract found 30 prior end_date.'); -- go to award
                open cur_contact;
                loop
                    li_recipient := 1;
                    
                    fetch cur_contact into ls_rolodex_email,ls_rolodex;
                    exit when cur_contact%NOTFOUND;
                                        
                     -- set recipient      
                   if (ls_rolodex_email is NULL) or (length(trim(ls_rolodex_email)) = 0 ) then
                        ls_recipient := 'kc-mit@mit.edu';
                        li_recipient :=0 ;
                    else
                        ls_recipient := ls_rolodex_email;
						ls_rolodex_id:=ls_rolodex;
                    end if;
					ls_message_status:='Y';
                    select document_number into ls_doc from subaward where subaward_code=ls_sub_code 
			        and sequence_number=(select max(sequence_number) from subaward_funding_source where subaward_code=ls_sub_code);
                    select notification_type_id into li_notification_typ_id from notification_type where module_code=4 and action_code=505;
					li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,4,'505');
	                if li_notification_is_active = 1 then
                    if (li_requisitioner = 0 ) and (li_recipient = 0 ) then
					    ls_cc_email:=ls_cc_email || ',' || ls_REQUISITIONER_email;
                        KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,505,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{PERCHASE_ORDER_NUM}',ls_po );
                              mail_message := replace(mail_message,'{START_DATE}',to_char(ls_start_date, 'mm/dd/yyyy'));							  
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));
                              mail_message := replace(mail_message,'{ANTICIPATED_AMOUNT}',ls_anticipated_amount);							  
		                       BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipient,ls_cc_email,NULL,mail_subject||'---'||ls_requisitioner_note ||'---'||ls_recipient_note,mail_message); 
                              EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END;
							 
							  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
							  if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,'00000',ls_message_status);
						       end if;   	
                    else
                        if (li_requisitioner = 1 ) and (li_recipient = 1 ) then
                            ls_cc_email:=ls_cc_email || ',' || ls_REQUISITIONER_email;
                            KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,505,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{PERCHASE_ORDER_NUM}',ls_po );
                              mail_message := replace(mail_message,'{START_DATE}',to_char(ls_start_date, 'mm/dd/yyyy'));							  
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));
                              mail_message := replace(mail_message,'{ANTICIPATED_AMOUNT}',ls_anticipated_amount);							  
		                      BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipient,ls_cc_email,NULL,mail_subject,mail_message); 
                              EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END;
							  
							  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
							  if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_rolodex_id,ls_message_status);
						       end if;   	
                        else
                            if  (li_requisitioner = 0 ) then
                                ls_cc_email:=ls_cc_email || ',' || ls_REQUISITIONER_email;
								KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,505,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{PERCHASE_ORDER_NUM}',ls_po );
                              mail_message := replace(mail_message,'{START_DATE}',to_char(ls_start_date, 'mm/dd/yyyy'));							  
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));
                              mail_message := replace(mail_message,'{ANTICIPATED_AMOUNT}',ls_anticipated_amount);							  
		                      BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipient,ls_cc_email,NULL,mail_subject||'---' ||ls_requisitioner_note,mail_message); 
                              EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END; 
							   
							  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
							  if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_rolodex_id,ls_message_status);
						       end if;   	
                            else
							    ls_cc_email:=ls_cc_email || ',' || ls_REQUISITIONER_email;
                                KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,505,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{PERCHASE_ORDER_NUM}',ls_po );
                              mail_message := replace(mail_message,'{START_DATE}',to_char(ls_start_date, 'mm/dd/yyyy'));							  
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));
                              mail_message := replace(mail_message,'{ANTICIPATED_AMOUNT}',ls_anticipated_amount);							  
		                      BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipient,ls_cc_email,NULL,mail_subject||'---' ||ls_requisitioner_note,mail_message); 
                               EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END; 
							 
							  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
							  if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_rolodex_id,ls_message_status);
						       end if;   	            
                            end if;                     
                        end if;                        
                    
                    end if; 
                    end if;
                     
                end loop;
                close cur_contact;
              else
               -- no Contact Type as 'Subaward Ending Email Contact'
			   
			   
			            select distinct kee.email_addr into ls_ao_email from
                               award_person_units au inner join
                               award_persons ap
                               on au.award_person_id= ap.award_person_id
                               inner join subaward_funding_source s on
                               ap.award_id=s.award_id
                               left outer join unit_administrator ua
                               on au.unit_number=ua.unit_number
                               left outer join unit_administrator uaa
                               on au.unit_number=uaa.unit_number
                               left outer  join  krim_prncpl_t kp
                               on kp.prncpl_id= ua.person_id
                               inner join krim_entity_nm_t ken
                               on kp.entity_id= ken.entity_id
                               inner join krim_entity_email_t kee
                               on kp.entity_id= kee.entity_id
                               where s.subaward_code=ls_sub_code
                               and s.SEQUENCE_NUMBER = (SELECT MAX(SEQUENCE_NUMBER)
                               FROM subaward_funding_source
                               WHERE s.subaward_code = subaward_funding_source.subaward_code)
                               and au.lead_unit_flag='Y'
                               and ua.unit_administrator_type_code=1;
                dbms_output.put_line('no Contact Type : Subaward Ending Email Contact');
				ls_recipient:='kc-notifications@mit.edu'; 
				ls_cc_email:=ls_cc_email|| ',' || ls_ao_email;
				               li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,4,'506');
	                        if li_notification_is_active = 1 then
                                KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_typ_id,4,506,mail_subject,mail_message);
		                      mail_message := replace(mail_message,'{PERCHASE_ORDER_NUM}',ls_po );
                              mail_message := replace(mail_message,'{START_DATE}',to_char(ls_start_date, 'mm/dd/yyyy'));							  
		                      mail_message := replace(mail_message,'{END_DATE}',to_char(ls_end_date, 'mm/dd/yyyy'));
                              mail_message := replace(mail_message,'{ANTICIPATED_AMOUNT}',ls_anticipated_amount);							  
		                      BEGIN
							  KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_typ_id,ls_recipient,ls_cc_email,NULL,mail_subject,mail_message); 
                               EXCEPTION
						       WHEN OTHERS THEN
						       ls_message_status:='N';
						        END; 
							 
							  li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_typ_id,'Subaward Notification',mail_message);
							  if li_ntfctn_id <>  -1 then 
						          KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_typ_id,li_ntfctn_id,ls_rolodex_id,ls_message_status);
						       end if; 
                            end if;							   
              end if;
              
           -- else 
            
            --no cotact info
            dbms_output.put_line('subcontract end in 30 days with no founding source.');  
            
           -- end if;
        
        
         end loop; 
        close cur_end_after;
        dbms_output.put_line('found 30 prior end_date subcontract' ||li_Count);
    else
        dbms_output.put_line('no subcontract found 30 prior end_date.');
    
    end if; 


return 1;


END fn_sub_end_after_notification;

end;
/
