package edu.mit.kc.bo;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.coeus.propdev.impl.attachment.NarrativeType;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.coeus.common.framework.module.CoeusModule;

/**
 * This class is only for PiAppointemnetType lookup
 */

@Entity
@Table(name = "SHARED_DOCUMENT_TYPE")
public final class SharedDocumentType extends  KcPersistableBusinessObjectBase {
	
    @Id
    @Column(name = "SHARED_DOCUMENT_TYPE_ID")
    private Integer sharedDocumentTypeId;
    
    @Column(name = "COEUS_MODULE_CODE")
    private String moduleCode;

    @Column(name = "DOCUMENT_TYPE_CODE")
    private String documentTypeCode;

	private CoeusModule coeusModule;
	
	private NarrativeType narrativeType;

	public String getModuleCode() {
		return moduleCode;
	}

	public void setModuleCode(String moduleCode) {
		this.moduleCode = moduleCode;
	}

	public String getDocumentTypeCode() {
		return documentTypeCode;
	}

	public void setDocumentTypeCode(String documentTypeCode) {
		this.documentTypeCode = documentTypeCode;
	}

	public Integer getSharedDocumentTypeId() {
		return sharedDocumentTypeId;
	}

	public void setSharedDocumentTypeId(Integer sharedDocumentTypeId) {
		this.sharedDocumentTypeId = sharedDocumentTypeId;
	}

	public CoeusModule getCoeusModule() {
		return coeusModule;
	}

	public void setCoeusModule(CoeusModule coeusModule) {
		this.coeusModule = coeusModule;
	}

	public NarrativeType getNarrativeType() {
		return narrativeType;
	}

	public void setNarrativeType(NarrativeType narrativeType) {
		this.narrativeType = narrativeType;
	}

	
}

    
 