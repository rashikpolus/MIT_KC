package org.kuali.coeus.propdev.impl.auth;

/*
 * Copyright 2005-2014 The Kuali Foundation
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

import org.kuali.coeus.common.framework.unit.admin.AbstractUnitAdministrator;
import org.kuali.coeus.common.framework.unit.admin.UnitAdministrator;
import org.kuali.kra.kim.bo.KcKimAttributes;
import org.kuali.coeus.common.framework.unit.admin.AbstractUnitAdministratorDerivedRoleTypeService;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.kim.framework.role.RoleTypeService;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.kra.infrastructure.Constants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component("proposalLeadUnitOspAdministratorDerivedRoleTypeService")
public class ProposalLeadUnitOspAdministratorDerivedRoleTypeServiceImpl extends AbstractUnitAdministratorDerivedRoleTypeService
        implements RoleTypeService {

	    @Autowired
	    @Qualifier("dataObjectService")
	    private DataObjectService dataObjectService;

	    
	    public DataObjectService getDataObjectService() {
	        return dataObjectService;
	    }

	    public void setDataObjectService(DataObjectService dataObjectService) {
	        this.dataObjectService = dataObjectService;
	    }
    @Override
    public List<? extends AbstractUnitAdministrator> getUnitAdministrators(Map<String, String> qualifiers) {

    	String proposalNumber = qualifiers.get(KcKimAttributes.PROPOSAL);
    	List<UnitAdministrator> result = new ArrayList<UnitAdministrator>();
    	if (proposalNumber != null) {
    		DevelopmentProposal proposal = getDataObjectService().find(DevelopmentProposal.class,proposalNumber);
    		Map<String, String> queryMap = new HashMap<String, String>();
    		queryMap.put("unitNumber", proposal.getUnitNumber());
    		String unitAdmininstratorTypeCode =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "OSP_ADMINISTRATOR_TYPE_CODE");  
    		queryMap.put("unitAdministratorTypeCode", unitAdmininstratorTypeCode);
    		result = (List<UnitAdministrator>) getBusinessObjectService().findMatching(UnitAdministrator.class, queryMap);
    	} 
    	return result;
    }

 


}
