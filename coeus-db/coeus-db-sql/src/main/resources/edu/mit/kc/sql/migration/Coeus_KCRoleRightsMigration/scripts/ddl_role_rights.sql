declare
li_count number;
begin
  select  count(table_name) into li_count  from all_tables   where table_name = 'BAK_KRIM_ROLE_T';
  if li_count > 0 then
    execute immediate('drop table BAK_KRIM_ROLE_T');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'BAK_KRIM_PERM_T';
  if li_count > 0 then
    execute immediate('drop table BAK_KRIM_PERM_T');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'BAK_KRIM_ROLE_PERM_T';
  if li_count > 0 then
    execute immediate('drop table BAK_KRIM_ROLE_PERM_T');
  end if;
  
   select  count(table_name) into li_count  from all_tables   where table_name = 'OSP$ROLE';
  if li_count > 0 then
    execute immediate('drop table OSP$ROLE');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'OSP$RIGHTS';
  if li_count > 0 then
    execute immediate('drop table OSP$RIGHTS');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'OSP$ROLE_RIGHTS';
  if li_count > 0 then
    execute immediate('drop table OSP$ROLE_RIGHTS');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'OSP$USER_ROLES';
  if li_count > 0 then
    execute immediate('drop table OSP$USER_ROLES');
  end if;  
    
  select  count(table_name) into li_count  from all_tables   where table_name = 'KC_COEUS_RIGHT_MAPPING';
  if li_count > 0 then
    execute immediate('drop table KC_COEUS_RIGHT_MAPPING');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'KC_COEUS_ROLE_MAPPING';
  if li_count > 0 then
    execute immediate('drop table KC_COEUS_ROLE_MAPPING');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'KC_COEUS_ROLE_PERM_MAPPING';
  if li_count > 0 then
    execute immediate('drop table KC_COEUS_ROLE_PERM_MAPPING');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'TMP_ROLE_PERM_MAPPING';
  if li_count > 0 then
    execute immediate('drop table TMP_ROLE_PERM_MAPPING');
  end if;

  
  select  count(table_name) into li_count  from all_tables   where table_name = 'KC_ROLE_UPDATE_ACTION';
  if li_count > 0 then
    execute immediate('drop table KC_ROLE_UPDATE_ACTION');
  end if;  
  
  
  
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'KC_ROLE_BOOTSTRAP';
  if li_count > 0 then
    execute immediate('drop table KC_ROLE_BOOTSTRAP');
  end if;
  
   select  count(table_name) into li_count  from all_tables   where table_name = 'KC_PERM_BOOTSTRAP';
  if li_count > 0 then
    execute immediate('drop table KC_PERM_BOOTSTRAP');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'KC_ROLE_PERM_BOOTSTRAP';
  if li_count > 0 then
    execute immediate('drop table KC_ROLE_PERM_BOOTSTRAP');
  end if; 
  
end;
/
commit
/
create table BAK_KRIM_ROLE_T as select * from KRIM_ROLE_T
/
create table BAK_KRIM_PERM_T as select * from KRIM_PERM_T
/
create table BAK_KRIM_ROLE_PERM_T as select * from KRIM_ROLE_PERM_T
/
commit
/
CREATE TABLE osp$role(ROLE_ID,
	DESCRIPTION,
	ROLE_NAME,
	ROLE_TYPE,
	OWNED_BY_UNIT,
	DESCEND_FLAG,
	STATUS_FLAG,
	CREATE_TIMESTAMP,
	CREATE_USER,
	UPDATE_TIMESTAMP,
	UPDATE_USER)
as
select 
	ROLE_ID,
	DESCRIPTION,
	ROLE_NAME,
	ROLE_TYPE,
	OWNED_BY_UNIT,
	DESCEND_FLAG,
	STATUS_FLAG,
	CREATE_TIMESTAMP,
	CREATE_USER,
	UPDATE_TIMESTAMP,
	UPDATE_USER
from osp$role@coeus.kuali
/
CREATE TABLE osp$rights(RIGHT_ID,
	DESCRIPTION,
	RIGHT_TYPE,
	DESCEND_FLAG,
	UPDATE_USER,
	UPDATE_TIMESTAMP)
as
select 
	RIGHT_ID,
	DESCRIPTION,
	RIGHT_TYPE,
	DESCEND_FLAG,
	UPDATE_USER,
	UPDATE_TIMESTAMP
from osp$rights@coeus.kuali
/
CREATE TABLE osp$role_rights(RIGHT_ID,
ROLE_ID,
DESCEND_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER)
as
select
	RIGHT_ID,
	ROLE_ID,
	DESCEND_FLAG,
	UPDATE_TIMESTAMP,
	UPDATE_USER
from osp$role_rights@coeus.kuali
/
CREATE TABLE OSP$USER_ROLES
(USER_ID, 
ROLE_ID, 
UNIT_NUMBER , 
DESCEND_FLAG, 
UPDATE_TIMESTAMP, 
UPDATE_USER 
)
as
select
	USER_ID,
	ROLE_ID,
	UNIT_NUMBER,
	DESCEND_FLAG,
	UPDATE_TIMESTAMP,
	UPDATE_USER
from osp$USER_ROLES@coeus.kuali
/
CREATE TABLE KC_COEUS_RIGHT_MAPPING (	
KC_PERM_NM VARCHAR2(120), 
KC_DESCRIPTION VARCHAR2(2000), 
COEUS_RIGHT_ID VARCHAR2(120), 
COEUS_DESCRIPTION VARCHAR2(2000),
NMSPC_CD	VARCHAR2(40)
)
/
CREATE TABLE KC_COEUS_ROLE_MAPPING (
COEUS_ROLES VARCHAR2(80), 
KC_ROLES VARCHAR2(80)
)
/
CREATE TABLE KC_ROLE_BOOTSTRAP (
  	ROLE_ID VARCHAR2(40), 
    OBJ_ID VARCHAR2(36) NOT NULL ENABLE, 
    VER_NBR NUMBER(8,0) NOT NULL ENABLE, 
    ROLE_NM VARCHAR2(80) NOT NULL ENABLE, 
    NMSPC_CD VARCHAR2(40) NOT NULL ENABLE, 
    DESC_TXT VARCHAR2(4000), 
    KIM_TYP_ID VARCHAR2(40) NOT NULL ENABLE, 
    ACTV_IND VARCHAR2(1), 
    LAST_UPDT_DT DATE
)
/
CREATE TABLE KC_PERM_BOOTSTRAP(
  PERM_ID VARCHAR2(40), 
	OBJ_ID VARCHAR2(36) NOT NULL ENABLE, 
	VER_NBR NUMBER(8,0) NOT NULL ENABLE, 
	PERM_TMPL_ID VARCHAR2(40), 
	NMSPC_CD VARCHAR2(40) NOT NULL ENABLE, 
	NM VARCHAR2(100) NOT NULL ENABLE, 
	DESC_TXT VARCHAR2(400), 
	ACTV_IND VARCHAR2(1)
)
/
CREATE TABLE KC_ROLE_PERM_BOOTSTRAP (
ROLE_PERM_ID VARCHAR2(40), 
OBJ_ID VARCHAR2(36) NOT NULL ENABLE, 
 VER_NBR NUMBER(8,0) DEFAULT 1 NOT NULL ENABLE, 
 ROLE_ID VARCHAR2(40) NOT NULL ENABLE, 
 PERM_ID VARCHAR2(40) NOT NULL ENABLE, 
 ACTV_IND VARCHAR2(1) DEFAULT 'Y'
)
/
CREATE TABLE KC_COEUS_ROLE_PERM_MAPPING(
  ROLE_NM VARCHAR2(80),
  ROLE_NMSPC_CD	VARCHAR2(40),
  PERM_NM	VARCHAR2(100),
  PERM_NMSPC_CD	VARCHAR2(40)
)
/

CREATE TABLE TMP_ROLE_PERM_MAPPING(
  ROLE_NM VARCHAR2(80),
  ROLE_NMSPC_CD	VARCHAR2(40),
  ROLE_KIM_TYP_NM	VARCHAR2(100),
  PERM_NM	VARCHAR2(100),
  PERM_NMSPC_CD	VARCHAR2(40)
)
/
CREATE TABLE KC_ROLE_UPDATE_ACTION(
ROLE_NM VARCHAR2(80), 
NMSPC_CD VARCHAR2(40), 
NEW_ROLE_NM VARCHAR2(80), 
NEW_NMSPC_CD VARCHAR2(40),
ACTION_TYP VARCHAR2(1)
)
/
