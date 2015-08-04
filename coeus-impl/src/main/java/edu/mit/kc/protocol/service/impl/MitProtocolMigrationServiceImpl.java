package edu.mit.kc.protocol.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.struts.action.ActionMapping;
import org.kuali.kra.bo.DocumentNextvalue;
import org.kuali.kra.irb.Protocol;
import org.kuali.kra.irb.ProtocolDocument;
import org.kuali.kra.irb.ProtocolForm;
import org.kuali.kra.irb.actions.ProtocolStatus;
import org.kuali.kra.protocol.ProtocolBase;
import org.kuali.rice.kew.actionitem.ActionItem;
import org.kuali.rice.kew.actionlist.service.ActionListService;
import org.kuali.rice.kew.actionrequest.ActionRequestValue;
import org.kuali.rice.kew.actionrequest.service.ActionRequestService;
import org.kuali.rice.kew.service.KEWServiceLocator;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.service.KRADServiceLocatorWeb;
import org.kuali.rice.krad.util.KRADConstants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import edu.mit.kc.protocol.service.MitProtocolMigrationService;

@Component("mitProtocolMigrationService")
@Transactional
public class MitProtocolMigrationServiceImpl implements MitProtocolMigrationService{

    @Autowired
    @Qualifier("businessObjectService")
    private BusinessObjectService businessObjectService;
    
	public void createDocumentForMigratedProtocol(ProtocolBase protocol) throws Exception {
		ProtocolDocument protocolDocument = (ProtocolDocument)protocol.getProtocolDocument();
		boolean finalDocument = protocolDocument.getDocumentHeader().getWorkflowDocument().isFinal();
		if(!finalDocument && isNewDocumentRequired(protocol)) {
	    	String documentNumber = protocol.getProtocolDocument().getDocumentNumber();
	    	ProtocolDocument newDoc = (ProtocolDocument) KRADServiceLocatorWeb.getDocumentService().getNewDocument(ProtocolDocument.class);
	        newDoc.getDocumentHeader().setDocumentDescription("Migrated Protocol");
	        newDoc.setProtocol(protocol);
	        protocol.setProtocolDocument(newDoc);
	        associateDocumentNextvalues(documentNumber, newDoc);
	        KRADServiceLocatorWeb.getDocumentService().saveDocument(newDoc);
	        businessObjectService.save(protocol);
		}
	}

	protected boolean isNewDocumentRequired(ProtocolBase protocol) {
	    if(protocol.getProtocolStatusCode().equals(ProtocolStatus.SUBMITTED_TO_IRB) ||
	    	protocol.getProtocolStatusCode().equals(ProtocolStatus.IN_PROGRESS) ||
	    	protocol.getProtocolStatusCode().equals(ProtocolStatus.AMENDMENT_IN_PROGRESS) ||
	    	protocol.getProtocolStatusCode().equals(ProtocolStatus.RENEWAL_IN_PROGRESS)) {
	    	return true;
	    }
		return false;
	}
	
	protected void associateDocumentNextvalues(String oldDocNum, ProtocolDocument newDoc) { 
	   	Map<String, String> query = new HashMap<String, String>(); 
	   	query.put("documentKey", oldDocNum); 
	   	List<DocumentNextvalue> nextVals = (List<DocumentNextvalue>) getBusinessObjectService().findMatching(DocumentNextvalue.class, query); 
	   	for (DocumentNextvalue nextVal : nextVals) { 
	   	 nextVal.setDocumentKey(newDoc.getDocumentNumber()); 
	   	} 
	   	getBusinessObjectService().save(nextVals); 
	   	newDoc.setDocumentNextvalues(nextVals); 
	   } 

	public boolean createDocumentForMigratedProtocolAndRoute(ActionMapping mapping, HttpServletRequest request, HttpServletResponse response, ProtocolForm protocolForm, String docIdRequestParameter) throws Exception { 
		ProtocolDocument protocolDocument = protocolForm.getProtocolDocument();
		boolean finalDocument = protocolDocument.getDocumentHeader().getWorkflowDocument().isFinal();
		if(!finalDocument && isNewDocumentRequired(protocolDocument.getProtocol())) {
			long protocolId = protocolForm.getProtocolDocument().getProtocol().getProtocolId();
		   	ProtocolDocument newDoc = (ProtocolDocument) KRADServiceLocatorWeb.getDocumentService().getNewDocument(ProtocolDocument.class); 
		       newDoc.getDocumentHeader().setDocumentDescription("Migrated Protocol"); 
		       Protocol protocol = getBusinessObjectService().findBySinglePrimaryKey(Protocol.class, protocolId); 
		       newDoc.setProtocol(protocol); 
		       protocol.setProtocolDocument(newDoc); 
		       associateDocumentNextvalues(docIdRequestParameter, newDoc); 
		       KRADServiceLocatorWeb.getDocumentService().saveDocument(newDoc); 
		       getBusinessObjectService().save(protocol); 
		       protocolForm.setDocument(newDoc); 
		       request.setAttribute(KRADConstants.PARAMETER_DOC_ID, newDoc.getDocumentNumber()); 
		       protocolForm.setDocId(newDoc.getDocumentNumber()); 

		       /** UITSRA-2413 - Need to route protocol if it should already be "ENROUTE" */ 
		       if(protocol.getProtocolStatusCode().equals(ProtocolStatus.SUBMITTED_TO_IRB)) { 
			       	if(StringUtils.isBlank(protocolForm.getDocTypeName())) { 
				       	 protocolForm.setDocTypeName(newDoc.getDocumentHeader().getWorkflowDocument().getDocumentTypeName()); 
			       	} 
			       	return true; 
		       } 
		       /** UITSRA-2998 - Get rid of "Complete" action requests unless protocol still needs to be routed */ 
		       else if (protocol.getProtocolSubmission() != null && protocol.getProtocolSubmission().getSubmissionStatusCode() != null) { 
			       	ActionRequestService arService = KEWServiceLocator.getActionRequestService(); 
			       	ActionListService alService = KEWServiceLocator.getActionListService(); 
			       	List<ActionRequestValue> actionRequests = arService.findPendingByDoc(newDoc.getDocumentNumber()); 
			       	for (ActionRequestValue actionRequest : actionRequests) { 
				       	 if (actionRequest.isCompleteRequst()) { 
					       	 // Actually, just delete action items so that Acknowledge and Approve requests aren't generated. 
					       	 for (ActionItem actionItem : actionRequest.getActionItems()) { 
						       	 alService.deleteActionItem(actionItem); 
					       	 } 
				       	 } 
			       	} 
		       }
		}
	       return false;
	} 
	
    public BusinessObjectService getBusinessObjectService() {
        return businessObjectService;
    }

	public void setBusinessObjectService(BusinessObjectService businessObjectService) {
		this.businessObjectService = businessObjectService;
	}
}
