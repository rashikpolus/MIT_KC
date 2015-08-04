package org.kuali.coeus.propdev.impl.sapfeed;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

public class TempSapSponsorDetails extends KcPersistableBusinessObjectBase {
	
	private String sponsorCode;
	private String sponsorName;
	private String adminActivityCode;
	
	public String getSponsorCode() {
		return sponsorCode;
	}
	public void setSponsorCode(String sponsorCode) {
		this.sponsorCode = sponsorCode;
	}
	public String getSponsorName() {
		return sponsorName;
	}
	public void setSponsorName(String sponsorName) {
		this.sponsorName = sponsorName;
	}
	public String getAdminActivityCode() {
		return adminActivityCode;
	}
	public void setAdminActivityCode(String adminActivityCode) {
		this.adminActivityCode = adminActivityCode;
	}
	
	

}
