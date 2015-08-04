package edu.mit.kc.alert.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.common.framework.person.KcPersonService;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import edu.mit.kc.alert.AlertType;
import edu.mit.kc.dashboard.bo.Alert;

public class AlertServiceBaseImpl {

	@Autowired
	@Qualifier("dataObjectService")
	private DataObjectService dataObjectService;
	
    @Autowired
    @Qualifier("dataSource")
    private DataSource dataSource;
    
    @Autowired
    @Qualifier("kcPersonService")
    private KcPersonService kcPersonService;
    
    protected enum AlertPriority {
        HIGH (1),
        MEDIUM (2),
        LOW(3);

        private Integer code;

        private AlertPriority(Integer code) {
            this.code = code;
        }

        public Integer getCode() { return code; }
    };
	
	protected Alert getNewAlert(AlertType alertType, String alertMessage, String alertUser, AlertPriority alertPriority) {
		Alert alert = new Alert();
		alert.setAlert(alertMessage);
		alert.setUserName(alertUser);
		alert.setPriority(alertPriority.getCode());
		alert.setAlertTypeId(alertType.getId());
		alert.setActive(Constants.YES_FLAG);
		return alert;
	}
	
	protected void deactivateAllAlerts(AlertType alertType) {
        try (Connection conn = getDataSource().getConnection()) {
        	deactivateAlertsForAlertType(conn, alertType);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
	}
	
	protected void deactivateAlertsForAlertType(Connection conn, AlertType alertType) throws SQLException {
    	try (PreparedStatement stmt = conn.prepareStatement("UPDATE ALERT SET active = 'N' WHERE ALERT_TYPE_ID = ? AND ACTIVE = 'Y'")) {
    		stmt.setLong(1, alertType.getId());
    		stmt.executeUpdate();
    	}
	}
	
	protected String getLoggedInUserName() {
		return GlobalVariables.getUserSession().getLoggedInUserPrincipalName();		
	}
	
	protected KcPerson getKcPerson(String userName) {
        return getKcPersonService().getKcPersonByUserName(userName);
 	}
	
	public DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}

	public DataSource getDataSource() {
		return dataSource;
	}

	public void setDataSource(DataSource dataSource) {
		this.dataSource = dataSource;
	}

	public KcPersonService getKcPersonService() {
		return kcPersonService;
	}

	public void setKcPersonService(KcPersonService kcPersonService) {
		this.kcPersonService = kcPersonService;
	}
	
}
