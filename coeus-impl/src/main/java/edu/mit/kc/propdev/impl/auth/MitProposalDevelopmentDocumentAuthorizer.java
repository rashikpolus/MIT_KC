package edu.mit.kc.propdev.impl.auth;

import org.kuali.coeus.propdev.impl.auth.ProposalDevelopmentDocumentAuthorizer;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.krad.document.Document;

public class MitProposalDevelopmentDocumentAuthorizer extends ProposalDevelopmentDocumentAuthorizer{
	
	@Override
	public boolean canDisapprove(Document document, Person user) {
		return false;
	}
	
	@Override
	public boolean canCancel(Document document, Person user) {
		return false;
	}
	
	@Override
	public boolean canRecall(Document document, Person user) {
		return false;
	}

}
