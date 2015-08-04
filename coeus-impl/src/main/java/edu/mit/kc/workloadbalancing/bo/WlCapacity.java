package edu.mit.kc.workloadbalancing.bo;

import javax.persistence.*;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

@Entity
@Table(name = "WL_CAPACITY")
public class WlCapacity extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_WL_CAPACITY_ID")
    @GeneratedValue(generator = "SEQ_WL_CAPACITY_ID")
	@Id
	@Column(name = "WLCAPACITY_ID")
	private String capacityId;

	@Column(name = "PERSON_ID")
	private String personId;

	@Column(name = "CAPACITY")
	private Integer capacity;

    public WlCapacity(){

    }

    public WlCapacity(WlSimCapacity capacity) {
        this.capacityId = capacity.getCapacityId();
        this.personId = capacity.getPersonId();
        this.capacity = capacity.getCapacity();
    }

	public String getCapacityId() {
		return capacityId;
	}

	public void setCapacityId(String capacityId) {
		this.capacityId = capacityId;
	}

	public String getPersonId() {
		return personId;
	}

	public void setPersonId(String personId) {
		this.personId = personId;
	}

	public Integer getCapacity() {
		return capacity;
	}

	public void setCapacity(Integer capacity) {
		this.capacity = capacity;
	}
}
