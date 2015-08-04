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
package org.kuali.kra.institutionalproposal.rules;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.kuali.coeus.sys.framework.rule.KcDocumentEventBase;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachments;
import org.kuali.kra.institutionalproposal.document.InstitutionalProposalDocument;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalCostShare;
import org.kuali.rice.krad.rules.rule.BusinessRule;


public class InstitutionalProposalAddAttachmentRuleEvent extends KcDocumentEventBase {

private static final Log LOG = LogFactory.getLog(InstitutionalProposalAddCostShareRuleEvent.class);
    
    private InstitutionalProposalAttachments institutionalProposalAttachment;

    public InstitutionalProposalAddAttachmentRuleEvent(String errorPathPrefix, 
            InstitutionalProposalDocument institutionalProposalDocument,
            InstitutionalProposalAttachments institutionalProposalAttachment) {
        super("Institutional Proposal", errorPathPrefix, institutionalProposalDocument);
        this.institutionalProposalAttachment = institutionalProposalAttachment;
    }
    
    /**
     * Convenience method to return an InstitutionalProposalDocument
     * @return
     */
    public InstitutionalProposalDocument getInstitutionalProposalDocument() {
        return (InstitutionalProposalDocument) getDocument();
    }
    
    /**
     * This method returns the equipment item for validation
     * @return
     */
    public InstitutionalProposalAttachments getInstitutionalProposalForValidation() {
        return institutionalProposalAttachment;
    }
    
    
    @Override
    protected void logEvent() {
        LOG.info("Logging InstitutionalProposalAttachmentRuleEvent");
    }

    @Override
    @SuppressWarnings("unchecked")
    public Class getRuleInterfaceClass() {
        return InstitutionalProposalAddAttachmentRule.class;
    }

    @Override
    public boolean invokeRuleMethod(BusinessRule rule) {
        return ((InstitutionalProposalAddAttachmentRule)rule).processAddInstitutionalProposalAttachmentBusinessRules(this);
    }

}
