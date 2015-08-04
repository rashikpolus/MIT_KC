/**
 * 
 */
package edu.mit.kc.propdev.krms;

import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;


/**
 * @author kc-mit-dev
 *  This interface is for defining all MIT custom KRMS functions
 */
public interface MitPropDevJavaFunctionKrmsTermService {
	
	/**
	 * KRMS Java function for NOTICE OF OPPORTUNITY IS MISSING
	 * * see FN_NO_NOTICE_OF_OPP_RULE.
	 * @param developmentProposal
	 * @return 'true' if proposal is missing a NOTICE OF OPPORTUNITY
	 */
	public boolean hasNoticeOfOpportunity(DevelopmentProposal developmenProposal);
	/**
	 * This method checks if a proposal has NSF CODE.
	 * see FN_NO_NSF_CODE_RULE.
	 * @param developmentProposal
	 * @return 'true' if there is no NSF CODE
	 */
	public String checkNsfCode(DevelopmentProposal developmentProposal);
	/**
	 * This method checks if a proposal has SPONSOR CODE.
	 * see FN_NO_SPONSOR_RULE.
	 * @param developmentProposal
	 * @return 'true' if proposal is missing a SPONSOR code
	 */
	public String checkSponsorCode(DevelopmentProposal developmentProposal);
	/**
	 * This method checks if a proposal has prime Sponsor Code.
	 * see FN_PRIME_SPONSOR_RULE.
	 * @param developmentProposal
	 * @return 'true' if there is prime Sponsor Code
	 */	
	public String checkPrimeSponsorCode(DevelopmentProposal developmentProposal);
	/**
	 * This method check if a proposal has a funding opportunity .
	 * see FN_NO_FUNDING_OPP_RULE.
	 * @param developmentProposal
	 * @return 'true' if proposal is missing a funding opp (PROGRAM ANNOUNCEMENT NUMBER)
	 */
	public String checkFundingOpportunity(DevelopmentProposal developmentProposal);
	/**
	 * This method check if a proposal has A DEADLINE DATE  .
	 * see FN_NO_DEADLINE_DATE_RULE.
	 * @param developmentProposal
	 * @return 'true' if proposal is missing a DEADLINE DATE
	 */	
	public String checkDeadlineDate(DevelopmentProposal developmentProposal);
	/**
	 * This method Checks if a proposal's notice of opportunity type is  a specified one.
	 * see FN_NOTICE_OF_OPP_TYPE_RULE.
	 * @param developmentProposal
	 *  @param noticeOfOpportunityCode
	 * @return 'true' if both are same. 
	 */	
	public String checkNopCodeRule(DevelopmentProposal developmentProposal,String noticeOfOpportunityCode);
	/**
	 * This method Checks if a proposal's grants.gov submission type is  a specified one.
	 * see fn_s2s_sub_type_rule.
	 * @param developmentProposal
	 *  @param s2sSubmissionTypeCOde
	 * @return 'true' if both are same. 
	 */	 
	public String checkS2SSubTypeRule(DevelopmentProposal developmentProposal,String s2sSubTypeCode);
	/**
	 * This method Checks if a proposal's prime sponsor and sponsor are same.
	 * see fn_prime_equals_sponsor_rule.
	 * @param developmentProposal
	 * @return 'true' if sponsor and sponsor are same.
	 */	
	public String isPrimeEqualsSponsor(DevelopmentProposal developmentProposal);
	/**
	 * This method Checks if a proposal budget has cost element.
	 * see FN_NO_COST_ELEMENTS_RULE.
	 * @param developmentProposal
	 * @return 'true' if proposal budget has cost element. 
	 */	
	public String hasCostElement(DevelopmentProposal developmentProposal);
	/**
	 * This method checks if the  proposal has an Other Organization that is not MIT.
	 * see fn_nonMIT_org_rule.
	 * @param developmentProposal
	 * @return if  there is an Other org  other than MIT 
	 */
	public String checkNonMITOrg(DevelopmentProposal developmentProposal);
	/**
	 * This method checks if proposal performing and other organization for a specific question .
	 * see FN_ORG_YNQ_RULE.
	 * @param developmentProposal
	 * @param questionId
	 * @return true if there is question with answer
	 */
	public String checkOrgYNQRule(DevelopmentProposal developmentProposal,String questionId);
	/**
	 * This method checks if a proposal has SUBCONTRACT CHECKED.
	 * see FN_CHECK_SUBCONTRACT_RULE.
	 * @param developmentProposal
	 * @return 'true' if proposal has subcontract box checked
	 */
	public String checkSubContractRule(DevelopmentProposal developmentProposal);
	/**
	 * This method checks if check if total cost of any period of a budget is  > $2mil
	 * see FN_BUD_PERIOD_AMT_RULE.
	 * @param developmentProposal
	 * @return 'true' if  total cost of any period of a budget is  > $2mil 
	 */
	public String budgetPeriodAmountRule(DevelopmentProposal developmentProposal);
	/**
 * This method checks if the principal investigator is from outside MIT. .
 * see FN_NON_MIT_PI.
 * @param developmentProposal
 * @return 'true' if proposal has PI from outside MIT
 */
  public String checkNonMitPi(DevelopmentProposal developmentProposal);
	/**
* This method checks if the  proposal has a Performance Site that is not MIT. .
* see fn_nonMIT_site_rule.
* @param developmentProposal
* @return 'true' if none of the perf sites is MIT
*/
  public String checkNonMitPerfomanceSite(DevelopmentProposal developmentProposal);
	/**
* This method checks if PRINCIPAL INVESTIGATOR IS A SPECIFIED PERSON. .
* see FN_PI_IS_SPECIFIED_PERSON.
* @param developmentProposal
*  @param personId
* @return 'true' if PI is the person
*/
  public String checkPiSameAsSpecifiedPerson(DevelopmentProposal developmentProposal,String personId);
  /**
   * This method checks if a cost element total cost is greater than a certain amount
   * see FN_COST_ELEMENT_LIMIT.
   * @param developmentProposal
   * @param costElement
   * @param amount
   * @return 'true' if  cost element total cost is greater than a certain amount
   */
  public String budgetCostElementLimitRule(DevelopmentProposal developmentProposal,String costElement,String amount);
  /**
   * This method checks if a cost element total cost is greater than a certain amount for any period
   * see FN_COST_ELEMENT_PER_LIMIT.
   * @param developmentProposal
   * @param costElement
   * @param amount
   * @return 'true' if  cost element total cost is greater than a certain amount for any period
   */
  public String budgetCostElementLimitForAnyPeriodRule(DevelopmentProposal developmentProposal,String costElement,String amount);
  /**
   * This method checks all multi-pis must have an ERA commons name 
   * see FN_S2S_ERA_COMMONS_RULE.
   * @param developmentProposal
   * @return 'true' if  all multi-pis have an ERA commons name
   */
  public String s2sEraCommonUserNameRule(DevelopmentProposal developmentProposal);
  /**
   * This method checks if the sponsor or prime sponsor for a proposal is in the
-  * coi dislosures sponsors hierarchy 
   * see fn_coi_disclosures_rule.
   * @param developmentProposal
   * @return 'true' if sponsor or prime sponsor for a proposal is in the coi dislosures sponsors hierarchy
   */
  public String coiDisclosureRule(DevelopmentProposal developmentProposal);
  /**
   * This method checks if PIs and Co-Is have completed the appropriate questionnaire
   * see FN_check_coi_qu_answered_rule
   * @param developmentProposal
   * @return 'true' if PIs and Co-Is have completed the appropriate questionnaire
   */
  public String coiAndPIQuestionAnsweredRule(DevelopmentProposal developmentProposal);
  /**
   * This method checks if a proposal certification has a Yes answer for a specified question
   * see FN_check_prop_cert_answer_rule
   * @param developmentProposal
   * @param questionnaireId
   * @param questionId
   * @return 'true' if a proposal certification has a Yes answer for a specified question
   */
  public String proposalCertificationAnswerRule(DevelopmentProposal developmentProposal,String questionnaireId,String questionId);
  /**
   * check proposal certification answers for investigators against
   * proposal special review answers for international questions
   * see FN_check_coi_qu_answered_rule
   * @param developmentProposal
   * @return 'true' if proposal certification answers for investigators against
   * proposal special review answers for international questions
   */
  public String specialReviewAnsewersForInternationalQuestionRule(DevelopmentProposal developmentProposal);
  /**
	 * This method checks if a proposal has an Exempt human subjects special review with exemption E4.
	 * see FN_EXEMPT_E4_RULE.
	 * @param developmentProposal
	 * @return 'true' if proposal has an Exempt human subjects special review with exemption E4.
	 */
	public String hasExemptHumanSubjSplReview(DevelopmentProposal developmentProposal);
	/**
	 * This method checks if agency routing identifier is null
	 * see FN_AGENCY_ROUTINGID_IS_NULL
	 * @param developmentProposal
	 * @return true if agency routing identifier is null
	 */
	public String checkForNullAgencyRoutingIdentifier(DevelopmentProposal developmentProposal);
	/**
	 * This method checks  if previous grants.gov tracking ID is null 
	 * see FN_PREV_GG_TRACKID_IS_NULL
	 * @param developmentProposal
	 * @return true if tracking ID is null
	 */ 
	public String checkForNullPrevGGTrackId(DevelopmentProposal developmentProposal);
	/***
	 * This method checks if all senior key persons have biosketch 
	 * see FN_S2S_SKPERSON_BIOSKETCH_RULE
	 * @param developmentProposal
	 * @return true if persons has biosketch
	 */
	public String S2SSeniorKeyPersonBiosketch(DevelopmentProposal developmentProposal);
	/**
	 * check proposal certification answers for investigators against
	 * proposal special review answers
	 * see fn_prop_cert_vs_sp_rev_rule
	 * @param developmentProposal
	 * @return 'true' if proposal certification answers for investigators against
	 * proposal special review answers are Yes
	 */
	public String checkPropCertAnswersAndSpecialReviews(DevelopmentProposal developmentProposal);
	/**
	 * Check Other Agencies flag deviates from
       proposal question concerning other agencies
	 * proposal special review answers
	 * see FN_OTHER_AGENCY_DEVIATION
	 * @param developmentProposal
	 * @return 'true' if if  deviation
	 * 
	 */
	public String otherAgencyDeviation(DevelopmentProposal developmentProposal);
	/***
	 * This method checks total cost for a cost element in any period of a version 
	 * see FN_COST_ELEMENT_VER_PER_LIMIT.
	 * @param developmentProposal
	 * @return true if crossed the limit
	 */
	public String getCostElemPeriodLimitInVer(DevelopmentProposal developmentProposal,Long budgetVersion,String costElement,String CostAmountLimit);
	/***
 * to validate keyPerson certification 
 * see FN_VALIDATE_PROP_KP_CERTIFY.
 * @param developmentProposal
 * @return 'true' if keyperson is certified
 */
public String isKeyPersonCertifyValid(DevelopmentProposal developmentProposal);
/**	 
 * This method is to check if ALL CO-PIS HAVE PI STATUS
 * fn_co_i_appoint_type_rule 
 */
public String coiAppointmentTypeRule(DevelopmentProposal developmentProposal);

/**
 * This method will check Multi Pi required Certification
 */
public String hasMultiPiRequiredCertification(DevelopmentProposal developmentProposal);
/*** Create New Function "ORIGINAL INSTITUTIONAL PROPOSAL ID IS VALID"
*  where if an IP # s entered in the field it's valid if the IP status is "Pending". 
*/
public boolean isOriginalIPIsValid(DevelopmentProposal developmentProposal);
/**
* Create New Function "PREVIOUS GRANTS.GOV TRACKING ID IS MISSING"
* if the function is equal to true it means the field in the KC Dev Proposal is blank.
*/
public boolean confirmTrackingIDBlank(DevelopmentProposal developmentProposal);

/**
 *This function will check if proposal reached OSP
 */
public String hasReachedOspInRouting(DevelopmentProposal developmentProposal);
public String piAppointmentTypeRule(DevelopmentProposal developmentProposal);
}
