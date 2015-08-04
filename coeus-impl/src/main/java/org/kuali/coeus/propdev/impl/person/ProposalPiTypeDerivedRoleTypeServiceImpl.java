/*
 * Copyright 2005-2014 The Kuali Foundation
 *
 * Licensed under the Educational Community License, Version 1.0 (the "License");
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
package org.kuali.coeus.propdev.impl.person;

import org.apache.commons.lang3.StringUtils;
import org.kuali.kra.bo.AbstractProjectPerson;
import org.kuali.kra.kim.bo.KcKimAttributes;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.person.ProposalPersonService;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.kra.workflow.AbstractProjectPersonDerivedRoleTypeServiceImpl;
import org.kuali.rice.core.api.membership.MemberType;
import org.kuali.rice.kim.api.role.RoleMembership;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component("proposalPiTypeDerivedRoleTypeService")
public class ProposalPiTypeDerivedRoleTypeServiceImpl extends ProposalPersonDerivedRoleTypeServiceImpl {

    @Autowired
    @Qualifier("proposalPersonService")
	private ProposalPersonService proposalPersonService;
    
    @Autowired
    @Qualifier("globalVariableService")
    private GlobalVariableService globalVariableService; 
	
	protected List<String> requiredAttributes = new ArrayList<String>();
	{
		requiredAttributes.add(KcKimAttributes.PROPOSAL);
	}

    public ProposalPersonService getProposalPersonService() {
        return proposalPersonService;
    }

    public void setProposalPersonService(ProposalPersonService proposalPersonService) {
        this.proposalPersonService = proposalPersonService;
    }
    public static final String PI_CONTACT = "4";
    public static final String PRINCIPLE_INVESTIGATOR = "3";

    @Override
    protected List<? extends AbstractProjectPerson> getProjectPersons(Map<String, String> qualification) {
    	 String principalId=getGlobalVariableService().getUserSession().getPrincipalId();  
        String proposalNumber = qualification.get(KcKimAttributes.PROPOSAL);
        if (StringUtils.isNotBlank(proposalNumber)) {
        	List<ProposalPerson> propPersons= getProposalPersonService().getProposalKeyPersonnel(proposalNumber);
        	List<AbstractProjectPerson> abstarctProjPersons=new ArrayList<AbstractProjectPerson>();
        	  for (ProposalPerson propPerson : propPersons) {
        	if (propPerson.getProposalPersonRoleId().equals("PI") ||propPerson.getProposalPersonRoleId().equals(PRINCIPLE_INVESTIGATOR)         			
	                 && StringUtils.equals(principalId, propPerson.getPersonId())){
        		abstarctProjPersons.add(propPerson);
        		
        	}}
        	return abstarctProjPersons;
        } 
        
        else {
            return new ArrayList<AbstractProjectPerson>();
        }
    }
  
    public GlobalVariableService getGlobalVariableService() {
		return globalVariableService;
	}

	public void setGlobalVariableService(GlobalVariableService globalVariableService) {
		this.globalVariableService = globalVariableService;
	}


}
