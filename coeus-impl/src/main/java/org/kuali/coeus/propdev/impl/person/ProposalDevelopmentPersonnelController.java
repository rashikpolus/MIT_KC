/*
 * Kuali Coeus, a comprehensive research administration system for higher education.
 * 
 * Copyright 2005-2015 Kuali, Inc.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.kuali.coeus.propdev.impl.person;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.notification.impl.bo.KcNotification;
import org.kuali.coeus.common.notification.impl.bo.NotificationTypeRecipient;
import org.kuali.coeus.common.view.wizard.framework.WizardControllerService;
import org.kuali.coeus.common.view.wizard.framework.WizardResultsDto;
import org.kuali.coeus.propdev.impl.core.*;
import org.kuali.coeus.common.questionnaire.framework.answer.Answer;
import org.kuali.coeus.common.questionnaire.framework.answer.AnswerHeader;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentViewHelperServiceImpl;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationContext;
import org.kuali.coeus.propdev.impl.notification.ProposalDevelopmentNotificationRenderer;
import org.kuali.coeus.propdev.impl.person.attachment.ProposalPersonBiography;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.coeus.common.api.sponsor.hierarchy.SponsorHierarchyService;
import org.kuali.coeus.common.framework.person.PersonTypeConstants;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.uif.UifConstants;
import org.kuali.rice.krad.uif.UifParameters;
import org.kuali.rice.krad.uif.util.ObjectPropertyUtils;
import org.kuali.rice.krad.web.controller.MethodAccessible;
import org.kuali.rice.krad.web.form.DocumentFormBase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;


@Controller
public class ProposalDevelopmentPersonnelController extends ProposalDevelopmentControllerBase {
	public static final String PROPOSAL_PERSONS_PATH = "document.developmentProposal.proposalPersons";
	private static final String SPONSOR_HEIRARCHY= "COIHierarchyName";
	private static final String COI_SPONSOR_HEIRARCHY_LEVEL1= "COIHierarchyLevel1";
	
    @Autowired
    @Qualifier("wizardControllerService")
    private WizardControllerService wizardControllerService;

    @Autowired
    @Qualifier("keyPersonnelService")
	private KeyPersonnelService keyPersonnelService;
    

	@Autowired
	@Qualifier("dataObjectService")
	private DataObjectService dataObjectService;

	@Autowired
    @Qualifier("sponsorHierarchyService")
    private SponsorHierarchyService sponsorHierarchyService;
	
	
    @Autowired
    @Qualifier("proposalPersonCoiIntegrationService")
    private ProposalPersonCoiIntegrationService proposalPersonCoiIntegrationService;


	@Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=navigate", "actionParameters[navigateToPageId]=PropDev-PersonnelPage"})
    public ModelAndView navigateToPersonnel(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) throws Exception {
        for (ProposalPerson person : form.getProposalDevelopmentDocument().getDevelopmentProposal().getProposalPersons()) {
            //workaround for the document associated with the OJB retrived dev prop not having a workflow doc.
            person.setDevelopmentProposal(form.getProposalDevelopmentDocument().getDevelopmentProposal());
            person.getQuestionnaireHelper().populateAnswers();
        }
        return super.navigate(form, result, request, response);
    }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=prepareAddPersonDialog"})
    public ModelAndView prepareAddPersonDialog(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form) {
        form.getAddKeyPersonHelper().setLineType(PersonTypeConstants.EMPLOYEE.getCode());
        return getModelAndViewService().showDialog("PropDev-PersonnelPage-Wizard",true,form);
    }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=navigateToPersonError"})
    public ModelAndView navigateToPersonError(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response) throws Exception {
        form.setAjaxReturnType("update-page");
    	return navigateToPersonnel(form, result, request, response);
    } 
    
    @Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=save", "pageId=PropDev-PersonnelPage"})
    public ModelAndView save(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form, BindingResult result, 
    		HttpServletRequest request, HttpServletResponse response) throws Exception {
    	ProposalDevelopmentDocumentForm pdForm = (ProposalDevelopmentDocumentForm) form;
    	ModelAndView mv = super.save(form);
    	return mv;
    }

   @Transactional @RequestMapping(value = "/proposalDevelopment", params="methodToCall=performPersonnelSearch")
   public ModelAndView performPersonnelSearch(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form, BindingResult result,
           HttpServletRequest request, HttpServletResponse response) throws Exception {
       form.getAddKeyPersonHelper().getResults().clear();
       List<Object> results = new ArrayList<Object>();

       for (Object object : getWizardControllerService().performWizardSearch(form.getAddKeyPersonHelper().getLookupFieldValues(),form.getAddKeyPersonHelper().getLineType())) {
           WizardResultsDto wizardResult = (WizardResultsDto) object;
           String personId = wizardResult.getKcPerson() != null ? wizardResult.getKcPerson().getPersonId() : wizardResult.getRolodex().getRolodexId().toString();
           if (!personAlreadyExists(personId,form.getDevelopmentProposal().getProposalPersons())) {
               results.add(object);
           }
       }

       form.getAddKeyPersonHelper().setResults(results);
       return getRefreshControllerService().refresh(form);
   }

   @Transactional @RequestMapping(value = "/proposalDevelopment", params="methodToCall=addPerson")
   public ModelAndView addPerson(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form, BindingResult result,
           HttpServletRequest request, HttpServletResponse response) throws Exception {
       ProposalPerson newProposalPerson = new ProposalPerson();
       for (Object object : form.getAddKeyPersonHelper().getResults()) {
           WizardResultsDto wizardResult = (WizardResultsDto) object;
           if (wizardResult.isSelected() == true) {
               if (wizardResult.getKcPerson() != null) {
                   newProposalPerson.setPersonId(wizardResult.getKcPerson().getPersonId());
                   newProposalPerson.setFullName(wizardResult.getKcPerson().getFullName());
                   newProposalPerson.setUserName(wizardResult.getKcPerson().getUserName());
               } else if (wizardResult.getRolodex() != null) {
                   newProposalPerson.setRolodexId(wizardResult.getRolodex().getRolodexId());
                   newProposalPerson.setFullName(wizardResult.getRolodex().getFullName());

               }
               break;
           }
       }

       newProposalPerson.setProposalPersonRoleId((String)form.getAddKeyPersonHelper().getParameter("personRole"));
       if (form.getAddKeyPersonHelper().getParameterMap().containsKey("keyPersonProjectRole")) {
        newProposalPerson.setProjectRole((String)form.getAddKeyPersonHelper().getParameter("keyPersonProjectRole"));
       }
       getKeyPersonnelService().addProposalPerson(newProposalPerson, form.getProposalDevelopmentDocument());
       Collections.sort(form.getProposalDevelopmentDocument().getDevelopmentProposal().getProposalPersons(), new ProposalPersonRoleComparator());
       form.getAddKeyPersonHelper().reset();
       form.setAjaxReturnType(UifConstants.AjaxReturnTypes.UPDATEPAGE.getKey());
       return super.save(form);
   }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=navigate", "actionParameters[navigateToPageId]=PropDev-CreditAllocationPage"})
    public ModelAndView navigateToCreditAllocation(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form, BindingResult result,
                                  HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = super.navigate(form,result,request,response);
        ((ProposalDevelopmentViewHelperServiceImpl) form.getViewHelperService()).populateCreditSplits(form);
        return mv;
    }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=deleteLine", "pageId=PropDev-PersonnelPage"})
    public ModelAndView deletePerson(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form,
        @RequestParam("actionParameters[" + UifParameters.SELECTED_COLLECTION_PATH + "]") String selectedCollectionPath,
        @RequestParam("actionParameters[" + UifParameters.SELECTED_LINE_INDEX + "]") String selectedLine) throws Exception {
        if (selectedCollectionPath.equals(PROPOSAL_PERSONS_PATH)) {
            Collection<Object> collection = ObjectPropertyUtils.getPropertyValue(form, selectedCollectionPath);
            Object deleteLine = ((List<Object>) collection).get(Integer.parseInt(selectedLine));

            deleteProposalPersonBios(form.getDevelopmentProposal(), (ProposalPerson) deleteLine);
        }

        return getCollectionControllerService().deleteLine(form);
    }

    private void deleteProposalPersonBios(DevelopmentProposal proposal, ProposalPerson deleteLine) {
        List<ProposalPersonBiography> tmpBios= new ArrayList<>();
        String personIdOfDeletedLine = deleteLine.getPersonId();
        for (ProposalPersonBiography biography : proposal.getPropPersonBios()) {
            if (personIdOfDeletedLine == null) {
                Integer rolodexId = deleteLine.getRolodexId();
                if (biography.getRolodexId() == null || rolodexId.compareTo(biography.getRolodexId()) != 0) {
                    tmpBios.add(biography);
                }
            }
            else {
                if (!biography.getPersonId().equals(personIdOfDeletedLine))
                    tmpBios.add(biography);
            }
        }
        proposal.setPropPersonBios(tmpBios);
    }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params = "methodToCall=clearAnswers")
   public ModelAndView clearAnswers(@ModelAttribute("KualiForm") DocumentFormBase form, BindingResult result,
           HttpServletRequest request, HttpServletResponse response) throws Exception {
	   ProposalDevelopmentDocumentForm pdForm = (ProposalDevelopmentDocumentForm) form;
	   String personNumber = pdForm.getActionParamaterValue("personNumber");
	   for (ProposalPerson person : pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().getProposalPersons()) {
		   if (StringUtils.equals(personNumber, person.getProposalPersonNumber().toString())) {
			   //get the certification questions
			   AnswerHeader ah = person.getQuestionnaireHelper().getAnswerHeaders().get(0);
			   for (Answer answer : ah.getAnswers()) {
				   answer.setAnswer(null);
			   }
		   }
	   }
	   saveAnswerHeaders(pdForm,request.getParameter(UifParameters.PAGE_ID));
	   ModelAndView mv = this.save(pdForm, result, request, response);
	   return mv;
   }
    @Transactional @RequestMapping(value = "/proposalDevelopment", params = "methodToCall=certificationToggle")
    public ModelAndView certificationToggle(@ModelAttribute("KualiForm") DocumentFormBase form, BindingResult result,
                                            HttpServletRequest request, HttpServletResponse response) throws Exception {
        ProposalDevelopmentDocumentForm pdForm = (ProposalDevelopmentDocumentForm) form;
        String personNumber = pdForm.getActionParamaterValue("personNumber");
        for (ProposalPerson person : pdForm.getProposalDevelopmentDocument().getDevelopmentProposal().getProposalPersons()) {
            if (StringUtils.equals(personNumber, person.getProposalPersonNumber().toString())) {

                person.setOptInCertificationStatus(!person.getOptInCertificationStatus());
                if (!person.getOptInCertificationStatus()){
                    return clearAnswers(form, result, request, response);
                }
            }
        }
        return getRefreshControllerService().refresh(form);
    }


    @Transactional @RequestMapping(value = "/proposalDevelopment", params = "methodToCall=viewCertification")
    public ModelAndView viewCertification(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form,
                                       @RequestParam("actionParameters[" + UifParameters.SELECTED_LINE_INDEX + "]") String selectedLine) throws Exception {
    ProposalPerson person = form.getDevelopmentProposal().getProposalPerson(Integer.parseInt(selectedLine));
    person.getQuestionnaireHelper().populateAnswers();
    form.setProposalPersonQuestionnaireHelper(person.getQuestionnaireHelper());
    return getModelAndViewService().showDialog("PropDev-SubmitPage-CertificationDetail",true,form);
    }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params = "methodToCall=sendCertificationNotification")
    public ModelAndView sendCertificationNotification(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form,
                                       @RequestParam("actionParameters[" + UifParameters.SELECTED_LINE_INDEX + "]") String selectedLine) throws Exception {

        sendPersonNotification(form, String.valueOf(selectedLine));
        return super.save(form);
    }


    public void sendPersonNotification(ProposalDevelopmentDocumentForm form, String selectedLine) throws Exception {
        ProposalPerson person = form.getDevelopmentProposal().getProposalPerson(Integer.parseInt(selectedLine));
        String currentUser=getGlobalVariableService().getUserSession().getPrincipalId();
        ProposalDevelopmentNotificationContext context = null;
        String sponsorHeirarchy =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, SPONSOR_HEIRARCHY); 
        String sponsorHeirarchyLevelName =   getParameterService().getParameterValueAsString(ProposalDevelopmentDocument.class, COI_SPONSOR_HEIRARCHY_LEVEL1);
        form.getDevelopmentProposal().setWorkingUserRoles(form.getWorkingUserRoles());
        if (getSponsorHierarchyService().isSponsorInHierarchy(form.getDevelopmentProposal().getSponsorCode(), sponsorHeirarchy,1,sponsorHeirarchyLevelName)) {
        	  context =  new ProposalDevelopmentNotificationContext(form.getDevelopmentProposal(), "107", "Certify Notification");
        }else{
        	  context =  new ProposalDevelopmentNotificationContext(form.getDevelopmentProposal(), "104", "Certify Notification");
        }
        ((ProposalDevelopmentNotificationRenderer) context.getRenderer()).setDevelopmentProposal(form.getDevelopmentProposal());
        ((ProposalDevelopmentNotificationRenderer) context.getRenderer()).setProposalPerson(person);
        KcNotification notification = getKcNotificationService().createNotificationObject(context);
        NotificationTypeRecipient recipient = new NotificationTypeRecipient();
        recipient.setPersonId(person.getPersonId());        
        getKcNotificationService().sendNotification(context,notification,Collections.singletonList(recipient));
        getGlobalVariableService().getMessageMap().putInfoForSectionId("PropDev-PersonnelPage-Collection", KeyConstants.INFO_NOTIFICATIONS_SENT, person.getFullName()+" "+notification.getCreateTimestamp());
        person.setLastNotification(((DateTimeService) KcServiceLocator.getService(Constants.DATE_TIME_SERVICE_NAME)).getCurrentTimestamp());
        getDataObjectService().save(person);
    }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params = "methodToCall=sendAllCertificationNotifications")
    public ModelAndView sendAllCertificationNotifications(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form) throws Exception {
        int index = 0;
        for (ProposalPerson proposalPerson : form.getDevelopmentProposal().getProposalPersons()) {
        	if(proposalPerson.isSelectedPerson()){
        		boolean certificationComplete = true;
        		for (AnswerHeader answerHeader : proposalPerson.getQuestionnaireHelper().getAnswerHeaders()) {
        			certificationComplete &= answerHeader.isCompleted();
        		}
        			sendPersonNotification(form, String.valueOf(index));
        	}  
        	index++;
        }
        return getRefreshControllerService().refresh(form);
    }



    @Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=movePersonUp"})
    public ModelAndView movePersonUp(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form,
                                     @RequestParam("actionParameters[" + UifParameters.SELECTED_LINE_INDEX + "]") String selectedLine) throws Exception {

        swapAdjacentPersonnel(form.getDevelopmentProposal().getProposalPersons(), Integer.parseInt(selectedLine), MoveOperationEnum.MOVING_PERSON_UP);

        return getRefreshControllerService().refresh(form);
    }

    @Transactional @RequestMapping(value = "/proposalDevelopment", params={"methodToCall=movePersonDown"})
    public ModelAndView movePersonDown(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form,
                                     @RequestParam("actionParameters[" + UifParameters.SELECTED_LINE_INDEX + "]") String selectedLine) throws Exception {

        swapAdjacentPersonnel(form.getDevelopmentProposal().getProposalPersons(), Integer.parseInt(selectedLine), MoveOperationEnum.MOVING_PERSON_DOWN);

        return getRefreshControllerService().refresh(form);
    }

    @MethodAccessible @Transactional @RequestMapping(value = "/proposalDevelopment", params = "methodToCall=certifyAnswers")
    public ModelAndView certifyAnswers(@ModelAttribute("KualiForm") ProposalDevelopmentDocumentForm form) throws Exception{
        String selectedPersonId = form.getProposalPersonQuestionnaireHelper().getProposalPerson().getPersonId();
        for (ProposalPerson proposalPerson : form.getDevelopmentProposal().getProposalPersons()) {
            if (StringUtils.equals(proposalPerson.getPersonId(),selectedPersonId)) {
                proposalPerson.setQuestionnaireHelper(form.getProposalPersonQuestionnaireHelper());
            }
        }
        	super.save(form);
        	ModelAndView view = getModelAndViewService().getModelAndView(form);
        	for (ProposalPerson proposalPerson : form.getDevelopmentProposal().getProposalPersons()) {
        		if (StringUtils.equals(proposalPerson.getPersonId(),selectedPersonId)) {
        			proposalPerson.setQuestionnaireHelper(form.getProposalPersonQuestionnaireHelper());
        			if(!isCOIQuestionAnswered(proposalPerson)){
        				if(proposalPerson.getQuestionnaireHelper()!=null && proposalPerson.getQuestionnaireHelper().getAnswerHeaders()!=null
        						&& !proposalPerson.getQuestionnaireHelper().getAnswerHeaders().isEmpty()){
        					if(proposalPerson.getQuestionnaireHelper().getAnswerHeaders().get(0).isCompleted()){
        						view =  getModelAndViewService().showDialog("PropDev-Personal-CertificationCompeleteDialog", true, form);
        					}else{
        						view =  getModelAndViewService().showDialog("PropDev-Personal-CertificationInCompeletedDialog", true, form);
        					}
        				}
        			}
        		}
        	}
        	return  view;
    }
    
   private boolean isCOIQuestionAnswered(ProposalPerson proposalPerson){
    	boolean coiQuestionsAnswered =false;
    	String loggedInUser = getGlobalVariableService().getUserSession().getPrincipalId();
    	if(proposalPerson.getPersonId()!=null && proposalPerson.getPersonId().equals(loggedInUser)){
    		coiQuestionsAnswered = getProposalPersonCoiIntegrationService().isCoiQuestionsAnswered(proposalPerson);
    	}

    	return coiQuestionsAnswered;
    }
    
    private enum MoveOperationEnum {
        MOVING_PERSON_DOWN (1),
        MOVING_PERSON_UP(-1);

        private int offset;

        private MoveOperationEnum(int offset) {
            this.offset = offset;
        }

        public int getOffset() { return offset; }
    };

    private void swapAdjacentPersonnel(List<ProposalPerson> keyPersonnel, int index1, MoveOperationEnum op) {
        ProposalPerson movingPerson = keyPersonnel.get(index1);

        if ((op == MoveOperationEnum.MOVING_PERSON_DOWN && movingPerson.isMoveDownAllowed()) || (op == MoveOperationEnum.MOVING_PERSON_UP && movingPerson.isMoveUpAllowed())) {
            int index2 = index1 + op.getOffset();
            keyPersonnel.set(index1, keyPersonnel.get(index2));
            keyPersonnel.set(index2, movingPerson);
        }
    }

    protected boolean personAlreadyExists(String personId, List<ProposalPerson> existingPersons) {
        for (ProposalPerson existingPerson: existingPersons ) {
            if (personId.equals(existingPerson.getPersonId())) {
                return true;
            }
        }
        return false;
    }

    protected KeyPersonnelService getKeyPersonnelService() {
        return keyPersonnelService;
    }

    public void setKeyPersonnelService(KeyPersonnelService keyPersonnelService) {
        this.keyPersonnelService = keyPersonnelService;
    }

    public WizardControllerService getWizardControllerService() {
        return wizardControllerService;
    }

    public void setWizardControllerService(WizardControllerService wizardControllerService) {
        this.wizardControllerService = wizardControllerService;
    }
    
	public class ProposalPersonRoleComparator implements Comparator<ProposalPerson> {
		@Override
		public int compare(ProposalPerson person1, ProposalPerson person2) {
			int retval = 0;
			if (person1.isInvestigator() || person2.isInvestigator()) {
				if (person1.isPrincipalInvestigator() || person2.isPrincipalInvestigator()) {
					if (person1.isPrincipalInvestigator()) {
						retval--;
					}
					if (person2.isPrincipalInvestigator()) {
						retval++;
					}
				}
				if (retval == 0) {
					if (person1.isMultiplePi() || person2.isMultiplePi()) {
						if (person1.isMultiplePi()) {
							retval--;
						}
						if (person2.isMultiplePi()) {
							retval++;
						}
					}
				}
			}
			if (retval == 0) {
				if (person1.isCoInvestigator() || person2.isCoInvestigator()) {
					if (person1.isCoInvestigator()) {
						retval--;
					}
					if (person2.isCoInvestigator()) {
						retval++;
					}
				}
			}
			if (retval == 0) {
				if (person1.isKeyPerson() || person2.isKeyPerson()) {
					if (person1.isKeyPerson()) {
						retval--;
					}
					if (person2.isKeyPerson()) {
						retval++;
					}
				}
			}
			return retval;
		}
	}
	
	 public DataObjectService getDataObjectService() {
			return dataObjectService;
		}

		public void setDataObjectService(DataObjectService dataObjectService) {
			this.dataObjectService = dataObjectService;
		}
		
	public SponsorHierarchyService getSponsorHierarchyService() {
	 return sponsorHierarchyService;
	}

	public void setSponsorHierarchyService(SponsorHierarchyService sponsorHierarchyService) {
		this.sponsorHierarchyService = sponsorHierarchyService;
	}
	
	public ProposalPersonCoiIntegrationService getProposalPersonCoiIntegrationService() {
		return proposalPersonCoiIntegrationService;
	}

	public void setProposalPersonCoiIntegrationService(
			ProposalPersonCoiIntegrationService proposalPersonCoiIntegrationService) {
		this.proposalPersonCoiIntegrationService = proposalPersonCoiIntegrationService;
	}
}