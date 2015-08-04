UPDATE budget_category_type SET description = 'Summary Items' WHERE budget_category_type_code = 'N'
/
commit
/
declare
  li_count number;
begin
  select count(cost_element) into li_count from cost_element where cost_element = '422117';
  if li_count = 0 then
    INSERT INTO cost_element(cost_element, description, budget_category_code, on_off_campus_flag, update_timestamp,
								update_user,  ver_nbr, obj_id, active_flag, fin_object_code )
    VALUES('422117', 'Direct Costs Summary', 38, 'N', sysdate, 'admin', 1, sys_guid(),'Y', null );	
  end if;
  
  select count(cost_element) into li_count from cost_element where cost_element = '422121';
  if li_count = 0 then
    INSERT INTO cost_element(cost_element, description, budget_category_code, on_off_campus_flag, update_timestamp,
								update_user,  ver_nbr, obj_id, active_flag, fin_object_code )
    VALUES('422121', 'Indirect Costs Summary', 38, 'N', sysdate, 'admin', 1, sys_guid(),'Y', null );	
  end if;
  
  select count(cost_element) into li_count from cost_element where cost_element = '422123';
  if li_count = 0 then
    INSERT INTO cost_element(cost_element, description, budget_category_code, on_off_campus_flag, update_timestamp,
								update_user,  ver_nbr, obj_id, active_flag, fin_object_code )
    VALUES('422123', 'Budget-Fund Fee', 38, 'N', sysdate, 'admin', 1, sys_guid(),'Y', null );	
  end if;
  
  select count(cost_element) into li_count from cost_element where cost_element = '422127';
  if li_count = 0 then
    INSERT INTO cost_element(cost_element, description, budget_category_code, on_off_campus_flag, update_timestamp,
								update_user,  ver_nbr, obj_id, active_flag, fin_object_code )
    VALUES('422127', 'EB Costs Summary', 38, 'N', sysdate, 'admin', 1, sys_guid(),'Y', null );	
  end if;
  
  select count(cost_element) into li_count from cost_element where cost_element = '422139';
  if li_count = 0 then
    INSERT INTO cost_element(cost_element, description, budget_category_code, on_off_campus_flag, update_timestamp,
								update_user,  ver_nbr, obj_id, active_flag, fin_object_code )
    VALUES('422139', 'Budget - Interest Income', 38, 'N', sysdate, 'admin', 1, sys_guid(),'Y', null );	
  end if;  
  
end;
/
ALTER TABLE BUDGET_DETAILS DISABLE CONSTRAINT FK_BUDGET_COST
/
ALTER TABLE VALID_CE_JOB_CODES DISABLE CONSTRAINT VALID_CE_JOB_CODES_COST_E_FK1
/
ALTER TABLE VALID_CE_RATE_TYPES DISABLE CONSTRAINT FK_VALID_CE_RATE_TYPES_CE_KRA
/
ALTER TABLE AWD_BGT_PER_SUM_CALC_AMT DISABLE CONSTRAINT FK2_AWARD_BGT_SUMM_CLAC_AMT
/

UPDATE COST_ELEMENT SET COST_ELEMENT = '422125', description = 'Budget - Closeout Adjustment', budget_category_code = 38
WHERE COST_ELEMENT = 'PCLOSE'
/
UPDATE BUDGET_DETAILS SET COST_ELEMENT = '422125' WHERE COST_ELEMENT = 'PCLOSE'
/
UPDATE AWD_BGT_PER_SUM_CALC_AMT SET COST_ELEMENT = '422125' WHERE COST_ELEMENT = 'PCLOSE'
/
UPDATE SAP_BUDGET_FEED SET COST_ELEMENT = '422125' WHERE COST_ELEMENT = 'PCLOSE'
/
UPDATE VALID_CE_JOB_CODES SET COST_ELEMENT = '422125' WHERE COST_ELEMENT = 'PCLOSE'
/
UPDATE VALID_CE_RATE_TYPES SET COST_ELEMENT = '422125' WHERE COST_ELEMENT = 'PCLOSE'
/


UPDATE COST_ELEMENT SET COST_ELEMENT = '422131', description = 'Budget - Incremental Costs', budget_category_code = 38
WHERE COST_ELEMENT = 'PINCRT'
/
UPDATE BUDGET_DETAILS SET COST_ELEMENT = '422131' WHERE COST_ELEMENT = 'PINCRT'
/
UPDATE AWD_BGT_PER_SUM_CALC_AMT SET COST_ELEMENT = '422131' WHERE COST_ELEMENT = 'PINCRT'
/
UPDATE SAP_BUDGET_FEED SET COST_ELEMENT = '422131' WHERE COST_ELEMENT = 'PINCRT'
/
UPDATE VALID_CE_JOB_CODES SET COST_ELEMENT = '422131' WHERE COST_ELEMENT = 'PINCRT'
/
UPDATE VALID_CE_RATE_TYPES SET COST_ELEMENT = '422131' WHERE COST_ELEMENT = 'PINCRT'
/


UPDATE COST_ELEMENT SET COST_ELEMENT = '422141', description = 'Carryforwards Budgets', budget_category_code = 38
WHERE COST_ELEMENT = 'PCARRY'
/
UPDATE BUDGET_DETAILS SET COST_ELEMENT = '422141' WHERE COST_ELEMENT = 'PCARRY'
/
UPDATE AWD_BGT_PER_SUM_CALC_AMT SET COST_ELEMENT = '422141' WHERE COST_ELEMENT = 'PCARRY'
/
UPDATE SAP_BUDGET_FEED SET COST_ELEMENT = '422141' WHERE COST_ELEMENT = 'PCARRY'
/
UPDATE VALID_CE_JOB_CODES SET COST_ELEMENT = '422141' WHERE COST_ELEMENT = 'PCARRY'
/
UPDATE VALID_CE_RATE_TYPES SET COST_ELEMENT = '422141' WHERE COST_ELEMENT = 'PCARRY'
/

--UPDATE BUDGET_DETAILS SET COST_ELEMENT = '422117' WHERE COST_ELEMENT = '400000'
/
ALTER TABLE BUDGET_DETAILS ENABLE CONSTRAINT FK_BUDGET_COST
/
ALTER TABLE VALID_CE_JOB_CODES ENABLE CONSTRAINT VALID_CE_JOB_CODES_COST_E_FK1
/
ALTER TABLE VALID_CE_RATE_TYPES ENABLE CONSTRAINT FK_VALID_CE_RATE_TYPES_CE_KRA
/
ALTER TABLE AWD_BGT_PER_SUM_CALC_AMT ENABLE CONSTRAINT FK2_AWARD_BGT_SUMM_CLAC_AMT
/
