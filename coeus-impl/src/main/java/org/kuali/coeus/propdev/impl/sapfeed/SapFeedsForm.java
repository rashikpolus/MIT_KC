package org.kuali.coeus.propdev.impl.sapfeed;

import java.sql.Timestamp;
import java.util.List;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.coreservice.api.parameter.Parameter;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.web.form.UifFormBase;

public class SapFeedsForm extends UifFormBase {
	
    private transient ParameterService parameterService;
    
    protected static final String SAP_FEED_SPONSORFEED_USER = "SAP_FEED_SPONSOR_FEED_USER";
    protected static final String SAP_FEED_SPONSORFEED_DATE = "SAP_FEED_SPONSOR_FEED_DATE";
	protected static final String SAP_FEED_ROLODEXFEED_USER = "SAP_FEED_ROLODEX_FEED_USER";
	protected static final String SAP_FEED_ROLODEXFEED_DATE = "SAP_FEED_ROLODEX_FEED_DATE";
	protected static final String KC_GENERAL_NAMESPACE = "KC-GEN";
	protected static final String DOCUMENT_COMPONENT_NAME = "All";
	
	private String path;
	private int pendingFeedCount;
	private Boolean sponsordatachanged=false;
	private Boolean masterFeedFileGenerated=false;
	private Boolean sponsorFeedGenerated=false;
	private Boolean rolodexFeedGenerated=false;
	private String batchFileName;
	private int fedInRecords;
	private int errorInRecords;
	
	private String sponsorFeedUser=null;
	private String sponsorFeedDate=null;
	private String rolodexFeedUser=null;
	private String rolodexFeedDate=null;
	
	
	private List<SapFeedErrorDetails> sapFeedErrorDetails;

	public Boolean getSponsordatachanged() {
		return sponsordatachanged;
	}

	public void setSponsordatachanged(Boolean sponsordatachanged) {
		this.sponsordatachanged = sponsordatachanged;
	}

	public String getPath() {
		return path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public int getPendingFeedCount() {
		return pendingFeedCount;
	}

	public void setPendingFeedCount(int pendingFeedCount) {
		this.pendingFeedCount = pendingFeedCount;
	}

	public Boolean getSponsorFeedGenerated() {
		return sponsorFeedGenerated;
	}

	public void setSponsorFeedGenerated(Boolean sponsorFeedGenerated) {
		this.sponsorFeedGenerated = sponsorFeedGenerated;
	}

	public Boolean getRolodexFeedGenerated() {
		return rolodexFeedGenerated;
	}

	public void setRolodexFeedGenerated(Boolean rolodexFeedGenerated) {
		this.rolodexFeedGenerated = rolodexFeedGenerated;
	}

	
	public Boolean getMasterFeedFileGenerated() {
		return masterFeedFileGenerated;
	}

	public void setMasterFeedFileGenerated(Boolean masterFeedFileGenerated) {
		this.masterFeedFileGenerated = masterFeedFileGenerated;
	}

	public String getBatchFileName() {
		return batchFileName;
	}

	public void setBatchFileName(String batchFileName) {
		this.batchFileName = batchFileName;
	}

	public int getFedInRecords() {
		return fedInRecords;
	}

	public void setFedInRecords(int fedInRecords) {
		this.fedInRecords = fedInRecords;
	}

	public int getErrorInRecords() {
		return errorInRecords;
	}

	public void setErrorInRecords(int errorInRecords) {
		this.errorInRecords = errorInRecords;
	}
	
	 protected ParameterService getParameterService() {
	        if (this.parameterService == null) {
	            this.parameterService = KcServiceLocator.getService(ParameterService.class);
	        }
	        return this.parameterService;
	    }

	public void setParameterService(ParameterService parameterService) {
		this.parameterService = parameterService;
	}

	public String getSponsorFeedUser() {
		Parameter param = this.getParameterService().getParameter(KC_GENERAL_NAMESPACE, DOCUMENT_COMPONENT_NAME,SAP_FEED_SPONSORFEED_USER);
		if(param !=null){
			sponsorFeedUser=param.getValue();
		}
		return sponsorFeedUser;
	}

	public void setSponsorFeedUser(String sponsorFeedUser) {
		this.sponsorFeedUser = sponsorFeedUser;
	}

	public String getSponsorFeedDate() {
		Parameter param = this.getParameterService().getParameter(KC_GENERAL_NAMESPACE, DOCUMENT_COMPONENT_NAME,SAP_FEED_SPONSORFEED_DATE);
		if(param !=null){
			sponsorFeedDate=param.getValue();
		}
		return sponsorFeedDate;
	}

	public void setSponsorFeedDate(String sponsorFeedDate) {
		this.sponsorFeedDate = sponsorFeedDate;
	}

	public String getRolodexFeedUser() {
		Parameter param = this.getParameterService().getParameter(KC_GENERAL_NAMESPACE, DOCUMENT_COMPONENT_NAME,SAP_FEED_ROLODEXFEED_USER);
		if(param !=null){
			rolodexFeedUser=param.getValue();
		}
		return rolodexFeedUser;
	}

	public void setRolodexFeedUser(String rolodexFeedUser) {
		this.rolodexFeedUser = rolodexFeedUser;
	}

	public String getRolodexFeedDate() {
		Parameter param = this.getParameterService().getParameter(KC_GENERAL_NAMESPACE, DOCUMENT_COMPONENT_NAME,SAP_FEED_ROLODEXFEED_DATE);
		if(param !=null){
			rolodexFeedDate=param.getValue();
		}
		return rolodexFeedDate;
	}

	public void setRolodexFeedDate(String rolodexFeedDate) {
		this.rolodexFeedDate = rolodexFeedDate;
	}

	public List<SapFeedErrorDetails> getSapFeedErrorDetails() {
		return sapFeedErrorDetails;
	}

	public void setSapFeedErrorDetails(List<SapFeedErrorDetails> sapFeedErrorDetails) {
		this.sapFeedErrorDetails = sapFeedErrorDetails;
	}
	
}
