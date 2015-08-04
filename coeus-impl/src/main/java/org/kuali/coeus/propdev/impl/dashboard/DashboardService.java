package org.kuali.coeus.propdev.impl.dashboard;


import java.util.List;

import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.kra.award.home.Award;

public interface DashboardService {
	
	public List<ProposalPerson> getProposalsForInvestigator(String investigatorPersonId);
	
	public List<Award> getAwardsForInvestigator(String investigatorPersonId);
	public List<Award> getActiveAwardsForInvestigator(String investigatorPersonId);
	public List<Award> getInvestigatorAwardsForProjectDocument(List<Award> myAwards);
	
}
