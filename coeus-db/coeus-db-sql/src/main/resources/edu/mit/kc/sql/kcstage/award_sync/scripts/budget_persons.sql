select ' Started BUDGET_PERSONS ' from dual
/
DECLARE
ls_doc_nbr VARCHAR2(40);
li_ver_nbr number:=1;
li_loop_count number;
ls_proposal_number	VARCHAR2(12);
li_budget_id	NUMBER(12,0);
li_per_seq_number NUMBER(3,0);
li_budget_ver	NUMBER(3,0);
ls_hide_in_hierarchy CHAR(1):='N';
ls_hierarchy_prop_num VARCHAR2(12):=NULL;
li_rolodex_id VARCHAR2(9);  
ls_tbn_id VARCHAR2(9); 
li_person_id VARCHAR2(40);
ls_appointment_typ_cd varchar2(3);
li_error_count number;
li_rolodex_count number;
li_count_bud_persn number;
li_count number;

CURSOR c_bud IS
SELECT bm.PROPOSAL_NUMBER,bm.VERSION_NUMBER,t3.BUDGET_ID,bm.PERSON_ID,bm.JOB_CODE,bm.EFFECTIVE_DATE,bm.CALCULATION_BASE,bm.APPOINTMENT_TYPE,
bm.UPDATE_TIMESTAMP,bm.UPDATE_USER,bm.PERSON_NAME,bm.NON_EMPLOYEE_FLAG,bm.SALARY_ANNIVERSARY_DATE,bm.BASE_SALARY_P1,bm.BASE_SALARY_P2,
bm.BASE_SALARY_P3,bm.BASE_SALARY_P4,bm.BASE_SALARY_P5,bm.BASE_SALARY_P6,bm.BASE_SALARY_P7,bm.BASE_SALARY_P8,bm.BASE_SALARY_P9,bm.BASE_SALARY_P10
 FROM OSP$BUDGET_PERSONS@coeus.kuali bm
INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on bm.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and bm.VERSION_NUMBER = t2.VERSION_NUMBER
INNER JOIN TEMP_BUDGET_MAIN t3 on bm.PROPOSAL_NUMBER=t3.PROPOSAL_NUM and bm.VERSION_NUMBER=t3.BUDGET_VER_NUM
ORDER BY bm.PROPOSAL_NUMBER,bm.VERSION_NUMBER;
r_bud c_bud%ROWTYPE;

BEGIN
IF c_bud%ISOPEN THEN
CLOSE c_bud;
END IF;
OPEN c_bud;
li_loop_count:=0;
li_error_count:=0;
LOOP
FETCH c_bud INTO r_bud;
EXIT WHEN c_bud%NOTFOUND;
SELECT to_number(r_bud.PROPOSAL_NUMBER) INTO ls_proposal_number from dual; 
BEGIN
SELECT  HIERARCHY_PROPOSAL_NUMBER INTO ls_hierarchy_prop_num FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER = ls_proposal_number;
EXCEPTION
WHEN OTHERS THEN
ls_hierarchy_prop_num:=NULL;
END; 

begin
IF r_bud.NON_EMPLOYEE_FLAG ='N' THEN 
  
 select count(rolodex_id) into li_rolodex_count from ROLODEX where to_char(rolodex_id)=r_bud.PERSON_ID;		  
 if li_rolodex_count = 0 then
	li_person_id:=r_bud.PERSON_ID;
	ls_tbn_id:=r_bud.PERSON_ID;
	li_rolodex_id:=null;
else
 li_rolodex_id:=r_bud.PERSON_ID;
 li_person_id:=null;
 ls_tbn_id:=null;
 end if;       
 
ELSE
 li_rolodex_id:=r_bud.PERSON_ID;
 li_person_id:=null;
 ls_tbn_id:=null;
END IF;
exception when others then
li_person_id := r_bud.PERSON_ID;           
li_rolodex_id := null;
end;
--end;

if     r_bud.APPOINTMENT_TYPE='SUM EMPLOYEE' then
	ls_appointment_typ_cd:='2';
elsif  r_bud.APPOINTMENT_TYPE='REG EMPLOYEE' then
	ls_appointment_typ_cd:='7';-- code for 12M duration
elsif  r_bud.APPOINTMENT_TYPE='TMP EMPLOYEE' then   
	ls_appointment_typ_cd:='1';     
elsif  r_bud.APPOINTMENT_TYPE='9M DURATION' then   
	ls_appointment_typ_cd:='3';
elsif  r_bud.APPOINTMENT_TYPE='10M DURATION' then   
	ls_appointment_typ_cd:='4';
elsif  r_bud.APPOINTMENT_TYPE='11M DURATION' then   
	ls_appointment_typ_cd:='5';
elsif  r_bud.APPOINTMENT_TYPE='12M DURATION' or r_bud.APPOINTMENT_TYPE='12M EMPLOYEE' then   
	ls_appointment_typ_cd:='6';       
else
	  ls_appointment_typ_cd:='1';     
end if;
/*
SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_bud.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_proposal_number)AND VER_NBR =r_bud.VERSION_NUMBER); 
*/
select t1.budget_id  INTO li_budget_id from budget t1 
		inner join eps_proposal_budget_ext t2 on t1.budget_id = t2.budget_id
		where t2.proposal_number = ls_proposal_number
		and t1.version_number = r_bud.VERSION_NUMBER;

BEGIN
li_per_seq_number:=FN_DOCUMENT_NEXTVAL(li_budget_id,'personSequenceNumber');
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('BUDGET_ID:'||li_budget_id);
END;


select count(*) into li_count FROM BUDGET_PERSONS where BUDGET_ID=r_bud.BUDGET_ID AND PERSON_ID=r_bud.PERSON_ID OR ROLODEX_ID=r_bud.PERSON_ID;

IF li_count=0 THEN

INSERT INTO  BUDGET_PERSONS(PERSON_SEQUENCE_NUMBER,BUDGET_ID,ROLODEX_ID,APPOINTMENT_TYPE_CODE,TBN_ID,HIERARCHY_PROPOSAL_NUMBER,HIDE_IN_HIERARCHY,PERSON_ID,JOB_CODE,EFFECTIVE_DATE,CALCULATION_BASE,PERSON_NAME,NON_EMPLOYEE_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,SALARY_ANNIVERSARY_DATE)
VALUES(li_per_seq_number,li_budget_id,li_rolodex_id,ls_appointment_typ_cd,ls_tbn_id,ls_hierarchy_prop_num,ls_hide_in_hierarchy,li_person_id,r_bud.JOB_CODE,r_bud.EFFECTIVE_DATE,r_bud.CALCULATION_BASE,r_bud.PERSON_NAME,r_bud.NON_EMPLOYEE_FLAG,r_bud.UPDATE_TIMESTAMP,r_bud.UPDATE_USER,li_ver_nbr,SYS_GUID(),r_bud.SALARY_ANNIVERSARY_DATE);

ELSE

	UPDATE BUDGET_PERSONS SET
	ROLODEX_ID = li_rolodex_id,
	APPOINTMENT_TYPE_CODE = ls_appointment_typ_cd,
	TBN_ID = ls_tbn_id,
	HIERARCHY_PROPOSAL_NUMBER = ls_hierarchy_prop_num,
	HIDE_IN_HIERARCHY = ls_hide_in_hierarchy,
	JOB_CODE = r_bud.JOB_CODE,
	EFFECTIVE_DATE = r_bud.EFFECTIVE_DATE,
	CALCULATION_BASE = r_bud.CALCULATION_BASE,
	PERSON_NAME = r_bud.PERSON_NAME,
	NON_EMPLOYEE_FLAG = r_bud.NON_EMPLOYEE_FLAG,
	UPDATE_TIMESTAMP = r_bud.UPDATE_TIMESTAMP,
	UPDATE_USER = r_bud.UPDATE_USER,
	SALARY_ANNIVERSARY_DATE = r_bud.SALARY_ANNIVERSARY_DATE
	WHERE BUDGET_ID=r_bud.BUDGET_ID AND PERSON_ID=r_bud.PERSON_ID OR ROLODEX_ID=r_bud.PERSON_ID;
	

END IF;

END LOOP;
CLOSE c_bud;
END;
/
select ' Ended BUDGET_PERSONS ' from dual
/