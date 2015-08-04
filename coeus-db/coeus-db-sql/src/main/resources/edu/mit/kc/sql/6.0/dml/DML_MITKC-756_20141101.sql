INSERT INTO KRCR_PARM_T (APPL_ID, NMSPC_CD, CMPNT_CD, PARM_NM, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, OBJ_ID, VER_NBR)
VALUES('KC', 'KC-GEN', 'All', 'EnableRoleIntegration', 'CONFG', 'N', 'Determines whether roles from central db should assign to user or not', 'A', sys_guid(), 1)
/
INSERT INTO KRCR_PARM_T (APPL_ID, NMSPC_CD, CMPNT_CD, PARM_NM, PARM_TYP_CD, VAL, PARM_DESC_TXT, EVAL_OPRTR_CD, OBJ_ID, VER_NBR)
VALUES('KC', 'KC-GEN', 'All', 'RoleCentralDbCategoryCode', 'CONFG', 'AWRD', 'Role Central Db Category Code', 'A', sys_guid(), 1)
/
