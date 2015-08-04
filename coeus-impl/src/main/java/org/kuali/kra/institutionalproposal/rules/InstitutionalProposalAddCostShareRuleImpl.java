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
package org.kuali.kra.institutionalproposal.rules;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.bo.CostShareType;
import org.kuali.coeus.common.framework.costshare.CostShareRuleResearchDocumentBase;
import org.kuali.coeus.common.framework.unit.UnitService;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalCostShare;
import org.kuali.coeus.sys.api.model.ScaleTwoDecimal;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.MessageMap;

import edu.mit.kc.infrastructure.KcMitConstants;


import java.util.HashMap;
import java.util.Map;

public class InstitutionalProposalAddCostShareRuleImpl extends CostShareRuleResearchDocumentBase implements
        InstitutionalProposalAddCostShareRule {

    private InstitutionalProposalCostShare institutionalProposalCostShare;
    private String fieldStarter = "";
    private boolean displayNullFieldErrors = true;
    private int SOURCE_ACCOUNT_LIMIT = 7;
    
    @Override
    public boolean processAddInstitutionalProposalCostShareBusinessRules(InstitutionalProposalAddCostShareRuleEvent institutionalProposalAddCostShareRuleEvent) {
        this.fieldStarter = "institutionalProposalCostShareBean.newInstitutionalProposalCostShare";
        this.displayNullFieldErrors = true;
        return proccessRules(institutionalProposalAddCostShareRuleEvent);
    }
    
    @Override
    public boolean processInstitutionalProposalCostShareBusinessRules(InstitutionalProposalAddCostShareRuleEvent institutionalProposalAddCostShareRuleEvent, int i) {
        this.fieldStarter = "document.institutionalProposalList[0].institutionalProposalCostShares["  + i + "]";
        this.displayNullFieldErrors = false;
        return proccessRules(institutionalProposalAddCostShareRuleEvent);
    }
    
    private boolean proccessRules(InstitutionalProposalAddCostShareRuleEvent institutionalProposalAddCostShareRuleEvent) {
        this.institutionalProposalCostShare = institutionalProposalAddCostShareRuleEvent.getCostShareForValidation();
        
        boolean isValid = processCommonValidations(institutionalProposalCostShare);
        
        // test if percentage is valid
        isValid &= validatePercentage(institutionalProposalCostShare.getCostSharePercentage());
        
        // test if type is selected and valid
        isValid &= validateCostShareType(institutionalProposalCostShare.getCostShareTypeCode());
        
        // test if commitment amount is entered and valid
        isValid &= validateAmount(institutionalProposalCostShare.getAmount());
        
        isValid &= validateSourceAccount(institutionalProposalCostShare.getSourceAccount());
        
        isValid &=validateCostShareUnit(institutionalProposalCostShare.getUnit());
        
        return isValid;
    }
    
    /**
     * This method processes common validations for business rules
     * @param event
     * @return
     */
    public boolean processCommonValidations(InstitutionalProposalCostShare institutionalProposalCostShare) {
        boolean validFiscalYearRange = validateCostShareFiscalYearRange(institutionalProposalCostShare);
        
        return validFiscalYearRange;
    }
    
   /**
    *
    * Test fiscal year for valid range.
    * @param AwardCostShare, ErrorMap
    * @return Boolean
    */
    public boolean validateCostShareFiscalYearRange(InstitutionalProposalCostShare institutionalProposalCostShare){
        String projectPeriodField = this.fieldStarter + ".projectPeriod";
        return this.validateProjectPeriod(institutionalProposalCostShare.getProjectPeriod(), projectPeriodField);
    }
    
    /*
    private String getProjectPeriodLabel() {
        String label = KcServiceLocator.getService(CostShareService.class).getCostShareLabel();
        return label;
    }*/

    private boolean validatePercentage(ScaleTwoDecimal percentage) {
        boolean isValid = true;
        String costSharePercentageField = this.fieldStarter + ".costSharePercentage";
        if (percentage != null && percentage.isLessThan(new ScaleTwoDecimal(0))) {
            isValid = false;
            this.reportError(costSharePercentageField, KeyConstants.ERROR_COST_SHARE_PERCENTAGE_RANGE);
        }
        return isValid;
    }
    
    private boolean validateCostShareType(Integer costShareTypeCode) {
        boolean isValid = true;
        String costShareTypeCodeField = this.fieldStarter + ".costShareTypeCode";
        if (costShareTypeCode == null) {
            isValid = false;
            if (displayNullFieldErrors) {
                this.reportError(costShareTypeCodeField, KeyConstants.ERROR_IP_COST_SHARE_TYPE_REQUIRED);
            }
        } else {
            BusinessObjectService businessObjectService = KcServiceLocator.getService(BusinessObjectService.class);
            Map<String,Integer> fieldValues = new HashMap<String,Integer>();
            fieldValues.put("costShareTypeCode", costShareTypeCode);
            if (businessObjectService.countMatching(CostShareType.class, fieldValues) != 1) {
                isValid = false;
                this.reportError(costShareTypeCodeField, KeyConstants.ERROR_IP_COST_SHARE_TYPE_INVALID, new String[] { costShareTypeCode.toString() });
            }
        }
        return isValid;
    }

    private boolean validateAmount(ScaleTwoDecimal commitmentAmount) {
        boolean isValid = true;
        String commitmentAmountField = this.fieldStarter + ".amount";
        if (commitmentAmount == null) {
        	isValid = false;
            this.reportError(commitmentAmountField, KeyConstants.ERROR_IP_COST_SHARE_COMMITMENT_AMOUNT_REQUIRED);
        } else if (commitmentAmount.isLessThan(new ScaleTwoDecimal(0))) {
            isValid = false;
            this.reportError(commitmentAmountField, KeyConstants.ERROR_IP_COST_SHARE_COMMITMENT_AMOUNT_INVALID, new String[] { commitmentAmount.toString() });
        }
        return isValid;
    }
    
    private boolean validateSourceAccount(String sourceAccount) {
        boolean isValid = true;
        String sourceAccountField = this.fieldStarter + ".sourceAccount";
        if (StringUtils.isEmpty(sourceAccount)) {
            isValid = false;
            if (displayNullFieldErrors) {
                this.reportError(sourceAccountField, KeyConstants.ERROR_IP_COST_SHARE_SOURCE_ACCOUNT_REQUIRED);
            }
        } else if(sourceAccount.toString().length() > SOURCE_ACCOUNT_LIMIT) {
        	if (displayNullFieldErrors) {
        		isValid = false;
            	this.reportError(sourceAccountField, KcMitConstants.ERROR_IP_COST_SHARE_SOURCE_ACCOUNT_LIMIT_EXCEEDS);
        	}
          }
        
        return isValid;
    }
    
    private boolean validateCostShareUnit(String unitNumber) {
        boolean valid = true;
           
            //check if the unit is valid
        MessageMap errorMap = GlobalVariables.getMessageMap();
           
           
            if (StringUtils.isNotEmpty(unitNumber)) {
            	UnitService unitService = KcServiceLocator.getService(UnitService.class);
           	
            	if (unitService.getUnit(unitNumber) == null) {
                	valid = false;
                //	errorMap.putError("unitNumber", IUKeyConstants.ERROR_INVALID_COST_SHARE_UNIT, unitNumber);
                    this.reportError(fieldStarter + ".unit", KeyConstants.ERROR_INVALID_COST_SHARE_UNIT, unitNumber);
            	}       
            } else {
                if (displayNullFieldErrors) {
            	  valid = false;
                  this.reportError(fieldStarter + ".unit", KeyConstants.ERROR_REQUIRED_COST_SHARE_UNIT, unitNumber);
                }
           }
            /* IU Customization Ends */
            
        
        return valid;
   }
}