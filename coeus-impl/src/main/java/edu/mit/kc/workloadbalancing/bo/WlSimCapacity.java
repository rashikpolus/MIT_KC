package edu.mit.kc.workloadbalancing.bo;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

import javax.persistence.*;

@Entity
@Table(name = "WL_SIM_CAPACITY")
public class WlSimCapacity extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_SIM_CAPACITY_ID")
    @GeneratedValue(generator = "SEQ_SIM_CAPACITY_ID")
	@Id
	@Column(name = "SIM_CAPACITY_ID")
	private String capacityId;

    @Column(name="SIM_ID")
    private String simId;

	@Column(name = "PERSON_ID")
	private String personId;

	@Column(name = "CAPACITY")
	private Integer capacity;

    public WlSimCapacity(){

    }

    public WlSimCapacity(WlCapacity capacity) {
        this.personId = capacity.getPersonId();
        this.capacity = capacity.getCapacity();
    }

    public String getCapacityId() {
		return capacityId;
	}

	public void setCapacityId(String capacityId) {
		this.capacityId = capacityId;
	}

    public String getSimId() {
        return simId;
    }

    public void setSimId(String simId) {
        this.simId = simId;
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
