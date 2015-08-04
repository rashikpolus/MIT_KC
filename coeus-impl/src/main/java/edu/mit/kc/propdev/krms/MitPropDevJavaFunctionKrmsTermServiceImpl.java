/**
 * 
 */
package edu.mit.kc.propdev.krms;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.budget.framework.core.Budget;
import org.kuali.coeus.common.budget.framework.nonpersonnel.BudgetLineItem;
import org.kuali.coeus.common.budget.framework.period.BudgetPeriod;
import org.kuali.coeus.common.budget.framework.personnel.AppointmentType;
import org.kuali.coeus.common.framework.custom.attr.CustomAttributeDocValue;
import org.kuali.coeus.common.framework.org.OrganizationYnq;
import org.kuali.coeus.common.framework.person.attr.PersonAppointment;
import org.kuali.coeus.common.framework.sponsor.hierarchy.SponsorHierarchy;
import org.kuali.coeus.common.impl.krms.KcKrmsJavaFunctionTermServiceBase;
import org.kuali.coeus.common.questionnaire.framework.answer.Answer;
import org.kuali.coeus.common.questionnaire.framework.answer.AnswerHeader;
import org.kuali.coeus.common.questionnaire.framework.answer.QuestionnaireAnswerService;
import org.kuali.coeus.common.questionnaire.framework.core.QuestionnaireService;
import org.kuali.coeus.instprop.api.admin.ProposalAdminDetailsContract;
import org.kuali.coeus.instprop.api.admin.ProposalAdminDetailsService;
import org.kuali.coeus.propdev.api.core.SubmissionInfoService;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.propdev.impl.core.ProposalDevelopmentDocument;
import org.kuali.coeus.propdev.impl.location.ProposalSite;
import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.coeus.propdev.impl.person.attachment.ProposalPersonBiography;
import org.kuali.coeus.propdev.impl.person.question.ProposalPersonModuleQuestionnaireBean;
import org.kuali.coeus.propdev.impl.s2s.S2sOppForms;
import org.kuali.coeus.propdev.impl.specialreview.ProposalSpecialReview;
import org.kuali.coeus.propdev.impl.specialreview.ProposalSpecialReviewExemption;
import org.kuali.coeus.propdev.impl.ynq.ProposalYnq;
import org.kuali.coeus.sys.api.model.ScaleTwoDecimal;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.bo.CoeusModule;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.institutionalproposal.home.InstitutionalProposalBoLite;
import org.kuali.kra.institutionalproposal.proposaladmindetails.ProposalAdminDetails;
import org.kuali.rice.core.api.criteria.PredicateFactory;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.service.DocumentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import edu.mit.coeus.utils.xml.v2.propdev.PROPOSALDocument.PROPOSAL;
import edu.mit.kc.bo.PiAppointmentType;
import edu.mit.kc.infrastructure.KcMitConstants;
import edu.mit.kc.workloadbalancing.bo.WLCurrentLoad;

/**
 * @author kc-mit-dev
 * 
 */
public class MitPropDevJavaFunctionKrmsTermServiceImpl extends
		KcKrmsJavaFunctionTermServiceBase implements
		MitPropDevJavaFunctionKrmsTermService {
	/**
	 * KRMS Java function for NOTICE OF OPPORTUNITY IS MISSING
	 */
	@Override
	public boolean hasNoticeOfOpportunity(DevelopmentProposal developmenProposal) {

		if (developmenProposal.getNoticeOfOpportunityCode() != null) {
			return false;
		}
		return true;
	}

	/**
	 * This method checks if a proposal has NSF CODE. see FN_NO_NSF_CODE_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if there is no NSF CODE
	 */
	@Override
	public String checkNsfCode(DevelopmentProposal developmentProposal) {
		String nsfCode = developmentProposal.getNsfCode();
		if (nsfCode == null) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method checks if a proposal has SPONSOR CODE. see
	 * FN_NO_SPONSOR_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if proposal is missing a SPONSOR code
	 */
	@Override
	public String checkSponsorCode(DevelopmentProposal developmentProposal) {
		String sponsorCode = developmentProposal.getSponsorCode();
		if (sponsorCode == null) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method checks if a proposal has prime Sponsor Code. see
	 * FN_PRIME_SPONSOR_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if there is prime Sponsor Code
	 */
	@Override
	public String checkPrimeSponsorCode(DevelopmentProposal developmentProposal) {
		String primeSponsorCode = developmentProposal.getPrimeSponsorCode();
		if (primeSponsorCode != null) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method check if a proposal has a funding opportunity . see
	 * FN_NO_FUNDING_OPP_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if proposal is missing a funding opp (PROGRAM ANNOUNCEMENT
	 *         NUMBER)
	 */
	@Override
	public String checkFundingOpportunity(
			DevelopmentProposal developmentProposal) {
		String programAnnouncementNo = developmentProposal
				.getProgramAnnouncementNumber();
		if (programAnnouncementNo == null) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method check if a proposal has A DEADLINE DATE . see
	 * FN_NO_DEADLINE_DATE_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if proposal is missing a DEADLINE DATE
	 */
	@Override
	public String checkDeadlineDate(DevelopmentProposal developmentProposal) {
		Date date = developmentProposal.getDeadlineDate();
		if (date == null) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method Checks if a proposal's notice of opportunity type is a
	 * specified one. see FN_NOTICE_OF_OPP_TYPE_RULE.
	 * 
	 * @param developmentProposal
	 * @param noticeOfOpportunityCode
	 * @return 'true' if both are same.
	 */
	@Override
	public String checkNopCodeRule(DevelopmentProposal developmentProposal,
			String noticeOfOpportunityCode) {
		String nopCodeProposal = developmentProposal
				.getNoticeOfOpportunityCode();
		if (nopCodeProposal.equals(noticeOfOpportunityCode)) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method Checks if a proposal's grants.gov submission type is a
	 * specified one. see fn_s2s_sub_type_rule.
	 * 
	 * @param developmentProposal
	 * @param s2sSubmissionTypeCOde
	 * @return 'true' if both are same.
	 */
	@Override
	public String checkS2SSubTypeRule(DevelopmentProposal developmentProposal,
			String s2sSubTypeCode) {
		String s2sSubTypeProp = developmentProposal.getS2sOpportunity()
				.getS2sSubmissionTypeCode();
		if (s2sSubTypeProp.equals(s2sSubTypeCode)) {
			return TRUE;
		}
		return FALSE;
	}

	@Override
	public String isPrimeEqualsSponsor(DevelopmentProposal developmentProposal) {
		if (developmentProposal.getSponsorCode() != null
				&& developmentProposal.getPrimeSponsorCode() != null) {
			if (developmentProposal.getSponsorCode().equals(
					developmentProposal.getPrimeSponsorCode())) {
				return TRUE;
			}

		}
		return FALSE;
	}

	/*
	 * This method will check cost element existing in budget
	 */

	@Override
	public String hasCostElement(DevelopmentProposal developmentProposal) {
		Budget budget = developmentProposal.getFinalBudget();
		if (budget.getTotalCost().isGreaterThan(ScaleTwoDecimal.ZERO)) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method checks if the proposal has an Other Organization that is not
	 * MIT. see fn_nonMIT_org_rule.
	 * 
	 * @param developmentProposal
	 * @return 'true' if there is an Other org other than MIT
	 */
	@Override
	public String checkNonMITOrg(DevelopmentProposal developmentProposal) {
		String orgId = developmentProposal.getOwnedByUnit().getOrganizationId();
		String orgParamId = getParameterService().getParameterValueAsString(
				ProposalDevelopmentDocument.class, "DEFAULT_ORGANIZATION_ID",
				"000001");
		if (orgId != orgParamId) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method checks if proposal performing and other organization for a
	 * specific question . see FN_ORG_YNQ_RULE.
	 * 
	 * @param developmentProposal
	 * @param questionId
	 * @return true if there is question with answer
	 */
	@Override
	public String checkOrgYNQRule(DevelopmentProposal developmentProposal,
			String questionId) {
		Integer locTypeCode = developmentProposal.getPerformingOrganization()
				.getLocationTypeCode();
		if (locTypeCode == 2 || locTypeCode == 3) {
			List<OrganizationYnq> orgYnqs = developmentProposal
					.getPerformingOrganization().getOrganization()
					.getOrganizationYnqs();
			for (OrganizationYnq orgYnq : orgYnqs) {
				if (orgYnq.getQuestionId().equals(questionId)
						&& orgYnq.getAnswer().equalsIgnoreCase("Y")) {
					return TRUE;
				}
			}
		}
		return FALSE;
	}

	/**
	 * This method checks if a proposal has SUBCONTRACT CHECKED. see
	 * FN_CHECK_SUBCONTRACT_RULE.
	 * 
	 * @param developmentProposal
	 * @return if proposal has subcontract box checked
	 */
	@Override
	public String checkSubContractRule(DevelopmentProposal developmentProposal) {
		Boolean subContract = developmentProposal.getSubcontracts();
		if (subContract) {
			return TRUE;
		}
		return FALSE;
	}

	/**
	 * This method checks if check if total cost of any period of a budget is >
	 * $2mil see FN_BUD_PERIOD_AMT_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if total cost of any period of a budget is > $2mil
	 */
	@Override
	public String budgetPeriodAmountRule(DevelopmentProposal developmentProposal) {
		ScaleTwoDecimal totalCost = new ScaleTwoDecimal(2000000);
		Budget finalBudget = developmentProposal.getFinalBudget();
		if(finalBudget != null) {
			for (BudgetPeriod budgetPeriod : finalBudget.getBudgetPeriods()) {
				if (budgetPeriod.getTotalCost().isGreaterThan(totalCost)) {
					return TRUE;
				}
			}
		}
		return FALSE;
	}

	/**
	 * This method checks if the principal investigator is from outside MIT. .
	 * see FN_NON_MIT_PI.
	 * 
	 * @param developmentProposal
	 * @return 'true' if proposal has PI from outside MIT
	 */
	@Override
	public String checkNonMitPi(DevelopmentProposal developmentProposal) {
		String propFlag = "";
		List<ProposalPerson> propInvs = developmentProposal.getProposalPersons();
		for (ProposalPerson propInv : propInvs) {
			propFlag = propInv.getProposalPersonRoleId();
			if (propFlag.equals("PI") && propInv.getRolodexId() != null) {
				return TRUE;
			}
		}
		return FALSE;
	}

	/**
	 * This method checks if the proposal has a Performance Site that is not
	 * MIT. . see fn_nonMIT_site_rule.
	 * 
	 * @param developmentProposal
	 * @return 'true' if none of the perf sites is MIT
	 */
	@Override
	public String checkNonMitPerfomanceSite(
			DevelopmentProposal developmentProposal) {
		for (ProposalSite propSites : developmentProposal.getPerformanceSites()) {
			if (propSites.getLocationTypeCode() != 4) {
				return FALSE;
			}
			if (propSites.getLocationTypeCode() == 4) {
				if (propSites.getRolodex() != null
						&& propSites
								.getRolodex()
								.getOrganization()
								.equals("Massachusetts Institute of Technology")) {
					return FALSE;
				}

			}
		}
		return TRUE;
	}

	/**
	 * This method checks if PRINCIPAL INVESTIGATOR IS A SPECIFIED PERSON. . see
	 * FN_PI_IS_SPECIFIED_PERSON.
	 * 
	 * @param developmentProposal
	 * @param personId
	 * @return 'true' if PI is the person
	 */
	@Override
	public String checkPiSameAsSpecifiedPerson(
			DevelopmentProposal developmentProposal, String personId) {
		for (ProposalPerson proPer : developmentProposal.getProposalPersons()) {
			if (proPer.getProposalPersonRoleId().equals(
					Constants.PRINCIPAL_INVESTIGATOR_ROLE)
					&& proPer.getPersonId().equals(personId)) {
				return TRUE;
			}
		}
		return FALSE;
	}

	/**
	 * This method checks if a cost element total cost is greater than a certain
	 * amount see FN_COST_ELEMENT_LIMIT.
	 * 
	 * @param developmentProposal
	 * @param costElement
	 * @param amount
	 * @return 'true' if cost element total cost is greater than a certain
	 *         amount
	 */
	@Override
	public String budgetCostElementLimitRule(
			DevelopmentProposal developmentProposal, String costElement,
			String amount) {
		ScaleTwoDecimal totalAmount = new ScaleTwoDecimal(amount);
		ScaleTwoDecimal totalLineItemCost = ScaleTwoDecimal.ZERO;
		Budget finalBudget = developmentProposal.getFinalBudget();
		for (BudgetPeriod budgetPeriod : finalBudget.getBudgetPeriods()) {
			for (BudgetLineItem budgetLineItem : budgetPeriod.getBudgetLineItems()) {
				if (budgetLineItem.getCostElement().equals(costElement)) {
					totalLineItemCost = totalLineItemCost.add(budgetLineItem.getLineItemCost());
				}
				if (totalLineItemCost.isGreaterThan(totalAmount)) {
					return TRUE;
				}
			}
		}
		return FALSE;
	}

	/**
	 * This method checks if a cost element total cost is greater than a certain
	 * amount for any period see FN_COST_ELEMENT_PER_LIMIT.
	 * 
	 * @param developmentProposal
	 * @param costElement
	 * @param amount
	 * @return 'true' if cost element total cost is greater than a certain
	 *         amount for any period
	 */
	@Override
	public String budgetCostElementLimitForAnyPeriodRule(
			DevelopmentProposal developmentProposal, String costElement,
			String amount) {
		ScaleTwoDecimal totalAmount = new ScaleTwoDecimal(amount);
		Budget budget = developmentProposal.getFinalBudget();
		for (BudgetPeriod budgetPeriod : budget.getBudgetPeriods()) {
			ScaleTwoDecimal totalLineItemCost = ScaleTwoDecimal.ZERO;
			for (BudgetLineItem budgetLineItem : budgetPeriod.getBudgetLineItems()) {
				if (budgetLineItem.getCostElement().equals(costElement)) {
					totalLineItemCost = totalLineItemCost.add(budgetLineItem.getLineItemCost());
				}
			}
			if (totalLineItemCost.isGreaterThan(totalAmount)) {
				return TRUE;
			}
		}
		return FALSE;
	}

	/**
	 * This method checks all multi-pis must have an ERA commons name see
	 * FN_S2S_ERA_COMMONS_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if all multi-pis have an ERA commons name
	 */
	@Override
	public String s2sEraCommonUserNameRule(
			DevelopmentProposal developmentProposal) {

		List<ProposalPerson> proposalPersons = developmentProposal
				.getProposalPersons();
		for (ProposalPerson proposalPerson : proposalPersons) {

			if (proposalPerson.isMultiplePi()
					|| proposalPerson.getProposalPersonRoleId().equals(
							(Constants.PRINCIPAL_INVESTIGATOR_ROLE))) {
				if (proposalPerson.getEraCommonsUserName() == null) {
					return FALSE;
				}
			}
		}
		return TRUE;
	}

	/**
	 * This method checks if the sponsor or prime sponsor for a proposal is in
	 * the coi dislosures sponsors hierarchy see fn_coi_disclosures_rule.
	 * 
	 * @param developmentProposal
	 * @return 'true' if sponsor or prime sponsor for a proposal is in the coi
	 *         dislosures sponsors hierarchy
	 */
	@Override
	public String coiDisclosureRule(DevelopmentProposal developmentProposal) {
		if (isSponsorInHierarchy(developmentProposal.getSponsorCode())) {
			return TRUE;
		}
		if (isSponsorInHierarchy(developmentProposal.getPrimeSponsorCode())) {
			return TRUE;
		}
		return FALSE;
	}

	private boolean isSponsorInHierarchy(String sponsorcode) {
		try {
			Map<String, String> valueMap = new HashMap<String, String>();

			valueMap.put("sponsorCode", sponsorcode);
			valueMap.put("hierarchyName", "COI Disclosures");
			int matchingHierarchies = KcServiceLocator.getService(
					BusinessObjectService.class).countMatching(
					SponsorHierarchy.class, valueMap);

			if (matchingHierarchies > 0) {
				return true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * This method checks if PIs and Co-Is have completed the appropriate
	 * questionnaire see FN_check_coi_qu_answered_rule
	 * 
	 * @param developmentProposal
	 * @return 'true' if PIs and Co-Is have completed the appropriate
	 *         questionnaire
	 */
	@Override
	public String coiAndPIQuestionAnsweredRule(
			DevelopmentProposal developmentProposal) {
		try {
			for (ProposalPerson person : developmentProposal
					.getProposalPersons()) {
				if (person.getProposalPersonRoleId().equals(
						Constants.PRINCIPAL_INVESTIGATOR_ROLE)
						|| person.getProposalPersonRoleId().equals(
								Constants.CO_INVESTIGATOR_ROLE)) {
					ProposalPersonModuleQuestionnaireBean moduleQuestionnaireBean = new ProposalPersonModuleQuestionnaireBean(developmentProposal,person);
					List<AnswerHeader> answerHeaders = KcServiceLocator.getService(QuestionnaireAnswerService.class)
																.getQuestionnaireAnswer(moduleQuestionnaireBean);
					AnswerHeader mostCurrentHeader = answerHeaders.get(0);
					for (AnswerHeader header : answerHeaders) {
						if (KcServiceLocator.getService(
								QuestionnaireService.class)
								.isCurrentQuestionnaire(
										header.getQuestionnaire())
								&& header
										.getQuestionnaire()
										.hasUsageFor(
												CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE,
												getSubModuleItemCode(person
														.getProposalPersonRoleId()))) {
							mostCurrentHeader = header;
						}
					}
					if (!mostCurrentHeader.isCompleted()) {
						return FALSE;
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return TRUE;
	}

	private static String getSubModuleItemCode(String roleId) {

		if (roleId.equals(Constants.PRINCIPAL_INVESTIGATOR_ROLE)) {

			return KcMitConstants.PROPOSAL_PERSON_PI_CERTIFICATION;

		} else if (roleId.equals(Constants.CO_INVESTIGATOR_ROLE)) {

			return KcMitConstants.PROPOSAL_PERSON_COI_CERTIFICATION;

		} else if (roleId.equals(Constants.KEY_PERSON_ROLE)) {
			return KcMitConstants.PROPOSAL_PERSON_KP_CERTIFICATION;
		}
		return null;
	}

	/**
	 * This method checks if a proposal certification has a Yes answer for a
	 * specified question see FN_check_prop_cert_answer_rule
	 * 
	 * @param developmentProposal
	 * @param questionnaireId
	 * @param questionId
	 * @return 'true' if a proposal certification has a Yes answer for a
	 *         specified question
	 */
	@Override
	public String proposalCertificationAnswerRule(
			DevelopmentProposal developmentProposal, String questionnaireId,
			String questionId) {
		for (ProposalPerson person : developmentProposal.getProposalPersons()) {
			ProposalPersonModuleQuestionnaireBean moduleQuestionnaireBean = new ProposalPersonModuleQuestionnaireBean(
					developmentProposal, person);
			List<AnswerHeader> answerHeaders = KcServiceLocator.getService(
					QuestionnaireAnswerService.class).getQuestionnaireAnswer(
					moduleQuestionnaireBean);
			if(answerHeaders!=null && !answerHeaders.isEmpty()){
				AnswerHeader mostCurrentHeader = answerHeaders.get(0);
				for (AnswerHeader header : answerHeaders) {
					if (KcServiceLocator.getService(QuestionnaireService.class)
							.isCurrentQuestionnaire(header.getQuestionnaire())
							&& header.getQuestionnaire().hasUsageFor(
									CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE,
									getSubModuleItemCode(person
											.getProposalPersonRoleId()))) {
						mostCurrentHeader = header;
					}
				}
				if (mostCurrentHeader.getQuestionnaire().getQuestionnaireSeqId()
						.equals(questionnaireId)) {
	
					List<Answer> answers = mostCurrentHeader.getAnswers();
					for (Answer answer : answers) {
	
						if (answer.getQuestion().getQuestionSeqId().toString().equals(questionId)) {
							if (questionId.equals("1001")
									|| questionId.equals("1013")
									|| questionId.equals("1016")) {
								if (answer.getAnswer()!=null && answer.getAnswer().equals("N")) {
									return FALSE;
								}
							}
							if (answer.getAnswer()!=null && answer.getAnswer().equals("Y")) {
								return TRUE;
							}
						}
					}
				}
			}
		}
		return FALSE;
	}

	/**
	 * check proposal certification answers for investigators against proposal
	 * special review answers for international questions see
	 * FN_check_coi_qu_answered_rule
	 * 
	 * @param developmentProposal
	 * @return 'true' if proposal certification answers for investigators
	 *         against proposal special review answers for international
	 *         questions
	 */
	@Override
	public String specialReviewAnsewersForInternationalQuestionRule(
			DevelopmentProposal developmentProposal) {
		for (ProposalSpecialReview proposalSpecialReview : developmentProposal
				.getPropSpecialReviews()) {
			if (proposalSpecialReview.getSpecialReviewTypeCode().equals("6")) {
				for (ProposalPerson person : developmentProposal
						.getProposalPersons()) {
					if (person.getProposalPersonRoleId().equals(
							Constants.PRINCIPAL_INVESTIGATOR_ROLE)
							|| person.getProposalPersonRoleId().equals(
									Constants.CO_INVESTIGATOR_ROLE)) {
						ProposalPersonModuleQuestionnaireBean moduleQuestionnaireBean = new ProposalPersonModuleQuestionnaireBean(
								developmentProposal, person);
						List<AnswerHeader> answerHeaders = KcServiceLocator
								.getService(QuestionnaireAnswerService.class)
								.getQuestionnaireAnswer(moduleQuestionnaireBean);
						AnswerHeader mostCurrentHeader = answerHeaders.get(0);
						for (AnswerHeader header : answerHeaders) {
							if (KcServiceLocator.getService(
									QuestionnaireService.class)
									.isCurrentQuestionnaire(
											header.getQuestionnaire())
									&& header
											.getQuestionnaire()
											.hasUsageFor(
													CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE,
													getSubModuleItemCode(person
															.getProposalPersonRoleId()))) {
								mostCurrentHeader = header;
							}
						}
						if (mostCurrentHeader.getQuestionnaire()
								.getQuestionnaireSeqId().equals("501")) {

							List<Answer> answers = mostCurrentHeader
									.getAnswers();
							for (Answer answer : answers) {

								if (answer.getQuestion().getQuestionSeqId()
										.equals("1009")) {
									if (answer.getAnswer() != null
											&& answer.getAnswer().equals("Y")) {
										return TRUE;
									}
								}
							}
						}
						if (mostCurrentHeader.getQuestionnaire()
								.getQuestionnaireSeqId().equals("503")) {

							List<Answer> answers = mostCurrentHeader
									.getAnswers();
							for (Answer answer : answers) {

								if (answer.getQuestion().getQuestionSeqId()
										.equals("1009")) {
									if (answer.getAnswer() != null
											&& answer.getAnswer().equals("Y")) {
										return TRUE;
									}
								}
							}
						}
					}
				}
			}
		}
		return FALSE;
	}

	/**
	 * * This method checks if a proposal has an Exempt human subjects special
	 * review with exemption E4. see FN_EXEMPT_E4_RULE.
	 * 
	 * @param developmentProposal
	 * @return 'true' if proposal has an Exempt human subjects special review
	 *         with exemption E4.
	 */
	@Override
	public String hasExemptHumanSubjSplReview(
			DevelopmentProposal developmentProposal) {

		List<ProposalSpecialReview> proposalSpclReview = developmentProposal
				.getPropSpecialReviews();
		int exemptTypeCode = 0;
		for (ProposalSpecialReview spclReview : proposalSpclReview) {
			List<ProposalSpecialReviewExemption> spclRevExemptions = spclReview
					.getSpecialReviewExemptions();
			for (ProposalSpecialReviewExemption proposalSpecialReviewExemption : spclRevExemptions) {
				exemptTypeCode = Integer
						.parseInt(proposalSpecialReviewExemption
								.getExemptionTypeCode());
			}
			if ((Integer.parseInt(spclReview.getSpecialReviewTypeCode()) == 1)
					&& exemptTypeCode == 4)
				if (spclReview.getComments() != null) {
					return TRUE;
				}
		}
		return FALSE;

	}

	/**
	 * This method checks if agency routing identifier is null see
	 * FN_AGENCY_ROUTINGID_IS_NULL
	 * 
	 * @param developmentProposal
	 * @return true if agency routing identifier is null
	 */
	public String checkForNullAgencyRoutingIdentifier(
			DevelopmentProposal developmentProposal) {

		if ((developmentProposal.getAgencyRoutingIdentifier() == null)
				|| (developmentProposal.getAgencyRoutingIdentifier().isEmpty())
				|| (developmentProposal.getAgencyRoutingIdentifier().length() == 0))
			return TRUE;
		else
			return FALSE;
	}

	/**
	 * This method checks if previous grants.gov tracking ID is null see
	 * FN_PREV_GG_TRACKID_IS_NULL
	 * 
	 * @param developmentProposal
	 * @return TRUE if tracking ID is null
	 */
	public String checkForNullPrevGGTrackId(
			DevelopmentProposal developmentProposal) {
		if ((developmentProposal.getPrevGrantsGovTrackingID() == null)
				|| (developmentProposal.getPrevGrantsGovTrackingID().isEmpty())
				|| (developmentProposal.getPrevGrantsGovTrackingID().length() == 0))
			return TRUE;
		else
			return FALSE;
	}

	/***
	 * This method checks if all senior key persons have biosketch see
	 * FN_S2S_SKPERSON_BIOSKETCH_RULE
	 * 
	 * @param developmentProposal
	 * @return TRUE if persons has biosketch
	 */
	public String S2SSeniorKeyPersonBiosketch(
			DevelopmentProposal developmentProposal) {
		int s2sFormCount = 0;
		int proposalPersonCount = 0;
		int personBiographiesCount = 0;

		List<S2sOppForms> s2sList = developmentProposal.getS2sOppForms();
		for (S2sOppForms oppForms : s2sList) {
			if ((oppForms.getProposalNumber()
					.equalsIgnoreCase(developmentProposal.getProposalNumber()))
					&& (oppForms.getFormName()
							.equalsIgnoreCase("RR_KeyPersonExpanded_2_0"))
					&& (oppForms.getInclude())) {
				s2sFormCount++;
			}

		}

		List<ProposalPerson> proposalPersonList = developmentProposal
				.getProposalPersons();
		for (ProposalPerson proposalPerson : proposalPersonList) {
			if (proposalPerson.getProposalNumber().equalsIgnoreCase(
					developmentProposal.getProposalNumber())) {
				proposalPersonCount++;
			}
		}

		List<ProposalPersonBiography> biographies = developmentProposal
				.getPropPersonBios();
		for (ProposalPersonBiography personBiography : biographies) {
			if (Integer.parseInt(personBiography.getDocumentTypeCode()) == 1
					&& personBiography.getProposalNumber().equalsIgnoreCase(
							developmentProposal.getProposalNumber())) {
				personBiographiesCount++;
			}
		}

		if (s2sFormCount > 0) {
			if (proposalPersonCount == personBiographiesCount) {
				return TRUE;
			}

			else {
				return FALSE;
			}

		}
		return FALSE;

	}

	/**
	 * check proposal certification answers for investigators against proposal
	 * special review answers see fn_prop_cert_vs_sp_rev_rule
	 * 
	 * @param developmentProposal
	 * @return 'true' if proposal certification answers for investigators
	 *         against proposal special review answers are Yes
	 */
	@Override
	public String checkPropCertAnswersAndSpecialReviews(
			DevelopmentProposal developmentProposal) {
		for (ProposalSpecialReview proposalSpecialReview : developmentProposal
				.getPropSpecialReviews()) {
			if (proposalSpecialReview.getSpecialReviewTypeCode().equals("1")) {
				for (ProposalPerson person : developmentProposal
						.getProposalPersons()) {
					if (person.getProposalPersonRoleId().equals(
							Constants.PRINCIPAL_INVESTIGATOR_ROLE)
							|| person.getProposalPersonRoleId().equals(
									Constants.CO_INVESTIGATOR_ROLE)) {
						ProposalPersonModuleQuestionnaireBean moduleQuestionnaireBean = new ProposalPersonModuleQuestionnaireBean(
								developmentProposal, person);
						List<AnswerHeader> answerHeaders = KcServiceLocator
								.getService(QuestionnaireAnswerService.class)
								.getQuestionnaireAnswer(moduleQuestionnaireBean);
						AnswerHeader mostCurrentHeader = answerHeaders.get(0);
						for (AnswerHeader header : answerHeaders) {
							if (KcServiceLocator.getService(
									QuestionnaireService.class)
									.isCurrentQuestionnaire(
											header.getQuestionnaire())
									&& header
											.getQuestionnaire()
											.hasUsageFor(
													CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE,
													getSubModuleItemCode(person
															.getProposalPersonRoleId()))) {
								mostCurrentHeader = header;
							}
						}
						if (mostCurrentHeader.getQuestionnaire()
								.getQuestionnaireSeqId().equals("501")) {

							List<Answer> answers = mostCurrentHeader
									.getAnswers();
							for (Answer answer : answers) {

								if (answer.getQuestion().getQuestionSeqId()
										.equals("1012")) {
									if (answer.getAnswer().equals("Y")) {
										return TRUE;
									}
								}
							}
						}
						if (mostCurrentHeader.getQuestionnaire()
								.getQuestionnaireSeqId().equals("503")) {

							List<Answer> answers = mostCurrentHeader
									.getAnswers();
							for (Answer answer : answers) {

								if (answer.getQuestion().getQuestionSeqId()
										.equals("1012")) {
									if (answer.getAnswer().equals("Y")) {
										return TRUE;
									}
								}
							}
						}
					}
				}

			}
			if (proposalSpecialReview.getSpecialReviewTypeCode().equals("2")) {
				for (ProposalPerson person : developmentProposal
						.getProposalPersons()) {
					if (person.getProposalPersonRoleId().equals(
							Constants.PRINCIPAL_INVESTIGATOR_ROLE)
							|| person.getProposalPersonRoleId().equals(
									Constants.CO_INVESTIGATOR_ROLE)) {
						ProposalPersonModuleQuestionnaireBean moduleQuestionnaireBean = new ProposalPersonModuleQuestionnaireBean(
								developmentProposal, person);
						List<AnswerHeader> answerHeaders = KcServiceLocator
								.getService(QuestionnaireAnswerService.class)
								.getQuestionnaireAnswer(moduleQuestionnaireBean);
						AnswerHeader mostCurrentHeader = answerHeaders.get(0);
						for (AnswerHeader header : answerHeaders) {
							if (KcServiceLocator.getService(
									QuestionnaireService.class)
									.isCurrentQuestionnaire(
											header.getQuestionnaire())
									&& header
											.getQuestionnaire()
											.hasUsageFor(
													CoeusModule.PROPOSAL_DEVELOPMENT_MODULE_CODE,
													getSubModuleItemCode(person
															.getProposalPersonRoleId()))) {
								mostCurrentHeader = header;
							}
						}
						if (mostCurrentHeader.getQuestionnaire()
								.getQuestionnaireSeqId().equals("501")) {

							List<Answer> answers = mostCurrentHeader
									.getAnswers();
							for (Answer answer : answers) {

								if (answer.getQuestion().getQuestionSeqId()
										.equals("1011")) {
									if (answer.getAnswer().equals("Y")) {
										return TRUE;
									}
								}
							}
						}
						if (mostCurrentHeader.getQuestionnaire()
								.getQuestionnaireSeqId().equals("503")) {

							List<Answer> answers = mostCurrentHeader
									.getAnswers();
							for (Answer answer : answers) {

								if (answer.getQuestion().getQuestionSeqId()
										.equals("1011")) {
									if (answer.getAnswer().equals("Y")) {
										return TRUE;
									}
								}
							}
						}
					}
				}
			}
		}
		return FALSE;
	}

	/**
	 * Check Other Agencies flag deviates from proposal question concerning
	 * other agencies proposal special review answers see
	 * FN_OTHER_AGENCY_DEVIATION
	 * 
	 * @param developmentProposal
	 * @return 'true' if if deviation
	 * 
	 */
	@Override
	public String otherAgencyDeviation(DevelopmentProposal developmentProposal) {
		for (ProposalYnq proYnq : developmentProposal.getProposalYnqs()) {
			if (proYnq.getQuestionId().equals("15")
					&& proYnq.getAnswer().equals("N")) {
				return FALSE;
			}
		}
		return TRUE;
	}

	/***
	 * This method checks total cost for a cost element in any period of a
	 * version see FN_COST_ELEMENT_VER_PER_LIMIT.
	 * 
	 * @param developmentProposal
	 * @return true if crossed the limit
	 */
	@Override
	public String getCostElemPeriodLimitInVer(
			DevelopmentProposal developmentProposal, Long budgetVersion,
			String costElement, String costAmountLimit) {
		ScaleTwoDecimal totalAmount = new ScaleTwoDecimal(costAmountLimit);
		Budget budget = developmentProposal.getFinalBudget();
		for (BudgetPeriod budgetPeriod : budget.getBudgetPeriods()) {
			ScaleTwoDecimal totalLineItemCost = ScaleTwoDecimal.ZERO;
			for (BudgetLineItem budgetLineItem : budgetPeriod.getBudgetLineItems()) {
				if (budgetLineItem.getCostElement().equals(costElement)) {
					totalLineItemCost = totalLineItemCost
							.add(budgetLineItem.getLineItemCost());
				}
			}
			if (totalLineItemCost.isGreaterThan(totalAmount)) {
				return TRUE;
			}
		}
		return FALSE;
	}

	/***
	 * to validate keyPerson certification see FN_VALIDATE_PROP_KP_CERTIFY.
	 * 
	 * @param developmentProposal
	 * @return 'true' if keyperson is certified
	 */
	public String isKeyPersonCertifyValid(
			DevelopmentProposal developmentProposal) {
		if (isKeyPersonRequiredForProposal(developmentProposal)) {
			if (coiDisclosureRule(developmentProposal).equalsIgnoreCase(TRUE)) {
				if (!isKeyPersonCertificationRequired(developmentProposal)) {
					if (coiAndPIQuestionAnsweredRule(developmentProposal)
							.equalsIgnoreCase(TRUE)) {
						return TRUE;
					}
				} else {
					return TRUE;
				}
			}
		} else {
			return TRUE;
		}
		return FALSE;

	}

	/**
	 * Checks based on the special conditions if certification required for the
	 * key person
	 * 
	 * @param developmentProposal
	 * @return
	 */
	private boolean isKeyPersonCertificationRequired(
			DevelopmentProposal developmentProposal) {
		boolean isCertifyRequired = false;
		int li_kp_count = 0;
		try {
			List<ProposalPerson> proposalPersons = developmentProposal
					.getProposalPersons();
			double percentageEffort = 0;
			for (ProposalPerson proposalPerson : proposalPersons) {
				if (proposalPerson.getPercentageEffort() != null) {
					percentageEffort = proposalPerson.getPercentageEffort()
							.doubleValue();
				}
				if (proposalPerson.getProjectRole().equalsIgnoreCase(
						"Other Significant Contributor")
						|| proposalPerson.getProjectRole().equalsIgnoreCase(
								"Subaward Investigator")
						|| proposalPerson.getProjectRole().equalsIgnoreCase(
								"Consultant")
						|| percentageEffort == 999.99
						|| 999.99 == 999) {
					li_kp_count++;
				}

			}
			if (li_kp_count <= 0) {
				isCertifyRequired = true;
			} else {
				isCertifyRequired = false;
			}

		} catch (Exception e) {
		}
		return isCertifyRequired;
	}

	/**
	 * this method will return true if key person entry is required for this
	 * proposal,based on the custom attrubute doc value.
	 * 
	 * @param developmentProposal
	 * @return
	 */
	private boolean isKeyPersonRequiredForProposal(
			DevelopmentProposal developmentProposal) {
		try {
			List<CustomAttributeDocValue> customDataList = developmentProposal
					.getProposalDocument().getCustomDataList();
			for (CustomAttributeDocValue attributeDocValue : customDataList) {
				if (attributeDocValue.getValue().equalsIgnoreCase("PCK")) {
					return true;
				}
			}
		} catch (Exception exception) {

		}
		return false;
	}
	 /**	 
     * MITKC-200
     * This method is to check if ALL CO-PIS HAVE PI STATUS
     * fn_co_i_appoint_type_rule 
     */
    public String coiAppointmentTypeRule(DevelopmentProposal developmentProposal) {
        List<ProposalPerson> people = developmentProposal.getProposalPersons();
        List<AppointmentType> appointmentTypes = (List<AppointmentType>)getBusinessObjectService().findAll(AppointmentType.class);
        for (ProposalPerson person : people) {
        	
        	 if (person.isCoInvestigator() //&& person.isInvestigator()
             		&& person.getPerson() != null && person.getPerson().getExtendedAttributes() != null) {
                List<PersonAppointment> appointments = person.getPerson().getExtendedAttributes().getPersonAppointments();
                for(PersonAppointment personAppointment : appointments) {
                    if(isAppointmentTypeEqualsJobTitle(appointmentTypes, personAppointment.getJobTitle())) {
                        return TRUE;
                    }
                }
            }
        }
        return FALSE;
    }
    private boolean isAppointmentTypeEqualsJobTitle(List<AppointmentType> appointmentTypes, String jobTitle) {
        for(AppointmentType appointmentType : appointmentTypes) {
            if(appointmentType.getDescription().equalsIgnoreCase(jobTitle)) {
                return true;
            }
        }
        return false;
    }
   /**MITKC-820
    * Create New Function "ORIGINAL INSTITUTIONAL PROPOSAL ID IS VALID"
    *  where if an IP # s entered in the field it's valid if the IP status is "Pending". 
    *  If the IP is any status other than "Pending", 
    *  we will write the validation as an error with a message to the user to contact the Data Team to update the Original IP status. 
    */
    public boolean isOriginalIPIsValid(DevelopmentProposal developmentProposal){
    	 String proposalNumber = null;
    	 String status = "Active";
    	// String iPNumber = developmentProposal.getProposalDocument().getInstitutionalProposalNumber();
    	List<? extends ProposalAdminDetailsContract> adminDetails = KcServiceLocator.getService(ProposalAdminDetailsService.class).findProposalAdminDetailsByPropDevNumber(developmentProposal.getProposalNumber());
		for (ProposalAdminDetailsContract propAdminDetails : adminDetails) {
			proposalNumber = propAdminDetails.getInstProposalId().toString();
		}
		if(proposalNumber!=null){
		  Map<String, String> proposalKeys = new HashMap<String, String>();
	        proposalKeys.put("proposalNumber", proposalNumber);
	        List<InstitutionalProposal> instList = getDataObjectService().findMatching(InstitutionalProposal.class,QueryByCriteria.Builder.andAttributes(proposalKeys).build()).getResults();
	    if(instList != null && instList.size() > 0){
	    	for (InstitutionalProposal institutionalProposal : instList) {
	    		status = institutionalProposal.getProposalSequenceStatus();
	    	}
	    	
	    }
		}
		if(status.equalsIgnoreCase("PENDING")){
			return true;
		}else{
			return false;
		}
    }
    @Autowired
    @Qualifier("dataObjectService")
    private DataObjectService dataObjectService;

    public DataObjectService getDataObjectService() {
        return dataObjectService;
    }

    public void setDataObjectService(DataObjectService dataObjectService) {
        this.dataObjectService = dataObjectService;
    }
    /**MITKC-819
     * Create New Function "PREVIOUS GRANTS.GOV TRACKING ID IS MISSING"
     * if the function is equal to true it means the field in the KC Dev Proposal is blank.
     */
     public boolean confirmTrackingIDBlank(DevelopmentProposal developmentProposal){//ref checkForNullPrevGGTrackId//DML_MITKC-284_20140702.sql
    	 
    	  Long proposalId = null;
          if (StringUtils.isNotEmpty(developmentProposal.getContinuedFrom())) {
             proposalId = getSubmissionInfoService().getProposalContinuedFromVersionProposalId(developmentProposal.getContinuedFrom());
          }
    	  String ggTrackingId = null;
    	             if (proposalId != null) {
    	                 ggTrackingId = getSubmissionInfoService().getGgTrackingIdFromProposal(proposalId);
    	             }
  
    	             if(ggTrackingId.isEmpty() && ggTrackingId.equalsIgnoreCase("")){
    	              	return true;
    	              	}
 		return false;
     }
     
     private SubmissionInfoService submissionInfoService;
     protected SubmissionInfoService getSubmissionInfoService() {
         if (this.submissionInfoService == null) {
             this.submissionInfoService = KcServiceLocator.getService(SubmissionInfoService.class);
         }
         return this.submissionInfoService;
     }

     public void setSubmissionInfoService(SubmissionInfoService submissionInfoService) {
         this.submissionInfoService = submissionInfoService;
     }

	@Override
	public String hasMultiPiRequiredCertification(
			DevelopmentProposal developmentProposal) {
		for(ProposalPerson proposalPerson : developmentProposal.getProposalPersons()){
			if(proposalPerson.getPerson()!=null && proposalPerson.getProposalPersonRoleId().equals(Constants.MULTI_PI_ROLE) && proposalPerson.getCertifiedBy()==null)  {
				return TRUE;
	           }
		}
		return FALSE;
	}
	
	@Override
	public String hasReachedOspInRouting(
			DevelopmentProposal developmentProposal) {
		List<WLCurrentLoad> wLCurrentLoadList = getDataObjectService().findMatching(WLCurrentLoad.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("proposalNumber", developmentProposal.getProposalNumber())		 
				 )).getResults();
		if(wLCurrentLoadList!=null && !wLCurrentLoadList.isEmpty()){
			return TRUE;
		}
		return FALSE;
	}
	
	/**
     * This method is to check if the PI or any multi-PI has PI status
     * FN_PI_APPOINTMENT_TYPE_RULE
     */
   public String piAppointmentTypeRule(DevelopmentProposal developmentProposal) {
        List<ProposalPerson> people = developmentProposal.getProposalPersons();
        List<PiAppointmentType> piAppointmentTypes = (List<PiAppointmentType>)getBusinessObjectService().findAll(PiAppointmentType.class);
        for (ProposalPerson person : people) {
            if ((person.isInvestigator() && person.isPrincipalInvestigator()) || (person.isMultiplePi())
            		&& person.getPerson() != null && person.getPerson().getExtendedAttributes() != null) {
                List<PersonAppointment> appointments = person.getPerson().getExtendedAttributes().getPersonAppointments();
                for(PersonAppointment personAppointment : appointments) {
                    if(isPiAppointmentTypeEqualsJobTitle(piAppointmentTypes, personAppointment.getJobTitle())) {
                        return TRUE;
                    }
                }
            }
        }
        return FALSE;
    }
	
	   private boolean isPiAppointmentTypeEqualsJobTitle(List<PiAppointmentType> piAppointmentTypes, String jobTitle) {
	        for(PiAppointmentType piAppointmentType : piAppointmentTypes) {
	            if(piAppointmentType.getDescription().equalsIgnoreCase(jobTitle)) {
	                return true;
	            }
	        }
	        return false;
	    }

	   

	
}