package edu.mit.kc.alert.service;

import edu.mit.kc.alert.AlertType;

/**
 * This interface is to declare all methods to create/update alerts
 */
public interface SystemAlertService {
	
	
	/**
	 * This method is to create new alerts
	 */
	public void createAlerts(AlertType alertType, String userName);
	
	
	/**
	 * This method is to change alert priority
	 */
	public void updateAlerts(AlertType alertType, String userName);
	
	
	/**
	 * This method is to deactivate alerts
	 */
	public void cleanUpAlerts(AlertType alertType, String userName);

}
