package edu.mit.kc.workloadbalancing.peopleflow;


import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.kuali.coeus.common.framework.sponsor.hierarchy.SponsorHierarchy;
import org.kuali.coeus.common.framework.unit.admin.UnitAdministrator;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.infrastructure.Constants;
import edu.mit.kc.workloadbalancing.bo.WLCurrentLoad;
import org.kuali.rice.core.api.criteria.PredicateFactory;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import edu.mit.kc.workloadbalancing.bo.WlAbsentee;
import edu.mit.kc.workloadbalancing.bo.WlCapacity;
import edu.mit.kc.workloadbalancing.bo.WlFlexibility;

@Component("wLCurrentLoadService")
public class WLCurrentLoadServiceImpl implements WLCurrentLoadService{
	
	
	@Autowired
	@Qualifier("dataObjectService")
	private DataObjectService dataObjectService;
	
	@Autowired
    @Qualifier("dateTimeService")
    private DateTimeService dateTimeService;
	
	
	 @Autowired
	 @Qualifier("businessObjectService")
	 private BusinessObjectService businessObjectService;

	

	// Function to get Flexible Load by Sponsor
	// Input: OSPLead, and Sponsor Group
	// Output: Number of proposals that the OSP person is working on as a flexible assignment
	public double getFlexibleLoadBySponsor(String personId, String sponsorGroup) {
		
         Calendar calendar = getDateTimeService().getCurrentCalendar();
         calendar.add(Calendar.DAY_OF_MONTH, -6);
		 List<WLCurrentLoad> wLCurrentLoadList = getDataObjectService().findMatching(WLCurrentLoad.class,QueryByCriteria.Builder.fromPredicates(
						 PredicateFactory.equal("person_id", personId),
						 PredicateFactory.equal("sponsorGroup", sponsorGroup),
						 PredicateFactory.notEqual("originalApprover", personId),
						 PredicateFactory.equal("reroutedFlag", "N"),
						 PredicateFactory.between("arrivalDate", calendar.getTime(), getDateTimeService().getCurrentDate()))).getResults();
		double res = 0.0;
		if(!wLCurrentLoadList.isEmpty()){
			res = wLCurrentLoadList.size();
		}
		return res;
	}

	// Function to get Current Load 
	// Input: OSPLead
	// Output: Number of proposals weighted by complexity that the OSP person is working on in total 	
	public double getCurrentLoad(String personId) {
		
		Calendar calendar = getDateTimeService().getCurrentCalendar();
        calendar.add(Calendar.DAY_OF_MONTH, -6);
		 List<WLCurrentLoad> wLCurrentLoadList = getDataObjectService().findMatching(WLCurrentLoad.class,QueryByCriteria.Builder.fromPredicates(
						 PredicateFactory.equal("person_id", personId),
						 PredicateFactory.between("arrivalDate", calendar.getTime(), getDateTimeService().getCurrentDate()))).getResults();
		
		double res = 0.0;
		if(!wLCurrentLoadList.isEmpty()){
			for(WLCurrentLoad wLCurrentLoad :wLCurrentLoadList){
				if(wLCurrentLoad.getComplexity()!=null){
					res = res + wLCurrentLoad.getComplexity();
				}
			}
		}
		return res;
	}
	
	// Function to get Unit Number
	// Input: Proposal Number
	// Output: The Unit ID for this proposal	
	public String getUnitNumber(String proposalId) {
		String unitNumber=null;
	    DevelopmentProposal developmentProposal = (DevelopmentProposal) getDataObjectService().find(DevelopmentProposal.class, proposalId);
		if(developmentProposal!=null){
			unitNumber = developmentProposal.getOwnedByUnitNumber();
		}
		return unitNumber;
	}
	
	
	//Nataly
	// Function to get list of all people at OSP with a positive capcity
	// Input : None
	// Output: Returns a sorted list of person IDs	
	public List<String> getAllOspPeople() {
		
	   List<WlCapacity> wlCapacityList = getDataObjectService().findMatching(WlCapacity.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.greaterThan("capacity", 0))).getResults();
		 
		List<String> personIds = new ArrayList<String>();
		  
		for(WlCapacity wlCapacity : wlCapacityList){
			personIds.add(wlCapacity.getPersonId());
		}
		return personIds;
	}
	
	
	//Nataly
	// Function to sort the current load of OSP CAs accross OSP
	// Input : None
	// Output: Returns a sorted list of person IDs	
	public String getLeastLoadedOspPerson() {
		List<String> ospPersonList = getAllOspPeople();
		List<String> sortedPersonList = new ArrayList<String>(ospPersonList);
		String leastLoadedOspPerson = null;
		Long complexityValue = 0L;
		Calendar calendar = getDateTimeService().getCurrentCalendar();
        calendar.add(Calendar.DAY_OF_MONTH, -6);
		List<WLCurrentLoad> wLCurrentLoadList = getDataObjectService().findMatching(WLCurrentLoad.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.between("arrivalDate", calendar.getTime(), getDateTimeService().getCurrentDate()))).getResults();
		Map<String,Long> personComplexityMap = new HashMap<String,Long>();
		List<Long> complextyList = new ArrayList<Long>();
		
		for(WLCurrentLoad wLCurrentLoad : wLCurrentLoadList){
			if(ospPersonList.contains(wLCurrentLoad.getPerson_id()) && wLCurrentLoad.getComplexity()!=null){
				sortedPersonList.remove(wLCurrentLoad.getPerson_id());
				if(personComplexityMap.containsKey(wLCurrentLoad.getPerson_id())){

					complexityValue = personComplexityMap.get(wLCurrentLoad.getPerson_id());
					complexityValue = complexityValue + wLCurrentLoad.getComplexity();
					personComplexityMap.put(wLCurrentLoad.getPerson_id(), complexityValue);
				}else{
					personComplexityMap.put(wLCurrentLoad.getPerson_id(), wLCurrentLoad.getComplexity());
				}
			}
		}
		 for(Long complextyValue :personComplexityMap.values()){
			 complextyList.add(complextyValue);
		 }
	//	 complextyList = (List<Long>) personComplexityMap.values();
		 Collections.sort(complextyList);
		 for(Long complexity : complextyList){
			 for (Entry<String, Long> personComplexityMapentry :personComplexityMap.entrySet() ){
				 if(personComplexityMapentry.getValue().equals(complexity)){
					 leastLoadedOspPerson = personComplexityMapentry.getKey();
					 break;
				 }
			 }
			 sortedPersonList.add(leastLoadedOspPerson);
			/* if(leastLoadedOspPerson!=null){
				 break;
			 }*/
		 }
		
		 
		 for(String sortedPerson : sortedPersonList){
			 if(!isAbsent(sortedPerson)){
				 leastLoadedOspPerson = sortedPerson;
				 break;
			 }
		 }
		 
		return leastLoadedOspPerson;
	}
	

	//Nataly
	// Function to tell if someone is absent on the arrival date
	// Input : None
	// Output: Returns a sorted list of person IDs
	public boolean isAbsent(String personId){
		
		 Calendar calendar = getDateTimeService().getCurrentCalendar();
		 List<WlAbsentee> wlAbsentees = getDataObjectService().findMatching(WlAbsentee.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("personId", personId),
				 PredicateFactory.lessThanOrEqual("leaveStartDate", calendar.getTime()),
				 PredicateFactory.greaterThanOrEqual("leaveEndDate", calendar.getTime()))).getResults();
		 
		if(wlAbsentees!=null && wlAbsentees.size()>0){
			return true;
		}
		return false;
	}
	
	//Nataly
	// Function to tell if someone is absent on the arrival date
	// Input : None
	// Output: Returns a sorted list of person IDs
	public boolean isAbsent(String personId , Timestamp arrivaldate){
		 List<WlAbsentee> wlAbsentees = getDataObjectService().findMatching(WlAbsentee.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("personId", personId),
				 PredicateFactory.lessThanOrEqual("leaveStartDate", arrivaldate),
				 PredicateFactory.greaterThanOrEqual("leaveEndDate", arrivaldate))).getResults();
		 
		if(wlAbsentees!=null && wlAbsentees.size()>0){
			return true;
		}
		return false;
	}

	
	// Nataly
	// Function to sort the current load of OSP CAs for a particular sponsor group
	// Input: Sponsor Group
	// Output: Returns a sorted list of person IDs	
	public List<String> getOspAdminsByCurrentLoad(String sponsorGroup) {
		List<String> flexiblePersonIds = getFlexiblePersons(sponsorGroup);
		List<String> sortedPersons = new ArrayList<String>(flexiblePersonIds);
		Calendar calendar = getDateTimeService().getCurrentCalendar();
        calendar.add(Calendar.DAY_OF_MONTH, -6);
		List<WLCurrentLoad> wLCurrentLoadList = getDataObjectService().findMatching(WLCurrentLoad.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.between("arrivalDate", calendar.getTime(), getDateTimeService().getCurrentDate()))).getResults();
		
		Map<String,Long> personComplexityMap = new HashMap<String,Long>();
		List<Long> complextyList = new ArrayList<Long>();
		for(WLCurrentLoad wLCurrentLoad : wLCurrentLoadList){
			if(flexiblePersonIds.contains(wLCurrentLoad.getPerson_id()) && wLCurrentLoad.getComplexity()!=null && !isAbsent(wLCurrentLoad.getPerson_id(),wLCurrentLoad.getArrivalDate())){
				sortedPersons.remove(wLCurrentLoad.getPerson_id());
				if(personComplexityMap.containsKey(wLCurrentLoad.getPerson_id())){

					Long complexity = personComplexityMap.get(wLCurrentLoad.getPerson_id());
					complexity = complexity + wLCurrentLoad.getComplexity();
					personComplexityMap.put(wLCurrentLoad.getPerson_id(), complexity);
				}else{
					personComplexityMap.put(wLCurrentLoad.getPerson_id(), wLCurrentLoad.getComplexity());
				}
			}
		}
		for(Long complextyValue :personComplexityMap.values()){
			 complextyList.add(complextyValue);
		 }
		 //complextyList = (List<Long>) personComplexityMap.values();
		 Collections.sort(complextyList);
		 for(Long complexity : complextyList){
			 for (Entry<String, Long> personComplexityMapentry :personComplexityMap.entrySet() ){
				 if(personComplexityMapentry.getValue().equals(complexity)){
					 if(!sortedPersons.contains(personComplexityMapentry.getKey())){
						 sortedPersons.add(personComplexityMapentry.getKey());
					 }
				 }
			 }
			
		 }
		return sortedPersons;
	}
	
	
	// Function to get the sponsor group
	// Input: Proposal Number and Activity Type
	// Output: Returns the Sponsor Group		
	public String getSponsorGroup(String proposalNumber, String activityType) {
		
		 String sponsorGroup = null;
		 DevelopmentProposal developmentProposal = (DevelopmentProposal) getDataObjectService().find(DevelopmentProposal.class, proposalNumber);
		 String wlHieararchyname =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "WL_SPONSOR_HIERARCHY_NAME");  

		 Map<String, String> queryMap = new HashMap<String, String>();
		 queryMap.put("sponsorCode", developmentProposal.getSponsorCode());
		 queryMap.put("hierarchyName",wlHieararchyname);
		 SponsorHierarchy sponsorHierarchy = (SponsorHierarchy)getBusinessObjectService().findByPrimaryKey(SponsorHierarchy.class, queryMap);
		 if(sponsorHierarchy!=null){
			 sponsorGroup = sponsorHierarchy.getLevel1();
		 }
	
		return sponsorGroup;
	}

	// Function to get the Activity Type
	// Input: Proposal Number
	// Output: Returns activity type	
	public String getActivityType(String proposalNumber) {
		
		String activityType=null;
		DevelopmentProposal developmentProposal = (DevelopmentProposal) getDataObjectService().find(DevelopmentProposal.class, proposalNumber);
		
		if(developmentProposal!=null){
			activityType = developmentProposal.getActivityTypeCode();
		}
		return activityType;
	}

	// Function to get the flexibility of a CA for a particular sponsor group
	// Input: Person ID and Sponsor Group
	// Output: Returns flexibility number	
	public double getFlexibility(String personId, String sponsorGroup) {
		double flexibility=-1;
		Map<String, String> queryMap = new HashMap<String, String>();
		queryMap.put("personId", personId);
		queryMap.put("sponsorGroup", sponsorGroup);
		
		List<WlFlexibility> wlFlexibilityList = (List<WlFlexibility>) getDataObjectService().findMatching(WlFlexibility.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("personId", personId),
				 PredicateFactory.equal("sponsorGroup", sponsorGroup))).getResults();
		
		WlFlexibility wlFlexibility = null;
		
		if(wlFlexibilityList!=null && !wlFlexibilityList.isEmpty()){
			wlFlexibility = wlFlexibilityList.get(0);
		}

		if(wlFlexibility!=null && wlFlexibility.getFlexibility()!=null && Double.parseDouble(wlFlexibility.getFlexibility())>0){
			flexibility = Double.parseDouble(wlFlexibility.getFlexibility());
		}
		return flexibility;
	}
	
	// Nataly
	// Function to get the flexible persons of a particular sponsor group that are not absent
	// Input: Person ID and Sponsor Group
	// Output: Returns flexibility number
	public List<String> getFlexiblePersons(String sponsorGroup) {
		List<String> persons = new ArrayList<String>();
		Calendar calendar = getDateTimeService().getCurrentCalendar();
		boolean personAbsentee = false;
	    List<WlFlexibility> wlFlexibilityList = getDataObjectService().findMatching(WlFlexibility.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("sponsorGroup", sponsorGroup),
				 PredicateFactory.isNotNull("flexibility"),
				 PredicateFactory.greaterThan("flexibility", 0))).getResults();
	    
		List<WlAbsentee> wlAbsentees = getDataObjectService().findMatching(WlAbsentee.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.lessThanOrEqual("leaveStartDate", calendar.getTime()),
				 PredicateFactory.greaterThanOrEqual("leaveEndDate", calendar.getTime()))).getResults();
		
		for(WlFlexibility wlFlexibility : wlFlexibilityList){
			for(WlAbsentee wlAbsentee : wlAbsentees){
				if(wlFlexibility.getPersonId().equals(wlAbsentee.getPersonId())){
					personAbsentee = true;
					break;
				}
			}
			if(!personAbsentee){
				persons.add(wlFlexibility.getPersonId());
			}
			personAbsentee = false;
		}

		return persons;
	}
	
	
	
	// Function to get the capacity of OSP CA
	// Input: Person ID
	// Output: Returns capacity		
	public int getCapacity(String personId) {
		
		int capacity=-1;
		List<WlCapacity> wlCapacityList = (List<WlCapacity>)getDataObjectService().findMatching(WlCapacity.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("personId", personId))).getResults();
		for(WlCapacity wlCapacity : wlCapacityList){
			capacity = wlCapacity.getCapacity();
			break;
		}
		return capacity;
	}
	
	// Function to get OSP lead of a certain unit 
	// Input: Unit ID
	// Output: Returns OSP lead ID		
	public String getOspAdmin(String unitId) {
		String ospAdmin=null;
		String unitAdmininstratorTypeCode =  KcServiceLocator.getService(ParameterService.class).getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE,Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, "OSP_ADMINISTRATOR_TYPE_CODE");  
		List<UnitAdministrator>  unitAdministrators = (List<UnitAdministrator>) getDataObjectService().findMatching(UnitAdministrator.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("unitNumber", unitId),
				 PredicateFactory.equal("unitAdministratorTypeCode", unitAdmininstratorTypeCode) )).getResults();
		for(UnitAdministrator unitAdministrator : unitAdministrators){
			ospAdmin = unitAdministrator.getPersonId();
			break;
		}
		return ospAdmin;
	}
	
	public DataObjectService getDataObjectService() {
	    return KcServiceLocator.getService(DataObjectService.class);
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
	    this.dataObjectService = dataObjectService;
	}
	
	public DateTimeService getDateTimeService() {
		return dateTimeService;
	}

	public void setDateTimeService(DateTimeService dateTimeService) {
		this.dateTimeService = dateTimeService;
	}
	
	public BusinessObjectService getBusinessObjectService() {
		return businessObjectService;
	}

	public void setBusinessObjectService(BusinessObjectService businessObjectService) {
		this.businessObjectService = businessObjectService;
	}
}
