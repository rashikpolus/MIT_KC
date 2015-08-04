UPDATE WL_CURRENT_LOAD  t1 
SET t1.PROPOSAL_NUMBER = ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )
where exists ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )                                                     
/

UPDATE WL_PROP_AGGREGATOR_ERR_COUNT  t1 
SET t1.PROPOSAL_NUMBER = ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )
where exists ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )  
/
UPDATE WL_PROP_REV_COMM_LAST_YEAR  t1 
SET t1.PROPOSAL_NUMBER = ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )
where exists ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )  
/
UPDATE WL_PROP_REVIEW_COMMENTS  t1 
SET t1.PROPOSAL_NUMBER = ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )
where exists ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) ) 
/
UPDATE WL_REVIEW_ASSIGNMENTS  t1 
SET t1.PROPOSAL_NUMBER = ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )
where exists ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )  
/
UPDATE WL_PROP_REVIEW_DETAILS  t1 
SET t1.PROPOSAL_NUMBER = ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )
where exists ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )  
/
UPDATE WL_SIM_CURRENT_LOAD  t1 
SET t1.PROPOSAL_NUMBER = ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )
where exists ( select t2.proposal_number from eps_proposal t2 where t1.proposal_number = trim(to_char(t2.proposal_number,'00000000')) )  
/
commit
/
