--update and insert new permissions for WL
delete from KRIM_ROLE_PERM_T where role_id in(select role_id from KRIM_ROLE_T where role_nm like 'WL Super User')
/
delete from KRIM_ROLE_T where role_nm like 'WL Super User'
/
delete from KRIM_PERM_T where nm like 'Run_WL_Simulation'
/
delete from KRIM_PERM_T where nm like 'Edit_WL'
/
delete from KRIM_PERM_T where nm like 'View_WL'
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
'KC-PD',
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
'KC-PD',
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
'KC-PD',
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
'KC-PD',
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-PD'),
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-PD'),
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-PD'),
(select PERM_ID from KRIM_PERM_T where      nm = 'Run_WL_Simulation'),
'Y'
)
/
