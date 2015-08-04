package edu.mit.kc.timeandmoney.service;

import java.util.List;
import java.util.Map;

import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardAmountInfo;
import org.kuali.kra.timeandmoney.AwardVersionHistory;
import org.kuali.kra.timeandmoney.TimeAndMoneyDocumentHistory;
import org.kuali.kra.timeandmoney.document.TimeAndMoneyDocument;
import org.kuali.rice.kew.api.exception.WorkflowException;

public interface MitTimeAndMoneyHistoryService {
    void  getTimeAndMoneyHistory(String awardNumber, Map<Object, Object> timeAndMoneyHistory, List<Integer> columnSpan) throws WorkflowException;

    void buildTimeAndMoneyHistoryObjects(String awardNumber, List<AwardVersionHistory> awardVersionHistoryCollection) throws WorkflowException;
    
    public List<TimeAndMoneyDocumentHistory> getDocHistoryAndValidInfosAssociatedWithAwardVersion(List<TimeAndMoneyDocument> docs,
            List<AwardAmountInfo> awardAmountInfos, Award award) throws WorkflowException;

}
