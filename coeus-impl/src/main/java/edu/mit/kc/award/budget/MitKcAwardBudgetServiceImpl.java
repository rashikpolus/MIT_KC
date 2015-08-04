package edu.mit.kc.award.budget;

import org.apache.commons.lang3.StringUtils;
import org.kuali.kra.award.budget.AwardBudgetExt;
import org.kuali.kra.award.budget.AwardBudgetServiceImpl;
import org.kuali.kra.award.budget.document.AwardBudgetDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.rice.krad.util.GlobalVariables;

import edu.mit.kc.infrastructure.KcMitConstants;

public class MitKcAwardBudgetServiceImpl extends AwardBudgetServiceImpl{
	
    private final static String BUDGET_VERSION_ERROR_PREFIX = "document.parentDocument.budgetDocumentVersion";

	@Override
	public void toggleStatus(AwardBudgetDocument awardBudgetDocument) {
		   String currentStatusCode = awardBudgetDocument.getAwardBudget().getAwardBudgetStatusCode();
	        if (currentStatusCode.equals(getParameterValue(KeyConstants.AWARD_BUDGET_STATUS_POSTED))) {
	            processStatusChange(awardBudgetDocument,KcMitConstants.AWARD_BUDGET_STATUS_REPOSTED);
	        }
	       
	        saveDocument(awardBudgetDocument);
	}
	
    public boolean checkForOutstandingBudgets(Award award) {
        boolean result = false;
        
        for (AwardBudgetExt awardBudget : award.getBudgets()) {
            if (!(StringUtils.equals(awardBudget.getAwardBudgetStatusCode(), getPostedBudgetStatus())
                    || StringUtils.equals(awardBudget.getAwardBudgetStatusCode(), getRejectedBudgetStatus())
                    || StringUtils.equals(awardBudget.getAwardBudgetStatusCode(), getCancelledBudgetStatus())
                    || StringUtils.equals(awardBudget.getAwardBudgetStatusCode(), getRePostedBudgetStatus()))) {
                result = true;
                GlobalVariables.getMessageMap().putError(BUDGET_VERSION_ERROR_PREFIX, 
                        KeyConstants.ERROR_AWARD_UNFINALIZED_BUDGET_EXISTS, (StringUtils.isBlank(awardBudget.getName()) ? "UNNAMED" : awardBudget.getName()));
            }
        }
        
        return result;
    }
    
    
    protected String getRePostedBudgetStatus() {
        return getParameterValue(KcMitConstants.AWARD_BUDGET_STATUS_REPOSTED);
    }
 
}
