package edu.mit.kc.alert;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.paymentreports.awardreports.reporting.ReportTracking;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.springframework.stereotype.Component;

@Component("reportFetchingService")
public class ReportFetchingServiceImpl implements ReportFetchingService {

	private BusinessObjectService businessObjectService;

	@Override
	public List<ReportTracking> fetchReportsByReportClassCode(
			String awardNumber, String reportClassCode, String frequencyBaseCode) {

		Map<String, String> params = new HashMap<String, String>();
		params.put("awardNumber", awardNumber);
		params.put("reportClassCode", reportClassCode);
		params.put("frequencyBaseCode", frequencyBaseCode);

		List<ReportTracking> reportTrackingCollection = (List<ReportTracking>) this.getBusinessObjectService().findMatching(ReportTracking.class,params);
		return reportTrackingCollection;
	}

	public BusinessObjectService getBusinessObjectService() {
		if (businessObjectService == null) {
			businessObjectService = KcServiceLocator.getService(BusinessObjectService.class);
		}
		return businessObjectService;
	}

	public void setBusinessObjectService(
			BusinessObjectService businessObjectService) {
		this.businessObjectService = businessObjectService;
	}

}
