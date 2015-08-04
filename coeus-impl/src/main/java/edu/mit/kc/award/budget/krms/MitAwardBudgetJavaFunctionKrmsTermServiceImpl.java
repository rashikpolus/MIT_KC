/**
 * 
 */
package edu.mit.kc.award.budget.krms;

import org.kuali.coeus.common.impl.krms.KcKrmsJavaFunctionTermServiceBase;
import org.kuali.kra.award.budget.AwardBudgetExt;


/**
 * @author kc-mit-dev
 * 
 */
public class MitAwardBudgetJavaFunctionKrmsTermServiceImpl extends
		KcKrmsJavaFunctionTermServiceBase implements
		MitAwardBudgetJavaFunctionKrmsTermService {
	
	

	@Override
	public String allAwardBudgetRule(AwardBudgetExt awardBudgetExt) {
		 return TRUE;
	}
	
}