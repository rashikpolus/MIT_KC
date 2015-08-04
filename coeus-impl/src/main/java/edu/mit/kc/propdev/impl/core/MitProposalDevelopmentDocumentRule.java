package edu.mit.kc.propdev.impl.core;

import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocumentRule;
import org.kuali.coeus.propdev.impl.state.ProposalState;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.document.TransactionalDocument;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;

public class MitProposalDevelopmentDocumentRule extends ProposalDevelopmentDocumentRule{
	
	
	  @Override
	    public boolean processSaveDocument(Document document) {
	        boolean isValid = true;
	        ProposalDevelopmentDocument proposalDevelopmentDocument = (ProposalDevelopmentDocument)document;
	        if(proposalDevelopmentDocument.getDevelopmentProposal()!=null && (proposalDevelopmentDocument.getDevelopmentProposal().getProposalStateTypeCode().equals(ProposalState.IN_PROGRESS) ||
	        		proposalDevelopmentDocument.getDevelopmentProposal().getProposalStateTypeCode().equals(ProposalState.REVISIONS_REQUESTED))){
	        	isValid = isDocumentOverviewValid(document);

	        	GlobalVariables.getMessageMap().addToErrorPath(KRADConstants.DOCUMENT_PROPERTY_NAME);

	        	getKnsDictionaryValidationService().validateDocumentAndUpdatableReferencesRecursively(document, getMaxDictionaryValidationDepth(),
	        			VALIDATION_REQUIRED, CHOMP_LAST_LETTER_S_FROM_COLLECTION_NAME);
	        	getDictionaryValidationService().validateDefaultExistenceChecksForTransDoc((TransactionalDocument) document);

	        	GlobalVariables.getMessageMap().removeFromErrorPath(KRADConstants.DOCUMENT_PROPERTY_NAME);

	        	isValid &= GlobalVariables.getMessageMap().hasNoErrors();
	        	isValid &= processCustomSaveDocumentBusinessRules(document);
	        }
	        return isValid;
	    }

}
