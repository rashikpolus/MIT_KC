DECLARE
li_return Number;
li_number Number;
ldt_LastRunDate     EVERIFY_NOTIFICATIONS.UPDATE_TIMESTAMP%type; 
li_id NUMBER(12,0);
BEGIN
select UPDATE_TIMESTAMP
        into ldt_LastRunDate
        from EVERIFY_NOTIFICATIONS
        where NOTIFICATION_ID = (select max(NOTIFICATION_ID) from EVERIFY_NOTIFICATIONS);
        
 select id into li_id  from custom_attribute where name = 'E-VERIFY'; 
 
 UPDATE AWARD_CUSTOM_DATA
 SET VALUE='No'
 WHERE CUSTOM_ATTRIBUTE_ID=li_id;
 
 UPDATE AWARD_CUSTOM_DATA
 SET VALUE='Yes'
 WHERE AWARD_NUMBER='017716-00004'
 AND SEQUENCE_NUMBER=4
 AND CUSTOM_ATTRIBUTE_ID=li_id;
 
  delete from  EVERIFY_NOTIF_DETAILS where award_number='017716-00004';
 
 delete from  SAP_FEED_DETAILS where FEED_ID = '666666';

 Insert into SAP_FEED_DETAILS (FEED_ID,AWARD_NUMBER,SEQUENCE_NUMBER,FEED_TYPE,FEED_STATUS,BATCH_ID,UPDATE_USER,UPDATE_TIMESTAMP,TRANSACTION_ID,VER_NBR,OBJ_ID) 
values (666666,'017716-00004',4,'C','F',209,'BARRIGAR',ldt_LastRunDate,'0000320265',1,sys_guid());

li_return:=KC_E_VERIFY_NOTIF_PKG.fn_gen_e_verify_emails();
dbms_output.put_line(li_return);
rollback;
END;
/