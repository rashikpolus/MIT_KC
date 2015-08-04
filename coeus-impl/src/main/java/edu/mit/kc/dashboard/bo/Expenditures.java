package edu.mit.kc.dashboard.bo;

import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

import javax.persistence.*;

@Entity
@Table(name = "DASHBOARD_EXPENDITURES")
public class Expenditures {

    @PortableSequenceGenerator(name = "SEQ_DASHBOARD_EXPENDITURES_ID")
    @GeneratedValue(generator = "SEQ_DASHBOARD_EXPENDITURES_ID")
    @Id
    @Column(name = "EXP_ID")
    private String expId;

    @Column(name = "PERSON_ID")
    private String personId;

    @Column(name = "USER_NAME")
    private String userName;

    @Column(name = "FISCAL_YEAR")
    private String fiscalYear;

    @Column(name = "DIRECT_EXP")
    private Double directExpenditures;

    @Column(name = "SUBAWARD_EXP")
    private Double subawardExpenditures;

    @Column(name = "FA_EXP")
    private Double faExpenditures;

    public String getExpId() {
        return expId;
    }

    public void setExpId(String expId) {
        this.expId = expId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPersonId() {
        return personId;
    }

    public void setPersonId(String personId) {
        this.personId = personId;
    }

    public String getFiscalYear() {
        return fiscalYear;
    }

    public void setFiscalYear(String fiscalYear) {
        this.fiscalYear = fiscalYear;
    }

    public Double getDirectExpenditures() {
        return directExpenditures;
    }

    public void setDirectExpenditures(Double directExpenditures) {
        this.directExpenditures = directExpenditures;
    }

    public Double getSubawardExpenditures() {
        return subawardExpenditures;
    }

    public void setSubawardExpenditures(Double subawardExpenditures) {
        this.subawardExpenditures = subawardExpenditures;
    }

    public Double getFaExpenditures() {
        return faExpenditures;
    }

    public void setFaExpenditures(Double faExpenditures) {
        this.faExpenditures = faExpenditures;
    }
}
