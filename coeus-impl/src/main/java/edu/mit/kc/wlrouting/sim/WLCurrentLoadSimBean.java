package edu.mit.kc.wlrouting.sim;

import java.sql.Date;
import java.sql.Timestamp;

public class WLCurrentLoadSimBean {
	
	private Long simCurrentLoadId;
    private Integer simId;
    private String routingNumber; 
    private String proposalNumber;
    private String originalApproverPersonId; 
    private String originalApproverUserId; 
    private String wlAssignedPersonId; 
    private String wlAssignedUserId; 
    private String simulatedPersonId; 
    private String simulatedUserId; 
    private String sponsorCode; 
    private String sponsorGroup; 
    private Double complexity; 
    private String leadUnit; 
    private String activityTypeCode;
    private String activeFlag; 
    private Timestamp arrivalDate; 
    private Date inactiveDate; 
    private String reroutedFlag;
    private String assignedBy;
    private Date updateTimestamp; 
    private String updateUser;
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
	public Double getComplexity() {
		return complexity;
	}
	/**
	 * @param complexity the complexity to set
	 */
	public void setComplexity(Double complexity) {
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
	public Date getInactiveDate() {
		return inactiveDate;
	}
	/**
	 * @param inactiveDate the inactiveDate to set
	 */
	public void setInactiveDate(Date inactiveDate) {
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
	 * @return the updateTimestamp
	 */
	public Date getUpdateTimestamp() {
		return updateTimestamp;
	}
	/**
	 * @param updateTimestamp the updateTimestamp to set
	 */
	public void setUpdateTimestamp(Date updateTimestamp) {
		this.updateTimestamp = updateTimestamp;
	}
	/**
	 * @return the updateUser
	 */
	public String getUpdateUser() {
		return updateUser;
	}
	/**
	 * @param updateUser the updateUser to set
	 */
	public void setUpdateUser(String updateUser) {
		this.updateUser = updateUser;
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
