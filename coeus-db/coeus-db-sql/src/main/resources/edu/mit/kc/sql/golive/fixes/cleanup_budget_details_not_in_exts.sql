CREATE TABLE TMP_BUDGET_CLEANUP_INDEX(
budget_id NUMBER(12),
document_number VARCHAR2(40)
)
/
INSERT INTO TMP_BUDGET_CLEANUP_INDEX( budget_id, document_number )
select t1.budget_id,t1.document_number from  budget t1
left outer join
  (
    select s1.budget_id from award_budget_ext s1
    union 
    select s2.budget_id from eps_proposal_budget_ext s2
  ) t2 on t1.budget_id = t2.budget_id
where t2.budget_id is null
/
delete from eps_prop_cost_sharing where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from eps_prop_idc_rate where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from eps_prop_la_rates where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from eps_prop_rates where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from awd_bgt_det_cal_amts_ext 
where budget_details_cal_amts_id in ( select budget_details_cal_amts_id from budget_details_cal_amts
                              where budget_id in ( select budget_id from tmp_budget_cleanup_index ) )
/
delete from award_budget_details_ext 
where budget_details_id in ( select budget_details_id from budget_details
                              where budget_id in ( select budget_id from tmp_budget_cleanup_index ) )
/
delete from award_budget_period_ext 
where budget_period_number in ( select budget_period_number from budget_periods
                                      where budget_id in ( select budget_id from tmp_budget_cleanup_index ) )
/
delete from award_budget_limit where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_sub_award_period_detail where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_sub_award_att where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_sub_award_files where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_sub_awards where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_project_income where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_modular_idc where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_modular where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_per_det_rate_and_base where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_person_salary_details where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_personnel_cal_amts where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_personnel_details where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_rate_and_base where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_details_cal_amts where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from bud_formulated_cost_detail
  where budget_details_id in ( select budget_details_id from budget_details
                                where budget_id in ( select budget_id from tmp_budget_cleanup_index ) )
/                                
delete from budget_details where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_persons where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
delete from budget_periods where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
ALTER TABLE AWARD_BUDGET_EXT DISABLE CONSTRAINT FK_AWARD_BUDGET_EXT ;
ALTER TABLE BUDGET_DETAILS DISABLE CONSTRAINT FK_BUDGET_DETAILS ;
ALTER TABLE BUDGET_DETAILS_CAL_AMTS DISABLE CONSTRAINT FK_BUDGET_DETAILS_CAL_AMTS ;
ALTER TABLE BUDGET_MODULAR DISABLE CONSTRAINT FK_BUDGET_MODULAR ;
ALTER TABLE BUDGET_MODULAR_IDC DISABLE CONSTRAINT FK_BUDGET_MODULAR_IDC ;
ALTER TABLE BUDGET_PERIODS DISABLE CONSTRAINT FK_BUDGET_PERIODS ;
ALTER TABLE BUDGET_PERSONNEL_CAL_AMTS DISABLE CONSTRAINT FK_BUDGET_PERSONNEL_CAL_AMTS ;
ALTER TABLE BUDGET_PERSONNEL_DETAILS DISABLE CONSTRAINT FK_BUDGET_PERSONNEL_DETAILS ;
ALTER TABLE BUDGET_PERSONS DISABLE CONSTRAINT FK_BUDGET_PERSONS ;
ALTER TABLE BUDGET_PER_DET_RATE_AND_BASE DISABLE CONSTRAINT FK_PER_DET_RATE_AND_BASE ;
ALTER TABLE BUDGET_PROJECT_INCOME DISABLE CONSTRAINT FK_PROJECT_INCOME ;
ALTER TABLE BUDGET_RATE_AND_BASE DISABLE CONSTRAINT FK_BUDGET_RATE_AND_BASE ;
ALTER TABLE BUDGET_SUB_AWARDS DISABLE CONSTRAINT FK_BUDGET_SUB_AWARDS ;
ALTER TABLE BUDGET_SUB_AWARD_ATT DISABLE CONSTRAINT FK_BUDGET_SUB_AWARD_ATT ;
ALTER TABLE BUDGET_SUB_AWARD_FILES DISABLE CONSTRAINT FK_BUDGET_SUB_AWARD_FILES ;
ALTER TABLE EPS_PROPOSAL_BUDGET_EXT DISABLE CONSTRAINT FK_EPS_PROPOSAL_BUDGET_EXT ;
ALTER TABLE EPS_PROP_COST_SHARING DISABLE CONSTRAINT FK_EPS_PROP_COST_SHARING ;
ALTER TABLE EPS_PROP_IDC_RATE DISABLE CONSTRAINT FK_EPS_PROP_IDC_RATE ;
ALTER TABLE EPS_PROP_LA_RATES DISABLE CONSTRAINT FK_EPS_PROP_LA_RATES ;
ALTER TABLE EPS_PROP_RATES DISABLE CONSTRAINT FK_EPS_PROP_RATES ;
delete from budget where budget_id in ( select budget_id from tmp_budget_cleanup_index )
/
ALTER TABLE AWARD_BUDGET_EXT ENABLE CONSTRAINT FK_AWARD_BUDGET_EXT ;
ALTER TABLE BUDGET_DETAILS ENABLE CONSTRAINT FK_BUDGET_DETAILS ;
ALTER TABLE BUDGET_DETAILS_CAL_AMTS ENABLE CONSTRAINT FK_BUDGET_DETAILS_CAL_AMTS ;
ALTER TABLE BUDGET_MODULAR ENABLE CONSTRAINT FK_BUDGET_MODULAR ;
ALTER TABLE BUDGET_MODULAR_IDC ENABLE CONSTRAINT FK_BUDGET_MODULAR_IDC ;
ALTER TABLE BUDGET_PERIODS ENABLE CONSTRAINT FK_BUDGET_PERIODS ;
ALTER TABLE BUDGET_PERSONNEL_CAL_AMTS ENABLE CONSTRAINT FK_BUDGET_PERSONNEL_CAL_AMTS ;
ALTER TABLE BUDGET_PERSONNEL_DETAILS ENABLE CONSTRAINT FK_BUDGET_PERSONNEL_DETAILS ;
ALTER TABLE BUDGET_PERSONS ENABLE CONSTRAINT FK_BUDGET_PERSONS ;
ALTER TABLE BUDGET_PER_DET_RATE_AND_BASE ENABLE CONSTRAINT FK_PER_DET_RATE_AND_BASE ;
ALTER TABLE BUDGET_PROJECT_INCOME ENABLE CONSTRAINT FK_PROJECT_INCOME ;
ALTER TABLE BUDGET_RATE_AND_BASE ENABLE CONSTRAINT FK_BUDGET_RATE_AND_BASE ;
ALTER TABLE BUDGET_SUB_AWARDS ENABLE CONSTRAINT FK_BUDGET_SUB_AWARDS ;
ALTER TABLE BUDGET_SUB_AWARD_ATT ENABLE CONSTRAINT FK_BUDGET_SUB_AWARD_ATT ;
ALTER TABLE BUDGET_SUB_AWARD_FILES ENABLE CONSTRAINT FK_BUDGET_SUB_AWARD_FILES ;
ALTER TABLE EPS_PROPOSAL_BUDGET_EXT ENABLE CONSTRAINT FK_EPS_PROPOSAL_BUDGET_EXT ;
ALTER TABLE EPS_PROP_COST_SHARING ENABLE CONSTRAINT FK_EPS_PROP_COST_SHARING ;
ALTER TABLE EPS_PROP_IDC_RATE ENABLE CONSTRAINT FK_EPS_PROP_IDC_RATE ;
ALTER TABLE EPS_PROP_LA_RATES ENABLE CONSTRAINT FK_EPS_PROP_LA_RATES ;
ALTER TABLE EPS_PROP_RATES ENABLE CONSTRAINT FK_EPS_PROP_RATES ;
delete from budget_document where document_number in ( select document_number from tmp_budget_cleanup_index )
/
