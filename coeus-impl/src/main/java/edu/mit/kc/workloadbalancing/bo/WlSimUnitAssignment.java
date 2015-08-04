package edu.mit.kc.workloadbalancing.bo;

import org.kuali.coeus.common.framework.unit.Unit;
import org.kuali.coeus.common.framework.unit.admin.UnitAdministrator;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

import javax.persistence.*;

@Entity
@Table(name = "WL_SIM_UNIT_ASSIGNMENTS")
public class WlSimUnitAssignment extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_SIM_UNIT_ASSIGNMENTS_ID")
    @GeneratedValue(generator = "SEQ_SIM_UNIT_ASSIGNMENTS_ID")
	@Id
	@Column(name = "SIM_UNIT_ASSIGNMENTS_ID")
	private String unitAssignmentId;

    @Column(name="SIM_ID")
    private String simId;

	@Column(name = "PERSON_ID")
	private String personId;

	@Column(name = "UNIT_NUMBER")
	private String unitNum;

    @ManyToOne(cascade = { CascadeType.REFRESH })
    @JoinColumn(name = "UNIT_NUMBER", referencedColumnName = "UNIT_NUMBER", insertable = false, updatable = false)
    private Unit unit;

    public WlSimUnitAssignment() {
    }

    public WlSimUnitAssignment(UnitAdministrator unitAdministrator) {
        this.personId = unitAdministrator.getPersonId();
        this.unit = unitAdministrator.getUnit();
        this.unitNum = unitAdministrator.getUnitNumber();
    }

    public String getUnitAssignmentId() {
		return unitAssignmentId;
	}

	public void setUnitAssignmentId(String unitAssignmentId) {
		this.unitAssignmentId = unitAssignmentId;
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

    public String getUnitNum() {
        return unitNum;
    }

    public void setUnitNum(String unitNum) {
        this.unitNum = unitNum;
    }

    public Unit getUnit() {
        return unit;
    }

    public void setUnit(Unit unit) {
        this.unit = unit;
    }

}
