package edu.mit.kc.workloadbalancing.bo;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "WL_SIM_FLEXIBILITY")
public class WlSimFlexibility extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_SIM_FLEXIBILITY_ID")
    @GeneratedValue(generator = "SEQ_SIM_FLEXIBILITY_ID")
	@Id
	@Column(name = "SIM_FLEXIBILITY_ID")
	private String flexibilityId;

    @Column(name="SIM_ID")
    private String simId;

	@Column(name = "PERSON_ID")
	private String personId;

	@Column(name = "SPONSOR_GROUP")
	private String sponsorGroup;

	@Column(name = "FLEXIBILITY")
	private String flexibility;

    public WlSimFlexibility() {
    }

    public WlSimFlexibility(WlFlexibility flexibility) {
        this.personId = flexibility.getPersonId();
        this.sponsorGroup = flexibility.getSponsorGroup();
        this.flexibility  = flexibility.getFlexibility();
    }

    public String getFlexibilityId() {
		return flexibilityId;
	}

	public void setFlexibilityId(String flexibilityId) {
		this.flexibilityId = flexibilityId;
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

	public String getSponsorGroup() {
		return sponsorGroup;
	}

	public void setSponsorGroup(String sponsorGroup) {
		this.sponsorGroup = sponsorGroup;
	}

	public String getFlexibility() {
		return flexibility;
	}

	public void setFlexibility(String flexibility) {
		this.flexibility = flexibility;
	}
}
