UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'EMAIL_NOTIFICATION_FROM_ADDRESS' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'EMAIL_NOTIFICATION_TEST_ADDRESS' and NMSPC_CD='KR-WKFLW'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-help@mit.edu' WHERE PARM_NM = 'FROM_ADDRESS' and NMSPC_CD='KR-WKFLW'
/
UPDATE KRCR_PARM_T SET VAL = 'kc-notifications@mit.edu' WHERE PARM_NM = 'LOOKUP_CONTACT_EMAIL' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'Y' WHERE PARM_NM = 'EMAIL_NOTIFICATIONS_ENABLED' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = 'Y' WHERE PARM_NM = 'EMAIL_NOTIFICATIONS_TEST_ENABLED' and NMSPC_CD='KC-GEN'
/
UPDATE KRCR_PARM_T SET VAL = '0 22 * * * ?' WHERE PARM_NM = 'REPORT_TRACKING_NOTIFICATIONS_BATCH_CRON_TRIGGER'
/
UPDATE KRCR_PARM_T SET VAL = 'N' WHERE PARM_NM = 'ENABLE_CITI_TRAINING_DATA_FEED'
/
UPDATE KRCR_PARM_T SET VAL = 'Y' WHERE PARM_NM = 'SEND_EMAIL_NOTIFICATION_IND'
/