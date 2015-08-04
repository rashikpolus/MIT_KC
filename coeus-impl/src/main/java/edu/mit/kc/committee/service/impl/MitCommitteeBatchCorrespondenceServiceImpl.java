package edu.mit.kc.committee.service.impl;

import org.apache.commons.lang3.StringUtils;
import org.kuali.kra.committee.service.impl.CommitteeBatchCorrespondenceServiceImpl;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.irb.Protocol;
import org.kuali.kra.irb.ProtocolDocument;
import org.kuali.kra.irb.actions.ProtocolActionType;
import org.kuali.kra.irb.actions.abandon.ProtocolAbandonService;
import org.kuali.kra.irb.actions.genericactions.ProtocolGenericActionBean;
import org.kuali.kra.irb.actions.genericactions.ProtocolGenericActionService;
import org.kuali.kra.protocol.ProtocolBase;
import org.kuali.kra.protocol.correspondence.BatchCorrespondenceBase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import edu.mit.kc.protocol.service.MitProtocolMigrationService;



@Component("committeeBatchCorrespondenceService")
@Transactional
public class MitCommitteeBatchCorrespondenceServiceImpl extends CommitteeBatchCorrespondenceServiceImpl {

    @Autowired
    @Qualifier("mitProtocolMigrationService")
    private MitProtocolMigrationService mitProtocolMigrationService;
    
    @Autowired
    @Qualifier("protocolAbandonService")
    protected ProtocolAbandonService protocolAbandonService;
   
    @Override
	protected void applyFinalAction(ProtocolBase protocol, BatchCorrespondenceBase batchCorrespondence) throws Exception {
        ProtocolGenericActionBean actionBean = new ProtocolGenericActionBean(null, Constants.EMPTY_STRING);
        actionBean.setComments("Final action of batch Correspondence: " + batchCorrespondence.getDescription());
        
        if (StringUtils.equals(ProtocolActionType.EXPIRED, batchCorrespondence.getFinalActionTypeCode())) { 
           	LOG.info("Batch Job: Expiring Protocol #"+protocol.getProtocolNumber()); 
           	if(protocol.getProtocolDocument().getDocumentNumber().startsWith("MP")) { 
              	 getMitProtocolMigrationService().createDocumentForMigratedProtocol(protocol); 
           	} 
        }

        if (StringUtils.equals(ProtocolActionType.SUSPENDED, batchCorrespondence.getFinalActionTypeCode())) {
            try {
                protocol.getProtocolDocument().getDocumentHeader().getWorkflowDocument();
            }
            catch (RuntimeException ex) {
                protocol.setProtocolDocument((ProtocolDocument) documentService.getByDocumentHeaderId(protocol.getProtocolDocument().getDocumentNumber()));
            }
            protocolGenericActionService.suspend((Protocol) protocol, actionBean);
            finalActionCounter++;
        }
        
        if (StringUtils.equals(ProtocolActionType.CLOSED_ADMINISTRATIVELY_CLOSED, batchCorrespondence.getFinalActionTypeCode())) {
            try {
                protocol.getProtocolDocument().getDocumentHeader().getWorkflowDocument();
            }
            catch (RuntimeException ex) {
                protocol.setProtocolDocument((ProtocolDocument) documentService.getByDocumentHeaderId(protocol.getProtocolDocument().getDocumentNumber()));
            }
            ((ProtocolGenericActionService) protocolGenericActionService).close((Protocol) protocol, actionBean);
            finalActionCounter++;
        }
        
        if (StringUtils.equals(ProtocolActionType.EXPIRED, batchCorrespondence.getFinalActionTypeCode())) {
            try {
                protocol.getProtocolDocument().getDocumentHeader().getWorkflowDocument();
            }
            catch (RuntimeException ex) {
                protocol.setProtocolDocument((ProtocolDocument) documentService.getByDocumentHeaderId(protocol.getProtocolDocument().getDocumentNumber()));
            }
            protocolGenericActionService.expire((Protocol) protocol, actionBean);
            finalActionCounter++;
        }
        
        if (StringUtils.equals(ProtocolActionType.ABANDON_PROTOCOL, batchCorrespondence.getFinalActionTypeCode())) {
            try {
                protocol.getProtocolDocument().getDocumentHeader().getWorkflowDocument();
            }
            catch (RuntimeException ex) {
                protocol.setProtocolDocument((ProtocolDocument) documentService.getByDocumentHeaderId(protocol.getProtocolDocument().getDocumentNumber()));
            }
            getProtocolAbandonService().abandonProtocol(protocol, actionBean);
            finalActionCounter++;
        }
    }

	public MitProtocolMigrationService getMitProtocolMigrationService() {
		return mitProtocolMigrationService;
	}

	public void setMitProtocolMigrationService(
			MitProtocolMigrationService mitProtocolMigrationService) {
		this.mitProtocolMigrationService = mitProtocolMigrationService;
	}

	public ProtocolAbandonService getProtocolAbandonService() {
		return protocolAbandonService;
	}

	public void setProtocolAbandonService(
			ProtocolAbandonService protocolAbandonService) {
		this.protocolAbandonService = protocolAbandonService;
	}
}
