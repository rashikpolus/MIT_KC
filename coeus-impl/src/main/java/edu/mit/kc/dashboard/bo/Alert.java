package edu.mit.kc.dashboard.bo;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

import javax.persistence.*;

/**
 * Alert business object
 */
@Entity
@Table(name = "SYSTEM_ALERTS")
public class Alert extends KcPersistableBusinessObjectBase {

    @PortableSequenceGenerator(name = "SEQ_MODULE_ALERT_ID")
    @GeneratedValue(generator = "SEQ_MODULE_ALERT_ID")
	@Id
   	@Column(name = "ALERT_ID")
    private String alertId;

   	@Column(name = "USER_NAME")
    private String userName;

   	@Column(name = "ALERT_MESSAGE")
    private String alert;

    @Column(name = "PRIORITY")
    private Integer priority;

    @Column(name = "ACTIVE")
    private String active;

	@Column(name = "ALERT_TYPE_ID")
    private Long alertTypeId;
	
    public String getAlertId() {
        return alertId;
    }

    public void setAlertId(String alertId) {
        this.alertId = alertId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getAlert() {
        return alert;
    }

    public void setAlert(String alert) {
        this.alert = alert;
    }

    public Integer getPriority() {
        return priority;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    public String getActive() {
        return active;
    }

    public void setActive(String active) {
        this.active = active;
    }

	public Long getAlertTypeId() {
		return alertTypeId;
	}

	public void setAlertTypeId(Long alertTypeId) {
		this.alertTypeId = alertTypeId;
	}
}
