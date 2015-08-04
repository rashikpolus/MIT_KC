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


import java.security.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.struts.upload.FormFile;
import org.eclipse.persistence.internal.weaving.RelationshipInfo;
import org.kuali.coeus.common.framework.attachment.AttachmentFile;
import org.kuali.coeus.common.framework.version.sequence.associate.SequenceAssociate;
import org.kuali.coeus.common.framework.version.sequence.owner.SequenceOwner;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.notesandattachments.attachments.AwardAttachment;
import org.kuali.kra.institutionalproposal.InstitutionalProposalAssociate;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalAttachmentType;
import org.kuali.kra.institutionalproposal.web.struts.form.InstitutionalProposalForm;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.kim.api.identity.PersonService;
import org.kuali.rice.kns.web.struts.form.BlankFormFile;
import org.kuali.rice.krad.service.BusinessObjectService;



public class InstitutionalProposalAttachments extends InstitutionalProposalAssociate  implements Comparable<InstitutionalProposalAttachments>, SequenceAssociate {


    private static final long serialVersionUID = 502762283098287794L;
    
    private Long proposalAttachmentId;
    
    private Long proposalId;
    
    private String proposalNumber;
    
    private Integer sequenceNumber;
    
    private Integer attachmentNumber;
    
    private String attachmentTitle;
    
    private Integer attachmentTypeCode;
    
    private String fileName;
    
    private String contentType;
    
    private String comments;
    
    private Long proposalAttachmentsDataId;
    
    private String documentStatusCode;
    
    private boolean modifyAttachment=false;
    
    private transient FormFile newFile;
    
    private InstitutionalProposalAttachmentType type;
    
    private InstitutionalProposalAttachmentsData file;
		
    private boolean viewAttachment = false;


    public InstitutionalProposalAttachments() {
        super();
    }
    
    public InstitutionalProposalAttachments(final InstitutionalProposal proposal) {
        this.setInstitutionalProposal(proposal);
    }
    
    /**
	 * @return the proposalAttachmentId
	 */
	public Long getProposalAttachmentId() {
		return proposalAttachmentId;
	}

	/**
	 * @param proposalAttachmentId the proposalAttachmentId to set
	 */
	public void setProposalAttachmentId(Long proposalAttachmentId) {
		this.proposalAttachmentId = proposalAttachmentId;
	}

	/**
	 * @return the proposalId
	 */
	public Long getProposalId() {
		return proposalId;
	}

	/**
	 * @param proposalId the proposalId to set
	 */
	public void setProposalId(Long proposalId) {
		this.proposalId = proposalId;
	}

	/**
	 * @return the proposalNumber
	 */
	public String getProposalNumber() {
		return proposalNumber;
	}

	/**
	 * @param proposalNumber the proposalNumber to set
	 */
	public void setProposalNumber(String proposalNumber) {
		this.proposalNumber = proposalNumber;
	}

	/**
	 * @return the sequenceNumber
	 */
	public Integer getSequenceNumber() {
		return sequenceNumber;
	}

	/**
	 * @param sequenceNumber the sequenceNumber to set
	 */
	public void setSequenceNumber(Integer sequenceNumber) {
		this.sequenceNumber = sequenceNumber;
	}

	/**
	 * @return the attachmentNumber
	 */
	public Integer getAttachmentNumber() {
		return attachmentNumber;
	}

	/**
	 * @param attachmentNumber the attachmentNumber to set
	 */
	public void setAttachmentNumber(Integer attachmentNumber) {
		this.attachmentNumber = attachmentNumber;
	}

	/**
	 * @return the attachmentTitle
	 */
	public String getAttachmentTitle() {
		return attachmentTitle;
	}

	/**
	 * @param attachmentTitle the attachmentTitle to set
	 */
	public void setAttachmentTitle(String attachmentTitle) {
		this.attachmentTitle = attachmentTitle;
	}

	/**
	 * @return the attachmentTypeCode
	 */
	public Integer getAttachmentTypeCode() {
		return attachmentTypeCode;
	}

	/**
	 * @param attachmentTypeCode the attachmentTypeCode to set
	 */
	public void setAttachmentTypeCode(Integer attachmentTypeCode) {
		this.attachmentTypeCode = attachmentTypeCode;
	}

	/**
	 * @return the fileName
	 */
	public String getFileName() {
		return fileName;
	}

	/**
	 * @param fileName the fileName to set
	 */
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	/**
	 * @return the contentType
	 */
	public String getContentType() {
		return contentType;
	}

	/**
	 * @param contentType the contentType to set
	 */
	public void setContentType(String contentType) {
		this.contentType = contentType;
	}

	/**
	 * @return the contactName
	 */

	/**
	 * @return the comments
	 */
	public String getComments() {
		return comments;
	}

	/**
	 * @param comments the comments to set
	 */
	public void setComments(String comments) {
		this.comments = comments;
	}

	/**
	 * @return the proposalAttachmentsDataId
	 */
	public Long getProposalAttachmentsDataId() {
		return proposalAttachmentsDataId;
	}

	/**
	 * @param proposalAttachmentsDataId the proposalAttachmentsDataId to set
	 */
	public void setProposalAttachmentsDataId(Long proposalAttachmentsDataId) {
		this.proposalAttachmentsDataId = proposalAttachmentsDataId;
	}

	public String getDocumentStatusCode() {
		return documentStatusCode;
	}

	public void setDocumentStatusCode(String documentStatusCode) {
		this.documentStatusCode = documentStatusCode;
	}

	public boolean isModifyAttachment() {
		return modifyAttachment;
	}

	public void setModifyAttachment(boolean modifyAttachment) {
		this.modifyAttachment = modifyAttachment;
	}

	/**
	 * @return the newFile
	 */
	public FormFile getNewFile() {
		return newFile;
	}

	/**
	 * @param newFile the newFile to set
	 */
	public void setNewFile(FormFile newFile) {
		this.newFile = newFile;
	}

	/**
	 * @return the type
	 */
	public InstitutionalProposalAttachmentType getType() {
		return type;
	}

	/**
	 * @param type the type to set
	 */
	public void setType(InstitutionalProposalAttachmentType type) {
		this.type = type;
	}

	/**
	 * @return the file
	 */
	public InstitutionalProposalAttachmentsData getFile() {
		return file;
	}

	/**
	 * @param file the file to set
	 */
	public void setFile(InstitutionalProposalAttachmentsData file) {
		this.file = file;
	}
	
	/**
     * 
     * This method returns the full name of the update user.
     * @return
     */
    public String getUpdateUserName() {
        Person updateUser = KcServiceLocator.getService(PersonService.class).getPersonByPrincipalName(this.getUpdateUser());
        return updateUser != null ? updateUser.getName() : this.getUpdateUser();
    }

    @Override
    public void resetPersistenceState() {
        this.proposalAttachmentId = null;
    }
    
	@Override
	public int compareTo(InstitutionalProposalAttachments o) {
		return this.getProposalAttachmentsDataId().compareTo(o.getProposalAttachmentsDataId());
	}
	@Override
    protected void preRemove() {
        super.preRemove();
        //if we have a file and its linked to other versions make sure its not deleted with this version.
        if (getProposalAttachmentsDataId() != null) {
            Map<String, Object> values = new HashMap<String, Object>();
            values.put("proposalAttachmentsDataId", getProposalAttachmentsDataId());
            List<InstitutionalProposalAttachments> otherAttachmentVersions = 
                (List<InstitutionalProposalAttachments>) KcServiceLocator.getService(BusinessObjectService.class).findMatching(InstitutionalProposalAttachments.class, values);
            if (otherAttachmentVersions.size() > 1) {
                setFile(null);
                setProposalAttachmentsDataId(null);
            }
        }
    }

	public boolean isViewAttachment() {
		return viewAttachment;
	}

	public void setViewAttachment(boolean viewAttachment) {
		this.viewAttachment = viewAttachment;
	}


	@Override
	public void setSequenceOwner(SequenceOwner newlyVersionedOwner) {
        setInstitutionalProposal((InstitutionalProposal) newlyVersionedOwner);
	}

	@Override
	public SequenceOwner getSequenceOwner() {
        return getInstitutionalProposal();
	}
	
}
