package org.kuali.coeus.common.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.kuali.coeus.common.framework.auth.UnitAuthorizationService;
import org.kuali.coeus.common.framework.auth.perm.KcAuthorizationService;
import org.kuali.coeus.common.framework.medusa.MedusaBean;
import org.kuali.coeus.common.framework.medusa.MedusaNode;
import org.kuali.coeus.common.framework.module.CoeusModule;
import org.kuali.coeus.propdev.impl.attachment.Narrative;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.coeus.sys.framework.workflow.KcWorkflowService;
import org.kuali.kra.award.contacts.AwardPerson;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.notesandattachments.attachments.AwardAttachment;
import org.kuali.kra.coi.disclosure.CoiDisclosedProjectBean;
import org.kuali.kra.infrastructure.PermissionConstants;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachments;
import org.kuali.kra.institutionalproposal.contacts.InstitutionalProposalPerson;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.subaward.bo.SubAward;
import org.kuali.kra.subaward.bo.SubAwardAttachments;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import edu.mit.kc.bo.SharedDocumentType;

@Component("sharedDocumentService")
public class SharedDocumentServiceImpl implements SharedDocumentService {

    @Autowired
    @Qualifier("businessObjectService")
    private BusinessObjectService businessObjectService;

	@Autowired
	@Qualifier("unitAuthorizationService")
    private UnitAuthorizationService unitAuthorizationService;
	
	
	@Autowired
	@Qualifier("kcAuthorizationService")
	private KcAuthorizationService kcAuthorizationService;
    
	
	private KcWorkflowService kcWorkflowService;

	@Override
	public String getSharedDocumentTypeForModule(String moduleCode) {
		List<SharedDocumentType> sharedDocTypes = getSharedDocumentTypes(moduleCode);
	    return getSharedDocumentTypes(sharedDocTypes, moduleCode);
	}
	
	protected List<SharedDocumentType> getSharedDocumentTypes(String moduleCode) {
		Map<String, String> queryMap = new HashMap<String, String>();
		queryMap.put("moduleCode", moduleCode);
		return (List<SharedDocumentType>) getBusinessObjectService().findMatching(SharedDocumentType.class, queryMap);
	}
	
	public List<SharedDocumentType> getAllSharedDocumentTypes() {
	    List<SharedDocumentType> sharedDocTypes = (List<SharedDocumentType>) getBusinessObjectService().findAll(SharedDocumentType.class);
	    return sharedDocTypes;
	}

	public String getSharedDocumentTypeForModule(List<SharedDocumentType> sharedDocumentTypes, String moduleCode) {
	    return getSharedDocumentTypes(sharedDocumentTypes, moduleCode);
	}
	
	protected String getSharedDocumentTypes(List<SharedDocumentType> sharedDocTypes, String moduleCode) {
		StringBuffer sharedDocumentTypeForModule = new StringBuffer();
		for(SharedDocumentType sharedDocumentType : sharedDocTypes) {
			if(sharedDocumentType.getModuleCode().equalsIgnoreCase(moduleCode)) {
				sharedDocumentTypeForModule.append(sharedDocumentType.getDocumentTypeCode());
				sharedDocumentTypeForModule.append(",");
			}
		}
		return sharedDocumentTypeForModule.toString();
	}

	public void populateAttachmentPermission(MedusaBean medusaBean) {
		String currentUser = GlobalVariables.getUserSession().getPrincipalId();
		List<SharedDocumentType> sharedDocumentTypes = getAllSharedDocumentTypes();
		populatePermissionsForDocumentInNode(medusaBean.getParentNodes(), currentUser, sharedDocumentTypes);
	}
	
    protected void populatePermissionsForDocumentInNode(List<MedusaNode> medusaNodes, String currentUser, List<SharedDocumentType> sharedDocumentTypes) {
        for(MedusaNode medusaNode : medusaNodes) {
	    	if (medusaNode.getData() instanceof DevelopmentProposal) {
	    		processDevelopmentProposalAttachments((DevelopmentProposal) medusaNode.getData(), currentUser, sharedDocumentTypes);
	    	} else if (medusaNode.getData() instanceof InstitutionalProposal) {
	    		processInstituteProposalAttachments((InstitutionalProposal) medusaNode.getData(), currentUser, sharedDocumentTypes);
	    	} else if (medusaNode.getData() instanceof Award) {
	    		processAwardAttachments((Award) medusaNode.getData(), currentUser, sharedDocumentTypes);
	        } else if (medusaNode.getData() instanceof SubAward) {
	    		processSubAwardAttachments((SubAward) medusaNode.getData(), currentUser, sharedDocumentTypes);
	        }
	    	populatePermissionsForDocumentInNode((List<MedusaNode>) medusaNode.getChildNodes(), currentUser, sharedDocumentTypes);
        }
    }
    
	public void processDevelopmentProposalAttachments(DevelopmentProposal developmentProposal) {
		String currentUser = GlobalVariables.getUserSession().getPrincipalId();
		List<SharedDocumentType> sharedDocumentTypes = getSharedDocumentTypes(CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE);
		processDevelopmentProposalAttachments(developmentProposal, currentUser, sharedDocumentTypes);
	}
	
	protected void processDevelopmentProposalAttachments(DevelopmentProposal developmentProposal, String currentUser, List<SharedDocumentType> sharedDocumentTypes) {
		boolean isUserPI = isUserPrincipalInvestigator(developmentProposal, currentUser);
		if(isUserPI) {
			String sharedDocTypes = getSharedDocumentTypeForModule(sharedDocumentTypes, CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE);
			setDevelopmentProposalAttachmentPermisson(developmentProposal.getNarratives(), false, true, sharedDocTypes);
		}else {
			verifyDevelopmentProposalAttachmentPermission(developmentProposal.getOwnedByUnitNumber(), currentUser, sharedDocumentTypes, developmentProposal);
		}
	}
	
	public void processInstituteProposalAttachments(InstitutionalProposal institutionalProposal) {
		String currentUser = GlobalVariables.getUserSession().getPrincipalId();
		List<SharedDocumentType> sharedDocumentTypes = getSharedDocumentTypes(CoeusModule.INSTITUTIONAL_PROPOSAL_MODULE_CODE);
		processInstituteProposalAttachments(institutionalProposal, currentUser, sharedDocumentTypes);
	}
	
	protected void processInstituteProposalAttachments(InstitutionalProposal institutionalProposal, String currentUser, List<SharedDocumentType> sharedDocumentTypes) {
		boolean isUserPI = isUserPrincipalInvestigator(institutionalProposal, currentUser);
		if(isUserPI) {
			String sharedDocTypes = getSharedDocumentTypeForModule(sharedDocumentTypes, CoeusModule.INSTITUTIONAL_PROPOSAL_MODULE_CODE);
			setInstituteProposalAttachmentPermisson(institutionalProposal.getInstProposalAttachments(), false, true, sharedDocTypes);
		}else {
			verifyInstituteProposalAttachmentPermission(institutionalProposal.getLeadUnitNumber(), currentUser, sharedDocumentTypes, institutionalProposal);
		}
	}
	
	public void processAwardAttachments(Award award) {
		String currentUser = GlobalVariables.getUserSession().getPrincipalId();
		List<SharedDocumentType> sharedDocumentTypes = getSharedDocumentTypes(CoeusModule.AWARD_MODULE_CODE);
		processAwardAttachments(award, currentUser, sharedDocumentTypes);
	}
	
	protected void processAwardAttachments(Award award, String currentUser, List<SharedDocumentType> sharedDocumentTypes) {
		boolean isUserPI = isUserPrincipalInvestigator(award, currentUser);
		if(isUserPI) {
			String sharedDocTypes = getSharedDocumentTypeForModule(sharedDocumentTypes, CoeusModule.AWARD_MODULE_CODE);
			setAwardAttachmentPermisson(award.getAwardAttachments(), false, true, sharedDocTypes);
		}else {
			verifyAwardAttachmentPermission(award.getLeadUnitNumber(), currentUser, sharedDocumentTypes, award);
		}
	}
	
	public void processSubAwardAttachments(SubAward subAward) {
		String currentUser = GlobalVariables.getUserSession().getPrincipalId();
		List<SharedDocumentType> sharedDocumentTypes = getSharedDocumentTypes(CoeusModule.SUBCONTRACTS_MODULE_CODE);
		processSubAwardAttachments(subAward, currentUser, sharedDocumentTypes);
	}
	
	protected void processSubAwardAttachments(SubAward subAward, String currentUser, List<SharedDocumentType> sharedDocumentTypes) {
		verifySubAwardAttachmentPermission(subAward.getLeadUnitNumber(), currentUser, sharedDocumentTypes, subAward);
	}
	
	protected boolean isUserPrincipalInvestigator(DevelopmentProposal developmentProposal, String principalId) {
	     for (ProposalPerson person : developmentProposal.getProposalPersons()) {
	            if (person.isPrincipalInvestigator() && StringUtils.equals(principalId, person.getPersonId())) {
	                return true;
	            }
	      }
	      return false;
	} 	     
	
	protected boolean isUserPrincipalInvestigator(Award award, String principalId) {
	     for (AwardPerson person : award.getProjectPersons()) {
	            if (person.isPrincipalInvestigator() && StringUtils.equals(principalId, person.getPersonId())) {
	                return true;
	            }
	      }
	      return false;
	} 	     
	
	protected boolean isUserPrincipalInvestigator(InstitutionalProposal institutionalProposal, String principalId) {
	     for (InstitutionalProposalPerson projectPerson : institutionalProposal.getProjectPersons()) {
	            if (projectPerson.isPrincipalInvestigator() && StringUtils.equals(principalId, projectPerson.getPersonId())) {
	                return true;
	            }
	      }
	      return false;
	} 	     

	protected void verifyDevelopmentProposalAttachmentPermission(String unitNumber, String currentUser, List<SharedDocumentType> sharedDocumentTypes, DevelopmentProposal developmentProposal) {
		boolean viewAttachment = false;
		boolean viewSharedDoc = false;
		String sharedDocTypes = null;
		 if (getKcAuthorizationService().hasPermission(currentUser, developmentProposal.getProposalDocument(), "VIEW_DEV_PROPOSAL_DOC") || 
				 getKcWorkflowService().hasWorkflowPermission(currentUser, developmentProposal.getProposalDocument())) {
			 viewAttachment = true;
		 }else if((getKcAuthorizationService().hasPermission(currentUser,developmentProposal.getProposalDocument(), "VIEW_ALL_SHARED_DOC"))) {
			sharedDocTypes = getSharedDocumentTypeForModule(sharedDocumentTypes, CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE);
			viewSharedDoc = true;
		 }
		 setDevelopmentProposalAttachmentPermisson(developmentProposal.getNarratives(), viewAttachment, viewSharedDoc, sharedDocTypes);
	}
	
	protected void setDevelopmentProposalAttachmentPermisson(List<Narrative> developmentProposalAttachments, boolean viewAttachment, boolean viewSharedDoc, String sharedDocTypes) {
		for(Narrative narrative : developmentProposalAttachments) {
			boolean viewAttachmentPermission = viewSharedDoc ? false : viewAttachment;
			if(viewSharedDoc && sharedDocTypes != null && sharedDocTypes.contains(narrative.getNarrativeTypeCode())) {
				viewAttachmentPermission = true;
			}
			narrative.setViewAttachment(viewAttachmentPermission);
		}
	}
	
	protected void verifyAwardAttachmentPermission(String unitNumber, String currentUser, List<SharedDocumentType> sharedDocumentTypes, Award award) {
		boolean viewAttachment = false;
		boolean viewSharedDoc = false;
		String sharedDocTypes = null;
		 if ((getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-AWARD", "Maintain Award Attachments")) ||
		    (getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-AWARD", "View Award Attachments")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-AWARD", "Create Award")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-AWARD", "Modify Award"))) {
			 viewAttachment = true;
		 }else if((getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-AWARD", "VIEW_SHARED_AWARD_DOC")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-SYS", "VIEW_ALL_SHARED_DOC"))) {
			sharedDocTypes = getSharedDocumentTypeForModule(sharedDocumentTypes, CoeusModule.AWARD_MODULE_CODE);
			viewSharedDoc = true;
		 }
		 setAwardAttachmentPermisson(award.getAwardAttachments(), viewAttachment, viewSharedDoc, sharedDocTypes);
	}
	
	protected void setAwardAttachmentPermisson(List<AwardAttachment> awardAttachments, boolean viewAttachment, boolean viewSharedDoc, String sharedDocTypes) {
		for(AwardAttachment awardAttachment : awardAttachments) {
			boolean viewAttachmentPermission = viewSharedDoc ? false : viewAttachment;
			if(viewSharedDoc && sharedDocTypes != null && sharedDocTypes.contains(awardAttachment.getTypeCode())) {
				viewAttachmentPermission = true;
			}
			awardAttachment.setViewAttachment(viewAttachmentPermission);
		}
	}
	
	protected void verifySubAwardAttachmentPermission(String unitNumber, String currentUser, List<SharedDocumentType> sharedDocumentTypes, SubAward subAward) {
		boolean viewAttachment = false;
		boolean viewSharedDoc = false;
		String sharedDocTypes = null;
		 if ((getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-SUBAWARD", "MODIFY SUBAWARD")) ||
		    (getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-SUBAWARD", "CREATE SUBAWARD")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-SUBAWARD", "VIEW_SUBAWARD_DOCUMENTS"))) {
			 viewAttachment = true;
		 }else if((getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-SUBAWARD", "VIEW_SHARED_SUBAWARD_DOC")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-SYS", "VIEW_ALL_SHARED_DOC"))) {
			sharedDocTypes = getSharedDocumentTypeForModule(sharedDocumentTypes, CoeusModule.SUBCONTRACTS_MODULE_CODE);
			viewSharedDoc = true;
		 }
		 setSubAwardAttachmentPermisson(subAward.getSubAwardAttachments(), viewAttachment, viewSharedDoc, sharedDocTypes);
	}
	
	protected void setSubAwardAttachmentPermisson(List<SubAwardAttachments> subAwardAttachments, boolean viewAttachment, boolean viewSharedDoc, String sharedDocTypes) {
		for(SubAwardAttachments subAwardAttachment : subAwardAttachments) {
			boolean viewAttachmentPermission = viewSharedDoc ? false : viewAttachment;
			if(viewSharedDoc && sharedDocTypes != null && sharedDocTypes.contains(subAwardAttachment.getSubAwardAttachmentTypeCode())) {
				viewAttachmentPermission = true;
			}
			subAwardAttachment.setViewAttachment(viewAttachmentPermission);
		}
	}

	protected void verifyInstituteProposalAttachmentPermission(String unitNumber, String currentUser, List<SharedDocumentType> sharedDocumentTypes, InstitutionalProposal institutionalProposal) {
		boolean viewAttachment = false;
		boolean viewSharedDoc = false;
		String sharedDocTypes = null;
		 if ((getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-IP", "Edit Institutional Proposal")) ||
		    (getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-IP", "Create Institutional Proposal")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-IP", "MAINTAIN_INST_PROPOSAL_DOC")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-IP", "VIEW_INST_PROPOSAL_DOC"))) {
			 viewAttachment = true;
		 }else if((getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-IP", "VIEW_SHARED_INST_PROPOSAL_DOC")) ||
			(getUnitAuthorizationService().hasPermission(currentUser, unitNumber, "KC-SYS", "VIEW_ALL_SHARED_DOC"))) {
			sharedDocTypes = getSharedDocumentTypeForModule(sharedDocumentTypes, CoeusModule.INSTITUTIONAL_PROPOSAL_MODULE_CODE);
			viewSharedDoc = true;
		 }
		 setInstituteProposalAttachmentPermisson(institutionalProposal.getInstProposalAttachments(), viewAttachment, viewSharedDoc, sharedDocTypes);
	}
	
	protected void setInstituteProposalAttachmentPermisson(List<InstitutionalProposalAttachments> institutionalProposalAttachments, boolean viewAttachment, boolean viewSharedDoc, String sharedDocTypes) {
		for(InstitutionalProposalAttachments institutionalProposalAttachment : institutionalProposalAttachments) {
			boolean viewAttachmentPermission = viewSharedDoc ? false : viewAttachment;
			String attachmentTypeCode = institutionalProposalAttachment.getAttachmentTypeCode().toString();
			if(viewSharedDoc && sharedDocTypes != null && sharedDocTypes.contains(attachmentTypeCode)) {
				viewAttachmentPermission = true;
			}
			institutionalProposalAttachment.setViewAttachment(viewAttachmentPermission);
		}
	}
	
	public BusinessObjectService getBusinessObjectService() {
		return businessObjectService;
	}

	public void setBusinessObjectService(BusinessObjectService businessObjectService) {
		this.businessObjectService = businessObjectService;
	}

	public UnitAuthorizationService getUnitAuthorizationService() {
		return unitAuthorizationService;
	}

	public void setUnitAuthorizationService(
			UnitAuthorizationService unitAuthorizationService) {
		this.unitAuthorizationService = unitAuthorizationService;
	}
	
	public KcAuthorizationService getKcAuthorizationService() {
		return kcAuthorizationService;
	}

	public void setKcAuthorizationService(
			KcAuthorizationService kcAuthorizationService) {
		this.kcAuthorizationService = kcAuthorizationService;
	}

	public KcWorkflowService getKcWorkflowService() {
		if (kcWorkflowService == null) {
            kcWorkflowService = KcServiceLocator.getService(KcWorkflowService.class);
        }
		return kcWorkflowService;
	}

	public void setKcWorkflowService(KcWorkflowService kcWorkflowService) {
		this.kcWorkflowService = kcWorkflowService;
	}
}
