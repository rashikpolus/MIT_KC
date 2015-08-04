/*
 * Copyright 2005-2014 The Kuali Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.osedu.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kuali.kra.institutionalproposal.home;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;


public class InstitutionalProposalAttachmentType extends KcPersistableBusinessObjectBase  {
	
	private static final long serialVersionUID = 391856374612054089L;

    private Integer attachmentTypeCode;

    private String description;
    
    private boolean allowMultiple;

    /**
     * empty ctor to satisfy JavaBean convention.
     */
    public InstitutionalProposalAttachmentType() {
        super();
    }

    /**
     * Gets the proposal attachment type code.
     * @return the proposal attachment type code
     */
    public Integer getAttachmentTypeCode() {
        return this.attachmentTypeCode;
    }

    /**
     * Sets the proposal attachment type code.
     * @param code the proposal attachment type code
     */
    public void setAttachmentTypeCode(Integer attachmentTypeCode) {
        this.attachmentTypeCode = attachmentTypeCode;
    }

    /**
     * Gets the proposal attachment type description.
     * @return the proposal attachment type description
     */
    public String getDescription() {
        return this.description;
    }

    /**
     * Sets the proposal attachment type description.
     * @param description the proposal attachment type description
     */
    public void setDescription(String description) {
        this.description = description;
    }

	/**
	 * @return the allowMultiple
	 */
	public boolean getAllowMultiple() {
		return allowMultiple;
	}

	/**
	 * @param allowMultiple the allowMultiple to set
	 */
	public void setAllowMultiple(boolean allowMultiple) {
		this.allowMultiple = allowMultiple;
	}

    

    
}
