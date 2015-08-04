package edu.mit.kc.workloadbalancing.bo;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;


@Entity
@Table(name = "WL_PROP_REVIEW_COMMENTS_V")
public class WlPropReviewComments extends KcPersistableBusinessObjectBase{

	@Id
	@Column(name = "PROPOSAL_NUMBER")
	private String proposalNUmber;
	
	@Id
	@Column(name = "COMMENT_NUMBER")
	private Long commentNumber;
	
	
	@Column(name = "PERSON_ID")
	private String personId;
	
	@Column(name = "CANNED_REVIEW_COMMENT_CODE")
	private Long cannedReviwCommentCode;
	
	
	
	public String getProposalNUmber() {
		return proposalNUmber;
	}

	public void setProposalNUmber(String proposalNUmber) {
		this.proposalNUmber = proposalNUmber;
	}

	

	public Long getCommentNumber() {
		return commentNumber;
	}

	public void setCommentNumber(Long commentNumber) {
		this.commentNumber = commentNumber;
	}

	public Long getCannedReviwCommentCode() {
		return cannedReviwCommentCode;
	}

	public void setCannedReviwCommentCode(Long cannedReviwCommentCode) {
		this.cannedReviwCommentCode = cannedReviwCommentCode;
	}

	public String getPersonId() {
		return personId;
	}

	public void setPersonId(String personId) {
		this.personId = personId;
	}

	
}
