package edu.mit.kc.workloadbalancing.bo;


import java.sql.Date;
import java.sql.Timestamp;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

@Entity
@Table(name = "WL_SIM_CURRENT_LOAD")
public class WLCurrentLoadSim extends KcPersistableBusinessObjectBase{
	
	@Id
	@Column(name = "SIM_CURRENT_LOAD_ID")
	private Long simCurrentLoadId;
	
	@Id
	@Column(name = "SIM_ID")
    private Integer simId;
	
	@Id
	@Column(name = "ROUTING_NUMBER")
    private String routingNumber; 
	
	@Id
	@Column(name = "PROPOSAL_NUMBER")
    private String proposalNumber;
	
	@Id
	@Column(name = "POC_PERSON_ID")
    private String originalApproverPersonId; 
	
	@Id
	@Column(name = "POC_USER_ID")
    private String originalApproverUserId; 
	
	@Id
	@Column(name = "APPROVER_USER_ID")
    private String wlAssignedPersonId; 
	
	@Id
	@Column(name = "APPROVER_PERSON_ID")
    private String wlAssignedUserId; 
	
	@Id
	@Column(name = "SIM_PERSON_ID")
    private String simulatedPersonId; 
	
	@Id
	@Column(name = "SIM_USER_ID")
    private String simulatedUserId; 
	
	@Id
	@Column(name = "SPONSOR_CODE")
    private String sponsorCode; 
	
	@Id
	@Column(name = "SPONSOR_GROUP")
    private String sponsorGroup; 
	
	@Id
	@Column(name = "COMPLEXITY")
    private Long complexity; 
	
	@Id
	@Column(name = "LEAD_UNIT")
    private String leadUnit; 
	
	
    private String activityTypeCode;
	
	@Id
	@Column(name = "ACTIVE_FLAG")
    private String activeFlag; 
	
	@Id
	@Column(name = "ARRIVAL_DATE")
    private Timestamp arrivalDate; 
	
	@Id
	@Column(name = "INACTIVE_DATE")
    private Timestamp inactiveDate; 
	
	@Id
	@Column(name = "REROUTED_FLAG")
    private String reroutedFlag;
	
	@Id
	@Column(name = "ASSIGNED_BY")
    private String assignedBy;
	
	
    private String ospLead;
	
	/**
	 * @return the simCurrentLoadId
	 */
	public Long getSimCurrentLoadId() {
		return simCurrentLoadId;
	}
	/**
	 * @param simCurrentLoadId the simCurrentLoadId to set
	 */
	public void setSimCurrentLoadId(Long simCurrentLoadId) {
		this.simCurrentLoadId = simCurrentLoadId;
	}
	/**
	 * @return the simId
	 */
	public Integer getSimId() {
		return simId;
	}
	/**
	 * @param simId the simId to set
	 */
	public void setSimId(Integer simId) {
		this.simId = simId;
	}
	/**
	 * @return the routingNumber
	 */
	public String getRoutingNumber() {
		return routingNumber;
	}
	/**
	 * @param routingNumber the routingNumber to set
	 */
	public void setRoutingNumber(String routingNumber) {
		this.routingNumber = routingNumber;
	}
	/**
	 * @return the prposalNumber
	 */
	public String getProposalNumber() {
		return proposalNumber;
	}
	/**
	 * @param prposalNumber the prposalNumber to set
	 */
	public void setProposalNumber(String proposalNumber) {
		this.proposalNumber = proposalNumber;
	}
	/**
	 * @return the originalApproverPersonId
	 */
	public String getOriginalApproverPersonId() {
		return originalApproverPersonId;
	}
	/**
	 * @param originalApproverPersonId the originalApproverPersonId to set
	 */
	public void setOriginalApproverPersonId(String originalApproverPersonId) {
		this.originalApproverPersonId = originalApproverPersonId;
	}
	/**
	 * @return the originalApproverUserId
	 */
	public String getOriginalApproverUserId() {
		return originalApproverUserId;
	}
	/**
	 * @param originalApproverUserId the originalApproverUserId to set
	 */
	public void setOriginalApproverUserId(String originalApproverUserId) {
		this.originalApproverUserId = originalApproverUserId;
	}
	/**
	 * @return the wlAssignedPersonId
	 */
	public String getWlAssignedPersonId() {
		return wlAssignedPersonId;
	}
	/**
	 * @param wlAssignedPersonId the wlAssignedPersonId to set
	 */
	public void setWlAssignedPersonId(String wlAssignedPersonId) {
		this.wlAssignedPersonId = wlAssignedPersonId;
	}
	/**
	 * @return the wlAssignedUserId
	 */
	public String getWlAssignedUserId() {
		return wlAssignedUserId;
	}
	/**
	 * @param wlAssignedUserId the wlAssignedUserId to set
	 */
	public void setWlAssignedUserId(String wlAssignedUserId) {
		this.wlAssignedUserId = wlAssignedUserId;
	}
	/**
	 * @return the simulatedPersonId
	 */
	public String getSimulatedPersonId() {
		return simulatedPersonId;
	}
	/**
	 * @param simulatedPersonId the simulatedPersonId to set
	 */
	public void setSimulatedPersonId(String simulatedPersonId) {
		this.simulatedPersonId = simulatedPersonId;
	}
	/**
	 * @return the simulatedUserId
	 */
	public String getSimulatedUserId() {
		return simulatedUserId;
	}
	/**
	 * @param simulatedUserId the simulatedUserId to set
	 */
	public void setSimulatedUserId(String simulatedUserId) {
		this.simulatedUserId = simulatedUserId;
	}
	/**
	 * @return the sponsorCode
	 */
	public String getSponsorCode() {
		return sponsorCode;
	}
	/**
	 * @param sponsorCode the sponsorCode to set
	 */
	public void setSponsorCode(String sponsorCode) {
		this.sponsorCode = sponsorCode;
	}
	/**
	 * @return the sponsorGroup
	 */
	public String getSponsorGroup() {
		return sponsorGroup;
	}
	/**
	 * @param sponsorGroup the sponsorGroup to set
	 */
	public void setSponsorGroup(String sponsorGroup) {
		this.sponsorGroup = sponsorGroup;
	}
	/**
	 * @return the complexity
	 */
	public Long getComplexity() {
		return complexity;
	}
	/**
	 * @param complexity the complexity to set
	 */
	public void setComplexity(Long complexity) {
		this.complexity = complexity;
	}
	/**
	 * @return the leadUnit
	 */
	public String getLeadUnit() {
		return leadUnit;
	}
	/**
	 * @param leadUnit the leadUnit to set
	 */
	public void setLeadUnit(String leadUnit) {
		this.leadUnit = leadUnit;
	}
	/**
	 * @return the activeFlag
	 */
	public String getActiveFlag() {
		return activeFlag;
	}
	/**
	 * @param activeFlag the activeFlag to set
	 */
	public void setActiveFlag(String activeFlag) {
		this.activeFlag = activeFlag;
	}
	/**
	 * @return the arrivalDate
	 */
	public Timestamp getArrivalDate() {
		return arrivalDate;
	}
	/**
	 * @param arrivalDate the arrivalDate to set
	 */
	public void setArrivalDate(Timestamp arrivalDate) {
		this.arrivalDate = arrivalDate;
	}
	/**
	 * @return the inactiveDate
	 */
	public Timestamp getInactiveDate() {
		return inactiveDate;
	}
	/**
	 * @param inactiveDate the inactiveDate to set
	 */
	public void setInactiveDate(Timestamp inactiveDate) {
		this.inactiveDate = inactiveDate;
	}
	/**
	 * @return the reroutedFlag
	 */
	public String getReroutedFlag() {
		return reroutedFlag;
	}
	/**
	 * @param reroutedFlag the reroutedFlag to set
	 */
	public void setReroutedFlag(String reroutedFlag) {
		this.reroutedFlag = reroutedFlag;
	}
	/**
	 * @return the assignedBy
	 */
	public String getAssignedBy() {
		return assignedBy;
	}
	/**
	 * @param assignedBy the assignedBy to set
	 */
	public void setAssignedBy(String assignedBy) {
		this.assignedBy = assignedBy;
	}
	
	/**
	 * @return the activityTypeCode
	 */
	public String getActivityTypeCode() {
		return activityTypeCode;
	}
	/**
	 * @param activityTypeCode the activityTypeCode to set
	 */
	public void setActivityTypeCode(String activityTypeCode) {
		this.activityTypeCode = activityTypeCode;
	}
	/**
	 * @return the ospLead
	 */
	public String getOspLead() {
		return ospLead;
	}
	/**
	 * @param ospLead the ospLead to set
	 */
	public void setOspLead(String ospLead) {
		this.ospLead = ospLead;
	}
}
