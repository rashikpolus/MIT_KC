DECLARE
li_count number;
cursor c_update is
select budget_id, proposal_number from EPS_PROPOSAL_BUDGET_EXT e
where e.STATUS_CODE not in ('1', '2') and final_version_flag = 'Y';

r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

update eps_proposal a
set a.final_budget_id = r_update.budget_id
where a.proposal_number = r_update.proposal_number;

END LOOP;
CLOSE c_update;
END;
/

update EPS_PROPOSAL_BUDGET_EXT a
set a.status_code = '1'
where e.STATUS_CODE not in ('1', '2') and final_version_flag = 'Y';

update EPS_PROPOSAL_BUDGET_EXT a
set a.status_code = '2'
where e.STATUS_CODE not in ('1', '2') and final_version_flag = 'N';

commit;
