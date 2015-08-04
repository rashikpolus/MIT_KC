package edu.mit.kc.alert;

import java.util.List;
import org.kuali.kra.award.paymentreports.awardreports.reporting.ReportTracking;

public interface ReportFetchingService {
	
	public List<ReportTracking> fetchReportsByReportClassCode(String awardNumber,String reportClassCode,String frequencyBaseCode);
}
