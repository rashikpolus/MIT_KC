package edu.mit.kc.dashboard.core;

import edu.mit.kc.dashboard.bo.Alert;
import edu.mit.kc.dashboard.bo.Expenditures;
import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.negotiations.bo.Negotiation;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.krad.uif.util.ObjectPropertyUtils;
import org.kuali.rice.krad.uif.util.ScriptUtils;
import org.kuali.rice.krad.web.form.UifFormBase;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 *
 */
public class DashboardForm extends UifFormBase {

    private KcPerson dashboardPerson;
    private String tempUserName;
    private List<ProposalPerson> myProposals = new ArrayList<>();
    private List<Award> myAwards;
    private List<Award> myProjects;
    private List<Expenditures> expenditureData = new ArrayList<>();
    private List<Alert> alerts = new ArrayList<>();

    public void setDashboardPerson(KcPerson dashboardPerson) {
        this.dashboardPerson = dashboardPerson;
    }

    public KcPerson getDashboardPerson() {
        return dashboardPerson;
    }

    public String getTempUserName() {
        return tempUserName;
    }

    public void setTempUserName(String tempUserName) {
        this.tempUserName = tempUserName;
    }

    public List<ProposalPerson> getMyProposals() {
        return myProposals;
    }

    public void setMyProposals(List<ProposalPerson> myProposals) {
        this.myProposals = myProposals;
    }

    public List<Award> getMyAwards() {
        return myAwards;
    }

    public void setMyAwards(List<Award> myAwards) {
        this.myAwards = myAwards;
    }

    public List<Alert> getAlerts() {
        return alerts;
    }

    public void setAlerts(List<Alert> alerts) {
        this.alerts = alerts;
    }

    public List<Expenditures> getExpenditureData() {
        return expenditureData;
    }

    public void setExpenditureData(List<Expenditures> expenditureData) {
        this.expenditureData = expenditureData;
    }

    public String getExpenditureDataAsJSON () {
        return ScriptUtils.translateValue(expenditureData).replaceAll("\"", "'");
    }

	public List<Award> getMyProjects() {
		return myProjects;
	}

	public void setMyProjects(List<Award> myProjects) {
		this.myProjects = myProjects;
	}
}
