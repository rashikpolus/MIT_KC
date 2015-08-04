package edu.mit.kc.irb.actions;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.committee.bo.CommitteeBatchCorrespondenceDetail;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.irb.ProtocolForm;
import org.kuali.kra.irb.actions.ProtocolProtocolActionsAction;
import org.kuali.kra.irb.actions.submit.ProtocolSubmission;
import org.kuali.kra.irb.correspondence.ProtocolCorrespondence;
import org.kuali.rice.kew.api.KewApiConstants;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.service.KRADServiceLocatorWeb;
import org.kuali.rice.krad.util.KRADConstants;

import edu.mit.kc.protocol.service.MitProtocolMigrationService;

public class MitProtocolProtocolActionsAction extends ProtocolProtocolActionsAction {
    private static final String SUBMISSION_ID = "submissionId";
    private MitProtocolMigrationService mitProtocolMigrationService;
    private static final Log LOG = LogFactory.getLog(MitProtocolProtocolActionsAction.class);
    private static final String NOT_FOUND_SELECTION = "The attachment was not found for selection ";
    private static final ActionForward RESPONSE_ALREADY_HANDLED = null;

    public ActionForward start(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        Map<String, String> fieldValues = new HashMap<String, String>();
        fieldValues.put(SUBMISSION_ID, request.getParameter(SUBMISSION_ID));
        ProtocolSubmission protocolSubmission = (ProtocolSubmission) getBusinessObjectService().findByPrimaryKey(ProtocolSubmission.class, fieldValues);
        protocolSubmission.getProtocol().setProtocolSubmission(protocolSubmission);
        
        ProtocolForm protocolForm = (ProtocolForm) form;
        protocolForm.setDocId(protocolSubmission.getProtocol().getProtocolDocument().getDocumentNumber());
        if (protocolForm.getDocId().startsWith("MP")) { 
        	boolean route = getMitProtocolMigrationService().createDocumentForMigratedProtocolAndRoute(mapping, request, response, protocolForm, protocolForm.getDocId()); 
        	if(route) {
        		route(mapping, protocolForm, request, response);
        	}
        } 
        loadDocument(protocolForm);
        protocolForm.initialize();
        return mapping.findForward(Constants.MAPPING_BASIC);
    }
    
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ProtocolForm protocolForm = (ProtocolForm) form;
        
        if (protocolForm.getDocId() != null && protocolForm.getDocId().startsWith("MP")) { 
        	boolean route = getMitProtocolMigrationService().createDocumentForMigratedProtocolAndRoute(mapping, request, response, protocolForm, protocolForm.getDocId()); 
        	if(route) {
        		route(mapping, protocolForm, request, response);
        	}
        } 
        
        // set the current task name on the action helper before the requested method is dispatched
        // so that beans etc can access it when preparing view after/during the requested method's execution
        String currentTaskName = getTaskName(request);
        if(currentTaskName != null) {
            protocolForm.getActionHelper().setCurrentTask(currentTaskName);
        }
        else {
            protocolForm.getActionHelper().setCurrentTask("");
        }
        ActionForward actionForward = super.execute(mapping, form, request, response);
        protocolForm.getActionHelper().prepareView();
        // submit action may change "submission details", so re-initializa it
        
        if ("close".equals(protocolForm.getMethodToCall()) || protocolForm.getMethodToCall() == null) {
            // If we're closing, we can just leave right here.
            return mapping.findForward(KRADConstants.MAPPING_PORTAL);
        }
        protocolForm.getActionHelper().initSubmissionDetails();
        
        return actionForward;
    }
    
    private String getTaskName(HttpServletRequest request) {
        String parameterName = (String) request.getAttribute(KRADConstants.METHOD_TO_CALL_ATTRIBUTE);
        
        String taskName = "";
        if (StringUtils.isNotBlank(parameterName)) {
            taskName = StringUtils.substringBetween(parameterName, ".taskName", ".");
        }
        
        return taskName;
    }

    @Override
    public ActionForward docHandler(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        ActionForward forward = null;
        
        ProtocolForm protocolForm = (ProtocolForm) form;
        String command = protocolForm.getCommand();
        String detailId;
       
        if (command.startsWith(KewApiConstants.DOCSEARCH_COMMAND+"detailId")) {
            detailId = command.substring((KewApiConstants.DOCSEARCH_COMMAND+"detailId").length());
            protocolForm.setDetailId(detailId);
            viewBatchCorrespondence(mapping, protocolForm, request, response);
            return RESPONSE_ALREADY_HANDLED;
        }
        if (KewApiConstants.ACTIONLIST_INLINE_COMMAND.equals(command)) {
            String docIdRequestParameter = request.getParameter(KRADConstants.PARAMETER_DOC_ID);
            Document retrievedDocument = KRADServiceLocatorWeb.getDocumentService().getByDocumentHeaderId(docIdRequestParameter);
            protocolForm.setDocument(retrievedDocument);
            request.setAttribute(KRADConstants.PARAMETER_DOC_ID, docIdRequestParameter);
            forward = mapping.findForward(Constants.MAPPING_COPY_PROPOSAL_PAGE);
            forward = new ActionForward(forward.getPath()+ "?" + KRADConstants.PARAMETER_DOC_ID + "=" + docIdRequestParameter);  
        } else if (Constants.MAPPING_PROTOCOL_ACTIONS.equals(command) || Constants.MAPPING_PROTOCOL_ONLINE_REVIEW.equals(command)) {
            String docIdRequestParameter = request.getParameter(KRADConstants.PARAMETER_DOC_ID);
            Document retrievedDocument = KRADServiceLocatorWeb.getDocumentService().getByDocumentHeaderId(docIdRequestParameter);
            protocolForm.setDocument(retrievedDocument);
            request.setAttribute(KRADConstants.PARAMETER_DOC_ID, docIdRequestParameter);
            loadDocument(protocolForm);
        } else {
            String docIdRequestParameter = request.getParameter(KRADConstants.PARAMETER_DOC_ID); 
            if (docIdRequestParameter != null && docIdRequestParameter.startsWith("MP")) { 
                // Migrated Protocol - need to create a new Document and associate it with this Protocol 
            	boolean route = getMitProtocolMigrationService().createDocumentForMigratedProtocolAndRoute(mapping, request, response, protocolForm, docIdRequestParameter); 
                if(route) {
                	route(mapping, protocolForm, request, response);
                }
            	forward = super.docHandler(mapping, form, request, response); 
            } else { 
                forward = super.docHandler(mapping, form, request, response); 
            } 
        }

        if (KewApiConstants.INITIATE_COMMAND.equals(protocolForm.getCommand())) {
            protocolForm.getProtocolDocument().initialize();
        } else {
            protocolForm.initialize();
        }
        
        if (Constants.MAPPING_PROTOCOL_ACTIONS.equals(command)) {
            forward = protocolActions(mapping, protocolForm, request, response);
        }
        if (Constants.MAPPING_PROTOCOL_ONLINE_REVIEW.equals(command)) {
            forward = onlineReview(mapping, protocolForm, request, response);
        }
        
        return forward;
    }
    
    private void viewBatchCorrespondence(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        ProtocolForm protocolForm = (ProtocolForm) form;
        Map primaryKeys = new HashMap();
        primaryKeys.put("committeeBatchCorrespondenceDetailId", protocolForm.getDetailId());
        CommitteeBatchCorrespondenceDetail batchCorrespondenceDetail = (CommitteeBatchCorrespondenceDetail) getBusinessObjectService()
                .findByPrimaryKey(CommitteeBatchCorrespondenceDetail.class, primaryKeys);
        primaryKeys.clear();
        primaryKeys.put("id", batchCorrespondenceDetail.getProtocolCorrespondenceId());
        ProtocolCorrespondence attachment = (ProtocolCorrespondence) getBusinessObjectService().findByPrimaryKey(
                ProtocolCorrespondence.class, primaryKeys);

        if (attachment == null) {
            LOG.info(NOT_FOUND_SELECTION + "detailID: " + protocolForm.getDetailId());
            // may want to tell the user the selection was invalid.
        }
        else {

            this.streamToResponse(attachment.getCorrespondence(), StringUtils.replace(attachment.getProtocolCorrespondenceType()
                    .getDescription(), " ", "")
                    + ".pdf", Constants.PDF_REPORT_CONTENT_TYPE, response);
        }
    }
    
	public MitProtocolMigrationService getMitProtocolMigrationService() {
		if (mitProtocolMigrationService == null) {
			mitProtocolMigrationService = KcServiceLocator.getService(MitProtocolMigrationService.class);
        }
		return mitProtocolMigrationService;
	}

	public void setMitProtocolMigrationService(MitProtocolMigrationService mitProtocolMigrationService) {
		this.mitProtocolMigrationService = mitProtocolMigrationService;
	}

}
