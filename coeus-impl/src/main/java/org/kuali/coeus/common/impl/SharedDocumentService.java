package org.kuali.coeus.common.impl;

import java.util.List;

import org.kuali.coeus.common.framework.medusa.MedusaBean;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.subaward.bo.SubAward;

import edu.mit.kc.bo.SharedDocumentType;

public interface SharedDocumentService {

	public String getSharedDocumentTypeForModule(String moduleCode);
	
	public List<SharedDocumentType> getAllSharedDocumentTypes();
	
	public String getSharedDocumentTypeForModule(List<SharedDocumentType> sharedDocumentTypes, String moduleCode);
	
	public void populateAttachmentPermission(MedusaBean medusaBean);
	
	public void processDevelopmentProposalAttachments(DevelopmentProposal developmentProposal);
	
	public void processInstituteProposalAttachments(InstitutionalProposal institutionalProposal);
	
	public void processAwardAttachments(Award award);
	
	public void processSubAwardAttachments(SubAward subAward);
	
}
