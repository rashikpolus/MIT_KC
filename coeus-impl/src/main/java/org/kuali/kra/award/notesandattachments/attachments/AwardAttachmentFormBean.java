/*
 * Kuali Coeus, a comprehensive research administration system for higher education.
 * 
 * Copyright 2005-2015 Kuali, Inc.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.kuali.kra.award.notesandattachments.attachments;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.kuali.coeus.common.framework.attachment.AttachmentFile;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.AwardForm;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.rice.krad.service.BusinessObjectService;

import java.io.Serializable;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class AwardAttachmentFormBean implements Serializable{


    private static final long serialVersionUID = 4184903707661244083L;
    
    private final AwardForm form;
    
    private AwardAttachment newAttachment;
    
    private boolean disableAttachmentRemovalIndicator=false;
    
    private boolean canViewAttachment=false;

    private boolean maintainAwardAttachment=false;
    
    private boolean canViewSharedDoc=false;
    
    private String awardSharedDocTypes;
    
    public AwardAttachmentFormBean(final AwardForm form) {
        this.form = form;
    }
    
    
    
    
    
    
    /**
     * Gets the new attachment. This method will not return null.
     * Also, The AwardAttachment should have a valid award Id at this point.
     * @return the new attachment
     */
    public AwardAttachment getNewAttachment() {
        if (this.newAttachment == null) {
            this.initAttachment();
        }
        
        return this.newAttachment;
    }
    
    /**
     * initializes a new attachment setting the award id.
     */
    private void initAttachment() {
        this.setNewAttachment(new AwardAttachment(this.getAward()));
    }

    /**
     * Sets the newAttachment attribute value.
     * @param newAttachment The newAttachment to set.
     */
    public void setNewAttachment(AwardAttachment newAttachment) {
        this.newAttachment = newAttachment;
    }

   
	public boolean isDisableAttachmentRemovalIndicator() {
		return disableAttachmentRemovalIndicator;
	}






	public void setDisableAttachmentRemovalIndicator(
			boolean disableAttachmentRemovalIndicator) {
		this.disableAttachmentRemovalIndicator = disableAttachmentRemovalIndicator;
	}






	public boolean isCanViewAttachment() {
		return canViewAttachment;
	}






	public void setCanViewAttachment(boolean canViewAttachment) {
		this.canViewAttachment = canViewAttachment;
	}






	public boolean isMaintainAwardAttachment() {
		return maintainAwardAttachment;
	}






	public void setMaintainAwardAttachment(boolean maintainAwardAttachment) {
		this.maintainAwardAttachment = maintainAwardAttachment;
	}






	/**
     * Gets the form attribute. 
     * @return Returns the form.
     */
    public AwardForm getForm() {
        return form;
    }
    
    /**
     * Get the Award.
     * @return the Award
     * @throws IllegalArgumentException if the {@link AwardDocument AwardDocument}
     * or {@link Award Award} is {@code null}.
     */
    public Award getAward() {

        if (this.form.getAwardDocument() == null) {
            throw new IllegalArgumentException("the document is null");
        }
        
        if (this.form.getAwardDocument().getAward() == null) {
            throw new IllegalArgumentException("the award is null");
        }

        return this.form.getAwardDocument().getAward();
    }
    
    /**
     * Adds the "new" AwardAttachment to the Award.  Before
     * adding this method executes validation.  If the validation fails the attachment is not added.
     */
    public void addNewAwardAttachment() {
        this.refreshAttachmentReferences(Collections.singletonList(this.getNewAttachment()));
        this.syncNewFiles(Collections.singletonList(this.getNewAttachment()));
        
        this.assignDocumentId(Collections.singletonList(this.getNewAttachment()), 
                this.createTypeToMaxDocNumber(this.getAward().getAwardAttachments()));
        
        this.newAttachment.setAwardId(this.getAward().getAwardId()); //OJB Hack.  Could not get the awardId to persist with anonymous access in repository file.
        this.newAttachment.setDocumentStatusCode("A");
        this.getAward().addAttachment(this.newAttachment);
        getBusinessObjectService().save(this.newAttachment);

        this.initNewAttachment();
    }
    
    /**
     * retrieves an attachment from a protocol based on a type.
     * 
     * @param <T> the type parameter
     * @param attachmentNumber the attachment number
     * @param type the type token
     * @return the attachment or null if not found
     * @throws IllegalArgumentException if the type is null or not recognized
     */
    public AwardAttachment retrieveExistingAttachment(int attachmentNumber) {
        if (!validIndexForList(attachmentNumber, this.getAward().getAwardAttachments())) {
            return null;
        }
        
        return this.getAward().getAwardAttachments().get(attachmentNumber);
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
     * initializes a new attachment personnel setting the protocol id.
     */
    private void initNewAttachment() {
        this.setNewAttachment(new AwardAttachment(this.getAward()));
    }
    
    /**
     * Creates a map containing the highest doc number from a collection of attachments for each type code.
     * @param <T> the type
     * @param attachments the collection of attachments
     * @return the map
     */
    private Map<String, Integer> createTypeToMaxDocNumber(List<AwardAttachment> attachments) {
        
        final Map<String, Integer> typeToDocNumber = new HashMap<String, Integer>();
        
        for (AwardAttachment attachment : attachments) {
            final Integer curMax = typeToDocNumber.get(attachment.getTypeCode());
            if (curMax == null || curMax.intValue() < attachment.getDocumentId().intValue()) {
                typeToDocNumber.put(attachment.getTypeCode(), attachment.getDocumentId());
            }
        }
        
        return typeToDocNumber;
    }
    
    /** 
     * assigns a document id to all attachments in the passed in collection based on the passed in type to doc number map. 
     * 
     * @param <T> the type of attachments
     * @param attachments the collection of attachments that require doc number assignment
     * @param typeToDocNumber the map that contains all the highest doc numbers of existing attachments based on type code
     */
    private void assignDocumentId(List<AwardAttachment> attachments,
        final Map<String, Integer> typeToDocNumber) {
        for (AwardAttachment attachment : attachments) {
            if (attachment.isNew()) {
                final Integer nextDocNumber = AwardAttachmentFormBean.createNextDocNumber(typeToDocNumber.get(attachment.getTypeCode()));
                attachment.setDocumentId(nextDocNumber);
            }
        }
    }
    
    /**
     * Creates the next doc number from a passed in doc number.  If null 1 is returned.
     * @param docNumber the doc number to base the new number off of.
     * @return the new doc number.
     */
    private static Integer createNextDocNumber(final Integer docNumber) {
        return docNumber == null ? NumberUtils.INTEGER_ONE : Integer.valueOf(docNumber.intValue() + 1);
    }
    
    
    
    
    
    
    /** 
     * refreshes a given Collection of attachment's references that can change.
     * @param attachments the attachments.
     */
    private void refreshAttachmentReferences(List<AwardAttachment> attachments) {
        assert attachments != null : "the attachments was null";
        
        for (final AwardAttachment attachment : attachments) {   
                attachment.refreshReferenceObject("type");
        }
    }
    
    /** 
     * Syncs all new files for a given Collection of attachments on the award.
     * @param attachments the attachments.
     */
    private void syncNewFiles(List<AwardAttachment> attachments) {
        assert attachments != null : "the attachments was null";
        
        for (AwardAttachment attachment : attachments) {
            if (AwardAttachmentFormBean.doesNewFileExist(attachment)) {
                final AttachmentFile newFile = AttachmentFile.createFromFormFile(attachment.getNewFile());
                //setting the sequence number to the old file sequence number
                if (attachment.getFile() != null) {
                    newFile.setSequenceNumber(attachment.getFile().getSequenceNumber());
                }
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
    private static boolean doesNewFileExist(AwardAttachment attachment) {
        return attachment.getNewFile() != null && StringUtils.isNotBlank(attachment.getNewFile().getFileName());
    }

    


    private BusinessObjectService getBusinessObjectService() {
        return KcServiceLocator.getService(BusinessObjectService.class);
    }






	public boolean isCanViewSharedDoc() {
		return canViewSharedDoc;
	}






	public void setCanViewSharedDoc(boolean canViewSharedDoc) {
		this.canViewSharedDoc = canViewSharedDoc;
	}






	public String getAwardSharedDocTypes() {
		return awardSharedDocTypes;
	}






	public void setAwardSharedDocTypes(String awardSharedDocTypes) {
		this.awardSharedDocTypes = awardSharedDocTypes;
	}
}