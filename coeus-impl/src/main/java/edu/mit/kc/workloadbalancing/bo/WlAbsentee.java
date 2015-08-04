package edu.mit.kc.workloadbalancing.bo;

import java.sql.Timestamp;
import java.util.Date;
import javax.persistence.*;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

@Entity
@Table(name = "WL_ABSENTEE")
public class WlAbsentee extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_ABSENTEE_ID")
    @GeneratedValue(generator = "SEQ_ABSENTEE_ID")
	@Id
	@Column(name = "ABSENTEE_ID")
	private String absenteeId;

	@Column(name = "PERSON_ID")
	private String personId;

	@Column(name = "LEAVE_START_DATE")
	private Timestamp leaveStartDate;

	@Column(name = "LEAVE_END_DATE")
	private Timestamp leaveEndDate;

	public String getAbsenteeId() {
		return absenteeId;
	}

	public void setAbsenteeId(String absenteeId) {
		this.absenteeId = absenteeId;
	}

    public String getPersonId() {
		return personId;
	}

	public void setPersonId(String personId) {
		this.personId = personId;
	}

    public Timestamp getLeaveStartDate() {
        return leaveStartDate;
    }

    public void setLeaveStartDate(Timestamp leaveStartDate) {
        this.leaveStartDate = leaveStartDate;
    }

    public Timestamp getLeaveEndDate() {
        return leaveEndDate;
    }

    public void setLeaveEndDate(Timestamp leaveEndDate) {
        this.leaveEndDate = leaveEndDate;
    }
}
