set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
set heading off;
DECLARE
li_coeus_count number;
li_kuali_count number;
li_proposal_id number(12);
CURSOR c_ip IS
SELECT PROPOSAL_NUMBER,SEQUENCE_NUMBER FROM TEMP_TAB_TO_SYNC_IP;
r_ip c_ip%ROWTYPE;

BEGIN
IF c_ip%ISOPEN THEN
CLOSE c_ip;
END IF;
OPEN c_ip;
LOOP
FETCH c_ip INTO r_ip;
EXIT WHEN c_ip%NOTFOUND;

select PROPOSAL_ID INTO li_proposal_id FROM PROPOSAL WHERE  PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER AND SEQUENCE_NUMBER=r_ip.SEQUENCE_NUMBER;

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$PROPOSAL@coeus.kuali  where 
    PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER and SEQUENCE_NUMBER=r_ip.SEQUENCE_NUMBER;

	select count(1) KC_AwardCustom_Count into li_kuali_count from PROPOSAL  where 
    PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER and SEQUENCE_NUMBER=r_ip.SEQUENCE_NUMBER;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in PROPOSAL row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER);
END IF;	

select count(1) Coeus_AwardCustom_Count into li_coeus_count  from OSP$PROPOSAL_ADMIN_DETAILS@coeus.kuali  where 
    INST_PROPOSAL_NUMBER=r_ip.PROPOSAL_NUMBER and INST_PROP_SEQUENCE_NUMBER=r_ip.SEQUENCE_NUMBER;

select count(1) KC_AwardCustom_Count into li_kuali_count from PROPOSAL_ADMIN_DETAILS  where 
    INST_PROPOSAL_ID=li_proposal_id;
    
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in PROPOSAL row count for PROPOSAL_NUMBER:'|| r_ip.PROPOSAL_NUMBER);
END IF;	


END LOOP;
CLOSE c_ip;
END;
/