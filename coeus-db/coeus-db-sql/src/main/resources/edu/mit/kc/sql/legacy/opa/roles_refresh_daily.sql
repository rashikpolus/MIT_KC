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

delete from OSP$OPA_HR_ORG_DESC;

insert into OSP$OPA_HR_ORG_DESC
select * from extract_desc@ROLESDB_COEUS.MIT.EDU
/

commit
/

exit;
