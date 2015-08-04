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
'View Keyperson Maintenance',
'KC-AWARD',
'View Keyperson Maintenance',
69,
'Y'
)
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'View Keyperson Maintenance'),
(select PERM_ID from KRIM_PERM_T where      nm = 'Maintain Keyperson'),
'Y'
)
/
