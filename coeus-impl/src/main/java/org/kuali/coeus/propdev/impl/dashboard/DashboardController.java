/**
 * Copyright 2005-2014 The Kuali Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.opensource.org/licenses/ecl2.php
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kuali.coeus.propdev.impl.dashboard;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.common.framework.person.KcPersonService;
import org.kuali.coeus.common.framework.ruleengine.KcBusinessRulesEngine;
import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.coeus.sys.framework.controller.KcCommonControllerService;
import org.kuali.coeus.sys.framework.controller.UifExportControllerService;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.document.authorization.AwardDocumentAuthorizer;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardService;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.kew.api.document.WorkflowDocumentService;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.document.TransactionalDocumentControllerService;
import org.kuali.rice.krad.service.LookupService;
import org.kuali.rice.krad.uif.field.AttributeQueryResult;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.web.controller.MethodAccessible;
import org.kuali.rice.krad.web.form.UifFormBase;
import org.kuali.rice.krad.web.service.CollectionControllerService;
import org.kuali.rice.krad.web.service.ModelAndViewService;
import org.kuali.rice.krad.web.service.NavigationControllerService;
import org.kuali.rice.krad.web.service.QueryControllerService;
import org.kuali.rice.krad.web.service.RefreshControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import edu.mit.kc.alert.service.ApplicationAlertService;
import edu.mit.kc.dashboard.bo.Alert;
import edu.mit.kc.dashboard.bo.Expenditures;
import edu.mit.kc.dashboard.core.DashboardForm;
import edu.mit.kc.workloadbalancing.core.WorkloadForm;

@Controller("dashboard")
@RequestMapping(value = "/dashboard")
public class DashboardController {

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
    @Qualifier("lookupService")
    private LookupService lookupService;

    @Autowired
    @Qualifier("kewWorkflowDocumentService")
    private WorkflowDocumentService workflowDocumentService;

    @Autowired
    @Qualifier("awardService")
    private AwardService awardService;

    @Autowired
    @Qualifier("kcPersonService")
    private KcPersonService kcPersonService;

    @Autowired
    @Qualifier("dashboardService")
    private DashboardService dashboardService;
    
    private ApplicationAlertService applicationAlertService;
    
    @ModelAttribute(value = "KualiForm")
    public UifFormBase initForm(HttpServletRequest request,
                                HttpServletResponse response) throws Exception {
        UifFormBase form = getKcCommonControllerService().initForm(
                this.createInitialForm(request), request, response);

        return form;
    }

    protected DashboardForm createInitialForm(HttpServletRequest request) {
        DashboardForm form = new DashboardForm();
        Person currentUser = GlobalVariables.getUserSession().getPerson();
        KcPerson kcPerson = kcPersonService.getKcPersonByPersonId(currentUser.getPrincipalId());
        form.setDashboardPerson(kcPerson);
        populateProposals(form);
        populateGraphData(form);
        populateAlerts(form);
        return form;
    }

    @Transactional
    @RequestMapping(params = "methodToCall=start")
    public ModelAndView start(
            @ModelAttribute("KualiForm") DashboardForm form) throws Exception {
        if (form.getClientStateForSyncing() != null) {
            form.getClientStateForSyncing().remove("Dashboard-Activity");
        }

        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=refresh")
    public ModelAndView refresh(@ModelAttribute("KualiForm") DashboardForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String refreshId = request.getParameter("updateComponentId");

        if (form.getMyAwards() == null &&
                (refreshId.equals("Dashboard-MyAwards") || refreshId.equals("Dashboard-ProjectDocuments") || refreshId.equals("Dashboard-KeyPerson"))) {
            populateAwards(form);
        }

        return getRefreshControllerService().refresh(form);
    }

    protected void populateAlerts(DashboardForm form) {
      HashMap<String, String> criteria = new HashMap<String, String>();
      criteria.put("userName", form.getDashboardPerson().getUserName());
      criteria.put("active", "Y");
      List<Alert> alerts =
              dataObjectService.findMatching(Alert.class, QueryByCriteria.Builder.andAttributes(criteria).setOrderByAscending("priority").build()).getResults();

      form.setAlerts(alerts);
    }

    protected void configureAlerts(String user) {
		getApplicationAlertService().processAllAlerts(user);
    }
    
    protected void populateGraphData(DashboardForm form) {
        HashMap<String, String> criteria = new HashMap<String, String>();
        criteria.put("userName", form.getDashboardPerson().getUserName());
        List<Expenditures> expendituresList =
                dataObjectService.findMatching(Expenditures.class, QueryByCriteria.Builder.andAttributes(criteria).setOrderByAscending("fiscalYear").build()).getResults();
        form.setExpenditureData(expendituresList);
    }

    protected void populateProposals(DashboardForm form) {
    	form.setMyProposals(getDashboardService().getProposalsForInvestigator(form.getDashboardPerson().getPersonId()));
    }
    
    protected void populateAwards(DashboardForm form) {
    	List<Award> myAwards = getDashboardService().getAwardsForInvestigator(form.getDashboardPerson().getPersonId());
        form.setMyAwards(myAwards);
        form.setMyProjects(getDashboardService().getInvestigatorAwardsForProjectDocument(myAwards));
    }
    
    // TODO unknown if need to filter on permission
    public List<Award> filterForPermissions(List<Award> results) {
        Person user = GlobalVariables.getUserSession().getPerson();
        AwardDocumentAuthorizer authorizer = new AwardDocumentAuthorizer();
        List<Award> filteredResults = new ArrayList<Award>();
        // if the user has permission.
        for (Award award : results) {
            if (award!=null && authorizer.canOpen(award.getAwardDocument(), user)) {
                filteredResults.add(award);
            }
        }
        return filteredResults;
    }

    @Transactional
    @RequestMapping(params = "methodToCall=changeDashboard")
    public ModelAndView changeDashboard(@ModelAttribute("KualiForm") DashboardForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String personId = null;
        KcPerson person = null;
        if (!StringUtils.isBlank(form.getTempUserName())) {
            person = kcPersonService.getKcPersonByUserName(form.getTempUserName());
            if (person != null) {
                personId = person.getPersonId();
            }
        }

        // Show message for missing person
        if (StringUtils.isBlank(personId)) {
            getGlobalVariableService().getMessageMap().putError("tempUserName", "dashboard.error.missingPerson");
            form.setUpdateComponentId("Dashboard-SpecifyUser-Dialog");
            return getRefreshControllerService().refresh(form);
        }

        form.setTempUserName(null);
        form.setMyProposals(new ArrayList<ProposalPerson>());
        form.setMyAwards(null);
        form.setMyProjects(null);
        if (form.getClientStateForSyncing() != null) {
            form.getClientStateForSyncing().remove("Dashboard-Activity");
        }

        form.setDashboardPerson(person);
        configureAlerts(person.getUserName());
        populateProposals(form);
        populateGraphData(form);
        populateAlerts(form);

        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=tableJsonRetrieval")
    public ModelAndView tableJsonRetrieval(@ModelAttribute("KualiForm") DashboardForm form, BindingResult result, HttpServletRequest request,
                                           HttpServletResponse response) {
        return getCollectionControllerService().tableJsonRetrieval(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=retrieveCollectionPage")
    public ModelAndView retrieveCollectionPage(@ModelAttribute("KualiForm") DashboardForm form, BindingResult result, HttpServletRequest request,
                                               HttpServletResponse response) throws Exception {
        return getCollectionControllerService().retrieveCollectionPage(form);
    }

    @MethodAccessible
    @Transactional
    @RequestMapping(params = "methodToCall=performFieldQuery")
    public
    @ResponseBody
        AttributeQueryResult performFieldQuery(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request,
                                           HttpServletResponse response) {
        return getQueryControllerService().performFieldQuery(form);
    }

    public UifExportControllerService getUifExportControllerService() {
        return uifExportControllerService;
    }

    public void setUifExportControllerService(UifExportControllerService uifExportControllerService) {
        this.uifExportControllerService = uifExportControllerService;
    }

    public KcCommonControllerService getKcCommonControllerService() {
        return kcCommonControllerService;
    }

    public void setKcCommonControllerService(KcCommonControllerService kcCommonControllerService) {
        this.kcCommonControllerService = kcCommonControllerService;
    }

    public TransactionalDocumentControllerService getTransactionalDocumentControllerService() {
        return transactionalDocumentControllerService;
    }

    public void setTransactionalDocumentControllerService(TransactionalDocumentControllerService transactionalDocumentControllerService) {
        this.transactionalDocumentControllerService = transactionalDocumentControllerService;
    }

    public CollectionControllerService getCollectionControllerService() {
        return collectionControllerService;
    }

    public void setCollectionControllerService(CollectionControllerService collectionControllerService) {
        this.collectionControllerService = collectionControllerService;
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

    public void setNavigationControllerService(NavigationControllerService navigationControllerService) {
        this.navigationControllerService = navigationControllerService;
    }

    public QueryControllerService getQueryControllerService() {
        return queryControllerService;
    }

    public void setQueryControllerService(QueryControllerService queryControllerService) {
        this.queryControllerService = queryControllerService;
    }

    public RefreshControllerService getRefreshControllerService() {
        return refreshControllerService;
    }

    public void setRefreshControllerService(RefreshControllerService refreshControllerService) {
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

    public void setKcBusinessRulesEngine(KcBusinessRulesEngine kcBusinessRulesEngine) {
        this.kcBusinessRulesEngine = kcBusinessRulesEngine;
    }

    public ConfigurationService getKualiConfigurationService() {
        return kualiConfigurationService;
    }

    public void setKualiConfigurationService(ConfigurationService kualiConfigurationService) {
        this.kualiConfigurationService = kualiConfigurationService;
    }

    public GlobalVariableService getGlobalVariableService() {
        return globalVariableService;
    }

    public void setGlobalVariableService(GlobalVariableService globalVariableService) {
        this.globalVariableService = globalVariableService;
    }

    public LookupService getLookupService() {
        return lookupService;
    }

    public void setLookupService(LookupService lookupService) {
        this.lookupService = lookupService;
    }

    public WorkflowDocumentService getWorkflowDocumentService() {
        return workflowDocumentService;
    }

    public void setWorkflowDocumentService(WorkflowDocumentService workflowDocumentService) {
        this.workflowDocumentService = workflowDocumentService;
    }

    public AwardService getAwardService() {
        return awardService;
    }

    public void setAwardService(AwardService awardService) {
        this.awardService = awardService;
    }

    public KcPersonService getKcPersonService() {
        return kcPersonService;
    }

    public void setKcPersonService(KcPersonService kcPersonService) {
        this.kcPersonService = kcPersonService;
    }

	public DashboardService getDashboardService() {
		return dashboardService;
	}

	public void setDashboardService(DashboardService dashboardService) {
		this.dashboardService = dashboardService;
	}

	public ApplicationAlertService getApplicationAlertService() {
		if(applicationAlertService == null) {
			this.applicationAlertService = KcServiceLocator.getService(ApplicationAlertService.class);
		}
		return applicationAlertService;
	}

	public void setApplicationAlertService(ApplicationAlertService applicationAlertService) {
		this.applicationAlertService = applicationAlertService;
	}

}
