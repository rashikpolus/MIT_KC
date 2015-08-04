TRUNCATE TABLE EPS_PROP_IDC_RATE
/
DECLARE
ls_doc_nbr VARCHAR2(40);
li_ver_nbr number:=1;
li_loop_count number;
ls_proposal_number	VARCHAR2(12);
li_budget_id	NUMBER(12,0);
ls_prop	VARCHAR2(12):=NULL;
li_unrecovered_fna_id NUMBER(5,0);
li_budget_ver	NUMBER(3,0);
ls_hide_in_hierarchy CHAR(1):='N';
ls_hierarchy_prop_num VARCHAR2(12):=NULL;
ls_source_account VARCHAR2(32);
BEGIN 
li_loop_count:=0;
for r_idc in ( SELECT * FROM OSP$EPS_PROP_IDC_RATE@coeus.kuali order by PROPOSAL_NUMBER ,VERSION_NUMBER, FISCAL_YEAR)
LOOP   
select to_number(r_idc.PROPOSAL_NUMBER) into ls_proposal_number from dual;      
BEGIN
SELECT t.DOCUMENT_NUMBER INTO ls_doc_nbr FROM  TEMP_LOOKUP_FOR_PROPOSAL t WHERE t.PROPOSAL_NUMBER=ls_proposal_number;
EXCEPTION
WHEN NO_DATA_FOUND THEN
SELECT e.DOCUMENT_NUMBER INTO ls_doc_nbr FROM  EPS_PROPOSAL e WHERE e.PROPOSAL_NUMBER=ls_proposal_number;
END;

BEGIN
SELECT  HIERARCHY_PROPOSAL_NUMBER INTO ls_hierarchy_prop_num FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER = ls_proposal_number;
EXCEPTION
WHEN OTHERS THEN
ls_hierarchy_prop_num:=NULL;
END;

select substr(r_idc.SOURCE_ACCOUNT, 1, 32) into ls_source_account from dual;
begin
li_budget_ver:=r_idc.VERSION_NUMBER; 
SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =li_budget_ver AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_proposal_number)AND VER_NBR =li_budget_ver); 
exception
when others then
dbms_output.put_line('Error while fetching BUDGET_ID using PROPOSAL_NUMBER:'||ls_proposal_number||'and VERSION_NUMBER:'||li_budget_ver||'and error is:'||sqlerrm);
end;

IF ls_prop IS NULL THEN
	li_unrecovered_fna_id := 1;
	ls_prop := r_idc.PROPOSAL_NUMBER;
ELSIF ls_prop = r_idc.PROPOSAL_NUMBER THEN
	li_unrecovered_fna_id := li_unrecovered_fna_id+1;
ELSIF ls_prop <> r_idc.PROPOSAL_NUMBER THEN
	li_unrecovered_fna_id := 1;
	ls_prop := r_idc.PROPOSAL_NUMBER;
END IF;

BEGIN
--SELECT  SEQ_UNRECOVERED_FNA_ID.NEXTVAL INTO li_unrecovered_fna_id  FROM DUAL;      
INSERT INTO EPS_PROP_IDC_RATE(BUDGET_ID,UNRECOVERED_FNA_ID,BUDGET_VERSION_NUMBER,FISCAL_YEAR,UNDERRECOVERY_OF_IDC,APPLICABLE_IDC_RATE,ON_CAMPUS_FLAG,SOURCE_ACCOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,PROPOSAL_NUMBER,HIERARCHY_PROPOSAL_NUMBER,HIDE_IN_HIERARCHY,OBJ_ID)
VALUES(li_budget_id,li_unrecovered_fna_id,li_budget_ver,r_idc.FISCAL_YEAR,r_idc.UNDERRECOVERY_OF_IDC,r_idc.APPLICABLE_IDC_RATE,r_idc.ON_CAMPUS_FLAG,ls_source_account,r_idc.UPDATE_TIMESTAMP,r_idc.UPDATE_USER,li_ver_nbr,ls_proposal_number,ls_hierarchy_prop_num,ls_hide_in_hierarchy,SYS_GUID());
li_loop_count:=li_loop_count+1; 
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('Exception in EPS_PROP_IDC_RATE ,for the proposal '||ls_proposal_number||' in  '||li_loop_count||' occurance'||SQLERRM);
END;
END LOOP;
commit;
dbms_output.put_line(CHR(10));
dbms_output.put_line('Successfull completed EPS_PROP_IDC_RATE ');

dbms_output.put_line('------------------Row Counts----------------');  
dbms_output.put_line('EPS_PROP_IDC_RATE : '||li_loop_count);
END;