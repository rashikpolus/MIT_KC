/*
 * UserIdAuthService.java
 *
 * Created on August 28, 2006, 1:11 PM
 * Copyright (c) Massachusetts Institute of Technology
 * 77 Massachusetts Avenue, Cambridge, MA 02139-4307
 * All rights reserved.
 */

package edu.mit.kc.auth;


import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.drools.core.util.StringUtils;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.rice.coreservice.framework.CoreFrameworkServiceLocator;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.kim.impl.identity.AuthenticationServiceImpl;
import org.kuali.rice.krad.UserSession;
import org.kuali.rice.krad.util.KRADUtils;

import edu.mit.kc.common.BackDoorLoginAuthorizationService;
import edu.mit.kc.infrastructure.KcMitConstants;
import edu.mit.kc.roleintegration.RoleIntegrationService;


/**
 *
 */
public class MitKcUserAuthServiceImpl extends AuthenticationServiceImpl{
    private static final Log LOG = LogFactory.getLog(MitKcUserAuthServiceImpl.class);
	
    @Override
    public String getPrincipalName(HttpServletRequest request) {
        String remoteUserEmail = request.getRemoteUser();
        LOG.info("Loggedin remote user=> "+remoteUserEmail);
        String kerbId = remoteUserEmail;
        if(!StringUtils.isEmpty(remoteUserEmail) && remoteUserEmail.indexOf("@")!=-1){
        	kerbId = remoteUserEmail.substring(0,remoteUserEmail.lastIndexOf("@"));
            LOG.info("Loggedin user utln=> "+kerbId);
        }else{
            LOG.info("Remote user email=> "+remoteUserEmail+ " is not valid");
        }
        handleBackDoorLogin(request,kerbId);
        return kerbId;
    }

	private void handleBackDoorLogin(HttpServletRequest request,String principalName){
		boolean backboorEnabled = false;
		boolean hasBackdoorloginPermission = false;
		boolean roleIntegrationEnabled = false;

		BackDoorLoginAuthorizationService backDoorLoginAuthorizationService = KcServiceLocator.getService(BackDoorLoginAuthorizationService.class);
	    ParameterService parameterService = CoreFrameworkServiceLocator.getParameterService();
		
		if(principalName!=null){
			try{
				backboorEnabled = parameterService.getParameterValueAsBoolean(org.kuali.rice.kew.api.KewApiConstants.KEW_NAMESPACE, 
							org.kuali.rice.krad.util.KRADConstants.DetailTypes.BACKDOOR_DETAIL_TYPE, 
							org.kuali.rice.kew.api.KewApiConstants.SHOW_BACK_DOOR_LOGIN_IND);
			}catch (NullPointerException ex){
				 LOG.error(ex.getMessage(), ex);
			}
		    hasBackdoorloginPermission = backDoorLoginAuthorizationService.hasBackdoorLoginPermission(principalName);
		    request.getSession().setAttribute("hasBackdoorloginPermission",hasBackdoorloginPermission);
		    request.getSession().setAttribute("backboorEnabled", backboorEnabled);
			try{
				roleIntegrationEnabled = parameterService.getParameterValueAsBoolean(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
						Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, KcMitConstants.ENABLE_ROLE_INTEGRATION);
			}catch (NullPointerException ex){
				LOG.error(ex.getMessage(), ex);
			}
	
			if(roleIntegrationEnabled){
				RoleIntegrationService roleIntegrationService = KcServiceLocator.getService(RoleIntegrationService.class);
	
				try {
					roleIntegrationService.updateUserRoles(principalName);
				} catch (Throwable  ex) {
					LOG.error(ex.getMessage(), ex);
				}
			}
		}
		
	}
}
