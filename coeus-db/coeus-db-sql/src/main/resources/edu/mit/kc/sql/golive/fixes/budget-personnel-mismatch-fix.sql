
declare
cursor c_budget is
  select budget_id  
  from EPS_PROPOSAL_BUDGET_EXT
  where proposal_number in ('22751');

cursor c_budget_detail(v_budget_id IN NUMBER) is
SELECT budget_details_id, cost_element, budget_category_code
  FROM budget_details
 WHERE budget_id = v_budget_id;

li_count NUMBER(10);
li_BUDGET_CATEGORY_CODE   VARCHAR2 (3);
li_per_b_cat_type_code VARCHAR2(3);
li_ce_category_type VARCHAR2(3);
 
begin

SELECT VAL INTO li_per_b_cat_type_code FROM KRCR_PARM_T k
WHERE k.NMSPC_CD = 'KC-B' AND K.CMPNT_CD = 'Document' AND k.PARM_NM = 'budgetCategoryType.personnel';

FOR budget_rec in c_budget
LOOP

	FOR budget_det_rec in c_budget_detail(budget_rec.budget_id)
	LOOP
		SELECT budget_category_code INTO li_BUDGET_CATEGORY_CODE
		from COST_ELEMENT where cost_element = budget_det_rec.cost_element;
		
		SELECT category_type INTO li_ce_category_type
		from budget_category where budget_category_code = li_BUDGET_CATEGORY_CODE;
		
		SELECT COUNT(*) 
		into li_count
		FROM BUDGET_PERSONNEL_DETAILS b where b.BUDGET_DETAILS_ID = budget_det_rec.BUDGET_DETAILS_ID;

		if li_ce_category_type <> li_per_b_cat_type_code and li_count > 0 then
			DELETE from BUDGET_PER_DET_RATE_AND_BASE p 
			where p.BUDGET_PERSONNEL_DETAILS_ID in (SELECT BUDGET_PERSONNEL_DETAILS_ID
			from BUDGET_PERSONNEL_DETAILS where BUDGET_DETAILS_ID = budget_det_rec.BUDGET_DETAILS_ID);

			DELETE from BUDGET_PERSONNEL_CAL_AMTS p 
			where p.BUDGET_PERSONNEL_DETAILS_ID in (SELECT BUDGET_PERSONNEL_DETAILS_ID
			from BUDGET_PERSONNEL_DETAILS where BUDGET_DETAILS_ID = budget_det_rec.BUDGET_DETAILS_ID);

			DELETE from BUDGET_PERSONNEL_DETAILS p 
			where p.BUDGET_DETAILS_ID = budget_det_rec.BUDGET_DETAILS_ID;
		end if;	
		
		UPDATE budget_details
		SET budget_category_code = li_BUDGET_CATEGORY_CODE
		where budget_details_id = budget_det_rec.budget_details_id;
		
	END LOOP;

END LOOP;

end;

/
