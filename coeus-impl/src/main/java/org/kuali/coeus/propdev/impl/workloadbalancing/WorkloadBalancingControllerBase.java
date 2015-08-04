package org.kuali.coeus.propdev.impl.workloadbalancing;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.kuali.coeus.common.framework.auth.UnitAuthorizationService;
import org.kuali.coeus.common.framework.auth.perm.KcAuthorizationService;
import org.kuali.coeus.common.framework.ruleengine.KcBusinessRulesEngine;
import org.kuali.coeus.sys.framework.controller.KcCommonControllerService;
import org.kuali.coeus.sys.framework.controller.UifExportControllerService;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.kra.infrastructure.PermissionConstants;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.document.TransactionalDocumentControllerService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.web.service.CollectionControllerService;
import org.kuali.rice.krad.web.service.FileControllerService;
import org.kuali.rice.krad.web.service.ModelAndViewService;
import org.kuali.rice.krad.web.service.NavigationControllerService;
import org.kuali.rice.krad.web.service.QueryControllerService;
import org.kuali.rice.krad.web.service.RefreshControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.ModelAndView;

import edu.mit.kc.workloadbalancing.core.WorkloadForm;

public class WorkloadBalancingControllerBase {

	@Autowired
	@Qualifier("uifExportControllerService")
	private UifExportControllerService uifExportControllerService;

	@Autowired
	@Qualifier("kcCommonControllerService")
	private KcCommonControllerService kcCommonControllerService;

	@Autowired
	@Qualifier("transactionalDocumentControllerService")
	private TransactionalDocumentControllerService transactionalDocumentControllerService;

	@Autowired
	@Qualifier("collectionControllerService")
	private CollectionControllerService collectionControllerService;

	@Autowired
	@Qualifier("fileControllerService")
	private FileControllerService fileControllerService;

	@Autowired
	@Qualifier("modelAndViewService")
	private ModelAndViewService modelAndViewService;

	@Autowired
	@Qualifier("navigationControllerService")
	private NavigationControllerService navigationControllerService;

	@Autowired
	@Qualifier("queryControllerService")
	private QueryControllerService queryControllerService;

	@Autowired
	@Qualifier("refreshControllerService")
	private RefreshControllerService refreshControllerService;

	@Autowired
	@Qualifier("dataObjectService")
	private DataObjectService dataObjectService;

	@Autowired
	@Qualifier("kcBusinessRulesEngine")
	private KcBusinessRulesEngine kcBusinessRulesEngine;

	@Autowired
	@Qualifier("kualiConfigurationService")
	private ConfigurationService kualiConfigurationService;

	@Autowired
	@Qualifier("globalVariableService")
	private GlobalVariableService globalVariableService;
	
	@Autowired
	@Qualifier("kcAuthorizationService")
	private KcAuthorizationService kraAuthorizationService;
	 
	@Autowired
	@Qualifier("unitAuthorizationService")
    private UnitAuthorizationService unitAuthorizationService;


	public ModelAndView save(WorkloadForm form, BindingResult result,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		getDataObjectService().save(form);
		return getModelAndViewService().getModelAndView(form);
	}
	
     protected boolean hasSimulationPermission() {
    	 String userId = GlobalVariables.getUserSession().getPrincipalId();
         return unitAuthorizationService.hasPermission(userId,"KC-PD",PermissionConstants.RUN_SIMULATION);
     }
     protected boolean hasEditPermission(WorkloadForm form) {
     	boolean canView=false;
        String userId = GlobalVariables.getUserSession().getPrincipalId();
        if(unitAuthorizationService.hasPermission(userId,"KC-PD",PermissionConstants.EDIT_WL))
        {
           canView=true;
           form.setCanEdit(true) ;
        }else if(unitAuthorizationService.hasPermission(userId,"KC-PD",PermissionConstants.VIEW_WL)){
        	   canView=true;
        }
         return canView;
     }

	public UifExportControllerService getUifExportControllerService() {
		return uifExportControllerService;
	}

	public void setUifExportControllerService(
			UifExportControllerService uifExportControllerService) {
		this.uifExportControllerService = uifExportControllerService;
	}

	public KcCommonControllerService getKcCommonControllerService() {
		return kcCommonControllerService;
	}

	public void setKcCommonControllerService(
			KcCommonControllerService kcCommonControllerService) {
		this.kcCommonControllerService = kcCommonControllerService;
	}

	public TransactionalDocumentControllerService getTransactionalDocumentControllerService() {
		return transactionalDocumentControllerService;
	}

	public void setTransactionalDocumentControllerService(
			TransactionalDocumentControllerService transactionalDocumentControllerService) {
		this.transactionalDocumentControllerService = transactionalDocumentControllerService;
	}

	public CollectionControllerService getCollectionControllerService() {
		return collectionControllerService;
	}

	public void setCollectionControllerService(
			CollectionControllerService collectionControllerService) {
		this.collectionControllerService = collectionControllerService;
	}

	public FileControllerService getFileControllerService() {
		return fileControllerService;
	}

	public void setFileControllerService(
			FileControllerService fileControllerService) {
		this.fileControllerService = fileControllerService;
	}

	public ModelAndViewService getModelAndViewService() {
		return modelAndViewService;
	}

	public void setModelAndViewService(ModelAndViewService modelAndViewService) {
		this.modelAndViewService = modelAndViewService;
	}

	public NavigationControllerService getNavigationControllerService() {
		return navigationControllerService;
	}

	public void setNavigationControllerService(
			NavigationControllerService navigationControllerService) {
		this.navigationControllerService = navigationControllerService;
	}

	public QueryControllerService getQueryControllerService() {
		return queryControllerService;
	}

	public void setQueryControllerService(
			QueryControllerService queryControllerService) {
		this.queryControllerService = queryControllerService;
	}

	public RefreshControllerService getRefreshControllerService() {
		return refreshControllerService;
	}

	public void setRefreshControllerService(
			RefreshControllerService refreshControllerService) {
		this.refreshControllerService = refreshControllerService;
	}

	public DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}

	public KcBusinessRulesEngine getKcBusinessRulesEngine() {
		return kcBusinessRulesEngine;
	}

	public void setKcBusinessRulesEngine(
			KcBusinessRulesEngine kcBusinessRulesEngine) {
		this.kcBusinessRulesEngine = kcBusinessRulesEngine;
	}

	public ConfigurationService getKualiConfigurationService() {
		return kualiConfigurationService;
	}

	public void setKualiConfigurationService(
			ConfigurationService kualiConfigurationService) {
		this.kualiConfigurationService = kualiConfigurationService;
	}

	public GlobalVariableService getGlobalVariableService() {
		return globalVariableService;
	}

	public void setGlobalVariableService(
			GlobalVariableService globalVariableService) {
		this.globalVariableService = globalVariableService;
	}
	
	protected KcAuthorizationService getKraAuthorizationService() {
	      return kraAuthorizationService;
	}
    public void setKraAuthorizationService(KcAuthorizationService kraAuthorizationService) {
	      this.kraAuthorizationService = kraAuthorizationService;
	}
    public UnitAuthorizationService getUnitAuthorizationService() {
		return unitAuthorizationService;
	}
	public void setUnitAuthorizationService(
		UnitAuthorizationService unitAuthorizationService) {
		this.unitAuthorizationService = unitAuthorizationService;
	}
	    

}
