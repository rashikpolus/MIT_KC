package edu.mit.kc.workloadbalancing.bo;

import java.io.Serializable;

/**
 * Wrapper for Absentee workload date to provide time fields.
 *
 */
public class AbsenteeWrapper implements Serializable {
    private static final long serialVersionUID = 2878716732151520221L;
    private WlAbsentee absentee;
    private String leaveStartHour;
    private String leaveEndHour;

    public AbsenteeWrapper() {
        absentee = new WlAbsentee();
    }

    public AbsenteeWrapper(WlAbsentee absentee) {
        this.absentee = absentee;
    }

    public WlAbsentee getAbsentee() {
        return absentee;
    }

    public void setAbsentee(WlAbsentee absentee) {
        this.absentee = absentee;
    }

    public String getLeaveStartHour() {
        return leaveStartHour;
    }

    public void setLeaveStartHour(String leaveStartHour) {
        this.leaveStartHour = leaveStartHour;
    }

    public String getLeaveEndHour() {
        return leaveEndHour;
    }

    public void setLeaveEndHour(String leaveEndHour) {
        this.leaveEndHour = leaveEndHour;
    }
}
