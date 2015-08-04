DROP TABLE AWARD_UNITS
/
DROP TABLE AWARD_INVESTIGATORS
/
CREATE TABLE AWARD_INVESTIGATORS
(MIT_AWARD_NUMBER CHAR(10), 
SEQUENCE_NUMBER NUMBER(4,0), 
PERSON_ID VARCHAR2(9), 
PERSON_NAME VARCHAR2(90), 
PRINCIPAL_INVESTIGATOR_FLAG CHAR(1), 
NON_MIT_PERSON_FLAG CHAR(1), 
FACULTY_FLAG CHAR(1), 
CONFLICT_OF_INTEREST_FLAG CHAR(1), 
PERCENTAGE_EFFORT NUMBER(5,2), 
FEDR_DEBR_FLAG CHAR(1), 
FEDR_DELQ_FLAG CHAR(1), 
UPDATE_TIMESTAMP DATE, 
UPDATE_USER VARCHAR2(8), 
MULTI_PI_FLAG VARCHAR2(1), 
ACADEMIC_YEAR_EFFORT NUMBER(5,2), 
SUMMER_YEAR_EFFORT NUMBER(5,2), 
CALENDAR_YEAR_EFFORT NUMBER(5,2),
AWARD_NUMBER VARCHAR2(12))
/
CREATE TABLE AWARD_UNITS
(MIT_AWARD_NUMBER	CHAR(10),
SEQUENCE_NUMBER	NUMBER(4,0),
UNIT_NUMBER	VARCHAR2(8),
PERSON_ID	VARCHAR2(9),
LEAD_UNIT_FLAG	CHAR(1),
UPDATE_TIMESTAMP DATE,
UPDATE_USER	VARCHAR2(8)
)
/
INSERT INTO AWARD_UNITS(MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
UNIT_NUMBER,
PERSON_ID,
LEAD_UNIT_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER
)
SELECT 
MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
UNIT_NUMBER,
PERSON_ID,
LEAD_UNIT_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER
FROM OSP$AWARD_UNITS@coeus.kuali
/
INSERT INTO AWARD_INVESTIGATORS(MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
PERSON_ID,
PERSON_NAME,
PRINCIPAL_INVESTIGATOR_FLAG,
NON_MIT_PERSON_FLAG,
FACULTY_FLAG,
CONFLICT_OF_INTEREST_FLAG,
PERCENTAGE_EFFORT,
FEDR_DEBR_FLAG,
FEDR_DELQ_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER,
MULTI_PI_FLAG,
ACADEMIC_YEAR_EFFORT,
SUMMER_YEAR_EFFORT,
CALENDAR_YEAR_EFFORT,
AWARD_NUMBER)
SELECT MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
PERSON_ID,
PERSON_NAME,
PRINCIPAL_INVESTIGATOR_FLAG,
NON_MIT_PERSON_FLAG,
FACULTY_FLAG,
CONFLICT_OF_INTEREST_FLAG,
PERCENTAGE_EFFORT,
FEDR_DEBR_FLAG,
FEDR_DELQ_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER,
MULTI_PI_FLAG,
ACADEMIC_YEAR_EFFORT,
SUMMER_YEAR_EFFORT,
CALENDAR_YEAR_EFFORT,
replace(MIT_AWARD_NUMBER,'-','-00')
FROM OSP$AWARD_INVESTIGATORS@coeus.kuali
/
INSERT INTO AWARD_UNITS
SELECT t0.mit_award_number,
b0.sequence_number,
t0.unit_number,
t0.person_id,
t0.lead_unit_flag,
t0.update_timestamp,
t0.update_user
from osp$award_units@coeus.kuali t0 inner join 
(
select t1.mit_award_number,t1.sequence_number
from osp$award@coeus.kuali t1 left outer join osp$award_units@coeus.kuali t2 on t1.mit_award_number = t2.mit_award_number 
and t1.sequence_number = t2.sequence_number
where t2.mit_award_number is null
) b0
on t0.mit_award_number = b0.mit_award_number
and t0.sequence_number = ( select max(s1.sequence_number) from osp$award_units@coeus.kuali s1
                           where s1.mit_award_number = b0.mit_award_number 
                           and  s1.sequence_number <= b0.sequence_number)
/
INSERT INTO AWARD_INVESTIGATORS(
MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
PERSON_ID,
PERSON_NAME,
PRINCIPAL_INVESTIGATOR_FLAG,
NON_MIT_PERSON_FLAG,
FACULTY_FLAG,
CONFLICT_OF_INTEREST_FLAG,
PERCENTAGE_EFFORT,
FEDR_DEBR_FLAG,
FEDR_DELQ_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER,
MULTI_PI_FLAG,
ACADEMIC_YEAR_EFFORT,
SUMMER_YEAR_EFFORT,
CALENDAR_YEAR_EFFORT,
AWARD_NUMBER)
SELECT t0.mit_award_number,
b0.sequence_number,
t0.person_id,
t0.person_name,
t0.principal_investigator_flag,
t0.non_mit_person_flag,
t0.faculty_flag,
t0.conflict_of_interest_flag,
t0.percentage_effort,
t0.fedr_debr_flag,
t0.fedr_delq_flag,
t0.update_timestamp,
t0.update_user,
t0.multi_pi_flag,
t0.academic_year_effort,
t0.summer_year_effort,
t0.calendar_year_effort,
replace(t0.mit_award_number,'-','-00')
from osp$award_investigators@coeus.kuali t0 inner join 
(
select t1.mit_award_number,t1.sequence_number
from osp$award@coeus.kuali t1 left outer join osp$award_investigators@coeus.kuali t2 on t1.mit_award_number = t2.mit_award_number 
and t1.sequence_number = t2.sequence_number
where t2.mit_award_number is null
) b0
on t0.mit_award_number = b0.mit_award_number
and t0.sequence_number = ( select max(s1.sequence_number) from osp$award_investigators@coeus.kuali s1
                           where s1.mit_award_number = b0.mit_award_number 
                           and  s1.sequence_number <= b0.sequence_number)
/
ALTER TABLE AWARD_UNITS ADD AWARD_NUMBER VARCHAR2(12)
/
update AWARD_UNITS set AWARD_NUMBER = replace(mit_award_number,'-','-00')
/
commit
/
update AWARD_UNITS t1 set t1.AWARD_NUMBER = (select distinct s1.change_award_number 
from kc_mig_award_conv s1 where s1.award_number = t1.award_number)
where t1.AWARD_NUMBER in (select s2.award_number from kc_mig_award_conv s2)
/
update AWARD_INVESTIGATORS t1 set t1.AWARD_NUMBER = (select distinct s1.change_award_number 
from kc_mig_award_conv s1 where s1.award_number = t1.award_number)
where t1.AWARD_NUMBER in (select s2.award_number from kc_mig_award_conv s2)
/
commit
/
declare
li_award number(12,0);
li_count NUMBER;
cursor c_pers is
select a.award_number,a.SEQUENCE_NUMBER,DECODE(r.ROLODEX_ID,null,a.PERSON_ID,null) PERSON_ID,r.ROLODEX_ID,a.PERSON_NAME,decode(a.PRINCIPAL_INVESTIGATOR_FLAG,'Y','PI','N','COI') CONTACT_ROLE_CODE,a.NON_MIT_PERSON_FLAG,a.FACULTY_FLAG,a.CONFLICT_OF_INTEREST_FLAG
,a.PERCENTAGE_EFFORT,a.FEDR_DEBR_FLAG,FEDR_DELQ_FLAG,a.UPDATE_TIMESTAMP,a.UPDATE_USER,a.MULTI_PI_FLAG,a.ACADEMIC_YEAR_EFFORT,a.SUMMER_YEAR_EFFORT,a.CALENDAR_YEAR_EFFORT
from AWARD_INVESTIGATORS a 
left outer join award_persons ap on a.AWARD_NUMBER=ap.AWARD_NUMBER and a.SEQUENCE_NUMBER=ap.SEQUENCE_NUMBER
and (a.PERSON_ID=ap.PERSON_ID or a.PERSON_ID=ap.ROLODEX_ID)
left outer join ROLODEX r on a.PERSON_ID=r.ROLODEX_ID
where ap.AWARD_NUMBER IS NULL;
r_pers c_pers%rowtype;

begin
if c_pers%isopen then
close c_pers;
end if;
open c_pers;
loop
fetch c_pers into r_pers;
exit when c_pers%notfound;
  
  

  begin
	  select award_id into li_award from award where award_number = r_pers.award_number and sequence_number= r_pers.sequence_number;
	  select count(award_person_id) into li_count 
    from AWARD_PERSONS
	  where AWARD_ID = li_award
	  AND  ( PERSON_ID = r_pers.PERSON_ID OR  ROLODEX_ID = r_pers.ROLODEX_ID );
	  
	  if li_count = 0 then
       insert into AWARD_PERSONS(AWARD_PERSON_ID,KEY_PERSON_PROJECT_ROLE,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,PERSON_ID,ROLODEX_ID,FULL_NAME,CONTACT_ROLE_CODE,ACADEMIC_YEAR_EFFORT,CALENDAR_YEAR_EFFORT,SUMMER_EFFORT,TOTAL_EFFORT,FACULTY_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
       values(SEQUENCE_AWARD_ID.NEXTVAL,null,li_award,r_pers.award_number,r_pers.sequence_number,r_pers.PERSON_ID,r_pers.ROLODEX_ID,r_pers.PERSON_NAME,r_pers.CONTACT_ROLE_CODE,r_pers.ACADEMIC_YEAR_EFFORT,r_pers.CALENDAR_YEAR_EFFORT,r_pers.SUMMER_YEAR_EFFORT,r_pers.PERCENTAGE_EFFORT,nvl(r_pers.FACULTY_FLAG,'Y'),r_pers.UPDATE_TIMESTAMP,r_pers.UPDATE_USER,1,SYS_GUID());
      
	  end if; 
	  
	exception
	when others then
	dbms_output.put_line('Exception in AWARD_PERSONS, award_id '||li_award||', error is '||sqlerrm);
	end;
	
	  
end loop;
close c_pers;
end;
/
DROP TABLE TEMP_AWARD_PERSON_UNITS
/
CREATE TABLE TEMP_AWARD_PERSON_UNITS
(AWARD_NUMBER VARCHAR2(12),
SEQUENCE_NUMBER NUMBER(4,0),
AWARD_ID NUMBER(12,0),
PERSON_ID	VARCHAR2(40),
ROLODEX_ID	NUMBER(6,0),
UNIT_NUMBER VARCHAR2(8) 
)
/
INSERT INTO TEMP_AWARD_PERSON_UNITS(AWARD_NUMBER,SEQUENCE_NUMBER,AWARD_ID,PERSON_ID,ROLODEX_ID,UNIT_NUMBER)
SELECT ap.AWARD_NUMBER,ap.SEQUENCE_NUMBER,ap.AWARD_ID,ap.PERSON_ID,ap.ROLODEX_ID,u.UNIT_NUMBER FROM AWARD_PERSONS ap
INNER JOIN AWARD_PERSON_UNITS u ON ap.AWARD_PERSON_ID=u.AWARD_PERSON_ID
/
create index award_units_i1 on AWARD_UNITS(AWARD_NUMBER,SEQUENCE_NUMBER,UNIT_NUMBER)
/
create index temp_awd_person_unitsi1 on TEMP_AWARD_PERSON_UNITS(AWARD_NUMBER,SEQUENCE_NUMBER,UNIT_NUMBER)
/
create index AWARD_PERSON_UNITSi10 on AWARD_PERSON_UNITS(AWARD_PERSON_ID,UNIT_NUMBER)
/
create index AWARD_PERSONSi10 on AWARD_PERSONS(AWARD_NUMBER,SEQUENCE_NUMBER,PERSON_ID,ROLODEX_ID)
/
declare
li_award_person number(12,0);
cursor c_pers is
select u.AWARD_NUMBER,u.SEQUENCE_NUMBER,u.UNIT_NUMBER,u.LEAD_UNIT_FLAG,u.PERSON_ID,u.UPDATE_TIMESTAMP,u.UPDATE_USER
from AWARD_UNITS u
left outer join TEMP_AWARD_PERSON_UNITS t on u.AWARD_NUMBER=t.AWARD_NUMBER 
and u.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER and (u.PERSON_ID=t.PERSON_ID or u.PERSON_ID=t.ROLODEX_ID)
and u.UNIT_NUMBER=t.UNIT_NUMBER
where t.AWARD_NUMBER is null;
r_pers c_pers%rowtype;
li_count number;
begin
if c_pers%isopen then
close c_pers;
end if;
open c_pers;
loop
fetch c_pers into r_pers;
exit when c_pers%notfound;

  begin
     select award_person_id into li_award_person from award_persons where award_number = r_pers.award_number 
     and sequence_number= r_pers.sequence_number and (person_id=r_pers.person_id or rolodex_id=r_pers.person_id);
     
	 select count(AWARD_PERSON_UNIT_ID) into li_count FROM AWARD_PERSON_UNITS 
	 WHERE AWARD_PERSON_ID = li_award_person
	 AND UNIT_NUMBER = r_pers.UNIT_NUMBER;
	 
	 if li_count = 0 then	 
		 insert into AWARD_PERSON_UNITS(AWARD_PERSON_UNIT_ID,AWARD_PERSON_ID,UNIT_NUMBER,LEAD_UNIT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
		 values(SEQUENCE_AWARD_ID.NEXTVAL,li_award_person,r_pers.UNIT_NUMBER,r_pers.LEAD_UNIT_FLAG,r_pers.UPDATE_TIMESTAMP,r_pers.UPDATE_USER,1,sys_guid());
		 
	 end if;
	 
	exception
	when others then
	dbms_output.put_line('Exception in AWARD_PERSON_UNITS, award_id '||li_award_person||', error is '||sqlerrm);
	end;      
end loop;
close c_pers;
end;
/
commit
/
