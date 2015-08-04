set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
set heading off;
DECLARE
li_coeus_count number;
li_kuali_count number;
li_budget_id number;
CURSOR c_ip IS
SELECT PROPOSAL_NUMBER,VERSION_NUMBER FROM TEMP_TAB_TO_SYNC_BUDGET;
r_ip c_ip%ROWTYPE;

BEGIN
IF c_ip%ISOPEN THEN
CLOSE c_ip;
END IF;
OPEN c_ip;
LOOP
FETCH c_ip INTO r_ip;
EXIT WHEN c_ip%NOTFOUND;

--SELECT DOCUMENT_NUMBER into ls_doc FROM EPS_PROPOSAL WHERE PROPOSAL_NUMBER=to_number(r_ip.PROPOSAL_NUMBER);
SELECT BUDGET_ID INTO li_budget_id FROM TEMP_BUDGET_MAIN WHERE PROPOSAL_NUM=r_ip.PROPOSAL_NUMBER AND BUDGET_VER_NUM=r_ip.VERSION_NUMBER;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET@coeus.kuali  where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;	

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_DETAILS@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_DETAILS  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_DETAILS row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;	

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_MODULAR@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_MODULAR  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_DETAILS row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;	

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_MODULAR_IDC@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_MODULAR_IDC  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_MODULAR_IDC row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;	

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_PERIODS@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_PERIODS  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_PERIODS row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_PERSONNEL_DETAILS@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_PERSONNEL_DETAILS  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_PERSONNEL_DETAILS row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;



select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_PERSONNEL_CAL_AMTS@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_PERSONNEL_CAL_AMTS  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_PERSONNEL_CAL_AMTS row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUD_PER_DET_RATE_AND_BASE@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_PER_DET_RATE_AND_BASE  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_PER_DET_RATE_AND_BASE row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_PERSONS@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_PERSONS  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_PERSONS row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$EPS_PROP_COST_SHARING@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from EPS_PROP_COST_SHARING  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in EPS_PROP_COST_SHARING row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;


select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$EPS_PROP_IDC_RATE@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from EPS_PROP_IDC_RATE  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in EPS_PROP_IDC_RATE row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$EPS_PROP_RATES@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from EPS_PROP_RATES  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in EPS_PROP_RATES row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$EPS_PROP_LA_RATES@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from EPS_PROP_LA_RATES  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in EPS_PROP_LA_RATES row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_DETAILS_CAL_AMTS@coeus.kuali   where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_DETAILS_CAL_AMTS  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_DETAILS_CAL_AMTS row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$BUDGET_RATE_AND_BASE@coeus.kuali  where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND VERSION_NUMBER=r_ip.VERSION_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from BUDGET_RATE_AND_BASE  where 
BUDGET_ID=li_budget_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in BUDGET_RATE_AND_BASE row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER||' and VERSION_NUMBER:'||r_ip.VERSION_NUMBER);
END IF;

END LOOP;
CLOSE c_ip;
END;
/