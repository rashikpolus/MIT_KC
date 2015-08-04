package edu.mit.kc.workloadbalancing.bo;


import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

import javax.persistence.*;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

@Entity
@Table(name = "WL_SIM_HEADER")
public class WlSimHeader extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_SIM_ID")
    @GeneratedValue(generator = "SEQ_SIM_ID")
	@Id
	@Column(name = "SIM_ID")
    private String simId;

    @Column(name = "DESCRIPTION")
    private String description;

    @Column(name = "SIM_RUN_STATUS_CODE")
    private String statusCode;
    
	
    @Column(name = "SIM_START_DATE")
	private Date startDate;
	
	
	
    @Column(name = "SIM_END_DATE")
	private Date endDate;
   
	public WlSimHeader(){
		
	}
	

	@OneToMany
    @JoinColumn(name = "SIM_ID", referencedColumnName = "SIM_ID", insertable = true, updatable = true)
    List<WlSimFlexibility> flexibilities;

    @OneToMany
    @JoinColumn(name = "SIM_ID", referencedColumnName = "SIM_ID", insertable = true, updatable = true)
    List<WlSimUnitAssignment> unitAssignments;

    @OneToMany
    @JoinColumn(name = "SIM_ID", referencedColumnName = "SIM_ID", insertable = true, updatable = true)
    List<WlSimCapacity> capacities;

    public String getSimId() {
        return simId;
    }

    public void setSimId(String simId) {
        this.simId = simId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(String statusCode) {
        this.statusCode = statusCode;
    }

    public List<WlSimFlexibility> getFlexibilities() {
        return flexibilities;
    }

    public void setFlexibilities(List<WlSimFlexibility> flexibilities) {
        this.flexibilities = flexibilities;
    }

    public List<WlSimUnitAssignment> getUnitAssignments() {
        return unitAssignments;
    }

    public void setUnitAssignments(List<WlSimUnitAssignment> unitAssignments) {
        this.unitAssignments = unitAssignments;
    }

    public List<WlSimCapacity> getCapacities() {
        return capacities;
    }

	public void setCapacities(List<WlSimCapacity> capacities) {
        this.capacities = capacities;
    }
    
	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

}
