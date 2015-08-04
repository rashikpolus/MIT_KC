DROP TABLE AWARD_UNITS
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
commit
/
declare
cursor c_data is
  select t1.mit_award_number,t1.award_number ,t3.award_id,t1.sequence_number
  from AWARD_INVESTIGATORS_COEUS t1 
  left outer join award_persons t2 on t1.award_number = t2.award_number   and t1.sequence_number = t2.sequence_number
  inner join award t3 on t3.award_number = t1.award_number and t3.sequence_number = t1.sequence_number
  where t2.award_number is null;
  r_data c_data%rowtype;  
  
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
    
INSERT INTO award_persons(
            award_person_id,
            key_person_project_role,
            award_id,
            award_number,
            sequence_number,
            person_id,
            rolodex_id,
            full_name,
            contact_role_code,
            academic_year_effort,
            calendar_year_effort,
            summer_effort,
            total_effort,
            faculty_flag,
            update_timestamp,
            update_user,
            ver_nbr,
            obj_id
            )
        SELECT  
          SEQUENCE_AWARD_ID.NEXTVAL,
          null,
          r_data.award_id,
          award_number,
          sequence_number,
          decode(non_mit_person_flag,'Y',null, person_id) person_id,
          decode(non_mit_person_flag,'Y',person_id, null) rolodex_id,
          person_name,
          decode(principal_investigator_flag,'Y','PI',decode(multi_pi_flag,'Y','MPI','COI')),
          academic_year_effort,
          calendar_year_effort,
          summer_year_effort,
          percentage_effort,
          nvl(FACULTY_FLAG,'Y'),
          update_timestamp,
          update_user,
          1,
          sys_guid()
          FROM AWARD_INVESTIGATORS_COEUS
          WHERE mit_award_number  = r_data.mit_award_number
          AND sequence_number = r_data.sequence_number;
    
    
  end loop;
  close c_data;
end;
/
commit
/
