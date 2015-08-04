package edu.mit.kc.alert;

import static org.kuali.rice.core.api.criteria.PredicateFactory.equal;
import java.sql.Date;
import java.util.List;
import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.propdev.impl.dashboard.DashboardService;
import org.kuali.coeus.sys.framework.util.DateUtils;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardService;
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

@Component("awardExpireAlertService")
public class AwardExpireAlertServiceImpl extends AlertServiceBaseImpl implements
		SystemAlertService {

	@Autowired
	@Qualifier("dashboardService")
	private DashboardService dashboardService;

	@Autowired
	@Qualifier("dateTimeService")
	private DateTimeService dateTimeService;

	@Autowired
	@Qualifier("kualiConfigurationService")
	private ConfigurationService kualiConfigurationService;

	Alert alertAwardExp = new Alert();

	@Override
	public void createAlerts(AlertType alertType, String userName) {
		String alertMessage = null;
		String loggedInUserId = getKcPerson(userName).getPersonId();
		Date finalExpirationDate = null;
		List<Award> myAwardsFiltered = getDashboardService().getActiveAwardsForInvestigator(loggedInUserId);

		for (Award award : myAwardsFiltered) {
			alertMessage = getKualiConfigurationService().getPropertyValueAsString(KcMitConstants.AWARD_FINAL_EXPIRATION_DATE_ALERT);
			Boolean rootaward = award.getAwardNumber().contains("-00001");
			if (rootaward) {

				finalExpirationDate = award.findLatestFinalExpirationDate();
				Date currentDate = DateUtils.clearTimeFields(new Date(System.currentTimeMillis()));
				int diff = getDateTimeService().dateDiff(currentDate,finalExpirationDate, true);
				if (diff >= 0 && diff <= 60) {
					if (!StringUtils.isEmpty(alertMessage)) {
						if (award.getAccountNumber() == null)
							alertMessage = alertMessage.replace("{0}", "");
						else {
							alertMessage = alertMessage.replace("{0}",award.getAccountNumber());
						}
						alertMessage = alertMessage.replace("{1}",award.getSponsorName());
					}

					alertAwardExp.setActive(Constants.YES_FLAG);
					alertAwardExp.setAlert(alertMessage);
					alertAwardExp.setUserName(getKcPerson(userName).getUserName());
					alertAwardExp.setUpdateUser(getKcPerson(userName).getUserName());
					alertAwardExp.setPriority(1);
					alertAwardExp.setAlertTypeId(alertType.getId());
					getDataObjectService().save(alertAwardExp,PersistenceOption.FLUSH);

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
