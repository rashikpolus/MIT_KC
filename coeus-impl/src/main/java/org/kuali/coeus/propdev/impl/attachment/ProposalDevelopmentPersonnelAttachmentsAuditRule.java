package org.kuali.coeus.propdev.impl.attachment;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.framework.attachment.KcAttachmentService;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.propdev.impl.person.attachment.ProposalPersonBiography;
import org.kuali.coeus.propdev.impl.person.attachment.ProposalPersonBiographyService;
import org.kuali.coeus.sys.framework.rule.KcTransactionalDocumentRuleBase;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.krad.document.Document;
import org.kuali.rice.krad.rules.rule.DocumentAuditRule;
import org.kuali.rice.krad.util.AuditCluster;
import org.kuali.rice.krad.util.AuditError;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.ObjectUtils;

import java.util.ArrayList;
import java.util.List;

import static org.kuali.coeus.propdev.impl.datavalidation.ProposalDevelopmentDataValidationConstants.*;

public class ProposalDevelopmentPersonnelAttachmentsAuditRule extends KcTransactionalDocumentRuleBase implements DocumentAuditRule {

    private KcAttachmentService kcAttachmentService;
    private ParameterService parameterService;
    private ProposalPersonBiographyService proposalPersonBiographyService;

    public boolean processRunAuditBusinessRules(Document document) {
        boolean valid = true;
        ProposalDevelopmentDocument proposalDevelopmentDocument = (ProposalDevelopmentDocument) document;
        DevelopmentProposal developmentProposal = proposalDevelopmentDocument.getDevelopmentProposal();
        int index = 0;
        for (ProposalPersonBiography biography : developmentProposal.getPropPersonBios()) {
            valid &=checkForDescription(biography);
            valid &= checkForInvalidCharacters(biography);
            valid &= checkForDuplicates(biography, developmentProposal.getPropPersonBios(), index);
            valid &= checkForProposalPerson(biography,index);
            index++;
        }
        return valid;
    }

    private boolean checkForDescription(ProposalPersonBiography biography){
        boolean valid = true;
        String otherCode = getProposalPersonBiographyService().findPropPerDocTypeForOther().getCode();
        if(StringUtils.equalsIgnoreCase(otherCode,biography.getDocumentTypeCode())) {
            if(StringUtils.isBlank(biography.getDescription())) {
                getAuditErrors(ATTACHMENT_PERSONNEL_SECTION_NAME,AUDIT_ERRORS).add(new AuditError(BIOGRAPHIES_KEY, KeyConstants.ERROR_PERSONNEL_ATTACHMENT_DESCRIPTION_REQUIRED,ATTACHMENT_PAGE_ID + "." + ATTACHMENT_PERSONNEL_SECTION_ID));
                valid = false;
            }
        }
        return valid;
    }
    private boolean checkForInvalidCharacters(ProposalPersonBiography proposalPersonBiography) {

        boolean valid = true;
        // Checking attachment file name for invalid characters.
        String attachmentFileName = proposalPersonBiography.getName();
        String invalidCharacters = getKcAttachmentService().getInvalidCharacters(attachmentFileName);
        if (ObjectUtils.isNotNull(invalidCharacters)) {
            String parameter = getParameterService().
                    getParameterValueAsString(ProposalDevelopmentDocument.class, Constants.INVALID_FILE_NAME_CHECK_PARAMETER);
            if (Constants.INVALID_FILE_NAME_ERROR_CODE.equals(parameter)) {
                valid = false;
                getAuditErrors(ATTACHMENT_PERSONNEL_SECTION_NAME,AUDIT_ERRORS).add(new AuditError(BIOGRAPHIES_KEY,KeyConstants.INVALID_FILE_NAME,ATTACHMENT_PAGE_ID+"."+ATTACHMENT_PERSONNEL_SECTION_ID));
            } else {
                valid = false;
                getAuditErrors(ATTACHMENT_PERSONNEL_SECTION_NAME,AUDIT_WARNINGS).add(new AuditError(BIOGRAPHIES_KEY, KeyConstants.INVALID_FILE_NAME, ATTACHMENT_PAGE_ID + "." + ATTACHMENT_PERSONNEL_SECTION_ID));
            }
        }
        return valid;
    }

    private boolean checkForDuplicates(ProposalPersonBiography biography, List<ProposalPersonBiography> existingBiographies,int index) {
        boolean valid = true;
        if(CollectionUtils.isNotEmpty(existingBiographies) && biography.getProposalPersonNumber() != null){
            for(ProposalPersonBiography personBiography: existingBiographies) {
                if(personBiography.getProposalPersonNumber() != null && personBiography.getDocumentTypeCode() != null &&
                        !StringUtils.equalsIgnoreCase(getProposalPersonBiographyService().findPropPerDocTypeForOther().getCode(),personBiography.getDocumentTypeCode()) &&
                        personBiography.getProposalPersonNumber().equals(biography.getProposalPersonNumber())
                        && personBiography.getDocumentTypeCode().equals(biography.getDocumentTypeCode())){

                    if(personBiography.getBiographyNumber() != biography.getBiographyNumber()) {
                        valid = false;
                        getAuditErrors(ATTACHMENT_PERSONNEL_SECTION_NAME,AUDIT_ERRORS).add(new AuditError(String.format(BIOGRAPHY_TYPE_KEY,index),KeyConstants.ERROR_PERSONNEL_ATTACHMENT_PERSON_DUPLICATE,ATTACHMENT_PAGE_ID + "." + ATTACHMENT_PERSONNEL_SECTION_ID));
                    }
                }
            }
        }
        return valid;
    }

    private boolean checkForProposalPerson(ProposalPersonBiography proposalPersonBiography, int index) {
        boolean valid= true;
        if(proposalPersonBiography.getProposalPersonNumber() == null || StringUtils.isBlank(proposalPersonBiography.getProposalPersonNumber().toString())){
            valid = false;
            getAuditErrors(ATTACHMENT_PERSONNEL_SECTION_NAME,AUDIT_ERRORS).add(new AuditError(String.format(BIOGRAPHY_PERSON_KEY,index),KeyConstants.ERROR_PERSONNEL_ATTACHMENT_PERSON_REQUIRED,ATTACHMENT_PAGE_ID + "." + ATTACHMENT_PERSONNEL_SECTION_ID));
        }
        return valid;
    }

    private List<AuditError> getAuditErrors(String sectionName, String severity ) {
        List<AuditError> auditErrors = new ArrayList<AuditError>();
        String clusterKey = ATTACHMENT_PAGE_NAME + "." + sectionName;
        if (!GlobalVariables.getAuditErrorMap().containsKey(clusterKey+severity)) {
            GlobalVariables.getAuditErrorMap().put(clusterKey+severity, new AuditCluster(clusterKey, auditErrors, severity));
        }
        else {
            auditErrors = GlobalVariables.getAuditErrorMap().get(clusterKey+severity).getAuditErrorList();
        }

        return auditErrors;
    }

    public KcAttachmentService getKcAttachmentService() {
        if (kcAttachmentService == null) {
            kcAttachmentService = KcServiceLocator.getService(KcAttachmentService.class);
        }
        return kcAttachmentService;
    }

    public void setKcAttachmentService(KcAttachmentService kcAttachmentService) {
        this.kcAttachmentService = kcAttachmentService;
    }

    public ParameterService getParameterService() {
        if (parameterService == null) {
            parameterService = KcServiceLocator.getService(ParameterService.class);
        }
        return parameterService;
    }

    public void setParameterService(ParameterService parameterService) {
        this.parameterService = parameterService;
    }

    public ProposalPersonBiographyService getProposalPersonBiographyService() {
        if (proposalPersonBiographyService == null) {
            proposalPersonBiographyService = KcServiceLocator.getService(ProposalPersonBiographyService.class);
        }
        return proposalPersonBiographyService;
    }

    public void setProposalPersonBiographyService(ProposalPersonBiographyService proposalPersonBiographyService) {
        this.proposalPersonBiographyService = proposalPersonBiographyService;
    }
}
