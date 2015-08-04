package edu.mit.kc.institutionalproposal.rules;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.api.sponsor.SponsorService;
import org.kuali.coeus.common.framework.custom.KcDocumentBaseAuditRule;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachments;
import org.kuali.kra.institutionalproposal.contacts.InstitutionalProposalCreditSplitBean;
import org.kuali.kra.institutionalproposal.contacts.InstitutionalProposalPersonAuditRule;
import org.kuali.kra.institutionalproposal.contacts.InstitutionalProposalPersonSaveRuleEvent;
import org.kuali.kra.institutionalproposal.contacts.InstitutionalProposalPersonSaveRuleImpl;
import org.kuali.kra.institutionalproposal.distribution.InstitutionalProposalCostShareAuditRule;
import org.kuali.kra.institutionalproposal.document.InstitutionalProposalDocument;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalCostShare;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalScienceKeyword;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalUnrecoveredFandA;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalAddAttachmentRuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalAddAttachmentRuleImpl;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalAddCostShareRuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalAddCostShareRuleImpl;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalDocumentRule;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalFinancialRuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalFinancialRuleImpl;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalRuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalRuleImpl;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalSaveUnrecoveredFandARuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalSponsorAndProgramRuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalUnrecoveredFandARuleImpl;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.document.TransactionalDocument;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;
import org.kuali.rice.krad.util.MessageMap;



public class MitInstitutionalProposalDocumentRule extends InstitutionalProposalDocumentRule {
	

    @Override
    protected boolean processCustomSaveDocumentBusinessRules(Document document) {
        boolean retval = true;
        MessageMap errorMap = GlobalVariables.getMessageMap();
        if (!(document instanceof InstitutionalProposalDocument)) {
            return false;
        }
        
        retval &= processUnrecoveredFandABusinessRules(document);
        retval &= processSponsorProgramBusinessRule(document);
        retval &= processInstitutionalProposalBusinessRules(document);
        retval &= processInstitutionalProposalFinancialRules(document);
        retval &= processInstitutionalProposalPersonBusinessRules(errorMap, document);
        retval &= processKeywordBusinessRule(document);
        //retval &= processAccountIdBusinessRule(document);
        retval &= processCostShareRules(document);
        retval &= validateSponsors(document);
        retval &= processInstitutionalProposalAttachmentsBusinessRules(document);
        return retval;
    }   
    
   private boolean processUnrecoveredFandABusinessRules(Document document) {
        boolean valid = true;
        MessageMap errorMap = GlobalVariables.getMessageMap();
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        int i = 0;
        List<InstitutionalProposalUnrecoveredFandA> institutionalProposalUnrecoveredFandAs = 
                                    institutionalProposalDocument.getInstitutionalProposal().getInstitutionalProposalUnrecoveredFandAs();
        errorMap.addToErrorPath(DOCUMENT_ERROR_PATH);
        errorMap.addToErrorPath(IP_ERROR_PATH);
        for (InstitutionalProposalUnrecoveredFandA institutionalProposalUnrecoveredFandA : institutionalProposalUnrecoveredFandAs) {
            String errorPath = "institutionalProposalUnrecoveredFandAs[" + i + Constants.RIGHT_SQUARE_BRACKET;
            errorMap.addToErrorPath(errorPath);
            InstitutionalProposalSaveUnrecoveredFandARuleEvent event = new InstitutionalProposalSaveUnrecoveredFandARuleEvent(errorPath, 
                                                                                institutionalProposalDocument, 
                                                                                institutionalProposalUnrecoveredFandA);
            valid &= new InstitutionalProposalUnrecoveredFandARuleImpl().processSaveInstitutionalProposalUnrecoveredFandABusinessRules(event);
            errorMap.removeFromErrorPath(errorPath);
            i++;
        }
        errorMap.removeFromErrorPath(IP_ERROR_PATH);
        errorMap.removeFromErrorPath(DOCUMENT_ERROR_PATH);
        return valid;
    }
    
    private boolean processSponsorProgramBusinessRule(Document document) {
        boolean valid = true;
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        String errorPath = "institutionalSponsorAndProgram";
        InstitutionalProposalSponsorAndProgramRuleEvent event = new InstitutionalProposalSponsorAndProgramRuleEvent(errorPath, 
                                                               institutionalProposalDocument, institutionalProposalDocument.getInstitutionalProposal());
        valid &= new MitInstitutionalProposalSponsorAndProgramRuleImpl().processInstitutionalProposalSponsorAndProgramRules(event);
        return valid;
    }

    private boolean processInstitutionalProposalBusinessRules(Document document) {
        boolean valid = true;
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        String errorPath = "institutionalProposal";
        InstitutionalProposalRuleEvent event = new InstitutionalProposalRuleEvent(errorPath, 
                                                               institutionalProposalDocument, institutionalProposalDocument.getInstitutionalProposal());
        valid &= new InstitutionalProposalRuleImpl().processInstitutionalProposalRules(event);
        return valid;
    }
    
    private boolean processInstitutionalProposalFinancialRules(Document document) {
        boolean valid = true;
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        String errorPath = "institutionalProposalFinancial";
        InstitutionalProposalFinancialRuleEvent event = new InstitutionalProposalFinancialRuleEvent(errorPath, 
                                                               institutionalProposalDocument, institutionalProposalDocument.getInstitutionalProposal());
        valid &= new InstitutionalProposalFinancialRuleImpl().processInstitutionalProposalFinancialRules(event);
        return valid;
    }   
    
    private boolean processInstitutionalProposalPersonBusinessRules(MessageMap errorMap, Document document) {
        errorMap.addToErrorPath(DOCUMENT_ERROR_PATH);
        errorMap.addToErrorPath(IP_ERROR_PATH);
        InstitutionalProposalPersonSaveRuleEvent event = new InstitutionalProposalPersonSaveRuleEvent("Project Persons", "projectPersons", document);
        boolean success = new InstitutionalProposalPersonSaveRuleImpl().processInstitutionalProposalPersonSaveBusinessRules(event);
        errorMap.removeFromErrorPath(IP_ERROR_PATH);
        errorMap.removeFromErrorPath(DOCUMENT_ERROR_PATH);
        
        return success;
    }
	
    private boolean processKeywordBusinessRule(Document document) {
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        List<InstitutionalProposalScienceKeyword> keywords = institutionalProposalDocument.getInstitutionalProposal().getKeywords();
        for ( InstitutionalProposalScienceKeyword keyword : keywords ) {
            for ( InstitutionalProposalScienceKeyword keyword2 : keywords ) {
                if ( keyword == keyword2 ) {
                    continue;
                } else if ( StringUtils.equalsIgnoreCase(keyword.getScienceKeywordCode(), keyword2.getScienceKeywordCode()) ) {
                    GlobalVariables.getMessageMap().putError("document.institutionalProposalList[0].keyword", "error.proposalKeywords.duplicate");
                   
                    return false;
                }
            }
        }
        return true;
    }
    
    private boolean processAccountIdBusinessRule(Document document) {
        boolean retVal = true;
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        InstitutionalProposal institutionalProposal = institutionalProposalDocument.getInstitutionalProposal();

        String ipAccountNumber = institutionalProposal.getCurrentAccountNumber();
        String awardNumber = institutionalProposal.getCurrentAwardNumber();
        if (!StringUtils.isEmpty(awardNumber) && !StringUtils.isEmpty(ipAccountNumber)) {
            BusinessObjectService boService = KcServiceLocator.getService(BusinessObjectService.class);
            Map<String, String> fieldValues = new HashMap<String, String>();
            fieldValues.put("awardNumber", awardNumber);
            Collection awardCol = boService.findMatching(Award.class, fieldValues);
            if (!awardCol.isEmpty()) {
                Award award = (Award) (awardCol.toArray())[0];
                String awardAccountNumber = award.getAccountNumber();
                if (!StringUtils.equalsIgnoreCase(ipAccountNumber, awardAccountNumber)) {
                    GlobalVariables.getMessageMap().putError("document.institutionalProposal.currentAccountNumber",
                            "error.institutionalProposal.accountNumber.invalid", ipAccountNumber);
                    retVal = false;
                }
            }
        }
        return retVal;
    }
    
    private boolean processCostShareRules(Document document) {
        boolean valid = true;
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        String errorPath = "institutionalProposal";
        int i = 0;
        List<InstitutionalProposalCostShare> costShares = institutionalProposalDocument.getInstitutionalProposal().getInstitutionalProposalCostShares();
        for (InstitutionalProposalCostShare costShare : costShares) {
            InstitutionalProposalAddCostShareRuleEvent event = new InstitutionalProposalAddCostShareRuleEvent(errorPath, institutionalProposalDocument, costShare);
            valid &= new InstitutionalProposalAddCostShareRuleImpl().processInstitutionalProposalCostShareBusinessRules(event, i);
            i++;
        }
        return valid;
    }
    
    private boolean validateSponsors(Document document) {
        boolean valid = true;
        MessageMap errorMap = GlobalVariables.getMessageMap();
        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
        SponsorService ss = this.getSponsorService();
        if (!ss.isValidSponsor(institutionalProposalDocument.getInstitutionalProposal().getSponsor())) {
            errorMap.putError("document.institutionalProposalList[0].sponsorCode", KeyConstants.ERROR_INVALID_SPONSOR_CODE);
            valid = false;
        }
        if (!StringUtils.isEmpty(institutionalProposalDocument.getInstitutionalProposal().getPrimeSponsorCode()) &&
                !ss.isValidSponsor(institutionalProposalDocument.getInstitutionalProposal().getPrimeSponsor())) {
            errorMap.putError("document.institutionalProposalList[0].primeSponsorCode", KeyConstants.ERROR_INVALID_SPONSOR_CODE);
            valid = false;
        }
        return valid;
    }
    
    private SponsorService getSponsorService() {
        return KcServiceLocator.getService(SponsorService.class);
    }
    
	@Override
	    public boolean processSaveDocument(Document document) {
	        boolean isValid = true;

	        isValid = isDocumentOverviewValid(document);

	        GlobalVariables.getMessageMap().addToErrorPath(KRADConstants.DOCUMENT_PROPERTY_NAME);
	        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument)document;
	        if(institutionalProposalDocument.getInstitutionalProposal().getSequenceNumber()== 1 || 
	                (institutionalProposalDocument.getInstitutionalProposal().getSequenceNumber()!=1 && !institutionalProposalDocument.getDocumentHeader().getWorkflowDocument().getStatus().getCode().equals("I"))){
	            
	            getKnsDictionaryValidationService().validateDocumentAndUpdatableReferencesRecursively(document, getMaxDictionaryValidationDepth(),
	                    VALIDATION_REQUIRED, CHOMP_LAST_LETTER_S_FROM_COLLECTION_NAME);
	            getDictionaryValidationService().validateDefaultExistenceChecksForTransDoc((TransactionalDocument) document);
	        }

	            GlobalVariables.getMessageMap().removeFromErrorPath(KRADConstants.DOCUMENT_PROPERTY_NAME);
	        

	        isValid &= GlobalVariables.getMessageMap().hasNoErrors();
	        isValid &= processCustomSaveDocumentBusinessRules(document);

	        return isValid;
	    }
	 
	 public boolean processRunAuditBusinessRules(Document document){
	        boolean retval = true;
	        
	        retval &= new KcDocumentBaseAuditRule().processRunAuditBusinessRules(document);
	        retval &= new InstitutionalProposalPersonAuditRule().processRunAuditBusinessRules(document);
	        retval &= new InstitutionalProposalCostShareAuditRule().processRunAuditBusinessRules(document);
	        retval &= processInstitutionalProposalPersonCreditSplitBusinessRules(document);
	        retval &= processInstitutionalProposalPersonUnitCreditSplitBusinessRules(document);
	        return retval;
	 }
	 
	 private boolean processInstitutionalProposalPersonCreditSplitBusinessRules(Document document) {
	        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
	        return new InstitutionalProposalCreditSplitBean(institutionalProposalDocument).recalculateCreditSplit();
	        
	    }
	 
	 private boolean processInstitutionalProposalPersonUnitCreditSplitBusinessRules(Document document) {
	        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
	        return new InstitutionalProposalCreditSplitBean(institutionalProposalDocument).recalculateCreditSplit();
	    }	
	 
	 private boolean processInstitutionalProposalAttachmentsBusinessRules(Document document) {
	        boolean valid = true;
	        InstitutionalProposalDocument institutionalProposalDocument = (InstitutionalProposalDocument) document;
	        String errorPath = "institutionalProposal";
	        List<InstitutionalProposalAttachments> instProposalAttachments = institutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments();
	        for(InstitutionalProposalAttachments instProposalAttachment:instProposalAttachments) {
	        InstitutionalProposalAddAttachmentRuleEvent event = new InstitutionalProposalAddAttachmentRuleEvent(errorPath, 
	                                                               institutionalProposalDocument,instProposalAttachment);
	        valid &= new InstitutionalProposalAddAttachmentRuleImpl().processAddInstitutionalProposalAttachmentBusinessRules(event);
	        }
	       if(valid) {
	    	   List <InstitutionalProposalAttachments> instProposalList = institutionalProposalDocument.getInstitutionalProposalList().get(0).getInstProposalAttachments();
	           for (InstitutionalProposalAttachments instProposal : instProposalList) {
	           	instProposal.setModifyAttachment(false); 
	           }
	       }
	        return valid;
	    }
}
