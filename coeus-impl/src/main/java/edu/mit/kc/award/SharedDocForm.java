/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.opensource.org/licenses/ecl1.php
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package edu.mit.kc.award;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.kuali.coeus.common.framework.medusa.MedusaBean;
import org.kuali.coeus.common.framework.module.CoeusModule;
import org.kuali.coeus.common.framework.version.history.VersionHistory;
import org.kuali.coeus.common.framework.version.history.VersionHistoryService;
import org.kuali.coeus.common.notification.impl.NotificationHelper;
import org.kuali.coeus.common.permissions.impl.web.struts.form.PermissionsForm;
import org.kuali.coeus.sys.framework.model.MultiLookupForm;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.coeus.sys.framework.validation.Auditable;
import org.kuali.kra.authorization.KraAuthorizationConstants;
import org.kuali.kra.award.AwardForm;
import org.kuali.kra.award.AwardTemplateSyncScope;
import org.kuali.kra.award.awardhierarchy.AwardHierarchy;
import org.kuali.kra.award.awardhierarchy.AwardHierarchyBean;
import org.kuali.kra.award.awardhierarchy.AwardHierarchyTempObject;
import org.kuali.kra.award.awardhierarchy.sync.AwardSyncBean;
import org.kuali.kra.award.budget.AwardBudgetLimitsBean;
import org.kuali.kra.award.budget.BudgetLimitSummaryHelper;
import org.kuali.kra.award.commitments.AwardFandaRate;
import org.kuali.kra.award.commitments.CostShareFormHelper;
import org.kuali.kra.award.contacts.AwardCentralAdminContactsBean;
import org.kuali.kra.award.contacts.AwardCreditSplitBean;
import org.kuali.kra.award.contacts.AwardProjectPersonnelBean;
import org.kuali.kra.award.contacts.AwardSponsorContactsBean;
import org.kuali.kra.award.contacts.AwardUnitContactsBean;
import org.kuali.kra.award.detailsdates.DetailsAndDatesFormHelper;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardComment;
import org.kuali.kra.award.home.approvedsubawards.ApprovedSubawardFormHelper;
import org.kuali.kra.award.home.fundingproposal.AwardFundingProposal;
import org.kuali.kra.award.home.fundingproposal.AwardFundingProposalBean;
import org.kuali.kra.award.notesandattachments.attachments.AwardAttachmentFormBean;
import org.kuali.kra.award.notesandattachments.comments.AwardCommentBean;
import org.kuali.kra.award.notesandattachments.notes.AwardNotepadBean;
import org.kuali.kra.award.notification.AwardNotificationContext;
import org.kuali.kra.award.paymentreports.ReportClass;
import org.kuali.kra.award.paymentreports.awardreports.AwardReportsBean;
import org.kuali.kra.award.paymentreports.awardreports.reporting.ReportTracking;
import org.kuali.kra.award.paymentreports.awardreports.reporting.ReportTrackingBean;
import org.kuali.kra.award.paymentreports.awardreports.reporting.service.ReportTrackingService;
import org.kuali.kra.award.paymentreports.closeout.AwardCloseoutBean;
import org.kuali.kra.award.paymentreports.paymentschedule.PaymentScheduleBean;
import org.kuali.kra.award.paymentreports.specialapproval.approvedequipment.ApprovedEquipmentBean;
import org.kuali.kra.award.paymentreports.specialapproval.foreigntravel.ApprovedForeignTravelBean;
import org.kuali.kra.award.permissions.PermissionsHelper;
import org.kuali.kra.award.printing.AwardPrintNotice;
import org.kuali.kra.award.printing.AwardTransactionSelectorBean;
import org.kuali.kra.award.service.AwardHierarchyUIService;
import org.kuali.kra.award.specialreview.SpecialReviewHelper;
import org.kuali.kra.award.web.struts.action.SponsorTermFormHelper;
import org.kuali.kra.external.award.web.AccountCreationPresentationHelper;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.rice.core.api.CoreApiServiceLocator;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.util.ConcreteKeyValue;
import org.kuali.rice.coreservice.framework.parameter.ParameterConstants;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.kew.api.KewApiConstants;
import org.kuali.rice.kew.api.WorkflowDocument;
import org.kuali.rice.kew.api.exception.WorkflowException;
import org.kuali.rice.kns.datadictionary.HeaderNavigation;
import org.kuali.rice.kns.util.ActionFormUtilMap;
import org.kuali.rice.kns.web.ui.ExtraButton;
import org.kuali.rice.kns.web.ui.HeaderField;
import org.kuali.rice.krad.util.KRADConstants;

import edu.mit.kc.award.contacts.AwardPersonRemove;
import edu.mit.kc.bo.SharedDocumentType;

/**
 * 
 * This class represents the Award Form Struts class.
 */
public class SharedDocForm extends AwardForm implements MultiLookupForm,Auditable,PermissionsForm {

    public static final String SAVE = "save";
    public static final String RELOAD = "reload";
    private static final String CUSTOM_DATA_NAV_TO = "customData";


    private static final int NUMBER_30 = 30;
    public static final String COLUMN = ":";
    public static final String UPDATE_TIMESTAMP_DD_NAME = "DataDictionary.Award.attributes.updateTimestamp";
    public static final String SPONSOR_DD_NAME = "DataDictionary.Sponsor.attributes.sponsorName";
    private static final Log LOG = LogFactory.getLog(AwardForm.class);
    private final String AWARD_HIERARCHY_TEMP_OBJ_PARAM_NAME_PREFIX = "awardHierarchyTempObject[";
    private final int AWARD_HIERARCHY_TEMP_OBJ_PARAM_NAME_PREFIX_LENGTH = AWARD_HIERARCHY_TEMP_OBJ_PARAM_NAME_PREFIX.length();
    
    private static final long serialVersionUID = -7633960906991275328L;
    
    private static final String PAYMENT_SCHEDULE_ACTIVE_LINKS_PARAMETER = "AwardPaymentScheduleActiveLinks";
    private static Boolean displayAwardPaymentScheduleActiveLinkFields;
    
    private String lookupResultsBOClassName;
    private String lookupResultsSequenceNumber;
    
    private String prevAwardNumber;
    private String prevRootAwardNumber;

    private AwardComment newAwardCostShareComment;
    
    private AwardFandaRate newAwardFandaRate;    
    private List<ConcreteKeyValue> reportClasses;
    private String directIndirectViewEnabled;
    
    private ApprovedEquipmentBean approvedEquipmentBean;
    private AwardProjectPersonnelBean projectPersonnelBean;
    private AwardUnitContactsBean unitContactsBean;
    private AwardCentralAdminContactsBean centralAdminContactsBean;
    private AwardSponsorContactsBean sponsorContactsBean;
    private CostShareFormHelper costShareFormHelper;
    private SponsorTermFormHelper sponsorTermFormHelper;
    private ApprovedSubawardFormHelper approvedSubawardFormHelper;
    private DetailsAndDatesFormHelper detailsAndDatesFormHelper;
    private AwardCloseoutBean awardCloseoutBean;
    
    private ReportClass reportClassForPaymentsAndInvoices;
    private PaymentScheduleBean paymentScheduleBean;
    private ApprovedForeignTravelBean approvedForeignTravelBean;
    private AwardReportsBean awardReportsBean;
    private AwardCommentBean awardCommentBean;
    private AwardNotepadBean awardNotepadBean;
    private AwardAttachmentFormBean awardAttachmentFormBean;
    private MedusaBean medusaBean;
    private AwardBudgetLimitsBean awardBudgetLimitsBean;
    
    private boolean auditActivated;
    private PermissionsHelper permissionsHelper;
    private SpecialReviewHelper specialReviewHelper;
    private NotificationHelper<AwardNotificationContext> notificationHelper;
    private AwardCreditSplitBean awardCreditSplitBean;
    private Map<String, AwardHierarchy> awardHierarchyNodes;
    private String awardNumberInputTemp;//This is temporary till the GUI mock is ready for award hierarchy
    private AwardFundingProposalBean fundingProposalBean;
    private String awardHierarchy;
    private String awardNumber;
    private String addRA;    
    private String deletedRas;
    private String rootAwardNumber;
    private boolean validPrompt;
    private boolean statusHold;
    
    private boolean awardProjectDocView;
    private boolean ipProjectDocView;
    private boolean propProjectDocView;
    private boolean subAwardProjectDocView;
    
    private boolean awardProjectSharedDocView;
    private boolean ipProjectSharedDocView;
    private boolean propProjectSharedDocView;
    private boolean subAwardProjectSharedDocView;

    private AwardHierarchyBean awardHierarchyBean;
    private AwardPrintNotice awardPrintNotice;
    private AwardTransactionSelectorBean awardPrintChangeReport;
    private AwardTransactionSelectorBean awardTimeAndMoneyTransactionReport;
    private List<AwardComment> awardCommentHistoryByType;
    
    private Map< AwardTemplateSyncScope, Boolean > syncRequiresConfirmationMap;
    private AwardTemplateSyncScope[] currentSyncScopes;
    private String currentSyncQuestionId;
    //KCAWD-494:  Added to track a template code lookup.
    private Integer oldTemplateCode;
    private boolean templateLookup = false;
    
    private String newProposalBudgetPeriods; 
    
    private String currentAwardNumber;
    private String currentSeqNumber;
    
    private List<ReportTracking> reportTrackingsToDelete = new ArrayList<ReportTracking>();
    
    private boolean viewFundingSource;

    private boolean syncMode;
    private AwardSyncBean awardSyncBean;
    
    private Long placeHolderAwardId;
    private boolean docOpenedFromAwardSearch;
    private BudgetLimitSummaryHelper budgetLimitSummary;

    private transient ParameterService parameterService;
    private transient AwardHierarchyUIService awardHierarchyUIService;
    private transient ReportTrackingService reportTrackingService;
    
    private List<ReportTrackingBean> reportTrackingBeans;
    private List<SharedDocumentType> sharedDocType;
    public  Collection<AwardPersonRemove> awardPersonRemovalHistory = new ArrayList<AwardPersonRemove>();
    private AccountCreationPresentationHelper accountCreationHelper;
    private boolean kpMaintenanceRole = false;
    private boolean pi = false;
    
	public boolean isPi() {
		return pi;
	}

	public void setPi(boolean pi) {
		this.pi = pi;
	}

	private boolean alertMessage = false;   
    
 private String tabHeader;
    
 private String navigateFlag;
 
 public String getNavigateFlag() {
	return navigateFlag;
}

public void setNavigateFlag(String navigateFlag) {
	this.navigateFlag = navigateFlag;
}
    public String getTabHeader() {
		return tabHeader;
	}

	public void setTabHeader(String tabHeader) {
		this.tabHeader = tabHeader;
	}

    public boolean isAlertMessage() {
		return alertMessage;
	}

	public void setAlertMessage(boolean alertMessage) {
	  this.alertMessage = alertMessage;
	}

	public boolean isKpMaintenanceRole() {
		return kpMaintenanceRole;
	}

	public void setKpMaintenanceRole(boolean kpMaintenanceRole) {
		this.kpMaintenanceRole = kpMaintenanceRole;
	}

	public  Collection<AwardPersonRemove> getAwardPersonRemovalHistory() {
		return awardPersonRemovalHistory;
	}

	public  void setAwardPersonRemovalHistory(Collection<AwardPersonRemove> awardPersonRemovalHistory) {
		this.awardPersonRemovalHistory = awardPersonRemovalHistory;
	}

    
    
    /**
     * Constructs a AwardForm with an existing AwardDocument. Used primarily by tests outside of Struts
     * @param document
     */
    public SharedDocForm() {
        super();
        initialize();
    }
    
    @Override
    protected String getDefaultDocumentTypeName() {
        return "AwardDocument";
    }
    
    /**
     * 
     * This method initialize all form variables
     */
	public void initialize() {
		newAwardFandaRate = new AwardFandaRate();
		awardCommentHistoryByType = new ArrayList<AwardComment>();
		centralAdminContactsBean = new AwardCentralAdminContactsBean(this);
		projectPersonnelBean = new AwardProjectPersonnelBean(this);
		unitContactsBean = new AwardUnitContactsBean(this);
		sponsorContactsBean = new AwardSponsorContactsBean(this);
		detailsAndDatesFormHelper = new DetailsAndDatesFormHelper(this);
		awardReportsBean = new AwardReportsBean(this);
		setPermissionsHelper(new PermissionsHelper(this));
		awardCreditSplitBean = new AwardCreditSplitBean(this);
		awardCommentBean = new AwardCommentBean(this);
		awardHierarchyNodes = new TreeMap<String, AwardHierarchy>();
		awardPrintNotice = new AwardPrintNotice();
		awardPrintChangeReport = new AwardTransactionSelectorBean();
		buildReportTrackingBeans();
		awardHierarchyBean = new AwardHierarchyBean(this);
		medusaBean = new MedusaBean();
		syncRequiresConfirmationMap = null;
		currentSyncScopes = null;
		syncMode = false;
		awardSyncBean = new AwardSyncBean(this);
		setDirectIndirectViewEnabled(getParameterService().getParameterValueAsString(Constants.PARAMETER_MODULE_AWARD,ParameterConstants.DOCUMENT_COMPONENT,"ENABLE_AWD_ANT_OBL_DIRECT_INDIRECT_COST"));
		budgetLimitSummary = new BudgetLimitSummaryHelper();
		accountCreationHelper = new AccountCreationPresentationHelper();
	}
    
    public void buildReportTrackingBeans() {
        reportTrackingBeans = new ArrayList<ReportTrackingBean>();
        int numberOfReportItems = this.getAwardDocument().getAward().getAwardReportTermItems().size();
        for (int i=0; i<numberOfReportItems; i++) {
            reportTrackingBeans.add(new ReportTrackingBean());
        }
    }

    /**
     * 
     * This method returns the AwardDocument object.
     * @return
     */
    public AwardDocument getAwardDocument() {
        return (AwardDocument) super.getDocument();
    }
    

    public ApprovedEquipmentBean getApprovedEquipmentBean() {
        return approvedEquipmentBean;
    }
    

    public ApprovedForeignTravelBean getApprovedForeignTravelBean() {
        return approvedForeignTravelBean;
    }
    

    public AwardCentralAdminContactsBean getCentralAdminContactsBean() {
        return centralAdminContactsBean;
    }
    

    public CostShareFormHelper getCostShareFormHelper() {
        return costShareFormHelper;
    }
    

    public AwardCommentBean getAwardCommentBean() {
        return awardCommentBean;
    }
   
    /**
     * 
     * This method initializes either the document or the form based on the command value.
     */
    public void initializeFormOrDocumentBasedOnCommand(){
        if (KewApiConstants.INITIATE_COMMAND.equals(getCommand())) {
            getAwardDocument().initialize();
        }else{
            initialize();
        }
    }
    public AwardComment getNewAwardCostShareComment() {
        return newAwardCostShareComment;
    }

    public void setNewAwardCostShareComment(AwardComment newAwardCostShareComment) {
        this.newAwardCostShareComment = newAwardCostShareComment;
    }


    public AwardFandaRate getNewAwardFandaRate() {
        return newAwardFandaRate;
    }

    /**
     *
     * @param newAwardFandaRate
     */
    public void setNewAwardFandaRate(AwardFandaRate newAwardFandaRate) {
        this.newAwardFandaRate = newAwardFandaRate;
    }
    
    @Override
    protected void setSaveDocumentControl(Map editMode) {
        getDocumentActions().put(KRADConstants.KUALI_ACTION_CAN_SAVE, KRADConstants.KUALI_DEFAULT_TRUE_VALUE);
    }
    
    @Override
    protected String getLockRegion() {
        return KraAuthorizationConstants.LOCK_DESCRIPTOR_AWARD;
    }

    /**
     * Gets the lookupResultsBOClassName attribute. 
     * @return Returns the lookupResultsBOClassName.
     */
    @Override
    public String getLookupResultsBOClassName() {
        return lookupResultsBOClassName;
    }

    /**
     * Sets the lookupResultsBOClassName attribute value.
     * @param lookupResultsBOClassName The lookupResultsBOClassName to set.
     */
    @Override
    public void setLookupResultsBOClassName(String lookupResultsBOClassName) {
        this.lookupResultsBOClassName = lookupResultsBOClassName;
    }

    /**
     * Gets the lookupResultsSequenceNumber attribute. 
     * @return Returns the lookupResultsSequenceNumber.
     */
    @Override
    public String getLookupResultsSequenceNumber() {
        return lookupResultsSequenceNumber;
    }

    /**
     * Sets the lookupResultsSequenceNumber attribute value.
     * @param lookupResultsSequenceNumber The lookupResultsSequenceNumber to set.
     */
    @Override
    public void setLookupResultsSequenceNumber(String lookupResultsSequenceNumber) {
        this.lookupResultsSequenceNumber = lookupResultsSequenceNumber;
    }

    /**
     * Gets the awardCommentHistoryByType attribute. 
     * @return Returns the awardCommentHistoryByType.
     */
    public List<AwardComment> getAwardCommentHistoryByType() {
        return awardCommentHistoryByType;
    }

    /**
     * Sets the awardCommentHistoryByType attribute value.
     * @param awardCommentHistoryByType The awardCommentHistoryByType to set.
     */
    public void setAwardCommentHistoryByType(List<AwardComment> awardCommentHistoryByType) {
        this.awardCommentHistoryByType = awardCommentHistoryByType;
    }

    /**
     * @return The selected lead unit
     */
    public String getSelectedLeadUnit() {
        return projectPersonnelBean.getSelectedLeadUnit();
    }
    
    public AwardSponsorContactsBean getSponsorContactsBean() {
        return sponsorContactsBean;
    }
    
    public AccountCreationPresentationHelper getAccountCreationHelper() {
        return accountCreationHelper;
    }

    public AwardUnitContactsBean getUnitContactsBean() {
    	if(unitContactsBean.getNewAwardContact().getContact() != null)    	
        	unitContactsBean.getUnitContact().setFullName(unitContactsBean.getNewAwardContact().getContact().getFullName());
        return unitContactsBean;
    }
    
    public AwardProjectPersonnelBean getProjectPersonnelBean() {
        return projectPersonnelBean;
    }
        
    public List<ConcreteKeyValue> getReportClasses() {
        if (reportClasses != null) {         
            Collections.sort(reportClasses);
        }
        
        return reportClasses;
    }

    public void setReportClasses(List<ConcreteKeyValue> reportClasses) {
        this.reportClasses = reportClasses;
    }

    /**
     * Gets the approvedSubawardFormHelper attribute. 
     * @return Returns the approvedSubawardFormHelper.
     */
    public ApprovedSubawardFormHelper getApprovedSubawardFormHelper() {
        return approvedSubawardFormHelper;
    }

    /**
     * Sets the approvedSubawardFormHelper attribute value.
     * @param approvedSubawardFormHelper The approvedSubawardFormHelper to set.
     */
    public void setApprovedSubawardFormHelper(ApprovedSubawardFormHelper approvedSubawardFormHelper) {
        this.approvedSubawardFormHelper = approvedSubawardFormHelper;
    }
    
     public ReportClass getReportClassForPaymentsAndInvoices() {
        return reportClassForPaymentsAndInvoices;
    }



    public void setReportClassForPaymentsAndInvoices(ReportClass reportClassForPaymentsAndInvoices) {
        this.reportClassForPaymentsAndInvoices = reportClassForPaymentsAndInvoices;
    }    


    /**
     * Gets the sponsorTermFormHelper attribute. 
     * @return Returns the sponsorTermFormHelper.
     */
    public SponsorTermFormHelper getSponsorTermFormHelper() {
        return sponsorTermFormHelper;
    }



    /**
     * @param unitName
     */
    public void setSelectedLeadUnit(String unitName) {
        projectPersonnelBean.setSelectedLeadUnit(unitName);
    }
    
    /**
     * Sets the sponsorTermFormHelper attribute value.
     * @param sponsorTermFormHelper The sponsorTermFormHelper to set.
     */
    public void setSponsorTermFormHelper(SponsorTermFormHelper sponsorTermFormHelper) {
        this.sponsorTermFormHelper = sponsorTermFormHelper;
    }

    /**
     * Gets the paymentScheduleBean attribute. 
     * @return Returns the paymentScheduleBean.
     */
    public PaymentScheduleBean getPaymentScheduleBean() {
        return paymentScheduleBean;
    }

    /**
     * Sets the paymentScheduleBean attribute value.
     * @param paymentScheduleBean The paymentScheduleBean to set.
     */
    public void setPaymentScheduleBean(PaymentScheduleBean paymentScheduleBean) {
        this.paymentScheduleBean = paymentScheduleBean;
    }
    
    @Override
    public boolean isAuditActivated() {
        return this.auditActivated;
    }

    @Override
    public void setAuditActivated(boolean auditActivated) {
        this.auditActivated = auditActivated;
    }
    
    

    /**
     * Gets the awardInMultipleNodeHierarchy attribute. 
     * @return Returns the awardInMultipleNodeHierarchy.
     */
    public boolean isAwardInMultipleNodeHierarchy() {
        return getAwardDocument().getAward().isAwardInMultipleNodeHierarchy();
    }
    
    /**
     * Gets the awardInMultipleNodeHierarchy attribute. 
     * @return Returns the awardInMultipleNodeHierarchy.
     */
    public boolean isAwardHasAssociatedTandMOrIsVersioned() {
        return getAwardDocument().getAward().isAwardHasAssociatedTandMOrIsVersioned();
    }

    /**
     * Gets the indexOfAwardAmountInfoWithHighestTransactionId attribute. 
     * @return Returns the indexOfAwardAmountInfoWithHighestTransactionId.
     * @throws WorkflowException 
     */
    public int getIndexOfAwardAmountInfoForDisplay() throws WorkflowException {
        return getAwardDocument().getAward().getIndexOfAwardAmountInfoForDisplay();
    }

    public DetailsAndDatesFormHelper getDetailsAndDatesFormHelper() {
        return detailsAndDatesFormHelper;
    }

    public void setDetailsAndDatesFormHelper(DetailsAndDatesFormHelper detailsAndDatesFormHelper) {
        this.detailsAndDatesFormHelper = detailsAndDatesFormHelper;
    }
    
    /**
     * Gets the Special Review Helper.
     * @return the Special Review Helper
     */
    public SpecialReviewHelper getSpecialReviewHelper() {
        return specialReviewHelper;
    }
    
    /**
     * Sets the Special Review Helper.
     * @param specialReviewHelper the Special Review Helper
     */
    public void setSpecialReviewHelper(SpecialReviewHelper specialReviewHelper) {
        this.specialReviewHelper = specialReviewHelper;
    }
    
    /**
     * Gets the Notification Helper.
     * @return the Notification Helper
     */
    public NotificationHelper<AwardNotificationContext> getNotificationHelper() {
        return notificationHelper;
    }
    
    /**
     * Sets the Notification Helper.
     * @param notificationHelper the Notification Helper
     */
    public void setNotificationHelper(NotificationHelper<AwardNotificationContext> notificationHelper) {
        this.notificationHelper = notificationHelper;
    }

    /**
     * Gets the permissionsHelper attribute. 
     * @return Returns the awardPermissionsHelper.
     */
    public PermissionsHelper getPermissionsHelper() {
        return permissionsHelper;
    }

    /**
     * Sets the awardPermissionsHelper attribute value.
     * @param permissionsHelper The permissionsHelper to set.
     */
    public void setPermissionsHelper(PermissionsHelper awardPermissionsHelper) {
        this.permissionsHelper = awardPermissionsHelper;
    }
    
    /**
     * This method returns a string representation of the document type
     * @return
     */
    public String getDocumentTypeName() {
        return "AwardDocument";
    }
    
    @Override
    public String getActionName() {
        return "award";
    }
    
    /**
     * Sets the awardAuditActivated attribute value.
     * @param awardAuditActivated The awardAuditActivated to set.
     */
    public void setAwardAuditActivated(boolean awardAuditActivated) {
        this.auditActivated = awardAuditActivated;
    }


    public AwardCreditSplitBean getAwardCreditSplitBean() {
        return awardCreditSplitBean;
    }

    /**
     * @param awardCreditSplitBean
     */
    public void setAwardCreditSplitBean(AwardCreditSplitBean awardCreditSplitBean) {
        this.awardCreditSplitBean = awardCreditSplitBean;
    }
    
    /**
     * @param projectPersonnelBean
     */
    public void setAwardProjectPersonnelBean(AwardProjectPersonnelBean projectPersonnelBean) {
        this.projectPersonnelBean = projectPersonnelBean;
    }
    
    /**
     * Gets the awardReportsBean attribute. 
     * @return Returns the awardReportsBean.
     */
    public AwardReportsBean getAwardReportsBean() {
        return awardReportsBean;
    }

    /**
     * Sets the awardReportsBean attribute value.
     * @param awardReportsBean The awardReportsBean to set.
     */
    public void setAwardReportsBean(AwardReportsBean awardReportsBean) {
        this.awardReportsBean = awardReportsBean;
    }

    /**
     * Gets the awardCloseoutBean attribute. 
     * @return Returns the awardCloseoutBean.
     */
    public AwardCloseoutBean getAwardCloseoutBean() {
        return awardCloseoutBean;
    }

    /**
     * Sets the awardCloseoutBean attribute value.
     * @param awardCloseoutBean The awardCloseoutBean to set.
     */
    public void setAwardCloseoutBean(AwardCloseoutBean awardCloseoutBean) {
        this.awardCloseoutBean = awardCloseoutBean;
    }
    
    
    
    /**
     * Gets the awardNotepadBean attribute. 
     * @return Returns the awardNotepadBean.
     */
    public AwardNotepadBean getAwardNotepadBean() {
        return awardNotepadBean;
    }

    /**
     * Sets the awardNotepadBean attribute value.
     * @param awardNotepadBean The awardNotepadBean to set.
     */
    public void setAwardNotepadBean(AwardNotepadBean awardNotepadBean) {
        this.awardNotepadBean = awardNotepadBean;
    }
    


    /**
     * Gets the awardAttachmentFormBean attribute. 
     * @return Returns the awardAttachmentFormBean.
     */
    public AwardAttachmentFormBean getAwardAttachmentFormBean() {
        return awardAttachmentFormBean;
    }

    /**
     * Sets the awardAttachmentFormBean attribute value.
     * @param awardAttachmentFormBean The awardAttachmentFormBean to set.
     */
    public void setAwardAttachmentFormBean(AwardAttachmentFormBean awardAttachmentFormBean) {
        this.awardAttachmentFormBean = awardAttachmentFormBean;
    }


    public AwardFundingProposalBean getFundingProposalBean() {
        return fundingProposalBean;
    }
    
    /**
     * Gets the awardHierarchyNodes attribute. 
     * @return Returns the awardHierarchyNodes.
     */
    public Map<String, AwardHierarchy> getAwardHierarchyNodes() {
        if(awardHierarchyNodes == null || awardHierarchyNodes.size()==0){
            awardHierarchyNodes = getAwardHierarchyBean().getAwardHierarchy(getAwardHierarchyBean().getRootNode(), new ArrayList<String>());
        }
        return awardHierarchyNodes;
    }

    /**
     * Sets the awardHierarchyNodes attribute value.
     * @param awardHierarchyNodes The awardHierarchyNodes to set.
     */
    public void setAwardHierarchyNodes(Map<String, AwardHierarchy> awardHierarchyNodes) {
        this.awardHierarchyNodes = awardHierarchyNodes;
    }

    /**
     * Gets the prevAwardNumber attribute. 
     * @return Returns the prevAwardNumber.
     */
    public String getPrevAwardNumber() {
        return prevAwardNumber;
    }

    /**
     * Sets the prevAwardNumber attribute value.
     * @param prevAwardNumber The prevAwardNumber to set.
     */
    public void setPrevAwardNumber(String prevAwardNumber) {
        this.prevAwardNumber = prevAwardNumber;
    }

    /**
     * Gets the prevRootAwardNumber attribute. 
     * @return Returns the prevRootAwardNumber.
     */
    public String getPrevRootAwardNumber() {
        return prevRootAwardNumber;
    }

    /**
     * Sets the prevRootAwardNumber attribute value.
     * @param prevRootAwardNumber The prevRootAwardNumber to set.
     */
    public void setPrevRootAwardNumber(String prevRootAwardNumber) {
        this.prevRootAwardNumber = prevRootAwardNumber;
    }

    /**
     * Gets the awardNumberInputTemp attribute. 
     * @return Returns the awardNumberInputTemp.
     */
    public String getAwardNumberInputTemp() {
        return awardNumberInputTemp;
    }

    /**
     * Sets the awardNumberInputTemp attribute value.
     * @param awardNumberInputTemp The awardNumberInputTemp to set.
     */
    public void setAwardNumberInputTemp(String awardNumberInputTemp) {
        this.awardNumberInputTemp = awardNumberInputTemp;
    }
    
    public AwardHierarchyBean getAwardHierarchyBean() {
        return awardHierarchyBean;
    }


    public String getAwardHierarchy() throws ParseException {
        awardHierarchy = "";
        if(StringUtils.isBlank(awardNumber)){ 
            awardNumber = this.getRootAwardNumber();
        }
        
        if (awardNumber!=null && StringUtils.isNotBlank(addRA) && addRA.equals("E")){
            setAwardHierarchy(getAwardHierarchyUIService().getSubAwardHierarchiesForTreeView(awardNumber, currentAwardNumber, currentSeqNumber));
        } else if (awardNumber!=null && StringUtils.isNotBlank(addRA) && addRA.equals("N")){
            setAwardHierarchy(getAwardHierarchyUIService().getRootAwardNode(awardNumber, currentAwardNumber, currentSeqNumber));  
        }
        
        return awardHierarchy;
    }
    
    public void setAwardHierarchy(String awardHierarchy) {
        this.awardHierarchy = awardHierarchy;
    }

    /**
     * Gets the awardNumber attribute. 
     * @return Returns the awardNumber.
     */
    public String getAwardNumber() {
        return awardNumber;
    }

    /**
     * Sets the awardNumber attribute value.
     * @param awardNumber The awardNumber to set.
     */
    public void setAwardNumber(String awardNumber) {
        this.awardNumber = awardNumber;
    }

    /**
     * Gets the addRA attribute. 
     * @return Returns the addRA.
     */
    public String getAddRA() {
        return addRA;
    }

    /**
     * Sets the addRA attribute value.
     * @param addRA The addRA to set.
     */
    public void setAddRA(String addRA) {
        this.addRA = addRA;
    }

    /**
     * Gets the deletedRas attribute. 
     * @return Returns the deletedRas.
     */
    public String getDeletedRas() {
        return deletedRas;
    }

    /**
     * Sets the deletedRas attribute value.
     * @param deletedRas The deletedRas to set.
     */
    public void setDeletedRas(String deletedRas) {
        this.deletedRas = deletedRas;
    }

    private AwardHierarchyUIService getAwardHierarchyUIService() {
        if (awardHierarchyUIService == null) {
            awardHierarchyUIService = KcServiceLocator.getService(AwardHierarchyUIService.class);
        }
        return awardHierarchyUIService;
    }
    
    private ReportTrackingService getReportTrackingService() {
        if (reportTrackingService == null) {
            reportTrackingService = KcServiceLocator.getService(ReportTrackingService.class);
        }
        return reportTrackingService;
    }
    
    /**
     * 
     * This method calls ReportTrackingService.autoRegenerateReports if that is true, this returns false.
     * @return
     */
    public boolean getDisplayRegenerateButton() {
        return !this.getReportTrackingService().autoRegenerateReports(this.getAwardDocument().getAward());
    }

    /**
     * Gets the rootAwardNumber attribute. 
     * @return Returns the rootAwardNumber.
     */
    public String getRootAwardNumber() {
        return rootAwardNumber;
    }

    /**
     * Sets the rootAwardNumber attribute value.
     * @param rootAwardNumber The rootAwardNumber to set.
     */
    public void setRootAwardNumber(String rootAwardNumber) {
        this.rootAwardNumber = rootAwardNumber;
    }

    /**
     * @return the AwardPrintNotice object
     */
    public AwardPrintNotice getAwardPrintNotice() {
        return awardPrintNotice;
    }

    /**
     * Set the AwardPrintNotice object - responsible for passing Award Notice choices for printing.
     * @param awardPrintNotice
     */
    public void setAwardPrintNotice(AwardPrintNotice awardPrintNotice) {
        this.awardPrintNotice = awardPrintNotice;
    }

    public AwardTransactionSelectorBean getAwardPrintChangeReport() {
        return awardPrintChangeReport;
    }

    public void setAwardPrintChangeReport(AwardTransactionSelectorBean awardPrintChangeReport) {
        this.awardPrintChangeReport = awardPrintChangeReport;
    }
    
    /**
     * Gets the hiddenObject attribute.
     * @return Returns the hiddenObject.
     */
    public List<AwardHierarchyTempObject> getAwardHierarchyTempObjects() {
        if(getAwardDocument().getAward().getAwardHierarchyTempObjects() == null) {
            getAwardDocument().getAward().initializeAwardHierarchyTempObjects(); 
        }
        
        return getAwardDocument().getAward().getAwardHierarchyTempObjects();
    }
    
    public AwardHierarchyTempObject getAwardHierarchyTempObject(int index) {
        while(getAwardHierarchyTempObjects().size() <= index) {
            getAwardDocument().getAward().getAwardHierarchyTempObjects().add(new AwardHierarchyTempObject());
        }
        return getAwardDocument().getAward().getAwardHierarchyTempObjects().get(index);
    }
    
    public String getValueFinderResultDoNotCache(){
        if (this.getActionFormUtilMap() instanceof ActionFormUtilMap) {
            ((ActionFormUtilMap) this.getActionFormUtilMap()).setCacheValueFinderResults(false);
        }
        return "";
    }
    
    public String getValueFinderResultCache(){
        if (this.getActionFormUtilMap() instanceof ActionFormUtilMap) {
            ((ActionFormUtilMap) this.getActionFormUtilMap()).setCacheValueFinderResults(true);
        }
        return "";
    }
    
    public List<ExtraButton> getExtraTopButtons() {
        extraButtons.clear();
        String externalImageURL = Constants.KRA_EXTERNALIZABLE_IMAGES_URI_KEY;
        String generatePeriodImage = lookupKualiConfigurationService().getPropertyValueAsString(externalImageURL) + "tinybutton-timemoney.gif";
        
        addExtraButton("methodToCall.timeAndMoney", generatePeriodImage, "Time And Money");
        
        return extraButtons;
    }
    

    private ConfigurationService lookupKualiConfigurationService() {
        return CoreApiServiceLocator.getKualiConfigurationService();
    }
    
    /**
     * This is a utility method to add a new button to the extra buttons
     * collection.
     *   
     * @param property
     * @param source
     * @param altText
     */ 
    protected void addExtraButton(String property, String source, String altText){
        
        ExtraButton newButton = new ExtraButton();
        
        newButton.setExtraButtonProperty(property);
        newButton.setExtraButtonSource(source);
        newButton.setExtraButtonAltText(altText);
        
        extraButtons.add(newButton);
    }

    /**
     * Gets the medusaBean attribute. 
     * @return Returns the medusaBean.
     */
    public MedusaBean getMedusaBean() {
        return medusaBean;
    }

    /**
     * Sets the medusaBean attribute value.
     * @param medusaBean The medusaBean to set.
     */
    public void setMedusaBean(MedusaBean medusaBean) {
        this.medusaBean = medusaBean;
    }
    
    /**
     * This is a hack to fix a problem with Award Hierarchy. The way the AH UI was implemented was in JavaScript. For some reason, the awardHierarchyTempObject
     * form field data doesn't get set on the temp objects by Rice's property setting mechanism. Time is short, so I just do it manually here. jack frosch
     *
     * @param requestParameters
     */
    @Override
    public void postprocessRequestParameters(Map requestParameters) {
        super.postprocessRequestParameters(requestParameters);

        @SuppressWarnings("unchecked") Map<String, Object> parms = requestParameters;
        for(String parmKey: parms.keySet()) {
            if(parmKey.startsWith(AWARD_HIERARCHY_TEMP_OBJ_PARAM_NAME_PREFIX)) {
                populateAwardHierarchyTempObject(parms, parmKey);
            }
        }
    }

    private void populateAwardHierarchyTempObject(Map<String, Object> parms, String parmKey) {
        int indexOfClosingBracket = parmKey.indexOf("]");
        String fieldName = parmKey.substring(indexOfClosingBracket + 2);
        Object fieldValue = parms.get(parmKey);
        int tempObjectIndex = Integer.valueOf(parmKey.substring(AWARD_HIERARCHY_TEMP_OBJ_PARAM_NAME_PREFIX_LENGTH, indexOfClosingBracket));
        AwardHierarchyTempObject tempObject = getAwardHierarchyTempObject(tempObjectIndex);
        populateAwardHierarchyTempObjectFromRequestParms(tempObject, fieldName, fieldValue);
        if(tempObject.getCopyDescendants() == null) {
            tempObject.setCopyDescendants(false);
        }
    }

    private void populateAwardHierarchyTempObjectFromRequestParms(AwardHierarchyTempObject tempObject, String fieldName, Object fieldValue) {
       try {
            BeanUtils.setProperty(tempObject, fieldName, fieldValue);
        } catch(Exception e) {
            String message = String.format("Attempt to set %s property to %s on AwardHierarchyTempObject resulted in exception", fieldName, fieldValue.toString());
            LOG.error(message, e);
            throw new IllegalArgumentException(message, e);
        }
    }


    /**
     * This map is generated in the action and stored in the form as synchronizations to the template can
     * span one or more requests.  Each entry indicates if the user must confirm the synchronization request
     * for a particular scope being synchronized.
     * 
     * @return The current scopes remaining to be synchronized.  The action is responsible for maintaining this field.
     */
    
    public Map<AwardTemplateSyncScope, Boolean> getSyncRequiresConfirmationMap() {
        return syncRequiresConfirmationMap;
    }

    public void setSyncRequiresConfirmationMap(Map<AwardTemplateSyncScope, Boolean> syncRequiresConfirmationMap) {
        this.syncRequiresConfirmationMap = syncRequiresConfirmationMap;
    }
    
    
    public void setCurrentSyncQuestionId( String currentSyncQuestionId ) {
        this.currentSyncQuestionId = currentSyncQuestionId;
    }
    
    public String getCurrentSyncQuestionId() {
        return currentSyncQuestionId;
    }
    
    
    /**
     * The currentSyncScopes array holds the array of scopes that are currently being synchronized 
     * with the award template.  It is set by the form when a sync is initiated by the user.  Since the
     * ui may request confirmations to sync each scope, this is done in a loop spanning one or more requests 
     * by the action, which removes the scopes as the synchronizations are confirmed and performed 
     * or are declined by the user.
     * 
     * @return The current scopes remaining to be synchronized.  The action is responsible for maintaining this field.
     */
    public AwardTemplateSyncScope[] getCurrentSyncScopes() {
        return currentSyncScopes;
    }

    public void setCurrentSyncScopes(AwardTemplateSyncScope[] currentSyncOperations) {
        this.currentSyncScopes = currentSyncOperations;
    }

    /**
     * Returns the value of oldTemplateCode.  This is set by the award action
     * when the user starts a template code lookup.
     * 
     * @return The template code of the award before the template lookup was done.
     */
    public Integer getOldTemplateCode() {
        return oldTemplateCode;
    }

    
    public void setOldTemplateCode(Integer oldTemplateCode) {
        this.oldTemplateCode = oldTemplateCode;
    }

    
    /**
     * Boolean flag to indicate that the user is in a template code lookup loop.
     * Set by the action when a template code lookup is initiated by the user.
     * 
     * @return templateLookup
     */
    public boolean isTemplateLookup() {
        return templateLookup;
    }

    public void setTemplateLookup(boolean templateCodeChange) {
        this.templateLookup = templateCodeChange;
    }
    
    public List<Long> getLinkedProposals() {
        List<Long> linkedProposals = new ArrayList<Long>();
        if (this.getAwardDocument() != null && this.getAwardDocument().getAward() != null) {
            for (AwardFundingProposal fundingProposal : this.getAwardDocument().getAward().getFundingProposals()) {
                linkedProposals.add(fundingProposal.getProposalId());
            }
        }
        return linkedProposals;
    }
    
   
    
    @Override
    public void populateHeaderFields(WorkflowDocument workflowDocument) {
        getDocInfo().clear();
    }

    private String getAwardIdAccount(AwardDocument awardDocument) {
        String awardNum = awardDocument.getAward().getAwardNumber();
        String account = awardDocument.getAward().getAccountNumber() != null ? awardDocument.getAward().getAccountNumber()
                : Constants.EMPTY_STRING;
        return awardNum + COLUMN + account;
    }

    private void setupLastUpdate(AwardDocument awardDocument) {
        String createDateStr = null;
        String updateUser = null;
        if (awardDocument.getUpdateTimestamp() != null) {
            createDateStr = CoreApiServiceLocator.getDateTimeService().toString(awardDocument.getUpdateTimestamp(), "MM/dd/yy hh:mm a");
            updateUser = awardDocument.getUpdateUser().length() > NUMBER_30 ? awardDocument.getUpdateUser().substring(0, NUMBER_30)
                    : awardDocument.getUpdateUser();
            getDocInfo().add(
                    new HeaderField(UPDATE_TIMESTAMP_DD_NAME, createDateStr + " by " + updateUser));
        } else {
            getDocInfo().add(new HeaderField(UPDATE_TIMESTAMP_DD_NAME, Constants.EMPTY_STRING));
        }

    }


    private void setupSponsor(AwardDocument awardDocument) {
        if (awardDocument.getAward().getSponsor() == null) {
            getDocInfo().add(new HeaderField(SPONSOR_DD_NAME, ""));
        } else {
            String sponsorName = awardDocument.getAward().getSponsorName();
            if (StringUtils.isNotBlank(sponsorName) && sponsorName.length() > NUMBER_30) {
                sponsorName = sponsorName.substring(0, NUMBER_30);
            }
            getDocInfo().add(new HeaderField(SPONSOR_DD_NAME, sponsorName));
        }

    }

    /**
     * Gets the newProposalBudgetPeriods attribute. 
     * @return Returns the newProposalBudgetPeriods.
     */
    public String getNewProposalBudgetPeriods() {
        return newProposalBudgetPeriods;
    }

    /**
     * Sets the newProposalBudgetPeriods attribute value.
     * @param newProposalBudgetPeriods The newProposalBudgetPeriods to set.
     */
    public void setNewProposalBudgetPeriods(String newProposalBudgetPeriods) {
        this.newProposalBudgetPeriods = newProposalBudgetPeriods;
    }
    
    public boolean getDisplayEditButton() {
        boolean displayEditButton = !isViewOnly() && !getAwardDocument().isCanceled();
        if (isDocOpenedFromAwardSearch() || getAwardDocument().isPlaceHolderDocument()) {
            displayEditButton = true;
        }
        
        VersionHistory activeVersion = getVersionHistoryService().findActiveVersion(Award.class, getAwardDocument().getAward().getAwardNumber());
        if (activeVersion != null) {
            displayEditButton &= activeVersion.getSequenceOwnerSequenceNumber().equals(getAwardDocument().getAward().getSequenceNumber());
        }
        
        return displayEditButton;
    }
    
    protected VersionHistoryService getVersionHistoryService() {
        return KcServiceLocator.getService(VersionHistoryService.class);
    }

    public String getCurrentAwardNumber() {
        return currentAwardNumber;
    }

    public void setCurrentAwardNumber(String currentAwardNumber) {
        this.currentAwardNumber = currentAwardNumber;
    }

    public String getCurrentSeqNumber() {
        return currentSeqNumber;
    }

    public void setCurrentSeqNumber(String currentSeqNumber) {
        this.currentSeqNumber = currentSeqNumber;
    }
    

    
    public String getCanCreateAward() {
        Boolean aFlag = this.getEditingMode().containsKey(Constants.CAN_CREATE_AWARD_KEY);
        return aFlag.toString();
    }
    
    public boolean getViewFundingSource() {
        return viewFundingSource;
    }
    
    public void setViewFundingSource(boolean viewFundingSource) {
        this.viewFundingSource = viewFundingSource;
    }

    public void setAwardTimeAndMoneyTransactionReport(AwardTransactionSelectorBean awardTimeAndMoneyTransactionReport) {
        this.awardTimeAndMoneyTransactionReport = awardTimeAndMoneyTransactionReport;
    }

    public AwardTransactionSelectorBean getAwardTimeAndMoneyTransactionReport() {
        return awardTimeAndMoneyTransactionReport;
    }
    
    /**
     * Looks up and returns the ParameterService.
     * @return the parameter service. 
     */
    protected ParameterService getParameterService() {
        if (this.parameterService == null) {
            this.parameterService = KcServiceLocator.getService(ParameterService.class);
        }
        return this.parameterService;
    }
    
    /**
     * Gets the directIndirectViewEnabled attribute. 
     * @return Returns the directIndirectViewEnabled.
     */
    public String getDirectIndirectViewEnabled() {
        return directIndirectViewEnabled;
    }

    public boolean isSyncMode() {
        return syncMode;
    }

    public void setSyncMode(boolean syncMode) {
        this.syncMode = syncMode;
    }

    public AwardSyncBean getAwardSyncBean() {
        return awardSyncBean;
    }

    public void setAwardSyncBean(AwardSyncBean awardSyncBean) {
        this.awardSyncBean = awardSyncBean;
    }     
    
    /**
     * Sets the directIndirectViewEnabled attribute value.
     * @param directIndirectViewEnabled The directIndirectViewEnabled to set.
     */
    public void setDirectIndirectViewEnabled(String directIndirectViewEnabled) {
        this.directIndirectViewEnabled = directIndirectViewEnabled;
    }
    
    @Override
    public HeaderNavigation[] getHeaderNavigationTabs() {

    	HeaderNavigation keyPersontab = new HeaderNavigation();
    	HeaderNavigation sharedDocTab = new HeaderNavigation();
    	keyPersontab.setHeaderTabNavigateTo("keyPerson");
    	keyPersontab.setHeaderTabDisplayName("Key Person Maintenance");
    	keyPersontab.setDisabled(false);
    	sharedDocTab.setHeaderTabNavigateTo("sharedDoc");
    	sharedDocTab.setHeaderTabDisplayName("Shared Doc Form");
    	sharedDocTab.setDisabled(false);
    	List<HeaderNavigation> resultList = new ArrayList<HeaderNavigation>();
    	resultList.add(sharedDocTab);
    	resultList.add(keyPersontab);
    	HeaderNavigation[] result = new HeaderNavigation[resultList.size()];
    	resultList.toArray(result);
    	return result;
    }
    
    public List<ExtraButton> getExtraActionsButtons() {
        extraButtons.clear();
        
        String externalImageURL = Constants.KRA_EXTERNALIZABLE_IMAGES_URI_KEY;
        ConfigurationService configurationService = CoreApiServiceLocator.getKualiConfigurationService();
        
        String sendNotificationImage = configurationService.getPropertyValueAsString(externalImageURL) + "buttonsmall_send_notification.gif";
        addExtraButton("methodToCall.sendNotification", sendNotificationImage, "Send Notification");
        
        return extraButtons;
    }

    public Long getPlaceHolderAwardId() {
        return placeHolderAwardId;
    }

    public void setPlaceHolderAwardId(Long placeHolderAwardId) {
        this.placeHolderAwardId = placeHolderAwardId;
    }

    public boolean isDocOpenedFromAwardSearch() {
        return docOpenedFromAwardSearch;
    }

    public void setDocOpenedFromAwardSearch(boolean docOpenedFromAwardSearch) {
        this.docOpenedFromAwardSearch = docOpenedFromAwardSearch;
    }

    public BudgetLimitSummaryHelper getBudgetLimitSummary() {
        return budgetLimitSummary;
    }

    public void setBudgetLimitSummary(BudgetLimitSummaryHelper budgetLimitSummary) {
        this.budgetLimitSummary = budgetLimitSummary;
    }

    public AwardBudgetLimitsBean getAwardBudgetLimitsBean() {
        return awardBudgetLimitsBean;
    }

    public void setAwardBudgetLimitsBean(AwardBudgetLimitsBean awardBudgetLimitsBean) {
        this.awardBudgetLimitsBean = awardBudgetLimitsBean;
    }
    
    public void setAwardHierarchyUIService(AwardHierarchyUIService awardHierarchyUIService) {
        this.awardHierarchyUIService = awardHierarchyUIService;
    }

    public List<ReportTracking> getReportTrackingsToDelete() {
        return reportTrackingsToDelete;
    }

    public void setReportTrackingsToDelete(List<ReportTracking> reportTrackingsToDelete) {
        this.reportTrackingsToDelete = reportTrackingsToDelete;
    }
    
    /**
     * 
     * This method returns true if the AwardPaymentScheduleActiveLinks equals "Y" otherwise returns false.
     * @return
     */
    public boolean getDisplayAwardPaymentScheduleActiveLinkFields() {
        if (displayAwardPaymentScheduleActiveLinkFields == null) {
            String parmVal = this.getParameterService().getParameterValueAsString("KC-AWARD", "Document", PAYMENT_SCHEDULE_ACTIVE_LINKS_PARAMETER);
            displayAwardPaymentScheduleActiveLinkFields = StringUtils.equalsIgnoreCase("Y", parmVal);
        }
        return displayAwardPaymentScheduleActiveLinkFields.booleanValue();
    }

    public void setReportTrackingService(ReportTrackingService reportTrackingService) {
        this.reportTrackingService = reportTrackingService;
    }

    public List<ReportTrackingBean> getReportTrackingBeans() {
        return reportTrackingBeans;
    }

    public void setReportTrackingBeans(List<ReportTrackingBean> reportTrackingBeans) {
        this.reportTrackingBeans = reportTrackingBeans;
    }
    
    public String determineRootAwardNumber(AwardForm awardForm) {
        String prevRootAwardNumber = getPrevRootAwardNumber();
        return prevRootAwardNumber != null ? prevRootAwardNumber : getAwardDocument().getAward().getAwardNumber();
    }

    public String determineParentAwardNumber(AwardForm awardForm) {
        String prevAwardNumber = getPrevAwardNumber();
        return prevAwardNumber != null ? prevAwardNumber : Constants.AWARD_HIERARCHY_DEFAULT_PARENT_OF_ROOT;
    }    
 
    // returns list of awards with the same award number and prior to or equal to this one
    public List<Award>getAwardsForHistoryDisplay() {
        List<Award>results = new ArrayList<Award>();
        List<Award>rawList = getAwardDocument().getAward().getAwardVersions();
        int sequenceNumber = getAwardDocument().getAward().getSequenceNumber();
        for (Award award : rawList) {
            if (award.getSequenceNumber() <= sequenceNumber) {
                results.add(award);
            }
        }
        Collections.reverse(results);
        return results;
    }
	public boolean isValidPrompt() {
		return validPrompt;
	}

	public void setValidPrompt(boolean validPrompt) {
		this.validPrompt = validPrompt;
	}

	public boolean isStatusHold() {
		return statusHold;
	}

	public void setStatusHold(boolean statusHold) {
		this.statusHold = statusHold;
	}

	public boolean isAwardProjectDocView() {
		return awardProjectDocView;
	}

	public void setAwardProjectDocView(boolean awardProjectDocView) {
		this.awardProjectDocView = awardProjectDocView;
	}

	public boolean isIpProjectDocView() {
		return ipProjectDocView;
	}

	public void setIpProjectDocView(boolean ipProjectDocView) {
		this.ipProjectDocView = ipProjectDocView;
	}

	public boolean isPropProjectDocView() {
		return propProjectDocView;
	}

	public void setPropProjectDocView(boolean propProjectDocView) {
		this.propProjectDocView = propProjectDocView;
	}

	public boolean isSubAwardProjectDocView() {
		return subAwardProjectDocView;
	}

	public void setSubAwardProjectDocView(boolean subAwardProjectDocView) {
		this.subAwardProjectDocView = subAwardProjectDocView;
	}

	public boolean isAwardProjectSharedDocView() {
		return awardProjectSharedDocView;
	}

	public void setAwardProjectSharedDocView(boolean awardProjectSharedDocView) {
		this.awardProjectSharedDocView = awardProjectSharedDocView;
	}

	public boolean isIpProjectSharedDocView() {
		return ipProjectSharedDocView;
	}

	public void setIpProjectSharedDocView(boolean ipProjectSharedDocView) {
		this.ipProjectSharedDocView = ipProjectSharedDocView;
	}

	public boolean isPropProjectSharedDocView() {
		return propProjectSharedDocView;
	}

	public void setPropProjectSharedDocView(boolean propProjectSharedDocView) {
		this.propProjectSharedDocView = propProjectSharedDocView;
	}

	public boolean isSubAwardProjectSharedDocView() {
		return subAwardProjectSharedDocView;
	}

	public void setSubAwardProjectSharedDocView(boolean subAwardProjectSharedDocView) {
		this.subAwardProjectSharedDocView = subAwardProjectSharedDocView;
	}

	public List<SharedDocumentType> getSharedDocType() {
		return sharedDocType;
	}

	public void setSharedDocType(List<SharedDocumentType> sharedDocType) {
		this.sharedDocType = sharedDocType;
	}

	public String getAwardSharedDocTypes() {
		return getSharedDocumentType(CoeusModule.AWARD_MODULE_CODE);
	}
	
	public String getDevelopmentProposalSharedDocTypes() {
		return getSharedDocumentType(CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE);
	}
	
	public String getInstituteProposalSharedDocTypes() {
		return getSharedDocumentType(CoeusModule.INSTITUTIONAL_PROPOSAL_MODULE_CODE);
	}
	
	public String getSubAwardSharedDocTypes() {
		return getSharedDocumentType(CoeusModule.SUBCONTRACTS_MODULE_CODE);
	}
	
	protected String getSharedDocumentType(String moduleCode) {
		StringBuffer sharedDocumentTypeForModule = new StringBuffer();
		for(SharedDocumentType sharedDocumentType : getSharedDocType()) {
			if(sharedDocumentType.getModuleCode().equalsIgnoreCase(moduleCode)) {
				sharedDocumentTypeForModule.append(sharedDocumentType.getDocumentTypeCode());
				sharedDocumentTypeForModule.append(",");
			}
		}
		return sharedDocumentTypeForModule.toString();
	}
}