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
package edu.mit.kc.auth;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.HttpServletResponse;

import org.kuali.rice.kim.api.identity.IdentityService;
import org.kuali.rice.kim.api.identity.principal.Principal;
import org.kuali.rice.kim.api.services.KimApiServiceLocator;
import org.kuali.rice.krad.UserSession;
import org.kuali.rice.krad.exception.AuthenticationException;
import org.kuali.rice.krad.util.KRADUtils;
import org.kuali.rice.krad.web.filter.UserLoginFilter;

public class MitKcShibUserLoginFilter extends UserLoginFilter {
    private String loginPath;
    @Override
    public void init(FilterConfig config) throws ServletException {
        loginPath = config.getInitParameter("loginPath");
        if (loginPath == null) {
            loginPath = "/WEB-INF/jsp/mit/mitInvalidLogin.jsp";
        }
        super.init(config);
    }
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        String authMode = request.getParameter("authMode");
        if(authMode==null){
            authMode = (String)((HttpServletRequest)request).getSession().getAttribute("authMode");
        }
        if(authMode!=null && authMode.equals("none")){
            doFilter((HttpServletRequest) request, (HttpServletResponse) response, chain);
        }else{
            try{
                loginPath = "/WEB-INF/jsp/mit/mitInvalidLogin.jsp";
                super.doFilter((HttpServletRequest) request, (HttpServletResponse) response, chain);
            }catch(AuthenticationException ex){
                handleInvalidLogin(request, response);
            }
        }
    }

    private void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException, ServletException{
        loginPath = "/WEB-INF/jsp/dummy_login.jsp";
        request.getSession().setAttribute("authMode", "none");
        final UserSession session = KRADUtils.getUserSessionFromRequest(request);
        if (session == null) {
            IdentityService auth = KimApiServiceLocator.getIdentityService();
            final String user = request.getParameter("__login_user");
            if (user != null && !user.trim().isEmpty()) {
                // Very simple password checking. Nothing hashed or encrypted. This is strictly for demonstration purposes only.
                final Principal principal = auth.getPrincipalByPrincipalName(user);
                if (principal == null) {
                    handleInvalidLogin(request, response);  
                    return;
                }
                
                // wrap the request with the remote user
                // UserLoginFilter and WebAuthenticationService will create the session
                request = new HttpServletRequestWrapper(request) {
                    @Override
                    public String getRemoteUser() {
                        return user;
                    }
                };  
                
            } else {
                // no session has been established and this is not a login form submission, so forward to login page
                request.getRequestDispatcher(loginPath).forward(request, response);
                return;
            }
        } else {
            request = new HttpServletRequestWrapper(request) {
                    @Override
                    public String getRemoteUser() {
                        return session.getPrincipalName();
                    }
                };
        }
        chain.doFilter(request, response);
    }
    /**
     * Handles and invalid login attempt.
     * 
     * @param request the incoming request
     * @param response the outgoing response
     * @throws ServletException if unable to handle the invalid login
     * @throws IOException if unable to handle the invalid login
     */
    private void handleInvalidLogin(ServletRequest request, ServletResponse response)
        throws ServletException, IOException {
        request.setAttribute("invalidAuth", Boolean.TRUE);
        request.getRequestDispatcher(loginPath).forward(request, response);
    }
    @Override
    public void destroy() {
        loginPath = null;
    }
}
