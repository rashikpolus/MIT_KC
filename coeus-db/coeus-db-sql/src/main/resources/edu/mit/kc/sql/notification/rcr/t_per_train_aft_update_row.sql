CREATE OR REPLACE TRIGGER t_per_train_aft_update_row
after UPDATE on PERSON_TRAINING for each row

declare

li_rc                 number;

ls_PersonId  PERSON_TRAINING.PERSON_ID%type;
li_TrainingCode PERSON_TRAINING.TRAINING_CODE%type;

ldt_Submitted   PERSON_TRAINING.DATE_SUBMITTED%type;
ldt_Acknowledged   PERSON_TRAINING.DATE_ACKNOWLEDGED%type;


ldt_SubmittedOld   PERSON_TRAINING.DATE_SUBMITTED%type;
ldt_AcknowledgedOld   PERSON_TRAINING.DATE_ACKNOWLEDGED%type;

ll_count    number;


begin

    ls_PersonId := :new.PERSON_ID;
    li_TrainingCode := :new.TRAINING_CODE;
    
    select count(*) 
    into ll_Count
    from training_modules
    where TRAINING_CODE = li_TrainingCode
    and MODULE_CODE = 100;	
	
    ldt_Submitted := :new.DATE_SUBMITTED;
    ldt_Acknowledged := :new.DATE_ACKNOWLEDGED;
    
    ldt_SubmittedOld := :old.DATE_SUBMITTED;
    ldt_AcknowledgedOld := :old.DATE_ACKNOWLEDGED;
    
    
    if ll_Count > 0 and (((ldt_SubmittedOld is null) and (ldt_Submitted is not null)) OR
            ((ldt_AcknowledgedOld is null) and (ldt_Acknowledged is not null)) ) then
        li_rc := KC_RCR_NOTIFCATIONS_PKG.fn_rcr_tr_compl_notif(ls_PersonId, li_TrainingCode );
    end if;

exception
    when others then
        --raise_application_error(-20100, 'Error generating notification' || SQLERRM);
        li_rc := 0;

end;
/