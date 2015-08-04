package org.kuali.coeus.propdev.impl.core;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.ListUtils;
import org.kuali.coeus.common.framework.person.attr.PersonAppointment;
import org.kuali.coeus.common.questionnaire.framework.answer.Answer;
import org.kuali.coeus.common.questionnaire.framework.answer.AnswerHeader;
import org.kuali.coeus.common.questionnaire.framework.answer.QuestionnaireAnswerService;
import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.coeus.propdev.impl.person.question.ProposalPersonModuleQuestionnaireBean;
import org.kuali.coeus.sys.framework.gv.GlobalVariableService;
import org.kuali.rice.krad.data.DataObjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import edu.mit.kc.bo.PiAppointmentType;


@Component("proposalQuestionnaireValidationService")
public class ProposalQuestionnaireValidationServiceImpl implements ProposalQuestionnaireValidationService {

    @Autowired
	@Qualifier("dataObjectService")
    private DataObjectService dataObjectService;

    @Autowired
    @Qualifier("questionnaireAnswerService")
    private QuestionnaireAnswerService questionnaireAnswerService;
    
    @Autowired
    @Qualifier("globalVariableService")
    private GlobalVariableService globalVariableService;
    
    private static final String PROPOSAL_SUBMIT_PAGE_ID = "PropDev-SubmitPage-ProposalSummary";
    private static final String GENERIC_ERROR_KEY = "error.generic";
    private static final String ERROR_PI_STATUS = "error.proposal.person.pi.status";
    
	@Override
	public void executeProposalQuestionnaireValidation(DevelopmentProposal developmentProposal) {
		Map<Long, List<ProposalQuestionnaireValidation>> questionnaireValidationMessages = getProposalQuestionnaireValidationMapping();
		for(ProposalPerson proposalPerson : developmentProposal.getProposalPersons()) {
			checkPIStatus(proposalPerson);
			List<AnswerHeader> answerHeaders = getProposalQuestionnaireAnswerHeaders(developmentProposal, proposalPerson);
			buildValidationMessages(answerHeaders, questionnaireValidationMessages, proposalPerson);
		}
	}

	protected void checkPIStatus(ProposalPerson proposalPerson) {
		if((proposalPerson.isPrincipalInvestigator() || proposalPerson.isCoInvestigator()) && 
				!isAppointmentTypePI(proposalPerson)) {
        	getGlobalVariableService().getMessageMap().putWarning(PROPOSAL_SUBMIT_PAGE_ID, ERROR_PI_STATUS, new String[]{proposalPerson.getProposalPersonRoleId(), proposalPerson.getLastName()});
		}
	}
		
	protected boolean isAppointmentTypePI(ProposalPerson proposalPerson) {
		boolean isAppointmentTypePI = proposalPerson.getFacultyFlag();
		if(!isAppointmentTypePI) {
	        List<PiAppointmentType> piAppointmentTypes = getDataObjectService().findAll(PiAppointmentType.class).getResults();
	        List<PersonAppointment> appointments = proposalPerson.getPerson().getExtendedAttributes().getPersonAppointments();
	        for(PersonAppointment personAppointment : appointments) {
	            if(isPiAppointmentTypeEqualsJobTitle(piAppointmentTypes, personAppointment.getJobTitle())) {
	            	isAppointmentTypePI = true;
	            	break;
	            }
	        }
		}
        return isAppointmentTypePI;
	 }
		
	 protected boolean isPiAppointmentTypeEqualsJobTitle(List<PiAppointmentType> piAppointmentTypes, String jobTitle) {
	    for(PiAppointmentType piAppointmentType : piAppointmentTypes) {
            if(piAppointmentType.getDescription().equalsIgnoreCase(jobTitle)) {
                return true;
            }
	    }
	    return false;
	 }
	
	protected void buildValidationMessages(List<AnswerHeader> answerHeaders, Map<Long, List<ProposalQuestionnaireValidation>> questionnaireValidationMessages,
			ProposalPerson proposalPerson) {
		for(AnswerHeader answerHeader : answerHeaders) {
			Long questionnaireId = Long.parseLong(answerHeader.getQuestionnaire().getQuestionnaireSeqId());
			List<ProposalQuestionnaireValidation> proposalQuestionnaireValidations = questionnaireValidationMessages.get(questionnaireId);
			if(proposalQuestionnaireValidations != null) {
				List<Answer> questionAnswers = answerHeader.getAnswers();
				for(ProposalQuestionnaireValidation proposalQuestionnaireValidation : proposalQuestionnaireValidations) {
					for(Answer answer : questionAnswers) {
						Long questionId = answer.getQuestion().getQuestionSeqId().longValue();
						if(questionId.equals(proposalQuestionnaireValidation.getQuestionId()) && 
								answer.getAnswer() != null && answer.getAnswer().equalsIgnoreCase(proposalQuestionnaireValidation.getAnswer())) {
							String validationMessage = proposalQuestionnaireValidation.getValidationMessage().concat(getAdditionalMessage(proposalPerson));
	                    	getGlobalVariableService().getMessageMap().putWarning(PROPOSAL_SUBMIT_PAGE_ID, GENERIC_ERROR_KEY, validationMessage);
	                    	break;
						}
					}
				}
			}
		}
	}

	protected String getAdditionalMessage(ProposalPerson proposalPerson) {
		StringBuffer additionalMessage = new StringBuffer();
		if(proposalPerson != null) {
			additionalMessage.append("(");
			additionalMessage.append(proposalPerson.getProposalPersonRoleId());
			additionalMessage.append(")");
			additionalMessage.append(" ");
			additionalMessage.append(proposalPerson.getLastName());
		}
		return additionalMessage.toString();
	}
	
	protected Map<Long, List<ProposalQuestionnaireValidation>> getProposalQuestionnaireValidationMapping() {
		Map<Long, List<ProposalQuestionnaireValidation>> questionnaireValidationMessages = new HashMap<Long, List<ProposalQuestionnaireValidation>>();
		List<ProposalQuestionnaireValidation> allValidationMessages = getAllProposalQuestionnaireValidationMessages();
		List<ProposalQuestionnaireValidation> questionnaireValidations = new ArrayList<ProposalQuestionnaireValidation>();
		for(ProposalQuestionnaireValidation proposalQuestionnaireValidation : allValidationMessages) {
			questionnaireValidations = questionnaireValidationMessages.get(proposalQuestionnaireValidation.getQuestionnaireId());
			if(questionnaireValidations == null) {
				questionnaireValidations = new ArrayList<ProposalQuestionnaireValidation>();
			}
			questionnaireValidations.add(proposalQuestionnaireValidation);
			questionnaireValidationMessages.put(proposalQuestionnaireValidation.getQuestionnaireId(), questionnaireValidations);
		}
		return questionnaireValidationMessages;
	}

    protected List<AnswerHeader> getProposalQuestionnaireAnswerHeaders(DevelopmentProposal developmentProposal, ProposalPerson proposalPerson) {
        ProposalPersonModuleQuestionnaireBean moduleQuestionnaireBean = new ProposalPersonModuleQuestionnaireBean(developmentProposal, proposalPerson);
        return ListUtils.emptyIfNull(questionnaireAnswerService.getQuestionnaireAnswer(moduleQuestionnaireBean));
    }
	
	protected List<ProposalQuestionnaireValidation> getAllProposalQuestionnaireValidationMessages() {
        return getDataObjectService().findAll(ProposalQuestionnaireValidation.class).getResults();
	}
	
	public DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}

	public QuestionnaireAnswerService getQuestionnaireAnswerService() {
		return questionnaireAnswerService;
	}

	public void setQuestionnaireAnswerService(
			QuestionnaireAnswerService questionnaireAnswerService) {
		this.questionnaireAnswerService = questionnaireAnswerService;
	}

    public GlobalVariableService getGlobalVariableService() {
		return globalVariableService;
	}

	public void setGlobalVariableService(GlobalVariableService globalVariableService) {
		this.globalVariableService = globalVariableService;
	}

}
