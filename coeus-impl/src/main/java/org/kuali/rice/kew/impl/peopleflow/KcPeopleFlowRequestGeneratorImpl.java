package org.kuali.rice.kew.impl.peopleflow;

import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.common.framework.person.KcPersonService;
import org.kuali.coeus.common.framework.sponsor.hierarchy.SponsorHierarchy;
import org.kuali.coeus.common.framework.unit.admin.UnitAdministrator;
import org.kuali.coeus.common.notification.impl.NotificationContext;
import org.kuali.coeus.common.notification.impl.bo.KcNotification;
import org.kuali.coeus.common.notification.impl.bo.NotificationType;
import org.kuali.coeus.common.notification.impl.bo.NotificationTypeRecipient;
import org.kuali.coeus.common.notification.impl.service.KcNotificationService;
import org.kuali.coeus.propdev.impl.auth.perm.ProposalDevelopmentPermissionsService;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.docperm.ProposalUserRoles;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationContext;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationRenderer;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.criteria.OrderByField;
import org.kuali.rice.core.api.criteria.OrderDirection;
import org.kuali.rice.core.api.criteria.Predicate;
import org.kuali.rice.core.api.criteria.PredicateFactory;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.core.api.exception.RiceRuntimeException;
import org.kuali.rice.core.api.membership.MemberType;
import org.kuali.rice.core.api.util.xml.XmlHelper;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.kew.actionrequest.KimPrincipalRecipient;
import org.kuali.rice.kew.actionrequest.Recipient;
import org.kuali.rice.kew.api.action.ActionRequest;
import org.kuali.rice.kew.api.action.ActionRequestPolicy;
import org.kuali.rice.kew.api.peopleflow.PeopleFlowMember;
import org.kuali.rice.kew.rule.xmlrouting.XPathHelper;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.RoleConstants;
import org.w3c.dom.Document;

import edu.mit.kc.workloadbalancing.bo.WLCurrentLoad;
import edu.mit.kc.workloadbalancing.bo.WlPropAggregatorComplexity;
import edu.mit.kc.workloadbalancing.bo.WlPropReviewComments;
import edu.mit.kc.workloadbalancing.peopleflow.WorkLoadService;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;


public class KcPeopleFlowRequestGeneratorImpl extends PeopleFlowRequestGeneratorImpl{

	private KcPersonService kcPersonService;
	private DataObjectService dataObjectService;
	private DateTimeService dateTimeService;
	private BusinessObjectService businessObjectService;
	private KcNotificationService kcNotificationService;
	
	protected void generateRequestForMember(Context context, PeopleFlowMember member) {
        String peopleflowName =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "OSP_PEOPLE_FLOW_NAME");
		String enabledWlRouting =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "ENABLE_WL_ROUTING");  
		String personId = null;
    	if(peopleflowName !=null && context.getPeopleFlow().getName().equalsIgnoreCase(peopleflowName)){
            String docContent = context.getRouteContext().getDocument().getDocContent();
            String proposalNumber = getElementValue(docContent, "//proposalNumber");
                   
            QueryByCriteria.Builder builder = QueryByCriteria.Builder.create();
            List<Predicate> predicates = new ArrayList<Predicate>();
            predicates.add(PredicateFactory.equal("proposalNUmber", proposalNumber));
            predicates.add(PredicateFactory.equal("cannedReviwCommentCode", "999"));
        	builder.setPredicates(PredicateFactory.and(predicates.toArray(new Predicate[] {})));
            builder.setOrderByFields(OrderByField.Builder.create("updateTimestamp", OrderDirection.DESCENDING).build());
            List<WlPropReviewComments> wlPropReviewCommentsList = KcServiceLocator.getService(DataObjectService.class).findMatching(WlPropReviewComments.class, builder.build()).getResults();
              
            if(wlPropReviewCommentsList!=null && !wlPropReviewCommentsList.isEmpty()){
            	WlPropReviewComments wlPropReviewComments = wlPropReviewCommentsList.get(0);
            	personId = wlPropReviewComments.getPersonId();
            }else{            
            	personId =  KcServiceLocator.getService(WorkLoadService.class).getNextRoutingOSP(proposalNumber);
            }
    		KcPerson orginalApprover = null;
    		 List<WLCurrentLoad> wLCurrentLoadList = getDataObjectService().findMatching(WLCurrentLoad.class, QueryByCriteria.Builder.fromPredicates
					 (PredicateFactory.equal("proposalNumber", proposalNumber))).getResults();
			 List<UnitAdministrator> unitAdministrators = new ArrayList<UnitAdministrator>();
			 DevelopmentProposal proposal = getDataObjectService().find(DevelopmentProposal.class,proposalNumber);
    		 if (MemberType.ROLE == member.getMemberType()) {
    			
    	     		Map<String, String> queryMap = new HashMap<String, String>();
    	    		queryMap.put("unitNumber", proposal.getUnitNumber());
    	     		String unitAdmininstratorTypeCode =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "OSP_ADMINISTRATOR_TYPE_CODE");  
    	     		queryMap.put("unitAdministratorTypeCode", unitAdmininstratorTypeCode);
    	     		unitAdministrators = (List<UnitAdministrator>) getBusinessObjectService().findMatching(UnitAdministrator.class, queryMap);
    	     		if(unitAdministrators!=null && !unitAdministrators.isEmpty()){
    	     			UnitAdministrator unitAdministrator= unitAdministrators.get(0);
    	     			orginalApprover = getKcPersonService().getKcPersonByPersonId(unitAdministrator.getPersonId());
    	     		}
    			 }else{
    				 orginalApprover = getKcPersonService().getKcPersonByPersonId(member.getMemberId());
    			 }
     		if (!context.getRouteContext().isSimulation() && personId!=null) {
    			 String sponsorGroup = null;
    			 Long complexity = null;
    			 if(wLCurrentLoadList!=null && !wLCurrentLoadList.isEmpty()){
    				 List<WLCurrentLoad> workLoadLatestList = new ArrayList<WLCurrentLoad>();
    				 for(WLCurrentLoad wLCurrentLoad : wLCurrentLoadList){
    					 if(workLoadLatestList.isEmpty()){
    						 workLoadLatestList.add(0,wLCurrentLoad);
    					 }else{
    						 WLCurrentLoad wLCurrentLoadlatest = workLoadLatestList.get(0);
    						 if(Integer.parseInt(wLCurrentLoadlatest.getRoutingNumber()) < Integer.parseInt(wLCurrentLoad.getRoutingNumber())){
    							 workLoadLatestList.remove(0);
    							 workLoadLatestList.add(0,wLCurrentLoad);
    						 }
    					 }
    				 }
    				 WLCurrentLoad currentWorkLoad = workLoadLatestList.get(0);
    				 KcPerson ospPerson = getKcPersonService().getKcPersonByPersonId(currentWorkLoad.getPerson_id());
    				  List<ActionRequest> actionRequests = proposal.getProposalDocument().getDocumentHeader().getWorkflowDocument().getDocumentDetail().getActionRequests();
    	                 int submitCount = 0;
    	                 for(ActionRequest actionRequest : actionRequests) {
    	                     if(actionRequest.getNodeName().equals(Constants.PD_INITIATED_ROUTE_NODE_NAME)) {
    	                         submitCount++;
    	                     }
    	                 }
    				  WLCurrentLoad wLCurrentLoad = new WLCurrentLoad();
    	    			 wLCurrentLoad.setRoutingNumber(String.valueOf(submitCount));
    	    			 wLCurrentLoad.setProposalNumber(currentWorkLoad.getProposalNumber());
    	    			 wLCurrentLoad.setOriginalApprover(orginalApprover.getPersonId());
    	    			 wLCurrentLoad.setOriginalUserId(orginalApprover.getUserName());
    	    			 wLCurrentLoad.setPerson_id(currentWorkLoad.getPerson_id());
    	    			 wLCurrentLoad.setUserId(currentWorkLoad.getUserId());
    	    			 wLCurrentLoad.setSponsorCode(currentWorkLoad.getSponsorCode());
    	    			 wLCurrentLoad.setSponsorGroup(currentWorkLoad.getSponsorGroup());
    	    			 wLCurrentLoad.setComplexity(currentWorkLoad.getComplexity());
    	    			 wLCurrentLoad.setLeadUnit(currentWorkLoad.getLeadUnit());
    	    			 wLCurrentLoad.setActiveFlag(currentWorkLoad.getActiveFlag());
    	    			 wLCurrentLoad.setArrivalDate(currentWorkLoad.getArrivalDate());
    	    			 wLCurrentLoad.setInactiveDate(currentWorkLoad.getInactiveDate());
    	    			 wLCurrentLoad.setReroutedFlag("Y");
    	    			 wLCurrentLoad.setAssignedBy(currentWorkLoad.getAssignedBy());
    	    			 wLCurrentLoad.setLastApprover(currentWorkLoad.getLastApprover());
    				  getDataObjectService().save(wLCurrentLoad);
    				  sendNotification(proposal,currentWorkLoad.getPerson_id(),ospPerson);
    			 }else{
    			 
    			 KcPerson ospPerson = getKcPersonService().getKcPersonByPersonId(personId);
    		     String wlHieararchyname =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "WL_SPONSOR_HIERARCHY_NAME");
    		     if(wlHieararchyname!=null){
    		    	 Map<String, String> valueMap = new HashMap<String, String>();
    		    	 valueMap.put("sponsorCode", proposal.getSponsorCode());
    		    	 valueMap.put("hierarchyName", wlHieararchyname);
    		    	 SponsorHierarchy sponsorHierarchy = getBusinessObjectService().findByPrimaryKey(SponsorHierarchy.class, valueMap);
    		    	 if(sponsorHierarchy!=null){
    		    		 sponsorGroup = sponsorHierarchy.getLevel1();
    		    	 }
    		     }
    		     String aggregator = context.getRouteContext().getRouteHeader().getInitiatorPrincipalId();
    		     if(aggregator!=null){
    		    	 List<WlPropAggregatorComplexity> WlPropAggregatorComplexityList = getDataObjectService().findMatching(WlPropAggregatorComplexity.class, QueryByCriteria.Builder.fromPredicates
    		    			 (PredicateFactory.equal("aggregatorPersonId", aggregator))).getResults();
    		    	 if(WlPropAggregatorComplexityList!=null && !WlPropAggregatorComplexityList.isEmpty()){
    		    		 WlPropAggregatorComplexity wlPropAggregatorComplexity = WlPropAggregatorComplexityList.get(0);
    		    		 complexity = wlPropAggregatorComplexity.getComplexity();
    		    	 }else{
    		    		 complexity =3l;
    		    	 }
    		     }else{
    		    	 complexity =3l;
    		     }
    		    
                 List<ActionRequest> actionRequests = proposal.getProposalDocument().getDocumentHeader().getWorkflowDocument().getDocumentDetail().getActionRequests();
                 int submitCount = 0;
                 for(ActionRequest actionRequest : actionRequests) {
                     if(actionRequest.getNodeName().equals(Constants.PD_INITIATED_ROUTE_NODE_NAME)) {
                         submitCount++;
                     }
                 }
    			 WLCurrentLoad wLCurrentLoad = new WLCurrentLoad();
    			 wLCurrentLoad.setRoutingNumber(String.valueOf(submitCount));
    			 wLCurrentLoad.setProposalNumber(proposalNumber);
    			 wLCurrentLoad.setOriginalApprover(orginalApprover.getPersonId());
    			 wLCurrentLoad.setOriginalUserId(orginalApprover.getUserName());
    			 wLCurrentLoad.setPerson_id(personId);
    			 wLCurrentLoad.setUserId(ospPerson.getUserName());
    			 wLCurrentLoad.setSponsorCode(proposal.getSponsorCode());
    			 wLCurrentLoad.setSponsorGroup(sponsorGroup);
    			 wLCurrentLoad.setComplexity(complexity);
    			 wLCurrentLoad.setLeadUnit(proposal.getUnitNumber());
    			 wLCurrentLoad.setActiveFlag("Y");
    			 wLCurrentLoad.setArrivalDate(getDateTimeService().getCurrentTimestamp());
    			 wLCurrentLoad.setInactiveDate(null);
    			 wLCurrentLoad.setReroutedFlag("N");
    			 wLCurrentLoad.setAssignedBy(null);
    			 wLCurrentLoad.setLastApprover(null);
    			 getDataObjectService().save(wLCurrentLoad);
    			 sendNotification(proposal,personId,ospPerson);
    			 }
    			 
    		 }
     		
    		 if(wLCurrentLoadList!=null && wLCurrentLoadList.isEmpty()){
    			 if(enabledWlRouting != null && enabledWlRouting.equalsIgnoreCase("Y") && personId!=null){
    			 context.getActionRequestFactory().addRootActionRequest(
    					 context.getActionRequested().getCode(), member.getPriority(), toRecipient(member,personId), "",
    					 member.getResponsibilityId(), member.getForceAction(), getActionRequestPolicyCode(member), null);
    			 }else if(enabledWlRouting != null && enabledWlRouting.equalsIgnoreCase("N")){
    				 super.generateRequestForMember(context, member);
    			 }
    		 }else if(wLCurrentLoadList!=null && !wLCurrentLoadList.isEmpty()){
    			 WLCurrentLoad wLCurrentLoad = wLCurrentLoadList.get(0);
    			 if(wLCurrentLoad.getPerson_id()!=null){
    				 context.getActionRequestFactory().addRootActionRequest(
    						 context.getActionRequested().getCode(), member.getPriority(), toRecipient(member,wLCurrentLoad.getPerson_id()), "",
    						 member.getResponsibilityId(), member.getForceAction(), getActionRequestPolicyCode(member), null);
    			 }
    		 }
    	}else{
    		super.generateRequestForMember(context, member);
    	}
    }
    
    private String getActionRequestPolicyCode(PeopleFlowMember member) {
        ActionRequestPolicy actionRequestPolicy = member.getActionRequestPolicy();
        return (actionRequestPolicy != null) ? actionRequestPolicy.getCode() : null;
    }
    
    private Recipient toRecipient(PeopleFlowMember member,String personId) {
        Recipient recipient;
        if(personId!=null){
        recipient = new KimPrincipalRecipient(personId);
        }else{
        	recipient = new KimPrincipalRecipient(member.getMemberId());
        }
        return recipient;
    }
    
    protected String getElementValue(String docContent, String xpathExpression) {
        try {
            Document document = XmlHelper.trimXml(new ByteArrayInputStream(docContent.getBytes()));

            XPath xpath = XPathHelper.newXPath();
            String value = (String) xpath.evaluate(xpathExpression, document, XPathConstants.STRING);

            return value;

        } catch (Exception e) {
            throw new RiceRuntimeException(e.getMessage(),e);
        }
    }
    
    protected void sendNotification(DevelopmentProposal proposal,String personId,KcPerson ospPerson){
    	proposal.setContactAdministrator(ospPerson);
    	ProposalDevelopmentNotificationContext notiFicationContext =  new ProposalDevelopmentNotificationContext(proposal, "108", "OSP Notification");
        ((ProposalDevelopmentNotificationRenderer) notiFicationContext.getRenderer()).setDevelopmentProposal(proposal);
        KcNotification notification =  createNotificationObject(notiFicationContext);
        List<String> persons = new ArrayList();
        proposal.setWorkingUserRoles(KcServiceLocator.getService(ProposalDevelopmentPermissionsService.class).getPermissions(proposal.getProposalDocument()));
       
        List<ProposalUserRoles> proposalUserRoles =  proposal.getWorkingUserRoles();
        if(proposalUserRoles!=null){
        	for(ProposalUserRoles proposalUserRole : proposalUserRoles){
        		if(proposalUserRole.getRoleNames().contains(RoleConstants.AGGREGATOR_DOCUMENT_LEVEL)){
        			proposalUserRole.getUsername();
        			KcPerson proposalPerson =  getKcPersonService().getKcPersonByUserName(proposalUserRole.getUsername());
        			persons.add(proposalPerson.getPersonId());
        		}
        	}
        }
        persons.add(personId);
        if(proposal.getPrincipalInvestigator()!=null){
        	persons.add(proposal.getPrincipalInvestigator().getPersonId());
        }
        for(String person:persons){
        	NotificationTypeRecipient recipient = new NotificationTypeRecipient();
        	recipient.setPersonId(person);        
        	getKcNotificationService().sendNotification(notiFicationContext,notification,Collections.singletonList(recipient));
        }
    }
    
    private KcNotification createNotificationObject(NotificationContext context) {
        KcNotification notification = new KcNotification();
        
        NotificationType notificationType = getNotificationType(context);
        if (notificationType != null) {
            notification.setNotificationTypeId(notificationType.getNotificationTypeId());
            notification.setDocumentNumber(context.getDocumentNumber());
            String instanceSubject = context.replaceContextVariables(notificationType.getSubject());
            notification.setSubject(instanceSubject);
            String instanceMessage = context.replaceContextVariables(notificationType.getMessage());
            notification.setMessage(instanceMessage);
            notification.setNotificationType(notificationType);
            notification.setCreateUser("Kuali Coeus System");
            notification.setCreateTimestamp(KcServiceLocator.getService(DateTimeService.class).getCurrentTimestamp());
        }
        
        return notification;
    }
    private NotificationType getNotificationType(NotificationContext context) {
        return getKcNotificationService().getNotificationType(context.getModuleCode(), context.getActionTypeCode());
    }
    public KcPersonService getKcPersonService() {
    	if(kcPersonService == null){
    		kcPersonService = KcServiceLocator.getService(KcPersonService.class);
    	}
    	return kcPersonService;
    }

	public void setKcPersonService(KcPersonService kcPersonService) {
		this.kcPersonService = kcPersonService;
	}
	
	public DataObjectService getDataObjectService() {
		if(dataObjectService == null){
			dataObjectService = KcServiceLocator.getService(DataObjectService.class);
    	}
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}
	
	public BusinessObjectService getBusinessObjectService() {
		if(businessObjectService == null){
			businessObjectService = KcServiceLocator.getService(BusinessObjectService.class);
    	}
		return businessObjectService;
	}

	public void setBusinessObjectService(@SuppressWarnings("deprecation") BusinessObjectService businessObjectService) {
		this.businessObjectService = businessObjectService;
	}

	public DateTimeService getDateTimeService() {
		if(dateTimeService == null){
			dateTimeService = KcServiceLocator.getService(DateTimeService.class);
    	}
		return dateTimeService;
	}

	public void setDateTimeService(DateTimeService dateTimeService) {
		this.dateTimeService = dateTimeService;
	}
	
	public KcNotificationService getKcNotificationService() {
		if(kcNotificationService == null){
			kcNotificationService =  KcServiceLocator.getService(KcNotificationService.class);
		}
		return kcNotificationService;
	}

	public void setKcNotificationService(KcNotificationService kcNotificationService) {
		this.kcNotificationService = kcNotificationService;
	}
}
