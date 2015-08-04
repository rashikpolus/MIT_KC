update eps_proposal_budget_ext set proposal_number = to_number(proposal_number)
/
commit
/
update eps_proposal_budget_ext t1 set t1.status_code = ( select nvl(t2.budget_status,'C') from eps_proposal t2
where t2.proposal_number = t1.proposal_number
)
/
commit
/