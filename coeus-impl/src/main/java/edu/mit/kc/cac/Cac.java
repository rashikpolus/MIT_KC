/*
 * Copyright 2005-2010 The Kuali Foundation
 * 
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.opensource.org/licenses/ecl1.php
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package edu.mit.kc.cac;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

import java.sql.Timestamp;

public class Cac extends KcPersistableBusinessObjectBase { 
    
    /**
	 * 
	 */
	private static final long serialVersionUID = -5681403700903676922L;


    private Long cacDataId;
    private String approvalDate;
    private String contactEmail;
    private String dept;
    private String expirationDate;
    private String fundingAgency;          
    private String fundingAgency2;
    private String fundingAgency3;
    private String fundingAgency4;
    private String fundingAgency5;
    private String fundingAgency6;
    private String grantNumber;
    private String grantNumber2;
    private String grantNumber3;
    private String grantNumber4;
    private String grantNumber5;
    private String grantNumber6;
    private String piEmail;
    private String piFirstName; 
    private String piLastName; 
    private String previousProtocolNumber;
    private String proposalType;
    private String protocolNumber;
    private String reviewLevel;
    private String submissionDate;
    private String wbsIp1;
    private String wbsIp2;
    private String wbsIp3;
    private String wbsIp4;
    private String wbsIp5;
    private String wbsIp6;
    private Number verNbr;
    private String objId;
    
    
    public Cac() { 

    } 
    
	public Long getCacDataId() {
		return cacDataId;
	}

	public void setCacDataId(Long cacDataId) {
		this.cacDataId = cacDataId;
	}

    public String getApprovalDate() {
        return approvalDate;
    }

    public void setApprovalDate(String approvalDate) {
        this.approvalDate = approvalDate;
    }
    
    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }
    
    public String getDept() {
        return dept;
    }

    public void setDept(String dept) {
        this.dept = dept;
    }
    
    public String getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(String expirationDate) {
        this.expirationDate = expirationDate;
    }
    
    public String getFundingAgency() {
        return fundingAgency;
    }

    public void setFundingAgency(String fundingAgency) {
        this.fundingAgency = fundingAgency;
    }
    
    public String getFundingAgency2() {
        return fundingAgency2;
    }

    public void setFundingAgency2(String fundingAgency2) {
        this.fundingAgency2 = fundingAgency2;
    }
    
    public String getFundingAgency3() {
        return fundingAgency3;
    }

    public void setFundingAgency3(String fundingAgency3) {
        this.fundingAgency3 = fundingAgency3;
    }
    
    public String getFundingAgency4() {
        return fundingAgency4;
    }

    public void setFundingAgency4(String fundingAgency4) {
        this.fundingAgency4 = fundingAgency4;
    }
    
    public String getFundingAgency5() {
        return fundingAgency5;
    }

    public void setFundingAgency5(String fundingAgency5) {
        this.fundingAgency5 = fundingAgency5;
    }
    
    public String getFundingAgency6() {
        return fundingAgency6;
    }

    public void setFundingAgency6(String fundingAgency6) {
        this.fundingAgency6 = fundingAgency6;
    }
    
    public String getGrantNumber() {
        return grantNumber;
    }

    public void setGrantNumber(String grantNumber) {
        this.grantNumber = grantNumber;
    }
    
    public String getGrantNumber2() {
        return grantNumber2;
    }

    public void setGrantNumber2(String grantNumber2) {
        this.grantNumber2 = grantNumber2;
    }
    
    public String getGrantNumber3() {
        return grantNumber3;
    }

    public void setGrantNumber3(String grantNumber3) {
        this.grantNumber3 = grantNumber3;
    }
    
    public String getGrantNumber4() {
        return grantNumber4;
    }

    public void setGrantNumber4(String grantNumber4) {
        this.grantNumber4 = grantNumber4;
    }
    
    public String getGrantNumber5() {
        return grantNumber5;
    }

    public void setGrantNumber5(String grantNumber5) {
        this.grantNumber5 = grantNumber5;
    }
    
    public String getGrantNumber6() {
        return grantNumber6;
    }

    public void setGrantNumber6(String grantNumber6) {
        this.grantNumber6 = grantNumber6;
    }
    
    public String getPiEmail() {
        return piEmail;
    }

    public void setPiEmail(String piEmail) {
        this.piEmail = piEmail;
    }
    
    public String getPiFirstName() {
        return piFirstName;
    }

    public void setPiFirstName(String piFirstName) {
        this.piFirstName = piFirstName;
    }
    
    public String getPiLastName() {
        return piLastName;
    }

    public void setPiLastName(String piLastName) {
        this.piLastName = piLastName;
    }
    
    public String getPreviousProtocolNumber() {
        return previousProtocolNumber;
    }

    public void setPreviousProtocolNumber(String previousProtocolNumber) {
        this.previousProtocolNumber = previousProtocolNumber;
    }
    
    public String getProposalType() {
        return proposalType;
    }

    public void setProposalType(String proposalType) {
        this.proposalType = proposalType;
    }
    
    public String getProtocolNumber() {
        return protocolNumber;
    }

    public void setProtocolNumber(String protocolNumber) {
        this.protocolNumber = protocolNumber;
    }
    
    public String getReviewLevel() {
        return reviewLevel;
    }

    public void setReviewLevel(String reviewLevel) {
        this.reviewLevel = reviewLevel;
    }
    
    public String getSubmissionDate() {
        return submissionDate;
    }

    public void setSubmissionDate(String submissionDate) {
        this.submissionDate = submissionDate;
    }
    
    public String getWbsIp1() {
        return wbsIp1;
    }

    public void setWbsIp1(String wbsIp1) {
        this.wbsIp1 = wbsIp1;
    }
    
    public String getWbsIp2() {
        return wbsIp2;
    }

    public void setWbsIp2(String wbsIp2) {
        this.wbsIp2 = wbsIp2;
    }
    
    public String getWbsIp3() {
        return wbsIp3;
    }

    public void setWbsIp3(String wbsIp3) {
        this.wbsIp3 = wbsIp3;
    }
    
    public String getWbsIp4() {
        return wbsIp4;
    }

    public void setWbsIp4(String wbsIp4) {
        this.wbsIp4 = wbsIp4;
    }
    
    public String getWbsIp5() {
        return wbsIp5;
    }

    public void setWbsIp5(String wbsIp5) {
        this.wbsIp5 = wbsIp5;
    }
    
    public String getWbsIp6() {
        return wbsIp6;
    }

    public void setWbsIp6(String wbsIp6) {
        this.wbsIp6 = wbsIp6;
    }
    
    public Number getVerNbr() {
        return verNbr;
    }

    public void setVerNbr(Number verNbr) {
        this.verNbr = verNbr;
    }
    
    public String getObjId() {
        return objId;
    }

    public void setObjId(String objId) {
        this.objId = objId;
    }
    
    @Override
    protected void prePersist() {
//        super.prePersist();
        this.setVersionNumber(new Long(0));
    }
}