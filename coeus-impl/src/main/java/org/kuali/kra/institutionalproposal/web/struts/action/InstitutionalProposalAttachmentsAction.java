/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the Educational Community License, Version 2.0 (the "License");
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
package org.kuali.kra.institutionalproposal.web.struts.action;


import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.kuali.coeus.sys.framework.controller.StrutsConfirmation;

import org.kuali.kra.award.rule.event.AddAwardAttachmentEvent;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachmentFormBean;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachments;
import org.kuali.kra.institutionalproposal.attachments.InstitutionalProposalAttachmentsData;
import org.kuali.kra.institutionalproposal.document.InstitutionalProposalDocument;
import org.kuali.kra.institutionalproposal.home.*;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalAddAttachmentRuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalAddAttachmentRuleImpl;
import org.kuali.kra.institutionalproposal.web.struts.form.InstitutionalProposalForm;
import org.kuali.rice.coreservice.framework.parameter.ParameterConstants;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class InstitutionalProposalAttachmentsAction extends InstitutionalProposalAction {
	
	private static final ActionForward RESPONSE_ALREADY_HANDLED = null;
    private static final String CONFIRM_DELETE_ATTACHMENT = "confirmDeleteAttachment";
    private static final String CONFIRM_VOID_ATTACHMENT = "confirmVoidAttachment";
    private static final String CONFIRM_DELETE_ATTACHMENT_KEY = "confirmDeleteAttachmentKey";
    private static final String CONFIRM_VOID_ATTACHMENT_KEY = "confirmVoidAttachmentKey";
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ActionForward forward = super.execute(mapping, form, request, response);
        
        return forward;
    }
    
    
    
    /**
     * This method is used to add a new InstitutionalProposal Attachment
     * 
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return mapping forward
     * @throws Exception
     */
    public ActionForward addAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
    	InstitutionalProposalAttachments instProposalAttachment = ((InstitutionalProposalForm) form).getInstitutionalProposalAttachmentBean().getNewAttachment();
    	InstitutionalProposalForm instProposalForm = ((InstitutionalProposalForm)form);
        InstitutionalProposalDocument instProposal = instProposalForm.getInstitutionalProposalDocument();
        String errorPath = "institutionalProposal";
        InstitutionalProposalAddAttachmentRuleEvent event = new InstitutionalProposalAddAttachmentRuleEvent(errorPath, instProposal, instProposalAttachment);
        if(new InstitutionalProposalAddAttachmentRuleImpl().processAddInstitutionalProposalAttachmentBusinessRules(event)){
        ((InstitutionalProposalForm) form).getInstitutionalProposalAttachmentBean().addNewInstitutionalProposalAttachment();
        instProposalAttachment.setViewAttachment(true);
        }
        return mapping.findForward(Constants.MAPPING_BASIC);
    }
    /**
     * This method is used to View InstitutionalProposal Attachment
     * 
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return mapping forward
     * @throws Exception
     */
    
    public ActionForward viewAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {  
        InstitutionalProposalForm InstitutionalProposalForm = (InstitutionalProposalForm) form;
        final int selection = this.getSelectedLine(request);
        final InstitutionalProposalAttachments attachment = InstitutionalProposalForm.getInstitutionalProposalAttachmentBean().retrieveExistingAttachment(selection);
        
        if (attachment == null) {
            return mapping.findForward(Constants.MAPPING_BASIC);
        }
        
        final InstitutionalProposalAttachmentsData file = attachment.getFile();
        this.streamToResponse(file.getData(), getValidHeaderString(file.getName()),  getValidHeaderString(file.getType()), response);
        return RESPONSE_ALREADY_HANDLED;
    }
    
    /**
     * This method is used to modify InstitutionalProposal Attachment
     * 
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return mapping forward
     * @throws Exception
     */
    
    public ActionForward modifyAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {  
        InstitutionalProposalForm InstitutionalProposalForm = (InstitutionalProposalForm) form;
        final int selection = this.getSelectedLine(request);
        InstitutionalProposalDocument instProposalDocumnet=(InstitutionalProposalDocument) InstitutionalProposalForm.getDocument();
        instProposalDocumnet.getInstitutionalProposalList().get(0).getInstProposalAttachments().get(selection).setModifyAttachment(true);
        return mapping.findForward(Constants.MAPPING_BASIC);
    }
    
    public ActionForward applyModifyAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
    	InstitutionalProposalForm institutionalProposalForm = (InstitutionalProposalForm) form;
        InstitutionalProposalDocument intitutionalProposalDocument = institutionalProposalForm.getInstitutionalProposalDocument();
        int voidAttachment = getSelectedLine(request);
        InstitutionalProposalAttachments instProposalAttachment = ((InstitutionalProposalForm) form).getInstitutionalProposalAttachmentBean().getNewAttachment();
    	String errorPath = "institutionalProposal";
        InstitutionalProposalAddAttachmentRuleEvent event = new InstitutionalProposalAddAttachmentRuleEvent(errorPath, intitutionalProposalDocument, instProposalAttachment);
        if(new InstitutionalProposalAddAttachmentRuleImpl().processAddInstitutionalProposalAttachment(event,voidAttachment)){
        	intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().get(voidAttachment).setModifyAttachment(false);
        	getBusinessObjectService().save(intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().get(voidAttachment));
        }
        return mapping.findForward(Constants.MAPPING_BASIC);
    }
    
    public ActionForward voidAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
    	InstitutionalProposalForm institutionalProposalForm = (InstitutionalProposalForm) form;
        InstitutionalProposalDocument intitutionalProposalDocument = institutionalProposalForm.getInstitutionalProposalDocument();
        int voidAttachment = getSelectedLine(request);
        return confirm(buildVoidAttachmentConfirmationQuestion(mapping, form, request, response,
        		voidAttachment), CONFIRM_VOID_ATTACHMENT, "");
   }
    
    /**
     * This method is used to delete InstitutionalProposal Attachment
     * 
     * @param mapping
     * @param form
     * @param request
     * @param response
     * @return mapping forward
     * @throws Exception
     */
    
    public ActionForward deleteAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        int delAttachment = getLineToDelete(request);
        
        return confirm(buildDeleteAttachmentConfirmationQuestion(mapping, form, request, response,
                delAttachment), CONFIRM_DELETE_ATTACHMENT, "");
    }

   private StrutsConfirmation buildDeleteAttachmentConfirmationQuestion(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response, int deleteAttachment) throws Exception {
        InstitutionalProposalForm institutionalProposalForm = (InstitutionalProposalForm) form;
        InstitutionalProposalDocument intitutionalProposalDocument = institutionalProposalForm.getInstitutionalProposalDocument();
        InstitutionalProposalAttachments attachment = intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().get(deleteAttachment);
        
        return buildParameterizedConfirmationQuestion(mapping, form, request, response, CONFIRM_DELETE_ATTACHMENT_KEY,
                KeyConstants.QUESTION_DELETE_ATTACHMENT, "Institutional Proposal Attachment", attachment.getAttachmentTitle());
    }
   
   private StrutsConfirmation buildVoidAttachmentConfirmationQuestion(ActionMapping mapping, ActionForm form,
           HttpServletRequest request, HttpServletResponse response, int deleteAttachment) throws Exception {
       InstitutionalProposalForm institutionalProposalForm = (InstitutionalProposalForm) form;
       InstitutionalProposalDocument intitutionalProposalDocument = institutionalProposalForm.getInstitutionalProposalDocument();
       InstitutionalProposalAttachments attachment = intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().get(deleteAttachment);
       
       return buildParameterizedConfirmationQuestion(mapping, form, request, response, CONFIRM_VOID_ATTACHMENT_KEY,
               KeyConstants.QUESTION_VOID_ATTACHMENT,"","");
   }
   
   public ActionForward confirmDeleteAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
           HttpServletResponse response) throws Exception {
	   InstitutionalProposalForm institutionalProposalForm = (InstitutionalProposalForm) form;
       InstitutionalProposalDocument intitutionalProposalDocument = institutionalProposalForm.getInstitutionalProposalDocument();
       int delAttachment = getLineToDelete(request);
       getBusinessObjectService().delete(intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().get(delAttachment));
       intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().remove(delAttachment);
       return mapping.findForward(Constants.MAPPING_BASIC);
   }
   
   public ActionForward confirmVoidAttachment(ActionMapping mapping, ActionForm form, HttpServletRequest request,
           HttpServletResponse response) throws Exception {
	   InstitutionalProposalForm institutionalProposalForm = (InstitutionalProposalForm) form;
       InstitutionalProposalDocument intitutionalProposalDocument = institutionalProposalForm.getInstitutionalProposalDocument();
       int voidAttachment = getSelectedLine(request);
       intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().get(voidAttachment).setDocumentStatusCode("V");
       getBusinessObjectService().save(intitutionalProposalDocument.getInstitutionalProposal().getInstProposalAttachments().get(voidAttachment));
       return mapping.findForward(Constants.MAPPING_BASIC);
   }
    
    

}
