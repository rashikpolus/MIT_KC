/* 
 * RCR NOTIFICATION 1 with RCR_NOTIF_TYPE_CODE = 1
 */
declare
li_return NUMBER;
begin
li_return := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(1);
end;
--------------------------------------------------------------------------------
/
/* 
 * RCR NOTIFICATION 2 with RCR_NOTIF_TYPE_CODE = 2
 */
declare
li_return NUMBER;
begin
li_return := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(2);
end;
/
--------------------------------------------------------------------------------

/* 
 * RCR NOTIFICATION 3 with RCR_NOTIF_TYPE_CODE = 3
 */
declare
li_return NUMBER;
begin
li_return := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(3);
end;
--------------------------------------------------------------------------------
/
/* 
 * RCR NOTIFICATION 4 with RCR_NOTIF_TYPE_CODE = 4
 */
declare
li_return NUMBER;
begin
li_return := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(4);
end;
--------------------------------------------------------------------------------
/

/* 
 * RCR NOTIFICATION 5 with RCR_NOTIF_TYPE_CODE = 5
 */
declare
li_return NUMBER;
begin
li_return := KC_RCR_NOTIFCATIONS_PKG.fn_send_notification(5);
end;
/
--------------------------------------------------------------------------------
/*  RCR NOTIFICATION 6
 * To test the training completion notification , the below insert will 
 * fire the trigger t_per_train_aft_insert_row.sql
 */
delete from PERSON_TRAINING where person_id ='922751800';
INSERT INTO PERSON_TRAINING(PERSON_TRAINING_ID,
		 PERSON_ID,
		 TRAINING_NUMBER,
		 TRAINING_CODE,	
     DATE_SUBMITTED,
		 UPDATE_TIMESTAMP,
		 UPDATE_USER,
		 VER_NBR,
		 OBJ_ID ) 
SELECT SEQ_PERSON_TRAINING_ID.NEXTVAL,
		 '922751800',--geot
		(select nvl(max(training_number),0) + 1 from person_training
      where person_id = '922751800' ) AS TRAINING_NUMBER,
		 50,		
     sysdate,
		 sysdate,
		 user,
		 1,
		 SYS_GUID()
from dual;
--------------------------------------------------------------------------------
/* RCR NOTIFICATION 6
 * To test the training completion notification , the below insert will fire the 
 * trigger t_per_train_aft_update_row.sql
 */
update PERSON_TRAINING set DATE_ACKNOWLEDGED = sysdate where  person_id ='922751800';
--------------------------------------------------------------------------------
/
