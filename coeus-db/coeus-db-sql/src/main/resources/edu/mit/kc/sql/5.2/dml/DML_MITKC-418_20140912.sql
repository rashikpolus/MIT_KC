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