--create and insert new permissions for WL
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
'View_WL',
'Allow the user to see the WL screens except the simulation functionality',
'Y'
)
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
'Edit_WL',
'Allow the user to see and edit the WL screens except the simulation functionality',
'Y'
)
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
'Run_WL_Simulation',
'Allow the user to see and edit the WL screens, including the Simulation functionality both in the production and the simulation modes',
'Y'
)
/
commit
/
--create superuser role to WL and assign permissions to the role
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
'WL Super User',
'KC-AWARD',
'Provide user with View_WL,Edit_WL and Run_WL_Simulation rights',
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-AWARD'),
(select PERM_ID from KRIM_PERM_T where      nm = 'View_WL'),
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-AWARD'),
(select PERM_ID from KRIM_PERM_T where      nm = 'Edit_WL'),
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-AWARD'),
(select PERM_ID from KRIM_PERM_T where      nm = 'Run_WL_Simulation'),
'Y'
)
/
