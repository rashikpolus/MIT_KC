/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.osedu.org/licenses/ECL-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kuali.kra.proposaldevelopment.service;


import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.kuali.coeus.common.framework.auth.perm.KcAuthorizationService;
import org.kuali.coeus.common.notification.impl.service.KcNotificationService;
import org.kuali.coeus.propdev.impl.attachment.Narrative;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
//import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentForm;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationContext;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationRenderer;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.RoleConstants;

import static org.kuali.kra.infrastructure.Constants.*;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.kim.api.identity.Person;
import org.kuali.rice.kim.api.identity.PersonService;
import org.kuali.rice.kim.api.role.Role;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.ObjectUtils;

import java.sql.Timestamp;
import java.util.*;


/**
 *This class using for sendnotification functionality for narrative attachment.. 
 */
public class MitPropNarrativeServiceImpl implements MitPropNarrativeService {

     private BusinessObjectService businessObjectService;
    private DateTimeService dateTimeService;
   private KcNotificationService notificationService; 
    
    /**
     * 
     * This class using for sendnotification functionality for narrative attachment.
     * 
     * @param mapping
     * @param form
     * @param narative
     */  
  
    
    public ActionForward sendNotification(ActionMapping mapping, ActionForm form, Narrative modifiedNarrative){
//        ProposalDevelopmentForm proposalDevelopmentForm = (ProposalDevelopmentForm) form;
//        ProposalDevelopmentDocument pd = proposalDevelopmentForm.getProposalDevelopmentDocument();
//        ActionForward forward = mapping.findForward(MAPPING_BASIC);
//        ProposalDevelopmentNotificationContext context = 
//                new ProposalDevelopmentNotificationContext(pd.getDevelopmentProposal(),"102", "Narrative Attachment Replaced");
//        ((ProposalDevelopmentNotificationRenderer) context.getRenderer()).setModifiedNarrative(modifiedNarrative);
//        if (proposalDevelopmentForm.getNotificationHelper().getPromptUserForNotificationEditor(context)) {
//           proposalDevelopmentForm.getNotificationHelper().initializeDefaultValues(context);
//          forward = mapping.findForward("notificationEditor");
//        } else {
//            getNotificationService().sendNotification(context);                
//        }
        return null;
    }
    protected KcNotificationService getNotificationService() {
        if (notificationService == null) {
            notificationService = KcServiceLocator.getService(KcNotificationService.class);
        }
        return notificationService;
    }
    /**
     * 
     * This is a helper method for retrieving KraAuthorizationService
     * @return
     */
    protected KcAuthorizationService getKraAuthorizationService(){
        return KcServiceLocator.getService(KcAuthorizationService.class);
    }
  

}
