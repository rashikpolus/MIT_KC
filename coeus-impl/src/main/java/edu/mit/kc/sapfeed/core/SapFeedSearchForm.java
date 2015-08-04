package edu.mit.kc.sapfeed.core;

import org.kuali.coeus.propdev.impl.sapfeed.SapFeedBatchDetails;
import org.kuali.coeus.propdev.impl.sapfeed.SapFeedDetails;
import org.kuali.rice.krad.web.form.UifFormBase;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class SapFeedSearchForm extends UifFormBase {

    private List<SapFeedDetails> detailsSearchResults = new ArrayList<SapFeedDetails>();
    private List<SapFeedBatchDetails> batchSearchResults = new ArrayList<SapFeedBatchDetails>();

    private String searchType;
    private String batchId;
    private Timestamp batchStartDate;
    private Timestamp batchEndDate;
    private String awardNumber;
    private String searchSummary = "";

    private String resendBatchType;
    private String resendBatchId;
    private String resendSapFeedBatchId;
    private String resendTargetDirectory;

    public List<SapFeedBatchDetails> getBatchSearchResults() {
        return batchSearchResults;
    }

    public void setBatchSearchResults(List<SapFeedBatchDetails> batchSearchResults) {
        this.batchSearchResults = batchSearchResults;
    }

    public List<SapFeedDetails> getDetailsSearchResults() {
        return detailsSearchResults;
    }

    public void setDetailsSearchResults(List<SapFeedDetails> detailsSearchResults) {
        this.detailsSearchResults = detailsSearchResults;
    }

    public String getSearchType() {
        return searchType;
    }

    public void setSearchType(String searchType) {
        this.searchType = searchType;
    }

    public String getBatchId() {
        return batchId;
    }

    public void setBatchId(String batchId) {
        this.batchId = batchId;
    }

    public Timestamp getBatchStartDate() {
        return batchStartDate;
    }

    public void setBatchStartDate(Timestamp batchStartDate) {
        this.batchStartDate = batchStartDate;
    }

    public Timestamp getBatchEndDate() {
        return batchEndDate;
    }

    public void setBatchEndDate(Timestamp batchEndDate) {
        this.batchEndDate = batchEndDate;
    }

    public String getAwardNumber() {
        return awardNumber;
    }

    public void setAwardNumber(String awardNumber) {
        this.awardNumber = awardNumber;
    }

    public String getSearchSummary() {
        return searchSummary;
    }

    public void setSearchSummary(String searchSummary) {
        this.searchSummary = searchSummary;
    }

    public String getResendBatchType() {
        return resendBatchType;
    }

    public void setResendBatchType(String resendBatchType) {
        this.resendBatchType = resendBatchType;
    }

    public String getResendBatchId() {
        return resendBatchId;
    }

    public void setResendBatchId(String resendBatchId) {
        this.resendBatchId = resendBatchId;
    }

    public String getResendSapFeedBatchId() {
        return resendSapFeedBatchId;
    }

    public void setResendSapFeedBatchId(String resendSapFeedBatchId) {
        this.resendSapFeedBatchId = resendSapFeedBatchId;
    }

    public String getResendTargetDirectory() {
        return resendTargetDirectory;
    }

    public void setResendTargetDirectory(String resendTargetDirectory) {
        this.resendTargetDirectory = resendTargetDirectory;
    }
}
