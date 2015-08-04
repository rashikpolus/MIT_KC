package edu.mit.kc.bo;

import java.util.List;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

/**
 * This class is only for PiAppointemnetType lookup
 */

@Entity
@Table(name = "PI_APPOINTMENT_TYPE")
public final class PiAppointmentType extends  KcPersistableBusinessObjectBase {
	
    @Id
    @Column(name = "PI_APPOINT_TYPE_CODE")
    private String typeCode;

    @Column(name = "DESCRIPTION")
    private String description;

	public String getTypeCode() {
		return typeCode;
	}

	public void setTypeCode(String typeCode) {
		this.typeCode = typeCode;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}


}

    
 