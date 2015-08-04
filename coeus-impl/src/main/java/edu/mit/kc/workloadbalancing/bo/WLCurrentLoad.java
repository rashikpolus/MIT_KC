package edu.mit.kc.workloadbalancing.bo;


import java.sql.Date;
import java.sql.Timestamp;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

@Entity
@Table(name = "WL_CURRENT_LOAD")
public class WLCurrentLoad extends KcPersistableBusinessObjectBase{
	
    @PortableSequenceGenerator(name = "SEQ_WL_CURRENT_LOAD_ID")
    @GeneratedValue(generator = "SEQ_WL_CURRENT_LOAD_ID")
	@Id
	@Column(name = "LOAD_ID")
	private Long loadId;
	
	@Column(name = "PROPOSAL_NUMBER")
	private String proposalNumber;
	
	@Column(name = "SPONSOR_CODE")
	private String sponsorCode;
	
	@Column(name = "ROUTING_NUMBER")
	private String routingNumber;
	
	@Column(name = "PERSON_ID")
	private String person_id;
	
	@Column(name = "LEAD_UNIT")
	private String leadUnit;
	
	@Column(name = "USER_ID")
	private String userId;
	
	@Column(name = "ORIG_APPROVER")
	private String originalApprover;
	
	@Column(name = "ORIG_USER_ID")
	private String originalUserId;
	
	@Column(name = "SPONSOR_GROUP")
	private String sponsorGroup;
	
	@Column(name = "ACTIVE_FLAG")
	private String activeFlag;
	
	@Column(name = "REROUTED_FLAG")
	private String reroutedFlag;
	
	@Column(name = "ASSIGNED_BY")
	private String assignedBy;
	
	@Column(name = "LAST_APPROVER")
	private String lastApprover;
	
	@Column(name = "COMPLEXITY")
	private Long complexity;
	
	@Column(name = "ARRIVAL_DATE")
	private Timestamp arrivalDate;
	
	@Column(name = "INACTIVE_DATE")
	private Timestamp inactiveDate;
	
	 
	/**
	 * @return the proposalNumber
	 */
	public String getProposalNumber() {
		return proposalNumber;
	}
	/**
	 * @param proposalNumber the proposalNumber to set
	 */
	public void setProposalNumber(String proposalNumber) {
		this.proposalNumber = proposalNumber;
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
	 * @return the person_id
	 */
	public String getPerson_id() {
		return person_id;
	}
	/**
	 * @param person_id the person_id to set
	 */
	public void setPerson_id(String person_id) {
		this.person_id = person_id;
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
	 * @return the userId
	 */
	public String getUserId() {
		return userId;
	}
	/**
	 * @param userId the userId to set
	 */
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public Long getLoadId() {
		return loadId;
	}
	public void setLoadId(Long loadId) {
		this.loadId = loadId;
	}
	public String getOriginalApprover() {
		return originalApprover;
	}
	public void setOriginalApprover(String originalApprover) {
		this.originalApprover = originalApprover;
	}
	public String getOriginalUserId() {
		return originalUserId;
	}
	public void setOriginalUserId(String originalUserId) {
		this.originalUserId = originalUserId;
	}
	public String getSponsorGroup() {
		return sponsorGroup;
	}
	public void setSponsorGroup(String sponsorGroup) {
		this.sponsorGroup = sponsorGroup;
	}
	public String getActiveFlag() {
		return activeFlag;
	}
	public void setActiveFlag(String activeFlag) {
		this.activeFlag = activeFlag;
	}
	public String getReroutedFlag() {
		return reroutedFlag;
	}
	public void setReroutedFlag(String reroutedFlag) {
		this.reroutedFlag = reroutedFlag;
	}
	public String getAssignedBy() {
		return assignedBy;
	}
	public void setAssignedBy(String assignedBy) {
		this.assignedBy = assignedBy;
	}
	public String getLastApprover() {
		return lastApprover;
	}
	public void setLastApprover(String lastApprover) {
		this.lastApprover = lastApprover;
	}
	public Long getComplexity() {
		return complexity;
	}
	public void setComplexity(Long complexity) {
		this.complexity = complexity;
	}
	public Timestamp getArrivalDate() {
		return arrivalDate;
	}
	public void setArrivalDate(Timestamp arrivalDate) {
		this.arrivalDate = arrivalDate;
	}
	public Timestamp getInactiveDate() {
		return inactiveDate;
	}
	public void setInactiveDate(Timestamp inactiveDate) {
		this.inactiveDate = inactiveDate;
	}
	


	
}
