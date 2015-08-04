package org.kuali.coeus.propdev.proposalperson;



import java.sql.SQLException;

public interface CoiDbFunctionService {
	

	/**
	 * For retrieving coi disclosure status of each person added to the development proposal
	 fn_check_prop_event_sub_to_coi (PROPOSAL_NUMBER, PERSON-ID)
 */	
	public String getKeyPersonnelCoiDisclosureStatus(String developmentProposalNumber,String keyPersonId,boolean isQuestionnairesCompleted) throws SQLException;
	public boolean isCoiDisclosureSubmitted(String developmentProposalNumber);

}