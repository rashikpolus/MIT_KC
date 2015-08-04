create or replace
FUNCTION fn_update_long_survey_notif 
(
  AS_NEG_ID IN VARCHAR2  
, AS_PI_ID IN VARCHAR2  
, AS_SURVEY_ID IN VARCHAR2  
, AS_NEG_CLOSE_DATE IN DATE
, AS_NOTIFIED_FLAG IN VARCHAR2
, AS_NOTIFICATION_DATE IN DATE
) RETURN NUMBER AS 

var_count number;

BEGIN

select count(*) into var_count from LONG_SURVEY_NOTIF where PI_ID = AS_PI_ID and NEGOTIATION_ID = AS_NEG_ID;

if var_count = 0 then
insert into LONG_SURVEY_NOTIF (LONG_SURVEY_NOTIF_ID,NEGOTIATION_ID, pi_id, negotiation_close_date, notified_flag, notification_date, survey_id, SURVEY_COMPLETION_DATE)
values(SEQ_LONG_SURVEY_NOTIF_ID.nextval,AS_NEG_ID , AS_PI_ID, AS_NEG_CLOSE_DATE, AS_NOTIFIED_FLAG, AS_NOTIFICATION_DATE,  AS_SURVEY_ID, SYSDATE);
else 
update LONG_SURVEY_NOTIF set 
SURVEY_COMPLETION_DATE = SYSDATE,
SURVEY_ID = AS_SURVEY_ID
where PI_ID = AS_PI_ID and NEGOTIATION_ID = AS_NEG_ID;
end if;

commit;
	return 0;
  
END fn_update_long_survey_notif;
/