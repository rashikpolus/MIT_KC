INSERT INTO KRIM_TYP_T (KIM_TYP_ID, OBJ_ID, VER_NBR, NM, SRVC_NM, ACTV_IND, NMSPC_CD) 
VALUES( KRIM_TYP_ID_S.NEXTVAL, SYS_GUID(), 1, 'Derived Role: Proposal Lead Unit OSP Administrator', 'proposalLeadUnitOspAdministratorDerivedRoleTypeService', 'Y', 'KC-PD')
/
INSERT INTO KRIM_ROLE_T (ROLE_ID, OBJ_ID, VER_NBR, ROLE_NM, NMSPC_CD, DESC_TXT, KIM_TYP_ID, ACTV_IND, LAST_UPDT_DT) 
VALUES (KRIM_ROLE_PERM_ID_S.NEXTVAL, SYS_GUID(), 1, 'Proposal Lead Unit OSP Administrator', 'KC-PD', 'Proposal Lead Unit OSP Administrator', (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-PD' AND NM = 'Derived Role: Proposal Lead Unit OSP Administrator'), 'Y', SYSDATE)
/
