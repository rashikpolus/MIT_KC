set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
set heading off;
DECLARE
li_coeus_count number;
li_kuali_count number;
CURSOR c_ip IS
SELECT PROPOSAL_NUMBER FROM TEMP_TAB_TO_SYNC_DEV;
r_ip c_ip%ROWTYPE;

BEGIN
IF c_ip%ISOPEN THEN
CLOSE c_ip;
END IF;
OPEN c_ip;
LOOP
FETCH c_ip INTO r_ip;
EXIT WHEN c_ip%NOTFOUND;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$EPS_PROPOSAL@coeus.kuali  where 
PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from EPS_PROPOSAL  where 
PROPOSAL_NUMBER=to_number(r_ip.PROPOSAL_NUMBER);
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in EPS_PROPOSAL row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER);
END IF;	


END LOOP;
CLOSE c_ip;
END;
/