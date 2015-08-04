package org.kuali.kra.institutionalproposal.distribution;

import java.util.ArrayList;
import java.util.List;

import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.institutionalproposal.document.InstitutionalProposalDocument;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalCostShare;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.rules.rule.DocumentAuditRule;
import org.kuali.rice.krad.util.AuditCluster;
import org.kuali.rice.krad.util.AuditError;
import org.kuali.rice.krad.util.GlobalVariables;

public class InstitutionalProposalCostShareAuditRule implements DocumentAuditRule {
	
	private List<AuditError> auditErrors;
	private static final String COST_SHARE_AUDIT_ERRORS = "costShareAuditErrors";
	private static final int SOURCE_ACCOUNT_LIMIT = 7;
	public static final String INSTITUTIONAL_PROPOSAL_COST_SHARE_LIST_ERROR_KEY = "document.institutionalProposalList[0].institutionalProposalCostShares.auditErrors";
	public static final String ERROR_INSTITUTIONAL_PROPOSAL_COST_SHARE = "error.institutionalProposalCostShare.sourceamount.exceeds";

	@Override
    public boolean processRunAuditBusinessRules(Document document) {
        boolean valid = true;
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument)document;
        auditErrors = new ArrayList<AuditError>();
        valid &= checkCostShareSourceAccount(institutionalProposalDocument.getInstitutionalProposal().getInstitutionalProposalCostShares());
        reportAndCreateAuditCluster();
        
        return valid;
    }
	
	protected void reportAndCreateAuditCluster() {
        if (auditErrors.size() > 0) {
            GlobalVariables.getAuditErrorMap().put(COST_SHARE_AUDIT_ERRORS, new AuditCluster(Constants.COST_SHARE_PANEL_NAME,
                                                                                          auditErrors, Constants.AUDIT_ERRORS));
        }
    }
	
	protected boolean checkCostShareSourceAccount(List<InstitutionalProposalCostShare> institutionalProposalCostShareList) {
        boolean valid = true;
        for(InstitutionalProposalCostShare institutionalProposalCostShare:institutionalProposalCostShareList) {
        	if(institutionalProposalCostShare.getSourceAccount().toString() !=null &&
        			institutionalProposalCostShare.getSourceAccount().toString().length() > SOURCE_ACCOUNT_LIMIT) {
        		    valid = false;
        		    auditErrors.add(new AuditError(INSTITUTIONAL_PROPOSAL_COST_SHARE_LIST_ERROR_KEY, ERROR_INSTITUTIONAL_PROPOSAL_COST_SHARE,                    
                        Constants.MAPPING_INSTITUTIONAL_PROPOSAL_DISTRIBUTION_PAGE + "." + Constants.COST_SHARE_PANEL_ANCHOR));
        	}
        }
        return valid;
    }

}
