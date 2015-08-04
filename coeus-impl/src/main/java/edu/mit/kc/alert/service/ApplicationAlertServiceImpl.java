package edu.mit.kc.alert.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.krad.data.DataObjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import edu.mit.kc.alert.AlertType;

@Component("applicationAlertService")
@Transactional
public class ApplicationAlertServiceImpl implements ApplicationAlertService {
	@Autowired
	@Qualifier("dataObjectService")
	private DataObjectService dataObjectService;

	private String userName;
	
	@Override
	public void processAllAlerts(String userName) {
		this.userName = userName;
		List<AlertType> alertTypes = getAllAlertTypes();
		for(AlertType alertType : alertTypes) {
			processAlert(alertType);
		}
	}

	@Override
	public void processAlert(AlertType alertType) {
		SystemAlertService alertService = getAlertService(alertType);
		alertService.cleanUpAlerts(alertType, getUserName());
		alertService.updateAlerts(alertType, getUserName());
		alertService.createAlerts(alertType, getUserName());
	}

	@Override
	public void deactivateAlert(AlertType alertType) {
		SystemAlertService alertService = getAlertService(alertType);
		alertService.cleanUpAlerts(alertType, getUserName());
	}

	private SystemAlertService getAlertService(AlertType alertType) {
		String serviceName = alertType.getAlertServiceName();
		return KcServiceLocator.getService(serviceName);
	}
	
	protected List<AlertType> getAllAlertTypes() {
        Map<String, String> alertKeys = new HashMap<String, String>();
        alertKeys.put("active", "Y");
        List<AlertType> alertTypes = getDataObjectService().findMatching(AlertType.class, QueryByCriteria.Builder.andAttributes(alertKeys).build()).getResults();
		return alertTypes;
	}
	
	public DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

}
