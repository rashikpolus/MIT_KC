set define off
ALTER TABLE KRMS_NL_TMPL_T ADD ACTV VARCHAR2(1) DEFAULT 'Y' NOT NULL
/
UPDATE KRCR_PARM_T SET VAL = 'http://site.kuali.org/rice/${rice.version}/reference/html/Help.html#lookup'
WHERE APPL_ID = 'KUALI' AND NMSPC_CD = 'KR-KRAD' AND CMPNT_CD = 'Lookup' AND PARM_NM = 'DEFAULT_HELP_URL'
/
INSERT INTO KRCR_PARM_T (APPL_ID, NMSPC_CD, CMPNT_CD, PARM_NM, VAL, PARM_DESC_TXT, PARM_TYP_CD, EVAL_OPRTR_CD, OBJ_ID, VER_NBR)
    SELECT 'KUALI', 'KR-NS', 'All', 'DEFAULT_COUNTRY', 'US', 'Used as the default country code when relating records that do not have a country code to records that do have a country code, e.g. validating a zip code where the country is not collected.', 'CONFG', 'A', SYS_GUID(), 1 FROM dual
    WHERE NOT EXISTS (SELECT 1 FROM KRCR_PARM_T WHERE NMSPC_CD = 'KR-NS' AND CMPNT_CD = 'All' AND PARM_NM = 'DEFAULT_COUNTRY')
/
DELETE FROM KRIM_ROLE_PERM_T
WHERE ROLE_ID = (SELECT ROLE_ID FROM KRIM_ROLE_T WHERE NMSPC_CD = 'KR-RULE' AND ROLE_NM = 'Kuali Rules Management System Administrator')
AND PERM_ID = (SELECT PERM_ID FROM KRIM_PERM_T WHERE NMSPC_CD = 'KR-RULE-TEST' AND NM = 'Maintain KRMS Agenda')
/

DELETE FROM KRIM_PERM_T WHERE NMSPC_CD = 'KR-RULE-TEST' AND NM = 'Maintain KRMS Agenda'
/
alter table KREW_PPL_FLW_MBR_T add FRC_ACTN NUMBER(1) default 1 NOT NULL
/
INSERT INTO KRCR_PARM_T (APPL_ID, NMSPC_CD, CMPNT_CD, PARM_NM, VAL, PARM_DESC_TXT, PARM_TYP_CD, EVAL_OPRTR_CD, OBJ_ID, VER_NBR)
    VALUES ('KUALI', 'KR-KRAD', 'All', 'AUTO_TRUNCATE_COLUMNS', 'N', 'Automatically truncate text that does not fit into table columns.  A tooltip with the non-trucated text on hover over.', 'CONFG', 'A', SYS_GUID(), 1)
/
INSERT INTO KRCR_PARM_T (APPL_ID, NMSPC_CD, CMPNT_CD, PARM_NM, VAL, PARM_DESC_TXT, PARM_TYP_CD, EVAL_OPRTR_CD, OBJ_ID, VER_NBR)
    VALUES ('KUALI', 'KR-KRAD', 'Lookup', 'AUTO_TRUNCATE_COLUMNS', 'N', 'Automatically truncate text that does not fit into lookup result columns.  A tooltip with the non-trucated text on hover over.', 'CONFG', 'A', SYS_GUID(), 1)
/
commit;
