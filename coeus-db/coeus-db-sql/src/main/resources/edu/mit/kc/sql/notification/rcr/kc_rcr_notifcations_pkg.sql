create or replace package KC_RCR_NOTIFCATIONS_PKG as

function fn_send_notification(AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) 
        return NUMBER;
        
function fn_rcr_tr_compl_notif(as_personid  in KRIM_PRNCPL_T.PRNCPL_ID%type,
                               ai_TrainingType in PERSON_TRAINING.TRAINING_CODE%type) 
        return NUMBER;        

end;
/
create or replace package body KC_RCR_NOTIFCATIONS_PKG as

function fn_get_next_rcr_notif_num return number;

                        
function fn_send_notification1(AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) return number;

function fn_send_notification2(AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) return number;

function fn_send_notification3(AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) return number;

function fn_send_notification4(AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) return number;

function fn_send_notification5(AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) return number;


function fn_send_notification( AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) 
return NUMBER IS

li_Ret number;

begin

    if AV_NOTIFICATION_TYPE = 1 then
        li_Ret := fn_send_notification1(1);
        commit;
        
    elsif AV_NOTIFICATION_TYPE = 2 then
        li_Ret := fn_send_notification2(2);
        commit;
        
    elsif AV_NOTIFICATION_TYPE = 3 then
        li_Ret := fn_send_notification3(3);
        commit;
        
    elsif AV_NOTIFICATION_TYPE = 4 then
        li_Ret := fn_send_notification4(4);
        commit;
        
    elsif AV_NOTIFICATION_TYPE = 5 then
        li_Ret := fn_send_notification5(5);
        commit;
        
    else
        li_Ret := -1;
        
    end if;

    Return li_ret;
/******************************/
end fn_send_notification;
/******************************/

function fn_send_notification1 (AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE) return number is

li_NumofDays        RCR_NOTIF_TYPE.NO_OF_DAYS_PRIOR%type;
ls_PersonID         RCR_APPOINTMENTS.PERSON_ID%type;
ls_AccountNUmber    RCR_APPOINTMENTS.ACCOUNT_NUMBER%type;
ldt_AppntDate       RCR_APPOINTMENTS.APPOINTMENT_DATE%type;
ls_AppntType        RCR_APPOINTMENTS.APPOINTMENT_TYPE%type;

ldt_PayrollStartDate RCR_PAYROLL_DATES.BASE_DATE%type;
ldt_DeadlineDate    RCR_PAYROLL_DATES.TRAINING_DEADLINE%type;


ls_Role             RCR_NOTIF_DETAILS.RECIPIENT_ROLE%type;
ll_NofificationId   RCR_NOTIFICATIONS.NOTIFICATION_ID%type;  
li_Count            number;

ls_TraineeName      VARCHAR2(100);
ls_TraineeFName     VARCHAR2(100);
ls_TraineeLName     VARCHAR2(100);
ls_TraineeEmail     KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_PIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_PIName           VARCHAR2(100);
ls_PIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_LeadUnit         unit.unit_number%type;

ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;

mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );

ls_document_number award.document_number% type;
li_notification_type_id notification_type.notification_type_id% type := null;
ls_mail_sent_status RCR_NOTIF_DETAILS.MAIL_SENT_STATUS%type;
li_notification_is_active PLS_INTEGER;
cursor cur_award is
    select distinct AWARD_NUMBER
    from AWARD
    where account_number = ls_AccountNUmber;

cursor cur_accts_to_notify is
    select A.PERSON_ID, A.ACCOUNT_NUMBER, a.APPOINTMENT_DATE, a.APPOINTMENT_TYPE
    from RCR_APPOINTMENTS a
    where A.PERSON_ID not in (select distinct PERSON_ID
        from person_training 
        where TRAINING_CODE in (select training_code from training where upper(description) like '%RCR%') 
            and DATE_SUBMITTED is not null);
    
cursor cur_notification_details is
    select distinct RECIPIENT_ID, RECIPIENT_ROLE,MAIL_SENT_STATUS, ACCOUNT_NUMBER, (krim_prncpl_v.last_nm||', '||krim_prncpl_v.first_nm) as FULL_NAME
    from  RCR_NOTIF_DETAILS, krim_prncpl_v
    where NOTIFICATION_ID = ll_NofificationId
    and RECIPIENT_ID = krim_prncpl_v.PRNCPL_ID;


--Figure out the deadline date
--If appointment type is M - take the end of month and then add 30 days
-- of W - get next friday and then add 30 days.
    
begin
    
    begin	
		select NO_OF_DAYS_PRIOR , NOTIFICATION_TYPE_ID  into  li_NumofDays , li_notification_type_id
		from RCR_NOTIF_TYPE 
		where RCR_NOTIF_TYPE_CODE = AV_NOTIFICATION_TYPE;
		
    exception
        when others then
            return -1;
    end;
    
    ll_NofificationId := null;
    
    open cur_accts_to_notify;
    loop
        fetch cur_accts_to_notify into ls_PersonID, ls_AccountNUmber, ldt_AppntDate, ls_AppntType;
        exit when cur_accts_to_notify%NOTFOUND;

        --check if Email 1 has been sent for this person for this account
        select count(ND.PERSON_ID)
        into li_count
        from RCR_NOTIFICATIONS n, RCR_NOTIF_DETAILS nd
        where N.NOTIFICATION_TYPE_CODE = AV_NOTIFICATION_TYPE
        and N.NOTIFICATION_ID = ND.NOTIFICATION_ID
        and ND.PERSON_ID = ls_PersonID
        and ND.ACCOUNT_NUMBER = ls_AccountNUmber;
        
        if li_Count = 0 then
        --Email 1 has not been sent.  Need to sent email 1.
         
          if ll_NofificationId is null then
            ll_NofificationId := fn_get_next_rcr_notif_num;
            
                INSERT INTO RCR_NOTIFICATIONS (
                   NOTIFICATION_ID, NOTIFICATION_TYPE_CODE, NOTIFICATION_DATE, 
                   NO_OF_DAYS_PRIOR, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, AV_NOTIFICATION_TYPE, sysdate,
                    li_NumofDays, sysdate, user,1,sys_guid());
          end if;
          
          --Figure out the deadline date
          if ls_AppntType = 'M' then
                ldt_DeadlineDate := last_day(ldt_AppntDate) + 30;
                
          elsif ls_AppntType = 'W' then
                ldt_DeadlineDate := next_day(ldt_AppntDate - 1, 'FRIDAY') + 30;
                
          else
                ldt_DeadlineDate := ldt_AppntDate + 30;
          end if;
          
    begin
			select distinct t3.first_nm as first_name, t3.last_nm as last_name, (t3.last_nm||', '|| t3.first_nm) as FULL_NAME, t1.email_addr  as EMAIL_ADDRESS
			 into ls_TraineeFName, ls_TraineeLName, ls_TraineeName, ls_TraineeEmail
			from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
			inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
			where t2.prncpl_id = ls_PersonID
			and  t1.dflt_ind = 'Y';      
      
     exception
      when others then 
      dbms_output.put_line(ls_PersonID);
      end;
          
          if ls_TraineeLName is not null and ls_TraineeFName is not null then
            ls_TraineeName := ls_TraineeFName || ' ' || ls_TraineeLName;
          end if;

          if ls_TraineeEmail is null then
            ls_TraineeEmail := 'coeus-mit@mit.edu';
          end if;
          
          --Using a Cursor just in case we have multiple awards with the same account number
            open cur_award;
            fetch cur_award into ls_MITAwardNumber;
    begin
             
			Select distinct I.PERSON_ID ,  (t3.last_nm||', '|| t3.first_nm) as FULL_NAME , t1.email_addr as EMAIL_ADDRESS   
			into ls_PIID, ls_PIName, ls_PIEmail
			from  AWARD_PERSONS i  inner join krim_prncpl_t t2 on t2.prncpl_id = i.person_id
			inner join krim_entity_email_t t1  on t1.entity_id = t2.entity_id
			inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
			where I.contact_role_code = 'PI'
			and I.AWARD_NUMBER = ls_MITAwardNumber            
			and i.SEQUENCE_NUMBER = (select max(i1.sequence_number)  from AWARD_PERSONS i1  where I.AWARD_NUMBER = I1.AWARD_NUMBER )       
			and  t1.dflt_ind = 'Y';
      
    exception
    when others then
    dbms_output.put_line(ls_MITAwardNumber);
    end;
            
            close cur_award;
            
            if ls_PIEmail is null then
            ls_PIEmail := 'coeus-mit@mit.edu';
          end if;
          
            INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE, MAIL_SENT_STATUS,
               RECIPIENT_EMAIL, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
            VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_PersonID, 'TRAINEE','Y',
                ls_TraineeEmail, sysdate, user,1 , sys_guid());
                
            INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE,MAIL_SENT_STATUS, 
               RECIPIENT_EMAIL, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
            VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_PIID, 'PI-CC','Y',
                ls_PIEmail, sysdate, user,1 , sys_guid() );
           
		li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,100,'501');
		if li_notification_is_active = 1 then
		    begin
			   
			   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,501,mail_subject,mail_message);
			   mail_subject := replace(mail_subject,'{TRAINING_DEADLINE}',to_char(ldt_DeadlineDate, 'mm-dd-yyyy') );	
			   mail_subject := replace(mail_subject,'{TRAINEE_NAME}',ls_TraineeName);	
			   mail_message := replace(mail_message, '{TRAINEE_NAME}',ls_TraineeName );	
			   mail_message := replace(mail_message, '{TRAINING_DEADLINE}',to_char(ldt_DeadlineDate, 'mm-dd-yyyy') );				
			   KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_TraineeEmail,ls_PIEmail,NULL,mail_subject,mail_message);	
				
			exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_PersonID OR RECIPIENT_ID = ls_PIID);				
			 
			end;   
        end if;
		
        end if;
    end loop;
   
   if li_notification_is_active = 1 then
		if ll_NofificationId is not null then
		
		   li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'RCR Notification',mail_message);
		   
			if li_ntfctn_id <>  -1 then
			
				open cur_notification_details;
				loop
					fetch cur_notification_details into ls_PersonID, ls_Role, ls_mail_sent_status ,ls_AccountNUmber, ls_PiName; 
					exit when cur_notification_details%NOTFOUND;
					
						KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_PersonID,ls_mail_sent_status);
								   
				end loop;
				close cur_notification_details;
		 end if;
				
		end if;
	end if;
	
              
    return 0;
    
end fn_send_notification1;

--********************************************************************

function fn_send_notification2( AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE)  return number is

li_NumofDays        RCR_NOTIF_TYPE.NO_OF_DAYS_PRIOR%type;
ls_PersonID         RCR_APPOINTMENTS.PERSON_ID%type;
ls_AccountNUmber    RCR_APPOINTMENTS.ACCOUNT_NUMBER%type;
ldt_AppntDate       RCR_APPOINTMENTS.APPOINTMENT_DATE%type;
ls_AppntType        RCR_APPOINTMENTS.APPOINTMENT_TYPE%type;

ldt_PayrollStartDate RCR_PAYROLL_DATES.BASE_DATE%type;
ldt_DeadlineDate    RCR_PAYROLL_DATES.TRAINING_DEADLINE%type;


ls_Role             RCR_NOTIF_DETAILS.RECIPIENT_ROLE%type;
ll_NofificationId   RCR_NOTIFICATIONS.NOTIFICATION_ID%type;  
li_Count            number;


ls_TraineeName      VARCHAR2(100);
ls_TraineeFName     VARCHAR2(100);
ls_TraineeLName     VARCHAR2(100);
ls_TraineeEmail     KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_PIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_PIName           VARCHAR2(100);
ls_PIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_LeadUnit         unit.unit_number%type;

ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;

mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;


mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
ls_mail_sent_status RCR_NOTIF_DETAILS.MAIL_SENT_STATUS%type;
ls_document_number award.document_number% type;
li_notification_type_id notification_type.notification_type_id% type := null;

cursor cur_award is
    select distinct AWARD_NUMBER
    from AWARD
    where account_number = ls_AccountNUmber;

cursor cur_accts_to_notify is
    select A.PERSON_ID, A.ACCOUNT_NUMBER, P.BASE_DATE
    from RCR_APPOINTMENTS a, RCR_PAYROLL_DATES p
    where A.PERSON_ID = P.PERSON_ID
    and A.ACCOUNT_NUMBER = P.ACCOUNT_NUMBER
    and P.PAYROLL_NUMBER = (select max(P1.PAYROLL_NUMBER)
        from  RCR_PAYROLL_DATES p1
        where P.PERSON_ID = P1.PERSON_ID
        and P.ACCOUNT_NUMBER = P1.ACCOUNT_NUMBER)
    and P.BASE_DATE + li_NumofDays <= trunc(sysdate) 
    and A.PERSON_ID not in (select distinct PERSON_ID
        from person_training 
        where TRAINING_CODE in (select training_code from training where upper(description) like '%RCR%') 
            and DATE_SUBMITTED is not null);


cursor cur_notification_details is
    select distinct RECIPIENT_ID, RECIPIENT_ROLE,MAIL_SENT_STATUS, ACCOUNT_NUMBER, (krim_prncpl_v.last_nm||', '||krim_prncpl_v.first_nm) as FULL_NAME
    from  RCR_NOTIF_DETAILS, krim_prncpl_v
    where NOTIFICATION_ID = ll_NofificationId
    and RECIPIENT_ID = krim_prncpl_v.PRNCPL_ID;

--Figure out the deadline date
--If appointment type is M - take the end of month and then add 30 days
-- of W - get next friday and then add 30 days.
    
begin
    
    begin
	
		select NO_OF_DAYS_PRIOR , NOTIFICATION_TYPE_ID  into  li_NumofDays , li_notification_type_id
		from RCR_NOTIF_TYPE 
		where RCR_NOTIF_TYPE_CODE = AV_NOTIFICATION_TYPE;
		
    exception
        when others then
            return -1;
    end;
    
    ll_NofificationId := null;
    
    open cur_accts_to_notify;
    loop
        fetch cur_accts_to_notify into ls_PersonID, ls_AccountNUmber, ldt_PayrollStartDate;
        exit when cur_accts_to_notify%NOTFOUND;
        
        ldt_DeadlineDate := trunc(ldt_PayrollStartDate) + 30;

        --check if Email 1 has been sent for this person for this account
        select count(ND.PERSON_ID)
        into li_count
        from RCR_NOTIFICATIONS n, RCR_NOTIF_DETAILS nd
        where N.NOTIFICATION_TYPE_CODE = AV_NOTIFICATION_TYPE
        and N.NOTIFICATION_ID = ND.NOTIFICATION_ID
        and ND.PERSON_ID = ls_PersonID
        and ND.ACCOUNT_NUMBER = ls_AccountNUmber
        and ND.TRAINING_DEADLINE = ldt_DeadlineDate;
        
        if li_Count = 0 then
        --Email 1 has not been sent.  Need to sent email 1.
         
          if ll_NofificationId is null then
            ll_NofificationId := fn_get_next_rcr_notif_num;
            
                INSERT INTO RCR_NOTIFICATIONS (
                   NOTIFICATION_ID, NOTIFICATION_TYPE_CODE, NOTIFICATION_DATE, 
                   NO_OF_DAYS_PRIOR, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, AV_NOTIFICATION_TYPE, sysdate,
                    li_NumofDays, sysdate, user,1 , sys_guid());
          end if;
          
          
      begin
        select distinct t3.first_nm as first_name, t3.last_nm as last_name, (t3.last_nm||', '|| t3.first_nm) as FULL_NAME, t1.email_addr  as EMAIL_ADDRESS
        into ls_TraineeFName, ls_TraineeLName, ls_TraineeName, ls_TraineeEmail
        from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
        inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
        where t2.prncpl_id = ls_PersonID
        and  t1.dflt_ind = 'Y';  
        
      exception when others then  
		  null;
      end;
		  
          if ls_TraineeLName is not null and ls_TraineeFName is not null then
            ls_TraineeName := ls_TraineeFName || ' ' || ls_TraineeLName;
          end if;
          

          if ls_TraineeEmail is null then
            ls_TraineeEmail := 'coeus-mit@mit.edu';
          end if;
          
          --Using a Cursor just in case we have multiple awards with the same account number
            open cur_award;
            fetch cur_award into ls_MITAwardNumber;                        
           
      begin 
        Select distinct I.PERSON_ID ,  (t3.last_nm||', '|| t3.first_nm) as FULL_NAME , t1.email_addr as EMAIL_ADDRESS   
        into ls_PIID, ls_PIName, ls_PIEmail
        from  AWARD_PERSONS i  inner join krim_prncpl_t t2 on t2.prncpl_id = i.person_id
        inner join krim_entity_email_t t1  on t1.entity_id = t2.entity_id
        inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
        where I.contact_role_code = 'PI'
        and I.AWARD_NUMBER = ls_MITAwardNumber            
        and i.SEQUENCE_NUMBER = (select max(i1.sequence_number)  from AWARD_PERSONS i1  where I.AWARD_NUMBER = I1.AWARD_NUMBER )       
        and  t1.dflt_ind = 'Y';	
        
		  exception when others then  
		  null;
      end;
			
            close cur_award;
            
            if ls_PIEmail is null then
            ls_PIEmail := 'coeus-mit@mit.edu';
          end if;
          
            INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE,MAIL_SENT_STATUS,  
               RECIPIENT_EMAIL, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID ) 
            VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_PersonID, 'TRAINEE','Y',
                ls_TraineeEmail, sysdate, user,1 , sys_guid() );
         
		begin 
		   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,502,mail_subject,mail_message);	
		   mail_subject := replace(mail_subject, '{TRAINEE_NAME}',ls_TraineeName );	
		   mail_subject := replace(mail_subject, '{TRAINING_DEADLINE}',to_char(ldt_DeadlineDate, 'mm-dd-yyyy') );	
		   mail_message := replace(mail_message, '{TRAINEE_NAME}',ls_TraineeName );	
		   mail_message := replace(mail_message, '{TRAINING_DEADLINE}',to_char(ldt_DeadlineDate, 'mm-dd-yyyy') );				
		   KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_TraineeEmail,null,NULL,mail_subject,mail_message);		
		   
		exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_PersonID );				
			 
		end;    
		  
 	  
        end if;
		
    end loop;
    
    if ll_NofificationId is not null then    
	
		li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'RCR Notification',mail_message);
	   
        if li_ntfctn_id <>  -1 then
		
			open cur_notification_details;
			loop
				fetch cur_notification_details into ls_PersonID, ls_Role, ls_mail_sent_status , ls_AccountNUmber, ls_PiName; 
				exit when cur_notification_details%NOTFOUND;
				
					KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_PersonID,ls_mail_sent_status);
							   
			end loop;
			close cur_notification_details;
        end if;
            
	end if;            
    
    return 0;
    
end fn_send_notification2;

--********************************************************************

function fn_send_notification3 (AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE)  return number is

li_NumofDays        RCR_NOTIF_TYPE.NO_OF_DAYS_PRIOR%type;
ls_PersonID         RCR_APPOINTMENTS.PERSON_ID%type;
ls_AccountNUmber    RCR_APPOINTMENTS.ACCOUNT_NUMBER%type;
ldt_PayrollStartDate RCR_PAYROLL_DATES.BASE_DATE%type;
ldt_DeadlineDate    RCR_PAYROLL_DATES.TRAINING_DEADLINE%type;

ll_NofificationId   RCR_NOTIFICATIONS.NOTIFICATION_ID%type;  
li_Count            number;

ls_TraineeName      VARCHAR2(100);
ls_TraineeEmail     KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_TraineeFName     VARCHAR2(100);
ls_PIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_PIName           VARCHAR2(100);
ls_PIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_AOID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_AoName           VARCHAR2(100);
ls_AOEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_DHID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_DHName           VARCHAR2(100);
ls_DHEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;


ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;
ls_Title            AWARD.TITLE%type;
ls_LeadUnit         unit.unit_number%type;

ls_Role             RCR_NOTIF_DETAILS.RECIPIENT_ROLE%TYPE;

mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;

mail_message_PI   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_message_AO   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_message_DH   NOTIFICATION_TYPE.MESSAGE%TYPE ;

li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;

mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );

ls_document_number award.document_number% type;
li_notification_type_id notification_type.notification_type_id% type := null;
ls_mail_sent_status RCR_NOTIF_DETAILS.MAIL_SENT_STATUS%type;
li_entered_inside NUMBER;
li_notification_is_active PLS_INTEGER;
cursor cur_award is
    select distinct AWARD_NUMBER
    from AWARD
    where account_number = ls_AccountNUmber;

cursor cur_accts_to_notify is
     select A.PERSON_ID, A.ACCOUNT_NUMBER, P.BASE_DATE
    from RCR_APPOINTMENTS a, RCR_PAYROLL_DATES p
    where A.PERSON_ID = P.PERSON_ID
    and A.ACCOUNT_NUMBER = P.ACCOUNT_NUMBER
    and P.PAYROLL_NUMBER = (select max(P1.PAYROLL_NUMBER)
        from  RCR_PAYROLL_DATES p1
        where P.PERSON_ID = P1.PERSON_ID
        and P.ACCOUNT_NUMBER = P1.ACCOUNT_NUMBER)
    and P.BASE_DATE + li_NumofDays <= trunc(sysdate) 
    and A.PERSON_ID not in (select distinct PERSON_ID
        from person_training 
        where TRAINING_CODE in (select training_code from training where upper(description) like '%RCR%') 
            and DATE_SUBMITTED is not null);
    
cursor cur_pis is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'PI';
    
cursor cur_aos is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'AO';
    
cursor cur_dhs is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'DH';        
    
cursor cur_students_for_pi is
    select distinct nd.PERSON_ID, nd.ACCOUNT_NUMBER, (P.last_nm||', '|| p.first_nm) AS FULL_NAME, A.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,  AWARD a
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_PIID
    and nd.RECIPIENT_ROLE = 'PI'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = ( select max (a2.sequence_number)
                                from AWARD a2
                                where A.AWARD_NUMBER = A2.AWARD_NUMBER 
                            )
  
    order by full_name;
	
	
cursor cur_students_for_ao is
     select distinct pis.pi_name, nd.PERSON_ID, nd.ACCOUNT_NUMBER, (P.last_nm||', '|| p.first_nm) AS FULL_NAME, a.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,  AWARD a,         
        (select distinct ND1.PERSON_ID, ND1.ACCOUNT_NUMBER,  (P1.last_nm||', '|| p1.first_nm) pi_name
            FROM RCR_NOTIF_DETAILS nd1, krim_prncpl_v p1
            where ND1.NOTIFICATION_ID = ll_NofificationId
            and ND1.RECIPIENT_ROLE = 'PI'
            and ND1.RECIPIENT_ID = P1.prncpl_id) pis            
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_AOID
    and nd.RECIPIENT_ROLE = 'AO'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = (select max (a2.sequence_number)
        from AWARD a2
        where A.AWARD_NUMBER = A2.AWARD_NUMBER )
    and ND.PERSON_ID = pis.person_id
    and ND.ACCOUNT_NUMBER = pis.account_number
    order by pis.pi_name,FULL_NAME;
	
cursor cur_students_for_dh is
       select distinct pis.pi_name, nd.PERSON_ID, nd.ACCOUNT_NUMBER,(P.last_nm||', '|| p.first_nm) AS FULL_NAME, A.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,   AWARD a,
        (select distinct ND1.PERSON_ID, ND1.ACCOUNT_NUMBER,  (P1.last_nm||', '|| p1.first_nm) pi_name
            FROM RCR_NOTIF_DETAILS nd1, krim_prncpl_v p1
            where ND1.NOTIFICATION_ID = ll_NofificationId
            and ND1.RECIPIENT_ROLE = 'PI'
            and ND1.RECIPIENT_ID = P1.prncpl_id) pis
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_DHID
    and nd.RECIPIENT_ROLE = 'DH'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = (select max (a2.sequence_number)
        from AWARD a2
        where A.AWARD_NUMBER = A2.AWARD_NUMBER )
    and ND.PERSON_ID = pis.person_id
    and ND.ACCOUNT_NUMBER = pis.account_number
    order by pis.pi_name, FULL_NAME;
        
cursor cur_notification_details is
    select distinct RECIPIENT_ID, RECIPIENT_ROLE, MAIL_SENT_STATUS,ACCOUNT_NUMBER, (krim_prncpl_v.last_nm||', '|| krim_prncpl_v.first_nm) full_name, UNIT_NUMBER
    from  RCR_NOTIF_DETAILS, krim_prncpl_v
    where NOTIFICATION_ID = ll_NofificationId
    and RECIPIENT_ID = krim_prncpl_v.prncpl_id
    and RECIPIENT_ROLE in ('PI', 'AO', 'DH')
    order by UNIT_NUMBER, RECIPIENT_ROLE, full_name;
            
    
begin
    
    begin	
		
		select NO_OF_DAYS_PRIOR , NOTIFICATION_TYPE_ID  into  li_NumofDays , li_notification_type_id
		from RCR_NOTIF_TYPE 
		where RCR_NOTIF_TYPE_CODE = AV_NOTIFICATION_TYPE;
		
    exception
        when others then
            return -1;
    end;
    
    ll_NofificationId := null;
    
    open cur_accts_to_notify;
    loop
        fetch cur_accts_to_notify into ls_PersonID, ls_AccountNUmber, ldt_PayrollStartDate;
        exit when cur_accts_to_notify%NOTFOUND;
        
        ldt_DeadlineDate := trunc(ldt_PayrollStartDate) + 60;
        
        --check if Email 1 has been sent for this person for this account
        select count(ND.PERSON_ID)
        into li_count
        from RCR_NOTIFICATIONS n, RCR_NOTIF_DETAILS nd
        where N.NOTIFICATION_TYPE_CODE = AV_NOTIFICATION_TYPE
        and N.NOTIFICATION_ID = ND.NOTIFICATION_ID
        and ND.PERSON_ID = ls_PersonID
        and ND.ACCOUNT_NUMBER = ls_AccountNUmber
        and nd.TRAINING_DEADLINE = ldt_DeadlineDate;
        
        if li_Count = 0 then
        --Email 2 has not been sent.  Need to sent email 1.
         
          if ll_NofificationId is null then
            ll_NofificationId := fn_get_next_rcr_notif_num;
            
                INSERT INTO RCR_NOTIFICATIONS (
                   NOTIFICATION_ID, NOTIFICATION_TYPE_CODE, NOTIFICATION_DATE, 
                   NO_OF_DAYS_PRIOR, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, AV_NOTIFICATION_TYPE, sysdate,
                    li_NumofDays, sysdate, user,1 , sys_guid() );
          end if;
          
      begin
    
      select distinct (t3.last_nm||', '||t3.first_nm) as FULL_NAME, t1.email_addr  as EMAIL_ADDRESS
			into ls_TraineeName, ls_TraineeEmail
			from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
			inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
			where t2.prncpl_id = ls_PersonID
			and  t1.dflt_ind = 'Y';	
        
		  exception when others then  
		  null;
      end;
		  
		  
          --Using a Cursor just in case we have multiple awards with the same account number
            open cur_award;
            fetch cur_award into ls_MITAwardNumber;                        
      
      begin
      
			Select  distinct I.PERSON_ID ,  (t3.last_nm||', '|| t3.first_nm) as FULL_NAME , t1.email_addr as EMAIL_ADDRESS   
			into ls_PIID, ls_PIName, ls_PIEmail
			from  AWARD_PERSONS i  inner join krim_prncpl_t t2 on t2.prncpl_id = i.person_id
			inner join krim_entity_email_t t1  on t1.entity_id = t2.entity_id
			inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
			where I.contact_role_code = 'PI'
			and I.AWARD_NUMBER = ls_MITAwardNumber            
			and i.SEQUENCE_NUMBER = (select max(i1.sequence_number)  from AWARD_PERSONS i1  where I.AWARD_NUMBER = I1.AWARD_NUMBER )       
			and  t1.dflt_ind = 'Y' ;
    
        
		  exception when others then  
		  null;
      end;
			
			
            close cur_award;
            
            ls_LeadUnit := null;
            
            begin
				
				  select distinct
				  P.prncpl_id AS PERSON_ID, (p.last_nm||', '|| p.first_nm) AS FULL_NAME, e.email_addr AS EMAIL_ADDRESS, AU.UNIT_NUMBER
				  into ls_AOID, ls_AoName, ls_AOEmail, ls_LeadUnit
				  from AWARD_PERSON_UNITS au , AWARD_PERSONS ap,UNIT_ADMINISTRATOR u, 
				   krim_prncpl_v p,krim_entity_email_t e,krim_prncpl_t f
				  where au.award_person_id = ap.award_person_id
				  and  ap.AWARD_NUMBER = ls_MITAwardNumber
				  and ap.SEQUENCE_NUMBER = ( select max(au1.sequence_number)
									   from AWARD_PERSONS au1
									   where ap.AWARD_NUMBER = au1.AWARD_NUMBER)
				  and  au.lead_unit_flag = 'Y'
				  and au.unit_number = u.unit_number
				  and u.PERSON_ID = P.prncpl_id
				  and u.UNIT_ADMINISTRATOR_TYPE_CODE = 1 --ADMINISTRATIVE_OFFICER      
				  and p.prncpl_id = f.prncpl_id
				  and f.entity_id = e.entity_id
				  and e.dflt_ind = 'Y';
			
			
            exception
                when others then
                    ls_AOID := null;
            end;
            
            begin
                                 
				 select distinct
				  P.prncpl_id AS PERSON_ID, (p.last_nm||', '|| p.first_nm) AS FULL_NAME, e.email_addr AS EMAIL_ADDRESS
				  into ls_DHID, ls_DHName, ls_DHEmail
				  from AWARD_PERSON_UNITS au , AWARD_PERSONS ap,UNIT_ADMINISTRATOR u, 
				   krim_prncpl_v p,krim_entity_email_t e,krim_prncpl_t f
				  where au.award_person_id = ap.award_person_id
				  and  ap.AWARD_NUMBER = ls_MITAwardNumber
				  and ap.SEQUENCE_NUMBER = ( select max(au1.sequence_number)
									   from AWARD_PERSONS au1
									   where ap.AWARD_NUMBER = au1.AWARD_NUMBER)
				  and  au.lead_unit_flag = 'Y'
				  and au.unit_number = u.unit_number
				  and u.PERSON_ID = P.prncpl_id
				  and u.UNIT_ADMINISTRATOR_TYPE_CODE = 3	--UNIT_HEAD  
				  and p.prncpl_id = f.prncpl_id
				  and f.entity_id = e.entity_id
				  and e.dflt_ind = 'Y';
				
				
            exception
                when others then
                    ls_DHID := null;
            end;

            INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE, MAIL_SENT_STATUS,
               RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
            VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_PIID, 'PI','Y',
                ls_PIEmail, ls_LeadUnit, sysdate, user,1 , sys_guid());
                
            if ls_AOID is not null then
                INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE,MAIL_SENT_STATUS, 
               RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_AOID, 'AO','Y',
                ls_AOEmail, ls_LeadUnit, sysdate, user,1 , sys_guid());
            end if;
            
             if ls_DHID is not null then
                INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE,MAIL_SENT_STATUS, 
               RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_DHID, 'DH','Y',
                ls_DHEmail, ls_LeadUnit, sysdate, user,1 , sys_guid());
            end if;
            
        end if;
    end loop;
    close cur_accts_to_notify;

    
    
    IF ll_NofificationId is not null then
    -- This run of the notification generated emails.  
    --Sent a grouped email to the PIs
	
	 li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,100,503);
	 if li_notification_is_active = 1 then
        open cur_pis;        
        loop
            fetch cur_pis into ls_PIID, ls_PIEmail;
            exit when cur_pis%NOTFOUND;
            
          li_entered_inside := 0;    
          
				open cur_students_for_pi;
				loop
					fetch cur_students_for_pi into ls_PersonID, ls_AccountNumber, ls_TraineeName, ls_Title, ldt_DeadlineDate;
					exit when cur_students_for_pi%NOTFOUND;
					
					mesg := '<tr>
					<td>' || ls_AccountNumber || '</td>
					<td>' || ls_Title || '</td>
					<td>' || ls_TraineeName || '</td>
					<td>' || to_char(ldt_DeadlineDate, 'mm/dd/yyyy') || '</td>
				   </tr>';		
           
				  li_entered_inside := 1;  
           
				end loop;
				
				close cur_students_for_pi; 
        
      if li_entered_inside = 1  then 
       mesg := '<table border="1">
                <tr>
                <th>Account Number</th>
                <th>Title</th>
                <th>Student</th>
                <th>Deadline</th>
               </tr>'||mesg||'</table>';
      end if; 
      
			begin
             KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,503,mail_subject,mail_message);	             
		     mail_message := replace(mail_message, '{STUDENT_LIST}',mesg );	
			 mail_message_PI	 :=  mail_message;		 
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_PIEmail,null,NULL,mail_subject,mail_message);	
			
			exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_PIID);				
			 
			end; 

			
        end loop;
        
        close cur_pis;
    
        
            --Sent a grouped email to the AOs
        open cur_aos;
        loop
            fetch cur_aos into ls_AOID, ls_AOEmail;
            exit when cur_aos%NOTFOUND;
            
             li_entered_inside := 0;                
            open cur_students_for_ao;
            loop
                fetch cur_students_for_ao into ls_PIName, ls_PersonID, ls_AccountNumber, ls_TraineeName, ls_Title, ldt_DeadlineDate;
                exit when cur_students_for_ao%NOTFOUND;
               
                mesg := '<tr>
                <td>' || ls_PIName || '</td>
                <td>' || ls_AccountNumber || '</td>
                <td>' || ls_Title || '</td>
                <td>' || ls_TraineeName || '</td>
                <td>' || to_char(ldt_DeadlineDate, 'mm/dd/yyyy') || '</td>
               </tr>';
                  li_entered_inside := 1;            
            end loop;
            
            close cur_students_for_ao; 
            
          if li_entered_inside = 1  then    
              mesg := '<table border="1">
                <tr>
                <th>PI</th>
                <th>Account Number</th>
                <th>Title</th>
                <th>Student</th>
                <th>Deadline</th>
               </tr>'||mesg||'</table>';
           end if; 
			begin

             KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,503,mail_subject,mail_message);	             
		     mail_message := replace(mail_message, '{STUDENT_LIST}',mesg );	
			 mail_message_AO := mail_message;
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_AOEmail,null,NULL,mail_subject,mail_message);	
            
			exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_AOID);				
			 
			end; 

			
        end loop;
        
        close cur_aos;
		
        --Sent a grouped email to the DHID
        open cur_dhs;
        loop
            fetch cur_dhs into ls_DHID, ls_DHEmail;
            exit when cur_dhs%NOTFOUND;
            
           li_entered_inside := 0;
            open cur_students_for_dh;
            loop
                fetch cur_students_for_dh into ls_PIName, ls_PersonID, ls_AccountNumber, ls_TraineeName, ls_Title, ldt_DeadlineDate;
                exit when cur_students_for_dh%NOTFOUND;               
                
              mesg := '<tr>
                        <td>' || ls_PIName || '</td>
                        <td>' || ls_AccountNumber || '</td>
                        <td>' || ls_Title || '</td>
                        <td>' || ls_TraineeName || '</td>
                        <td>' || to_char(ldt_DeadlineDate, 'mm/dd/yyyy') || '</td>
                       </tr>';               
            li_entered_inside := 1;
               
            end loop;
            
            close cur_students_for_dh; 
            
       if li_entered_inside = 1  then       
         mesg := '<table border="1">
                  <tr>
                  <th>PI</th>
                  <th>Account Number</th>
                  <th>Title</th>
                  <th>Student</th>
                  <th>Deadline</th>
                 </tr>'||mesg||'</table>';
       end if;
       
			begin
			
				 KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,503,mail_subject,mail_message);	             
				 mail_message := replace(mail_message, '{STUDENT_LIST}',mesg );
				 mail_message_DH := mail_message;
				 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_DHEmail,null,NULL,mail_subject,mail_message);	
            
			exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_DHID );				
			 
			end;   
          

			
        end loop;
        
        close cur_dhs;
        
        -- Notifications were sent.  		

	   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,503,mail_subject,mail_message);	 
	   li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'RCR Notification',mail_message);
	   
       if li_ntfctn_id <>  -1 then 
			open cur_notification_details;
			loop
				fetch cur_notification_details into ls_PersonID, ls_Role, ls_mail_sent_status ,ls_AccountNUmber, ls_PiName, ls_LeadUnit; 
				exit when cur_notification_details%NOTFOUND;
				
					KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_PersonID,ls_mail_sent_status);
				   
			end loop;
			close cur_notification_details;        
       end if;
	   
    end if;
	
    end if;
    
    return 0;
    
end fn_send_notification3;

--********************************************************************

function fn_send_notification4 (AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE)  return number is

li_NumofDays        RCR_NOTIF_TYPE.NO_OF_DAYS_PRIOR%type;
ls_PersonID         RCR_APPOINTMENTS.PERSON_ID%type;
ls_AccountNUmber    RCR_APPOINTMENTS.ACCOUNT_NUMBER%type;
ldt_PayrollStartDate RCR_PAYROLL_DATES.BASE_DATE%type;
ldt_DeadlineDate    RCR_PAYROLL_DATES.TRAINING_DEADLINE%type;

ll_NofificationId   RCR_NOTIFICATIONS.NOTIFICATION_ID%type;  
li_Count            number;

ls_TraineeName      VARCHAR2(100);
ls_TraineeEmail     KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_PIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_PIName           VARCHAR2(100);
ls_PIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_AOID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_AoName           VARCHAR2(100);
ls_AOEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_DHID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_DHName           VARCHAR2(100);
ls_DHEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;


ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;
ls_Title            AWARD.TITLE%type;
ls_LeadUnit         unit.unit_number%type;

ls_Role         RCR_NOTIF_DETAILS.RECIPIENT_ROLE%TYPE;

mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE; 
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;

mail_message_PI   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_message_AO   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_message_DH   NOTIFICATION_TYPE.MESSAGE%TYPE ;

mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );

ls_document_number award.document_number% type;
li_notification_type_id notification_type.notification_type_id% type := null;
ls_mail_sent_status RCR_NOTIF_DETAILS.MAIL_SENT_STATUS%type;
li_entered_inside NUMBER;

li_notification_is_active  PLS_INTEGER;

cursor cur_award is
    select distinct AWARD_NUMBER
    from AWARD
    where account_number = ls_AccountNUmber;

cursor cur_accts_to_notify is
     select A.PERSON_ID, A.ACCOUNT_NUMBER, P.BASE_DATE
    from RCR_APPOINTMENTS a, RCR_PAYROLL_DATES p
    where A.PERSON_ID = P.PERSON_ID
    and A.ACCOUNT_NUMBER = P.ACCOUNT_NUMBER
    and P.PAYROLL_NUMBER = (select max(P1.PAYROLL_NUMBER)
        from  RCR_PAYROLL_DATES p1
        where P.PERSON_ID = P1.PERSON_ID
        and P.ACCOUNT_NUMBER = P1.ACCOUNT_NUMBER)
    and P.BASE_DATE + li_NumofDays <= trunc(sysdate) 
    and A.PERSON_ID not in (select distinct PERSON_ID
        from person_training 
        where TRAINING_CODE in (select training_code from training where upper(description) like '%RCR%') 
            and DATE_SUBMITTED is not null);
    
cursor cur_pis is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'PI';
    
cursor cur_aos is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'AO';
    
cursor cur_dhs is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'DH';        
    
cursor cur_students_for_pi is
	
   select distinct nd.PERSON_ID, nd.ACCOUNT_NUMBER, (P.last_nm||', '|| p.first_nm) AS FULL_NAME, A.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,  AWARD a
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_PIID
    and nd.RECIPIENT_ROLE = 'PI'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = ( select max (a2.sequence_number)
                                from AWARD a2
                                where A.AWARD_NUMBER = A2.AWARD_NUMBER 
                            )
  
    order by full_name; 


 
cursor cur_students_for_ao is	
	select distinct pis.pi_name, nd.PERSON_ID, nd.ACCOUNT_NUMBER, (P.last_nm||', '|| p.first_nm) AS FULL_NAME, a.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,  AWARD a,         
        (select distinct ND1.PERSON_ID, ND1.ACCOUNT_NUMBER,  (P1.last_nm||', '|| p1.first_nm) pi_name
            FROM RCR_NOTIF_DETAILS nd1, krim_prncpl_v p1
            where ND1.NOTIFICATION_ID = ll_NofificationId
            and ND1.RECIPIENT_ROLE = 'PI'
            and ND1.RECIPIENT_ID = P1.prncpl_id) pis            
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_AOID
    and nd.RECIPIENT_ROLE = 'AO'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = (select max (a2.sequence_number)
        from AWARD a2
        where A.AWARD_NUMBER = A2.AWARD_NUMBER )
    and ND.PERSON_ID = pis.person_id
    and ND.ACCOUNT_NUMBER = pis.account_number
    order by pis.pi_name,FULL_NAME;
	
	
    
cursor cur_students_for_dh is
    select distinct pis.pi_name, nd.PERSON_ID, nd.ACCOUNT_NUMBER,(P.last_nm||', '|| p.first_nm) AS FULL_NAME, A.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,   AWARD a,
        (select distinct ND1.PERSON_ID, ND1.ACCOUNT_NUMBER,  (P1.last_nm||', '|| p1.first_nm) pi_name
            FROM RCR_NOTIF_DETAILS nd1, krim_prncpl_v p1
            where ND1.NOTIFICATION_ID = ll_NofificationId
            and ND1.RECIPIENT_ROLE = 'PI'
            and ND1.RECIPIENT_ID = P1.prncpl_id) pis
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_DHID
    and nd.RECIPIENT_ROLE = 'DH'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = (select max (a2.sequence_number)
        from AWARD a2
        where A.AWARD_NUMBER = A2.AWARD_NUMBER )
    and ND.PERSON_ID = pis.person_id
    and ND.ACCOUNT_NUMBER = pis.account_number
    order by pis.pi_name, FULL_NAME;
    
cursor cur_notification_details is   
	select distinct RECIPIENT_ID, RECIPIENT_ROLE, MAIL_SENT_STATUS , ACCOUNT_NUMBER, (krim_prncpl_v.last_nm||', '|| krim_prncpl_v.first_nm) full_name, UNIT_NUMBER
    from  RCR_NOTIF_DETAILS, krim_prncpl_v
    where NOTIFICATION_ID = ll_NofificationId
    and RECIPIENT_ID = krim_prncpl_v.prncpl_id
    and RECIPIENT_ROLE in ('PI', 'AO', 'DH')
    order by UNIT_NUMBER, RECIPIENT_ROLE, full_name;	
    
begin
    
    begin
	
		select NO_OF_DAYS_PRIOR , NOTIFICATION_TYPE_ID  into  li_NumofDays , li_notification_type_id
		from RCR_NOTIF_TYPE 
		where RCR_NOTIF_TYPE_CODE = AV_NOTIFICATION_TYPE;
		
    exception
        when others then
            return -1;
    end;
    
    ll_NofificationId := null;
    
    open cur_accts_to_notify;
    loop
        fetch cur_accts_to_notify into ls_PersonID, ls_AccountNUmber, ldt_PayrollStartDate;
        exit when cur_accts_to_notify%NOTFOUND;
        
        ldt_DeadlineDate := trunc(ldt_PayrollStartDate) + 60;
        
        --check if Email 1 has been sent for this person for this account
        select count(ND.PERSON_ID)
        into li_count
        from RCR_NOTIFICATIONS n, RCR_NOTIF_DETAILS nd
        where N.NOTIFICATION_TYPE_CODE = AV_NOTIFICATION_TYPE
        and N.NOTIFICATION_ID = ND.NOTIFICATION_ID
        and ND.PERSON_ID = ls_PersonID
        and ND.ACCOUNT_NUMBER = ls_AccountNUmber
        and nd.TRAINING_DEADLINE = ldt_DeadlineDate;
        
        if li_Count = 0 then
        --Email 2 has not been sent.  Need to sent email 1.
         
          if ll_NofificationId is null then
            ll_NofificationId := fn_get_next_rcr_notif_num;
            
                INSERT INTO RCR_NOTIFICATIONS (
                   NOTIFICATION_ID, NOTIFICATION_TYPE_CODE, NOTIFICATION_DATE, 
                   NO_OF_DAYS_PRIOR, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, AV_NOTIFICATION_TYPE, sysdate,
                    li_NumofDays, sysdate, user,1 , sys_guid());
          end if;
    
    begin      
			select distinct (t3.last_nm||', '|| t3.first_nm) as FULL_NAME, t1.email_addr  as EMAIL_ADDRESS
			into ls_TraineeName, ls_TraineeEmail
			from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
			inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
			where t2.prncpl_id = ls_PersonID
			and  t1.dflt_ind = 'Y';
		  
  exception
  when others then
    dbms_output.put_line(ls_PersonID||' .'||SQLERRM);
  end;
          --Using a Cursor just in case we have multiple awards with the same account number
            open cur_award;
            fetch cur_award into ls_MITAwardNumber;
	
  begin
  
			Select distinct  I.PERSON_ID ,  (t3.last_nm||', '|| t3.first_nm) as FULL_NAME , t1.email_addr as EMAIL_ADDRESS   
			into ls_PIID, ls_PIName, ls_PIEmail
			from  AWARD_PERSONS i  inner join krim_prncpl_t t2 on t2.prncpl_id = i.person_id
			inner join krim_entity_email_t t1  on t1.entity_id = t2.entity_id
			inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
			where I.contact_role_code = 'PI'
			and I.AWARD_NUMBER = ls_MITAwardNumber            
			and i.SEQUENCE_NUMBER = (select max(i1.sequence_number)  from AWARD_PERSONS i1  where I.AWARD_NUMBER = I1.AWARD_NUMBER )       
			and  t1.dflt_ind = 'Y' ;
			
  exception
  when others then
    dbms_output.put_line(ls_MITAwardNumber||' .'||SQLERRM);
  end;
			
            close cur_award;
            
            ls_LeadUnit := null;
            
            begin
			
			  select distinct
			  P.prncpl_id AS PERSON_ID, (p.last_nm||', '|| p.first_nm) AS FULL_NAME, e.email_addr AS EMAIL_ADDRESS, AU.UNIT_NUMBER
			  into ls_AOID, ls_AoName, ls_AOEmail, ls_LeadUnit
			  from AWARD_PERSON_UNITS au , AWARD_PERSONS ap,UNIT_ADMINISTRATOR u, 
			   krim_prncpl_v p,krim_entity_email_t e,krim_prncpl_t f
			  where au.award_person_id = ap.award_person_id
			  and  ap.AWARD_NUMBER = ls_MITAwardNumber
			  and ap.SEQUENCE_NUMBER = ( select max(au1.sequence_number)
								   from AWARD_PERSONS au1
								   where ap.AWARD_NUMBER = au1.AWARD_NUMBER)
			  and  au.lead_unit_flag = 'Y'
			  and au.unit_number = u.unit_number
			  and u.PERSON_ID = P.prncpl_id
			  and u.UNIT_ADMINISTRATOR_TYPE_CODE = 1 --ADMINISTRATIVE_OFFICER      
			  and p.prncpl_id = f.prncpl_id
			  and f.entity_id = e.entity_id
			  and e.dflt_ind = 'Y';
            
            exception
                when others then
                    ls_AOID := null;
            end;
            
            begin
                                      
				 select distinct
				  P.prncpl_id AS PERSON_ID, (p.last_nm||', '|| p.first_nm) AS FULL_NAME, e.email_addr AS EMAIL_ADDRESS
				  into ls_DHID, ls_DHName, ls_DHEmail
				  from AWARD_PERSON_UNITS au , AWARD_PERSONS ap,UNIT_ADMINISTRATOR u, 
				   krim_prncpl_v p,krim_entity_email_t e,krim_prncpl_t f
				  where au.award_person_id = ap.award_person_id
				  and  ap.AWARD_NUMBER = ls_MITAwardNumber
				  and ap.SEQUENCE_NUMBER = ( select max(au1.sequence_number)
									   from AWARD_PERSONS au1
									   where ap.AWARD_NUMBER = au1.AWARD_NUMBER)
				  and  au.lead_unit_flag = 'Y'
				  and au.unit_number = u.unit_number
				  and u.PERSON_ID = P.prncpl_id
				  and u.UNIT_ADMINISTRATOR_TYPE_CODE = 3	--UNIT_HEAD  
				  and p.prncpl_id = f.prncpl_id
				  and f.entity_id = e.entity_id
				  and e.dflt_ind = 'Y';
				
				
				
            exception
                when others then
                    ls_DHID := null;
            end;

            INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE, MAIL_SENT_STATUS,
               RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
            VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_PIID, 'PI','Y',
                ls_PIEmail, ls_LeadUnit, sysdate, user,1 , sys_guid());
                
            if ls_AOID is not null then
                INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE,MAIL_SENT_STATUS, 
               RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_AOID, 'AO','Y',
                ls_AOEmail, ls_LeadUnit, sysdate, user,1 , sys_guid());
            end if;
            
             if ls_DHID is not null then
                INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE, MAIL_SENT_STATUS,
               RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_DHID, 'DH','Y',
                ls_DHEmail, ls_LeadUnit, sysdate, user,1 , sys_guid());
            end if;
            
        end if;
    end loop;
    close cur_accts_to_notify;

    
    
    IF ll_NofificationId is not null then
    -- This run of the notification generated emails.  
    --Sent a grouped email to the PIs
	 li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,100,504);
	 if li_notification_is_active = 1 then
        open cur_pis;        
        loop
            fetch cur_pis into ls_PIID, ls_PIEmail;
            exit when cur_pis%NOTFOUND;
            
            li_entered_inside := 0; 
            open cur_students_for_pi;
            loop
                fetch cur_students_for_pi into ls_PersonID, ls_AccountNumber, ls_TraineeName, ls_Title, ldt_DeadlineDate;
                exit when cur_students_for_pi%NOTFOUND;
                
                mesg := '<tr>
                          <td>' || ls_AccountNumber || '</td>
                          <td>' || ls_Title || '</td>
                          <td>' || ls_TraineeName || '</td>
                          <td>' || to_char(ldt_DeadlineDate, 'mm/dd/yyyy') || '</td>
                         </tr>';   
                 li_entered_inside := 1;         
                             
            end loop;
            
            close cur_students_for_pi; 
            
           if li_entered_inside = 1  then  
            mesg := '<table border="1">
                <tr>
                <th>Account Number</th>
                <th>Title</th>
                <th>Student</th>
                <th>Deadline</th>
               </tr>'||mesg||'</table>'; 
           end if;    
               
			begin
			
             KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,504,mail_subject,mail_message);	             
		     mail_message := replace(mail_message, '{STUDENT_LIST}',mesg );	
			 mail_message_PI	 :=  mail_message;		 
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_PIEmail,null,NULL,mail_subject,mail_message);	
            
			exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_PIID);				
			 
			end;  
	
			
        end loop;
        
        close cur_pis;
        
            --Sent a grouped email to the AOs
        open cur_aos;
        loop
            fetch cur_aos into ls_AOID, ls_AOEmail;
            exit when cur_aos%NOTFOUND;
                    
           li_entered_inside := 0; 
            open cur_students_for_ao;
            loop
                fetch cur_students_for_ao into ls_PIName, ls_PersonID, ls_AccountNumber, ls_TraineeName, ls_Title, ldt_DeadlineDate;
                exit when cur_students_for_ao%NOTFOUND;
               
                mesg := '<tr>
                <td>' || ls_PIName || '</td>
                <td>' || ls_AccountNumber || '</td>
                <td>' || ls_Title || '</td>
                <td>' || ls_TraineeName || '</td>
                <td>' || to_char(ldt_DeadlineDate, 'mm/dd/yyyy') || '</td>
               </tr>';
               li_entered_inside := 1; 
            end loop;
            
            close cur_students_for_ao; 
            
      if li_entered_inside = 1  then 
      	 mesg := '<table border="1">
                <tr>
                <th>PI</th>
                <th>Account Number</th>
                <th>Title</th>
                <th>Student</th>
                <th>Deadline</th>
               </tr>'||mesg||'</table>';
      end if; 
               
			begin
			
             KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,504,mail_subject,mail_message);	             
		     mail_message := replace(mail_message, '{STUDENT_LIST}',mesg );	
			 mail_message_AO	 :=  mail_message;		 
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_AOEmail,null,NULL,mail_subject,mail_message);	
        
            exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_AOID);				
			 
			end;  

			
        end loop;
        
        close cur_aos;
        
        open cur_dhs;
        loop
            fetch cur_dhs into ls_DHID, ls_DHEmail;
            exit when cur_dhs%NOTFOUND;
            
          li_entered_inside := 0;
            open cur_students_for_dh;
            loop
                fetch cur_students_for_dh into ls_PIName, ls_PersonID, ls_AccountNumber, ls_TraineeName, ls_Title, ldt_DeadlineDate;
                exit when cur_students_for_dh%NOTFOUND;
               
                mesg := '<tr>
                <td>' || ls_PIName || '</td>
                <td>' || ls_AccountNumber || '</td>
                <td>' || ls_Title || '</td>
                <td>' || ls_TraineeName || '</td>
                <td>' || to_char(ldt_DeadlineDate, 'mm/dd/yyyy') || '</td>
               </tr>';
                            
             li_entered_inside := 1;
             
            end loop;
            
            close cur_students_for_dh; 
            
       if li_entered_inside = 1  then 
      	 mesg := '<table border="1">
                <tr>
                <th>PI</th>
                <th>Account Number</th>
                <th>Title</th>
                <th>Student</th>
                <th>Deadline</th>
               </tr>'||mesg||'</table>';
      end if;         
			
			begin
             KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,504,mail_subject,mail_message);	             
		     mail_message := replace(mail_message, '{STUDENT_LIST}',mesg );
			 mail_message_DH := mail_message;
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_DHEmail,null,NULL,mail_subject,mail_message);	
            
			exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_DHID);				
			 
			end;  
			
        end loop;
        
        close cur_dhs;
        
        -- Notifications were sent.  
		   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,504,mail_subject,mail_message);	 
		   li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'RCR Notification',mail_message);
		   
		   if li_ntfctn_id <>  -1 then 
				open cur_notification_details;
				loop
					fetch cur_notification_details into ls_PersonID, ls_Role,ls_mail_sent_status, ls_AccountNUmber, ls_PiName, ls_LeadUnit; 
					exit when cur_notification_details%NOTFOUND;
					
						KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_PersonID,ls_mail_sent_status);
					   
				end loop;
				close cur_notification_details;        
		   end if;
    end if;     

    end if;
    
    return 0;
    
end fn_send_notification4;

--********************************************************************

function fn_send_notification5 (AV_NOTIFICATION_TYPE  IN RCR_NOTIF_TYPE.RCR_NOTIF_TYPE_CODE%TYPE)  return number is

li_NumofDays        RCR_NOTIF_TYPE.NO_OF_DAYS_PRIOR%type;
ls_PersonID         RCR_APPOINTMENTS.PERSON_ID%type;
ls_AccountNUmber    RCR_APPOINTMENTS.ACCOUNT_NUMBER%type;
ldt_PayrollStartDate RCR_PAYROLL_DATES.BASE_DATE%type;
ldt_DeadlineDate    RCR_PAYROLL_DATES.TRAINING_DEADLINE%type;

ll_NofificationId   RCR_NOTIFICATIONS.NOTIFICATION_ID%type;  
li_Count            number;

ls_TraineeName      VARCHAR2(100);
ls_TraineeEmail     KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_PIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_PIName           VARCHAR2(100);
ls_PIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_AOID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_AoName           VARCHAR2(100);
ls_AOEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_DHID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_DHName           VARCHAR2(100);
ls_DHEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_ADID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_ADName           VARCHAR2(100);
ls_ADFName          VARCHAR2(100);
ls_ADLName          VARCHAR2(100);
ls_ADEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;


mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE; 
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;

ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;
ls_Title            AWARD.TITLE%type;
ls_LeadUnit         unit.unit_number%type;
ls_Role         RCR_NOTIF_DETAILS.RECIPIENT_ROLE%TYPE;

mail_message_PI   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_message_AO   NOTIFICATION_TYPE.MESSAGE%TYPE ;
mail_message_DH   NOTIFICATION_TYPE.MESSAGE%TYPE ;

mesg                     CLOB;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );


ls_document_number award.document_number% type;
li_notification_type_id notification_type.notification_type_id% type := null;
ls_mail_sent_status RCR_NOTIF_DETAILS.MAIL_SENT_STATUS%type;

li_entered_inside NUMBER;
li_notification_is_active PLS_INTEGER;

cursor cur_award is
    select distinct AWARD_NUMBER
    from AWARD
    where account_number = ls_AccountNUmber;

cursor cur_accts_to_notify is
     select A.PERSON_ID, A.ACCOUNT_NUMBER, P.BASE_DATE
    from RCR_APPOINTMENTS a, RCR_PAYROLL_DATES p
    where A.PERSON_ID = P.PERSON_ID
    and A.ACCOUNT_NUMBER = P.ACCOUNT_NUMBER
    and P.PAYROLL_NUMBER = (select max(P1.PAYROLL_NUMBER)
        from  RCR_PAYROLL_DATES p1
        where P.PERSON_ID = P1.PERSON_ID
        and P.ACCOUNT_NUMBER = P1.ACCOUNT_NUMBER)
    and P.BASE_DATE + li_NumofDays <= trunc(sysdate) 
    and A.PERSON_ID not in (select distinct PERSON_ID
        from person_training 
        where TRAINING_CODE in (select training_code from training where upper(description) like '%RCR%') 
            and DATE_SUBMITTED is not null);
    
cursor cur_pis is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'PI';
    
cursor cur_aos is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'AO';
    
cursor cur_dhs is
    select distinct RECIPIENT_ID, RECIPIENT_EMAIL
    from RCR_NOTIF_DETAILS
    where NOTIFICATION_ID  = ll_NofificationId
    and RECIPIENT_ROLE = 'DH';      
    
cursor cur_ads is
    select distinct nd.RECIPIENT_ID, nd.RECIPIENT_EMAIL, (p.last_nm||', '|| p.first_nm) AS FULL_NAME, p.first_nm FIRST_NAME, p.last_nm LAST_NAME
    from RCR_NOTIF_DETAILS nd, krim_prncpl_v p
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ROLE = 'AD'
    and ND.RECIPIENT_ID = p.prncpl_id;    
   
	
cursor cur_students_for_pi is
	select distinct nd.PERSON_ID, nd.ACCOUNT_NUMBER, (P.last_nm||', '|| p.first_nm) AS FULL_NAME, A.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,  AWARD a
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_PIID
    and nd.RECIPIENT_ROLE = 'PI'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = ( select max (a2.sequence_number)
                                from AWARD a2
                                where A.AWARD_NUMBER = A2.AWARD_NUMBER 
                            )
  
    order by full_name;
	
	
cursor cur_students_for_ao is
	 select distinct pis.pi_name, nd.PERSON_ID, nd.ACCOUNT_NUMBER, (P.last_nm||', '|| p.first_nm) AS FULL_NAME, a.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,  AWARD a,         
        (select distinct ND1.PERSON_ID, ND1.ACCOUNT_NUMBER,  (P1.last_nm||', '|| p1.first_nm) pi_name
            FROM RCR_NOTIF_DETAILS nd1, krim_prncpl_v p1
            where ND1.NOTIFICATION_ID = ll_NofificationId
            and ND1.RECIPIENT_ROLE = 'PI'
            and ND1.RECIPIENT_ID = P1.prncpl_id) pis            
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_AOID
    and nd.RECIPIENT_ROLE = 'AO'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = (select max (a2.sequence_number)
        from AWARD a2
        where A.AWARD_NUMBER = A2.AWARD_NUMBER )
    and ND.PERSON_ID = pis.person_id
    and ND.ACCOUNT_NUMBER = pis.account_number
    order by pis.pi_name,FULL_NAME;
	
	
	
cursor cur_students_for_dh is
	select distinct pis.pi_name, nd.PERSON_ID, nd.ACCOUNT_NUMBER,(P.last_nm||', '|| p.first_nm) AS FULL_NAME, A.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,   AWARD a,
        (select distinct ND1.PERSON_ID, ND1.ACCOUNT_NUMBER,  (P1.last_nm||', '|| p1.first_nm) pi_name
            FROM RCR_NOTIF_DETAILS nd1, krim_prncpl_v p1
            where ND1.NOTIFICATION_ID = ll_NofificationId
            and ND1.RECIPIENT_ROLE = 'PI'
            and ND1.RECIPIENT_ID = P1.prncpl_id) pis
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_DHID
    and nd.RECIPIENT_ROLE = 'DH'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = (select max (a2.sequence_number)
        from AWARD a2
        where A.AWARD_NUMBER = A2.AWARD_NUMBER )
    and ND.PERSON_ID = pis.person_id
    and ND.ACCOUNT_NUMBER = pis.account_number
    order by pis.pi_name, ND.UNIT_NUMBER, FULL_NAME;
	
cursor cur_students_for_ad is    

	select distinct pis.pi_name, nd.PERSON_ID, nd.ACCOUNT_NUMBER,(P.last_nm||', '|| p.first_nm) AS FULL_NAME, A.TITLE, nd.TRAINING_DEADLINE
    from  RCR_NOTIF_DETAILS nd, krim_prncpl_v p,   AWARD a,
        (select distinct ND1.PERSON_ID, ND1.ACCOUNT_NUMBER,  (P1.last_nm||', '|| p1.first_nm) pi_name
            FROM RCR_NOTIF_DETAILS nd1, krim_prncpl_v p1
            where ND1.NOTIFICATION_ID = ll_NofificationId
            and ND1.RECIPIENT_ROLE = 'PI'
            and ND1.RECIPIENT_ID = P1.prncpl_id) pis
    where nd.NOTIFICATION_ID  = ll_NofificationId
    and nd.RECIPIENT_ID = ls_DHID
    and nd.RECIPIENT_ROLE = 'AD'
    and ND.PERSON_ID = P.prncpl_id
    and ND.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER
    and A.SEQUENCE_NUMBER = (select max (a2.sequence_number)
        from AWARD a2
        where A.AWARD_NUMBER = A2.AWARD_NUMBER )
    and ND.PERSON_ID = pis.person_id
    and ND.ACCOUNT_NUMBER = pis.account_number
    order by pis.pi_name, FULL_NAME;


	
        
cursor cur_notification_details is
    select distinct RECIPIENT_ID, RECIPIENT_ROLE,ls_mail_sent_status, ACCOUNT_NUMBER, (krim_prncpl_v.last_nm||', '|| krim_prncpl_v.first_nm) AS full_name, UNIT_NUMBER
    from  RCR_NOTIF_DETAILS, krim_prncpl_v
    where NOTIFICATION_ID = ll_NofificationId
    and RECIPIENT_ID = krim_prncpl_v.prncpl_id
    and RECIPIENT_ROLE in ('AD')
    order by UNIT_NUMBER, RECIPIENT_ROLE, full_name;

   
cursor cur_ad is 
                  
    select distinct
	  P.prncpl_id AS "ADMINISTRATOR",p.first_nm,p.last_nm, (p.last_nm||', '|| p.first_nm) AS FULL_NAME, trim(e.email_addr) AS EMAIL_ADDRESS, AU.UNIT_NUMBER
	  from AWARD_PERSON_UNITS au , AWARD_PERSONS ap,UNIT_ADMINISTRATOR u, 
	   krim_prncpl_v p,krim_entity_email_t e,krim_prncpl_t f
	  where au.award_person_id = ap.award_person_id
	  and  ap.AWARD_NUMBER = ls_MITAwardNumber
	  and ap.SEQUENCE_NUMBER = ( select max(au1.sequence_number)
						   from AWARD_PERSONS au1
						   where ap.AWARD_NUMBER = au1.AWARD_NUMBER)
	  and  au.lead_unit_flag = 'Y'
	  and au.unit_number = u.unit_number
	  and u.PERSON_ID = P.prncpl_id
	  and u.UNIT_ADMINISTRATOR_TYPE_CODE =16 --	Assistant Dean (RCR)   
	  and p.prncpl_id = f.prncpl_id
	  and f.entity_id = e.entity_id
	  and e.dflt_ind = 'Y';        
    
begin
    
    begin
		select NO_OF_DAYS_PRIOR , NOTIFICATION_TYPE_ID  into  li_NumofDays , li_notification_type_id
		from RCR_NOTIF_TYPE 
		where RCR_NOTIF_TYPE_CODE = AV_NOTIFICATION_TYPE;		
		
    exception
        when others then
            return -1;
    end;
    
    ll_NofificationId := null;
    
    open cur_accts_to_notify;
    loop
        fetch cur_accts_to_notify into ls_PersonID, ls_AccountNUmber, ldt_PayrollStartDate;
        exit when cur_accts_to_notify%NOTFOUND;
        
        ldt_DeadlineDate := trunc(ldt_PayrollStartDate) + 60;
        
        --check if Email 1 has been sent for this person for this account
        select count(ND.PERSON_ID)
        into li_count
        from RCR_NOTIFICATIONS n, RCR_NOTIF_DETAILS nd
        where N.NOTIFICATION_TYPE_CODE = AV_NOTIFICATION_TYPE
        and N.NOTIFICATION_ID = ND.NOTIFICATION_ID
        and ND.PERSON_ID = ls_PersonID
        and ND.ACCOUNT_NUMBER = ls_AccountNUmber
        and nd.TRAINING_DEADLINE = ldt_DeadlineDate;
        
        if li_Count = 0 then
        --Email has not been sent.  Need to sent email 1.
         
          if ll_NofificationId is null then
            ll_NofificationId := fn_get_next_rcr_notif_num;
            
                INSERT INTO RCR_NOTIFICATIONS (
                   NOTIFICATION_ID, NOTIFICATION_TYPE_CODE, NOTIFICATION_DATE, 
                   NO_OF_DAYS_PRIOR, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                VALUES ( ll_NofificationId, AV_NOTIFICATION_TYPE, sysdate,
                    li_NumofDays, sysdate, user,1 , sys_guid());
          end if;
          
      begin
      
        select distinct (t3.last_nm||', '|| t3.first_nm) as FULL_NAME, t1.email_addr  as EMAIL_ADDRESS
        into ls_TraineeName, ls_TraineeEmail
        from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
        inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
        where t2.prncpl_id = ls_PersonID
        and  t1.dflt_ind = 'Y';
      
      exception
      when others then
      dbms_output.put_line(ls_PersonID||' .'||sqlerrm);
      end;
        
		  
          --Using a Cursor just in case we have multiple awards with the same account number
            open cur_award;
            fetch cur_award into ls_MITAwardNumber;
      
            begin      
                Select distinct I.PERSON_ID ,  (t3.last_nm||', '|| t3.first_nm) as FULL_NAME , t1.email_addr as EMAIL_ADDRESS   
                into ls_PIID, ls_PIName, ls_PIEmail
                from  AWARD_PERSONS i  inner join krim_prncpl_t t2 on t2.prncpl_id = i.person_id
                inner join krim_entity_email_t t1  on t1.entity_id = t2.entity_id
                inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
                where I.contact_role_code = 'PI'
                and I.AWARD_NUMBER = ls_MITAwardNumber            
                and i.SEQUENCE_NUMBER = (select max(i1.sequence_number)  from AWARD_PERSONS i1  where I.AWARD_NUMBER = I1.AWARD_NUMBER )       
                and  t1.dflt_ind = 'Y' ;
            exception
            when others then
            dbms_output.put_line(ls_MITAwardNumber||' .'||sqlerrm);
            end;
            
            close cur_award;
            
           /* INSERT INTO RCR_NOTIF_DETAILS (
               NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
               TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE, 
               RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
            VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                ldt_DeadlineDate, ls_PIID, 'PI',
                ls_PIEmail, ls_LeadUnit, sysdate, user,1 , sys_guid() );
             */   
            ls_LeadUnit := null;
            ls_ADID := null;
            
            open cur_ad;
            loop
                fetch cur_ad into ls_ADID, ls_ADFName, ls_ADLName, ls_ADName, ls_ADEmail, ls_LeadUnit;
                exit when cur_ad%NOTFOUND;
               
               
              if ls_ADID is not null then
              
                INSERT INTO RCR_NOTIF_DETAILS (
                   NOTIFICATION_ID, PERSON_ID, ACCOUNT_NUMBER, 
                   TRAINING_DEADLINE, RECIPIENT_ID, RECIPIENT_ROLE, MAIL_SENT_STATUS,
                   RECIPIENT_EMAIL, UNIT_NUMBER, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                    VALUES ( ll_NofificationId, ls_PersonID, ls_AccountNUmber,
                    ldt_DeadlineDate, ls_ADID, 'AD','Y',
                    ls_ADEmail, ls_LeadUnit, sysdate, user,1 , sys_guid() );
                    
              end if;
            
               
            end loop;
            close cur_ad;
            
            
        end if;
    end loop;
    close cur_accts_to_notify;

    
    
    IF ll_NofificationId is not null then
    -- This run of the notification generated emails.  
    --Sent a grouped email to the PIs
    li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,100,505);  
	if li_notification_is_active = 1 then
        open cur_ads;
        loop
            fetch cur_ads into ls_ADID, ls_ADEmail, ls_ADName, ls_ADFName, ls_ADLName;
            exit when cur_ads%NOTFOUND;
           
            if ls_ADFName is not null and ls_ADLName is not null then
                   ls_ADName := ls_ADFName || ' ' || ls_ADLName;
            end if;
             
                   
             KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,505,mail_subject,mail_message);
			 mail_subject := replace(mail_subject, '{ADMINISTRATOR_NAME}',ls_ADName );			 
		     mail_message := replace(mail_message, '{ADMINISTRATOR_NAME}',ls_ADName );	
                   
           li_entered_inside := 0;
            open cur_students_for_ad;
            loop
                fetch cur_students_for_ad into ls_PIName, ls_PersonID, ls_AccountNumber, ls_TraineeName, ls_Title, ldt_DeadlineDate;
                exit when cur_students_for_ad%NOTFOUND;
               
                mesg := '<tr>
                <td>' || ls_PIName || '</td>
                <td>' || ls_AccountNumber || '</td>
                <td>' || ls_Title || '</td>
                <td>' || ls_TraineeName || '</td>
                <td>' || to_char(ldt_DeadlineDate, 'mm/dd/yyyy') || '</td>
               </tr>';
               
               li_entered_inside := 1;
            end loop;
            
            close cur_students_for_ad; 
            
        if li_entered_inside = 1  then  
      	 mesg := '<table border="1">
                <tr>
                <th>PI</th>
                <th>Account Number</th>
                <th>Title</th>
                <th>Student</th>
                <th>Deadline</th>
               </tr>'||mesg||'</table>';
                        
				end if;		
             mail_message := replace(mail_message, '{STUDENT_LIST}',mesg );
			 
			begin
			
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_ADEmail,null,NULL,mail_subject,mail_message);	
			 
            exception
			when others then
				UPDATE RCR_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
				WHERE NOTIFICATION_ID = ll_NofificationId
				AND ( RECIPIENT_ID = ls_ADID);				
			 
			end;   

        end loop;
        
        close cur_ads;
        
		
		
	   KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,505,mail_subject,mail_message);	 
	   li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'RCR Notification',mail_message);
	   
       if li_ntfctn_id <>  -1 then 
			open cur_notification_details;
			loop
            fetch cur_notification_details into ls_PersonID, ls_Role,ls_mail_sent_status, ls_AccountNUmber, ls_PiName, ls_LeadUnit; 
            exit when cur_notification_details%NOTFOUND;
				
					KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,ls_PersonID,ls_mail_sent_status);
				   
			end loop;
			close cur_notification_details;        
       end if;
		
	end if;        

    end if;
    
    return 0;
    
end fn_send_notification5;

--********************************************************************

function fn_rcr_tr_compl_notif(as_personid  in KRIM_PRNCPL_T.PRNCPL_ID%type,
                               ai_TrainingType in person_training.TRAINING_CODE%type) 
        return NUMBER is

ll_ret  number;
ls_TraineeName   VARCHAR2(100);
ls_TraineeFName  VARCHAR2(100);
ls_TraineeLName  VARCHAR2(100);
ls_TraineeEmail  KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
mesg   CLOB;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE; 
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
ls_mail_sent_status RCR_NOTIF_DETAILS.MAIL_SENT_STATUS%type := 'Y';
li_notification_type_id notification_type.notification_type_id% type := null;
ls_document_number KRIM_PERSON_DOCUMENT_T.FDOC_NBR% type;
li_notification_is_active PLS_INTEGER;
begin
    
    begin
		
		select distinct t3.first_nm as first_name, t3.last_nm as last_name,(t3.last_nm||', '|| t3.first_nm) as FULL_NAME, t1.email_addr  as EMAIL_ADDRESS
		 into ls_TraineeFName, ls_TraineeLName, ls_TraineeName, ls_TraineeEmail
		from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
		inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
		where t2.prncpl_id = as_personid
		and  t1.dflt_ind = 'Y';
		
    exception
        when others then
            return -1;
    end;
    
    if ls_TraineeFName is not null and ls_TraineeLName is not null then
        ls_TraineeName := ls_TraineeFName || ' ' || ls_TraineeLName;
    end if;
	
	li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,100,506);
	
	if li_notification_is_active = 1 then
	
		select NOTIFICATION_TYPE_ID into li_notification_type_id from NOTIFICATION_TYPE where module_code = 100 and action_code = 506;
		KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,100,506,mail_subject,mail_message);				
		begin
			if (ls_TraineeEmail is not null) and (length(trim(ls_TraineeEmail)) > 0) then         
				 mail_message := replace(mail_message, '{TRAINEE_NAME}',ls_TraineeName );	
				 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_TraineeEmail,null,NULL,mail_subject,mail_message);	
						
			end if;
		exception
		when others then
		ls_mail_sent_status := 'N';
		end;
		
		
		   li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'RCR Notification',mail_message);       
		   KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,as_personid,ls_mail_sent_status);
		
	end if;
	
    Return ll_ret;
    
end fn_rcr_tr_compl_notif;           
        

function fn_get_next_rcr_notif_num return number is

ll_num             NUMBER(10,0);

begin
    select SEQ_RCR_NOTIFICATION_ID.NEXTVAL
    into ll_num
    from dual;
    
    return ll_num;
end fn_get_next_rcr_notif_num;

end ;
/