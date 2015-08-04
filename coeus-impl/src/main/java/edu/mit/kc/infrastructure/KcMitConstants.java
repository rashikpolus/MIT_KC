package edu.mit.kc.infrastructure;

import org.kuali.kra.infrastructure.Constants;

public interface KcMitConstants {
	
	/* Backdoor Login permission */
    public static final String ALLOW_BACKDOOR_LOGIN = "Allow Backdoor Login";
    
    public static final String PROPOSAL_PERSON_PI_CERTIFICATION = "4";

    public static final String PROPOSAL_PERSON_COI_CERTIFICATION = "5";

    public static final String PROPOSAL_PERSON_KP_CERTIFICATION = "6";
    
    public static final String ERROR_AWARD_FANDA_INVALID_RATE_PAIR = "error.awardDirectFandADistribution.invalid.rate.pare";


    /*Award FandA Rates*/
    
    public static final String ERROR_AWARD_FANDA_RATES_SOURCE="error.awardDirectFandADistribution.source.required";
    
    public static final String ERROR_AWARD_FANDA_RATES_DESTINATION="error.awardDirectFandADistribution.destination.required";
    
    public static final String ERROR_AWARD_FANDA_RATES_DESTINATION_LIMIT="error.awardDirectFandADistribution.destination.limit";
    
    public static final String ERROR_AWARD_FANDA_RATES_SOURCE_LIMIT="error.awardDirectFandADistribution.source.limit";
    
    /* Award Keyperson Maintenance */
    public static final String AWARD_KEYPERSON_MAINTENANCE_ROLE = "Maintain Keyperson"; 
    
    public static final String ROLE_CENTRAL_DB_KEYSTORE_LOCATION = "rolecentraldb.keystore.location"; 
    public static final String ROLE_CENTRAL_DB_KEYSTORE_PASSWORD = "rolecentraldb.keystore.password"; 
    public static final String ROLE_CENTRAL_DB_TRUSTSTORE_LOCATION = "rolecentraldb.truststore.location"; 
    public static final String ROLE_CENTRAL_DB_TRUSTSTORE_PASSWORD = "rolecentraldb.truststore.password"; 
    
    
    public static final String ENABLE_ROLE_INTEGRATION = "EnableRoleIntegration";
    
    public static final String ROLE_CENTRAL_DB_CATEGORY_CODE = "RoleCentralDbCategoryCode";
    
    
    public static final String HOLD_PROMPT = "Hold Prompt";
    
    public static final String ERROR_AWARD_TRANSACTION_TYPE = "error.award.no.transaction.type";
    //Award Hold Prompts
    public static final String ERROR_AWARD_HOLD_PROMPT_SPONSOR_CODE = "error.award.status.hold.sponsor.code";
    public static final String ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW_MAIN= "error.award.status.hold.human.review.main";
    public static final String ERROR_AWARD_HOLD_PROMPT_HUMAN_REVIEW ="error.award.status.hold.human.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_MULTIPLE_HUMAN_REVIEW ="error.award.status.hold.multiple.human.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_ANIMAL_REVIEW ="error.award.status.hold.animal.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_MULTIPLE_ANIMAL_REVIEW ="error.award.status.hold.multiple.animal.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_DNA_REVIEW ="error.award.status.hold.dna.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_MULTIPLE_DNA_REVIEW="error.award.status.hold.multiple.dna.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_ISOTOP_REVIEW="error.award.status.hold.isotop.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_MULTIPLE_ISOTOP_REVIEW="error.award.status.hold.multiple.isotop.review";
    public static final String ERROR_AWARD_HOLD_PROMPT_BIO_REVIEW="error.award.status.hold.bio.review"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_MULTIPLE_BIO_REVIEW="error.award.status.hold.multiple.bio.review";
    public static final String ERROR_AWARD_HOLD_PROMPT_INTER_REVIEW="error.award.status.hold.inter.review";
    public static final String ERROR_AWARD_HOLD_PROMPT_MULTIPLE_INTER_REVIEW="error.award.status.hold.multiple.inter.review";
    public static final String ERROR_AWARD_HOLD_PROMPT_REPORT_TERM="error.award.status.hold.report.term"; 
    public static final String ERROR_AWARD_HOLD_PROMPT_NO_SPECIAL_REVIEW="error.award.status.hold.no.specialreview";
    public static final String ERROR_AWARD_HOLD_PROMPT_NO_TERM_SPREVIEW="error.award.status.hold.no.term.spreview";
    public static final String ERROR_AWARD_HOLD_PROMPT_TERM_AND_SP_REV="error.award.hold.prompt.term.and.sp.rev";
    public static final String ERROR_AWARD_HOLD_NO_DISC_INV= "error.award.status.hold.no.disclosure.inv"; 
    public static final String ERROR_AWARD_HOLD_NO_DISC_KP= "error.award.status.hold.no.disclosure.kp";
    public static final String ERROR_AWARD_HOLD_KP_NOT_CONFIRMED= "error.award.status.hold.kp.not.confirmed";
    public static final String ERROR_AWARD_HOLD_PROMPT_COMMON="error.award.status.hold.common.violation";
    public static final String ERROR_COST_SHARE_SOURCE="error.awardCostShare.source.required";
    public static final String ERROR_COST_SHARE_DESTINATION="error.awardCostShare.destination.required";
    public static final String ERROR_COST_SHARE_SOURCE_LIMIT="error.awardCostShare.source.limit";
    public static final String ERROR_COST_SHARE_DESTINATION_LIMIT="error.awardCostShare.destination.limit";
    public static final String ERROR_OBLIGATED_OR_ANTICIPATED_AMOUNT_REQUIRED = "error.transaction.amount.required";
    public static final String ERROR_IP_COST_SHARE_SOURCE_ACCOUNT_LIMIT_EXCEEDS="error.institutionalProposalCostShare.sourceamount.exceeds";
    public static final String AWARD_BUDGET_STATUS_REPOSTED = "awardBudgetStatusRePosted";
    public static final String COI_QUESTION_ANSWERED = "proposal.info.coiQuestionAnswered";
    public static final String MIT_COEUS_COI_APPLICATION_URL = "mit.coeus.coi.application.url";
    
    public static final String COI_DISCLOSURE_EXPIRATION_DATE_ALERT = "coi.expirationDate.alert";
    public static final String COI_DISCLOSURE_EXPIRATION_NULLDATE_ALERT = "coi.expirationNullDate.alert";
    public static final String AWARD_FINAL_EXPIRATION_DATE_ALERT = "award.finalExpirationDate.alert";
    public static final String FINAL_TECHNICAL_REPORT_ALERT = "final.technicalReportsDue.alert";
    public static final String FINAL_PATENT_REPORT_ALERT = "final.patentReportsDue.alert";
    
  
    public static final String CERTIFICATION_COMPLETED = "error.proposalperson.certfication.completed";

}
