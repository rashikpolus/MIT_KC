package edu.mit.kc.alert;

import static org.kuali.rice.core.api.criteria.PredicateFactory.equal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.propdev.impl.dashboard.DashboardService;
import org.kuali.coeus.sys.framework.util.DateUtils;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.paymentreports.awardreports.reporting.ReportTracking;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.krad.data.PersistenceOption;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import edu.mit.kc.alert.service.AlertServiceBaseImpl;
import edu.mit.kc.alert.service.SystemAlertService;
import edu.mit.kc.dashboard.bo.Alert;
import edu.mit.kc.infrastructure.KcMitConstants;

@Component("finalTechnicalReportAlertService")
public class FinalTechnicalReportAlertServiceImpl extends AlertServiceBaseImpl
		implements SystemAlertService {

	@Autowired
	@Qualifier("dashboardService")
	private DashboardService dashboardService;

	@Autowired
	@Qualifier("reportFetchingService")
	private ReportFetchingService reportFetchingService;

	@Autowired
	@Qualifier("dateTimeService")
	private DateTimeService dateTimeService;

	@Autowired
	@Qualifier("kualiConfigurationService")
	private ConfigurationService kualiConfigurationService;

	Alert alert = new Alert();

	public static final String FREQUENCY_BASE_CODE = "4";
	public static final String REPORT_CLASS_CODE = "4";

	@Override
	public void createAlerts(AlertType alertType, String userName) {
		String alertMessage = null;
		List<ReportTracking> reports = null;
		String loggedInUserId = getKcPerson(userName).getPersonId();
		List<ReportTracking> reportTrackings = null;
		List<Award> myAwardsFiltered = getDashboardService().getActiveAwardsForInvestigator(loggedInUserId);

		for (Award award : myAwardsFiltered) {
			reportTrackings = new ArrayList<ReportTracking>();
			alertMessage = getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.FINAL_TECHNICAL_REPORT_ALERT);
			reports = getReportFetchingService().fetchReportsByReportClassCode(award.getAwardNumber(), REPORT_CLASS_CODE,FREQUENCY_BASE_CODE);
			if (reports != null && reports.size() > 0) {
				reportTrackings.addAll(reports);
			}

			for (ReportTracking reportTracking : reportTrackings) {
				if (reportTracking.getDueDate() != null) {
					Date dueDate = reportTracking.getDueDate();
					Date currentDate = DateUtils.clearTimeFields(new Date(System.currentTimeMillis()));
					int diff = getDateTimeService().dateDiff(currentDate,dueDate, true);
					if (diff >= 0 && diff <= 30) {
						if (!StringUtils.isEmpty(alertMessage)) {
							alertMessage = alertMessage.replace("{0}",award.getSponsorName());
							if (award.getAccountNumber() == null)
								alertMessage = alertMessage.replace("{1}", "");
							else {
								alertMessage = alertMessage.replace("{1}",award.getAccountNumber());
							}
							alertMessage = alertMessage.replace("{2}",reportTracking.getDueDate().toString());
						}

						alert.setActive(Constants.YES_FLAG);
						alert.setAlert(alertMessage);
						alert.setUserName(getKcPerson(userName).getUserName());
						alert.setUpdateUser(getKcPerson(userName).getUserName());
						alert.setPriority(1);
						alert.setAlertTypeId(alertType.getId());
						getDataObjectService().save(alert,PersistenceOption.FLUSH);
					}
				}
			}
		}
	}

	@Override
	public void updateAlerts(AlertType alertType, String userName) {

	}

	@Override
	public void cleanUpAlerts(AlertType alertType, String userName) {
		getDataObjectService().deleteMatching(Alert.class,QueryByCriteria.Builder.fromPredicates(equal("alertTypeId",alertType.getId())));

	}

	public ReportFetchingService getReportFetchingService() {
		return reportFetchingService;
	}

	public void setReportFetchingService(
			ReportFetchingService reportFetchingService) {
		this.reportFetchingService = reportFetchingService;
	}

	public DateTimeService getDateTimeService() {
		return dateTimeService;
	}

	public void setDateTimeService(DateTimeService dateTimeService) {
		this.dateTimeService = dateTimeService;
	}

	public ConfigurationService getKualiConfigurationService() {
		return kualiConfigurationService;
	}

	public void setKualiConfigurationService(
			ConfigurationService kualiConfigurationService) {
		this.kualiConfigurationService = kualiConfigurationService;
	}

	public DashboardService getDashboardService() {
		return dashboardService;
	}

	public void setDashboardService(DashboardService dashboardService) {
		this.dashboardService = dashboardService;
	}

}
