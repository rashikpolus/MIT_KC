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
package org.kuali.kra.bo;

import org.kuali.coeus.common.framework.module.CoeusSubModule;
import org.kuali.coeus.common.questionnaire.framework.core.QuestionnaireUsage;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.rice.core.api.util.type.KualiDecimal;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;

public class CoeusModule extends KcPersistableBusinessObjectBase {

    public static final String AWARD_MODULE_CODE = KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
                    Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_AWARD");   

    public static final String INSTITUTIONAL_PROPOSAL_MODULE_CODE =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INSTITUTIONAL_PROPOSAL");

    public static final String PROPOSAL_DEVELOPMENT_MODULE_CODE =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_PROPOSAL_DEVELOPMENT"); 
    public static final String SUBCONTRACTS_MODULE_CODE = KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_SUBCONTRACTS"); 
    public static final String NEGOTIATIONS_MODULE_CODE = KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_NEGOTIATIONS"); 
    public static final String PERSON_MODULE_CODE = KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_PERSON"); 
    public static final String IRB_MODULE_CODE = KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_IRB");
    public static final String COI_DISCLOSURE_MODULE_CODE =KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_COI_DISCLOSURE");
    public static final String IACUC_PROTOCOL_MODULE_CODE = KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_IACUC_PROTOCOLE");
    public static final String COMMITTEE_MODULE_CODE = KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_COMMITTEE");

    public static final int AWARD_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
                    Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_AWARD_INT")).intValue();     
    public static final int INSTITUTIONAL_PROPOSAL_MODULE_CODE_INT =new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_INSTITUTIONAL_PROPOSAL")).intValue();
    public static final int PROPOSAL_DEVELOPMENT_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_PROPOSAL_DEVELOPMENT")).intValue();
    public static final int SUBCONTRACTS_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_SUBCONTRACTS")).intValue();
    public static final int NEGOTIATIONS_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_NEGOTIATIONS")).intValue();
    public static final int PERSON_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_PERSON")).intValue();
    public static final int IRB_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_IRB")).intValue();
    public static final int COI_DISCLOSURE_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_COI_DISCLOSURE")).intValue();
    public static final int IACUC_PROTOCOL_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_IACUC_PROTOCOL")).intValue();
    public static final int COMMITEE_MODULE_CODE_INT = new KualiDecimal(KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
            Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "KC_MODULE_INT_COMMITTEE")).intValue();

    private static final long serialVersionUID = 1L;

    private String moduleCode;

    private String description;

    private QuestionnaireUsage questionnaireUsage;

    private CoeusSubModule coeusSubModule;
    private transient ParameterService parameterService;

    /* TODO : Implemented in the future 
    
    private ProtocolRelatedProjects protocolRelatedProjects;
    
    private CustomDataElementUsage customDataElementUsage;
    private ProtocolLinks protocolLinks;
    private NotifActionType notifActionType;
    private PersonRoleModule personRoleModule;
    private NotificationType notificationType;
    private NotificationDetails notificationDetails;
    */
    public CoeusModule() {
    }

    public String getModuleCode() {
        return moduleCode;
    }

    public void setModuleCode(String moduleCode) {
        this.moduleCode = moduleCode;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public QuestionnaireUsage getQuestionnaireUsage() {
        return questionnaireUsage;
    }

    public void setQuestionnaireUsage(QuestionnaireUsage questionnaireUsage) {
        this.questionnaireUsage = questionnaireUsage;
    }

    public CoeusSubModule getCoeusSubModule() {
        return coeusSubModule;
    }

    public void setCoeusSubModule(CoeusSubModule coeusSubModule) {
        this.coeusSubModule = coeusSubModule;
    }

    /* TODO : Implemented later
    public ProtocolRelatedProjects getProtocolRelatedProjects() {
        return protocolRelatedProjects;
    }

    public void setProtocolRelatedProjects(ProtocolRelatedProjects protocolRelatedProjects) {
        this.protocolRelatedProjects = protocolRelatedProjects;
    }

    public CustomDataElementUsage getCustomDataElementUsage() {
        return customDataElementUsage;
    }

    public void setCustomDataElementUsage(CustomDataElementUsage customDataElementUsage) {
        this.customDataElementUsage = customDataElementUsage;
    }

    public ProtocolLinks getProtocolLinks() {
        return protocolLinks;
    }

    public void setProtocolLinks(ProtocolLinks protocolLinks) {
        this.protocolLinks = protocolLinks;
    }

    public NotifActionType getNotifActionType() {
        return notifActionType;
    }

    public void setNotifActionType(NotifActionType notifActionType) {
        this.notifActionType = notifActionType;
    }

    public PersonRoleModule getPersonRoleModule() {
        return personRoleModule;
    }

    public void setPersonRoleModule(PersonRoleModule personRoleModule) {
        this.personRoleModule = personRoleModule;
    }

    public NotificationType getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(NotificationType notificationType) {
        this.notificationType = notificationType;
    }

    public NotificationDetails getNotificationDetails() {
        return notificationDetails;
    }

    public void setNotificationDetails(NotificationDetails notificationDetails) {
        this.notificationDetails = notificationDetails;
    }
    */
    
}
