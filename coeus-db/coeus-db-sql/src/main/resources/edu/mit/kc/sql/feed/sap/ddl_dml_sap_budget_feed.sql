drop table sap_bud_rate_class_gl_mapping
/
create table sap_bud_rate_class_gl_mapping(
  rate_class_code	varchar2(3),
  on_off_campus_flag	char(1),
  gl_account_key	varchar2(10),
  CONSTRAINT sap_bud_rate_class_gl_map_uk UNIQUE (rate_class_code,on_off_campus_flag)
)
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('1','N', '600304-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES( '1','F','600305-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('2','N', '600304-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('2','F', '600305-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('3','N', '600304-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('3','F', '600305-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('4','N', '600400-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('4','F' , '600400-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('5','N', '600204-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('5','F', '600205-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('8','N', '600236-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('8','F' , '600237-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('10','N', '600100-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('10','F', '600101-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('11','N', '600104-001' )
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('11','F', '600105-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES( '12','N' , '600106-001')
/
INSERT INTO sap_bud_rate_class_gl_mapping(rate_class_code,on_off_campus_flag,gl_account_key)
VALUES('12','F', '600107-001')
/

create table sap_kc_obj_cd_mapping(
  KC_OBJ_CD	varchar2(10),
  KC_OBJ_CD_DESC	varchar2(100),
  SAP_OBJ_CD	varchar2(10) 
)
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00005','Senior Personnel (Summer Months)','400005')
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00025', 'Senior Personnel (Academic Months)', '400025' )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00300' ,'Senior Personnel (Calendar Months)' ,'400300' )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES('P00390', 'Postdocs', '400390 ' )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00350', 'Other Professionals', '400350'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00706' ,'Graduate Students (Research Assistants)', '400706'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00754', 'Undergraduate Students (UROPs, etc)', '400754'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00250' ,'Secretarial-Clerical (if charged directly)', '400250'  )
/
INSERT INTO sap_kc_obj_cd_mapping(kc_obj_cd, kc_obj_cd_desc, sap_obj_cd)
VALUES( 'P00001', 'Other Personnel Costs', '422163'  )
/
commit
/
CREATE TABLE SAP_BUDGET_FEED(
SAP_BUDGET_FEED_ID NUMBER(12),
SAP_BUDGET_FEED_DETAILS_ID NUMBER(10),
SAP_BUDGET_FEED_BATCH_ID NUMBER(12),
BATCH_ID NUMBER(3),
FISCAL_YEAR VARCHAR2(4),
ACCOUNT_NUMBER VARCHAR2(12),
COST_ELEMENT VARCHAR2(10),
AMOUNT VARCHAR2(15),
VER_NBR NUMBER(8),
OBJ_ID VARCHAR2(36)
)
/
CREATE TABLE SAP_BUDGET_FEED_BATCH_LIST(
SAP_BUDGET_FEED_BATCH_ID NUMBER(12),
BATCH_ID NUMBER(3),
BATCH_FILE_NAME VARCHAR2(30),
BATCH_TIMESTAMP DATE,
UPDATE_USER VARCHAR2(8),
NO_OF_RECORDS NUMBER(5),
UPDATE_TIMESTAMP DATE,
VER_NBR NUMBER(8),
OBJ_ID VARCHAR2(36)
)
/
CREATE TABLE SAP_BUDGET_FEED_DETAILS(
SAP_BUDGET_FEED_DETAILS_ID NUMBER(10),
SAP_BUDGET_FEED_BATCH_ID NUMBER(12),
BATCH_ID NUMBER(3),
BUDGET_ID NUMBER(12),
AWARD_NUMBER VARCHAR2(12),
SEQUENCE_NUMBER NUMBER(4),
FEED_STATUS CHAR(1),
UPDATE_USER VARCHAR2(8),
UPDATE_TIMESTAMP DATE,
VER_NBR NUMBER(8),
OBJ_ID VARCHAR2(36)
)
/
INSERT INTO KRCR_PARM_T(NMSPC_CD, CMPNT_CD, PARM_NM, OBJ_ID, VER_NBR, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, APPL_ID)
 VALUES ('KC-GEN', 'All', 'SAP_AWD_BUD_FEED_STATUS', SYS_GUID(), '1', 'CONFG', '10', 'This is the comma seperated values of the award budget status, these status is used to recognize the feed to know the pending feeds.', 'A', 'KC')
/
CREATE SEQUENCE SEQ_SAP_BUDGET_FEED_BATCH_ID
START WITH 1
MAXVALUE 9999999999
MINVALUE 1
NOCYCLE
NOCACHE
NOORDER
/
CREATE SEQUENCE SEQ_SAP_BUDGET_FEED_DETAILS_ID
START WITH 1
MAXVALUE 9999999999
MINVALUE 1
NOCYCLE
NOCACHE
NOORDER
/
CREATE SEQUENCE SEQ_SAP_BUDGET_FEED_ID
START WITH 1
MAXVALUE 9999999999
MINVALUE 1
NOCYCLE
NOCACHE
NOORDER
/
