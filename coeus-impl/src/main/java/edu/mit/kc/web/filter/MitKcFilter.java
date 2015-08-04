package edu.mit.kc.web.filter;



import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.rice.coreservice.framework.CoreFrameworkServiceLocator;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;

import edu.mit.kc.alert.service.ApplicationAlertService;
import edu.mit.kc.common.BackDoorLoginAuthorizationService;
import edu.mit.kc.infrastructure.KcMitConstants;
import edu.mit.kc.roleintegration.RoleIntegrationService;


public class MitKcFilter implements Filter {
	
    private static final Log LOG = LogFactory.getLog(MitKcFilter.class);


	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
	
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response,
			FilterChain chain) throws IOException, ServletException {

		HttpServletRequest hsreq = (HttpServletRequest) request;
		boolean backboorEnabled = false;
		boolean hasBackdoorloginPermission = false;
		boolean roleIntegrationEnabled = false;
		BackDoorLoginAuthorizationService backDoorLoginAuthorizationService = KcServiceLocator.getService(BackDoorLoginAuthorizationService.class);
	    ParameterService parameterService = CoreFrameworkServiceLocator.getParameterService();

		String user = request.getParameter("__login_user");
		String backdoorId = request.getParameter("backdoorId");
		
		if(user!=null){
			try{
		    backboorEnabled = parameterService.getParameterValueAsBoolean(org.kuali.rice.kew.api.KewApiConstants.KEW_NAMESPACE, org.kuali.rice.krad.util.KRADConstants.DetailTypes.BACKDOOR_DETAIL_TYPE, org.kuali.rice.kew.api.KewApiConstants.SHOW_BACK_DOOR_LOGIN_IND);
			}catch (NullPointerException ex){
				 LOG.error(ex.getMessage(), ex);
			}
		    hasBackdoorloginPermission = backDoorLoginAuthorizationService.hasBackdoorLoginPermission(user);
			hsreq.getSession().setAttribute("hasBackdoorloginPermission",hasBackdoorloginPermission);
			hsreq.getSession().setAttribute("backboorEnabled", backboorEnabled);
		}
		if(user != null || backdoorId !=null){
			if(user == null){
				user = backdoorId;
			}
			try{
				roleIntegrationEnabled = parameterService.getParameterValueAsBoolean(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
						Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, KcMitConstants.ENABLE_ROLE_INTEGRATION);
			}catch (NullPointerException ex){
				LOG.error(ex.getMessage(), ex);
			}

			if(roleIntegrationEnabled){
				RoleIntegrationService roleIntegrationService = KcServiceLocator.getService(RoleIntegrationService.class);

				try {
					roleIntegrationService.updateUserRoles(user);
				} catch (Throwable  ex) {
					LOG.error(ex.getMessage(), ex);
				}
			}
			
			ApplicationAlertService applicationAlertService = KcServiceLocator.getService(ApplicationAlertService.class);

			try {
				applicationAlertService.processAllAlerts(user);
			} catch (Throwable  ex) {
				LOG.error(ex.getMessage(), ex);
			}
			
		}
		chain.doFilter(request, response);
		
		
	}

	@Override
	public void destroy() {
	
	}

	

}
