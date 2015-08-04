package org.kuali.coeus.propdev.impl.core;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

@Entity
@Table(name = "PROP_QUESTIONNAIRE_VALIDATION")
public final class ProposalQuestionnaireValidation extends  KcPersistableBusinessObjectBase {

    @Id
    @Column(name = "QUESTIONNAIRE_VALIDATION_ID")
    private Long questionnaireValidationId;

    @Column(name = "QUESTION_ID")
    private Long questionId;

    @Column(name = "QUESTIONNAIRE_ID")
    private Long questionnaireId;

    @Column(name = "ANSWER")
    private String answer;

    @Column(name = "VALIDATION_MESSAGE")
    private String validationMessage;

    public Long getQuestionnaireValidationId() {
		return questionnaireValidationId;
	}

	public void setQuestionnaireValidationId(Long questionnaireValidationId) {
		this.questionnaireValidationId = questionnaireValidationId;
	}

	public Long getQuestionId() {
		return questionId;
	}

	public void setQuestionId(Long questionId) {
		this.questionId = questionId;
	}

	public Long getQuestionnaireId() {
		return questionnaireId;
	}

	public void setQuestionnaireId(Long questionnaireId) {
		this.questionnaireId = questionnaireId;
	}

	public String getAnswer() {
		return answer;
	}

	public void setAnswer(String answer) {
		this.answer = answer;
	}

	public String getValidationMessage() {
		return validationMessage;
	}

	public void setValidationMessage(String validationMessage) {
		this.validationMessage = validationMessage;
	}

}

    
 