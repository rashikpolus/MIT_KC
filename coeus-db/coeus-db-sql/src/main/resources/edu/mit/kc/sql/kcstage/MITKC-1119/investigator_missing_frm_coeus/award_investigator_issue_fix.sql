CREATE TABLE AWARD_INVESTIGATORS_COEUS
(	MIT_AWARD_NUMBER CHAR(10 BYTE) NOT NULL ENABLE, 
SEQUENCE_NUMBER NUMBER(4,0) NOT NULL ENABLE, 
PERSON_ID VARCHAR2(9 BYTE) NOT NULL ENABLE, 
PERSON_NAME VARCHAR2(90 BYTE), 
PRINCIPAL_INVESTIGATOR_FLAG CHAR(1 BYTE) NOT NULL ENABLE, 
NON_MIT_PERSON_FLAG CHAR(1 BYTE) NOT NULL ENABLE, 
FACULTY_FLAG CHAR(1 BYTE), 
CONFLICT_OF_INTEREST_FLAG CHAR(1 BYTE), 
PERCENTAGE_EFFORT NUMBER(5,2), 
FEDR_DEBR_FLAG CHAR(1 BYTE), 
FEDR_DELQ_FLAG CHAR(1 BYTE), 
UPDATE_TIMESTAMP DATE NOT NULL ENABLE, 
UPDATE_USER VARCHAR2(8 BYTE) NOT NULL ENABLE, 
MULTI_PI_FLAG VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL ENABLE, 
ACADEMIC_YEAR_EFFORT NUMBER(5,2), 
SUMMER_YEAR_EFFORT NUMBER(5,2), 
CALENDAR_YEAR_EFFORT NUMBER(5,2)
)
/
INSERT INTO AWARD_INVESTIGATORS_COEUS SELECT * FROM OSP$AWARD_INVESTIGATORS@coeus.kuali
/
INSERT INTO AWARD_INVESTIGATORS_COEUS
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
t0.calendar_year_effort
from osp$award_investigators t0 inner join 
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
ALTER TABLE AWARD_INVESTIGATORS_COEUS ADD AWARD_NUMBER VARCHAR2(12)
/
update AWARD_INVESTIGATORS_COEUS set AWARD_NUMBER = replace(mit_award_number,'-','-00')
/
commit
/
update AWARD_INVESTIGATORS_COEUS t1 set t1.AWARD_NUMBER = (select s1.change_award_number 
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
