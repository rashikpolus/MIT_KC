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
package edu.mit.kc.common;

import java.util.HashMap;
import java.util.Map;

import org.kuali.kra.kim.bo.KcKimAttributes;
import org.kuali.rice.kim.api.identity.IdentityService;
import org.kuali.rice.kim.api.identity.principal.Principal;
import org.kuali.rice.kim.api.permission.PermissionService;
import org.kuali.rice.kim.api.services.KimApiServiceLocator;

import edu.mit.kc.infrastructure.KcMitConstants;

public class BackDoorLoginAuthorizationServiceImpl implements BackDoorLoginAuthorizationService{
    
    
    private PermissionService permissionService;
    
    
    /**.
     * This method is for checking whether user has permission for back door login functionality
     * @return boolean
     */
    public boolean hasBackdoorLoginPermission(String username){
        
        boolean userHasPermission = false;
        Map<String, String> qualifiedRoleAttributes = new HashMap<String, String>();
        qualifiedRoleAttributes.put(KcKimAttributes.UNIT_NUMBER, "*"); 
        if(username!=null){

        	IdentityService identityService = KimApiServiceLocator.getIdentityService();
        	Principal principal = identityService.getPrincipalByPrincipalName(username);
        	if(principal!=null){
        		userHasPermission = permissionService.isAuthorized(principal.getPrincipalId(), "KC-UNT",KcMitConstants.ALLOW_BACKDOOR_LOGIN , qualifiedRoleAttributes);
        	}
        }
        return userHasPermission;
    }
    
    
    public PermissionService getPermissionService() {
        return permissionService;
    }

    public void setPermissionService(PermissionService permissionService) {
        this.permissionService = permissionService;
    }

}
