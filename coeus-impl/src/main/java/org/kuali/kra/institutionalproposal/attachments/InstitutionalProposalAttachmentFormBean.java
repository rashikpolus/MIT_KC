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
package org.kuali.kra.institutionalproposal.attachments;

import org.apache.commons.lang3.StringUtils;

import org.kuali.coeus.sys.framework.service.KcServiceLocator;

import org.kuali.kra.award.home.Award;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.institutionalproposal.web.struts.form.InstitutionalProposalForm;
import org.kuali.rice.krad.service.BusinessObjectService;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class InstitutionalProposalAttachmentFormBean implements Serializable{


    private static final long serialVersionUID = 4184903707661244083L;
    
    private final InstitutionalProposalForm form;
    
    private InstitutionalProposalAttachments newAttachment;
    
    private boolean disableAttachmentRemovalIndicator=false;
    
    private boolean maintainInstituteProposal=false;
    
    private boolean canViewAttachment=false;
    
    public InstitutionalProposalAttachmentFormBean(final InstitutionalProposalForm form) {
        this.form = form;
    }
    
    
    
    /**
     * Gets the new attachment. This method will not return null.
     * Also, The InstitutionalProposalAttachment should have a valid Proposal  Id at this point.
     * @return the new attachment
     */
    public InstitutionalProposalAttachments getNewAttachment() {
    	if (this.newAttachment == null) {
            this.initAttachment();
        }
        return this.newAttachment;
    }
    
    /**
     * initializes a new attachment setting the proposal id.
     */
    private void initAttachment() {
        this.setNewAttachment(new InstitutionalProposalAttachments(this.getInstitutionalProposal()));
    }

    /**
     * Sets the newAttachment attribute value.
     * @param newAttachment The newAttachment to set.
     */
    public void setNewAttachment(InstitutionalProposalAttachments newAttachment) {
        this.newAttachment = newAttachment;
    }

    /**
     * Gets the form attribute. 
     * @return Returns the form.
     */
    public InstitutionalProposalForm getForm() {
        return form;
    }
    
    /**
     * Get the Institutionalproposal.
     * @return the Institutionalproposal
     * @throws IllegalArgumentException if the {@link InstitutionalproposalDocument AwardDocument}
     * or {@link Award Award} is {@code null}.
     */
    public InstitutionalProposal getInstitutionalProposal() {

        if (this.form.getInstitutionalProposalDocument() == null) {
            throw new IllegalArgumentException("the document is null");
        }
        
        if (this.form.getInstitutionalProposalDocument().getInstitutionalProposal() == null) {
            throw new IllegalArgumentException("the award is null");
        }

        return this.form.getInstitutionalProposalDocument().getInstitutionalProposal();
    }
    
    /**
     * Adds the "new" IPAttachment to the InstitutionalProposal.  Before
     * adding this method executes validation.  If the validation fails the attachment is not added.
     */
    public void addNewInstitutionalProposalAttachment() {
         this.newAttachment.setProposalId(this.getInstitutionalProposal().getProposalId()); //OJB Hack.  Could not get the awardId to persist with anonymous access in repository file.
         this.newAttachment.setDocumentStatusCode("A");
         Map<String, String> criteria = new HashMap<String, String>();
         criteria.put("proposalNumber", this.getInstitutionalProposal().getProposalNumber());
         Collection<InstitutionalProposalAttachments> allAttachments = getBusinessObjectService().findMatching(InstitutionalProposalAttachments.class, criteria);
         setAttachmentNumber(allAttachments);
         this.syncNewFiles(Collections.singletonList(this.getNewAttachment()));
         this.getInstitutionalProposal().addAttachment(this.newAttachment);
         getBusinessObjectService().save(this.newAttachment);
         this.initNewAttachment();
    }
    
    /**
     * retrieves an attachment from an Institutional Proposal based on a type.
     * 
     * @param <T> the type parameter
     * @param attachmentNumber the attachment number
     * @param type the type token
     * @return the attachment or null if not found
     * @throws IllegalArgumentException if the type is null or not recognized
     */
    public InstitutionalProposalAttachments retrieveExistingAttachment(int attachmentNumber) {
        if (!validIndexForList(attachmentNumber, this.getInstitutionalProposal().getInstProposalAttachments())) {
            return null;
        }
        return this.getInstitutionalProposal().getInstProposalAttachments().get(attachmentNumber);
    }
    
    /**
     * Checks if a given index is valid for a given list. This method returns null if the list is null.
     * 
     * @param index the index
     * @param forList the list
     * @return true if a valid index
     */
    private static boolean validIndexForList(int index, final List<?> forList) {      
        return forList != null && index >= 0 && index <= forList.size() - 1;
    }
    
    /**
     * initializes a new attachment personnel setting the proposal id.
     */
    private void initNewAttachment() {
        this.setNewAttachment(new InstitutionalProposalAttachments(this.getInstitutionalProposal()));
    }
    
    
    /** 
     * Syncs all new files for a given Collection of attachments on the award.
     * @param attachments the attachments.
     */
    private void syncNewFiles(List<InstitutionalProposalAttachments> attachments) {
        assert attachments != null : "the attachments was null";
        for (InstitutionalProposalAttachments attachment : attachments) {
            if (InstitutionalProposalAttachmentFormBean.doesNewFileExist(attachment)) {
                final InstitutionalProposalAttachmentsData newFile = InstitutionalProposalAttachmentsData.createFromFormFile(attachment.getNewFile());
            	//setting the sequence number to the old file sequence number
                if (attachment.getFile() != null) {
                    newFile.setSequenceNumber(attachment.getFile().getSequenceNumber());
                }
                newFile.setProposalNumber(this.getInstitutionalProposal().getProposalNumber());
                newFile.setProposalId(this.getInstitutionalProposal().getProposalId());
                newFile.setSequenceNumber(this.getInstitutionalProposal().getSequenceNumber());
                newFile.setAttachmentNumber(this.newAttachment.getAttachmentNumber());
                attachment.setFile(newFile);
           }
        }
    }
    
    /**
     * Checks if a new file exists on an attachment
     * 
     * @param attachment the attachment
     * @return true if new false if not
     */
    private static boolean doesNewFileExist(InstitutionalProposalAttachments attachment) {
        return attachment.getNewFile() != null && StringUtils.isNotBlank(attachment.getNewFile().getFileName());
    }
    
    /**
     * Add attachment Number
     * 
     * @param allAttachments the attachment
     * @return attachmentNumber
     */
    private void setAttachmentNumber(Collection<InstitutionalProposalAttachments> allAttachments) {
    	if(allAttachments.isEmpty() || allAttachments == null) {
        	this.newAttachment.setAttachmentNumber(1);	
        } else {
        	ArrayList<Integer> maxAttachmentNumber = new ArrayList<Integer>();
    		for(InstitutionalProposalAttachments attachment: allAttachments) {
        		if(attachment.getAttachmentNumber() != null) {
        			maxAttachmentNumber.add(attachment.getAttachmentNumber());
        		}
        	} 
        	    if(Collections.max(maxAttachmentNumber) != null) {
        		this.newAttachment.setAttachmentNumber((Collections.max(maxAttachmentNumber)+1));
        		}
        }
    }

    


    public boolean isDisableAttachmentRemovalIndicator() {
		return disableAttachmentRemovalIndicator;
	}



	public void setDisableAttachmentRemovalIndicator(
			boolean disableAttachmentRemovalIndicator) {
		this.disableAttachmentRemovalIndicator = disableAttachmentRemovalIndicator;
	}



	public boolean isMaintainInstituteProposal() {
		return maintainInstituteProposal;
	}



	public void setMaintainInstituteProposal(boolean maintainInstituteProposal) {
		this.maintainInstituteProposal = maintainInstituteProposal;
	}



	public boolean isCanViewAttachment() {
		return canViewAttachment;
	}



	public void setCanViewAttachment(boolean canViewAttachment) {
		this.canViewAttachment = canViewAttachment;
	}



	private BusinessObjectService getBusinessObjectService() {
        return KcServiceLocator.getService(BusinessObjectService.class);
    }
}
