CREATE OR REPLACE TRIGGER T_KP_CONFIRM_AFT_INSERT_ROW 
after insert on AWARD_KEY_PERS_CONFIRM for each row

declare

ls_recipient        KRIM_ROLE_MBR_T.MBR_ID%TYPE;
ls_message            VARCHAR2(2000);
li_rc                 number;
ls_PersonName        VARCHAR2(120);
li_Count                number;
li_KP_Needs_COI         number;
li_COI_Complete         number;
li_Training_Complete    number;
ll_coi_disp_code        COI_DISCLOSURE.DISCLOSURE_DISPOSITION_CODE%type;
ll_coi_rev_code         COI_DISCLOSURE.REVIEW_STATUS_CODE%type;
ll_COIBasedOnCustomData number;
li_NeedsCOI             number;
li_IsPCK                number;
ls_error_message        VARCHAR2(250):=NULL;
li_mail_send CHAR(1);
ls_TestMailReceiver    varchar2(256);       

/** Case 185 Begin **/


ls_ModuleItemKey        AWARD.AWARD_NUMBER%TYPE;
ls_PersonId             AWARD_PERSONS.PERSON_ID%TYPE;
ls_disc_num         	COI_DISCLOSURE.COI_DISCLOSURE_NUMBER%TYPE;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
li_notification_type_id notification_type.notification_type_id% type;

error_inserting         EXCEPTION;


begin
    
    ls_ModuleItemKey :=  :new.AWARD_NUMBER;
    ls_PersonId    := :new.PERSON_ID;
    
    --Send notification only if person id is not ('000000000' or '999999999'
    if ls_PersonId in ('999999999', '000000000') then
        return; 
    end if;
    
    ll_COIBasedOnCustomData := kc_kp_notifications_pkg.fn_get_awd_custom_data(ls_ModuleItemKey, 'COI_REQUIREMENT');
    
    -- fn_check_coi_hierarchy return -1 if COI is not needed for this award
     --  Returns 1 if KP does nto have to do COI
     -- return 2 if Key persons needs to do COI
     
    li_KP_Needs_COI := kc_kp_notifications_pkg.fn_check_coi_hierarchy(ls_ModuleItemKey);
    
    if (li_KP_Needs_COI <> 2) and (ll_COIBasedOnCustomData <> 3) then
        return;
    end if;
    
    li_COI_Complete := 0;
    
    if li_KP_Needs_COI = 2 then
        li_NeedsCOI := 1;
    else
        li_NeedsCOI := 0;
    end if;
    
    if ll_COIBasedOnCustomData = 3 then
        li_IsPCK := 1;
    else
        li_IsPCK := 0;
    end if;  
    
    --Check if the person has submitted a disclosure for any award in this hierarchy.
    --review status code should be somthing other than 1.
    
       begin

     select D.DISCLOSURE_DISPOSITION_CODE, D.REVIEW_STATUS_CODE
     into   ll_coi_disp_code, ll_coi_rev_code
     from osp$coi_disclosure@coeus.kuali d,
        (select distinct DD.COI_DISCLOSURE_NUMBER, DD.SEQUENCE_NUMBER
         from   osp$coi_disc_details@coeus.kuali dd
         where  dd.MODULE_CODE = 1
         and    dd.MODULE_ITEM_KEY like  substr(ls_ModuleItemKey, 1, 6) || '%'
         and    DD.SEQUENCE_NUMBER = (select max(DD2.SEQUENCE_NUMBER)
                                     from   osp$coi_disc_details@coeus.kuali dd2
                                     where  DD.COI_DISCLOSURE_NUMBER = DD2.COI_DISCLOSURE_NUMBER
                                     and    DD.MODULE_ITEM_KEY = DD2.MODULE_ITEM_KEY)) discl
         where D.PERSON_ID =  ls_PersonId
         and   D.COI_DISCLOSURE_NUMBER = discl.COI_DISCLOSURE_NUMBER
         and   D.SEQUENCE_NUMBER = discl.SEQUENCE_NUMBER;



           if (ll_coi_rev_code <> 1) then
             -- person has submited the disclosure
               li_COI_Complete := 1;
			   
           end if;


    exception
         when others then
           li_COI_Complete := 0;
		   ls_error_message:= substr(sqlerrm,1,200);
    end;
    
	-- Sent notification if not COI synced START	
			if li_COI_Complete= 0 then
			
			   BEGIN
					select VAL into ls_TestMailReceiver
					from KRCR_PARM_T
					where PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS'
					AND  nmspc_cd ='KC-GEN';
				EXCEPTION
				WHEN OTHERS THEN
				raise_application_error(-20101, 'Error Generating Email. Parameter EMAIL_NOTIFICATION_TEST_ADDRESS not found in parameter table' );
					return;
				END;
			   mail_subject:= 'COI not in sync';
			   mail_message:='COI Disclosure from coeus not synced with KC and the error message is:'||CHR(13)||ls_error_message;			
			   li_mail_send := 'Y';
				begin
					 KC_MAIL_GENERIC_PKG.SEND_MAIL(-999,ls_TestMailReceiver,null,ls_TestMailReceiver,mail_subject,mail_message);

				exception
				when others then
					li_mail_send := 'N';
				end;
				 /* intentionaly commented
				begin
					li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN('KP Notification',mail_message);
					KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_ntfctn_id,ls_TestMailReceiver,li_mail_send);
				exception
				when others then
					null;
				end;
				intentionaly commented
				 */
			end if;
	-- Sent notification if not COI synced END	
	
    --Check if the person has completed COI training
    li_Training_Complete := 0;
    
    begin

         select count(*)
         into  li_count
         from PERSON_TRAINING t
         where T.PERSON_ID = ls_PersonId
         and   T.TRAINING_CODE = 54
         and   T.FOLLOWUP_DATE > sysdate;

     if (li_count > 0) then
      --Training Complete
        li_Training_Complete := 1;  
     end if;
    
    exception
        when others then
            li_Training_Complete := 0;

    end;
    
    if (li_COI_Complete = 1) and (li_Training_Complete = 1) then
        -- Person has comleted training and COI
        -- No need to send notification
         
        Return;
        
    end if;
    
    
    li_rc := kc_kp_notifications_pkg.fn_gen_kp_coi_notification (ls_PersonId, ls_ModuleItemKey, li_COI_Complete, li_Training_Complete, li_NeedsCOI, li_IsPCK );
        
    

exception
    when error_inserting then
        raise_application_error(-20100, 'Error generating notifications' || SQLERRM);
    when others then
        raise_application_error(-20100, 'Error generating notifications' || SQLERRM);

end;
/