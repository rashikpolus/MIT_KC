/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
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
package edu.mit.kc.award.service.impl;

import org.kuali.kra.award.contacts.AwardPerson;
import org.kuali.kra.award.customdata.AwardCustomData;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardSponsorTerm;
import org.kuali.kra.award.home.fundingproposal.AwardFundingProposal;
import org.kuali.kra.award.paymentreports.awardreports.AwardReportTerm;
import org.kuali.kra.award.paymentreports.awardreports.reporting.ReportTracking;
import org.kuali.kra.award.specialreview.AwardSpecialReview;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.coeus.common.api.sponsor.hierarchy.SponsorHierarchyService;
import org.kuali.coeus.common.framework.custom.attr.CustomAttribute;
import org.kuali.coeus.common.framework.module.CoeusModule;
import org.kuali.coeus.common.framework.person.attr.PersonTraining;
import org.kuali.coeus.common.questionnaire.framework.answer.Answer;
import org.kuali.coeus.common.questionnaire.framework.answer.AnswerHeader;
import org.kuali.coeus.common.questionnaire.framework.answer.ModuleQuestionnaireBean;
import org.kuali.coeus.common.questionnaire.framework.answer.QuestionnaireAnswerService;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.propdev.impl.person.question.ProposalPersonModuleQuestionnaireBean;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import edu.mit.kc.award.service.AwardCommonValidationService;
import edu.mit.kc.common.DbFunctionExecuteService;
import edu.mit.kc.infrastructure.KcMitConstants;

import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.coreservice.api.parameter.Parameter;

import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.kns.util.KNSGlobalVariables;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.AuditCluster;
import org.kuali.rice.krad.util.AuditError;
import org.kuali.rice.krad.util.ErrorMessage;
import org.kuali.rice.krad.util.GlobalVariables;
import org.springframework.transaction.annotation.Transactional;
import java.util.logging.Logger;
import java.util.logging.Level;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import java.util.*;

/**
 * Service class for Award Hold Prompt Validation Rules.
 */
@Transactional
public class AwardCommonValidationServiceImpl implements AwardCommonValidationService {
    
    private List<AuditError> auditWarnings = new ArrayList<AuditError>();
    private ParameterService parameterService;  
    private BusinessObjectService businessObjectService;
	private Integer AWARD_MODULE_CODE=1;
    private String SPONSOR_TERM_CODE_HOLD ="143";
    private String NIH_SPONSOR_CODE="000500";
    private String REPORT_TRACKING_FREQ_CODE="4";
    private String REPORT_TRACKING_STATUS_CODE="1";
    private String REPORT_TRACKING_CLASS_CODE="4";
    private DbFunctionExecuteService dbFunctionExecuteService;
    private SponsorHierarchyService sponsorHierarchyService;
    private QuestionnaireAnswerService questionnaireAnswerService;
	protected static final String KC_COI_DB_LINK = "KC_COI_DB_LINK"; 
	protected static final String KC_GENERAL_NAMESPACE = "KC-GEN";
	protected static final String DOCUMENT_COMPONENT_NAME = "Document";
	private String  coiReqKP ="COI Disclosures with KP req";
   private String  coiReqNoKP ="COI Disclosures no KP";
   private static final String SPONSOR_HEIRARCHY= "COIHierarchyName";
   private static final String COI_SPONSOR_HEIRARCHY_LEVEL1= "COIHierarchyLevel1";
	Logger LOGGER;
	
	public AwardCommonValidationServiceImpl() {
		super();
		LOGGER = Logger.getLogger(AwardCommonValidationServiceImpl.class.getName());
	}
    
/* public boolean validateAwardHoldPrompt(Award award) {
    	boolean retval = true;      	
    	retval &=validateSponsorCodeIsNIH(award);
    	retval &=validateSpecialReviews(award);
    	retval &=validateReports(award);
    	retval &=validateAwardTerm(award);
   if (!retval) {   	 
        reportAndCreateAuditCluster();            
    } 
   
   
 return retval;
    	
    }*/
    @SuppressWarnings("unchecked")
    
	protected String getDBLink() {
    	
		try {
			Parameter parm = this.getParameterService().getParameter(KC_GENERAL_NAMESPACE, DOCUMENT_COMPONENT_NAME,KC_COI_DB_LINK);
			
			if (!parm.getValue().isEmpty()) {
				return '@' + parm.getValue();
			}
			
		

		} catch (NullPointerException e) {
			LOGGER.log(Level.ALL, e.getMessage(), e);
			LOGGER.log(Level.ALL,
					"DBLINK is not accessible or the parameter value returning null");
		} 

		return "";
	}
    public boolean validateAwardOnCOI(Award award) {
    	boolean awardPromptCoi = getParameterService().getParameterValueAsBoolean(
    			"KC-AWARD", "Document", "AWARD_ON_HOLD_BASED_ON_COI");
    	String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
    	String errorKey = "document.awardList[0].statusCode";
    	String awardNewPerList="";
    	String awardNumber=award.getAwardNumber();
    	String sponsorCode=award.getSponsorCode();
    	String primeSponsorCode=award.getPrimeSponsorCode(); 
    	boolean isHoldprompt = true;
    	if(awardPromptCoi){	
    		if(!checkCustomDataPCKFlag(award)){
    			isHoldprompt = false;
    		}
    		if (getSponsorHierarchyService().isSponsorInHierarchy(sponsorCode,
    				"COI Disclosures") || (primeSponsorCode!=null && getSponsorHierarchyService().isSponsorInHierarchy(primeSponsorCode,"COI Disclosures"))) {		
    			StringBuilder awardPersonList = new StringBuilder();
    			award.refreshReferenceObject("investigators");
    			for(AwardPerson awardPerson:award.getInvestigators()){		
    				if(awardPerson.getPersonId()!=null){
    					awardPersonList.append(awardPerson.getPersonId());
    					awardPersonList.append(",");	
    				}
    			}			
    			awardNewPerList=awardPersonList.toString();
    			if(awardNewPerList!=null && !awardNewPerList.isEmpty()){
    				if (!hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
    					auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV, link));
    					GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV,KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV);
    					isHoldprompt = false;
    				}
    			}
    		}
    	       String sponsorHeirarchy =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, SPONSOR_HEIRARCHY); 
    	       String sponsorHeirarchyLevelName =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, COI_SPONSOR_HEIRARCHY_LEVEL1); 

    		if (getSponsorHierarchyService().isSponsorInHierarchy(sponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName) || 
    				(primeSponsorCode!=null && getSponsorHierarchyService().isSponsorInHierarchy(primeSponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName))) {
    			StringBuilder awardPersonList = new StringBuilder();
    			for(AwardPerson awardPerson:award.getKeyPersons()){		
    				if(awardPerson.getPersonId()!=null){
    					awardPersonList.append(awardPerson.getPersonId());
    					awardPersonList.append(",");			
    				}
    			}			
    			awardNewPerList=awardPersonList.toString();		
    			if(awardNewPerList!=null && !awardNewPerList.isEmpty()){
    				if (hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
    					for(AwardPerson awardPerson:award.getKeyPersons()){	
    						if(awardPerson.getConfirmed().equals("false")){	
    							auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED, link));
    							GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED,KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED);
    							isHoldprompt = false;
    						}
    					}
    				}else{
    					auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP, link));
    					GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP,KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP);
    					isHoldprompt = false;
    				}
    			}
    		}
    	}
    	return isHoldprompt;
    }
    
    protected boolean checkCustomDataPCKFlag(Award award){
    	List<AwardCustomData> awardCustomDataList = award.getAwardCustomDataList();
    	String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
    	String errorKey = "document.awardList[0].statusCode";
    	String awardNewPerList="";
    	String awardNumber=award.getAwardNumber();
    	boolean isHoldprompt = true;
    	for (AwardCustomData awardCustomData : awardCustomDataList) {
    		CustomAttribute customAttribute = awardCustomData
    				.getCustomAttribute();
    		if (customAttribute.getName().equals("COI_REQUIREMENT")
    				&& awardCustomData.getValue()!= null && awardCustomData.getValue().equals("PCK")) {
    			StringBuilder awardPersonList = new StringBuilder();
    			for(AwardPerson awardPerson:award.getKeyPersons()){		
    				if(awardPerson.getPersonId()!=null){
    					awardPersonList.append(awardPerson.getPersonId());
    					awardPersonList.append(",");		
    				}
    			}			
    			awardNewPerList=awardPersonList.toString();		
    			if(awardNewPerList!=null && !awardNewPerList.isEmpty()){
    				if (hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
    					for(AwardPerson awardPerson:award.getKeyPersons()){	
    						if(awardPerson.getConfirmed().equals("false")){	
    							auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED, link));
    							GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED,KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED);
    							isHoldprompt = false;
    						}
    					}
    				}else{
    					auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP, link));
    					GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP,KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP);
    					isHoldprompt = false;
    				}
    			}
    			StringBuilder awardInvestigatorList = new StringBuilder();
    			for(AwardPerson awardPerson:award.getInvestigators()){		
    				if(awardPerson.getPersonId()!=null){
    					awardInvestigatorList.append(awardPerson.getPersonId());
    					awardInvestigatorList.append(",");			
    				}
    			}			
    			awardNewPerList=awardInvestigatorList.toString();
    			if(awardNewPerList!=null && !awardNewPerList.isEmpty()){

    				if (!hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
    					auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV, link));
    					GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV,KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV);
    					isHoldprompt = false;
    				}
    			}
    		} else if (customAttribute.getName().equals("COI_REQUIREMENT")	&& (awardCustomData.getValue()!= null && awardCustomData.getValue().equals("PC"))) {
    			StringBuilder awardPersonList = new StringBuilder();
    			for(AwardPerson awardPerson:award.getInvestigators()){		
    				if(awardPerson.getPersonId()!=null){
    					awardPersonList.append(awardPerson.getPersonId());
    					awardPersonList.append(",");			
    				}
    			}			
    			awardNewPerList=awardPersonList.toString();
    			if(awardNewPerList!=null && !awardNewPerList.isEmpty()){

    				if (!hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
    					auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV, link));
    					GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV,KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV);
    					isHoldprompt = false;
    				}
    			}
    		}
    	}
		return isHoldprompt;
    }
    
    public boolean validateSponsorCodeIsNIH (Award award) {
        boolean valid = true;
        String sponsorCode=award.getSponsorCode();
        String primeSponsorCode=award.getPrimeSponsorCode();           
        String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
        String messageKey = KcMitConstants.ERROR_AWARD_HOLD_PROMPT_SPONSOR_CODE;
        String errorKey = "document.awardList[0].awardStatus";
        boolean awardSponsorNsf = getParameterService().getParameterValueAsBoolean(
                "KC-AWARD", "Document", "ENABLE_AWARD_NSF_RCR_REVIEW_VALID");
         if(awardSponsorNsf && sponsorCode!=null && sponsorCode.equalsIgnoreCase(NIH_SPONSOR_CODE)||primeSponsorCode!=null && primeSponsorCode.equalsIgnoreCase(NIH_SPONSOR_CODE)){                
            valid = false;
            auditWarnings.add(new AuditError(errorKey, messageKey, link));
            GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_SPONSOR_CODE , KcMitConstants.ERROR_AWARD_HOLD_PROMPT_SPONSOR_CODE); 
         } 
        return valid;
        }
    
    @SuppressWarnings("unchecked") 
    
  public boolean validateSpecialReviews(Award award){
      int  noOfHumanReviews = 0;
      int noOfAnimalReviews = 0;
      int noOfDnaReviews = 0;
      int noOfIsotopReviews = 0;
      int noOfBioReviews = 0;
      int noOfInterReviews =0;
      String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
      String errorKey = "document.awardList[0].statusCode";
      boolean valid = true;
      String specialReviewHumanSubjects = getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "ENABLE_AWARD_HUMAN_REVIEW_VALID");
      String specialReviewAnimal = getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "ENABLE_ANIMAL_REVIEW_VALID");
      String specialReviewDna = getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "ENABLE_AWARD_DNA_REVIEW_VALID");
      String specialReviewIsotop = getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "ENABLE_AWARD_ISOTOPE_REVIEW_VALID");
      String specialReviewBio = getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "ENABLE_AWARD_BIOHAZARD_REVIEW_VALID");
      String specialReviewInter = getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "ENABLE_AWARD_INTER_REVIEW_VALID");
        List<AwardSpecialReview> specialReviews = award.getSpecialReviews();
        if(specialReviews!=null){
        for(AwardSpecialReview spReview:specialReviews){
      if(specialReviewHumanSubjects!=null && spReview.getSpecialReviewTypeCode().equalsIgnoreCase("1")&& 
              specialReviewHumanSubjects.equalsIgnoreCase(spReview.getApprovalTypeCode())){
          valid = false;
          noOfHumanReviews ++;            
      }if(specialReviewAnimal!=null && spReview.getSpecialReviewTypeCode().equalsIgnoreCase("2")&& 
              specialReviewAnimal.equalsIgnoreCase(spReview.getApprovalTypeCode())){
          valid = false;
          noOfAnimalReviews ++;           
      }if(specialReviewDna!=null && spReview.getSpecialReviewTypeCode().equalsIgnoreCase("3")&& 
              specialReviewDna.equalsIgnoreCase(spReview.getApprovalTypeCode())){
          valid = false;
          noOfDnaReviews ++;              
      }if(specialReviewIsotop!=null && spReview.getSpecialReviewTypeCode().equalsIgnoreCase("4")&& 
              specialReviewIsotop.equalsIgnoreCase(spReview.getApprovalTypeCode())){
          valid = false;
          noOfIsotopReviews ++;           
      }if(specialReviewBio!=null && spReview.getSpecialReviewTypeCode().equalsIgnoreCase("5")&& 
              specialReviewBio.equalsIgnoreCase(spReview.getApprovalTypeCode())){
          valid = false;
          noOfBioReviews ++;              
      }if(specialReviewInter!=null && spReview.getSpecialReviewTypeCode().equalsIgnoreCase("6")&& 
              specialReviewInter.equalsIgnoreCase(spReview.getApprovalTypeCode())){ 
          valid = false;
          noOfInterReviews ++;            
      }}}
      if(noOfHumanReviews==1){
          auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW, link));
          GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW);
     }else if(noOfHumanReviews > 1){
         auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_HUMAN_REVIEW, link));
         GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_HUMAN_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_HUMAN_REVIEW);
     } if(noOfAnimalReviews==1){
         auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW, link));
         GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW);
    }else if(noOfAnimalReviews > 1){
        auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW, link));
        GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW);
    } if(noOfDnaReviews==1){
        auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_DNA_REVIEW, link));
        GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_DNA_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_DNA_REVIEW);
   }else if(noOfDnaReviews > 1){
       auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_DNA_REVIEW, link));
       GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_DNA_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_DNA_REVIEW);
   } if(noOfIsotopReviews==1){
       auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ISOTOP_REVIEW, link));
       GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ISOTOP_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_ISOTOP_REVIEW);
  }else if(noOfIsotopReviews > 1){
      auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_ISOTOP_REVIEW, link));
      GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_ISOTOP_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_ISOTOP_REVIEW);
  } if(noOfBioReviews==1){
      auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_BIO_REVIEW, link));
      GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_BIO_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_BIO_REVIEW);
 }else if(noOfBioReviews > 1){
     auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_BIO_REVIEW, link));
     GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_BIO_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_BIO_REVIEW);
 } if(noOfInterReviews==1){
     auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW, link));
     GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW);
}else if(noOfInterReviews > 1){
    auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW, link));
    GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW);
}
 return valid;
  }
    
    @SuppressWarnings("unchecked")
    public boolean validateReports(Award award){
        boolean awardHoldOnReportTerm = getParameterService().getParameterValueAsBoolean(
                "KC-AWARD", "Document", "ENABLE_AWARD_REPORT_VALIDATION");
        boolean valid = true;
        String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
        String errorKey = "document.awardList[0].statusCode";       
      List<AwardReportTerm>awardReportTerms= award.getAwardReportTermItems();
    for(AwardReportTerm awardReportTerm:awardReportTerms){
       List<ReportTracking>reportTrackings = awardReportTerm.getReportTrackings();      
       if(reportTrackings!=null){
    for(ReportTracking reportTracking:reportTrackings){
    	/*if(reportTracking.getDueDate()!=null){
    	 int dateToCompare =  reportTracking.getDueDate().compareTo(new java.util.Date());}*/
    	Date crrentDate = new java.util.Date();
    	Calendar cal = Calendar.getInstance();
        cal.setTime(crrentDate);
        cal.add(Calendar.DATE, -74);
        Date dateBefore74Days = cal.getTime();
    	 if(awardHoldOnReportTerm && reportTracking.getFrequencyCode()!=null && reportTracking.getFrequencyCode().equals(REPORT_TRACKING_FREQ_CODE) && reportTracking.getReportClassCode()!=null && reportTracking.getReportClassCode().equals(REPORT_TRACKING_CLASS_CODE) &&
        		reportTracking.getStatusCode()!=null && reportTracking.getStatusCode().equals(REPORT_TRACKING_STATUS_CODE)  && reportTracking.getDueDate()!=null) {
        	int dateToCompare =  reportTracking.getDueDate().compareTo(new java.util.Date());
        	int datePastDue = reportTracking.getDueDate().compareTo(dateBefore74Days);
        	if(dateToCompare<0 && datePastDue<0){
            valid=false;
            auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_INTER_REVIEW, link));
            GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_INTER_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_MULTIPLE_INTER_REVIEW);
        }
    }}
    }}
        return valid;
    }
   
    public boolean validateAwardTerm(Award award){
        boolean valid=true;
        String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
        String errorKey = "document.awardList[0].statusCode";
        int noOfAwardTerms = 0;
        int noOfSpecialReview = 0;
        boolean awardHoldOnTermReview = getParameterService().getParameterValueAsBoolean(
                "KC-AWARD", "Document", "ENABLE_AWARD_TERM_REVIEW_VALID");
        String awardAnimalSpReview= getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "IACUC_SPL_REV_TYPE_CODE");
        String awardHumanSpReview = getParameterService().getParameterValueAsString(
                "KC-AWARD", "Document", "SPL_REV_TYPE_CODE_HUMAN");
        List<AwardSponsorTerm>awardSponsorTerms = award.getAwardSponsorTerms();
        if(awardSponsorTerms!=null){
        for(AwardSponsorTerm awardSponsorTerm:awardSponsorTerms){
         if(awardHoldOnTermReview && awardSponsorTerm.getSponsorTermCode().equals(SPONSOR_TERM_CODE_HOLD)){
             noOfAwardTerms++; 
         }
    }}List<AwardSpecialReview>awardSpecialReviews = award.getSpecialReviews();
    if(awardSpecialReviews!=null){
    for(AwardSpecialReview awardSpecialReview:awardSpecialReviews){
        if(awardHoldOnTermReview && awardSpecialReview.getSpecialReviewTypeCode().equalsIgnoreCase(awardHumanSpReview) ||  awardSpecialReview.getSpecialReviewTypeCode().equalsIgnoreCase(awardAnimalSpReview)){
            noOfSpecialReview ++;   
        }
    }}
    if(noOfSpecialReview > 0){
       if(noOfAwardTerms ==0){
           valid = false;
           auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_TERM_SPREVIEW, link));
           GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_TERM_SPREVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_TERM_SPREVIEW);
       }}else if(noOfAwardTerms > 0){
    	   if(noOfSpecialReview ==0){
           valid = false;
           auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW, link)); 
           GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW);
       }}/*else{
           valid=false;
           auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW, link));
           GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW,KcMitConstants.ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW);
       }*/
    
        return valid;
    }
    
    
    public boolean validateTrainingRequirements(Award award){
    	boolean isValid = true;
    	String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
    	String errorKey = "document.awardList[0].statusCode";
		boolean trainingRequired = getTrainingRequired(award);
		if(trainingRequired){
			for(AwardPerson awardPerson : award.getProjectPersons()){
				if(awardPerson.getPersonId()!=null){
					if(!getTrainingStatus(awardPerson).equalsIgnoreCase("Training Completed")){ 
						isValid = false;
						if(!isValid){
							auditWarnings.add(new AuditError(errorKey, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV, link));
							GlobalVariables.getMessageMap().putWarning(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV,KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV);
							return isValid;
						}
					}else{
						isValid = true;
					}
				}
			}
		}
		
		return isValid;
	}
	
    public String getTrainingStatus(AwardPerson person){
		String training = "Training Required";
		Map<String, String> queryMap = new HashMap<String, String>();
		queryMap.put("trainingCode", "54");
		queryMap.put("personId",person.getPersonId());
		List <PersonTraining> personTrainingList = (List<PersonTraining>) getBusinessObjectService().findMatching(PersonTraining.class, queryMap);
		if(personTrainingList!=null && !personTrainingList.isEmpty()){
			PersonTraining personTraining = personTrainingList.get(0);
			if(personTraining.getFollowupDate()!=null && personTraining.getFollowupDate().after(KcServiceLocator.getService(DateTimeService.class).getCurrentDate())){
				training = "Training Completed";
			}
			else{
				training = "Training Required";
			}
		}
		return training;
	}
    
/*   public boolean validateAwardOnCOI (Award award) {
       // To be Implemented later
      return true;
      }
    */
    protected void reportAndCreateAuditCluster() {    
        if (auditWarnings.size() > 0) {  
        		
            GlobalVariables.getAuditErrorMap().put("homePageAuditWarnings", new AuditCluster(Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_NAME, auditWarnings,Constants.AUDIT_WARNINGS));            
        
        }     

    }
    public boolean hasCoiDisclosure(String awardNumber, Integer moduleCode, String personIds){
    	List<Object> paramValues = new ArrayList<Object>();
    	String result = "";	
    	Integer newResult=0;
    	try{
    		paramValues.add(0, awardNumber);
    		paramValues.add(1,AWARD_MODULE_CODE);
    		paramValues.add(2,personIds);
    		result = getDbFunctionExecuteService()
    				.executeFunction(
    						"fn_is_proj_disc_stat_complete"
    								+ this.getDBLink(), paramValues);
    	} catch (Exception ex) {
    		LOGGER.log(Level.INFO, "Got exception:" + ex.getMessage());
    		LOGGER.log(Level.ALL, ex.getMessage(), ex);
    	} finally {
    		try {
    			if (!result.isEmpty()) {
    				LOGGER.log(Level.INFO,
    						"Function Successfully Invoked");
    			}
    		} catch (Exception e) {
    			LOGGER.log(Level.ALL, e.getMessage(), e);
    		}
    	}
    	if(result.equals("")){
    		return false;
    	}
    	if(result!=null){
    		newResult=Integer.parseInt(result);}
    	if (newResult ==-1 ) {
    		return false;
    	}else
    	{
    		return true;
    	}
}


public List<AwardPerson> getCOIHoldPromptDisclousureItems(Award award,AwardPerson disclosurePerson) {
	boolean awardPromptCoi = getParameterService().getParameterValueAsBoolean(
			"KC-AWARD", "Document", "AWARD_ON_HOLD_BASED_ON_COI");
	List<AwardPerson> disclosurePersons = new ArrayList();
	String awardNewPerList="";
	String awardNumber=award.getAwardNumber();
	String sponsorCode=award.getSponsorCode();
	String primeSponsorCode=award.getPrimeSponsorCode(); 
	disclosurePerson.setTrainingRequired(false);
	disclosurePerson.setDisclosuerNotRequired(false);
	
   
	disclosurePersons = checkPCKCustomData(award,disclosurePerson);

	if(disclosurePersons!=null && !disclosurePersons.isEmpty()){
		return disclosurePersons;
	}
	
	String sponsorHeirarchy =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, SPONSOR_HEIRARCHY); 
    String sponsorHeirarchyLevelName =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, COI_SPONSOR_HEIRARCHY_LEVEL1); 
    if (getSponsorHierarchyService().isSponsorInHierarchy(sponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName) || 
			(primeSponsorCode!=null && getSponsorHierarchyService().isSponsorInHierarchy(primeSponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName))) {
    	disclosurePerson.setTrainingRequired(true);
    }else {
    	if(disclosurePerson.getRoleCode().equals(Constants.KEY_PERSON_ROLE)){
    		disclosurePerson.setDisclosuerNotRequired(true);
    	}
    }
	if(awardPromptCoi && disclosurePerson.getPersonId()!=null){	
		if (getSponsorHierarchyService().isSponsorInHierarchy(sponsorCode,
				"COI Disclosures") || (primeSponsorCode!=null && getSponsorHierarchyService().isSponsorInHierarchy(primeSponsorCode,"COI Disclosures"))) {		
			StringBuilder awardPersonList = new StringBuilder();
			award.refreshReferenceObject("investigators");
			if(award.getInvestigators().contains(disclosurePerson) && disclosurePerson.getPersonId()!=null){
				awardPersonList.append(disclosurePerson.getPersonId());
				awardNewPerList=awardPersonList.toString();
				if (!hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
					disclosurePersons.add(disclosurePerson);
					return disclosurePersons;
				}
			}
		}
		
		if (getSponsorHierarchyService().isSponsorInHierarchy(sponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName) || 
				(primeSponsorCode!=null && getSponsorHierarchyService().isSponsorInHierarchy(primeSponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName))) {
			StringBuilder awardPersonList = new StringBuilder();
			if(award.getKeyPersons().contains(disclosurePerson) && disclosurePerson.getPersonId()!=null){
				awardPersonList.append(disclosurePerson.getPersonId());
				awardNewPerList=awardPersonList.toString();		
				if (hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
						if(disclosurePerson.getConfirmed().equals("false")){	
							disclosurePersons.add(disclosurePerson);
							return disclosurePersons;
						}
				}else{
					disclosurePersons.add(disclosurePerson);
					return disclosurePersons;
				}}
		}
		}
	if(disclosurePersons!=null && disclosurePersons.isEmpty() && disclosurePerson.getPersonId()!=null){
		//disclosurePerson.setDisclosuerNotRequired(true);
		disclosurePersons.add(disclosurePerson);
	}
	return disclosurePersons;
}
protected List<AwardPerson> checkPCKCustomData(Award award,AwardPerson disclosurePerson){
	List<AwardPerson> disclosurePersons = new ArrayList();
	String awardNewPerList="";
	String awardNumber=award.getAwardNumber();
		List<AwardCustomData> awardCustomDataList = award.getAwardCustomDataList();
		for (AwardCustomData awardCustomData : awardCustomDataList) {
			CustomAttribute customAttribute = awardCustomData
					.getCustomAttribute();
			if (customAttribute.getName().equals("COI_REQUIREMENT") && awardCustomData.getValue()!= null && awardCustomData.getValue().equals("PCK")) {
				StringBuilder awardPersonList = new StringBuilder();
				if(disclosurePerson.getPersonId()!=null && award.getKeyPersons().contains(disclosurePerson)){
					awardPersonList.append(disclosurePerson.getPersonId());
					awardNewPerList=awardPersonList.toString();		
					if (hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
							if(disclosurePerson.getConfirmed().equals("false")){	
								disclosurePersons.add(disclosurePerson);
								return disclosurePersons;
							}
					}else{
						disclosurePersons.add(disclosurePerson);
						return disclosurePersons;
					}
				}
				
				StringBuilder awardInvestigatorList = new StringBuilder();
				if(disclosurePerson.getPersonId()!=null && award.getInvestigators().contains(disclosurePerson)){
					awardInvestigatorList.append(disclosurePerson.getPersonId());
					awardNewPerList = awardInvestigatorList.toString();

					if (!hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
						disclosurePersons.add(disclosurePerson);
						return disclosurePersons;
					}
				}
				
			} else if (customAttribute.getName().equals("COI_REQUIREMENT")	&& (awardCustomData.getValue()!= null && awardCustomData.getValue().equals("PC"))) {
				StringBuilder awardPersonList = new StringBuilder();
				if(disclosurePerson.getPersonId()!=null && award.getInvestigators().contains(disclosurePerson)){
					awardPersonList.append(disclosurePerson.getPersonId());
					awardNewPerList=awardPersonList.toString();
					if (!hasCoiDisclosure(awardNumber,AWARD_MODULE_CODE,awardNewPerList) ) {
						disclosurePersons.add(disclosurePerson);
						return disclosurePersons;
					}
				}
			}
		}
		return disclosurePersons;
}

public boolean getTrainingRequired(Award award){

	String sponsorCode=award.getSponsorCode();
	String primeSponsorCode=award.getPrimeSponsorCode(); 
	String sponsorHeirarchy =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, SPONSOR_HEIRARCHY); 
	String sponsorHeirarchyLevelName =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, COI_SPONSOR_HEIRARCHY_LEVEL1); 
	if (getSponsorHierarchyService().isSponsorInHierarchy(sponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName) || 
			(primeSponsorCode!=null && getSponsorHierarchyService().isSponsorInHierarchy(primeSponsorCode, sponsorHeirarchy,1,sponsorHeirarchyLevelName))) {
		return true;
	}else{
		return false;
	}
}

public String getAwardDisclousureStatusForPerson(Award award,String personId) {
	List<Object> paramValues = new ArrayList<Object>();
	String result = "";	
	try{
		paramValues.add(0,award.getAwardNumber());
		paramValues.add(1,personId);
		result = getDbFunctionExecuteService()
				.executeFunction(
						"fn_get_award_disc_stat_for_per"
								+ this.getDBLink(), paramValues);
} catch (Exception ex) {
	LOGGER.log(Level.INFO, "Got exception:" + ex.getMessage());
	LOGGER.log(Level.ALL, ex.getMessage(), ex);
} finally {
	try {
		if (!result.isEmpty()) {
			LOGGER.log(Level.INFO,
					"Function Successfully Invoked");
		}
	} catch (Exception e) {
		LOGGER.log(Level.ALL, e.getMessage(), e);
	}
}
	return  result;

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
public void setParameterService(ParameterService parameterService) {
    this.parameterService = parameterService;
}

public DbFunctionExecuteService getDbFunctionExecuteService() {
	if (dbFunctionExecuteService == null) {
		dbFunctionExecuteService = KcServiceLocator.getService(DbFunctionExecuteService.class);
	}

	return dbFunctionExecuteService;
}

public void setDbFunctionExecuteService(DbFunctionExecuteService dbFunctionExecuteService) {
	this.dbFunctionExecuteService = dbFunctionExecuteService;
}

public SponsorHierarchyService getSponsorHierarchyService() {
	if (sponsorHierarchyService == null) {
		sponsorHierarchyService = KcServiceLocator.getService(SponsorHierarchyService.class);
	}
	return sponsorHierarchyService;
}
	
public void setSponsorHierarchyService(SponsorHierarchyService sponsorHierarchyService) {
	this.sponsorHierarchyService = sponsorHierarchyService;
}

public QuestionnaireAnswerService getQuestionnaireAnswerService() {
	if (questionnaireAnswerService == null) {
		questionnaireAnswerService = KcServiceLocator.getService(QuestionnaireAnswerService.class);
	}	
	return questionnaireAnswerService;
}

public void setQuestionnaireAnswerService(QuestionnaireAnswerService questionnaireAnswerService) {
	this.questionnaireAnswerService = questionnaireAnswerService;
}

public BusinessObjectService getBusinessObjectService() {
	if (businessObjectService == null) {
		businessObjectService = KcServiceLocator.getService(BusinessObjectService.class);
	}
	return businessObjectService;
}

public void setBusinessObjectService(BusinessObjectService businessObjectService) {
	this.businessObjectService = businessObjectService;
}
}
