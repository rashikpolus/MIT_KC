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

import org.apache.commons.lang3.StringUtils;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.keywords.AwardScienceKeyword;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.rules.rule.DocumentAuditRule;
import org.kuali.rice.krad.util.AuditCluster;
import org.kuali.rice.krad.util.AuditError;
import org.kuali.rice.krad.util.GlobalVariables;

import edu.mit.kc.infrastructure.KcMitConstants;

import java.util.ArrayList;
import java.util.List;

public class AwardCostShareAuditRule implements DocumentAuditRule {
    private static final String AUDIT_CLUSTER = "costShareAuditErrors";
    private String fieldStarter = "";   
    private List<AuditError> auditErrors;
    
    public boolean processRunAuditBusinessRules(Document document) {
        boolean retval = true;
        AwardDocument awardDocument = (AwardDocument)document;
        Award award = awardDocument.getAward();
        retval &= validateCostShareDoesNotViolateUniqueConstraint(award.getAwardCostShares());
        retval &= validateDestination(award.getAwardCostShares());
        retval &= validateSource(award.getAwardCostShares());        
        retval &= validateDestinationLimit(award.getAwardCostShares());
        retval &= validateSourceLimit(award.getAwardCostShares());        
              if (!retval) {
            reportAndCreateAuditCluster();            
        }
        return retval;
    }
    
    /**
     * This method tests that the Cost Shares do not violate unique constraint on Database table.
     * @param awardCostShareRuleEvent
     * @param awardCostShare
     * @return
     */
    public boolean validateCostShareDoesNotViolateUniqueConstraint (List<AwardCostShare> awardCostShares) {
        boolean valid = true;
        for (AwardCostShare costShare1 : awardCostShares) {
            for (AwardCostShare costShare2 : awardCostShares) {
                if (costShare1 == costShare2) {
                    continue;
                } else if (StringUtils.equals(costShare1.getProjectPeriod(), costShare2.getProjectPeriod()) &&
                        costShare1.getCostShareTypeCode().equals(costShare2.getCostShareTypeCode()) &&
                            StringUtils.equalsIgnoreCase(costShare1.getSource(), costShare2.getSource()) &&
                                StringUtils.equalsIgnoreCase(costShare1.getDestination(), costShare2.getDestination())) {
                    valid = false;
                    addAuditError(new AuditError("document.awardList[0].awardCostShares["+awardCostShares.indexOf(costShare1)+"].fiscalYear", 
                            KeyConstants.ERROR_DUPLICATE_ENTRY,
                            Constants.MAPPING_AWARD_COMMITMENTS_PAGE+"."+Constants.COST_SHARE_PANEL_ANCHOR));
                }
            }
        }
        return valid;
    }

    private void addAuditError(AuditError auditError) {
        if(auditErrors == null) {
            auditErrors = new ArrayList<AuditError>();            
        }
        auditErrors.add(auditError);
    }
    /**
     * 
     * This method checks whether cost share destination fields are entered or not
     * @param awardFandaRate
     * @param propertyPrefix
     * @return
     */
    private boolean validateDestination(List<AwardCostShare> awardCostShares) {
        boolean isValid = true;
        String destinationField = fieldStarter + ".destination";
        for(AwardCostShare awardCostShare:awardCostShares){
        	 if (awardCostShare.getDestination() == null) {
                 isValid = false;
                 addAuditError(new AuditError("document.awardList[0].awardCostShares["+awardCostShares.indexOf(awardCostShare)+"].destination", 
                		 KcMitConstants.ERROR_COST_SHARE_DESTINATION,
                         Constants.MAPPING_AWARD_COMMITMENTS_PAGE+"."+Constants.COST_SHARE_PANEL_ANCHOR));        		 
                		
             } 	
        }
       
       
        return isValid;
    }
    /**
     * 
     * This method checks whether cost share source fields are entered or not
     * @param awardFandaRate
     * @param propertyPrefix
     * @return
     */
    private boolean validateSource(List<AwardCostShare> awardCostShares) {
        boolean isValid = true;
        String destinationField = fieldStarter + ".source";
        for(AwardCostShare awardCostShare:awardCostShares){
        	 if (awardCostShare.getSource() == null) {
                 isValid = false;
                 addAuditError(new AuditError("document.awardList[0].awardCostShares["+awardCostShares.indexOf(awardCostShare)+"].source", 
                		 KcMitConstants.ERROR_COST_SHARE_SOURCE,
                         Constants.MAPPING_AWARD_COMMITMENTS_PAGE+"."+Constants.COST_SHARE_PANEL_ANCHOR));        		 
                		
             } 	
        }
       
       
        return isValid;
    }
    private boolean validateAwardTransactionType(Award award) {
        boolean isValid = true;   
        
       if(award.getAwardTransactionType()==null) {
           addAuditError(new AuditError("document.awardList[0].awardTransactionTypeCode",KcMitConstants.ERROR_AWARD_TRANSACTION_TYPE,Constants.MAPPING_AWARD_HOME_PAGE ));
                    isValid = false;
                }
            
        
        return isValid;
    }
    /**
     * This method creates and adds the AuditCluster to the Global AuditErrorMap.
     */
    @SuppressWarnings("unchecked")
    protected void reportAndCreateAuditCluster() {
        if (auditErrors.size() > 0) {
            GlobalVariables.getAuditErrorMap().put(AUDIT_CLUSTER, new AuditCluster(Constants.COST_SHARE_PANEL_NAME, auditErrors, Constants.AUDIT_ERRORS));
        }
    }
    /**
     * This method checks whether the source account exceeded the limit.
     * @param awardCostShares
     * @return
     */
    private boolean validateSourceLimit(List<AwardCostShare> awardCostShares) {
        boolean isValid = true;
        for(AwardCostShare awardCostShare:awardCostShares){
        	 if (awardCostShare.getSource() != null && awardCostShare.getSource().toString().length()>7) {
                 isValid = false;
                 addAuditError(new AuditError("document.awardList[0].awardCostShares["+awardCostShares.indexOf(awardCostShare)+"].source", 
                		 KcMitConstants.ERROR_COST_SHARE_SOURCE_LIMIT,
                         Constants.MAPPING_AWARD_COMMITMENTS_PAGE+"."+Constants.COST_SHARE_PANEL_ANCHOR));        		 
             } 	
        }
		return isValid;
}
    /**
     * This method checks whether the destination account exceeded the limit.
     * @param awardCostShares
     * @return
     */
    private boolean validateDestinationLimit(List<AwardCostShare> awardCostShares) {
        boolean isValid = true;
        for(AwardCostShare awardCostShare:awardCostShares){
        	 if (awardCostShare.getDestination() != null && awardCostShare.getDestination().toString().length()>7) {
                 isValid = false;
                 addAuditError(new AuditError("document.awardList[0].awardCostShares["+awardCostShares.indexOf(awardCostShare)+"].destination", 
                		 KcMitConstants.ERROR_COST_SHARE_DESTINATION_LIMIT,
                         Constants.MAPPING_AWARD_COMMITMENTS_PAGE+"."+Constants.COST_SHARE_PANEL_ANCHOR));        		 
             } 	
        }
        return isValid;
    }
}