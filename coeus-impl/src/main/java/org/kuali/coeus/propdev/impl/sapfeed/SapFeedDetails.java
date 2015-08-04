package org.kuali.coeus.propdev.impl.sapfeed;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.sql.Timestamp;

@Entity
@Table(name = "SAP_FEED_DETAILS")
public class SapFeedDetails extends KcPersistableBusinessObjectBase {

    @Id
    @Column(name = "FEED_ID")
    private Integer feedId;

    @Column(name = "AWARD_NUMBER")
    private String awardNumber;

    @Column(name = "SEQUENCE_NUMBER")
    private Integer sequenceNumber;

    @Column(name = "FEED_TYPE")
    private String feedType;

    @Column(name = "FEED_STATUS")
    private String feedStatus;

    @Column(name = "BATCH_ID")
    private String batchId;

    @Column(name = "TRANSACTION_ID")
    private String tranId;

    @Column(name = "SAP_FEED_BATCH_ID")
    private Long sapFeedBatchId;

    @Column(name = "UPDATE_TIMESTAMP")
    private Timestamp updateTimestamp;

    @Column(name = "UPDATE_USER")
    private String updateUser;

    public static enum FeedTypeNames {
        N("New"), C("Change");

        private final String name;

        FeedTypeNames(String name) {
            this.name = name;
        }

        public String getName(){
            return name;
        }
    }

    public static enum FeedStatusNames {
        F("Fed"), E("Error"), R("Rejected"), C("Cancelled"), P("Pending");

        private final String name;

        FeedStatusNames(String name) {
            this.name = name;
        }

        public String getName(){
            return name;
        }
    }

    public String getFeedTypeName(){
        return FeedTypeNames.valueOf(feedType).getName();
    }

    public String getFeedStatusName() {
        return FeedStatusNames.valueOf(feedStatus).getName();
    }

    public boolean isFeedPending() {
        return FeedStatusNames.valueOf(feedStatus).getName().equalsIgnoreCase(FeedStatusNames.P.getName());
    }
    
    public boolean isFeedFed() {
        return FeedStatusNames.valueOf(feedStatus).getName().equalsIgnoreCase(FeedStatusNames.F.getName());
    }
    
    public boolean isFeedRejected() {
        return FeedStatusNames.valueOf(feedStatus).getName().equalsIgnoreCase(FeedStatusNames.R.getName());
    }
    
    public boolean isFeedError() {
        return FeedStatusNames.valueOf(feedStatus).getName().equalsIgnoreCase(FeedStatusNames.E.getName());
    }
    
    public Integer getFeedId() {
        return feedId;
    }

    public void setFeedId(Integer feedId) {
        this.feedId = feedId;
    }

    public String getAwardNumber() {
        return awardNumber;
    }

    public void setAwardNumber(String awardNumber) {
        this.awardNumber = awardNumber;
    }

    public Integer getSequenceNumber() {
        return sequenceNumber;
    }

    public void setSequenceNumber(Integer sequenceNumber) {
        this.sequenceNumber = sequenceNumber;
    }

    public String getFeedType() {
        return feedType;
    }

    public void setFeedType(String feedType) {
        this.feedType = feedType;
    }

    public String getFeedStatus() {
        return feedStatus;
    }

    public void setFeedStatus(String feedStatus) {
        this.feedStatus = feedStatus;
    }

    public String getBatchId() {
        return batchId;
    }

    public void setBatchId(String batchId) {
        this.batchId = batchId;
    }

    public String getTranId() {
        return tranId;
    }

    public void setTranId(String tranId) {
        this.tranId = tranId;
    }

    public Long getSapFeedBatchId() {
        return sapFeedBatchId;
    }

    public void setSapFeedBatchId(Long sapFeedBatchId) {
        this.sapFeedBatchId = sapFeedBatchId;
    }

    public Timestamp getUpdateTimestamp() {
        return updateTimestamp;
    }

    public void setUpdateTimestamp(Timestamp updateTimestamp) {
        this.updateTimestamp = updateTimestamp;
    }

    public String getUpdateUser() {
        return updateUser;
    }

    public void setUpdateUser(String updateUser) {
        this.updateUser = updateUser;
    }
}
