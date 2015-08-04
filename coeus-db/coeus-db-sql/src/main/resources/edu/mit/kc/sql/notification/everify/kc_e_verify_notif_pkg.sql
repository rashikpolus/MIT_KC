create or replace package KC_E_VERIFY_NOTIF_PKG as

	function fn_gen_e_verify_emails return number;
	function fn_insert_data return number;
	function fn_send_everify_email(as_award_num  IN AWARD.AWARD_NUMBER%TYPE) return number;
function fn_get_account_for_award   ( AW_MIT_AWARD_NUMBER IN award.award_number%TYPE ) RETURN varchar2;
end;
/
create or replace package body KC_E_VERIFY_NOTIF_PKG as

	mail_conn             utl_smtp.connection;
	gl_NofificationId     EVERIFY_NOTIF_DETAILS.NOTIFICATION_ID%type; 
                        
--function fn_get_account_for_award  ( AW_MIT_AWARD_NUMBER IN award.award_number%TYPE ) RETURN varchar2;        
               
function fn_check_mail(as_award_num  IN AWARD.AWARD_NUMBER%TYPE,
    as_PERSON_ID in EVERIFY_NOTIF_DETAILS.RECIPIENT_ID%TYPE, 
    as_PERSON_ROLE in EVERIFY_NOTIF_DETAILS.RECIPIENT_ROLE%TYPE) RETURN NUMBER;
    
                        
/******************************************************************************/
function fn_gen_e_verify_emails
  RETURN NUMBER IS
/******************************************************************************/
li_Count            number;
ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;

                
cursor cur_everify_award is
    select substr(AWARD_NUMBER,1,6)
    from EVERIFY_NOTIF_DETAILS 
    where NOTIFICATION_ID = gl_NofificationId   
    group by substr(AWARD_NUMBER,1,6);
                
BEGIN  
 
    gl_NofificationId := null;
    
    li_Count := fn_insert_data(); 
    
    open cur_everify_award;
    loop
        fetch cur_everify_award into ls_MITAwardNumber;
        exit when cur_everify_award%NOTFOUND;
       
        li_Count := fn_send_everify_email(ls_MITAwardNumber);  
        
        --DBMS_LOCK.SLEEP(2);       
               
    end loop;    
    close cur_everify_award;
return 1;

END fn_gen_e_verify_emails;      

/******************************************************************************/
function fn_insert_data
  RETURN NUMBER IS
/******************************************************************************/

li_Count            number; 
ll_NofificationId   EVERIFY_NOTIF_DETAILS.NOTIFICATION_ID%type;  

ls_PIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_PIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_AIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_AIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_OIID             KRIM_PRNCPL_T.PRNCPL_ID%type;
ls_OIEmail          KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;

ls_LeadUnit         unit.unit_number%type;

ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;
ls_SeqNumber        AWARD.SEQUENCE_NUMBER%type;
ls_AccountNUmber    AWARD.ACCOUNT_NUMBER%type;

ldt_LastRunDate     EVERIFY_NOTIFICATIONS.UPDATE_TIMESTAMP%type; 
li_everify_mail_count       NUMBER :=0; 

cursor cur_everify_award_data is -- need to include SAP feed         
	 select  distinct 
    t1.award_number AWARD_NUMBER,
    t1.SEQUENCE_NUMBER,
    t1.account_number,
    t4.unit_number,
    t2.PERSON_ID pi_id, 
    t7.email_addr  pi_eamil,
    t6.PERSON_ID oi_id, 
    t9.email_addr oi_eamil,
    t5.PERSON_ID ai_id,
    t8.email_addr ai_eamil    
   from award t1 inner join award_persons t2 on t1.award_id = t2.award_id
   inner join award_custom_data t3 on  t1.award_id = t3.award_id  
   inner join award_person_units t4 on t2.award_person_id = t4.award_person_id
   inner join unit_administrator t5 on t4.unit_number = t5.unit_number 
   and t5.unit_administrator_type_code = (   select unit_administrator_type_code from unit_administrator_type where upper(description) = upper('ADMINISTRATIVE_OFFICER'))
   inner join unit_administrator t6 on t4.unit_number = t6.unit_number 
   and t6.unit_administrator_type_code = (   select unit_administrator_type_code from unit_administrator_type where upper(description) = upper('OTHER_INDIVIDUAL_TO_NOTIFY'))
   inner join SAP_FEED_DETAILS t10 on t1.award_number = t10.award_number
   left outer join (	select distinct t2.prncpl_id, t1.email_addr	
		from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
		inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
		where t1.dflt_ind = 'Y' ) t7 on t2.PERSON_ID = t7.prncpl_id
    
     left outer join (	select distinct t2.prncpl_id, t1.email_addr	
		from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
		inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
		where t1.dflt_ind = 'Y' ) t8 on t5.PERSON_ID = t8.prncpl_id
    
      left outer join (	select distinct t2.prncpl_id, t1.email_addr	
		from krim_entity_email_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
		inner join krim_prncpl_v t3 on t3.prncpl_id = t2.prncpl_id
		where t1.dflt_ind = 'Y' ) t9 on t6.PERSON_ID = t9.prncpl_id
   
   where  t10.UPDATE_TIMESTAMP >= to_date(ldt_LastRunDate)
   and    (t10.FEED_TYPE = 'N' or t10.FEED_TYPE = 'C')  
   and t10.FEED_ID = (select max(s1.feed_id) from sap_feed_details s1  where t10.AWARD_NUMBER = s1.AWARD_NUMBER)
   and t2.contact_role_code = 'PI'
   and t1.sequence_number = (select max(s1.sequence_number) from award s1 where s1.award_number = t1.award_number)
   and  t3.custom_attribute_id = (select id from custom_attribute where name = 'E-VERIFY')
   and  t3.value = 'Yes'
   and  t4.lead_unit_flag = 'Y';	

begin
    begin  
        select UPDATE_TIMESTAMP
        into ldt_LastRunDate
        from EVERIFY_NOTIFICATIONS
        where NOTIFICATION_ID = (select max(NOTIFICATION_ID) from EVERIFY_NOTIFICATIONS);
    exception 
            when others then
             ldt_LastRunDate := sysdate;
    end;
        
    begin   
           select COUNT(t1.award_number)  into li_Count  -- need to include SAP feed 
		   from award t1 
		   inner join award_custom_data t3 on  t1.award_id = t3.award_id    
		   inner join SAP_FEED_DETAILS t10 on t1.award_number = t10.award_number
		   where t10.UPDATE_TIMESTAMP >= to_date(ldt_LastRunDate)		   
		   and    (t10.FEED_TYPE = 'N' or t10.FEED_TYPE = 'C')  
		   and t10.FEED_ID = (select max(s1.feed_id) from sap_feed_details s1  where t10.AWARD_NUMBER = s1.AWARD_NUMBER)
		   and t1.sequence_number = (select max(s1.sequence_number) from award s1 where s1.award_number = t1.award_number)
		   and  t3.custom_attribute_id = (select id from custom_attribute where name = 'E-VERIFY')
		   and  t3.value = 'Yes';
			   
        exception
            when NO_DATA_FOUND then
            li_Count := 0;
    end;    
    
    if  li_Count > 0 then
    
        dbms_output.put_line('E2-Verify found.');
        select SEQ_EVERIFY_NOTIFICATION_ID.NEXTVAL into ll_NofificationId from dual;
        
        gl_NofificationId := ll_NofificationId;
        
        INSERT INTO EVERIFY_NOTIFICATIONS (NOTIFICATION_ID, NOTIFICATION_DATE,UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
			VALUES ( ll_NofificationId, sysdate,sysdate, user,1,sys_guid());
			
        open cur_everify_award_data;
        loop
            fetch cur_everify_award_data into ls_MITAwardNumber,ls_SeqNumber, ls_AccountNUmber, ls_LeadUnit, ls_PIID, ls_PIEmail, ls_OIID, ls_OIEmail,ls_AIID,ls_AIEmail;
            exit when cur_everify_award_data%NOTFOUND;
            if ls_PIID is not null then
                if ls_PIEmail is null then
                    ls_PIEmail := 'kc-mit-dev@mit.edu';
                end if; 
                                
                
                li_everify_mail_count := 0;
                li_everify_mail_count := fn_check_mail(ls_MITAwardNumber, ls_PIID, 'PI');    
                if li_everify_mail_count = 0 then
                    BEGIN
                    INSERT INTO EVERIFY_NOTIF_DETAILS (
                       NOTIF_DETAILS_ID, NOTIFICATION_ID, AWARD_NUMBER,SEQUENCE_NUMBER,RECIPIENT_ID,RECIPIENT_ROLE, RECIPIENT_EMAIL,UNIT_NUMBER,MAIL_SENT_STATUS,UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                    VALUES ( SEQ_EVERIFY_NOTIF_DETAILS_ID.NEXTVAL, ll_NofificationId,ls_MITAwardNumber,ls_SeqNumber, ls_PIID, 'PI', ls_PIEmail,ls_LeadUnit,'Y', sysdate, user,1,sys_guid());   
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                        -- Row already exists, which is ok
                            NULL;
                    END;         
                end if;            
                   
                            
            end if;
            
            if ls_AIID is not null then
                if ls_AIEmail is null then
                    ls_AIEmail := 'kc-mit-dev@mit.edu';
                end if;
                
                   
                li_everify_mail_count := 0;
                li_everify_mail_count := fn_check_mail(ls_MITAwardNumber, ls_AIID, 'AO');    
                if li_everify_mail_count = 0 then 
                    BEGIN            
                    INSERT INTO EVERIFY_NOTIF_DETAILS (
                       NOTIF_DETAILS_ID, NOTIFICATION_ID, AWARD_NUMBER,SEQUENCE_NUMBER,RECIPIENT_ID,RECIPIENT_ROLE, RECIPIENT_EMAIL,UNIT_NUMBER,MAIL_SENT_STATUS,UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                    VALUES ( SEQ_EVERIFY_NOTIF_DETAILS_ID.NEXTVAL, ll_NofificationId,ls_MITAwardNumber,ls_SeqNumber, ls_AIID, 'AO', ls_AIEmail,ls_LeadUnit,'Y', sysdate, user,1,sys_guid());
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                        -- Row already exists, which is ok
                            NULL;
                    END;        
                end if;        
	                 
            end if;
                    
            if ls_OIID is not null then
                if ls_OIEmail is null then
                    ls_OIEmail := 'kc-mit-dev@mit.edu';
                end if;
                
                   
                li_everify_mail_count := 0;
                li_everify_mail_count := fn_check_mail(ls_MITAwardNumber, ls_OIID, 'OI');    
                if li_everify_mail_count = 0 then 
                    BEGIN
                    INSERT INTO EVERIFY_NOTIF_DETAILS (
                       NOTIF_DETAILS_ID, NOTIFICATION_ID, AWARD_NUMBER,SEQUENCE_NUMBER,RECIPIENT_ID,RECIPIENT_ROLE, RECIPIENT_EMAIL,UNIT_NUMBER,MAIL_SENT_STATUS,UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID) 
                    VALUES ( SEQ_EVERIFY_NOTIF_DETAILS_ID.NEXTVAL, ll_NofificationId,ls_MITAwardNumber,ls_SeqNumber, ls_OIID, 'OI', ls_OIEmail,ls_LeadUnit,'Y', sysdate, user,1,sys_guid()); 
                    EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                        -- Row already exists, which is ok
                            NULL;
                    END;        
                end if;             
            end if;          
        end loop;
        close cur_everify_award_data;
        
        
        dbms_output.put_line('E-Verify found.');
        return li_Count;
    
    else
        dbms_output.put_line('No E-Verify found.');
        return li_Count;

    end if;



return 1;

end fn_insert_data;

/******************************************************************************/
function fn_check_mail(as_award_num  IN AWARD.AWARD_NUMBER%TYPE,
    as_PERSON_ID in EVERIFY_NOTIF_DETAILS.RECIPIENT_ID%TYPE, 
    as_PERSON_ROLE in EVERIFY_NOTIF_DETAILS.RECIPIENT_ROLE%TYPE)
 RETURN NUMBER IS
/******************************************************************************/

li_mail_count       NUMBER :=0; 

begin
    select count(AWARD_NUMBER)
    into li_mail_count
    from EVERIFY_NOTIF_DETAILS
    where AWARD_NUMBER = as_award_num
        and RECIPIENT_ID = as_PERSON_ID
        and RECIPIENT_ROLE = as_PERSON_ROLE;
        
    if li_mail_count > 0 then
        return 1;
    else 
        return 0;
    end if;
end fn_check_mail;


/******************************************************************************/
function fn_send_everify_email(as_award_num  IN AWARD.AWARD_NUMBER%TYPE) 
  RETURN NUMBER IS
/******************************************************************************/

li_first                      number := 0;

ls_MITAwardNumber   AWARD.AWARD_NUMBER%type;
ls_AccountNUmber    AWARD.ACCOUNT_NUMBER%type;


ls_recipients           varchar2(2000) := null;
ls_email_address        KRIM_ENTITY_EMAIL_T.EMAIL_ADDR%type;
ls_cc_email              varchar2(200) := 'kc-mit-dev@mit.edu';
ls_subject               varchar2(600) := 'Award Accounts Subject to E-Verify Certification' ;
mesg                     CLOB;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
li_notification_type_id notification_type.notification_type_id% type := null;
ls_document_number award.document_number% type;

cursor cur_get_recipients is 
    select distinct RECIPIENT_EMAIL 
    from EVERIFY_NOTIF_DETAILS
    where NOTIFICATION_ID = gl_NofificationId
        and substr(AWARD_NUMBER,1,6) = substr(as_award_num,1,6) 
        and RECIPIENT_EMAIL != 'kc-mit-dev@mit.edu';
        
cursor cur_get_award_account is 
    select distinct AWARD_NUMBER ,FN_GET_ACCOUNT_FOR_AWARD(AWARD_NUMBER)
    from EVERIFY_NOTIF_DETAILS  
    where NOTIFICATION_ID = gl_NofificationId
        and substr(AWARD_NUMBER,1,6) = substr(as_award_num,1,6) 
        order by AWARD_NUMBER;
		
cursor cur_get_pers_for_kc_wf is 
    select distinct AWARD_NUMBER ,RECIPIENT_ID,MAIL_SENT_STATUS
    from EVERIFY_NOTIF_DETAILS  
    where NOTIFICATION_ID = gl_NofificationId
        and substr(AWARD_NUMBER,1,6) = substr(as_award_num,1,6) 
        order by AWARD_NUMBER;		
		
rec_get_pers_for_kc_wf cur_get_pers_for_kc_wf%rowtype;
li_notification_is_active pls_integer;
begin

	li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,1,'601');
	if li_notification_is_active = 1 then
	
    open cur_get_recipients;
        loop
            fetch cur_get_recipients into ls_email_address;
            exit when cur_get_recipients%NOTFOUND;

            if ls_recipients is null then
                ls_recipients := ls_email_address;
            else
                 ls_recipients := ls_recipients || ',' ||ls_email_address;
            end if;
        
        end loop;
    close cur_get_recipients;
    

    open  cur_get_award_account;
        loop
            fetch cur_get_award_account into ls_MITAwardNumber, ls_AccountNUmber;
            EXIT WHEN cur_get_award_account%NOTFOUND;
            if li_first = 0 then -- first row from the table
                if substr(ls_MITAwardNumber,-5,5) <> '00001' then
                mesg := '<tr>
                    <td>' || substr(as_award_num,1,6) || '-00001' || '</td>
                    <td>' || FN_GET_ACCOUNT_FOR_AWARD(substr(as_award_num,1,6) || '-00001') || '</td>
                   </tr>';
                                 
                end if;
                mesg := '<tr>
                    <td>' || ls_MITAwardNumber || '</td>
                    <td>' || ls_AccountNUmber || '</td>
                   </tr>';              
                li_first := 1;
            else
                mesg := '<tr>
                    <td>' || ls_MITAwardNumber || '</td>
                    <td>' || ls_AccountNUmber || '</td>
                   </tr>';
            end if;
            
        end loop;
    close cur_get_award_account;  
	
		-- sending email start
		begin
			 KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,1,601,mail_subject,mail_message);
			 mail_message := replace(mail_message, '{AWARD_LIST}',mesg );	
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_recipients,null,NULL,mail_subject,mail_message);	
		exception
		when others then
			UPDATE EVERIFY_NOTIF_DETAILS SET MAIL_SENT_STATUS = 'N'
			where NOTIFICATION_ID = gl_NofificationId;			
		 
		end; 
		-- sending email end
		
		
			begin			
				select NOTIFICATION_TYPE_ID into li_notification_type_id
				from NOTIFICATION_TYPE
				where MODULE_CODE = 1
				and ACTION_CODE		= 601;
				
			exception
			when others then
			li_notification_type_id := null;
			end;
		 
		
		-- inserting into KC tables START
	    li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'EVERIFY',mail_message);
		
    	open  cur_get_pers_for_kc_wf;
        loop
            fetch cur_get_pers_for_kc_wf into rec_get_pers_for_kc_wf;
            EXIT WHEN cur_get_pers_for_kc_wf%NOTFOUND;
			
			begin
				 if li_ntfctn_id <>  -1 then 
						KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,rec_get_pers_for_kc_wf.RECIPIENT_ID,rec_get_pers_for_kc_wf.MAIL_SENT_STATUS);
						
				end if;		
			exception
			when others then
			NULL;
			end; 
					
			
        end loop;
      close cur_get_pers_for_kc_wf;  
	
	end if;	
	-- inserting into KC tables END
		
	
    return 1;         
               
    
end fn_send_everify_email;

/******************************************************************************/
function fn_get_account_for_award
   ( AW_MIT_AWARD_NUMBER IN award.award_number%TYPE )
	RETURN varchar2
/******************************************************************************/
IS
	var_account_num award.account_number%TYPE;

BEGIN
   SELECT account_number
	INTO	 var_account_num
	FROM   award
	WHERE ltrim(rtrim(AWARD_NUMBER)) = ltrim(rtrim(AW_MIT_AWARD_NUMBER))
  		AND sequence_number IN  ( SELECT MAX(A.SEQUENCE_NUMBER)   FROM AWARD A   WHERE A.AWARD_NUMBER = AWARD.AWARD_NUMBER);

	RETURN (var_account_num) ;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN (var_account_num) ;

END;

end;
/