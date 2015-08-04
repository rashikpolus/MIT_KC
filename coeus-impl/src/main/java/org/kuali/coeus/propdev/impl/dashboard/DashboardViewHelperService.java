package org.kuali.coeus.propdev.impl.dashboard;

import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.kra.award.home.Award;
import org.kuali.rice.core.api.CoreApiServiceLocator;
import org.kuali.rice.kew.api.KewApiConstants;
import org.kuali.rice.kew.api.doctype.DocumentTypeService;
import org.kuali.rice.kew.api.exception.WorkflowException;
import org.kuali.rice.kns.lookup.HtmlData;
import org.kuali.rice.krad.service.KRADServiceLocator;
import org.kuali.rice.krad.uif.element.Link;
import org.kuali.rice.krad.uif.field.LinkField;
import org.kuali.rice.krad.uif.service.impl.ViewHelperServiceImpl;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.util.UrlFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import java.util.Properties;

/**

 */
@Component("dashboardViewHelperService")
@Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
public class DashboardViewHelperService extends ViewHelperServiceImpl {

	 @Autowired
	 @Qualifier("globalVariableService")
	 private GlobalVariableService globalVariableService;

	

	public static String buildPropDevLink(String docId) throws WorkflowException {
        return CoreApiServiceLocator.getKualiConfigurationService().getPropertyValueAsString(KRADConstants.WORKFLOW_URL_KEY)
     	                + KRADConstants.DOCHANDLER_DO_URL
     	                + docId
     	                + KRADConstants.DOCHANDLER_URL_CHUNK;

	}

    public static String buildAwardLink(String docId) throws WorkflowException {
        return CoreApiServiceLocator.getKualiConfigurationService().getPropertyValueAsString(KRADConstants.WORKFLOW_URL_KEY)
     	                + KRADConstants.DOCHANDLER_DO_URL
     	                + docId
     	                + KRADConstants.DOCHANDLER_URL_CHUNK;
   	}

    public static String buildProjectDocLink(String docId, String awardId) {
        Properties parameters = new Properties();
        parameters.put(KRADConstants.DISPATCH_REQUEST_PARAMETER, "sharedDoc");
        parameters.put(KRADConstants.PARAMETER_COMMAND, KewApiConstants.DOCSEARCH_COMMAND);
        parameters.put(KRADConstants.DOCUMENT_TYPE_NAME, "AwardDocument");
        parameters.put("viewDocument", "false");
        parameters.put("docId", docId);
        parameters.put("docOpenedFromAwardSearch", "true");
        parameters.put("placeHolderAwardId", awardId);
        String href  = UrlFactory.parameterizeUrl("../" + getHtmlActionShared(), parameters);
        return href;
    }

    public static String buildKeyPersonLink(String docId, String awardId) {

       Properties parameters = new Properties();
       parameters.put(KRADConstants.DISPATCH_REQUEST_PARAMETER, "keyPerson");//contact
       parameters.put(KRADConstants.PARAMETER_COMMAND, KewApiConstants.DOCSEARCH_COMMAND);
       parameters.put(KRADConstants.DOCUMENT_TYPE_NAME, "AwardDocument");
       parameters.put("viewDocument", "false");
       parameters.put("docId", docId);
       parameters.put("docOpenedFromAwardSearch", "true");
       parameters.put("placeHolderAwardId", awardId);
       String href  = UrlFactory.parameterizeUrl("../"+getHtmlActionKeyPerson(), parameters);
       return href;

    }

    protected static String getHtmlActionShared() {
        return "sharedDoc.do";
    }
    protected static String getHtmlActionKeyPerson() {
        return "keyperson.do";
    }
    
    public boolean showDashBoardGraph(String dashBoardPerson) {
    	boolean showDashBoardGraph = false;
    	String loggedInPerson = getGlobalVariableService().getUserSession().getPrincipalId();
    	if(loggedInPerson!=null && dashBoardPerson!=null && loggedInPerson.equals(dashBoardPerson)){
    		showDashBoardGraph = true;
    	}
        return showDashBoardGraph;
    }
    public GlobalVariableService getGlobalVariableService() {
		return globalVariableService;
	}

	public void setGlobalVariableService(GlobalVariableService globalVariableService) {
		this.globalVariableService = globalVariableService;
	}
}
