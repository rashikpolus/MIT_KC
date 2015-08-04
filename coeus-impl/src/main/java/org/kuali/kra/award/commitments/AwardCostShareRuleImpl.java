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
package org.kuali.kra.award.commitments;

import org.apache.commons.lang.StringUtils;
import org.kuali.kra.bo.CostShareType;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.coeus.common.framework.costshare.CostShareRuleResearchDocumentBase;
import org.kuali.coeus.common.framework.unit.UnitService;
import org.kuali.coeus.sys.api.model.ScaleTwoDecimal;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.util.type.KualiDecimal;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.MessageMap;

import edu.mit.kc.infrastructure.KcMitConstants;

import java.util.HashMap;
import java.util.Map;

/**
 * This class...
 */
public class AwardCostShareRuleImpl extends CostShareRuleResearchDocumentBase implements AwardCostShareRule {

    
    //private static final String NEW_AWARD_COST_SHARE = "costShareFormHelper.newAwardCostShare";
    private AwardCostShare awardCostShare;
    private String fieldStarter = "";
    
    /**
     * @see org.kuali.kra.award.commitments.AwardCostShareRule#processCostShareBusinessRules
     * (org.kuali.kra.award.commitments.AwardCostShareRuleEvent)
     */
    public boolean processCostShareBusinessRules(AwardCostShareRuleEvent awardCostShareRuleEvent, int i) {
        this.fieldStarter = "document.awardList[0].awardCostShares[" + i + "]";
        this.awardCostShare = awardCostShareRuleEvent.getCostShareForValidation();
        return processCommonValidations(awardCostShare);
    }
    
    /**
     * This method checks the Cost Share fields for validity.
     * @param awardCostShareRuleEvent
     * @return true if valid, false otherwise
     */
    public boolean processAddCostShareBusinessRules(AwardCostShareRuleEvent awardCostShareRuleEvent) {
        this.awardCostShare = awardCostShareRuleEvent.getCostShareForValidation();
        this.fieldStarter = "costShareFormHelper.newAwardCostShare";
        boolean isValid = processCommonValidations(awardCostShare);
     // test if source is valid
        isValid &= validateSource(awardCostShare);
     // test if destination is valid
        isValid &= validateDestination(awardCostShare);
     // test if source limit is valid
        isValid &= validateSourceLimit(awardCostShare);
     // test if destination limit is valid
        isValid &= validateDestinationLimit(awardCostShare);
        // test if percentage is valid
        isValid &= validatePercentage(awardCostShare.getCostSharePercentage());
        
        // test if type is selected and valid
        isValid &= validateCostShareType(awardCostShare.getCostShareTypeCode());
        
        // test if commitment amount is entered and valid
        isValid &= validateCommitmentAmount(awardCostShare.getCommitmentAmount());
        
        // test if cost share met is valid
        isValid &= validateCostShareMet(awardCostShare.getCostShareMet());
        
       
        
        return isValid;
    }
    
    /**
     * This method processes common validations for business rules
     * @param event
     * @return
     */
    public boolean processCommonValidations(AwardCostShare awardCostShare) {        
        boolean validSourceAndDestination = validateCostShareSourceAndDestinationForEquality(awardCostShare);
        boolean validFiscalYearRange = validateCostShareFiscalYearRange(awardCostShare);  
          return validSourceAndDestination && validFiscalYearRange;
    }
    
    /**
    *
    * Test source and destination for equality in AwardCostShare.
    * @param AwardCostShare, MessageMap
    * @return Boolean
    */
    public boolean validateCostShareSourceAndDestinationForEquality(AwardCostShare awardCostShare){
        boolean valid = true;
          if (awardCostShare.getSource() != null && awardCostShare.getDestination() != null) {
            if (awardCostShare.getSource().equals(awardCostShare.getDestination())) {
                valid = false;
                reportError(fieldStarter + ".source", KeyConstants.ERROR_SOURCE_DESTINATION);
            }
        }
       return valid;
    }
    
    private boolean validateSource(AwardCostShare awardCostShare) {
        boolean isValid = true;
        String sourceField = fieldStarter + ".source";
        if (awardCostShare.getSource() == null) {
            isValid = false;
            this.reportError(sourceField, KcMitConstants.ERROR_COST_SHARE_SOURCE);
        } 
       
        return isValid;
    }
    
    private boolean validateDestination(AwardCostShare awardCostShare) {
        boolean isValid = true;
        String destinationField = fieldStarter + ".destination";
        if (awardCostShare.getDestination() == null) {
            isValid = false;
            this.reportError(destinationField, KcMitConstants.ERROR_COST_SHARE_DESTINATION);
        } 
       
        return isValid;
    }
    /**
     * This method checks while adding or saving,whether the source account crossed the limit
     * @param awardCostShare
     * @return
     */
    private boolean validateSourceLimit(AwardCostShare awardCostShare) {
        boolean isValid = true;
        String sourceField = fieldStarter + ".source";
        if (awardCostShare.getSource() != null && awardCostShare.getSource().toString().length()>7) {
            isValid = false;
            this.reportError(sourceField, KcMitConstants.ERROR_COST_SHARE_SOURCE_LIMIT);
        } 
       
        return isValid;
    }
    
    /**
     * This method checks while adding or saving,whether the destination account crossed the limit
     * @param awardCostShare
     * @return
     */
    private boolean validateDestinationLimit(AwardCostShare awardCostShare) {
        boolean isValid = true;
        String destinationField = fieldStarter + ".destination";
        if (awardCostShare.getDestination() != null && awardCostShare.getDestination().toString().length()>7) {
            isValid = false;
            this.reportError(destinationField, KcMitConstants.ERROR_COST_SHARE_DESTINATION_LIMIT);
        } 
       
        return isValid;
    }
    
   /**
    *
    * Test fiscal year for valid range.
    * @param AwardCostShare
    * @return Boolean
    */
    public boolean validateCostShareFiscalYearRange(AwardCostShare awardCostShare) {
        String projectPeriodField = fieldStarter + ".projectPeriod";
        //int numberOfProjectPeriods = 51;
        //return this.validateProjectPeriod(awardCostShare.getProjectPeriod(), projectPeriodField, numberOfProjectPeriods);
        return this.validateProjectPeriod(awardCostShare.getProjectPeriod(), projectPeriodField);
    }
    
    /*
    private String getProjectPeriodLabel() {
        String label = KcServiceLocator.getService(CostShareService.class).getCostShareLabel();
        return label;
    }*/

    private boolean validatePercentage(ScaleTwoDecimal percentage) {
        boolean isValid = true;
        if (percentage != null && percentage.isLessThan(new ScaleTwoDecimal(0))) {
            isValid = false;
            this.reportError(fieldStarter + ".costSharePercentage", KeyConstants.ERROR_COST_SHARE_PERCENTAGE_RANGE);
        }
        return isValid;
    }
    
    private boolean validateCostShareType(Integer costShareTypeCode) {
        boolean isValid = true;
        String costShareTypeCodeField = fieldStarter + ".costShareTypeCode";
        if (costShareTypeCode == null) {
            isValid = false;
            this.reportError(costShareTypeCodeField, KeyConstants.ERROR_COST_SHARE_TYPE_REQUIRED);
        } else {
            BusinessObjectService businessObjectService = KcServiceLocator.getService(BusinessObjectService.class);
            Map<String,Integer> fieldValues = new HashMap<String,Integer>();
            fieldValues.put("costShareTypeCode", costShareTypeCode);
            if (businessObjectService.countMatching(CostShareType.class, fieldValues) != 1) {
                isValid = false;
                this.reportError(costShareTypeCodeField, KeyConstants.ERROR_COST_SHARE_TYPE_INVALID, new String[] { costShareTypeCode.toString() });
            }
        }
        return isValid;
    }

    private boolean validateCommitmentAmount(ScaleTwoDecimal commitmentAmount) {
        boolean isValid = true;
        String commitmentAmountField = fieldStarter + ".commitmentAmount";
        if (commitmentAmount == null) {
            isValid = false;
            this.reportError(commitmentAmountField, KeyConstants.ERROR_COST_SHARE_COMMITMENT_AMOUNT_REQUIRED);
        } else if (commitmentAmount.isLessThan(new ScaleTwoDecimal(0))) {
            isValid = false;
            this.reportError(commitmentAmountField, KeyConstants.ERROR_COST_SHARE_COMMITMENT_AMOUNT_INVALID, new String[] { commitmentAmount.toString() });
        }
        return isValid;
    }

    private boolean validateCostShareMet(ScaleTwoDecimal costShareMet) {
        boolean isValid = true;
        if (costShareMet != null && costShareMet.isLessThan(new ScaleTwoDecimal(0))) {
            isValid = false;
            this.reportError(fieldStarter + ".costShareMet", KeyConstants.ERROR_COST_SHARE_MET_INVALID, new String[] { costShareMet.toString() });
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
                	errorMap.putError("unitNumber", KeyConstants.ERROR_INVALID_COST_SHARE_UNIT, unitNumber);
                //    this.reportError(fieldStarter + ".unitNumber", IUKeyConstants.ERROR_INVALID_COST_SHARE_UNIT, unitNumber);
           	}       
            } else {
            	valid = false;
                this.reportError(fieldStarter + ".unitNumber", KeyConstants.ERROR_REQUIRED_COST_SHARE_UNIT, unitNumber);
            	
            }
           
   
        return valid;
    }

    private boolean validateNotEmptyUnit(String unitNumber) {
        boolean valid = true;
            
            //check if the unit is valid           
            
            if (StringUtils.isEmpty(unitNumber)) {
            	valid = false;
                this.reportError(fieldStarter + ".unitNumber", KeyConstants.ERROR_REQUIRED_COST_SHARE_UNIT, unitNumber);
            	
            }
            
        
        return valid;
    }
}
