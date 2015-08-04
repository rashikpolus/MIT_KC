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

import org.apache.struts.upload.FormFile;
import org.kuali.coeus.sys.api.model.KcFile;
import org.kuali.coeus.common.framework.version.sequence.associate.SeparateAssociate;

import java.io.IOException;
import java.util.Arrays;

/**
 * Represents a Attachment File.
 */
public class InstitutionalProposalAttachmentsData extends SeparateAssociate implements KcFile {

    /** the max file name length. length={@value}*/
    public static final int MAX_FILE_NAME_LENGTH = 150;

    /** the max file type length. length={@value}*/
    public static final int MAX_FILE_TYPE_LENGTH = 250;

    private static final long serialVersionUID = 8999619585664343780L;
    
    private Long proposalAttachmentsDataId;
    
    private Long proposalId;
    
    private String proposalNumber;
    
    private Integer attachmentNumber; 
    
    private String name;

    private String type;
    
    private Integer sequenceNumber;

    private byte[] data;
    
    
    /**
     * empty ctor to satisfy JavaBean convention.
     */
    public InstitutionalProposalAttachmentsData() {
        super();
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
	 * @return the name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * @return the type
	 */
	public String getType() {
		return type;
	}

	/**
	 * @param type the type to set
	 */
	public void setType(String type) {
		this.type = type;
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
     * Convenience ctor to set the relevant properties of this class.
     * 
     * <p>
     * This ctor does not validate any of the properties.
     * </p>
     * 
     * @param name the name.
     * @param type the type.
     * @param data the data.
     */
    public InstitutionalProposalAttachmentsData(String name, String type, byte[] data) {
        this.setName(name);
        this.setType(type);
        this.setData(data);
    }

	/**
     * factory method creating an instance from a {@link FormFile FormFile}.
     * <p>
     * If the file name's length > {@link #MAX_FILE_NAME_LENGTH} then the name will be
     * modified.
     * </p>
     * 
     * <p>
     * If the file type's length > {@link #MAX_FILE_TYPE_LENGTH} then the type will be
     * modified.
     * </p>
     * @param formFile the {@link FormFile FormFile}
     * @return an instance
     * @throws IllegalArgumentException if the formfile is null.
     * @throws CreateException if unable to create from FormFile.
     */
    public static final InstitutionalProposalAttachmentsData createFromFormFile(FormFile formFile) {
        if (formFile == null) {
            throw new IllegalArgumentException("the formFile is null");
        }
        final String fName = removeFrontForLength(formFile.getFileName(), MAX_FILE_NAME_LENGTH);
        final String fType = removeFrontForLength(formFile.getContentType(), MAX_FILE_TYPE_LENGTH);
        try {
            return new InstitutionalProposalAttachmentsData(fName, fType, formFile.getFileData());
        } catch (IOException e) {
            throw new CreateException(e);
        }
    }

    /**
     * Removes the start of String in order to meet the passed in length.
     * @param aString the string.
     * @param aLength the length.
     * @return the modified string.
     */
    private static String removeFrontForLength(String aString, int aLength) {
        assert aString != null : "aString is null";
        assert aLength > 0 : "aLength is negative: " + aLength;
        if (aString.length() > aLength) {
            StringBuilder tempString = new StringBuilder(aString);
            tempString.delete(0, tempString.length() - aLength);
            return tempString.toString();
        }
        return aString;
    }

    /**
     * Gets the Proposal Attachment File data.
     * @return the Proposal Attachment File data
     */
    public byte[] getData() {
        return (this.data == null) ? null : this.data.clone();
    }

    /**
     * Sets the Proposal Attachment File data.
     * @param data the Proposal Attachment File data
     */
    public void setData(byte[] data) {
        this.data = (data == null) ? null : data.clone();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Arrays.hashCode(this.getData());
        result = prime * result + ((this.getName() == null) ? 0 : this.getName().hashCode());
        result = prime * result + ((this.getType() == null) ? 0 : this.getType().hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (this.getClass() != obj.getClass()) {
            return false;
        }
        InstitutionalProposalAttachmentsData other = (InstitutionalProposalAttachmentsData) obj;
        if (!Arrays.equals(this.getData(), other.getData())) {
            return false;
        }
        if (this.getName() == null) {
            if (other.getName() != null) {
                return false;
            }
        } else if (!this.getName().equals(other.getName())) {
            return false;
        }
        if (this.getType() == null) {
            if (other.getType() != null) {
                return false;
            }
        } else if (!this.getType().equals(other.getType())) {
            return false;
        }
        return true;
    }

    /**
     * Exception thrown when unable to create instance from static factory.
     */
    public static class CreateException extends RuntimeException {

        private static final long serialVersionUID = -230592614193518930L;

        /**
         * Wraps caused-by Throwable.
         * @param t the Throwable
         */
        public CreateException(Throwable t) {
            super(t);
        }
    }

}
