Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','KC_DB_MAIL_HOST',sys_guid(),1,'CONFG','outgoing.mit.edu','A','Set mail host for notificaion sent from DB','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID) 
values ('KC-GEN','All','KC_DB_MAIL_PORT',sys_guid(),1,'CONFG','25','A','Set mail port for notificaion sent from DB','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','KC_DB_SENDER_ID',sys_guid(),1,'CONFG','kc-notifications@mit.edu','A','Set sender id for DB notification','KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,EVAL_OPRTR_CD,PARM_DESC_TXT,APPL_ID)
values ('KC-GEN','All','KC_DB_REPLY_ID',sys_guid(),1,'CONFG','kc-notifications@mit.edu','A','Set reply to id for DB notification','KC')
/
-- new added start
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'EMAIL_NOTIFICATION_FROM_ADDRESS' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS' and NMSPC_CD='KR-WKFLW'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'FROM_ADDRESS' and NMSPC_CD='KR-WKFLW'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'LOOKUP_CONTACT_EMAIL' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'Y' WHERE PARM_NM = 'EMAIL_NOTIFICATIONS_ENABLED' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET PARM_NM = 'EMAIL_NOTIFICATIONS_TEST_ENABLED' WHERE PARM_NM = 'EMAIL_NOTIFICATION_TEST_ENABLED' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'Y' WHERE PARM_NM = 'EMAIL_NOTIFICATIONS_TEST_ENABLED' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = '0 */10 * * * ?' WHERE PARM_NM = 'REPORT_TRACKING_NOTIFICATIONS_BATCH_CRON_TRIGGER'
/
delete from kc_qrtz_cron_triggers where trigger_name='citiTrainingDataFeedTrigger'
/
delete from kc_qrtz_triggers where trigger_name='citiTrainingDataFeedTrigger'
/
delete from kc_qrtz_job_details where job_name='citiTrainingDataFeedJobDetail'
/
UPDATE KRCR_PARM_T SET VAL = '0 0 7,19 * * ?' WHERE PARM_NM = 'CITI_TRAINING_DATA_FEED_CRON_TRIGGER'
/
UPDATE KRCR_PARM_T SET VAL = 'N' WHERE PARM_NM = 'ENABLE_CITI_TRAINING_DATA_FEED'
/
UPDATE KRCR_PARM_T SET VAL = 'Y' WHERE PARM_NM = 'SEND_EMAIL_NOTIFICATION_IND'
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,PARM_DESC_TXT,EVAL_OPRTR_CD,APPL_ID) values ('KC-GEN','Document','KC_COI_DB_LINK',sys_guid(),1,'AUTH','COEUS.KUALI','DB Link to connect with Coeus DB to get the COI Functions','A','KUALI')
/
UPDATE KRCR_PARM_T SET VAL = 'COEUS.KUALI',PARM_DESC_TXT =  'DB Link to connect with Coeus DB to get the COI Functions' WHERE NMSPC_CD = 'KC-GEN' AND PARM_NM = 'KC_COI_DB_LINK'
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-GEN', 'Document', 'disableAttachmentRemoval', SYS_GUID(), '1', 'CONFG', 'Y', 'Disable Attachment Removal', 'A', 'KC')
/
Insert into KRCR_PARM_T (NMSPC_CD,CMPNT_CD,PARM_NM,OBJ_ID,VER_NBR,PARM_TYP_CD,VAL,PARM_DESC_TXT,EVAL_OPRTR_CD,APPL_ID) values ('KC-GEN','Document','ENABLE_SEP_LINK',sys_guid(),1,'AUTH','Y','Parameter for enabling Single Point Entry menu under Proposal Budget','A','KUALI')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_ANIMAL_REVIEW_VALID', SYS_GUID(), '1', 'CONFG', '1', 'Specifies Animal Usage Special Review Status.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_BIOHAZARD_REVIEW_VALID', SYS_GUID(), '1', 'CONFG', '1', 'Specifies Biohazard Materials Special Review Status.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_HUMAN_REVIEW_VALID', SYS_GUID(), '1', 'CONFG', '1', 'Specifies Human Subjects  Special Review Status.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_DNA_REVIEW_VALID', SYS_GUID(), '1', 'CONFG', '1', 'Specifies Recombinant DNA  Special Review Status.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_ISOTOPE_REVIEW_VALID', SYS_GUID(), '1', 'CONFG', '1', 'Specifies Radioactive Isotopes Special Review Status.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_INTER_REVIEW_VALID', SYS_GUID(), '1', 'CONFG', '1', 'Specifies International Programs  Special Review Status.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'AWARD_ON_HOLD_BASED_ON_COI' , SYS_GUID(), '1', 'CONFG', 'Y', 'This is the decide whether Award Hold Prompt is enabled for COI/Financial Dsiclosures.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_NSF_RCR_REVIEW_VALID' , SYS_GUID(), '1', 'CONFG', 'Y', 'This is the decide whether Award Hold Prompt is needed to trigger if NSF is sponsor.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_REPORT_VALIDATION' , SYS_GUID(), '1', 'CONFG', 'Y', 'This is the decide whether Award Hold Prompt is needed to trigger if  Lead Unit PI has a Final Technical Report.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_TERM_REVIEW_VALID' , SYS_GUID(), '1', 'CONFG', 'Y', 'This is the decide whether Award Hold Prompt is needed to trigger if If award term (143) is missing when Animal and/or Human subjects special reviews are present.If value of the parameter is N, this hold prompt is off.', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'ENABLE_AWARD_VALIDATIONS' , SYS_GUID(), '1', 'CONFG', 'Y', 'Turning on (1) or off (0) of this parameter will turn on /off all the triggers for Hold prompt irrespective of the individual parameter values', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'IACUC_SPL_REV_TYPE_CODE' , SYS_GUID(), '1', 'CONFG', '2', 'IACUC Special Review Type Code', 'A', 'KC')
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-AWARD', 'Document', 'SPL_REV_TYPE_CODE_HUMAN' , SYS_GUID(), '1', 'CONFG', '1', 'Special Review Type Code for Human', 'A', 'KC')
/
UPDATE KRCR_PARM_T set VAL ='1' WHERE  PARM_NM='ENABLE_ANIMAL_REVIEW_VALID'
/
UPDATE KRCR_PARM_T set VAL ='1' WHERE  PARM_NM='ENABLE_AWARD_BIOHAZARD_REVIEW_VALID'
/
UPDATE KRCR_PARM_T set VAL ='1' WHERE  PARM_NM='ENABLE_AWARD_HUMAN_REVIEW_VALID'
/
UPDATE KRCR_PARM_T set VAL ='1' WHERE  PARM_NM='ENABLE_AWARD_DNA_REVIEW_VALID'
/
UPDATE KRCR_PARM_T set VAL ='1' WHERE  PARM_NM='ENABLE_AWARD_ISOTOPE_REVIEW_VALID'
/
UPDATE KRCR_PARM_T set VAL ='1' WHERE  PARM_NM='ENABLE_AWARD_INTER_REVIEW_VALID'
/
UPDATE KRCR_PARM_T set VAL ='Y' WHERE  PARM_NM='AWARD_ON_HOLD_BASED_ON_COI'
/
UPDATE KRCR_PARM_T set VAL ='Y' WHERE  PARM_NM='ENABLE_AWARD_NSF_RCR_REVIEW_VALID'
/
UPDATE KRCR_PARM_T set VAL ='Y' WHERE  PARM_NM='ENABLE_AWARD_REPORT_VALIDATION'
/
UPDATE KRCR_PARM_T set VAL ='Y' WHERE  PARM_NM='ENABLE_AWARD_VALIDATIONS'
/
UPDATE KRCR_PARM_T set VAL ='2' WHERE  PARM_NM='IACUC_SPL_REV_TYPE_CODE'
/
UPDATE KRCR_PARM_T set VAL ='1' WHERE  PARM_NM='SPL_REV_TYPE_CODE_HUMAN'
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID) VALUES ('KC-GEN', 'All', 'ALL_SPONSOR_HIERARCHY_NIH_MULTI_PI', SYS_GUID(), '1', 'CONFG', 'NIH Multiple PI', 'The name of Sponsors Hierarchy', 'A', 'KC')
/
--UPDATE KRCR_PARM_T SET VAL = 'N' WHERE PARM_NM = 'REPORT_TRACKING_NOTIFICATIONS_BATCH_ENABLED'
--/
--UPDATE KRCR_PARM_T SET VAL = 'quickstart' WHERE PARM_NM = 'REPORT_TRACKING_NOTIFICATIONS_BATCH_RECIPIENT'
--/
--UPDATE KRCR_PARM_T SET VAL = 'K' WHERE PARM_NM = 'SEND_NOTE_WORKFLOW_NOTIFICATION_ACTIONS'
--/
--UPDATE KRCR_PARM_T SET VAL = '1' WHERE PARM_NM = 'SIMPLE_NOTIFICATION_CONTENT_TYPE_ID'
--/
--UPDATE KRCR_PARM_T SET VAL = '1000' WHERE PARM_NM = 'SYSTEM_NOTIFICATION_PRODUCER_ID'
--/
