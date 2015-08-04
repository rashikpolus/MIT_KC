package org.kuali.coeus.propdev.impl.core;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.kuali.coeus.common.framework.sponsor.Sponsor;
import org.kuali.coeus.propdev.impl.sapfeed.SapFeedBatchDetails;
import org.kuali.coeus.propdev.impl.sapfeed.SapFeedDetails;
import org.kuali.coeus.propdev.impl.sapfeed.SapFeedErrorDetails;
import org.kuali.coeus.propdev.impl.sapfeed.SapFeedService;
import org.kuali.coeus.propdev.impl.sapfeed.SapFeedsForm;
import org.kuali.coeus.propdev.impl.sapfeed.TempSapSponsorDetails;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.criteria.QueryResults;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.web.controller.MethodAccessible;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

@Controller("sapFeedsCommonController")
@RequestMapping(value = "/sapFeedsCommon")
public class SapFeedsCommonController extends SapFeedsControllerBase {

	private static final String SAP_FEED_RESULT_DIALOG_ID = "FeedGenerated-DialogGroup";
	private static final String SAP_FEED_ERROR_DIALOG_ID = "FeedError-DialogGroup";
	private static final String SAP_FEED_COMMONERROR_DIALOG_ID = "FeedCommonError-DialogGroup";
	
	private static final String SAP_MASTERFEED_ERROR_DIALOG_ID = "MasterFeedNoPenidngFeed-DialogGroup";
	private static final String SAP_MASTERFEED_NO_PENDINGFEED_VALUE = "-100";
	private static final String SAP_FEED_INVALID_PATH_VALUE = "-1";
	private static final String DUMMY_SPONSOR = "999999";


	@Autowired
	@Qualifier("kualiConfigurationService")
	private ConfigurationService kualiConfigurationService;

	@Autowired
	@Qualifier("globalVariableService")
	private GlobalVariableService globalVariableService;

	@Autowired
	@Qualifier("sapFeedService")
	private SapFeedService sapFeedService;

	@MethodAccessible
	@Transactional
	@RequestMapping(params = "methodToCall=retrieveCollectionPage")
	public ModelAndView retrieveCollectionPage(
			@ModelAttribute("KualiForm") SapFeedsForm form,
			BindingResult result, HttpServletRequest request,
			HttpServletResponse response) throws Exception {
        
		generatePendingFeedCount(form);
        isSponsorUpdated(form);
		
        return getCollectionControllerService().retrieveCollectionPage(form);
	}

	@RequestMapping(params = "methodToCall=navigate")
	public ModelAndView navigate(@ModelAttribute("KualiForm") SapFeedsForm form)
			throws Exception {
		return super.navigate(form);
	}

	@Transactional
	@RequestMapping(value = "/sapFeedsCommon", params = "methodToCall=start")
	public ModelAndView start(@ModelAttribute("KualiForm") SapFeedsForm form,
			BindingResult result, HttpServletRequest request,
			HttpServletResponse response) {
		return getTransactionalDocumentControllerService().start(form);
	}

	@Transactional
	@RequestMapping(params = "methodToCall=defaultMapping")
	public ModelAndView defaultMapping(@RequestParam("path") String pathKey,
			@ModelAttribute("KualiForm") SapFeedsForm form,
			BindingResult result, HttpServletRequest request,
			HttpServletResponse response) throws SQLException {
		String path;
		if (pathKey.equals("P")){
			path = kualiConfigurationService
					.getPropertyValueAsString("SAP.PRODUCTION.PATH");
		}else{
			path = kualiConfigurationService
					.getPropertyValueAsString("SAP.TEST.PATH");
		}

	    String user=getLoggedInUser();
		String statusMasterFeed = null;
		String sapFeedStatus=null;
		String budgetFeedStatus=null;
		statusMasterFeed = sapFeedService.generateMasterFeed(path, user);
		
		String[] feedStatus=statusMasterFeed.split(",");
		if(feedStatus !=null &&feedStatus.length >=0){
			 sapFeedStatus=feedStatus[0];
			 budgetFeedStatus=feedStatus[1];
			 if (sapFeedStatus.equals("0") || sapFeedStatus.equals("-1")) {
					return getModelAndViewService().showDialog(
							SAP_FEED_COMMONERROR_DIALOG_ID, true, form);
				}

				if (sapFeedStatus.equals(SAP_MASTERFEED_NO_PENDINGFEED_VALUE)) {
					return getModelAndViewService().showDialog(
							SAP_MASTERFEED_ERROR_DIALOG_ID, true, form);
				}
				getSapFeedBatchDetals(form,sapFeedStatus);
		}
		
		
		return getModelAndViewService().showDialog(SAP_FEED_RESULT_DIALOG_ID,
				true, form);
	}

	@RequestMapping(params = "methodToCall=generateSponsor")
	public ModelAndView generateSponsor(@RequestParam("path") String pathKey,
			@ModelAttribute("KualiForm") SapFeedsForm form,
			BindingResult result, HttpServletRequest request,
			HttpServletResponse response) throws SQLException {
		String path;
		if (pathKey.equals("P")){
			path = kualiConfigurationService
					.getPropertyValueAsString("SAP.PRODUCTION.PATH");
		}else{
			path = kualiConfigurationService
					.getPropertyValueAsString("SAP.TEST.PATH");
		}
		String user=getLoggedInUser();
		String statusSponsorFeed = null;
		statusSponsorFeed = sapFeedService.generateSponsorFeed(path,user);
		if(statusSponsorFeed.equals("0"))
			form.setSponsorFeedGenerated(true);
		
		if (statusSponsorFeed.equals("")) {
			return getModelAndViewService().showDialog(
					SAP_FEED_COMMONERROR_DIALOG_ID, true, form);
		}
		
		if (statusSponsorFeed.equals(SAP_FEED_INVALID_PATH_VALUE)) {
			return getModelAndViewService().showDialog(
					SAP_FEED_ERROR_DIALOG_ID, true, form);
		}
		return getModelAndViewService().showDialog(SAP_FEED_RESULT_DIALOG_ID,
				true, form);
	}

	@RequestMapping(params = "methodToCall=generateRolodex")
	public ModelAndView generateRolodex(@RequestParam("path") String pathKey,
			@ModelAttribute("KualiForm") SapFeedsForm form,
			BindingResult result, HttpServletRequest request,
			HttpServletResponse response) throws SQLException {
		String path;
		if (pathKey.equals("P")){
			path = kualiConfigurationService
					.getPropertyValueAsString("SAP.PRODUCTION.PATH");
		}else{
			path = kualiConfigurationService
					.getPropertyValueAsString("SAP.TEST.PATH");
		}
		
		String user=getLoggedInUser();
		String statusRolodexFeed = null;
		statusRolodexFeed = sapFeedService.generateRolodexFeed(path,user);
		
		if(statusRolodexFeed.equals("0"))
			form.setRolodexFeedGenerated(true);
		
		if (statusRolodexFeed.equals("")) {
			return getModelAndViewService().showDialog(
					SAP_FEED_COMMONERROR_DIALOG_ID, true, form);
		}

		if (statusRolodexFeed.equals(SAP_FEED_INVALID_PATH_VALUE)) {
			return getModelAndViewService().showDialog(
					SAP_FEED_ERROR_DIALOG_ID, true, form);
		}
		return getModelAndViewService().showDialog(SAP_FEED_RESULT_DIALOG_ID,
				true, form);
	}
	
	public void getSapFeedBatchDetals(SapFeedsForm form,String sapFeedBatchId) {
		
		List<SapFeedDetails> fedSapfeedDetails=new ArrayList<SapFeedDetails>();;
		List<SapFeedDetails> errorSapfeedDetails=new ArrayList<SapFeedDetails>();;
		HashMap<String, String> fieldValues = new HashMap<String, String>();
		HashMap<String, String> params = new HashMap<String, String>();
		
		fieldValues.put("sapFeedBatchId", sapFeedBatchId);
		fieldValues.put("feedStatus", "E");
		
		params.put("sapFeedBatchId", sapFeedBatchId);
		params.put("feedStatus", "F");

		errorSapfeedDetails = (List<SapFeedDetails>) KcServiceLocator.getService(BusinessObjectService.class).findMatching(SapFeedDetails.class,fieldValues);
		fedSapfeedDetails = (List<SapFeedDetails>) KcServiceLocator.getService(BusinessObjectService.class).findMatching(SapFeedDetails.class,params);
		
		
		SapFeedBatchDetails sapFeedBatchDetail = KcServiceLocator.getService(DataObjectService.class).findUnique(SapFeedBatchDetails.class, QueryByCriteria.Builder.andAttributes(Collections.singletonMap("sapFeedBatchId", sapFeedBatchId)).build());
		if(sapFeedBatchDetail !=null )
		form.setBatchFileName(sapFeedBatchDetail.getBatchFileName());
		
		
	    QueryResults<SapFeedErrorDetails> sapFeedErrorDetails = KcServiceLocator.getService(DataObjectService.class).findMatching(SapFeedErrorDetails.class, QueryByCriteria.Builder.andAttributes(Collections.singletonMap("sapFeedBatchId", sapFeedBatchId)).build());
		if(sapFeedErrorDetails !=null )
			form.setSapFeedErrorDetails(sapFeedErrorDetails.getResults());
			
		if(errorSapfeedDetails !=null && fedSapfeedDetails!=null ){
			form.setFedInRecords(fedSapfeedDetails.size());
			form.setErrorInRecords(errorSapfeedDetails.size());
		}
		
	}
	
	public void generatePendingFeedCount(SapFeedsForm form) {
		
		List<SapFeedDetails> sapfeedDetails=null;
		HashMap<String, String> fieldValues = new HashMap<String, String>();
		fieldValues.put("feedStatus", "P");

		sapfeedDetails = (List<SapFeedDetails>) KcServiceLocator.getService(BusinessObjectService.class).findMatching(SapFeedDetails.class,fieldValues);
		if(sapfeedDetails !=null && sapfeedDetails.size() >=0)
		form.setPendingFeedCount(sapfeedDetails.size());
	}
	
	public void isSponsorUpdated(SapFeedsForm form) {
		 
		 List<Sponsor> sponsors=null;
		 List<Sponsor> dummySponsors =null ;
		 List<TempSapSponsorDetails> tempSapSponsorDetails = null;
		 HashMap<String, String> fieldValues = new HashMap<String, String>();
		 fieldValues.put("sponsorCode", "999999");
		 int sponsorCount=0;
		
		 sponsors = (List<Sponsor>) KcServiceLocator.getService(BusinessObjectService.class).findAll(Sponsor.class);
		 dummySponsors = (List<Sponsor>) KcServiceLocator.getService(BusinessObjectService.class).findMatching(Sponsor.class, fieldValues);
		 
		 if(sponsors !=null && dummySponsors !=null)
			 sponsorCount=sponsors.size()-dummySponsors.size();
		
		 tempSapSponsorDetails = (List<TempSapSponsorDetails>) KcServiceLocator.getService(BusinessObjectService.class).findAll(TempSapSponsorDetails.class);
		 
		 if (tempSapSponsorDetails !=null && sponsorCount != tempSapSponsorDetails.size())
			 form.setSponsordatachanged(true);
	}
	
	public String getLoggedInUser(){
		return globalVariableService.getUserSession().getLoggedInUserPrincipalName();
	}
	
	public void setKualiConfigurationService(
			ConfigurationService kualiConfigurationService) {
		this.kualiConfigurationService = kualiConfigurationService;
	}

	public ConfigurationService getKualiConfigurationService() {
		return kualiConfigurationService;
	}

	public GlobalVariableService getGlobalVariableService() {
		return globalVariableService;
	}

	public void setGlobalVariableService(
			GlobalVariableService globalVariableService) {
		this.globalVariableService = globalVariableService;
	}

	public SapFeedService getSapFeedService() {
		return sapFeedService;
	}

	public void setSapFeedService(SapFeedService sapFeedService) {
		this.sapFeedService = sapFeedService;
	}
}
