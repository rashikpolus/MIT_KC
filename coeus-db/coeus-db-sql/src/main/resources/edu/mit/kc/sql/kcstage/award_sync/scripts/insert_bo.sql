insert into ROLODEX(ROLODEX_ID,LAST_NAME,FIRST_NAME,MIDDLE_NAME,SUFFIX,PREFIX,TITLE,ORGANIZATION,ADDRESS_LINE_1,ADDRESS_LINE_2,ADDRESS_LINE_3,FAX_NUMBER,EMAIL_ADDRESS,CITY,COUNTY,STATE,POSTAL_CODE,COMMENTS,PHONE_NUMBER,COUNTRY_CODE,SPONSOR_CODE,OWNED_BY_UNIT,SPONSOR_ADDRESS_FLAG,DELETE_FLAG,CREATE_USER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
select cr.ROLODEX_ID,cr.LAST_NAME,cr.FIRST_NAME,cr.MIDDLE_NAME,cr.SUFFIX,cr.PREFIX,cr.TITLE,cr.ORGANIZATION,cr.ADDRESS_LINE_1,cr.ADDRESS_LINE_2,cr.ADDRESS_LINE_3,cr.FAX_NUMBER,cr.EMAIL_ADDRESS,cr.CITY,cr.COUNTY,cr.STATE,cr.POSTAL_CODE,cr.COMMENTS,cr.PHONE_NUMBER,cr.COUNTRY_CODE,cr.SPONSOR_CODE,cr.OWNED_BY_UNIT,cr.SPONSOR_ADDRESS_FLAG,cr.DELETE_FLAG,cr.CREATE_USER,cr.UPDATE_TIMESTAMP,cr.UPDATE_USER,1,sys_guid()
from OSP$ROLODEX@coeus.kuali cr left outer join ROLODEX r on cr.ROLODEX_ID=r.ROLODEX_ID where r.ROLODEX_ID is null
/
insert into SPONSOR(SPONSOR_CODE,SPONSOR_NAME,ACRONYM,SPONSOR_TYPE_CODE,DUN_AND_BRADSTREET_NUMBER,DUNS_PLUS_FOUR_NUMBER,DODAC_NUMBER,CAGE_NUMBER,POSTAL_CODE,STATE,COUNTRY_CODE,ROLODEX_ID,AUDIT_REPORT_SENT_FOR_FY,OWNED_BY_UNIT,CREATE_USER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,ACTV_IND)
select s.SPONSOR_CODE,s.SPONSOR_NAME,s.ACRONYM,s.SPONSOR_TYPE_CODE,s.DUN_AND_BRADSTREET_NUMBER,s.DUNS_PLUS_FOUR_NUMBER,s.DODAC_NUMBER,s.CAGE_NUMBER,s.POSTAL_CODE,s.STATE,s.COUNTRY_CODE,s.ROLODEX_ID,s.AUDIT_REPORT_SENT_FOR_FY,s.OWNED_BY_UNIT,s.CREATE_USER,s.UPDATE_TIMESTAMP,s.UPDATE_USER,1,sys_guid(),decode( upper(s.STATUS),'A','Y','N' )
from OSP$SPONSOR@coeus.kuali  s left outer join SPONSOR os on s.SPONSOR_CODE=os.SPONSOR_CODE where  os.SPONSOR_CODE is null
/
insert into INV_CREDIT_TYPE(INV_CREDIT_TYPE_CODE,DESCRIPTION,ADDS_TO_HUNDRED,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ACTIVE_FLAG,OBJ_ID)
select i.INV_CREDIT_TYPE_CODE,i.DESCRIPTION,i.ADDS_TO_HUNDRED,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,'Y',sys_guid() 
from OSP$INV_CREDIT_TYPE@coeus.kuali i left outer join INV_CREDIT_TYPE ki on i.INV_CREDIT_TYPE_CODE=ki.INV_CREDIT_TYPE_CODE where  ki.INV_CREDIT_TYPE_CODE is null
/
INSERT INTO UNIT(UNIT_NUMBER,UNIT_NAME,ORGANIZATION_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,PARENT_UNIT_NUMBER,OBJ_ID,ACTIVE_FLAG)
SELECT u.UNIT_NUMBER,u.UNIT_NAME,u.ORGANIZATION_ID,u.UPDATE_TIMESTAMP,u.UPDATE_USER,1,uh.PARENT_UNIT_NUMBER,sys_guid(),'Y' 
FROM OSP$UNIT@coeus.kuali u INNER JOIN OSP$UNIT_HIERARCHY@coeus.kuali uh ON u.UNIT_NUMBER=uh.UNIT_NUMBER
LEFT OUTER JOIN UNIT ku ON u.UNIT_NUMBER=ku.UNIT_NUMBER WHERE ku.UNIT_NUMBER IS NULL
/
commit
/
DECLARE
cursor c_update is
select t1.unit_number,
t1.parent_unit_number
from osp$unit_hierarchy@coeus.kuali t1 left outer join
unit t2 on t1.unit_number = t2.unit_number
 where t1.parent_unit_number <>t2.parent_unit_number;
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

         update unit
         set parent_unit_number = r_update.parent_unit_number
         where unit_number = r_update.unit_number;

END LOOP;
CLOSE c_update;
END;
/
DECLARE
cursor c_update is
select t1.unit_number,
t3.unit_name
from osp$unit_hierarchy@coeus.kuali t1 inner join osp$unit@coeus.kuali t3 on t1.unit_number=t3.unit_number left outer join
unit t2 on t1.unit_number = t2.unit_number
where t3.unit_name <>t2.unit_name;
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


         update unit
         set unit_name = r_update.unit_name
         where unit_number = r_update.unit_number;

END LOOP;
CLOSE c_update;
END;
/
CREATE TABLE TEMP_UNIT_ADMINISTRATOR 
   ( UNIT_NUMBER VARCHAR2(8), 
	PERSON_ID VARCHAR2(40), 
	UNIT_ADMINISTRATOR_TYPE_CODE VARCHAR2(3), 
	UPDATE_TIMESTAMP DATE, 
	UPDATE_USER VARCHAR2(60) 
	)
/
INSERT INTO TEMP_UNIT_ADMINISTRATOR(UNIT_NUMBER,PERSON_ID,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER)
SELECT 	UNIT_NUMBER,ADMINISTRATIVE_OFFICER,1,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$UNIT@coeus.kuali  
WHERE ADMINISTRATIVE_OFFICER IS NOT NULL
/
INSERT INTO TEMP_UNIT_ADMINISTRATOR(UNIT_NUMBER,PERSON_ID,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER)
SELECT 	UNIT_NUMBER,OSP_ADMINISTRATOR,2,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$UNIT@coeus.kuali
WHERE OSP_ADMINISTRATOR IS NOT NULL
/
INSERT INTO TEMP_UNIT_ADMINISTRATOR(UNIT_NUMBER,PERSON_ID,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER)
SELECT 	UNIT_NUMBER,UNIT_HEAD,3,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$UNIT@coeus.kuali
WHERE UNIT_HEAD IS NOT NULL
/
INSERT INTO TEMP_UNIT_ADMINISTRATOR(UNIT_NUMBER,PERSON_ID,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER)
SELECT 	UNIT_NUMBER,DEAN_VP,4,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$UNIT@coeus.kuali
WHERE DEAN_VP IS NOT NULL
/
INSERT INTO TEMP_UNIT_ADMINISTRATOR(UNIT_NUMBER,PERSON_ID,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER)
SELECT 	UNIT_NUMBER,OTHER_INDIVIDUAL_TO_NOTIFY,5,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$UNIT@coeus.kuali
WHERE OTHER_INDIVIDUAL_TO_NOTIFY IS NOT NULL
/
INSERT INTO TEMP_UNIT_ADMINISTRATOR(UNIT_NUMBER,PERSON_ID,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER)
SELECT 	UNIT_NUMBER,ADMINISTRATOR,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$UNIT_ADMINISTRATORS@coeus.kuali
/
INSERT INTO UNIT_ADMINISTRATOR(UNIT_NUMBER,PERSON_ID,UNIT_ADMINISTRATOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT t.UNIT_NUMBER,t.PERSON_ID,t.UNIT_ADMINISTRATOR_TYPE_CODE,t.UPDATE_TIMESTAMP,t.UPDATE_USER,1,sys_guid() FROM TEMP_UNIT_ADMINISTRATOR t
LEFT OUTER JOIN  UNIT_ADMINISTRATOR u ON t.UNIT_NUMBER=u.UNIT_NUMBER AND t.PERSON_ID=u.PERSON_ID AND t.UNIT_ADMINISTRATOR_TYPE_CODE=u.UNIT_ADMINISTRATOR_TYPE_CODE
WHERE u.UNIT_NUMBER IS NULL
/
DROP TABLE TEMP_UNIT_ADMINISTRATOR
/
/*
declare
cursor c_del is
SELECT u.UNIT_NUMBER,u.PERSON_ID,u.UNIT_ADMINISTRATOR_TYPE_CODE FROM  UNIT_ADMINISTRATOR u
LEFT OUTER JOIN TEMP_UNIT_ADMINISTRATOR t ON u.UNIT_NUMBER=t.UNIT_NUMBER AND u.PERSON_ID=t.PERSON_ID AND u.UNIT_ADMINISTRATOR_TYPE_CODE=t.UNIT_ADMINISTRATOR_TYPE_CODE
WHERE t.UNIT_NUMBER IS NULL;
r_del c_del%rowtype;

begin
if c_del%isopen then
close c_del;
end if;
open c_del;
loop
fetch c_del into r_del;
exit when c_del%notfound;

delete from UNIT_ADMINISTRATOR where UNIT_NUMBER = r_del.UNIT_NUMBER and PERSON_ID = r_del.PERSON_ID AND UNIT_ADMINISTRATOR_TYPE_CODE = r_del.UNIT_ADMINISTRATOR_TYPE_CODE;

end loop;
close c_del;
end;
/
*/
commit
/