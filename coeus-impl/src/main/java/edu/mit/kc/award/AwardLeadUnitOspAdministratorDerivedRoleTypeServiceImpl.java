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
package edu.mit.kc.award;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.framework.unit.admin.AbstractUnitAdministrator;
import org.kuali.coeus.common.framework.unit.admin.UnitAdministrator;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardService;
import org.kuali.kra.kim.bo.KcKimAttributes;
import org.kuali.coeus.common.framework.unit.admin.AbstractUnitAdministratorDerivedRoleTypeService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.kim.framework.role.RoleTypeService;
import org.kuali.kra.infrastructure.Constants;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AwardLeadUnitOspAdministratorDerivedRoleTypeServiceImpl extends AbstractUnitAdministratorDerivedRoleTypeService
        implements RoleTypeService {

    private AwardService awardService;
    @Override
    public List<? extends AbstractUnitAdministrator> getUnitAdministrators(Map<String, String> qualifiers) {
        String awardIdStr = qualifiers.get(KcKimAttributes.AWARD);
        List<UnitAdministrator> result = new ArrayList<UnitAdministrator>();
        if (StringUtils.isNotBlank(awardIdStr) && awardIdStr.matches("\\d+")) {
            Long awardId = Long.valueOf(awardIdStr);
            Award award = getAwardService().getAward(awardId);
            Map<String, String> queryMap = new HashMap<String, String>();
            queryMap.put("unitNumber", award.getLeadUnitNumber());
            String unitAdmininstratorTypeCode =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "OSP_ADMINISTRATOR_TYPE_CODE");  
            queryMap.put("unitAdministratorTypeCode", unitAdmininstratorTypeCode);
            result = (List<UnitAdministrator>) getBusinessObjectService().findMatching(UnitAdministrator.class, queryMap);
        }   
        return result;
    }

    protected AwardService getAwardService() {
        return awardService;
    }

    public void setAwardService(AwardService awardService) {
        this.awardService = awardService;
    }


}
