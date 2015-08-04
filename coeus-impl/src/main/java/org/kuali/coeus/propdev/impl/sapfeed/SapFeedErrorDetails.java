package org.kuali.coeus.propdev.impl.sapfeed;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

@Entity
@Table(name = "SAP_FEED_ERROR_LOG")
public class SapFeedErrorDetails extends KcPersistableBusinessObjectBase {
	
	@Id
    @Column(name = "SAP_FEED_ERROR_ID")
	private Long errorId;
	
	@Column(name = "SAP_FEED_BATCH_ID")
	private Long sapFeedBatchId;
	
    @Column(name = "BATCH_ID")
	private Long batchId;
	
	
	@Column(name = "FEED_ID")
	private Long feedId;
	
	@Column(name = "ERROR_MESSAGE")
	private String errorMessage;
	
	public Long getErrorId() {
		return errorId;
	}

	public void setErrorId(Long errorId) {
		this.errorId = errorId;
	}


	public Long getBatchId() {
		return batchId;
	}

	public void setBatchId(Long batchId) {
		this.batchId = batchId;
	}

	public Long getFeedId() {
		return feedId;
	}

	public void setFeedId(Long feedId) {
		this.feedId = feedId;
	}

	public String getErrorMessage() {
		return errorMessage;
	}

	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}

	public Long getSapFeedBatchId() {
		return sapFeedBatchId;
	}

	public void setSapFeedBatchId(Long sapFeedBatchId) {
		this.sapFeedBatchId = sapFeedBatchId;
	}
	
}
