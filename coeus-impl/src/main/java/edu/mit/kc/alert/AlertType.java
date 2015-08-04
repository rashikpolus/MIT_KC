package edu.mit.kc.alert;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

@Entity
@Table(name = "ALERT_TYPE")
public class AlertType {
    @PortableSequenceGenerator(name = "SEQ_ALERT_TYPE_ID")
    @GeneratedValue(generator = "SEQ_ALERT_TYPE_ID")
	@Id
	@Column(name = "ALERT_TYPE_ID")
    private Long id;

    @Column(name = "ALERT_TYPE_NAME")
    private String alertName;

    @Column(name = "ALERT_TYPE_NMSPC_CD")
    private String alertNameSpace;

    @Column(name = "ALERT_TYPE_SERVICE_NM")
    private String alertServiceName;

    @Column(name = "ALERT_TYPE_ACTIVE")
    private String active;
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getAlertName() {
		return alertName;
	}

	public void setAlertName(String alertName) {
		this.alertName = alertName;
	}

	public String getAlertNameSpace() {
		return alertNameSpace;
	}

	public void setAlertNameSpace(String alertNameSpace) {
		this.alertNameSpace = alertNameSpace;
	}

	public String getAlertServiceName() {
		return alertServiceName;
	}

	public void setAlertServiceName(String alertServiceName) {
		this.alertServiceName = alertServiceName;
	}

	public String getActive() {
		return active;
	}

	public void setActive(String active) {
		this.active = active;
	}
    
}
