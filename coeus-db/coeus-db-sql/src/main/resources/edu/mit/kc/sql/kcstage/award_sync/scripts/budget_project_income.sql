select ' Started BUDGET_PROJECT_INCOME ' from dual
/
DECLARE
	li_budget_id number(12);
CURSOR c_project IS
SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.BUDGET_PERIOD,t1.INCOME_NUMBER,t1.AMOUNT,t1.DESCRIPTION,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER 
FROM OSP$BUDGET_PROJECT_INCOME@coeus.kuali t1
INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_project c_project%ROWTYPE;

BEGIN
IF c_project%ISOPEN THEN
CLOSE c_project;
END IF;
OPEN c_project;
LOOP
FETCH c_project INTO r_project;
EXIT WHEN c_project%NOTFOUND;


	begin
	SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_project.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=r_project.PROPOSAL_NUMBER)AND VER_NBR =r_project.VERSION_NUMBER);
	exception
	when others then
	dbms_output.put_line('Error while fetching BUDGET_ID with PROPOSAL_NUMBER:'||r_project.PROPOSAL_NUMBER||'and version_number:'||r_project.VERSION_NUMBER||'and error is:'||substr(sqlerrm,1,100));
	continue;
	end;

	delete from BUDGET_PROJECT_INCOME where BUDGET_ID = li_budget_id;

END LOOP;
CLOSE c_project;
       
END;
/
commit
/
DECLARE
li_ver_nbr number(8):=1;
li_budget_id number(12);
ls_hide_in_hierarchy char(1):='N';
ls_hierarchy_prop_num varchar2(12);
li_project_income number(5);
ls_property_name VARCHAR2(200);
li_bud_period number(12);
li_count_pjt_incm number;
CURSOR c_project IS
SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.BUDGET_PERIOD,t1.INCOME_NUMBER,t1.AMOUNT,t1.DESCRIPTION,
t1.UPDATE_TIMESTAMP,t1.UPDATE_USER 
FROM OSP$BUDGET_PROJECT_INCOME@coeus.kuali t1
INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_project c_project%ROWTYPE;

BEGIN
IF c_project%ISOPEN THEN
CLOSE c_project;
END IF;
OPEN c_project;
LOOP
FETCH c_project INTO r_project;
EXIT WHEN c_project%NOTFOUND;


BEGIN
SELECT  HIERARCHY_PROPOSAL_NUMBER INTO ls_hierarchy_prop_num FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER = r_project.PROPOSAL_NUMBER;
EXCEPTION
WHEN OTHERS THEN
ls_hierarchy_prop_num:=NULL;
END;

ls_property_name:='BUDGET_PROJECT_INCOME_KEY';
begin
SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_project.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=r_project.PROPOSAL_NUMBER)AND VER_NBR =r_project.VERSION_NUMBER);
exception
when others then
dbms_output.put_line('Error while fetching BUDGET_ID with PROPOSAL_NUMBER:'||r_project.PROPOSAL_NUMBER||'and version_number:'||r_project.VERSION_NUMBER||'and error is:'||substr(sqlerrm,1,100));
end;
begin
SELECT BUDGET_PERIOD_NUMBER INTO li_bud_period FROM BUDGET_PERIODS WHERE BUDGET_ID=li_budget_id and budget_period=r_project.BUDGET_PERIOD;
exception
when others then
dbms_output.put_line('Error while fetching BUDGET_PERIOD_NUMBER with BUDGET_ID:'||li_budget_id||'and budget_period:'||r_project.BUDGET_PERIOD||'and error is:'||substr(sqlerrm,1,100));
end;
BEGIN
li_project_income:=FN_DOCUMENT_NEXTVAL(li_budget_id,ls_property_name);
INSERT INTO BUDGET_PROJECT_INCOME(BUDGET_ID,PROJECT_INCOME_ID,BUDGET_PERIOD_NUMBER,PROPOSAL_NUMBER,BUDGET_VERSION_NUMBER,BUDGET_PERIOD,AMOUNT,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,HIERARCHY_PROPOSAL_NUMBER,HIDE_IN_HIERARCHY,OBJ_ID)
VALUES(li_budget_id,li_project_income,li_bud_period,r_project.PROPOSAL_NUMBER,r_project.VERSION_NUMBER,r_project.BUDGET_PERIOD,r_project.AMOUNT,r_project.DESCRIPTION,r_project.UPDATE_TIMESTAMP,r_project.UPDATE_USER,li_ver_nbr,ls_hierarchy_prop_num,ls_hide_in_hierarchy,SYS_GUID());

EXCEPTION                     

WHEN OTHERS THEN                   
dbms_output.put_line('Error in BUDGET_PROJECT_INCOME '||substr(sqlerrm,1,200));
END;

END LOOP;
CLOSE c_project;       
END;
/
select ' Ended BUDGET_PROJECT_INCOME ' from dual
/