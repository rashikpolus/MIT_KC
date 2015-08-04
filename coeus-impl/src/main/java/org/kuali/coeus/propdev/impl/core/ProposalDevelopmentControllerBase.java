/*
 * Kuali Coeus, a comprehensive research administration system for higher education.
 * 
 * Copyright 2005-2015 Kuali, Inc.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.kuali.coeus.propdev.impl.core;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.kuali.coeus.common.framework.compliance.exemption.ExemptionType;
import org.kuali.coeus.common.framework.keyword.ScienceKeyword;
import org.kuali.coeus.common.notification.impl.bo.KcNotification;
import org.kuali.coeus.common.notification.impl.bo.NotificationTypeRecipient;
import org.kuali.coeus.common.notification.impl.service.KcNotificationService;
import org.kuali.coeus.common.framework.person.PropAwardPersonRole;
import org.kuali.coeus.common.questionnaire.framework.answer.Answer;
import org.kuali.coeus.common.questionnaire.framework.answer.AnswerHeader;
import org.kuali.coeus.common.framework.compliance.core.SaveDocumentSpecialReviewEvent;
import org.kuali.coeus.propdev.impl.datavalidation.ProposalDevelopmentDataValidationConstants;
import org.kuali.coeus.propdev.impl.docperm.ProposalRoleTemplateService;
import org.kuali.coeus.propdev.impl.docperm.ProposalUserRoles;
import org.kuali.coeus.propdev.impl.keyword.PropScienceKeyword;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationContext;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationRenderer;
import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.coeus.propdev.impl.person.ProposalPersonCoiIntegrationService;
import org.kuali.coeus.common.framework.auth.perm.KcAuthorizationService;
import org.kuali.coeus.common.impl.SharedDocumentService;
import org.kuali.coeus.propdev.impl.person.attachment.ProposalPersonBiography;
import org.kuali.coeus.propdev.impl.person.attachment.ProposalPersonBiographyService;
import org.kuali.coeus.propdev.impl.specialreview.ProposalSpecialReview;
import org.kuali.coeus.propdev.impl.specialreview.ProposalSpecialReviewExemption;
import org.kuali.coeus.sys.framework.controller.KcCommonControllerService;
import org.kuali.coeus.sys.framework.controller.UifExportControllerService;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.coeus.propdev.impl.attachment.Narrative;
import org.kuali.coeus.propdev.impl.auth.perm.ProposalDevelopmentPermissionsService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.coeus.sys.framework.validation.AuditHelper;
import org.kuali.coeus.sys.impl.validation.DataValidationItem;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.kra.infrastructure.RoleConstants;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.core.api.exception.RiceRuntimeException;
import org.kuali.rice.core.api.util.RiceKeyConstants;
import org.kuali.rice.coreservice.framework.parameter.ParameterConstants;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.document.DocumentBase;
import org.kuali.rice.krad.document.TransactionalDocumentControllerService;
import org.kuali.rice.krad.exception.ValidationException;
import org.kuali.rice.krad.rules.rule.event.DocumentEventBase;
import org.kuali.rice.krad.service.DocumentAdHocService;
import org.kuali.rice.krad.service.DocumentService;
import org.kuali.rice.krad.service.LegacyDataAdapter;
import org.kuali.rice.krad.service.PessimisticLockService;
import org.kuali.rice.krad.uif.UifParameters;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.util.MessageMap;
import org.kuali.rice.krad.web.form.DialogResponse;
import org.kuali.rice.krad.web.form.DocumentFormBase;
import org.kuali.rice.krad.web.form.UifFormBase;
import org.kuali.rice.krad.web.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.propertyeditors.CustomCollectionEditor;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import edu.mit.kc.coi.KcCoiLinkService;
import edu.mit.kc.infrastructure.KcMitConstants;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

public abstract class ProposalDevelopmentControllerBase {

    protected static final String PROPDEV_DEFAULT_VIEW_ID = "PropDev-DefaultView";
    private static final String CONFIRM_MY_COI_DIALOG_ID = "PropDev-Personal-CoiQuestionDialog";

    @Autowired
    @Qualifier("uifExportControllerService")
    private UifExportControllerService uifExportControllerService;

    @Autowired
    @Qualifier("kcCommonControllerService")
    private KcCommonControllerService kcCommonControllerService;

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
    @Qualifier("transactionalDocumentControllerService")
    private TransactionalDocumentControllerService transactionalDocumentControllerService;

    @Autowired
    @Qualifier("documentService")
    private DocumentService documentService;

    @Autowired
    @Qualifier("kcAuthorizationService")
    private KcAuthorizationService kraAuthorizationService;

    @Autowired
    @Qualifier("proposalDevelopmentService")
    private ProposalDevelopmentService proposalDevelopmentService;

    @Autowired
    @Qualifier("proposalDevelopmentPermissionsService")
    private ProposalDevelopmentPermissionsService proposalDevelopmentPermissionsService;

    @Autowired
    @Qualifier("legacyDataAdapter")
    private LegacyDataAdapter legacyDataAdapter;
    
    @Autowired
    @Qualifier("proposalRoleTemplateService")
    private ProposalRoleTemplateService proposalRoleTemplateService;

    @Autowired
    @Qualifier("dataObjectService")
    private DataObjectService dataObjectService;
    
    @Autowired
    @Qualifier("globalVariableService")
    private GlobalVariableService globalVariableService;

    @Autowired
    @Qualifier("proposalPersonBiographyService")
    private ProposalPersonBiographyService proposalPersonBiographyService;

    @Autowired
    @Qualifier("documentAdHocService")
    private DocumentAdHocService documentAdHocService;

    @Autowired
    @Qualifier("auditHelper")
    private AuditHelper auditHelper;

    @Autowired
    @Qualifier("pessimisticLockService")
    private PessimisticLockService pessimisticLockService;

    @Autowired
    @Qualifier("kcNotificationService")
    private KcNotificationService kcNotificationService;

    @Autowired
    @Qualifier("parameterService")
    private ParameterService parameterService;
    
    @Autowired
    @Qualifier("kualiConfigurationService")
    private ConfigurationService kualiConfigurationService;

    
    @Autowired
    @Qualifier("proposalPersonCoiIntegrationService")
    private ProposalPersonCoiIntegrationService proposalPersonCoiIntegrationService;
    
    @Autowired
    @Qualifier("proposalTypeService")
    private ProposalTypeService proposalTypeService;
   
	
	private transient boolean updatedToCoi = false;
  

	protected DocumentFormBase createInitialForm(HttpServletRequest request) {
        return new ProposalDevelopmentDocumentForm();
    }
    
    @ModelAttribute(value = "KualiForm")
    public UifFormBase initForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
        UifFormBase form =  getKcCommonControllerService().initForm(this.createInitialForm(request), request, response);
        return form;
    }
    private final Logger LOGGER = Logger.getLogger(ProposalDevelopmentSubmitController.class);
   
    
    public KcCoiLinkService kcCoiLinkService;
    
	public KcCoiLinkService getKcCoiLinkService() {
		if (kcCoiLinkService == null) {
			kcCoiLinkService = KcServiceLocator.getService(KcCoiLinkService.class);
		}
		
		return kcCoiLinkService;
	}


	public void setKcCoiLinkService(KcCoiLinkService kcCoiLinkService) {
		this.kcCoiLinkService = kcCoiLinkService;
	}
     
    /**
     * Create the original set of Proposal Users for a new Proposal Development Document.
     * The creator the proposal is assigned to the AGGREGATOR role.
     */
     protected void initializeProposalUsers(ProposalDevelopmentDocument doc) {

         // Assign the creator of the proposal to the AGGREGATOR role.
         String userId = GlobalVariables.getUserSession().getPrincipalId();
         if (!kraAuthorizationService.hasDocumentLevelRole(userId, RoleConstants.AGGREGATOR, doc))
             kraAuthorizationService.addDocumentLevelRole(userId, RoleConstants.AGGREGATOR, doc);

         // Add the users defined in the role templates for the proposal's lead unit
         proposalRoleTemplateService.addUsers(doc);
     }

     protected void initialSave(ProposalDevelopmentDocument proposalDevelopmentDocument) {
         preSave(proposalDevelopmentDocument);
         proposalDevelopmentService.initializeUnitOrganizationLocation(
                 proposalDevelopmentDocument);
         proposalDevelopmentService.initializeProposalSiteNumbers(
                 proposalDevelopmentDocument);
     }

     protected void preSave(ProposalDevelopmentDocument proposalDevelopmentDocument) {
         if (proposalDevelopmentDocument.isDefaultDocumentDescription()) {
             proposalDevelopmentDocument.setDefaultDocumentDescription();
         }
     }

     public ModelAndView save(ProposalDevelopmentDocumentForm form, BindingResult result,
             HttpServletRequest request, HttpServletResponse response) throws Exception {
    	 return save(form);
     }
     
     public ModelAndView save(ProposalDevelopmentDocumentForm form) throws Exception {
         ProposalDevelopmentDocument proposalDevelopmentDocument = (ProposalDevelopmentDocument) form.getDocument();

         if (StringUtils.equalsIgnoreCase(form.getPageId(), Constants.PROP_DEV_PERMISSIONS_PAGE)) {
             saveDocumentPermissions(form);
         }
         DialogResponse dialogResponse = form.getDialogResponse(CONFIRM_MY_COI_DIALOG_ID);
         if (StringUtils.equalsIgnoreCase(form.getPageId(), Constants.KEY_PERSONNEL_PAGE) ||
        		 StringUtils.equalsIgnoreCase(form.getPageId(),"PropDev-CertificationView-Page")){
        	 String coiApplicationUrl =  getParameterService().getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "LINK_TO_COI");
        	 String proposalNumber = proposalDevelopmentDocument.getDevelopmentProposal().getProposalNumber();
				StringBuilder proposalPrefix = new StringBuilder();
				for(int count=0;count<=8; count++){
					if(proposalNumber.length()-1 <= count){
						proposalPrefix.append("0");
					}
					count ++;
				}
			form.setCoiUrl(coiApplicationUrl+"&proposalNumber="+proposalPrefix+proposalDevelopmentDocument.getDevelopmentProposal().getProposalNumber());
        	 String pageId = form.getActionParamaterValue(UifParameters.NAVIGATE_TO_PAGE_ID);
             if (StringUtils.isBlank(pageId)){
            	 if(dialogResponse!=null){
            		 boolean confirmResetDefault = dialogResponse.getResponseAsBoolean();
            		 if(confirmResetDefault){
            			 if(coiApplicationUrl!=null){
            				 return getModelAndViewService().getModelAndView(form, pageId);
            			 }
            		 }else{
            			 return getModelAndViewService().getModelAndView(form, pageId);
            		 }
            	 }
             }
         }

        

         if (getGlobalVariableService().getMessageMap().getErrorCount() == 0 && form.getEditableCollectionLines() != null) {
            form.getEditableCollectionLines().clear();
         }
         if (StringUtils.equalsIgnoreCase(form.getPageId(), ProposalDevelopmentDataValidationConstants.DETAILS_PAGE_ID)) {
             handleSponsorChange(proposalDevelopmentDocument);
             if (proposalDevelopmentDocument.getDevelopmentProposal().getS2sOpportunity() != null) {
            	 handleProposalTypeChange(proposalDevelopmentDocument.getDevelopmentProposal());
             }
         }

         preSave(proposalDevelopmentDocument);

         proposalDevelopmentService.initializeUnitOrganizationLocation(proposalDevelopmentDocument);
         proposalDevelopmentService.initializeProposalSiteNumbers(proposalDevelopmentDocument);

         for (ProposalPersonBiography biography : form.getDevelopmentProposal().getPropPersonBios()) {
             getProposalPersonBiographyService().prepareProposalPersonBiographyForSave(form.getDevelopmentProposal(),biography);
         }

         ((ProposalDevelopmentViewHelperServiceImpl)form.getViewHelperService()).setOrdinalPosition(form.getDevelopmentProposal().getProposalPersons());
         saveAnswerHeaders(form, form.getPageId());

         getTransactionalDocumentControllerService().save(form);
         
         if (StringUtils.equalsIgnoreCase(form.getPageId(), ProposalDevelopmentDataValidationConstants.ATTACHMENT_PAGE_ID)) {
             ((ProposalDevelopmentViewHelperServiceImpl)form.getViewHelperService()).populateAttachmentReferences(form.getDevelopmentProposal());
     		 getSharedDocumentService().processDevelopmentProposalAttachments(form.getDevelopmentProposal());
         }
         
         if (form.isAuditActivated()){
             getAuditHelper().auditConditionally(form);
         }


         populateAdHocRecipients(form.getProposalDevelopmentDocument());

         if (StringUtils.equalsIgnoreCase(form.getPageId(), Constants.CREDIT_ALLOCATION_PAGE)) {
             ((ProposalDevelopmentViewHelperServiceImpl)form.getViewHelperService()).populateCreditSplits(form);
         }

         if (StringUtils.equalsIgnoreCase(form.getPageId(), Constants.QUESTIONS_PAGE)) {
             ((ProposalDevelopmentViewHelperServiceImpl)form.getViewHelperService()).populateQuestionnaires(form);
         }
         String pageId = form.getActionParamaterValue(UifParameters.NAVIGATE_TO_PAGE_ID);
         ModelAndView view = null;
         if (StringUtils.isNotBlank(pageId) && getGlobalVariableService().getMessageMap().hasNoErrors()) {
        	 form.setDirtyForm(false);
             view = getModelAndViewService().getModelAndView(form, pageId);
         } else {
             view = getModelAndViewService().getModelAndView(form);
         }

         if (form.getProposalDevelopmentDocument().getDevelopmentProposal() != null
                 && form.getProposalDevelopmentDocument().getDevelopmentProposal().getPropSpecialReviews() != null) {
             for (ProposalSpecialReview specialReview : form.getProposalDevelopmentDocument().getDevelopmentProposal().getPropSpecialReviews()) {
                 if (!specialReview.isLinkedToProtocol()) {
                     form.getSpecialReviewHelper().prepareProtocolLinkViewFields(specialReview);
                 }
             }
         }

         if(StringUtils.isBlank(pageId) && dialogResponse == null && isUpdatedToCoi()){
        	 form.setCoiIntegrationMessage(getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.COI_QUESTION_ANSWERED));
        	 view =  getModelAndViewService().showDialog("PropDev-Personal-CoiQuestionDialog", true, form);
         }
         
         return view;
     }

     public ModelAndView save(@ModelAttribute("KualiForm") DocumentFormBase form, BindingResult result,
             HttpServletRequest request, HttpServletResponse response, Class<? extends DocumentEventBase> eventClazz) throws Exception {
         ProposalDevelopmentDocumentForm pdForm = (ProposalDevelopmentDocumentForm) form;
         ProposalDevelopmentDocument proposalDevelopmentDocument = (ProposalDevelopmentDocument) pdForm.getDocument();
         proposalDevelopmentService.initializeUnitOrganizationLocation(
                 proposalDevelopmentDocument);
         proposalDevelopmentService.initializeProposalSiteNumbers(
                 proposalDevelopmentDocument);
         ModelAndView view = null;

         saveAnswerHeaders(pdForm,request.getParameter(UifParameters.PAGE_ID));

         if (eventClazz == null) {
             getTransactionalDocumentControllerService().save(form);
         } else {
             performCustomSave(proposalDevelopmentDocument, SaveDocumentSpecialReviewEvent.class);
         }

         populateAdHocRecipients(pdForm.getProposalDevelopmentDocument());

         String pageId = form.getActionParamaterValue(UifParameters.NAVIGATE_TO_PAGE_ID);
         if (StringUtils.isNotBlank(pageId) && getGlobalVariableService().getMessageMap().hasNoErrors()) {
        	 form.setDirtyForm(false);
             view = getModelAndViewService().getModelAndView(form, pageId);
         } else {
             view = getModelAndViewService().getModelAndView(form);
         }

         if (pdForm.getProposalDevelopmentDocument().getDevelopmentProposal() != null
                 && pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().getPropSpecialReviews() != null) {
             for (ProposalSpecialReview specialReview : pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().getPropSpecialReviews()) {
                 if (!specialReview.isLinkedToProtocol()) {
                     pdForm.getSpecialReviewHelper().prepareProtocolLinkViewFields(specialReview);
                 }
             }
         }

         return view;
     }
     
     protected void performCustomSave(DocumentBase document, Class<? extends DocumentEventBase> eventClazz) {
         try {
             getDocumentService().saveDocument(document, eventClazz);
             GlobalVariables.getMessageMap().putInfo(KRADConstants.GLOBAL_MESSAGES, RiceKeyConstants.MESSAGE_SAVED);
         } catch (ValidationException e) {
             // if errors in map, swallow exception so screen will draw with errors
             // if not then throw runtime because something bad happened
             if (GlobalVariables.getMessageMap().hasNoErrors()) {
                 throw new RiceRuntimeException("Validation Exception with no error message.", e);
             }
         } catch (Exception e) {
             throw new RiceRuntimeException(
                     "Exception trying to save document: " + document
                             .getDocumentNumber(), e);
         }
     }
     
     protected ModelAndView navigate(ProposalDevelopmentDocumentForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) throws Exception {
         if (form.getDevelopmentProposal().getS2sOpportunity() != null && !getProposalDevelopmentService().isGrantsGovEnabledForProposal(form.getDevelopmentProposal())) {
             ((ProposalDevelopmentViewHelperServiceImpl)form.getViewHelperService()).clearOpportunity(form.getDevelopmentProposal());
         }
         populateAdHocRecipients(form.getProposalDevelopmentDocument());
         String navigateToPageId = form.getActionParamaterValue(UifParameters.NAVIGATE_TO_PAGE_ID);
         if (isNavigateToDeliveryInfoPage(navigateToPageId)) {
             if (form.getDevelopmentProposal().getS2sOpportunity() != null) {
                 getGlobalVariableService().getMessageMap().putInfo(ProposalDevelopmentConstants.KradConstants.DELIVERY_INFO_PAGE, KeyConstants.DELIVERY_INFO_NOT_NEEDED);
             }
         }
         if (form.isCanEditView()) {
             return save(form);
         } else {
             return getNavigationControllerService().navigate(form);
         }

     }


    protected boolean isNavigateToDeliveryInfoPage(String navigateToPageId) {
        return StringUtils.equals(navigateToPageId, ProposalDevelopmentConstants.KradConstants.DELIVERY_INFO_PAGE);
    }

    public void addEditableCollectionLine(ProposalDevelopmentDocumentForm form, String selectedCollectionPath){
        if(form.getEditableCollectionLines().containsKey(selectedCollectionPath)) {
            updateEditableCollectionLines(form, selectedCollectionPath);
        } else {
            List<String> newKeyList = new ArrayList<String>();
            newKeyList.add("0");
            form.getEditableCollectionLines().put(selectedCollectionPath,newKeyList);
        }

    }

    public void updateEditableCollectionLines(ProposalDevelopmentDocumentForm form, String selectedCollectionPath){
        List<String> indexes = new ArrayList<String>();
        indexes.add("0");
        for (String index : form.getEditableCollectionLines().get(selectedCollectionPath)) {
            Integer newIndex= Integer.parseInt(index) + 1;
            indexes.add(newIndex.toString());
        }
        form.getEditableCollectionLines().get(selectedCollectionPath).clear();
        form.getEditableCollectionLines().get(selectedCollectionPath).addAll(indexes);
    }
    
    protected KcAuthorizationService getKraAuthorizationService() {
        return kraAuthorizationService;
    }

    public void setKraAuthorizationService(KcAuthorizationService kraAuthorizationService) {
        this.kraAuthorizationService = kraAuthorizationService;
    }

    protected ProposalDevelopmentService getProposalDevelopmentService() {
        return proposalDevelopmentService;
    }

    public void setProposalDevelopmentService(ProposalDevelopmentService proposalDevelopmentService) {
        this.proposalDevelopmentService = proposalDevelopmentService;
    }

    protected TransactionalDocumentControllerService getTransactionalDocumentControllerService() {
        return transactionalDocumentControllerService;
    }

    public void setTransactionalDocumentControllerService(TransactionalDocumentControllerService transactionalDocumentControllerService) {
        this.transactionalDocumentControllerService = transactionalDocumentControllerService;
    }
    
    protected DocumentService getDocumentService() {
        return documentService;
    }

    public void setDocumentService(DocumentService documentService) {
        this.documentService = documentService;
    }

    protected LegacyDataAdapter getLegacyDataAdapter() {
        return legacyDataAdapter;
    }

    public void setLegacyDataAdapter(LegacyDataAdapter legacyDataAdapter) {
        this.legacyDataAdapter = legacyDataAdapter;
    }

	protected ProposalRoleTemplateService getProposalRoleTemplateService() {
		return proposalRoleTemplateService;
	}

	public void setProposalRoleTemplateService(
			ProposalRoleTemplateService proposalRoleTemplateService) {
		this.proposalRoleTemplateService = proposalRoleTemplateService;
	}    

	protected DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}

	public void saveAnswerHeaders(ProposalDevelopmentDocumentForm pdForm,String pageId) {
        boolean allCertificationsWereComplete = true;
        boolean allCertificationAreNowComplete = true;
        Person loggedinUser = getGlobalVariableService().getUserSession().getPerson();
        setUpdatedToCoi(false);
        if (StringUtils.equalsIgnoreCase(pageId, Constants.KEY_PERSONNEL_PAGE) ||
                StringUtils.equalsIgnoreCase(pageId,"PropDev-CertificationView-Page")) {
	         List<ProposalPerson> proposalPersons = new ArrayList();
	       	 for (ProposalPerson person : pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().getProposalPersons()) {
	       		 if (person.getDevelopmentProposal()!=null){
	       			 proposalPersons.add(person);
	       		 }
	       	 }
	       	pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().setProposalPersons(proposalPersons);
            for (ProposalPerson person : pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().getProposalPersons()) {
                if (person.getDevelopmentProposal()!=null && person.getQuestionnaireHelper() != null && person.getQuestionnaireHelper().getAnswerHeaders() != null
                        && !person.getQuestionnaireHelper().getAnswerHeaders().isEmpty()) {
                    for (AnswerHeader answerHeader : person.getQuestionnaireHelper().getAnswerHeaders()) {
                        boolean wasComplete = answerHeader.isCompleted();
                        boolean hasCertficationPermission = getProposalDevelopmentPermissionsService().hasCertificationPermissions(pdForm.getProposalDevelopmentDocument(), loggedinUser, person);
                        if(hasCertficationPermission){
                        	allCertificationsWereComplete &= wasComplete;
                        }
                        getLegacyDataAdapter().save(answerHeader);
                        person.getQuestionnaireHelper().populateAnswers();
                        boolean isComplete = person.getQuestionnaireHelper().getAnswerHeaders().get(0).isCompleted();
                        if(hasCertficationPermission){
                        	allCertificationAreNowComplete &= isComplete;
                        }
                        if(isComplete && !wasComplete){
                        	getGlobalVariableService().getMessageMap().putInfoForSectionId("PropDev-CertificationView", KcMitConstants.CERTIFICATION_COMPLETED,"");
                        	person.setCertifiedBy(getGlobalVariableService().getUserSession().getPrincipalName());
                            person.setCertifiedTime(((DateTimeService) KcServiceLocator.getService(Constants.DATE_TIME_SERVICE_NAME)).getCurrentTimestamp());

                        }else if(wasComplete && !isComplete){
                        	person.setCertifiedBy(null);
                        	person.setCertifiedTime(null);
                        }
                        if(!isUpdatedToCoi()){
                        	setUpdatedToCoi(updateCOIOnPDCerificationComplete(pdForm,person,isComplete || wasComplete,answerHeader));
                        }else{
                        	updateCOIOnPDCerificationComplete(pdForm,person,isComplete || wasComplete,answerHeader);
                        }
                        checkForCertifiedByProxy(pdForm.getDevelopmentProposal(),person,isComplete && !wasComplete,wasComplete);
                    }
                }
            }
        } else if (StringUtils.equalsIgnoreCase(pageId, Constants.QUESTIONS_PAGE)) {
            for (AnswerHeader answerHeader : pdForm.getQuestionnaireHelper().getAnswerHeaders()) {
                getLegacyDataAdapter().save(answerHeader);
            }
            for (AnswerHeader answerHeader : pdForm.getS2sQuestionnaireHelper().getAnswerHeaders()) {
                getLegacyDataAdapter().save(answerHeader);
            }
        }

        boolean allowsSendCertificationCompleteNotification = getParameterService().getParameterValueAsBoolean(Constants.MODULE_NAMESPACE_PROPOSAL_DEVELOPMENT,Constants.PARAMETER_COMPONENT_DOCUMENT,ProposalDevelopmentConstants.Parameters.NOTIFY_ALL_CERTIFICATIONS_COMPLETE);
        if (!allCertificationsWereComplete && allCertificationAreNowComplete && allowsSendCertificationCompleteNotification) {
            ProposalDevelopmentNotificationContext context = new ProposalDevelopmentNotificationContext(pdForm.getDevelopmentProposal(),"105","All Proposal Persons Certification Completed");
            ((ProposalDevelopmentNotificationRenderer) context.getRenderer()).setDevelopmentProposal(pdForm.getDevelopmentProposal());
            getKcNotificationService().sendNotification(context);
        }
	}

	public boolean updateCOIOnPDCerificationComplete(ProposalDevelopmentDocumentForm pdForm, ProposalPerson person, boolean completed,AnswerHeader answerHeader) {
			boolean coiQuestionsAnswered = false;
			if(person.getPersonId()!=null && checkForCOIquestions(answerHeader) && completed){
				 updateToCOI(pdForm,person);
			}
			String loggedInUser = getGlobalVariableService().getUserSession().getPrincipalId();

			if(person.getPersonId()!=null && person.getPersonId().equals(loggedInUser)){
				coiQuestionsAnswered = getProposalPersonCoiIntegrationService().isCoiQuestionsAnswered(person);
			}
            return coiQuestionsAnswered;
    }
	
	private void updateToCOI(ProposalDevelopmentDocumentForm pdForm, ProposalPerson person){
		String userName = getGlobalVariableService().getUserSession().getPrincipalName();
		try {
			getKcCoiLinkService().updateCOIOnPDCerificationComplete(pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().getProposalNumber(), person.getPersonId(), userName);
		} catch (SQLException e) {
			LOGGER.info(Level.ALL, e);
			LOGGER.warn("DBLINK is not accessible or the parameter value returning null");
		}
		
	}
	
	private boolean checkForCOIquestions(AnswerHeader answerHeader ){

		boolean hasCOIquestions = false;
		String coiCertificationQuestionIds = getParameterService().getParameterValueAsString("KC-GEN", "All", "PROP_PERSON_COI_CERTIFY_QID");
		List<String> coiCertificationQuestionIdList = new ArrayList<String>();
		if(coiCertificationQuestionIds!=null){
			String[] questionIds = coiCertificationQuestionIds.split(",");
			for (String questionid : questionIds){
				coiCertificationQuestionIdList.add(questionid);
			}
		}
		for(Answer answer :answerHeader.getAnswers()){
			for(String coiCertificationQuestionId : coiCertificationQuestionIdList){
				if(coiCertificationQuestionId.equals(answer.getQuestionSeqId().toString())){
					hasCOIquestions = true;
					break;
				}

			}
		}
		return hasCOIquestions;
	}

    public void checkForCertifiedByProxy(DevelopmentProposal developmentProposal, ProposalPerson person, boolean recentlyCompleted,boolean wasComplete) {
        boolean selfCertifyOnly = getParameterService().getParameterValueAsBoolean(Constants.MODULE_NAMESPACE_PROPOSAL_DEVELOPMENT,Constants.PARAMETER_COMPONENT_DOCUMENT,ProposalDevelopmentConstants.Parameters.KEY_PERSON_CERTIFICATION_SELF_CERTIFY_ONLY);
        if (selfCertifyOnly) {
            String proxyId = getGlobalVariableService().getUserSession().getPrincipalId();
            if (!StringUtils.equals(person.getPersonId(), proxyId) && recentlyCompleted) {
                ProposalDevelopmentNotificationContext context = new ProposalDevelopmentNotificationContext(developmentProposal,"106","Proposal Person Certification Completed");
                ((ProposalDevelopmentNotificationRenderer) context.getRenderer()).setDevelopmentProposal(developmentProposal);
                ((ProposalDevelopmentNotificationRenderer) context.getRenderer()).setProposalPerson(person);
                KcNotification notification = getKcNotificationService().createNotificationObject(context);
                NotificationTypeRecipient recipient = new NotificationTypeRecipient();
                recipient.setPersonId(person.getPersonId());
                getKcNotificationService().sendNotification(context,notification,Collections.singletonList(recipient));
            }
        }
    }
    /**
     * Method calls the permissions service, where it will determine if any user permissions need to be added and/or removed.
     *
     * @param pdForm ProposalDevelopmentDocumentForm that contains the permissions helper
     */
    public void saveDocumentPermissions(ProposalDevelopmentDocumentForm pdForm) {
        List<String> editableLines = pdForm.getEditableCollectionLines().get(Constants.PERMISSION_PROPOSAL_USERS_COLLECTION_PROPERTY_KEY);
        if (editableLines != null && editableLines.size() > 0) {
            getGlobalVariableService().getMessageMap().putErrorForSectionId(Constants.PERMISSION_PROPOSAL_USERS_COLLECTION_ID_KEY, KeyConstants.ERROR_UNFINISHED_PERMISSIONS);
        } else if (arePermissionsValid(pdForm.getProposalDevelopmentDocument(),pdForm.getWorkingUserRoles())) {
            getProposalDevelopmentPermissionsService().savePermissions(pdForm.getProposalDevelopmentDocument(), getProposalDevelopmentPermissionsService().getPermissions(pdForm.getProposalDevelopmentDocument()), pdForm.getWorkingUserRoles());
        }
    }

    protected boolean arePermissionsValid(ProposalDevelopmentDocument document, List<ProposalUserRoles> proposalUsers) {
        boolean retVal = true;
        for (ProposalUserRoles proposalUser : proposalUsers) {
            retVal &= getProposalDevelopmentPermissionsService().validateUpdatePermissions(document,proposalUsers,proposalUser);
        }
        return retVal;
    }

    @InitBinder
    protected void initBinder(WebDataBinder binder) throws Exception {
        binder.registerCustomEditor(List.class, "document.developmentProposal.propScienceKeywords", new PropScienceKeywordEditor());
        binder.registerCustomEditor(List.class, "document.developmentProposal.propSpecialReviews.specialReviewExemptions", new PropSpecialReviewExemptionTypeEditor());

        // For add line binding
        binder.registerCustomEditor(List.class, "newCollectionLines.specialReviewExemptions", new PropSpecialReviewExemptionTypeEditor());
    }

    protected class PropScienceKeywordEditor extends CustomCollectionEditor {
        public PropScienceKeywordEditor() {
            super(List.class, true);
        }

        protected Object convertElement(Object element) {
            if (element != null && element instanceof String) {
                return new PropScienceKeyword(null, getScienceKeyword(element));
            }

            return element;
        }

        public String getAsText() {
            if (this.getValue() != null) {
                Collection<PropScienceKeyword> keywords = (Collection<PropScienceKeyword>) this.getValue();
                StringBuilder result = new StringBuilder();
                for(PropScienceKeyword keyword : keywords) {
                    result.append(keyword.getScienceKeyword().getCode());
                    result.append(",");
                }

                if (result.length() > 0) {
                    return result.substring(0, result.length() - 1);
                }
            }
            return null;
        }
    }

    /**
     * Editor to convert (to and from) a String list of exemption type codes to ProposalSpecialReviewExemption objects
     */
    protected class PropSpecialReviewExemptionTypeEditor extends CustomCollectionEditor {
 		public PropSpecialReviewExemptionTypeEditor() {
 			super(List.class, true);
 		}

 		protected Object convertElement(Object element) {
 			if (element != null && element instanceof String) {
 				return new ProposalSpecialReviewExemption(null, getExemptionType(element));
 			}

            return element;
 		}

        public String getAsText() {
            if (this.getValue() != null) {
                Collection<ProposalSpecialReviewExemption> exemptions = (Collection<ProposalSpecialReviewExemption>) this.getValue();
                StringBuilder result = new StringBuilder();
                for(ProposalSpecialReviewExemption exemption : exemptions) {
                    result.append(exemption.getExemptionTypeCode());
                    result.append(",");
                }

                if (result.length() > 0) {
                    return result.substring(0, result.length() - 1);
                }
            }
            return null;
        }
 	}

    protected ExemptionType getExemptionType(Object element) {
 	   return (ExemptionType) getDataObjectService().findUnique(ExemptionType.class, QueryByCriteria.Builder.forAttribute("code", element).build());
    }

    public AuditHelper.ValidationState getValidationState(ProposalDevelopmentDocumentForm form) {
        AuditHelper.ValidationState severityLevel = AuditHelper.ValidationState.OK;
        form.setAuditActivated(true);
        List<DataValidationItem> dataValidationItems = ((ProposalDevelopmentViewHelperServiceImpl)form.getViewHelperService())
                .populateDataValidation(form);
        if(dataValidationItems != null && dataValidationItems.size() > 0 ) {
            for(DataValidationItem validationItem : dataValidationItems) {
                if (StringUtils.endsWith(validationItem.getSeverity(),Constants.AUDIT_ERRORS)) {
                    severityLevel = AuditHelper.ValidationState.ERROR;
                    break;
                }
                if (StringUtils.equals(validationItem.getSeverity(), Constants.AUDIT_WARNINGS)){
                    severityLevel = AuditHelper.ValidationState.WARNING;
                }
            }
            form.setDataValidationItems(dataValidationItems);
        }
        getGlobalVariableService().getMessageMap().clearErrorMessages();
        return severityLevel;
    }

    /**
     * During navigation and routing the ad hoc recipients which are transient get removed.  To solve this, repopulate them in the document before each save.
     * This will stop the system from removing the current recipients from the database.
     *
     * Extra logic added to assist in avoiding the null document number issue.
     */
    public void populateAdHocRecipients(ProposalDevelopmentDocument proposalDevelopmentDocument){
        if (StringUtils.isEmpty(proposalDevelopmentDocument.getDocumentNumber())
                && proposalDevelopmentDocument.getDocumentHeader() != null && StringUtils.isNotEmpty(proposalDevelopmentDocument.getDocumentHeader().getDocumentNumber())){
            proposalDevelopmentDocument.setDocumentNumber(proposalDevelopmentDocument.getDocumentHeader().getDocumentNumber());
        }
        if (StringUtils.isNotEmpty(proposalDevelopmentDocument.getDocumentNumber())){
            getDocumentAdHocService().addAdHocs(proposalDevelopmentDocument);
        }

    }

    /**
     *
     * If the sponsor has changed, default the key personnel role codes to COI if the role can't be found
     */
    public void handleSponsorChange(ProposalDevelopmentDocument proposalDevelopmentDocument){
        for (int i=0; i< proposalDevelopmentDocument.getDevelopmentProposal().getProposalPersons().size();i++){
            ProposalPerson person = proposalDevelopmentDocument.getDevelopmentProposal().getProposalPersons().get(i);
            if (person.getRole() == null){
                person.setProposalPersonRoleId(PropAwardPersonRole.CO_INVESTIGATOR);
                String propertyName = ProposalDevelopmentConstants.PropertyConstants.PROPOSAL_PERSONS;
                getGlobalVariableService().getMessageMap().putInfo(propertyName + "[" + i + "].proposalPersonRoleId", KeyConstants.INFO_PERSONNEL_INVALID_ROLE, person.getDevelopmentProposal().getSponsorCode(), person.getFullName());
            }
        }
    }
    
    public void handleProposalTypeChange(DevelopmentProposal proposal){
	    if (!StringUtils.isBlank(proposal.getS2sOpportunity().getS2sSubmissionTypeCode())) {
	 	   String defaultS2sSubmissionTypeCode = proposal.getS2sOpportunity().getS2sSubmissionTypeCode();
	       if(StringUtils.equals(proposal.getProposalTypeCode(),getProposalTypeService().getNewChangedOrCorrectedProposalTypeCode())
	     		   || StringUtils.equals(proposal.getProposalTypeCode(),getProposalTypeService().getResubmissionChangedOrCorrectedProposalTypeCode())
	     				   || StringUtils.equals(proposal.getProposalTypeCode(),getProposalTypeService().getSupplementChangedOrCorrectedProposalTypeCode())
	     						  || StringUtils.equals(proposal.getProposalTypeCode(),getProposalTypeService().getRenewalChangedOrCorrectedProposalTypeCode())) {
	     	   defaultS2sSubmissionTypeCode = getParameterService().getParameterValueAsString(Constants.MODULE_NAMESPACE_PROPOSAL_DEVELOPMENT,
	                    ParameterConstants.DOCUMENT_COMPONENT, ProposalDevelopmentConstants.PropDevParameterConstants.CHANGE_CORRECTED_CODE); 
	 	   } else if(StringUtils.equals(proposal.getProposalTypeCode(),getProposalTypeService().getPreProposalProposalTypeCode())) {
	 		   defaultS2sSubmissionTypeCode = getParameterService().getParameterValueAsString(Constants.MODULE_NAMESPACE_PROPOSAL_DEVELOPMENT,
	                    ParameterConstants.ALL_COMPONENT, ProposalDevelopmentConstants.PropDevParameterConstants.S2S_SUBMISSION_TYPE_CODE_PREAPPLICATION_PARM);
	 	   } else {
	 		  defaultS2sSubmissionTypeCode = getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, KeyConstants.S2S_SUBMISSIONTYPE_APPLICATION);
	 	   }
	        proposal.getS2sOpportunity().setS2sSubmissionTypeCode(defaultS2sSubmissionTypeCode);
	        getDataObjectService().wrap(proposal.getS2sOpportunity()).fetchRelationship("s2sSubmissionType");
	    }
    }

    public void populateDeferredMessages(ProposalDevelopmentDocumentForm proposalDevelopmentDocumentForm){
        if (proposalDevelopmentDocumentForm.getDeferredMessages() != null
                && proposalDevelopmentDocumentForm.getDeferredMessages().hasMessages()){
            MessageMap messageMap = proposalDevelopmentDocumentForm.getDeferredMessages();
            MessageMap currentMessageMap = getGlobalVariableService().getMessageMap();
            messageMap.getErrorMessages().putAll(currentMessageMap.getErrorMessages());
            messageMap.getInfoMessages().putAll(currentMessageMap.getInfoMessages());
            messageMap.getWarningMessages().putAll(currentMessageMap.getWarningMessages());
            getGlobalVariableService().setMessageMap(messageMap);
        }
        proposalDevelopmentDocumentForm.setDeferredMessages(null);
    }

    protected ScienceKeyword getScienceKeyword(Object element) {
        return getDataObjectService().findUnique(ScienceKeyword.class, QueryByCriteria.Builder.forAttribute("code", element).build());
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

    public CollectionControllerService getCollectionControllerService() {
        return collectionControllerService;
    }

    public void setCollectionControllerService(CollectionControllerService collectionControllerService) {
        this.collectionControllerService = collectionControllerService;
    }

    public FileControllerService getFileControllerService() {
        return fileControllerService;
    }

    public void setFileControllerService(FileControllerService fileControllerService) {
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

	public GlobalVariableService getGlobalVariableService() {
		return globalVariableService;
	}

	public void setGlobalVariableService(GlobalVariableService globalVariableService) {
		this.globalVariableService = globalVariableService;
	}

    protected ProposalDevelopmentPermissionsService getProposalDevelopmentPermissionsService() {
        return proposalDevelopmentPermissionsService;
    }

    public void setProposalDevelopmentPermissionsService(ProposalDevelopmentPermissionsService proposalDevelopmentPermissionsService) {
        this.proposalDevelopmentPermissionsService = proposalDevelopmentPermissionsService;
    }

    public ProposalPersonBiographyService getProposalPersonBiographyService() {
        return proposalPersonBiographyService;
    }

    public void setProposalPersonBiographyService(ProposalPersonBiographyService proposalPersonBiographyService) {
        this.proposalPersonBiographyService = proposalPersonBiographyService;
    }

    public DocumentAdHocService getDocumentAdHocService() {
        return documentAdHocService;
    }

    public void setDocumentAdHocService(DocumentAdHocService documentAdHocService) {
        this.documentAdHocService = documentAdHocService;
    }

    public AuditHelper getAuditHelper() {
        return auditHelper;
    }

    public void setAuditHelper(AuditHelper auditHelper) {
        this.auditHelper = auditHelper;
    }

    public KcNotificationService getKcNotificationService() {
        return kcNotificationService;
    }

    public void setKcNotificationService(KcNotificationService kcNotificationService) {
        this.kcNotificationService = kcNotificationService;
    }

    public ParameterService getParameterService() {
        return parameterService;
    }

    public void setParameterService(ParameterService parameterService) {
        this.parameterService = parameterService;
    }

    public PessimisticLockService getPessimisticLockService() {
        return pessimisticLockService;
    }

    public void setPessimisticLockService(PessimisticLockService pessimisticLockService) {
        this.pessimisticLockService = pessimisticLockService;
    }
    
    public boolean isUpdatedToCoi() {
		return updatedToCoi;
	}

	public void setUpdatedToCoi(boolean updatedToCoi) {
		this.updatedToCoi = updatedToCoi;
	}
	
	public ConfigurationService getKualiConfigurationService() {
		return kualiConfigurationService;
	}

	public void setKualiConfigurationService(
			ConfigurationService kualiConfigurationService) {
		this.kualiConfigurationService = kualiConfigurationService;
	}
	
	public ProposalPersonCoiIntegrationService getProposalPersonCoiIntegrationService() {
		return proposalPersonCoiIntegrationService;
	}

	public void setProposalPersonCoiIntegrationService(
			ProposalPersonCoiIntegrationService proposalPersonCoiIntegrationService) {
		this.proposalPersonCoiIntegrationService = proposalPersonCoiIntegrationService;
	}
	
	public ProposalTypeService getProposalTypeService() {
		return proposalTypeService;
	}

	public SharedDocumentService getSharedDocumentService() {
	      return KcServiceLocator.getService(SharedDocumentService.class);
	}
}