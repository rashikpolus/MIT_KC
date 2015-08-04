--REMOVING PERMISSION 'Maintain Keyperson' FROM ROLE 'Aggregator' BASED ON MITKC-997
DELETE FROM KRIM_ROLE_PERM_T WHERE ROLE_ID IN (select ROLE_ID from KRIM_ROLE_T where role_nm = 'Aggregator')
AND PERM_ID IN (select PERM_ID from KRIM_PERM_T where      nm = 'Maintain Keyperson')
/
DELETE FROM KRIM_ROLE_T WHERE NMSPC_CD = 'KC-AWARD' AND ROLE_NM = 'Maintain Key Person'
/
DELETE FROM KRIM_ROLE_PERM_T WHERE  PERM_ID = (SELECT PERM_ID FROM KRIM_PERM_T WHERE NM = 'Maintain Keyperson' AND NMSPC_CD = 'KC-AWARD')
/
DELETE FROM KRIM_PERM_T WHERE NMSPC_CD = 'KC-AWARD' AND NM = 'Maintain Keyperson'
/
INSERT INTO KRIM_PERM_T(
PERM_ID,
OBJ_ID,
VER_NBR,
PERM_TMPL_ID,
NMSPC_CD,
NM,
DESC_TXT,
ACTV_IND
)
VALUES(
KRIM_PERM_ID_S.nextval,
sys_guid(),
1,
1,
'KC-AWARD',
'Maintain Keyperson',
'Maintain Keyperson',
'Y'
)
/  
INSERT INTO KRIM_ROLE_T(
ROLE_ID,
OBJ_ID,
VER_NBR,
ROLE_NM,
NMSPC_CD,
DESC_TXT,
KIM_TYP_ID,
ACTV_IND
)  
VALUES(
KRIM_ROLE_ID_S.NEXTVAL,
SYS_GUID(),
1,
'Maintain Key Person',
'KC-AWARD',
'Maintain Key Person',
69,
'Y'
)
/
commit
/ 
INSERT INTO KRIM_ROLE_PERM_T(
ROLE_PERM_ID,
OBJ_ID,
VER_NBR,
ROLE_ID,
PERM_ID,
ACTV_IND
)
VALUES(
KRIM_ROLE_PERM_ID_S.nextval,
sys_guid(),
1,
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'Maintain Key Person' and NMSPC_CD= 'KC-AWARD' ),
(select PERM_ID from KRIM_PERM_T where      nm = 'Maintain Keyperson' and NMSPC_CD= 'KC-AWARD' ),
'Y'
)
/