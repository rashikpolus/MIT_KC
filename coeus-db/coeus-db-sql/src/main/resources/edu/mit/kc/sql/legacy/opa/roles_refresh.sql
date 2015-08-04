echo `date` 'Starting Roles DB refresh for OPA ***Coeus Prod Instance***'


ORACLE_SID=OSPA
export ORACLE_SID

ORACLE_HOME=/oracle/product/11.2.0/db
export ORACLE_HOME

ORACLE_CONNECT_STRING=`cat /home/coeus/ospauser/id`
$ORACLE_HOME/bin/sqlplus  $ORACLE_CONNECT_STRING @/home/coeus/opa/roles_refresh.sql


echo `date` 'End roles_refresh.sh'

mail -s 'Roles Refresh -HOURLY- Production Database - OSPA' coeus-dev-team@mit.edu < /home/coeus/opa/roles_refresh.log
coeus@osp-award.MIT.EDU> cat /home/coeus/opa/roles_refresh.sql
--feed_eri_roles.sql
-- Script to refresh 
--  ERI_ROLES_FROM_ROLESDB table from Roles database

set heading off;
set echo off;


select 'Purging all rows from  OSP$OPA_HR_ORG_UNIT ' from dual
/
delete from OSP$OPA_HR_ORG_UNIT
/
commit
/
select 'Populating OSP$OPA_HR_ORG_UNIT from Warehouse ' from dual
/
insert into OSP$OPA_HR_ORG_UNIT
select
  HR_ORG_UNIT_ID,   
  HR_ORG_UNIT_TITLE,
  HR_ORG_UNIT_LEVEL,
  HR_DEPARTMENT_ID,
  HR_DEPARTMENT_CODE_OLD,
  ORG_HIER_SCHOOL_AREA_NAME,
  ORG_HIER_TOP_LEVEL_NAME,
  ORG_HIER_ROOT_NAME,
  WAREHOUSE_LOAD_DATE 
 from 
WAREUSER.HR_ORG_UNIT@WAREHOUSE_COEUS.MIT.EDU
/
commit
/


select 'Roles Assignment Feed from test Roles at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS AM') from dual
/

--**************************************************************************
-- Refresh Role assignments from Roles database
--**************************************************************************
select 'Purging all rows from  OSP$OPA_ROLES_FROM_ROLESDB ' from dual
/
delete from OSP$OPA_ROLES_FROM_ROLESDB
/
commit
/
select 'Populating OSP$OPA_ROLES_FROM_ROLESDB from Test Roles DB ' from dual
/

insert into OSP$OPA_ROLES_FROM_ROLESDB
select r.KERBEROS_NAME, r.FUNCTION_NAME,
       decode(r.QUALIFIER_CODE, 'NULL', '10000000', r.QUALIFIER_CODE), 
       org.HR_ORG_UNIT_TITLE, 
       r.FUNCTION_CATEGORY,
       r.DESCEND, r.EFFECTIVE_DATE, r.EXPIRATION_DATE,
       DECODE (r.QUALIFIER_CODE, '10000000', '000001', org.HR_DEPARTMENT_CODE_OLD)
from extract_auth@ROLESDB_COEUS.MIT.EDU r,
hr_org_unit@WAREHOUSE_COEUS.MIT.EDU org
where r.QUALIFIER_CODE = org.HR_ORG_UNIT_ID
and r.FUNCTION_NAME like 'CAN VIEW OPAS%';


commit
/

-- Does not refresh OSP$OPA_HR_ORG_DESC;
--Will be done daily by the daily script

exit;