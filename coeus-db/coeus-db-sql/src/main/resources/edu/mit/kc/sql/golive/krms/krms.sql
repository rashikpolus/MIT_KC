ALTER TABLE KRMS_ACTN_ATTR_T DISABLE CONSTRAINT KRMS_ACTN_ATTR_FK1
/
ALTER TABLE KRMS_ACTN_ATTR_T DISABLE CONSTRAINT KRMS_ACTN_ATTR_FK2
/
TRUNCATE TABLE KRMS_ACTN_ATTR_T
/
INSERT INTO KRMS_ACTN_ATTR_T(ACTN_ATTR_DATA_ID,ACTN_ID,ATTR_DEFN_ID,ATTR_VAL,VER_NBR)
SELECT a.ACTN_ATTR_DATA_ID,a.ACTN_ID,a.ATTR_DEFN_ID,a.ATTR_VAL,a.VER_NBR FROM KRMS_ACTN_ATTR_T@KC_STAG_DB_LINK a INNER JOIN 
KRMS_ATTR_DEFN_T@KC_STAG_DB_LINK b on a.ATTR_DEFN_ID=b.ATTR_DEFN_ID
where b.ACTV = 'Y'
/
ALTER TABLE KRMS_ACTN_T DISABLE CONSTRAINT KRMS_ACTN_FK1
/
TRUNCATE TABLE KRMS_ACTN_T
/
INSERT INTO KRMS_ACTN_T(ACTN_ID,NM,DESC_TXT,TYP_ID,RULE_ID,SEQ_NO,VER_NBR,NMSPC_CD)
SELECT a.ACTN_ID,a.NM,a.DESC_TXT,a.TYP_ID,a.RULE_ID,a.SEQ_NO,a.VER_NBR,a.NMSPC_CD FROM KRMS_ACTN_T@KC_STAG_DB_LINK a
/
ALTER TABLE KRMS_AGENDA_ATTR_T DISABLE CONSTRAINT KRMS_AGENDA_ATTR_FK1
/
ALTER TABLE KRMS_AGENDA_ATTR_T DISABLE CONSTRAINT KRMS_AGENDA_ATTR_FK2
/
TRUNCATE TABLE KRMS_AGENDA_ATTR_T
/
INSERT INTO KRMS_AGENDA_ATTR_T(AGENDA_ATTR_ID,AGENDA_ID,ATTR_VAL,ATTR_DEFN_ID,VER_NBR)
SELECT a.AGENDA_ATTR_ID,a.AGENDA_ID,a.ATTR_VAL,a.ATTR_DEFN_ID,a.VER_NBR FROM KRMS_AGENDA_ATTR_T@KC_STAG_DB_LINK a INNER JOIN 
KRMS_ATTR_DEFN_T@KC_STAG_DB_LINK b on a.ATTR_DEFN_ID=b.ATTR_DEFN_ID
where b.ACTV = 'Y'
/
ALTER TABLE KRMS_AGENDA_ITM_T DISABLE CONSTRAINT KRMS_AGENDA_ITM_FK1
/
ALTER TABLE KRMS_AGENDA_ITM_T DISABLE CONSTRAINT KRMS_AGENDA_ITM_FK2
/
ALTER TABLE KRMS_AGENDA_ITM_T DISABLE CONSTRAINT KRMS_AGENDA_ITM_FK3
/
ALTER TABLE KRMS_AGENDA_ITM_T DISABLE CONSTRAINT KRMS_AGENDA_ITM_FK4
/
ALTER TABLE KRMS_AGENDA_ITM_T DISABLE CONSTRAINT KRMS_AGENDA_ITM_FK5
/
ALTER TABLE KRMS_AGENDA_ITM_T DISABLE CONSTRAINT KRMS_AGENDA_ITM_FK6
/
TRUNCATE TABLE KRMS_AGENDA_ITM_T
/
INSERT INTO KRMS_AGENDA_ITM_T(AGENDA_ITM_ID,RULE_ID,SUB_AGENDA_ID,AGENDA_ID,VER_NBR,WHEN_TRUE,WHEN_FALSE,ALWAYS)
SELECT a.AGENDA_ITM_ID,a.RULE_ID,a.SUB_AGENDA_ID,a.AGENDA_ID,a.VER_NBR,a.WHEN_TRUE,a.WHEN_FALSE,a.ALWAYS FROM KRMS_AGENDA_ITM_T@KC_STAG_DB_LINK a
INNER JOIN 
KRMS_AGENDA_T@KC_STAG_DB_LINK b on a.AGENDA_ID=b.AGENDA_ID
where b.ACTV = 'Y'
/
ALTER TABLE KRMS_AGENDA_T DISABLE CONSTRAINT KRMS_AGENDA_FK1
/
TRUNCATE TABLE KRMS_AGENDA_T
/
INSERT INTO KRMS_AGENDA_T(AGENDA_ID,NM,CNTXT_ID,INIT_AGENDA_ITM_ID,TYP_ID,ACTV,VER_NBR)
SELECT AGENDA_ID,NM,CNTXT_ID,INIT_AGENDA_ITM_ID,TYP_ID,ACTV,VER_NBR FROM KRMS_AGENDA_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_RULE_ATTR_T DISABLE CONSTRAINT KRMS_RULE_ATTR_FK2
/
ALTER TABLE KRMS_NL_TMPL_ATTR_T DISABLE CONSTRAINT KRMS_NL_TMPL_ATTR_FK2
/
ALTER TABLE KRMS_CNTXT_ATTR_T DISABLE CONSTRAINT KRMS_CNTXT_ATTR_FK2
/
ALTER TABLE KRMS_TERM_RSLVR_ATTR_T DISABLE CONSTRAINT KRMS_TERM_RSLVR_ATTR_FK2
/
ALTER TABLE KRMS_AGENDA_ATTR_T DISABLE CONSTRAINT KRMS_AGENDA_ATTR_FK2
/
ALTER TABLE KRMS_TYP_ATTR_T DISABLE CONSTRAINT KRMS_TYP_ATTR_FK1
/
ALTER TABLE KRMS_NL_USAGE_ATTR_T DISABLE CONSTRAINT KRMS_NL_USAGE_ATTR_FK2
/
ALTER TABLE KRMS_ACTN_ATTR_T DISABLE CONSTRAINT KRMS_ACTN_ATTR_FK2
/
TRUNCATE TABLE KRMS_ATTR_DEFN_T
/
INSERT INTO KRMS_ATTR_DEFN_T(ATTR_DEFN_ID,NM,NMSPC_CD,LBL,ACTV,CMPNT_NM,VER_NBR,DESC_TXT)
SELECT ATTR_DEFN_ID,NM,NMSPC_CD,LBL,ACTV,CMPNT_NM,VER_NBR,DESC_TXT FROM KRMS_ATTR_DEFN_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_RULE_ATTR_T ENABLE CONSTRAINT KRMS_RULE_ATTR_FK2
/
ALTER TABLE KRMS_NL_TMPL_ATTR_T ENABLE CONSTRAINT KRMS_NL_TMPL_ATTR_FK2
/
ALTER TABLE KRMS_CNTXT_ATTR_T ENABLE CONSTRAINT KRMS_CNTXT_ATTR_FK2
/
ALTER TABLE KRMS_TERM_RSLVR_ATTR_T ENABLE CONSTRAINT KRMS_TERM_RSLVR_ATTR_FK2
/
ALTER TABLE KRMS_AGENDA_ATTR_T ENABLE CONSTRAINT KRMS_AGENDA_ATTR_FK2
/
ALTER TABLE KRMS_TYP_ATTR_T ENABLE CONSTRAINT KRMS_TYP_ATTR_FK1
/
ALTER TABLE KRMS_NL_USAGE_ATTR_T ENABLE CONSTRAINT KRMS_NL_USAGE_ATTR_FK2
/
ALTER TABLE KRMS_ACTN_ATTR_T ENABLE CONSTRAINT KRMS_ACTN_ATTR_FK2
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T DISABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK1
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T DISABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK2
/
TRUNCATE TABLE KRMS_CMPND_PROP_PROPS_T
/
INSERT INTO KRMS_CMPND_PROP_PROPS_T(CMPND_PROP_ID,PROP_ID)
SELECT CMPND_PROP_ID,PROP_ID FROM KRMS_CMPND_PROP_PROPS_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_CNTXT_ATTR_T DISABLE CONSTRAINT KRMS_CNTXT_ATTR_FK1
/
ALTER TABLE KRMS_CNTXT_ATTR_T DISABLE CONSTRAINT KRMS_CNTXT_ATTR_FK2
/
TRUNCATE TABLE KRMS_CNTXT_ATTR_T
/
INSERT INTO KRMS_CNTXT_ATTR_T(CNTXT_ATTR_ID,CNTXT_ID,ATTR_VAL,ATTR_DEFN_ID,VER_NBR)
SELECT a.CNTXT_ATTR_ID,a.CNTXT_ID,a.ATTR_VAL,a.ATTR_DEFN_ID,a.VER_NBR FROM KRMS_CNTXT_ATTR_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_CNTXT_T@KC_STAG_DB_LINK b
ON a.CNTXT_ID=b.CNTXT_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI1
/
ALTER TABLE KRMS_AGENDA_T DISABLE CONSTRAINT KRMS_AGENDA_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_AGENDA_TYP_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_AGENDA_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_FUNC_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_FUNC_FK1
/
ALTER TABLE KRMS_CNTXT_ATTR_T DISABLE CONSTRAINT KRMS_CNTXT_ATTR_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_ACTN_TYP_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_ACTN_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_RULE_TYP_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_RULE_TYP_FK1
/
TRUNCATE TABLE KRMS_CNTXT_T
/
INSERT INTO KRMS_CNTXT_T(CNTXT_ID,NMSPC_CD,NM,TYP_ID,ACTV,VER_NBR,DESC_TXT)
SELECT CNTXT_ID,NMSPC_CD,NM,TYP_ID,ACTV,VER_NBR,DESC_TXT FROM KRMS_CNTXT_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI1
/
ALTER TABLE KRMS_AGENDA_T ENABLE CONSTRAINT KRMS_AGENDA_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_AGENDA_TYP_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_AGENDA_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_FUNC_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_FUNC_FK1
/
ALTER TABLE KRMS_CNTXT_ATTR_T ENABLE CONSTRAINT KRMS_CNTXT_ATTR_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_ACTN_TYP_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_ACTN_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_RULE_TYP_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_RULE_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_ACTN_TYP_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_ACTN_TYP_FK1
/
TRUNCATE TABLE KRMS_CNTXT_VLD_ACTN_TYP_T
/
INSERT INTO KRMS_CNTXT_VLD_ACTN_TYP_T(CNTXT_VLD_ACTN_ID,CNTXT_ID,ACTN_TYP_ID,VER_NBR)
SELECT a.CNTXT_VLD_ACTN_ID,a.CNTXT_ID,a.ACTN_TYP_ID,a.VER_NBR FROM KRMS_CNTXT_VLD_ACTN_TYP_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_CNTXT_T@KC_STAG_DB_LINK b
ON a.CNTXT_ID=b.CNTXT_ID
WHERE b.ACTV='Y'
/
ALTER TABLE KRMS_CNTXT_VLD_AGENDA_TYP_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_AGENDA_TYP_FK1
/
TRUNCATE TABLE KRMS_CNTXT_VLD_AGENDA_TYP_T
/
INSERT INTO KRMS_CNTXT_VLD_AGENDA_TYP_T(CNTXT_VLD_AGENDA_ID,CNTXT_ID,AGENDA_TYP_ID,VER_NBR)
SELECT a.CNTXT_VLD_AGENDA_ID,a.CNTXT_ID,a.AGENDA_TYP_ID,a.VER_NBR FROM KRMS_CNTXT_VLD_AGENDA_TYP_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_CNTXT_T@KC_STAG_DB_LINK b
ON a.CNTXT_ID=b.CNTXT_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_CNTXT_VLD_FUNC_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_FUNC_FK1
/
TRUNCATE TABLE KRMS_CNTXT_VLD_FUNC_T
/
INSERT INTO KRMS_CNTXT_VLD_FUNC_T(CNTXT_VLD_FUNC_ID,CNTXT_ID,FUNC_ID,VER_NBR)
SELECT a.CNTXT_VLD_FUNC_ID,a.CNTXT_ID,a.FUNC_ID,a.VER_NBR FROM KRMS_CNTXT_VLD_FUNC_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_CNTXT_T@KC_STAG_DB_LINK b
ON a.CNTXT_ID=b.CNTXT_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_CNTXT_VLD_RULE_TYP_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_RULE_TYP_FK1
/
TRUNCATE TABLE KRMS_CNTXT_VLD_RULE_TYP_T
/
INSERT INTO KRMS_CNTXT_VLD_RULE_TYP_T(CNTXT_VLD_RULE_ID,CNTXT_ID,RULE_TYP_ID,VER_NBR)
SELECT a.CNTXT_VLD_RULE_ID,a.CNTXT_ID,a.RULE_TYP_ID,a.VER_NBR FROM KRMS_CNTXT_VLD_RULE_TYP_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_CNTXT_T@KC_STAG_DB_LINK b
ON a.CNTXT_ID=b.CNTXT_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI1
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI2
/
TRUNCATE TABLE KRMS_CNTXT_VLD_TERM_SPEC_T
/
INSERT INTO KRMS_CNTXT_VLD_TERM_SPEC_T(CNTXT_TERM_SPEC_PREREQ_ID,CNTXT_ID,TERM_SPEC_ID,PREREQ)
SELECT a.CNTXT_TERM_SPEC_PREREQ_ID,a.CNTXT_ID,a.TERM_SPEC_ID,a.PREREQ FROM KRMS_CNTXT_VLD_TERM_SPEC_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_TERM_SPEC_T@KC_STAG_DB_LINK b
ON a.TERM_SPEC_ID=b.TERM_SPEC_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T DISABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK2
/
ALTER TABLE KRMS_FUNC_CTGRY_T DISABLE CONSTRAINT KRMS_FUNC_CTGRY_FK2
/
TRUNCATE TABLE KRMS_CTGRY_T
/
INSERT INTO KRMS_CTGRY_T(CTGRY_ID,NM,NMSPC_CD,VER_NBR)
SELECT CTGRY_ID,NM,NMSPC_CD,VER_NBR FROM KRMS_CTGRY_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T ENABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK2
/
ALTER TABLE KRMS_FUNC_CTGRY_T ENABLE CONSTRAINT KRMS_FUNC_CTGRY_FK2
/
ALTER TABLE KRMS_FUNC_CTGRY_T DISABLE CONSTRAINT KRMS_FUNC_CTGRY_FK1
/
ALTER TABLE KRMS_FUNC_CTGRY_T DISABLE CONSTRAINT KRMS_FUNC_CTGRY_FK2
/
TRUNCATE TABLE KRMS_FUNC_CTGRY_T
/
INSERT INTO KRMS_FUNC_CTGRY_T(FUNC_ID,CTGRY_ID)
SELECT a.FUNC_ID,a.CTGRY_ID FROM KRMS_FUNC_CTGRY_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_FUNC_T@KC_STAG_DB_LINK b
ON a.FUNC_ID=b.FUNC_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_FUNC_PARM_T DISABLE CONSTRAINT KRMS_FUNC_PARM_FK1
/
TRUNCATE TABLE KRMS_FUNC_PARM_T
/
INSERT INTO KRMS_FUNC_PARM_T(FUNC_PARM_ID,NM,DESC_TXT,TYP,FUNC_ID,SEQ_NO)
SELECT a.FUNC_PARM_ID,a.NM,a.DESC_TXT,a.TYP,a.FUNC_ID,a.SEQ_NO FROM KRMS_FUNC_PARM_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_FUNC_T@KC_STAG_DB_LINK b
ON a.FUNC_ID=b.FUNC_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_FUNC_T DISABLE CONSTRAINT KRMS_FUNC_FK1
/
TRUNCATE TABLE KRMS_FUNC_T
/
INSERT INTO KRMS_FUNC_T(FUNC_ID,NMSPC_CD,NM,DESC_TXT,RTRN_TYP,TYP_ID,ACTV,VER_NBR)
SELECT FUNC_ID,NMSPC_CD,NM,DESC_TXT,RTRN_TYP,TYP_ID,ACTV,VER_NBR FROM KRMS_FUNC_T@KC_STAG_DB_LINK
WHERE ACTV = 'Y'
/
ALTER TABLE KRMS_NL_TMPL_ATTR_T DISABLE CONSTRAINT KRMS_NL_TMPL_ATTR_FK1
/
ALTER TABLE KRMS_NL_TMPL_ATTR_T DISABLE CONSTRAINT KRMS_NL_TMPL_ATTR_FK2
/
TRUNCATE TABLE KRMS_NL_TMPL_ATTR_T
/
INSERT INTO KRMS_NL_TMPL_ATTR_T(NL_TMPL_ATTR_ID,NL_TMPL_ID,ATTR_DEFN_ID,ATTR_VAL,VER_NBR)
SELECT a.NL_TMPL_ATTR_ID,a.NL_TMPL_ID,a.ATTR_DEFN_ID,a.ATTR_VAL,a.VER_NBR FROM KRMS_NL_TMPL_ATTR_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_NL_TMPL_T@KC_STAG_DB_LINK b
ON a.NL_TMPL_ID=b.NL_TMPL_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_NL_TMPL_T DISABLE CONSTRAINT KRMS_NL_TMPL_FK1
/
ALTER TABLE KRMS_NL_TMPL_T DISABLE CONSTRAINT KRMS_TYP_T
/
TRUNCATE TABLE KRMS_NL_TMPL_T
/
INSERT INTO KRMS_NL_TMPL_T(NL_TMPL_ID,LANG_CD,NL_USAGE_ID,TYP_ID,TMPL,VER_NBR,ACTV)
SELECT NL_TMPL_ID,LANG_CD,NL_USAGE_ID,TYP_ID,TMPL,VER_NBR,ACTV FROM KRMS_NL_TMPL_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_NL_USAGE_ATTR_T DISABLE CONSTRAINT KRMS_NL_USAGE_ATTR_FK1
/
ALTER TABLE KRMS_NL_USAGE_ATTR_T DISABLE CONSTRAINT KRMS_NL_USAGE_ATTR_FK2
/
TRUNCATE TABLE KRMS_NL_USAGE_ATTR_T
/
INSERT INTO KRMS_NL_USAGE_ATTR_T(NL_USAGE_ATTR_ID,NL_USAGE_ID,ATTR_DEFN_ID,ATTR_VAL,VER_NBR)
SELECT a.NL_USAGE_ATTR_ID,a.NL_USAGE_ID,a.ATTR_DEFN_ID,a.ATTR_VAL,a.VER_NBR FROM KRMS_NL_USAGE_ATTR_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_NL_USAGE_T@KC_STAG_DB_LINK b
ON a.NL_USAGE_ID=b.NL_USAGE_ID
WHERE b.ACTV = 'Y'
/
TRUNCATE TABLE KRMS_NL_USAGE_T
/
INSERT INTO KRMS_NL_USAGE_T(NL_USAGE_ID,NM,NMSPC_CD,DESC_TXT,ACTV,VER_NBR)
SELECT NL_USAGE_ID,NM,NMSPC_CD,DESC_TXT,ACTV,VER_NBR FROM KRMS_NL_USAGE_T@KC_STAG_DB_LINK 
/
ALTER TABLE KRMS_PROP_PARM_T DISABLE CONSTRAINT KRMS_PROP_PARM_FK1
/
TRUNCATE TABLE KRMS_PROP_PARM_T
/
INSERT INTO KRMS_PROP_PARM_T(PROP_PARM_ID,PROP_ID,PARM_VAL,PARM_TYP_CD,SEQ_NO,VER_NBR)
SELECT PROP_PARM_ID,PROP_ID,PARM_VAL,PARM_TYP_CD,SEQ_NO,VER_NBR FROM KRMS_PROP_PARM_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_PROP_T DISABLE CONSTRAINT KRMS_PROP_FK2
/
ALTER TABLE KRMS_RULE_T DISABLE CONSTRAINT KRMS_RULE_FK1
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T DISABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK1
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T DISABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK2
/
ALTER TABLE KRMS_PROP_PARM_T DISABLE CONSTRAINT KRMS_PROP_PARM_FK1
/
TRUNCATE TABLE KRMS_PROP_T
/
INSERT INTO KRMS_PROP_T(PROP_ID,DESC_TXT,TYP_ID,DSCRM_TYP_CD,CMPND_OP_CD,RULE_ID,VER_NBR,CMPND_SEQ_NO)
SELECT PROP_ID,DESC_TXT,TYP_ID,DSCRM_TYP_CD,CMPND_OP_CD,RULE_ID,VER_NBR,CMPND_SEQ_NO FROM KRMS_PROP_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T ENABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK1
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T ENABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK2
/
ALTER TABLE KRMS_PROP_PARM_T ENABLE CONSTRAINT KRMS_PROP_PARM_FK1
/
TRUNCATE TABLE KRMS_REF_OBJ_KRMS_OBJ_T
/
INSERT INTO KRMS_REF_OBJ_KRMS_OBJ_T(REF_OBJ_KRMS_OBJ_ID,COLLECTION_NM,KRMS_OBJ_ID,KRMS_DSCR_TYP,REF_OBJ_ID,REF_DSCR_TYP,NMSPC_CD,ACTV,VER_NBR)
SELECT REF_OBJ_KRMS_OBJ_ID,COLLECTION_NM,KRMS_OBJ_ID,KRMS_DSCR_TYP,REF_OBJ_ID,REF_DSCR_TYP,NMSPC_CD,ACTV,VER_NBR FROM KRMS_REF_OBJ_KRMS_OBJ_T @KC_STAG_DB_LINK 
WHERE ACTV='Y'
/
ALTER TABLE KRMS_RULE_ATTR_T DISABLE CONSTRAINT KRMS_RULE_ATTR_FK1
/
ALTER TABLE KRMS_RULE_ATTR_T DISABLE CONSTRAINT KRMS_RULE_ATTR_FK2
/
TRUNCATE TABLE KRMS_RULE_ATTR_T
/
INSERT INTO KRMS_RULE_ATTR_T(RULE_ATTR_ID,RULE_ID,ATTR_DEFN_ID,ATTR_VAL,VER_NBR)
SELECT a.RULE_ATTR_ID,a.RULE_ID,a.ATTR_DEFN_ID,a.ATTR_VAL,a.VER_NBR FROM KRMS_RULE_ATTR_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_RULE_T@KC_STAG_DB_LINK b
ON a.RULE_ID=b.RULE_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_RULE_T DISABLE CONSTRAINT KRMS_RULE_FK1
/
TRUNCATE TABLE KRMS_RULE_T
/
INSERT INTO KRMS_RULE_T(RULE_ID,NMSPC_CD,NM,TYP_ID,PROP_ID,ACTV,VER_NBR,DESC_TXT)
SELECT RULE_ID,NMSPC_CD,NM,TYP_ID,PROP_ID,ACTV,VER_NBR,DESC_TXT FROM KRMS_RULE_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_TERM_PARM_T DISABLE CONSTRAINT KRMS_TERM_PARM_FK1
/
TRUNCATE TABLE KRMS_TERM_PARM_T
/
INSERT INTO KRMS_TERM_PARM_T(TERM_PARM_ID,TERM_ID,NM,VAL,VER_NBR)
SELECT TERM_PARM_ID,TERM_ID,NM,VAL,VER_NBR FROM KRMS_TERM_PARM_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_TERM_RSLVR_ATTR_T DISABLE CONSTRAINT KRMS_TERM_RSLVR_ATTR_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_ATTR_T DISABLE CONSTRAINT KRMS_TERM_RSLVR_ATTR_FK2
/
TRUNCATE TABLE KRMS_TERM_RSLVR_ATTR_T
/
INSERT INTO KRMS_TERM_RSLVR_ATTR_T(TERM_RSLVR_ATTR_ID,TERM_RSLVR_ID,ATTR_DEFN_ID,ATTR_VAL,VER_NBR)
SELECT a.TERM_RSLVR_ATTR_ID,a.TERM_RSLVR_ID,a.ATTR_DEFN_ID,a.ATTR_VAL,a.VER_NBR FROM KRMS_TERM_RSLVR_ATTR_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_TERM_RSLVR_T@KC_STAG_DB_LINK b
ON a.TERM_RSLVR_ID=b.TERM_RSLVR_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_TERM_RSLVR_INPUT_SPEC_T DISABLE CONSTRAINT KRMS_INPUT_ASSET_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_INPUT_SPEC_T DISABLE CONSTRAINT KRMS_INPUT_ASSET_FK2
/
TRUNCATE TABLE KRMS_TERM_RSLVR_INPUT_SPEC_T
/
INSERT INTO KRMS_TERM_RSLVR_INPUT_SPEC_T(TERM_SPEC_ID,TERM_RSLVR_ID)
SELECT a.TERM_SPEC_ID,a.TERM_RSLVR_ID FROM KRMS_TERM_RSLVR_INPUT_SPEC_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_TERM_RSLVR_T@KC_STAG_DB_LINK b
ON a.TERM_RSLVR_ID=b.TERM_RSLVR_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_TERM_RSLVR_PARM_SPEC_T DISABLE CONSTRAINT KRMS_TERM_RESLV_PARM_FK1
/
TRUNCATE TABLE KRMS_TERM_RSLVR_PARM_SPEC_T
/
INSERT INTO KRMS_TERM_RSLVR_PARM_SPEC_T(TERM_RSLVR_PARM_SPEC_ID,TERM_RSLVR_ID,NM,VER_NBR)
SELECT a.TERM_RSLVR_PARM_SPEC_ID,a.TERM_RSLVR_ID,a.NM,a.VER_NBR FROM KRMS_TERM_RSLVR_PARM_SPEC_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_TERM_RSLVR_T@KC_STAG_DB_LINK b
ON a.TERM_RSLVR_ID=b.TERM_RSLVR_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_TERM_RSLVR_T DISABLE CONSTRAINT KRMS_TERM_RSLVR_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_T DISABLE CONSTRAINT KRMS_TERM_RSLVR_FK3
/
TRUNCATE TABLE KRMS_TERM_RSLVR_T
/
INSERT INTO KRMS_TERM_RSLVR_T(TERM_RSLVR_ID,NMSPC_CD,NM,TYP_ID,OUTPUT_TERM_SPEC_ID,ACTV,VER_NBR)
SELECT TERM_RSLVR_ID,NMSPC_CD,NM,TYP_ID,OUTPUT_TERM_SPEC_ID,ACTV,VER_NBR FROM KRMS_TERM_RSLVR_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T DISABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK1
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T DISABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK2
/
TRUNCATE TABLE KRMS_TERM_SPEC_CTGRY_T
/
INSERT INTO KRMS_TERM_SPEC_CTGRY_T(TERM_SPEC_ID,CTGRY_ID)
SELECT a.TERM_SPEC_ID,a.CTGRY_ID FROM KRMS_TERM_SPEC_CTGRY_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_TERM_SPEC_T@KC_STAG_DB_LINK b
ON a.TERM_SPEC_ID=b.TERM_SPEC_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_TERM_RSLVR_INPUT_SPEC_T DISABLE CONSTRAINT KRMS_INPUT_ASSET_FK2
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T DISABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T DISABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI2
/
ALTER TABLE KRMS_TERM_T DISABLE CONSTRAINT KRMS_TERM_T__FK1
/
ALTER TABLE KRMS_TERM_RSLVR_T DISABLE CONSTRAINT KRMS_TERM_RSLVR_FK1
/
TRUNCATE TABLE KRMS_TERM_SPEC_T
/
INSERT INTO KRMS_TERM_SPEC_T(TERM_SPEC_ID,NM,TYP,ACTV,VER_NBR,DESC_TXT,NMSPC_CD)
SELECT TERM_SPEC_ID,NM,TYP,ACTV,VER_NBR,DESC_TXT,NMSPC_CD FROM KRMS_TERM_SPEC_T@KC_STAG_DB_LINK
/
ALTER TABLE KRMS_TERM_RSLVR_INPUT_SPEC_T ENABLE CONSTRAINT KRMS_INPUT_ASSET_FK2
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T ENABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI2
/
ALTER TABLE KRMS_TERM_RSLVR_T ENABLE CONSTRAINT KRMS_TERM_RSLVR_FK1
/
TRUNCATE TABLE KRMS_TERM_T
/
INSERT INTO KRMS_TERM_T(TERM_ID,TERM_SPEC_ID,VER_NBR,DESC_TXT)
SELECT a.TERM_ID,a.TERM_SPEC_ID,a.VER_NBR,a.DESC_TXT FROM KRMS_TERM_T@KC_STAG_DB_LINK a
INNER JOIN KRMS_TERM_SPEC_T@KC_STAG_DB_LINK b
ON a.TERM_SPEC_ID=b.TERM_SPEC_ID
WHERE b.ACTV = 'Y'
/
ALTER TABLE KRMS_TERM_T ENABLE CONSTRAINT KRMS_TERM_T__FK1
/
ALTER TABLE KRMS_TYP_ATTR_T DISABLE CONSTRAINT KRMS_TYP_ATTR_FK1
/
ALTER TABLE KRMS_TYP_ATTR_T DISABLE CONSTRAINT KRMS_TYP_ATTR_FK2
/
TRUNCATE TABLE KRMS_TYP_ATTR_T
/
INSERT INTO KRMS_TYP_ATTR_T(TYP_ATTR_ID,SEQ_NO,TYP_ID,ATTR_DEFN_ID,ACTV,VER_NBR)
SELECT TYP_ATTR_ID,SEQ_NO,TYP_ID,ATTR_DEFN_ID,ACTV,VER_NBR FROM KRMS_TYP_ATTR_T@KC_STAG_DB_LINK
WHERE ACTV = 'Y'
/
ALTER TABLE KRMS_TYP_RELN_T DISABLE CONSTRAINT KRMS_TYP_RELN_FK1
/
ALTER TABLE KRMS_TYP_RELN_T DISABLE CONSTRAINT KRMS_TYP_RELN_FK2
/
TRUNCATE TABLE KRMS_TYP_RELN_T
/
INSERT INTO KRMS_TYP_RELN_T(TYP_RELN_ID,FROM_TYP_ID,TO_TYP_ID,RELN_TYP,SEQ_NO,VER_NBR,ACTV)
SELECT TYP_RELN_ID,FROM_TYP_ID,TO_TYP_ID,RELN_TYP,SEQ_NO,VER_NBR,ACTV FROM KRMS_TYP_RELN_T@KC_STAG_DB_LINK
WHERE ACTV = 'Y'
/
TRUNCATE TABLE KRMS_TYP_T
/
INSERT INTO KRMS_TYP_T(TYP_ID,NM,NMSPC_CD,SRVC_NM,ACTV,VER_NBR)
SELECT TYP_ID,NM,NMSPC_CD,SRVC_NM,ACTV,VER_NBR FROM KRMS_TYP_T@KC_STAG_DB_LINK
WHERE ACTV = 'Y'
/
DELETE FROM KRMS_ACTN_ATTR_T WHERE ACTN_ID NOT IN(SELECT ACTN_ID FROM KRMS_ACTN_T)
/
DELETE FROM KRMS_AGENDA_ATTR_T WHERE AGENDA_ID NOT IN(SELECT AGENDA_ID FROM KRMS_AGENDA_T)
/
ALTER TABLE KRMS_ACTN_ATTR_T ENABLE CONSTRAINT KRMS_ACTN_ATTR_FK1
/
ALTER TABLE KRMS_ACTN_ATTR_T ENABLE CONSTRAINT KRMS_ACTN_ATTR_FK2
/
ALTER TABLE KRMS_ACTN_T ENABLE CONSTRAINT KRMS_ACTN_FK1
/
ALTER TABLE KRMS_AGENDA_ATTR_T ENABLE CONSTRAINT KRMS_AGENDA_ATTR_FK1
/
ALTER TABLE KRMS_AGENDA_ATTR_T ENABLE CONSTRAINT KRMS_AGENDA_ATTR_FK2
/
ALTER TABLE KRMS_AGENDA_ITM_T ENABLE CONSTRAINT KRMS_AGENDA_ITM_FK1
/
ALTER TABLE KRMS_AGENDA_ITM_T ENABLE CONSTRAINT KRMS_AGENDA_ITM_FK2
/
ALTER TABLE KRMS_AGENDA_ITM_T ENABLE CONSTRAINT KRMS_AGENDA_ITM_FK3
/
ALTER TABLE KRMS_AGENDA_ITM_T ENABLE CONSTRAINT KRMS_AGENDA_ITM_FK4
/
ALTER TABLE KRMS_AGENDA_ITM_T ENABLE CONSTRAINT KRMS_AGENDA_ITM_FK5
/
ALTER TABLE KRMS_AGENDA_ITM_T ENABLE CONSTRAINT KRMS_AGENDA_ITM_FK6
/
ALTER TABLE KRMS_AGENDA_T ENABLE CONSTRAINT KRMS_AGENDA_FK1
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T ENABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK1
/
ALTER TABLE KRMS_CMPND_PROP_PROPS_T ENABLE CONSTRAINT KRMS_CMPND_PROP_PROPS_FK2
/
ALTER TABLE KRMS_CNTXT_ATTR_T ENABLE CONSTRAINT KRMS_CNTXT_ATTR_FK1
/
ALTER TABLE KRMS_CNTXT_ATTR_T ENABLE CONSTRAINT KRMS_CNTXT_ATTR_FK2
/
ALTER TABLE KRMS_CNTXT_VLD_ACTN_TYP_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_ACTN_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_AGENDA_TYP_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_AGENDA_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_FUNC_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_FUNC_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_RULE_TYP_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_RULE_TYP_FK1
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI1
/
ALTER TABLE KRMS_CNTXT_VLD_TERM_SPEC_T ENABLE CONSTRAINT KRMS_CNTXT_VLD_TERM_SPEC_TI2
/
ALTER TABLE KRMS_FUNC_CTGRY_T ENABLE CONSTRAINT KRMS_FUNC_CTGRY_FK1
/
ALTER TABLE KRMS_FUNC_CTGRY_T ENABLE CONSTRAINT KRMS_FUNC_CTGRY_FK2
/
ALTER TABLE KRMS_FUNC_PARM_T ENABLE CONSTRAINT KRMS_FUNC_PARM_FK1
/
ALTER TABLE KRMS_FUNC_T ENABLE CONSTRAINT KRMS_FUNC_FK1
/
ALTER TABLE KRMS_NL_TMPL_ATTR_T ENABLE CONSTRAINT KRMS_NL_TMPL_ATTR_FK1
/
ALTER TABLE KRMS_NL_TMPL_ATTR_T ENABLE CONSTRAINT KRMS_NL_TMPL_ATTR_FK2
/
ALTER TABLE KRMS_NL_TMPL_T ENABLE CONSTRAINT KRMS_NL_TMPL_FK1
/
ALTER TABLE KRMS_NL_TMPL_T ENABLE CONSTRAINT KRMS_TYP_T
/
ALTER TABLE KRMS_NL_USAGE_ATTR_T ENABLE CONSTRAINT KRMS_NL_USAGE_ATTR_FK1
/
ALTER TABLE KRMS_NL_USAGE_ATTR_T ENABLE CONSTRAINT KRMS_NL_USAGE_ATTR_FK2
/
ALTER TABLE KRMS_PROP_PARM_T ENABLE CONSTRAINT KRMS_PROP_PARM_FK1
/
ALTER TABLE KRMS_PROP_T ENABLE CONSTRAINT KRMS_PROP_FK2
/
ALTER TABLE KRMS_RULE_ATTR_T ENABLE CONSTRAINT KRMS_RULE_ATTR_FK1
/
ALTER TABLE KRMS_RULE_ATTR_T ENABLE CONSTRAINT KRMS_RULE_ATTR_FK2
/
ALTER TABLE KRMS_RULE_T ENABLE CONSTRAINT KRMS_RULE_FK1
/
ALTER TABLE KRMS_TERM_PARM_T ENABLE CONSTRAINT KRMS_TERM_PARM_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_ATTR_T ENABLE CONSTRAINT KRMS_TERM_RSLVR_ATTR_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_ATTR_T ENABLE CONSTRAINT KRMS_TERM_RSLVR_ATTR_FK2
/
ALTER TABLE KRMS_TERM_RSLVR_INPUT_SPEC_T ENABLE CONSTRAINT KRMS_INPUT_ASSET_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_INPUT_SPEC_T ENABLE CONSTRAINT KRMS_INPUT_ASSET_FK2
/
ALTER TABLE KRMS_TERM_RSLVR_PARM_SPEC_T ENABLE CONSTRAINT KRMS_TERM_RESLV_PARM_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_T ENABLE CONSTRAINT KRMS_TERM_RSLVR_FK1
/
ALTER TABLE KRMS_TERM_RSLVR_T ENABLE CONSTRAINT KRMS_TERM_RSLVR_FK3
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T ENABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK1
/
ALTER TABLE KRMS_TERM_SPEC_CTGRY_T ENABLE CONSTRAINT KRMS_TERM_SPEC_CTGRY_FK2
/
ALTER TABLE KRMS_TERM_T ENABLE CONSTRAINT KRMS_TERM_T__FK1
/
ALTER TABLE KRMS_TYP_ATTR_T ENABLE CONSTRAINT KRMS_TYP_ATTR_FK1
/
ALTER TABLE KRMS_TYP_ATTR_T ENABLE CONSTRAINT KRMS_TYP_ATTR_FK2
/
ALTER TABLE KRMS_TYP_RELN_T ENABLE CONSTRAINT KRMS_TYP_RELN_FK1
/
ALTER TABLE KRMS_TYP_RELN_T ENABLE CONSTRAINT KRMS_TYP_RELN_FK2
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ACTN_ATTR_DATA_ID) into ls_max_val from KRMS_ACTN_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_ACTN_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_ACTN_ATTR_S increment by '||li_increment);
    select KRMS_ACTN_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_ACTN_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ACTN_ID) into ls_max_val from KRMS_ACTN_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_ACTN_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_ACTN_S increment by '||li_increment);
    select KRMS_ACTN_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_ACTN_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(AGENDA_ATTR_ID,'MITKC')) into ls_max_val from KRMS_AGENDA_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_AGENDA_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_AGENDA_ATTR_S increment by '||li_increment);
    select KRMS_AGENDA_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_AGENDA_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(AGENDA_ITM_ID,'MITKC')) into ls_max_val from KRMS_AGENDA_ITM_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_AGENDA_ITM_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_AGENDA_ITM_S increment by '||li_increment);
    select KRMS_AGENDA_ITM_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_AGENDA_ITM_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(AGENDA_ID,'MITKC')) into ls_max_val from KRMS_AGENDA_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_AGENDA_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_AGENDA_S increment by '||li_increment);
    select KRMS_AGENDA_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_AGENDA_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(ATTR_DEFN_ID,'MITKC')) into ls_max_val from KRMS_ATTR_DEFN_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_ATTR_DEFN_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_ATTR_DEFN_S increment by '||li_increment);
    select KRMS_ATTR_DEFN_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_ATTR_DEFN_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(CMPND_PROP_ID,'MITKC')) into ls_max_val from KRMS_CMPND_PROP_PROPS_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CMPND_PROP_PROPS_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CMPND_PROP_PROPS_S increment by '||li_increment);
    select KRMS_CMPND_PROP_PROPS_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CMPND_PROP_PROPS_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(CNTXT_ATTR_ID) into ls_max_val from KRMS_CNTXT_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CNTXT_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CNTXT_ATTR_S increment by '||li_increment);
    select KRMS_CNTXT_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CNTXT_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(CNTXT_VLD_ACTN_ID,'MITKC')) into ls_max_val from KRMS_CNTXT_VLD_ACTN_TYP_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CNTXT_VLD_ACTN_TYP_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CNTXT_VLD_ACTN_TYP_S increment by '||li_increment);
    select KRMS_CNTXT_VLD_ACTN_TYP_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CNTXT_VLD_ACTN_TYP_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(CNTXT_VLD_AGENDA_ID,'MITKC')) into ls_max_val from KRMS_CNTXT_VLD_AGENDA_TYP_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CNTXT_VLD_AGENDA_TYP_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CNTXT_VLD_AGENDA_TYP_S increment by '||li_increment);
    select KRMS_CNTXT_VLD_AGENDA_TYP_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CNTXT_VLD_AGENDA_TYP_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(CNTXT_VLD_FUNC_ID) into ls_max_val from KRMS_CNTXT_VLD_FUNC_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CNTXT_VLD_FUNC_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CNTXT_VLD_FUNC_S increment by '||li_increment);
    select KRMS_CNTXT_VLD_FUNC_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CNTXT_VLD_FUNC_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(CNTXT_VLD_RULE_ID,'MITKC')) into ls_max_val from KRMS_CNTXT_VLD_RULE_TYP_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CNTXT_VLD_RULE_TYP_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CNTXT_VLD_RULE_TYP_S increment by '||li_increment);
    select KRMS_CNTXT_VLD_RULE_TYP_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CNTXT_VLD_RULE_TYP_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(CNTXT_TERM_SPEC_PREREQ_ID,'MITKC')) into ls_max_val from KRMS_CNTXT_VLD_TERM_SPEC_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CNTXT_VLD_TERM_SPEC_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CNTXT_VLD_TERM_SPEC_S increment by '||li_increment);
    select KRMS_CNTXT_VLD_TERM_SPEC_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CNTXT_VLD_TERM_SPEC_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(CTGRY_ID,'MITKC')) into ls_max_val from KRMS_CTGRY_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_CTGRY_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_CTGRY_S increment by '||li_increment);
    select KRMS_CTGRY_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_CTGRY_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(FUNC_PARM_ID,'MITKC')) into ls_max_val from KRMS_FUNC_PARM_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_FUNC_PARM_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_FUNC_PARM_S increment by '||li_increment);
    select KRMS_FUNC_PARM_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_FUNC_PARM_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(FUNC_ID,'MITKC')) into ls_max_val from KRMS_FUNC_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_FUNC_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_FUNC_S increment by '||li_increment);
    select KRMS_FUNC_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_FUNC_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(NL_TMPL_ATTR_ID) into ls_max_val from KRMS_NL_TMPL_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_NL_TMPL_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_NL_TMPL_ATTR_S increment by '||li_increment);
    select KRMS_NL_TMPL_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_NL_TMPL_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(NL_TMPL_ID) into ls_max_val from KRMS_NL_TMPL_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_NL_TMPL_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_NL_TMPL_S increment by '||li_increment);
    select KRMS_NL_TMPL_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_NL_TMPL_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(NL_USAGE_ATTR_ID) into ls_max_val from KRMS_NL_USAGE_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_NL_USAGE_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_NL_USAGE_ATTR_S increment by '||li_increment);
    select KRMS_NL_USAGE_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_NL_USAGE_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(NL_USAGE_ID) into ls_max_val from KRMS_NL_USAGE_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_NL_USAGE_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_NL_USAGE_S increment by '||li_increment);
    select KRMS_NL_USAGE_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_NL_USAGE_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(PROP_PARM_ID,'KC')) into ls_max_val from KRMS_PROP_PARM_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_PROP_PARM_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_PROP_PARM_S increment by '||li_increment);
    select KRMS_PROP_PARM_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_PROP_PARM_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(PROP_ID,'MITKC')) into ls_max_val from KRMS_PROP_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_PROP_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_PROP_S increment by '||li_increment);
    select KRMS_PROP_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_PROP_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(REF_OBJ_KRMS_OBJ_ID) into ls_max_val from KRMS_REF_OBJ_KRMS_OBJ_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_REF_OBJ_KRMS_OBJ_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_REF_OBJ_KRMS_OBJ_S increment by '||li_increment);
    select KRMS_REF_OBJ_KRMS_OBJ_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_REF_OBJ_KRMS_OBJ_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(RULE_ATTR_ID,'MITKC')) into ls_max_val from KRMS_RULE_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_RULE_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_RULE_ATTR_S increment by '||li_increment);
    select KRMS_RULE_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_RULE_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(RULE_ID,'MITKC')) into ls_max_val from KRMS_RULE_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_RULE_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_RULE_S increment by '||li_increment);
    select KRMS_RULE_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_RULE_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(TERM_PARM_ID,'MITKC')) into ls_max_val from KRMS_TERM_PARM_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TERM_PARM_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TERM_PARM_S increment by '||li_increment);
    select KRMS_TERM_PARM_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TERM_PARM_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(TERM_RSLVR_ATTR_ID) into ls_max_val from KRMS_TERM_RSLVR_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TERM_RSLVR_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TERM_RSLVR_ATTR_S increment by '||li_increment);
    select KRMS_TERM_RSLVR_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TERM_RSLVR_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(TERM_RSLVR_PARM_SPEC_ID,'MITKC')) into ls_max_val from KRMS_TERM_RSLVR_PARM_SPEC_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TERM_RSLVR_PARM_SPEC_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TERM_RSLVR_PARM_SPEC_S increment by '||li_increment);
    select KRMS_TERM_RSLVR_PARM_SPEC_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TERM_RSLVR_PARM_SPEC_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(TERM_RSLVR_ID,'MITKC')) into ls_max_val from KRMS_TERM_RSLVR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TERM_RSLVR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TERM_RSLVR_S increment by '||li_increment);
    select KRMS_TERM_RSLVR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TERM_RSLVR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(TERM_ID,'MITKC')) into ls_max_val from KRMS_TERM_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TERM_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TERM_S increment by '||li_increment);
    select KRMS_TERM_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TERM_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(TERM_SPEC_ID,'MITKC')) into ls_max_val from KRMS_TERM_SPEC_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TERM_SPEC_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TERM_SPEC_S increment by '||li_increment);
    select KRMS_TERM_SPEC_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TERM_SPEC_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(TYP_ATTR_ID,'MITKC')) into ls_max_val from KRMS_TYP_ATTR_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TYP_ATTR_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TYP_ATTR_S increment by '||li_increment);
    select KRMS_TYP_ATTR_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TYP_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(TYP_RELN_ID) into ls_max_val from KRMS_TYP_RELN_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TYP_RELN_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TYP_RELN_S increment by '||li_increment);
    select KRMS_TYP_RELN_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TYP_RELN_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ltrim(TYP_ID,'MITKC')) into ls_max_val from KRMS_TYP_T;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select KRMS_TYP_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KRMS_TYP_S increment by '||li_increment);
    select KRMS_TYP_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KRMS_TYP_S increment by 1');
  end if;

end;
/