package edu.mit.kc.institutionalproposal.rules;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.kuali.coeus.common.framework.sponsor.Sponsor;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.coeus.sys.framework.util.DateUtils;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;

import org.kuali.kra.institutionalproposal.home.InstitutionalProposal;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalSponsorAndProgramRuleEvent;
import org.kuali.kra.institutionalproposal.rules.InstitutionalProposalSponsorAndProgramRuleImpl;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;

public class MitInstitutionalProposalSponsorAndProgramRuleImpl extends
		InstitutionalProposalSponsorAndProgramRuleImpl {

	@Override
	public boolean processInstitutionalProposalSponsorAndProgramRules(
			InstitutionalProposalSponsorAndProgramRuleEvent institutionalProposalSponsorAndProgramRuleEvent) {
		return processCommonValidations(institutionalProposalSponsorAndProgramRuleEvent
				.getInstitutionalProposalForValidation());
	}

	@Override
	public boolean processCommonValidations(
			InstitutionalProposal institutionalProposal) {

		boolean validSponsorCode = validateSponsorCodeExists(institutionalProposal
				.getSponsorCode());

		boolean validPrimeSponsorId = validatePrimeSponsorIdExists(institutionalProposal
				.getPrimeSponsorCode());

		boolean validSponsorDeadlineTime = validateSponsorDeadlineTime(institutionalProposal);

		return validSponsorCode && validSponsorDeadlineTime;
	}

	private boolean validateSponsorDeadlineTime(
			InstitutionalProposal institutionalProposal) {
		boolean valid = true;
		if (!(institutionalProposal.getDeadlineTime() == null)) {

			String formatTime = DateUtils
					.formatFrom12Or24Str(institutionalProposal
							.getDeadlineTime());
			if (!formatTime.equalsIgnoreCase(Constants.INVALID_TIME)) {
				institutionalProposal.setDeadlineTime(formatTime);
			} else {
				GlobalVariables.getMessageMap().putError(
						"document.institutionalProposal.deadlineTime",
						KeyConstants.INVALID_DEADLINE_TIME);
				valid = false;
			}

		}
		return valid;
	}

	@SuppressWarnings("unchecked")
	private boolean validateSponsorCodeExists(String sponsorCode) {
		boolean valid = true;
		if (!(sponsorCode == null)) {
			Map<String, Object> fieldValues = new HashMap<String, Object>();
			fieldValues.put("sponsorCode", sponsorCode);
			BusinessObjectService businessObjectService = KcServiceLocator
					.getService(BusinessObjectService.class);
			List<Sponsor> sponsors = (List<Sponsor>) businessObjectService
					.findMatching(Sponsor.class, fieldValues);
			if (sponsors.size() == 0) {
				this.reportError(
						"document.institutionalProposalList[0].sponsorCode",
						KeyConstants.ERROR_INVALID_SPONSOR_CODE);
				valid = false;
			}
		}
		return valid;

	}

	@SuppressWarnings("unchecked")
	private boolean validatePrimeSponsorIdExists(String primeSponsorId) {
		boolean valid = true;
		if (!(primeSponsorId == null)) {
			Map<String, Object> fieldValues = new HashMap<String, Object>();
			fieldValues.put("sponsorCode", primeSponsorId);
			BusinessObjectService businessObjectService = KcServiceLocator
					.getService(BusinessObjectService.class);
			List<Sponsor> sponsors = (List<Sponsor>) businessObjectService
					.findMatching(Sponsor.class, fieldValues);
			if (sponsors.size() == 0) {
				this.reportError(
						"document.institutionalProposal.primeSponsorCode",
						KeyConstants.ERROR_INVALID_PRIME_SPONSOR_CODE);
				valid = false;
			}
		}
		return valid;
		
	}
}
