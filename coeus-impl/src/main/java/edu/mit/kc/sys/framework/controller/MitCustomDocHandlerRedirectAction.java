package edu.mit.kc.sys.framework.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.kuali.coeus.sys.framework.controller.CustomDocHandlerRedirectAction;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.irb.ProtocolForm;
import org.kuali.rice.core.api.util.RiceConstants;
import org.kuali.rice.core.api.util.RiceKeyConstants;
import org.kuali.rice.kns.util.KNSGlobalVariables;
import org.kuali.rice.kns.web.struts.form.KualiDocumentFormBase;
import org.kuali.rice.krad.bo.AdHocRouteRecipient;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.service.DocumentService;
import org.kuali.rice.krad.service.KRADServiceLocatorWeb;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.util.KRADPropertyConstants;

import edu.mit.kc.protocol.service.MitProtocolMigrationService;

public class MitCustomDocHandlerRedirectAction extends CustomDocHandlerRedirectAction {
    private MitProtocolMigrationService mitProtocolMigrationService;
    private DocumentService documentService;

    @Override
    public ActionForward start(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        ActionForward returnForward = super.execute(mapping, form, request, response);
        
       	String docIdRequestParameter = request.getParameter(KRADConstants.PARAMETER_DOC_ID); 
       	if (docIdRequestParameter != null && docIdRequestParameter.startsWith("MP")) { 
               // Migrated Protocol - need to create a new Document and associate it with this Protocol 
       		boolean route = getMitProtocolMigrationService().createDocumentForMigratedProtocolAndRoute(mapping, request, response, ((ProtocolForm) form), docIdRequestParameter); 
       		if(route) {
           		route(mapping, form, request, response);
       		}
       	} 
       	
        String docHandler = returnForward.getPath();
        if (("ProposalDevelopmentDocument").equals(request.getParameter("documentTypeName"))) {
            docHandler = docHandler.replace(KRADConstants.DOC_HANDLER_METHOD, "actions");
        } else if (("ProtocolDocument").equals(request.getParameter("documentTypeName"))) {
            docHandler = docHandler.replace(KRADConstants.DOC_HANDLER_METHOD, "protocolActions");
        } else if (("AwardDocument").equals(request.getParameter("documentTypeName"))) {
            docHandler = docHandler.replace(KRADConstants.DOC_HANDLER_METHOD, "awardActions");
        }
          
        returnForward = new ActionForward(docHandler, returnForward.getRedirect());
        return returnForward;
    }

    public ActionForward route(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        KualiDocumentFormBase kualiDocumentFormBase = (KualiDocumentFormBase) form;
        doProcessingAfterPost(kualiDocumentFormBase, request);

        kualiDocumentFormBase.setDerivedValuesOnForm(request);
//        ActionForward preRulesForward = promptBeforeValidation(mapping, form, request, response);
//        if (preRulesForward != null) {
//            return preRulesForward;
//        }

        Document document = kualiDocumentFormBase.getDocument();

//        ActionForward forward = checkAndWarnAboutSensitiveData(mapping, form, request, response, KRADPropertyConstants.DOCUMENT_EXPLANATION, document.getDocumentHeader().getExplanation(), "route", "");
//        if (forward != null) {
//            return forward;
//        }

        document = getDocumentService().routeDocument(document, kualiDocumentFormBase.getAnnotation(), combineAdHocRecipients(kualiDocumentFormBase));
        kualiDocumentFormBase.setDocument(document);
        KNSGlobalVariables.getMessageList().add(RiceKeyConstants.MESSAGE_ROUTE_SUCCESSFUL);
        kualiDocumentFormBase.setAnnotation("");

        return mapping.findForward(RiceConstants.MAPPING_BASIC);
    }
    
    protected List<AdHocRouteRecipient> combineAdHocRecipients(KualiDocumentFormBase kualiDocumentFormBase) {
        List<AdHocRouteRecipient> adHocRecipients = new ArrayList<AdHocRouteRecipient>();
        adHocRecipients.addAll(kualiDocumentFormBase.getAdHocRoutePersons());
        adHocRecipients.addAll(kualiDocumentFormBase.getAdHocRouteWorkgroups());
        return adHocRecipients;
    }
    
    protected DocumentService getDocumentService() {
        if (documentService == null) {
            documentService = KRADServiceLocatorWeb.getDocumentService();
        }
        return this.documentService;
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

	public void setDocumentService(DocumentService documentService) {
		this.documentService = documentService;
	}
    
    
}
