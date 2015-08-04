truncate table krim_role_perm_t;
insert into krim_role_perm_t(
  ROLE_PERM_ID,
  OBJ_ID,
  VER_NBR,
  ROLE_ID,
  PERM_ID,
  ACTV_IND
)
select ROLE_PERM_ID,
OBJ_ID,
VER_NBR,
ROLE_ID,
PERM_ID,
ACTV_IND from bak_krim_role_perm_t;
truncate table KRIM_PERM_T;
insert into KRIM_PERM_T(
  PERM_ID,
  OBJ_ID,
  VER_NBR,
  PERM_TMPL_ID,
  NMSPC_CD,
  NM,
  DESC_TXT,
  ACTV_IND
)
select 
  PERM_ID,
  OBJ_ID,
  VER_NBR,
  PERM_TMPL_ID,
  NMSPC_CD,
  NM,
  DESC_TXT,
  ACTV_IND
from   bak_krim_perm_t;
truncate table KRIM_ROLE_T;
insert into KRIM_ROLE_T(
ROLE_ID,
OBJ_ID,
VER_NBR,
ROLE_NM,
NMSPC_CD,
DESC_TXT,
KIM_TYP_ID,
ACTV_IND,
LAST_UPDT_DT
)
select ROLE_ID,
OBJ_ID,
VER_NBR,
ROLE_NM,
NMSPC_CD,
DESC_TXT,
KIM_TYP_ID,
ACTV_IND,
LAST_UPDT_DT
from bak_krim_role_t;
alter sequence KRIM_ROLE_PERM_ID_S increment by 1000;
/
select KRIM_ROLE_PERM_ID_S.NEXTVAL from dual
/
alter sequence KRIM_ROLE_PERM_ID_S increment by 1
/