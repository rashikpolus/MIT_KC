package edu.mit.kc.award.budget.document.authorization;

import org.kuali.kra.award.budget.document.authorization.AwardBudgetDocumentAuthorizer;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.krad.document.Document;

public class MitAwardBudgetDocumentAuthorizer extends AwardBudgetDocumentAuthorizer{
	
	  @Override
	    public boolean canDisapprove( Document document, Person user ) {
	        return false;
	    }

	@Override
	public boolean canCopy(Document document, Person user) {
		return false;
	}
}
