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

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.drools.core.util.StringUtils;
import org.kuali.rice.kim.api.identity.AuthenticationService;

public class MitKcShibAuthServiceImpl implements AuthenticationService {
    private static final Log LOG = LogFactory.getLog(MitKcShibAuthServiceImpl.class);
    @Override
    public String getPrincipalName(HttpServletRequest request) {
        String remoteUser = request.getRemoteUser();
        LOG.info("Loggedin remote user=> "+remoteUser);
        String kerbEmail = remoteUser;
        if(!StringUtils.isEmpty(remoteUser) && remoteUser.indexOf("@")!=-1){
        	kerbEmail = remoteUser.substring(0,remoteUser.lastIndexOf("@"));
            LOG.info("Loggedin user utln=> "+kerbEmail);
        }else{
            LOG.info("Remote user=> "+remoteUser+ " is not valid");
        }
        return kerbEmail;
    }

}
