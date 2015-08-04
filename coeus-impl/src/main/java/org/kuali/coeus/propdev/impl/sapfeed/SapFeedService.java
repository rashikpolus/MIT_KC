package org.kuali.coeus.propdev.impl.sapfeed;

import java.sql.SQLException;
import java.util.Map;

import org.kuali.kra.timeandmoney.AwardHierarchyNode;



public interface SapFeedService {
	
	public String generateMasterFeed(String path,String user)
			throws SQLException;
	
	public String generateRolodexFeed(String path,String user)
			throws SQLException;
	
	public String generateSponsorFeed(String path,String user)
			throws SQLException;
	
	public void insertSapFeedDetails(String awardNumber, Integer sequenceNumber, String feedType, String feedStatus);
	
	public void performRejectAction(SapFeedDetails sapFeedDetails);
	
	public void performUndoReject(SapFeedDetails sapFeedDetails);
	
	public void performResendBatch(Integer sapFeedBatchId,Integer batchId,Boolean processSubsequentBatches, String path);
	
	public void updateSapFeedDetails(String awardNumber,Integer sequenceNumber);
	
	public boolean isAwardSapFeedExists(String awardNumber, Integer sequenceNumber);
	
	public void setSapDetailsToWorkInProgress(String awardNumber,Integer sequenceNumber);
	
	public void setAllWorkInProgressSapFeedDetailsToPending(Map<String, AwardHierarchyNode> awardHierarchyNodes);

	public void removeWorkInProgressSapDetails(String awardNumber,Integer sequenceNumber);
	
	public void performCancelAction(SapFeedDetails sapFeedDetails);
	
}
