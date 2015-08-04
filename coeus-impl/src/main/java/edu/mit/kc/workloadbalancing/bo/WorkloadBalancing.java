package edu.mit.kc.workloadbalancing.bo;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import org.kuali.coeus.common.framework.sponsor.hierarchy.SponsorHierarchy;


public class WorkloadBalancing {

    private String index;
	private String adminId;
	private String userName;
	private String personName;
	private String flexibility;

    private boolean currentlyAbsent;

	private WlCapacity wlCapacity;

	private List<WlFlexibility> wlflexibilityList;

    public String getIndex() {
        return index;
    }

    public void setIndex(String index) {
        this.index = index;
    }

    public String getAdminId() {
		return adminId;
	}

	public void setAdminId(String adminId) {
		this.adminId = adminId;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getPersonName() {
		return personName;
	}

	public void setPersonName(String personName) {
		this.personName = personName;
	}

	public String getFlexibility() {
		return flexibility;
	}

	public void setFlexibility(String flexibility) {
		this.flexibility = flexibility;
	}

    public boolean isCurrentlyAbsent() {
        return currentlyAbsent;
    }

    public void setCurrentlyAbsent(boolean currentlyAbsent) {
        this.currentlyAbsent = currentlyAbsent;
    }

    public WlCapacity getWlCapacity() {
		return wlCapacity;
	}

	public void setWlCapacity(WlCapacity wlCapacity) {
		this.wlCapacity = wlCapacity;
	}

	public List<WlFlexibility> getWlflexibilityList() {
		return wlflexibilityList;
	}

	public void setWlflexibilityList(List<WlFlexibility> wlflexibilityList) {
		this.wlflexibilityList = wlflexibilityList;
	}

    public int getFlexibilityListHalfIndex(){
        return (int)Math.ceil(this.getWlflexibilityList().size() / 2);
    }

}
