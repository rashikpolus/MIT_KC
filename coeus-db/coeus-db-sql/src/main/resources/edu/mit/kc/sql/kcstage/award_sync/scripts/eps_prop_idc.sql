select ' Started EPS_PROP_IDC_RATE script ' from dual
/
DECLARE
ls_doc_nbr VARCHAR2(40);
li_ver_nbr number:=1;
li_loop_count number;
ls_proposal_number	VARCHAR2(12);
li_budget_id	NUMBER(12,0);
li_unrecovered_fna_id NUMBER(5,0);
li_budget_ver	NUMBER(3,0);
ls_hide_in_hierarchy CHAR(1):='N';
ls_hierarchy_prop_num VARCHAR2(12):=NULL;
ls_source_account VARCHAR2(32);

CURSOR c_idc IS
SELECT t1.* FROM OSP$EPS_PROP_IDC_RATE@coeus.kuali t1 
 INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_idc c_idc%ROWTYPE;

BEGIN
IF c_idc%ISOPEN THEN
CLOSE c_idc;
END IF;
OPEN c_idc;
li_loop_count:=0;
LOOP
FETCH c_idc INTO r_idc;
EXIT WHEN c_idc%NOTFOUND;
	select to_number(r_idc.PROPOSAL_NUMBER) into ls_proposal_number from dual;


	BEGIN
		li_budget_ver:=r_idc.VERSION_NUMBER; 	
		SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =li_budget_ver AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_proposal_number)AND VER_NBR =li_budget_ver);
		DELETE FROM EPS_PROP_IDC_RATE WHERE BUDGET_ID = li_budget_id;

	EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('Exception in EPS_PROP_IDC_RATE ,for the proposal '||ls_proposal_number||' in  '||li_loop_count||' occurance'||SQLERRM);
	END;
END LOOP;
CLOSE c_idc;
END;
/       
commit
/
DECLARE
ls_doc_nbr VARCHAR2(40);
li_ver_nbr number:=1;
li_loop_count number;
ls_proposal_number	VARCHAR2(12);
li_budget_id	NUMBER(12,0);
li_unrecovered_fna_id NUMBER(5,0);
li_budget_ver	NUMBER(3,0);
ls_hide_in_hierarchy CHAR(1):='N';
ls_hierarchy_prop_num VARCHAR2(12):=NULL;
ls_source_account VARCHAR2(32);

CURSOR c_idc IS
SELECT t1.* FROM OSP$EPS_PROP_IDC_RATE@coeus.kuali t1
INNER JOIN TEMP_TAB_TO_SYNC_BUDGET t2 on t1.PROPOSAL_NUMBER = t2.PROPOSAL_NUMBER and t1.VERSION_NUMBER = t2.VERSION_NUMBER;
r_idc c_idc%ROWTYPE;

BEGIN
    IF c_idc%ISOPEN THEN
    CLOSE c_idc;
    END IF;
    OPEN c_idc;
    li_loop_count:=0;
    LOOP
    FETCH c_idc INTO r_idc;
    EXIT WHEN c_idc%NOTFOUND;
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
    
    BEGIN
    SELECT  SEQ_UNRECOVERED_FNA_ID.NEXTVAL INTO li_unrecovered_fna_id  FROM DUAL;      
    li_budget_ver:=r_idc.VERSION_NUMBER; 
    SELECT BUDGET_ID INTO li_budget_id FROM BUDGET WHERE version_number =li_budget_ver AND document_number=(SELECT DOCUMENT_NUMBER FROM BUDGET_DOCUMENT WHERE PARENT_DOCUMENT_KEY =(SELECT DOCUMENT_NUMBER FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=ls_proposal_number)AND VER_NBR =li_budget_ver);
    INSERT INTO EPS_PROP_IDC_RATE(BUDGET_ID,UNRECOVERED_FNA_ID,BUDGET_VERSION_NUMBER,FISCAL_YEAR,UNDERRECOVERY_OF_IDC,APPLICABLE_IDC_RATE,ON_CAMPUS_FLAG,SOURCE_ACCOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,PROPOSAL_NUMBER,HIERARCHY_PROPOSAL_NUMBER,HIDE_IN_HIERARCHY,OBJ_ID)
    VALUES(li_budget_id,li_unrecovered_fna_id,li_budget_ver,r_idc.FISCAL_YEAR,r_idc.UNDERRECOVERY_OF_IDC,r_idc.APPLICABLE_IDC_RATE,r_idc.ON_CAMPUS_FLAG,ls_source_account,r_idc.UPDATE_TIMESTAMP,r_idc.UPDATE_USER,li_ver_nbr,ls_proposal_number,ls_hierarchy_prop_num,ls_hide_in_hierarchy,SYS_GUID());
      li_loop_count:=li_loop_count+1; 
    EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('Exception in EPS_PROP_IDC_RATE ,for the proposal '||ls_proposal_number||' in  '||li_loop_count||' occurance'||SQLERRM);
     END;
   END LOOP;
   CLOSE c_idc; 
END;
/
select ' Ended EPS_PROP_IDC_RATE script ' from dual
/