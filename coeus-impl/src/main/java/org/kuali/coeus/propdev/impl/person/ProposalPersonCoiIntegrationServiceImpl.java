package org.kuali.coeus.propdev.impl.person;

import java.util.ArrayList;
import java.util.List;

import org.kuali.coeus.common.questionnaire.framework.answer.Answer;
import org.kuali.coeus.common.questionnaire.framework.answer.AnswerHeader;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component("proposalPersonCoiIntegrationService")
public class ProposalPersonCoiIntegrationServiceImpl implements ProposalPersonCoiIntegrationService {
	
	@Autowired
    @Qualifier("parameterService")
    private ParameterService parameterService;

	/*
	 * This method will check the questions are completed and any of the COI questions answered “yes”.
	 */
	@Override
	public boolean isCoiQuestionsAnswered(ProposalPerson proposalPerson) {
		Boolean isCoiQuestionsAnswered= false;
		for (AnswerHeader answerHeader : proposalPerson.getQuestionnaireHelper().getAnswerHeaders()) {
			boolean wasComplete = answerHeader.isCompleted();
			boolean isComplete = proposalPerson.getQuestionnaireHelper().getAnswerHeaders().get(0).isCompleted();
			if(isComplete || wasComplete){
				isCoiQuestionsAnswered = checkForCOIquestionsAnswered(answerHeader);
			}
		}
		return isCoiQuestionsAnswered;
	}

	private boolean checkForCOIquestionsAnswered(AnswerHeader answerHeader){

		boolean hasCOIquestions = false;
		String coiCertificationQuestionIds = getParameterService().getParameterValueAsString("KC-GEN", "All", "PROP_PERSON_COI_CERTIFY_QID");
		List<String> coiCertificationQuestionIdList = new ArrayList<String>();
		if(coiCertificationQuestionIds!=null){
			String[] questionIds = coiCertificationQuestionIds.split(",");
			for (String questionid : questionIds){
				coiCertificationQuestionIdList.add(questionid);
			}
		}
		for(Answer answer :answerHeader.getAnswers()){
			for(String coiCertificationQuestionId : coiCertificationQuestionIdList){
				if(coiCertificationQuestionId.equals(answer.getQuestionSeqId().toString()) && answer.getAnswer().equals("Y")){
					hasCOIquestions = true;
					break;
				}

			}
		}
		return hasCOIquestions;
	}
	
	public ParameterService getParameterService() {
		return parameterService;
	}

	public void setParameterService(ParameterService parameterService) {
		this.parameterService = parameterService;
	}
	

	@Override
	public boolean isCoiQuestionsAnsweredN(ProposalPerson proposalPerson) {
		Boolean isCoiQuestionsAnswered= false;
		for (AnswerHeader answerHeader : proposalPerson.getQuestionnaireHelper().getAnswerHeaders()) {
			boolean wasComplete = answerHeader.isCompleted();
			boolean isComplete = proposalPerson.getQuestionnaireHelper().getAnswerHeaders().get(0).isCompleted();
			if(isComplete || wasComplete){
				isCoiQuestionsAnswered = checkForCOIquestionsAnsweredN(answerHeader);
			}
		}
		return isCoiQuestionsAnswered;
	}
/**
 * check if the person has entered 'N' for all
 * @param answerHeader
 * @return
 */
	private boolean checkForCOIquestionsAnsweredN(AnswerHeader answerHeader){

		boolean hasCOIquestions = false;
		String coiCertificationQuestionIds = getParameterService().getParameterValueAsString("KC-GEN", "All", "PROP_PERSON_COI_CERTIFY_QID");
		List<String> coiCertificationQuestionIdList = new ArrayList<String>();
		if(coiCertificationQuestionIds!=null){
			String[] questionIds = coiCertificationQuestionIds.split(",");
			for (String questionid : questionIds){
				coiCertificationQuestionIdList.add(questionid);
			}
		}
		
		
		int coiIdSize = coiCertificationQuestionIdList.size();
		for(Answer answer :answerHeader.getAnswers()){
			for(String coiCertificationQuestionId : coiCertificationQuestionIdList){
				int i =  0;
				if(coiCertificationQuestionId.equals(answer.getQuestionSeqId().toString()) && answer.getAnswer().equals("N")){
					i++;
				}
				if(i == coiIdSize){
					hasCOIquestions = true;
					break;
				}
			}
		}
		return hasCOIquestions;
	}
}
