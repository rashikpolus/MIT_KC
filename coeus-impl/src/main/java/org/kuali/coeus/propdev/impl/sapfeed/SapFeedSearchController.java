package org.kuali.coeus.propdev.impl.sapfeed;

import edu.mit.kc.sapfeed.core.SapFeedSearchForm;
import org.apache.commons.lang.StringUtils;
import org.kuali.coeus.sys.framework.controller.KcCommonControllerService;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.criteria.Predicate;
import org.kuali.rice.core.api.criteria.PredicateFactory;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.search.SearchOperator;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.uif.UifParameters;
import org.kuali.rice.krad.web.form.UifFormBase;
import org.kuali.rice.krad.web.service.NavigationControllerService;
import org.kuali.rice.krad.web.service.RefreshControllerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Date;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Brian on 4/8/15.
 */
@Controller("sapFeedSearch")
@RequestMapping(value = "/sapFeedSearch")
public class SapFeedSearchController {

    @Autowired
    @Qualifier("dataObjectService")
    private DataObjectService dataObjectService;

    @Autowired
    @Qualifier("kualiConfigurationService")
    private ConfigurationService kualiConfigurationService;

    @Autowired
    @Qualifier("globalVariableService")
    private GlobalVariableService globalVariableService;

    @Autowired
    @Qualifier("refreshControllerService")
    private RefreshControllerService refreshControllerService;

    @Autowired
    @Qualifier("kcCommonControllerService")
    private KcCommonControllerService kcCommonControllerService;

    @Autowired
    @Qualifier("navigationControllerService")
    private NavigationControllerService navigationControllerService;

    @Autowired
   	@Qualifier("sapFeedService")
   	private SapFeedService sapFeedService;

    private static final String SAP_FEED_ACTION_ALLOWED_ERROR_KEY = "error.sapfeed.action.allowed";
    private static final String SAP_FEED_SEARCH_PAGE_ID = "SapFeedSearch-View";
    private static final String SAP_FEED_SEARCH_ERROR_KEY = "error.sapfeed.search.criteria";
    
    @ModelAttribute(value = "KualiForm")
    public UifFormBase initForm(HttpServletRequest request,
                                HttpServletResponse response) throws Exception {
        UifFormBase form = getKcCommonControllerService().initForm(
                this.createInitialForm(request), request, response);

        return form;
    }

    protected SapFeedSearchForm createInitialForm(HttpServletRequest request) {
        SapFeedSearchForm form = new SapFeedSearchForm();

        return form;
    }

    @Transactional
    @RequestMapping(params = "methodToCall=start")
    public ModelAndView start(
            @ModelAttribute("KualiForm") SapFeedSearchForm form) throws Exception {

        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=refresh")
    public ModelAndView refresh(@ModelAttribute("KualiForm") SapFeedSearchForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String refreshId = request.getParameter("updateComponentId");

        // force binding
        String resendBatchId = request.getParameter("resendBatchId");
        form.setResendBatchId(resendBatchId);
        String resendSapBatchId = request.getParameter("resendSapFeedBatchId");
        form.setResendSapFeedBatchId(resendSapBatchId);

        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=search")
    public ModelAndView search(@ModelAttribute("KualiForm") SapFeedSearchForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
    	performSearch(form);
        return getNavigationControllerService().navigate(form);
    }
    
    protected void performSearch(SapFeedSearchForm form) {
        String searchType = form.getSearchType();
        HashMap<String, String> criteria = new HashMap<String, String>();

        if (searchType == null) {
        	getGlobalVariableService().getMessageMap().putError(SAP_FEED_SEARCH_PAGE_ID, SAP_FEED_SEARCH_ERROR_KEY);
        }else {
            if (searchType.equals("BATCH")) {
                String searchSummary = "[span class='sapSearch-subTitle']for '";
                List<Predicate> predicates = new ArrayList<>();
                if (StringUtils.isNotBlank(form.getBatchId())) {
                    searchSummary = searchSummary + "Batch ID: " + form.getBatchId() + ", ";
                    predicates.add(PredicateFactory.equal("batchId", form.getBatchId()));
                }

                if (form.getBatchStartDate() != null && form.getBatchEndDate() != null) {
                    predicates.add(PredicateFactory.between("batchTimeStamp", form.getBatchStartDate(), form.getBatchEndDate()));
                    searchSummary = searchSummary + "Dates: " + form.getBatchStartDate() + "-" + form.getBatchEndDate();
                } else if (form.getBatchStartDate() != null) {
                    predicates.add(PredicateFactory.greaterThanOrEqual("batchTimeStamp", form.getBatchStartDate()));
                    searchSummary = searchSummary + "Dates: " + ">=" + form.getBatchStartDate();
                } else if (form.getBatchEndDate() != null) {
                    predicates.add(PredicateFactory.lessThanOrEqual("batchTimeStamp", form.getBatchEndDate()));
                    searchSummary = searchSummary + "Dates: " + "<=" + form.getBatchEndDate();
                }

                List<SapFeedBatchDetails> sapFeedBatchDetailsList = new ArrayList<>();

                if (predicates.isEmpty()) {
                    sapFeedBatchDetailsList =
                            getDataObjectService().findAll(SapFeedBatchDetails.class).getResults();
                    searchSummary = "";
                } else {
                    QueryByCriteria query = QueryByCriteria.Builder.fromPredicates(predicates);
                    sapFeedBatchDetailsList =
                            getDataObjectService().findMatching(SapFeedBatchDetails.class, query).getResults();
                    searchSummary = StringUtils.removeEnd(searchSummary, ", ") + "'[/span]";
                }

                form.setBatchSearchResults(sapFeedBatchDetailsList);
                form.setSearchSummary(searchSummary);

                form.getActionParameters().put(UifParameters.NAVIGATE_TO_PAGE_ID, "SapFeedSearch-BatchPage");

            } else if (searchType.startsWith("DETAILS")) {
                String searchSummary = "[span class='sapSearch-subTitle']for '";

                if (searchType.equals("DETAILS_PENDING")) {
                    criteria.put("feedStatus", "P");
                    searchSummary = searchSummary + "Status: Pending'[/span]";

                } else if (StringUtils.isNotBlank(form.getAwardNumber())) {
                    criteria.put("awardNumber", form.getAwardNumber());
                    searchSummary = searchSummary + "Award Number: " + form.getAwardNumber() + "'[/span]";
                }

                List<SapFeedDetails> sapFeedDetailsList = new ArrayList<>();

                if (criteria.isEmpty()) {
                    sapFeedDetailsList = getDataObjectService().findAll(SapFeedDetails.class).getResults();
                    searchSummary = "";
                } else {
                    sapFeedDetailsList =
                            getDataObjectService().findMatching(SapFeedDetails.class, QueryByCriteria.Builder.andAttributes(criteria).build()).getResults();
                }

                form.setDetailsSearchResults(sapFeedDetailsList);
                form.setSearchSummary(searchSummary);

                form.getActionParameters().put(UifParameters.NAVIGATE_TO_PAGE_ID, "SapFeedSearch-DetailsPage");
            }
        }
    }

    @Transactional
    @RequestMapping(params = "methodToCall=restoreFeed")
    public ModelAndView restoreFeed(@ModelAttribute("KualiForm") SapFeedSearchForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) {
        String feedId = request.getParameter("feedId").trim();
		SapFeedDetails sapFeedDetails = getSapFeedDetails(feedId);
		if (sapFeedDetails != null && sapFeedDetails.isFeedRejected()) {
	        sapFeedService.performUndoReject(sapFeedDetails);
	    	performSearch(form);
	        return getNavigationControllerService().navigate(form);
		}else {
        	getGlobalVariableService().getMessageMap().putError(SAP_FEED_SEARCH_PAGE_ID, SAP_FEED_ACTION_ALLOWED_ERROR_KEY, new String[]{"Restore", "Rejected"});
		}
        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=rejectFeed")
    public ModelAndView rejectFeed(@ModelAttribute("KualiForm") SapFeedSearchForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) {
        String feedId = request.getParameter("feedId").trim();
		SapFeedDetails sapFeedDetails = getSapFeedDetails(feedId);
		if (sapFeedDetails != null && sapFeedDetails.isFeedFed()) {
	        sapFeedService.performRejectAction(sapFeedDetails);
	    	performSearch(form);
	        return getNavigationControllerService().navigate(form);
		}else {
        	getGlobalVariableService().getMessageMap().putError(SAP_FEED_SEARCH_PAGE_ID, SAP_FEED_ACTION_ALLOWED_ERROR_KEY, new String[]{"Reject", "Fed"});
		}
        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=cancelFeed")
    public ModelAndView cancelFeed(@ModelAttribute("KualiForm") SapFeedSearchForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) {
        String feedId = request.getParameter("feedId").trim();
		SapFeedDetails sapFeedDetails = getSapFeedDetails(feedId);
		if (sapFeedDetails != null && sapFeedDetails.isFeedPending()) {
	        sapFeedService.performCancelAction(sapFeedDetails);
	    	performSearch(form);
	        return getNavigationControllerService().navigate(form);
		}else {
        	getGlobalVariableService().getMessageMap().putError(SAP_FEED_SEARCH_PAGE_ID, SAP_FEED_ACTION_ALLOWED_ERROR_KEY, new String[]{"Cancel", "Pending"});
		}
        return getRefreshControllerService().refresh(form);
    }
    
    protected SapFeedDetails getSapFeedDetails(String feedId) {
		return getDataObjectService().findUnique(SapFeedDetails.class,QueryByCriteria.Builder.andAttributes(Collections.singletonMap("feedId", feedId)).build());
    }
    
    @Transactional
    @RequestMapping(params = "methodToCall=resendBatch")
    public ModelAndView resendBatch(@ModelAttribute("KualiForm") SapFeedSearchForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) {
        boolean resendSubsequent = false;
        if (form.getResendBatchType().equals("ALL")) {
            resendSubsequent = true;
        }

        String path = getKualiConfigurationService().getPropertyValueAsString(form.getResendTargetDirectory());
        sapFeedService.performResendBatch(Integer.valueOf(form.getResendBatchId()),
                Integer.valueOf(form.getResendSapFeedBatchId()), resendSubsequent, path);

        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(method = RequestMethod.POST, params = "methodToCall=navigate")
    public ModelAndView navigate(SapFeedSearchForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) {
        String navigateId = form.getActionParamaterValue(UifParameters.NAVIGATE_TO_PAGE_ID);

        if (navigateId.equals("SapFeedSearch-StartPage")) {
            form.setAwardNumber(null);
            form.setBatchStartDate(null);
            form.setBatchEndDate(null);
            form.setSearchType("");
            form.setBatchId(null);
        }

        return getNavigationControllerService().navigate(form);
    }

    public DataObjectService getDataObjectService() {
        return dataObjectService;
    }

    public void setDataObjectService(DataObjectService dataObjectService) {
        this.dataObjectService = dataObjectService;
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

    public RefreshControllerService getRefreshControllerService() {
        return refreshControllerService;
    }

    public void setRefreshControllerService(RefreshControllerService refreshControllerService) {
        this.refreshControllerService = refreshControllerService;
    }

    public KcCommonControllerService getKcCommonControllerService() {
        return kcCommonControllerService;
    }

    public void setKcCommonControllerService(KcCommonControllerService kcCommonControllerService) {
        this.kcCommonControllerService = kcCommonControllerService;
    }

    public NavigationControllerService getNavigationControllerService() {
        return navigationControllerService;
    }

    public void setNavigationControllerService(NavigationControllerService navigationControllerService) {
        this.navigationControllerService = navigationControllerService;
    }

    public SapFeedService getSapFeedService() {
        return sapFeedService;
    }

    public void setSapFeedService(SapFeedService sapFeedService) {
        this.sapFeedService = sapFeedService;
    }
}
