package edu.mit.kc.award.document.authorization;

import org.kuali.kra.award.document.authorization.AwardDocumentAuthorizer;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.krad.document.Document;

public class MitAwardDocumentAuthorizer extends AwardDocumentAuthorizer{
	
	 /**
     * Can the user disapprove the given document?
     * @param document the document
     * @param user the user
     * @return true if the user can disapprove the document; otherwise false
     */
    @Override
    public boolean canDisapprove(Document document, Person user) {
        return false;
    }

}
