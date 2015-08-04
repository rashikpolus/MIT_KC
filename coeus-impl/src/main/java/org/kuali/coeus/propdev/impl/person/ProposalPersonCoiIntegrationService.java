package org.kuali.coeus.propdev.impl.person;

public interface ProposalPersonCoiIntegrationService {
	
	/*
	 * This method will check the questions are completed and any of the COI questions answered “yes”.
	 */
	public boolean isCoiQuestionsAnswered(ProposalPerson proposalPerson);

	boolean isCoiQuestionsAnsweredN(ProposalPerson proposalPerson);

}
