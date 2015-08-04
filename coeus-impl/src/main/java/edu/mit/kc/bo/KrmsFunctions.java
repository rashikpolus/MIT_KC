package edu.mit.kc.bo;

import java.util.List;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

/**
 * This class is only for Krms functions lookup
 */

@Entity
@Table(name = "KRMS_FUNC_T")
public final class KrmsFunctions extends  KcPersistableBusinessObjectBase {
	
    @Id
    @Column(name = "FUNC_ID")
    private String id;

    @Column(name = "NMSPC_CD")
    private String namespace;

    @Column(name = "NM")
    private String name;

    @Column(name = "DESC_TXT")
    private String description;

    @Column(name = "RTRN_TYP")
    private String returnType;

    @Column(name = "TYP_ID")
    private String typeId;
    
    @Column(name = "ACTV")
    private String active;
    
    @Column(name = "VER_NBR" , insertable=false, updatable=false )
    private String versionNo;
    
    private List<KrmsFunctionsParams> functionsParams;
    
    public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getNamespace() {
		return namespace;
	}

	public void setNamespace(String namespace) {
		this.namespace = namespace;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getReturnType() {
		return returnType;
	}

	public void setReturnType(String returnType) {
		this.returnType = returnType;
	}

	public String getTypeId() {
		return typeId;
	}

	public void setTypeId(String typeId) {
		this.typeId = typeId;
	}
    
    public String getActive() {
		return active;
	}

	public void setActive(String active) {
		this.active = active;
	}

	public String getVersionNo() {
		return versionNo;
	}

	public void setVersionNo(String versionNo) {
		this.versionNo = versionNo;
	}

    public List<KrmsFunctionsParams> getFunctionsParams() {
	return functionsParams;
    }

    public void setFunctionsParams(List<KrmsFunctionsParams> functionsParams) {
	this.functionsParams = functionsParams;
    }
}
