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
package org.kuali.kra.award.web.struts.action;

import static org.apache.commons.lang3.StringUtils.isNotBlank;
import static org.apache.commons.lang3.StringUtils.substringBetween;
import static org.kuali.rice.krad.util.KRADConstants.METHOD_TO_CALL_ATTRIBUTE;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.kuali.coeus.common.framework.attachment.AttachmentFile;
import org.kuali.coeus.common.framework.auth.UnitAuthorizationService;
import org.kuali.coeus.common.framework.auth.perm.KcAuthorizationService;
import org.kuali.coeus.common.framework.medusa.MedusaBean;
import org.kuali.coeus.common.framework.medusa.MedusaNode;
import org.kuali.coeus.common.framework.medusa.MedusaService;
import org.kuali.coeus.common.framework.module.CoeusModule;
import org.kuali.coeus.common.impl.SharedDocumentService;
import org.kuali.coeus.propdev.impl.attachment.Narrative;
import org.kuali.coeus.propdev.impl.attachment.NarrativeAttachment;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.sys.framework.controller.StrutsConfirmation;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.AwardForm;
import org.kuali.kra.award.awardhierarchy.sync.AwardSyncType;
import org.kuali.kra.award.contacts.AwardPerson;
import org.kuali.kra.award.contacts.AwardPersonUnit;
import org.kuali.kra.award.contacts.AwardProjectPersonnelBean;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.notesandattachments.attachments.AwardAttachment;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachments;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachmentsData;
import org.kuali.kra.institutionalproposal.document.InstitutionalProposalDocument;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.negotiations.bo.Negotiation;
import org.kuali.kra.protocol.ProtocolBase;
import org.kuali.kra.subaward.bo.SubAward;
import org.kuali.kra.subaward.bo.SubAwardAttachments;
import org.kuali.rice.kim.api.permission.PermissionService;
import org.kuali.rice.kim.api.services.KimApiServiceLocator;
import org.kuali.rice.krad.util.GlobalVariables;
import org.kuali.rice.krad.util.KRADConstants;

import edu.mit.kc.award.SharedDocForm;
import edu.mit.kc.award.contacts.AwardPersonRemove;
import edu.mit.kc.bo.SharedDocumentType;
import edu.mit.kc.infrastructure.KcMitConstants;
/**
 * 
 * This class represents the Struts Action for Medusa page(AwardMedusa.jsp)
 */
public class AwardSharedDocAction extends AwardAction {    
	private static final ActionForward RESPONSE_ALREADY_HANDLED = null;
	private MedusaService medusaService;
	private Long moduleIdentifier;
	 private KcAuthorizationService kraAuthorizationService;
	private List<SharedDocumentType> sharedDocType=new ArrayList<SharedDocumentType>();
	
	
	private static final String PROJECT_PERSON_PREFIX = ".personIndex";
    private static final String LINE_SUFFIX = ".line";

    private static final String CONFIRM_SYNC_UNIT_DETAILS = "confirmSyncUnitDetails";
    private static final String ADD_SYNC_UNIT_DETAILS = "addSyncUnitDetails";
    private static final String CONFIRM_SYNC_UNIT_CONTACTS_KEY = "confirmSyncUnitContactsKey";
	
    
	 protected  MedusaService getMedusaService (){
	        if (medusaService == null)
	            medusaService = KcServiceLocator.getService(MedusaService.class);
	        return medusaService;
	    }
	 public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		 if(form.getClass().getName().equals("org.kuali.kra.award.AwardForm")){ 
    		 AwardForm awardForm = (AwardForm) form; 
    		 ActionForward actionForward = super.execute(mapping, form, request, response);
    		 return actionForward;
    	 }else{
		 SharedDocForm sharedDocForm=(SharedDocForm)form;
	
		 ActionForward actionForward = super.execute(mapping, form, request, response); 
		 String currentUser = GlobalVariables.getUserSession().getPrincipalId();
		 
		 sharedDocForm.setPi(isLoggedInUserPI(currentUser,sharedDocForm));

		 sharedDocForm.setKpMaintenanceRole(KimApiServiceLocator.getPermissionService().hasPermission(GlobalVariables.getUserSession().getPrincipalId(), "KC-AWARD", KcMitConstants.AWARD_KEYPERSON_MAINTENANCE_ROLE));  //Move to Constants
		 sharedDocForm.setAwardPersonRemovalHistory(new AwardContactsAction().getProjectPersonRemovalHistory(form));
		 List<SharedDocumentType>sharedDocTypeNew=getSharedDocType();
		 sharedDocForm.setSharedDocType(sharedDocTypeNew);
		 
		 getSharedDocumentService().populateAttachmentPermission(sharedDocForm.getMedusaBean());
		 
		      		
	 return actionForward;
	 }
		 }
	 
	
    public ActionForward viewAttachmentIp(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {  
     InstitutionalProposalAttachments attachment =null;
    	 InstitutionalProposal institutionalProposal =null;
    	 Long proposalId=null;
    	 final int selection = this.getSelectedLine(request);
    	   int selectedLine = -1;
           String parameterName = (String) request.getAttribute(KRADConstants.METHOD_TO_CALL_ATTRIBUTE);
           if (StringUtils.isNotBlank(parameterName)) {
               String lineNumber = StringUtils.substringBetween(parameterName, ".line", ".");
              String proposalIdOld = (StringUtils.substringBetween(parameterName, ".id", "."));
              proposalId=Long.valueOf(proposalIdOld);
               selectedLine = Integer.parseInt(lineNumber);
           }
           MedusaNode node = getMedusaService().getMedusaNode("IP", proposalId);
           institutionalProposal=(InstitutionalProposal) node.getData();
        if(institutionalProposal!=null){
      attachment= institutionalProposal.getInstProposalAttachments().get(selection);
      }
       if (attachment == null) {
            return mapping.findForward(Constants.MAPPING_BASIC);
        }        
        final InstitutionalProposalAttachmentsData file = attachment.getFile();
       this.streamToResponse(file.getData(), getValidHeaderString(file.getName()),  getValidHeaderString(file.getType()), response);
        return RESPONSE_ALREADY_HANDLED;
    }
	
    public ActionForward viewAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {  
        AwardForm awardForm = (AwardForm) form;  
       
        AwardAttachment attachment=null;
        Award award=null;
      Long awardId=null;
       
        final int selection = this.getSelectedLine(request);
        String parameterName = (String) request.getAttribute(KRADConstants.METHOD_TO_CALL_ATTRIBUTE);
        if (StringUtils.isNotBlank(parameterName)) {
            String lineNumber = StringUtils.substringBetween(parameterName, ".line", ".");
           String awardIdOld = (StringUtils.substringBetween(parameterName, ".id", "."));
           awardId=Long.valueOf(awardIdOld);           
        }   
        List<SharedDocumentType>sharedDocTypeNew=getSharedDocType();
        MedusaNode node = getMedusaService().getMedusaNode("award", awardId);
        award=(Award) node.getData();
        if(award!=null)
        	 attachment= award.getAwardAttachments().get(selection);        	
     
        if (attachment == null) {
        	return mapping.findForward(Constants.MAPPING_BASIC);
        }
   
        final AttachmentFile file = attachment.getFile();
        this.streamToResponse(file.getData(), getValidHeaderString(file.getName()),  getValidHeaderString(file.getType()), response);
        return RESPONSE_ALREADY_HANDLED;
        }
 
    public ActionForward viewAttachmentDp(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {  
    	 DevelopmentProposal developmentProposal =null;
    	 Long proposalNumber=null;
    	  Narrative attachment =null;
    	  List<SharedDocumentType>sharedDocTypeNew=getSharedDocType();
    	  	 final int selection = this.getSelectedLine(request);
    	  AwardForm awardForm = (AwardForm) form; 
    	  String parameterName = (String) request.getAttribute(KRADConstants.METHOD_TO_CALL_ATTRIBUTE);
          if (StringUtils.isNotBlank(parameterName)) {
              String lineNumber = StringUtils.substringBetween(parameterName, ".line", ".");
             String proposalNumberOld = (StringUtils.substringBetween(parameterName, ".id", "."));
             proposalNumber=Long.valueOf(proposalNumberOld);
              
          }
              MedusaNode node = getMedusaService().getMedusaNode("DP", proposalNumber);
          developmentProposal=(DevelopmentProposal) node.getData();    	  
          if(developmentProposal!=null){
     attachment= developmentProposal.getNarratives().get(selection);}
       if (attachment == null) {
            return mapping.findForward(Constants.MAPPING_BASIC);
        }
   
       final NarrativeAttachment file = attachment.getNarrativeAttachment();
       this.streamToResponse(file.getData(), getValidHeaderString(file.getName()),  getValidHeaderString(file.getType()), response);
        return RESPONSE_ALREADY_HANDLED;
    }
    public ActionForward viewAttachmentSubAward(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {  
    	 SubAward subAward =null;
    	 Long subAwardId=null;
    	 SubAwardAttachments attachment=null;
    	 final int selection = this.getSelectedLine(request);
    	  AwardForm awardForm = (AwardForm) form; 
    	  String parameterName = (String) request.getAttribute(KRADConstants.METHOD_TO_CALL_ATTRIBUTE);
          if (StringUtils.isNotBlank(parameterName)) {
              String lineNumber = StringUtils.substringBetween(parameterName, ".line", ".");
             String subAwardIdOld = (StringUtils.substringBetween(parameterName, ".id", "."));
             subAwardId=Long.valueOf(subAwardIdOld);
             
          }
          MedusaNode node = getMedusaService().getMedusaNode("subAward", subAwardId);
          subAward=(SubAward) node.getData();    	
          if(subAward!=null){
      attachment= subAward.getSubAwardAttachments().get(selection);}
       if (attachment == null) {
            return mapping.findForward(Constants.MAPPING_BASIC);
        }
        
        final AttachmentFile file = attachment.getFile();
       this.streamToResponse(file.getData(), getValidHeaderString(file.getName()),  getValidHeaderString(file.getType()), response);
        return RESPONSE_ALREADY_HANDLED;
    }
    
    public ActionForward close(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return mapping.findForward(KRADConstants.MAPPING_PORTAL);
    }
    
    public ActionForward refreshView(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        return mapping.findForward(Constants.MAPPING_AWARD_BASIC);
    }

	public List<SharedDocumentType> getSharedDocType() {		
		 List<SharedDocumentType> sharedDocType = 
 	            (List<SharedDocumentType>) getBusinessObjectService().findAll(SharedDocumentType.class);
		
		return sharedDocType;
	}
	
	protected SharedDocumentService getSharedDocumentService() {
	      return KcServiceLocator.getService(SharedDocumentService.class);
	}

	public void setSharedDocType(List<SharedDocumentType> sharedDocType) {
		this.sharedDocType = sharedDocType;
	}
	  
	  //For Key Person
	  @Override
	    public ActionForward save(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	        AwardForm awardForm = (AwardForm) form;
	        Award award = awardForm.getAwardDocument().getAward();
	        ActionForward forward;
	        updateContactsBasedOnRoleChange(award);
	        if (isValidSave(awardForm)) {
	            setLeadUnitOnAwardFromPILeadUnit(award, awardForm);
	            award.initCentralAdminContacts();
	            forward = super.save(mapping, form, request, response);
	        } else {
	            forward = mapping.findForward(Constants.MAPPING_AWARD_BASIC);            
	        }
	        return forward;
	    }
	    
	    protected void updateContactsBasedOnRoleChange(Award award) {
	        for (AwardPerson person : award.getProjectPersons()) {
	            if (person.isRoleChanged()) {
	                person.updateBasedOnRoleChange();
	                person.setRoleChanged(false);
	            }
	        }
	    }
	    
	    /**
	     * This method is called to reset the Lead Unit on the award if the lead unit is changed on the PI.
	     * @param award
	     */
	    @SuppressWarnings("unchecked")
	    private void setLeadUnitOnAwardFromPILeadUnit(Award award, AwardForm awardForm) {
	        for (AwardPerson person : award.getProjectPersons()) {
	            if (person.isPrincipalInvestigator() && person.getUnits().size() >= 1) {
	                AwardPersonUnit selectedUnit = null;
	                for (AwardPersonUnit unit : person.getUnits()) {
	                    if (unit.isLeadUnit()) {
	                        selectedUnit = unit;
	                    }
	                }
	                //if a unit hasn't been selected as lead, use the first unit
	                if (selectedUnit == null) {
	                    selectedUnit = person.getUnit(0);
	                }
	                if (selectedUnit != null) {
	                    award.setUnitNumber(selectedUnit.getUnitNumber());
	                    award.setLeadUnit(selectedUnit.getUnit());
	                } else {
	                    award.setUnitNumber(null);
	                    award.setLeadUnit(null);
	                }
	            }
	        }
	    }
	    /**
	     * @param mapping
	     * @param form
	     * @param request
	     * @param response
	     * @return
	     * @throws Exception
	     */
	    public ActionForward addProjectPerson(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) 
	                                                                                                                        throws Exception {
	        AwardPerson awardPerson = getProjectPersonnelBean(form).addProjectPerson();
	        if (awardPerson != null) {
	            return this.confirmSyncAction(mapping, form, request, response, AwardSyncType.ADD_SYNC, awardPerson, "projectPersons", null, 
	                    mapping.findForward(Constants.MAPPING_AWARD_BASIC));
	        } else {
	            return mapping.findForward(Constants.MAPPING_AWARD_BASIC);
	        }


	    }
	    /**
	     * @param mapping
	     * @param form
	     * @param request
	     * @param response
	     * @return
	     * @throws Exception
	     */
	    public ActionForward deleteProjectPerson(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) 
	                                                                                                                        throws Exception {
	        AwardPerson awardPerson = getProjectPersonnelBean(form).getProjectPersonnel().get(getLineToDelete(request));
	        getProjectPersonnelBean(form).deleteProjectPerson(getLineToDelete(request));
	        getProjectPersonRemovalHistory(form);
	        return this.confirmSyncAction(mapping, form, request, response, AwardSyncType.DELETE_SYNC, awardPerson, "projectPersons", null, mapping.findForward(Constants.MAPPING_AWARD_BASIC));
	    }
	    /**
	     * @param mapping
	     * @param form
	     * @param request
	     * @param response
	     * @return
	     * @throws Exception
	     */
	    public ActionForward deleteProjectPersonUnit(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) 
	                                                                                                                        throws Exception {
	        AwardPersonUnit unit = getProjectPersonnelBean(form).getProjectPersonnel().get(getProjectPersonIndex(request)).getUnit(getLineToDelete(request));
	        getProjectPersonnelBean(form).deleteProjectPersonUnit(getProjectPersonIndex(request), getLineToDelete(request));
	        return this.confirmSyncAction(mapping, form, request, response, AwardSyncType.DELETE_SYNC, unit, "projectPersons", null, mapping.findForward(Constants.MAPPING_AWARD_BASIC));
	    }
	    private int getProjectPersonIndex(HttpServletRequest request) {
	        int selectedPersonIndex = -1;
	        String parameterName = (String) request.getAttribute(METHOD_TO_CALL_ATTRIBUTE);
	        if (isNotBlank(parameterName)) {
	            selectedPersonIndex = Integer.parseInt(substringBetween(parameterName, PROJECT_PERSON_PREFIX, LINE_SUFFIX));
	        }

	        return selectedPersonIndex;
	    }
	    private AwardProjectPersonnelBean getProjectPersonnelBean(ActionForm form) {
	        return ((AwardForm) form).getProjectPersonnelBean();
	    }
	    public ActionForward confirmProjectPerson(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)
	            throws Exception {          
	            AwardPerson awardPerson = getProjectPersonnelBean(form).getProjectPersonnel().get(getLineToEdit(request));
	            getProjectPersonnelBean(form).confirmProjectPeersonEntry(getLineToEdit(request));
	            return this.confirmSyncAction(mapping, form, request, response, AwardSyncType.ADD_SYNC, awardPerson, "projectPersons", null, mapping.findForward(Constants.MAPPING_AWARD_BASIC));
	       
	        }

	      
	    public Collection<AwardPersonRemove> getProjectPersonRemovalHistory(ActionForm form)
	            throws Exception {   
	    	Collection<AwardPersonRemove> awardPersonRemoves =  new ArrayList<AwardPersonRemove>();
	    	SharedDocForm awardForm = (SharedDocForm)form;
	    	if (awardForm.getAwardDocument().getAward().getAwardNumber() != null) {
	    		awardPersonRemoves =  getProjectPersonnelBean(form).getAwardPersonRemoval(//awardForm.getAwardDocument().getAward().getAwardId().toString(),
	    				awardForm.getAwardDocument().getAward().getAwardNumber());
	    	}
	    	if (!awardPersonRemoves.isEmpty()) {
	    		awardForm.setAwardPersonRemovalHistory(awardPersonRemoves);
	    		return awardPersonRemoves;   
	    	}    	
	    	return new ArrayList<AwardPersonRemove>();
	        }

	    //for unit details
	    public ActionForward addUnitDetails(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)
	            throws Exception {
	            AwardForm awardForm = (AwardForm) form;
	            AwardPerson person = awardForm.getProjectPersonnelBean().getProjectPersonnel().get(getSelectedLine(request));
	            awardForm.getProjectPersonnelBean().addUnitDetails(person);
	            return mapping.findForward(Constants.MAPPING_AWARD_BASIC);
	        }
	        
	        public ActionForward removeUnitDetails(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)
	            throws Exception {
	            AwardForm awardForm = (AwardForm) form;
	            AwardPerson person = awardForm.getProjectPersonnelBean().getProjectPersonnel().get(getSelectedLine(request));
	            awardForm.getProjectPersonnelBean().removeUnitDetails(person);
	            return mapping.findForward(Constants.MAPPING_AWARD_BASIC);
	        }
	        public ActionForward addNewProjectPersonUnit(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) 
                    throws Exception {       
	        	Award award = ((AwardForm)form).getAwardDocument().getAward();
	        	AwardPersonUnit newPersonUnit = getProjectPersonnelBean(form).getNewAwardPersonUnit(getSelectedLine(request));

	        	if( newPersonUnit.isLeadUnit() && award.getLeadUnit() != null){
		        	return confirm(buildSyncUnitDetailsConfirmationQuestion(mapping, form, request, response), CONFIRM_SYNC_UNIT_DETAILS, ADD_SYNC_UNIT_DETAILS);
	        	}
	        	else
	        	{
		        	AwardPersonUnit unit = getProjectPersonnelBean(form).addNewProjectPersonUnit(getSelectedLine(request));
		        	if (unit != null) {
		        	return confirmSyncAction(mapping, form, request, response, AwardSyncType.ADD_SYNC, unit, "projectPersons", null, mapping.findForward(Constants.MAPPING_AWARD_BASIC));       
		        	} else {
		        	return mapping.findForward(Constants.MAPPING_AWARD_BASIC);
		        	}
	        	}
            }
	        
	        private StrutsConfirmation buildSyncUnitDetailsConfirmationQuestion(ActionMapping mapping, ActionForm form,
	                HttpServletRequest request, HttpServletResponse response) throws Exception {        
	                
	            return buildParameterizedConfirmationQuestion(mapping, form, request, response, CONFIRM_SYNC_UNIT_CONTACTS_KEY,
	                    KeyConstants.QUESTION_SYNC_UNIT_CONTACTS);
	            
	        }
	        
	 
	        public boolean isLoggedInUserPI(String principalId,AwardForm awardForm){
	   		 AwardDocument awardDocument = awardForm.getAwardDocument();
			  Award currentAward = awardDocument.getAward();
	          	       for (AwardPerson person : currentAward.getInvestigators()) {
	          	            if ((person.isInvestigator() && person.isPrincipalInvestigator())
	          	                    && StringUtils.equals(principalId, person.getPersonId())) {
	          	                return true;
	          	            }
	          	        }
	          	        return false;
	          	    } 	     
 }
