package edu.mit.kc.wh;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;



@Entity
@Table(name = "WAREHOUSE_PERSON")
public class WareHousePerson{
	
	
	@Id
	@Column(name = "PERSON_ID")
	private String personId;
	
	@Column(name = "RESIDENCY_STATUS_CODE")
	private String residencyStatusCode;
	

	public String getPersonId() {
		return personId;
	}

	public void setPersonId(String personId) {
		this.personId = personId;
	}

	public String getResidencyStatusCode() {
		return residencyStatusCode;
	}

	public void setResidencyStatusCode(String residencyStatusCode) {
		this.residencyStatusCode = residencyStatusCode;
	}

	

}
