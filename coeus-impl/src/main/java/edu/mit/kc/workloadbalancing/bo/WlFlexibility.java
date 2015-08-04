package edu.mit.kc.workloadbalancing.bo;

import javax.persistence.*;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

import java.math.BigDecimal;

@Entity
@Table(name = "WL_FLEXIBILITY")
public class WlFlexibility extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_WL_FLEXIBILITY_ID")
    @GeneratedValue(generator = "SEQ_WL_FLEXIBILITY_ID")
	@Id
	@Column(name = "FLEXIBILITY_ID")
	private String flexibilityId;

	@Column(name = "PERSON_ID")
	private String personId;

	@Column(name = "SPONSOR_GROUP")
	private String sponsorGroup;

	@Column(name = "FLEXIBILITY")
	private String flexibility;

    public WlFlexibility() {
    }

    public WlFlexibility(WlSimFlexibility flexibility) {
        this.flexibilityId = flexibility.getFlexibilityId();
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
