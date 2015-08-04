package org.kuali.coeus.propdev.impl.dashboard;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.kuali.coeus.common.framework.version.VersionStatus;
import org.kuali.coeus.propdev.impl.person.ProposalPerson;
import org.kuali.coeus.propdev.impl.state.ProposalState;
import org.kuali.kra.award.document.AwardDocument;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.AwardService;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.kra.infrastructure.KeyConstants;
import org.kuali.rice.core.api.criteria.OrderByField;
import org.kuali.rice.core.api.criteria.OrderDirection;
import org.kuali.rice.core.api.criteria.Predicate;
import org.kuali.rice.core.api.criteria.PredicateFactory;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.krad.data.DataObjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component("dashboardService")
public class DashboardServiceImpl implements DashboardService {
    @Autowired
	@Qualifier("dataObjectService")
    private DataObjectService dataObjectService;

    @Autowired
    @Qualifier("awardService")
    private AwardService awardService;
    
    @Autowired
    @Qualifier("parameterService")
    private ParameterService parameterService;
    
    public enum AwardStatus {
    	HOLD ("6"),
    	PENDING ("3"),
    	ACTIVE ("1"),
    	INACTIVE ("7"),
    	TERMINATED ("2"),
    	CLOSED ("4"),
    	RESTRICTED ("5");
        
        private final String statusCode;   
       
        AwardStatus(String statusCode) {
            this.statusCode = statusCode;
        }

        public String getStatusCode() { 
            return statusCode; 
        }
    }
    
    private static final String ROOT_AWARD_KEY = "-00001";
    
	public List<ProposalPerson> getProposalsForInvestigator(String investigatorPersonId) {
    	QueryByCriteria.Builder builder = QueryByCriteria.Builder.create();
        List<Predicate> predicates = new ArrayList<Predicate>();
        predicates.add(PredicateFactory.equal("personId", investigatorPersonId));
        predicates.add(PredicateFactory.equal("proposalPersonRoleId", Constants.PRINCIPAL_INVESTIGATOR_ROLE));
    	builder.setPredicates(PredicateFactory.and(predicates.toArray(new Predicate[] {})));
        builder.setOrderByFields(OrderByField.Builder.create("developmentProposal.proposalNumber", OrderDirection.DESCENDING).build());

        List<ProposalPerson> myProposals = getDataObjectService().findMatching(ProposalPerson.class, builder.build()).getResults();
        List<ProposalPerson> myArrangedProposals = new ArrayList<ProposalPerson>();
        if(myProposals != null && !myProposals.isEmpty()) {
            myArrangedProposals = getReArrangedProposals(myProposals);
        }
        return myArrangedProposals;
	}

	public List<Award> getAwardsForInvestigator(String investigatorPersonId) {
		List<Award> myAwards = getAllAwardsForInvestigator(investigatorPersonId);
        List<Award> myArrangedAwards = new ArrayList<Award>();
        if(myAwards != null && !myAwards.isEmpty()) {
            myArrangedAwards = getReArrangedAwards(myAwards);
        }
        return myArrangedAwards;
	}
	
	public List<Award> getActiveAwardsForInvestigator(String investigatorPersonId) {
		List<Award> myAwards = getAllAwardsForInvestigator(investigatorPersonId);
        List<Award> myAwardsFiltered = new ArrayList<Award>();
        String activeAwardStatusCodes = getActiveAwardStatusCodes();
        if(activeAwardStatusCodes != null) {
        	myAwardsFiltered = filterAwardForStatusCodes(activeAwardStatusCodes, myAwards);
        }else {
        	myAwardsFiltered.addAll(myAwards);
        }
        return myAwardsFiltered;
	}
	
	public List<Award> getInvestigatorAwardsForProjectDocument(List<Award> myAwards) {
		List<Award> myAwardsFiltered = new ArrayList<Award>();
		for(Award award : myAwards) {
			String awardStatusCode = Integer.toString(award.getStatusCode());
			String awardNumber = award.getAwardNumber();
	        if(awardNumber.endsWith(ROOT_AWARD_KEY) && (awardStatusCode.equals(AwardStatus.ACTIVE.getStatusCode()) || 
	        		awardStatusCode.equals(AwardStatus.PENDING.getStatusCode()) ||
	        		awardStatusCode.equals(AwardStatus.HOLD.getStatusCode()) ||
	        		awardStatusCode.equals(AwardStatus.INACTIVE.getStatusCode()))) {
				myAwardsFiltered.add(award);
			}
		}
		return myAwardsFiltered;
	}
	
	protected List<Award> filterAwardForStatusCodes(String activeAwardStatusCodes, List<Award> myAwards) {
        List<Award> myAwardsFiltered = new ArrayList<Award>();
		for(Award award : myAwards) {
			String awardStatusCode = Integer.toString(award.getStatusCode());
			if(activeAwardStatusCodes.contains(awardStatusCode)) {
				myAwardsFiltered.add(award);
			}
		}
		return myAwardsFiltered;
	}
	
	protected List<Award> getAllAwardsForInvestigator(String investigatorPersonId) {
        Map<String, Object> awardCriteria = new HashMap<String, Object>();
        awardCriteria.put("projectPersons.personId", investigatorPersonId);
        awardCriteria.put("projectPersons.roleCode", Constants.PRINCIPAL_INVESTIGATOR_ROLE);
        Collection<Award> myAwards = getAwardService().retrieveAwardsByCriteria(awardCriteria);
        List<Award> myAwardsFiltered = new ArrayList<Award>();
        for (Award award : myAwards) {
            if (VersionStatus.ACTIVE.toString().equals(award.getAwardSequenceStatus())) {
                myAwardsFiltered.add(award);
            }
        }
        return myAwardsFiltered;
	}
	
    protected List<ProposalPerson> getReArrangedProposals(List<ProposalPerson> myProposals) {
    	List<ProposalPerson> allMyArrangedProposals = new ArrayList<ProposalPerson>();
    	allMyArrangedProposals.addAll(getProposalsForStatus(myProposals, ProposalState.IN_PROGRESS));
     	allMyArrangedProposals.addAll(getProposalsForStatus(myProposals, ProposalState.REVISIONS_REQUESTED));
     	String[] filteredStateCodes = { ProposalState.IN_PROGRESS, ProposalState.REVISIONS_REQUESTED };
     	allMyArrangedProposals.addAll(getOtherProposals(myProposals, filteredStateCodes));
    	return allMyArrangedProposals;
    }
    
    protected List<ProposalPerson> getProposalsForStatus(List<ProposalPerson> myProposals, String proposalStateCode) {
    	List<ProposalPerson> myFilteredProposals = new ArrayList<ProposalPerson>();
    	List<ProposalPerson> currentProposals = new ArrayList<>(myProposals);
    	for(ProposalPerson proposalPerson : currentProposals) {
    		if(proposalPerson.getDevelopmentProposal().getProposalStateTypeCode().equals(proposalStateCode)) {
    			myFilteredProposals.add(proposalPerson);
    		}
    	}
    	return myFilteredProposals;
    }

    protected List<ProposalPerson> getOtherProposals(List<ProposalPerson> myProposals, String[] filteredStateCodes) {
    	List<ProposalPerson> myFilteredProposals = new ArrayList<ProposalPerson>();
    	List<ProposalPerson> currentProposals = new ArrayList<>(myProposals);
    	for(ProposalPerson proposalPerson : currentProposals) {
    		String proposalStateCode = proposalPerson.getDevelopmentProposal().getProposalStateTypeCode();
    		if(!Arrays.asList(filteredStateCodes).contains(proposalStateCode)) {
    			myFilteredProposals.add(proposalPerson);
    		}
    	}
    	return myFilteredProposals;
    }

    protected List<Award> getReArrangedAwards(Collection<Award> myAwards) {
    	List<Award> allMyArrangedAwards = new ArrayList<Award>();
    	for (AwardStatus awardStatus : AwardStatus.values()) {
    		for(Award award : myAwards) {
    			String awardStatusCode = Integer.toString(award.getStatusCode());
    			if(awardStatusCode.equals(awardStatus.getStatusCode())) {
    				allMyArrangedAwards.add(award);
    			}
    		}
		}    	
    	return allMyArrangedAwards;
    }

    protected String getActiveAwardStatusCodes() {
        return getParameterService().getParameterValueAsString(AwardDocument.class, KeyConstants.AWARD_ACTIVE_STATUS_CODES_PARM);
    }
    
	public DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}

	public AwardService getAwardService() {
		return awardService;
	}

	public void setAwardService(AwardService awardService) {
		this.awardService = awardService;
	}

	public ParameterService getParameterService() {
		return parameterService;
	}

	public void setParameterService(ParameterService parameterService) {
		this.parameterService = parameterService;
	}

}
