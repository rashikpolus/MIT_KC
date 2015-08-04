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
package org.kuali.kra.award;

import org.apache.commons.lang.StringUtils;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import edu.mit.kc.award.service.AwardCommonValidationService;
import edu.mit.kc.infrastructure.KcMitConstants;

import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.rules.rule.DocumentAuditRule;
import org.kuali.rice.krad.util.AuditCluster;
import org.kuali.rice.krad.util.AuditError;
import org.kuali.rice.krad.util.GlobalVariables;

import java.util.ArrayList;
import java.util.List;

public class AwardCommonValidationAuditRule implements DocumentAuditRule {
	private List<AuditError> auditWarnings = new ArrayList<AuditError>();
	private List<AuditError> auditWarnings1 = new ArrayList<AuditError>();
	private List<AuditError> auditWarnings2 = new ArrayList<AuditError>();
	private List<AuditError> auditWarnings3 = new ArrayList<AuditError>();
	private List<AuditError> auditWarnings5 = new ArrayList<AuditError>();
	   private ParameterService parameterService;	
	   private AwardCommonValidationService awardCommonValidationService;
	   private String HOLD_PROMPT ="Hold Prompt";
	   private Integer Hold_Status=6;
	   private String SPECIAL_REVIEW_PANEL="Special Review";
	public boolean processRunAuditBusinessRules(Document document) {
		 String link = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
	      String errorKey = "document.awardList[0].statusCode";
	boolean retval = true;
	boolean retvalSponsor = true;
	boolean retvalSpReview = true;
	boolean retvalReports =true;
	boolean retvalTerm =true;
	boolean retvalCoi =true;
	boolean retvalTraining =true;
	  AwardDocument awardDocument = (AwardDocument)document;
	 Award award = awardDocument.getAward();
	 Integer status=award.getStatusCode();
	boolean awardHoldPromptEnabled = getParameterService().getParameterValueAsBoolean(
             "KC-AWARD", "Document", "ENABLE_AWARD_VALIDATIONS");
	if(awardHoldPromptEnabled && status!=6){
//	retvalSponsor &= getAwardCommonValidationService().validateSponsorCodeIsNIH(award);
	 retvalSpReview &= getAwardCommonValidationService().validateSpecialReviews(award);
	 retvalReports &= getAwardCommonValidationService().validateReports(award);
	 retvalTerm &= getAwardCommonValidationService().validateAwardTerm(award);
	 retvalCoi &=getAwardCommonValidationService().validateAwardOnCOI(award);
	 if(retvalCoi){
		 retvalCoi &=getAwardCommonValidationService().validateTrainingRequirements(award);
	 }
	 
	}else{
		retval = true;
	}
	 if (!retvalSpReview) {
	    	String link4 = Constants.MAPPING_AWARD_SPECIAL_REVIEW_PAGE + "." + "SpecialReview";
	        String messageKey = KcMitConstants.ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW_MAIN;
	        String errorKey4 ="specialReviewHelper.newSpecialReview*";
	    	auditWarnings.add(new AuditError(errorKey4, messageKey, link4));
	    	 if (auditWarnings.size() > 0) {
		            GlobalVariables.getAuditErrorMap().put("specialReviewAuditWarnings",new AuditCluster(SPECIAL_REVIEW_PANEL, auditWarnings, HOLD_PROMPT)); 
		             retval=false;
		        }             
	     }
    if (!retvalReports) {
    	String link1 = Constants.MAPPING_AWARD_PAYMENT_REPORTS_AND_TERMS_PAGE + "." + Constants.REPORTS_PANEL_ANCHOR;
        String messageKey1 = KcMitConstants.ERROR_AWARD_HOLD_PROMPT_REPORT_TERM;
        String errorkey1="document.awardList[0].awardReportTermItems";
        auditWarnings1.add(new AuditError(errorkey1, messageKey1, link1));
    	 if (auditWarnings1.size() > 0) {
	           GlobalVariables.getAuditErrorMap().put("reportsAuditWarnings",new AuditCluster(Constants.REPORTS_PANEL_NAME, auditWarnings1, HOLD_PROMPT));     		
	            retval=false;
	        }             
     }
    if (!retvalTerm) {
    	 String link3 = Constants.MAPPING_AWARD_PAYMENT_REPORTS_AND_TERMS_PAGE + "." + Constants.TERMS_PANEL_ANCHOR;
	      String errorKey3 = "document.awardList[0].awardSponsorTerms*";
    	auditWarnings3.add(new AuditError(errorKey3, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_TERM_AND_SP_REV, link3));
    	 if (auditWarnings3.size() > 0) {
	            GlobalVariables.getAuditErrorMap().put("termsAuditWarnings",new AuditCluster(Constants.TERMS_PANEL_NAME, auditWarnings3, HOLD_PROMPT));
    		     retval=false;
	        }             
     }
    if (!retvalSponsor) {
   	 String link2 = Constants.MAPPING_AWARD_HOME_PAGE + "." + Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_ANCHOR;
	      String errorKey2 = "document.awardList[0].statusCode";
   	auditWarnings2.add(new AuditError(errorKey2, KcMitConstants.ERROR_AWARD_HOLD_PROMPT_SPONSOR_CODE, link2));
   	 if (auditWarnings2.size() > 0) {
	            GlobalVariables.getAuditErrorMap().put("homePageAuditWarnings",new AuditCluster(Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_NAME, auditWarnings2, HOLD_PROMPT)); 
	            retval=false;
	        }             
    }
    if (!retvalCoi){
    	 String link5 = Constants.MAPPING_AWARD_CONTACTS_PAGE + "." + Constants.CONTACTS_PANEL_ANCHOR;
	      String errorKey5 = "document.awardList[0].projectPersons";
  	auditWarnings5.add(new AuditError(errorKey5, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_INV, link5));
  	if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP)!=null){
  		auditWarnings5.add(new AuditError(errorKey5, KcMitConstants.ERROR_AWARD_HOLD_NO_DISC_KP, link5));
  	}if(GlobalVariables.getMessageMap().getWarningMessagesForProperty(KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED)!=null){
  		auditWarnings5.add(new AuditError(errorKey5, KcMitConstants.ERROR_AWARD_HOLD_KP_NOT_CONFIRMED, link5));
  	}
  	 if (auditWarnings5.size() > 0) {
	            GlobalVariables.getAuditErrorMap().put("contactsAuditWarnings",new AuditCluster(Constants.MAPPING_AWARD_CONTACTS_PAGE, auditWarnings5, HOLD_PROMPT)); 
	            retval=false;
	        }  
    }
	return retval;
	}
	
	   private AwardCommonValidationService getAwardCommonValidationService() {
	        if( awardCommonValidationService == null ) {
	            awardCommonValidationService = KcServiceLocator.getService(AwardCommonValidationService.class);
	        }
	        return awardCommonValidationService;
	    }

	  protected void reportAndCreateAuditCluster() {		;
	        if (auditWarnings.size() > 0) {
	            GlobalVariables.getAuditErrorMap().put("homePageAuditWarnings",new AuditCluster(Constants.MAPPING_AWARD_HOME_DETAILS_AND_DATES_PAGE_NAME, auditWarnings, HOLD_PROMPT));            
	        }  	       
	    
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
	    }