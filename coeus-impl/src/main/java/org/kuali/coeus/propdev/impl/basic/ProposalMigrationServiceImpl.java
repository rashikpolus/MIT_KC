package org.kuali.coeus.propdev.impl.basic;

import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.service.DocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;



@Component("proposalMigrationService")
@Transactional(propagation = Propagation.REQUIRES_NEW)
public class ProposalMigrationServiceImpl implements ProposalMigrationService {

    @Autowired
    @Qualifier("dataObjectService")
    private DataObjectService dataObjectService;
    
    @Autowired
    @Qualifier("documentService")
    private DocumentService documentService;
    
    public void executeProposalMigration(ProposalDevelopmentDocument document) {
		DevelopmentProposal devProposal = document.getDevelopmentProposal();
		String documentDesc = devProposal.getTitle(); 
    	String documentNumber = document.getDocumentNumber();
    	try {
        ProposalDevelopmentDocument newDoc = (ProposalDevelopmentDocument) getDocumentService().getNewDocument(document.getClass());
        newDoc.getDocumentHeader().setDocumentDescription(documentDesc);
        newDoc.setDevelopmentProposal(devProposal);
        newDoc = (ProposalDevelopmentDocument) getDocumentService().saveDocument(newDoc);
        devProposal.setProposalDocument(newDoc);
       // associateDocumentNextvalues(documentNumber, newDoc);
        getDataObjectService().save(devProposal);
    	}catch(Exception ex) {
    		System.out.println("Error in proposal # " + devProposal.getProposalNumber());
    		ex.printStackTrace();
    	}
    }

	public DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}

	public DocumentService getDocumentService() {
		return documentService;
	}

	public void setDocumentService(DocumentService documentService) {
		this.documentService = documentService;
	}

}
