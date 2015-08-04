select ' Started EPS_PROP_COST_SHARING ' from dual
/
-- delete 
DECLARE
li_ver_nbr number(8):=1;
li_budget_id number(12);
ls_property_name VARCHAR2(200);
li_cost_share number(5);
ls_hierarchy_prop_num varchar2(12);
ls_hide_in_hierarchy char(1):='N';
ls_source_account VARCHAR2(32);
li_count_cs number;
BEGIN
	for  r_cost in (
	SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.FISCAL_YEAR,t1.SOURCE_ACCOUNT,t1.COST_SHARING_PERCENTAGE,
	t1.AMOUNT,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER FROM OSP$EPS_PROP_COST_SHARING@coeus.kuali t1
	INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER
	)
LOOP

	begin
	SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_cost.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=r_cost.PROPOSAL_NUMBER)AND VER_NBR =r_cost.VERSION_NUMBER);
	exception
	when others then
	dbms_output.put_line('Error while fetching BUDGET_ID using PROPOSAL_NUMBER:'||r_cost.PROPOSAL_NUMBER||'and VERSION_NUMBER:'||r_cost.VERSION_NUMBER||'and error is:'||sqlerrm);
	end;

	DELETE FROM EPS_PROP_COST_SHARING WHERE BUDGET_ID = li_budget_id;
	
END LOOP;

END;
/
commit
/
DECLARE
li_ver_nbr number(8):=1;
li_budget_id number(12);
ls_property_name VARCHAR2(200);
li_cost_share number(5);
ls_hierarchy_prop_num varchar2(12);
ls_hide_in_hierarchy char(1):='N';
ls_source_account VARCHAR2(32);
li_count_cs number;
BEGIN

for  r_cost in (SELECT to_number(t1.PROPOSAL_NUMBER) PROPOSAL_NUMBER,t1.VERSION_NUMBER,t1.FISCAL_YEAR,t1.SOURCE_ACCOUNT,t1.COST_SHARING_PERCENTAGE,
t1.AMOUNT,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER FROM OSP$EPS_PROP_COST_SHARING@coeus.kuali t1
INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER
)
LOOP
ls_property_name:='BUDGET_COST_SHARE_KEY';
BEGIN
SELECT  HIERARCHY_PROPOSAL_NUMBER INTO ls_hierarchy_prop_num FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER = r_cost.PROPOSAL_NUMBER;
EXCEPTION
WHEN OTHERS THEN
ls_hierarchy_prop_num:=NULL;
END;

begin
SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =r_cost.VERSION_NUMBER AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=r_cost.PROPOSAL_NUMBER)AND VER_NBR =r_cost.VERSION_NUMBER);
exception
when others then
dbms_output.put_line('Error while fetching BUDGET_ID using PROPOSAL_NUMBER:'||r_cost.PROPOSAL_NUMBER||'and VERSION_NUMBER:'||r_cost.VERSION_NUMBER||'and error is:'||sqlerrm);
end;

BEGIN
select substr(r_cost.SOURCE_ACCOUNT, 1, 32) into ls_source_account from dual;
li_cost_share:=FN_DOCUMENT_NEXTVAL(li_budget_id,ls_property_name);
INSERT INTO EPS_PROP_COST_SHARING(BUDGET_ID,COST_SHARE_ID,PROPOSAL_NUMBER,BUDGET_VERSION_NUMBER,PROJECT_PERIOD,AMOUNT,COST_SHARING_PERCENTAGE,SOURCE_ACCOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,HIERARCHY_PROPOSAL_NUMBER,HIDE_IN_HIERARCHY,OBJ_ID)
VALUES(li_budget_id,li_cost_share,r_cost.PROPOSAL_NUMBER,r_cost.VERSION_NUMBER,r_cost.FISCAL_YEAR,r_cost.AMOUNT,r_cost.COST_SHARING_PERCENTAGE,ls_source_account,r_cost.UPDATE_TIMESTAMP,r_cost.UPDATE_USER,li_ver_nbr,ls_hierarchy_prop_num,ls_hide_in_hierarchy,SYS_GUID());
EXCEPTION 
WHEN OTHERS THEN                   
dbms_output.put_line('Error in EPS_PROP_COST_SHARING '||substr(sqlerrm,1,200));
END;
END LOOP;

END;
/
select ' Ended of EPS_PROP_COST_SHARING ' from dual
/