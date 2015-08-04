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


import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.sys.framework.rule.KcTransactionalDocumentRuleBase;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachments;

public class InstitutionalProposalAddAttachmentRuleImpl extends KcTransactionalDocumentRuleBase implements InstitutionalProposalAddAttachmentRule {

    @Override
    public boolean processAddInstitutionalProposalAttachmentBusinessRules(InstitutionalProposalAddAttachmentRuleEvent institutionalProposalRuleEvent) {
        InstitutionalProposalAttachments proposalAttachment = institutionalProposalRuleEvent.getInstitutionalProposalForValidation();
        boolean valid=true;
        if( proposalAttachment.getAttachmentTypeCode()  == null ) {
            valid = false;
            if(!proposalAttachment.isModifyAttachment()) {
                reportError("institutionalProposalAttachmentBean.newAttachment.attachmentTypeCode", KeyConstants.INSTITUTIONAL_PROPOSAL_ATTACHMENT_TYPE_CODE_REQUIRED);
            }
        }
        
        if((proposalAttachment.getFile() == null) && (proposalAttachment.getNewFile() == null || StringUtils.isEmpty(proposalAttachment.getNewFile().getFileName()))) {
            valid = false;
            reportError("institutionalProposalAttachmentBean.newAttachment.newFile", KeyConstants.INSTITUTIONAL_PROPOSAL_ATTACHMENT_FILE_REQUIRED);
        }
        return valid;
    }
    
    @Override
    public boolean processAddInstitutionalProposalAttachment(InstitutionalProposalAddAttachmentRuleEvent institutionalProposalRuleEvent,int i) {
        InstitutionalProposalAttachments proposalAttachment = institutionalProposalRuleEvent.getInstitutionalProposalDocument().getInstitutionalProposal().getInstProposalAttachment(i);
        boolean valid=true;
        if( proposalAttachment.getAttachmentTypeCode()  == null ) {
            valid = false;
            reportError("document.institutionalProposalList[0].instProposalAttachments["+i+"].attachmentTypeCode", KeyConstants.INSTITUTIONAL_PROPOSAL_ATTACHMENT_TYPE_CODE_REQUIRED);
        }
         return valid;
    }
    
    
}