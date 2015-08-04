INSERT INTO COEUS_MODULE(
	MODULE_CODE,
	DESCRIPTION,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID
)
VALUES(
	102,
	'CITI',
	sysdate,
	user,
	1,
	sys_guid()
)
/
INSERT INTO NOTIFICATION_TYPE(
	NOTIFICATION_TYPE_ID,
	MODULE_CODE,
	ACTION_CODE,
	DESCRIPTION,
	SUBJECT,
	MESSAGE,
	PROMPT_USER,
	SEND_NOTIFICATION,
	UPDATE_USER,
	UPDATE_TIMESTAMP,
	VER_NBR,
	OBJ_ID
)
VALUES(SEQ_NOTIFICATION_TYPE_ID.NEXTVAL,
	102,
	'501',
	'CITI daily dataload completion report',
	'CITI daily dataload completion report for ',
	'<p>Dear CITI Team,  </p>'||CHR( 13 ) || CHR( 10 )||
	'Citi training data has been populated with following details:<br>',
	'N',
	'Y',
	user,
	sysdate,
	1,
	sys_guid()
)
/
delete from kc_qrtz_cron_triggers where trigger_name='citiTrainingDataFeedTrigger'
/
delete from kc_qrtz_triggers where trigger_name='citiTrainingDataFeedTrigger'
/
delete from kc_qrtz_job_details where job_name='citiTrainingDataFeedJobDetail'
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,PARM_DESC_TXT,EVAL_OPRTR_CD,APPL_ID) 
	values ('KC-ADM','All','CITI_TRAINING_DATA_FEED_CRON_TRIGGER',SYS_GUID(),1,'CONFG','0 0 7,19 * * ?','Cron expression for Citi feed','A','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,PARM_DESC_TXT,EVAL_OPRTR_CD,APPL_ID) 
	values ('KC-ADM','All','ENABLE_CITI_TRAINING_DATA_FEED',SYS_GUID(),1,'CONFG','Y','Citi training feed enable flag','A','KC')
/
commit
/
