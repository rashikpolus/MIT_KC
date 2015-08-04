package edu.mit.kc.workloadbalancing.sim;


import static org.kuali.rice.core.api.criteria.PredicateFactory.equal;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.common.framework.person.KcPersonService;
import org.kuali.coeus.propdev.impl.core.DevelopmentProposal;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.criteria.PredicateFactory;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.datetime.DateTimeService;
import org.kuali.rice.krad.data.DataObjectService;
import org.kuali.rice.krad.data.PersistenceOption;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

import edu.mit.kc.workloadbalancing.bo.WLCurrentLoad;
import edu.mit.kc.workloadbalancing.bo.WLCurrentLoadSim;
import edu.mit.kc.workloadbalancing.bo.WlAbsentee;
import edu.mit.kc.workloadbalancing.bo.WlSimCapacity;
import edu.mit.kc.workloadbalancing.bo.WlSimFlexibility;
import edu.mit.kc.workloadbalancing.bo.WlSimHeader;
import edu.mit.kc.workloadbalancing.bo.WlSimUnitAssignment;



@Component("wLSimCurrentLoadService")
public class WLSimCurrentLoadServiceImpl implements WLSimCurrentLoadService{
	
	@Autowired
	@Qualifier("dataObjectService")
	private DataObjectService dataObjectService;
	
	

	@Autowired
    @Qualifier("dateTimeService")
    private DateTimeService dateTimeService;
	
	public double getFlexibleLoadBySponsor(Integer simNumber,String OSPLead, String sponsorGroup, Timestamp arrivalDate) {
		        
		double res = 0.0;
		
        Calendar calendar  = getDateTimeService().getCalendar(arrivalDate);
        
        calendar.add(Calendar.DAY_OF_MONTH, -6);
        
		List<WLCurrentLoadSim> wLCurrentLoadSimList = getDataObjectService().findMatching(WLCurrentLoadSim.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("simId", simNumber),
				 PredicateFactory.equal("simulatedPersonId", OSPLead),
				 PredicateFactory.notEqual("sponsorGroup", sponsorGroup),
				 PredicateFactory.equal("originalApproverPersonId", OSPLead),
				 PredicateFactory.between("arrivalDate", calendar.getTime(), arrivalDate))).getResults();
		
		if(wLCurrentLoadSimList !=null){
			res = wLCurrentLoadSimList.size();
		}
		
		
		
		return res;
	}

	public double getCurrentLoadForSim(Integer simNumber,String personId, Timestamp arrivalDate){
		
		double res = 0.0;
        Calendar calendar  = getDateTimeService().getCalendar(arrivalDate);
        calendar.add(Calendar.DAY_OF_MONTH, -6);
		List<WLCurrentLoadSim> wLCurrentLoadSimList = getDataObjectService().findMatching(WLCurrentLoadSim.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("simId", simNumber),
				 PredicateFactory.equal("simulatedPersonId", personId),
				 PredicateFactory.between("arrivalDate", calendar.getTime(), arrivalDate))).getResults();
		
		for(WLCurrentLoadSim wLCurrentLoadSim : wLCurrentLoadSimList){
			res = res + wLCurrentLoadSim.getComplexity();
		}
		
		
		
		return res;
	}
	public String getLeastLoadedOspPerson(Integer simNumber,Timestamp arrivalDate) {
		
		String leastLoadedOspPerson = null;
		Long complexityValue = 0L;
		Calendar calendar  = getDateTimeService().getCalendar(arrivalDate);
	    calendar.add(Calendar.DAY_OF_MONTH, -6);
		List<WLCurrentLoadSim> wLCurrentLoadSimList = getDataObjectService().findMatching(WLCurrentLoadSim.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("simId", simNumber),
				 PredicateFactory.between("arrivalDate", calendar.getTime(), arrivalDate))).getResults();
		
		Map<String,Long> personComplexityMap = new HashMap<String,Long>();
		List<Long> complextyList = new ArrayList<Long>();
		List<String> ospPersonList = getAllOspPeople(simNumber);
		
		List<String> unLoadedPersonList = new ArrayList<String>(ospPersonList);
		
		
		for(WLCurrentLoadSim wLCurrentLoadSim : wLCurrentLoadSimList){
			if(ospPersonList.contains(wLCurrentLoadSim.getSimulatedPersonId()) && wLCurrentLoadSim.getComplexity()!=null &&!isAbsent(wLCurrentLoadSim.getSimulatedPersonId(),arrivalDate)){
				unLoadedPersonList.remove(wLCurrentLoadSim.getSimulatedPersonId());
				if(personComplexityMap.containsKey(wLCurrentLoadSim.getSimulatedPersonId())){

					complexityValue = personComplexityMap.get(wLCurrentLoadSim.getSimulatedPersonId());
					complexityValue = complexityValue + wLCurrentLoadSim.getComplexity();
					personComplexityMap.put(wLCurrentLoadSim.getSimulatedPersonId(), complexityValue);
				}else{
					personComplexityMap.put(wLCurrentLoadSim.getSimulatedPersonId(), wLCurrentLoadSim.getComplexity());
				}
			}
		}
		for(Long complextyValue :personComplexityMap.values()){
			 complextyList.add(complextyValue);
		 }
		 //complextyList = (List<Double>) personComplexityMap.values();
		 Collections.sort(complextyList);
		 for(Long complexity : complextyList){
			 for (Entry<String, Long> personComplexityMapentry :personComplexityMap.entrySet() ){
				 if(personComplexityMapentry.getValue().equals(complexity)){
					 leastLoadedOspPerson = personComplexityMapentry.getKey();
					 break;
				 }
			 }
			 unLoadedPersonList.add(leastLoadedOspPerson);
			 /*if(leastLoadedOspPerson!=null){
				 break;
			 }*/
		 }
		if(unLoadedPersonList!=null && !unLoadedPersonList.isEmpty()){
			leastLoadedOspPerson = unLoadedPersonList.get(0);
		}
		
	
		
		return leastLoadedOspPerson;
	}
	
	public List<String> getOspAdminsByCurrentLoad(Integer simNumber,String sponsorGroup,Timestamp arrivalDate){
		
		
		Long complexityValue = 0L;
		Calendar calendar  = getDateTimeService().getCalendar(arrivalDate);
	    calendar.add(Calendar.DAY_OF_MONTH, -6);
		List<WLCurrentLoadSim> wLCurrentLoadSimList = getDataObjectService().findMatching(WLCurrentLoadSim.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("simId", simNumber),
				 PredicateFactory.between("arrivalDate", calendar.getTime(), arrivalDate))).getResults();
		
		Map<String,Long> personComplexityMap = new HashMap<String,Long>();
		List<Long> complextyList = new ArrayList<Long>();
		List<String> ospPersonList = getAllOspPeople(simNumber);
		List<String> sortedPersons = new ArrayList<String>(ospPersonList);
		for(WLCurrentLoadSim wLCurrentLoadSim : wLCurrentLoadSimList){
			if(ospPersonList.contains(wLCurrentLoadSim.getSimulatedPersonId()) && !isAbsent(wLCurrentLoadSim.getSimulatedPersonId(),arrivalDate)){
				sortedPersons.remove(wLCurrentLoadSim.getSimulatedPersonId());
				if(personComplexityMap.containsKey(wLCurrentLoadSim.getSimulatedPersonId())){

					complexityValue = personComplexityMap.get(wLCurrentLoadSim.getSimulatedPersonId());
					complexityValue = complexityValue + wLCurrentLoadSim.getComplexity();
					personComplexityMap.put(wLCurrentLoadSim.getSimulatedPersonId(), complexityValue);
				}else{
					personComplexityMap.put(wLCurrentLoadSim.getSimulatedPersonId(), wLCurrentLoadSim.getComplexity());
				}
			}
		}
		
		for(Long complextyValue :personComplexityMap.values()){
			 complextyList.add(complextyValue);
		 }
		// complextyList = (List<Long>) personComplexityMap.values();
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
	
	public double getFlexibility(Integer simNumber,String oSPId, String sponsorGroup){

		double flexibility=-1;
		List<WlSimFlexibility> wlSimFlexibilityList = getDataObjectService().findMatching(WlSimFlexibility.class,QueryByCriteria.Builder.fromPredicates(
				PredicateFactory.equal("simId", simNumber),
				PredicateFactory.equal("personId", oSPId),
				PredicateFactory.equal("sponsorGroup", sponsorGroup),
				PredicateFactory.isNotNull("flexibility"),
				PredicateFactory.greaterThan("flexibility", 0))).getResults();


		if(wlSimFlexibilityList != null && !wlSimFlexibilityList.isEmpty()){
			WlSimFlexibility wlSimFlexibility = wlSimFlexibilityList.get(0);
			flexibility = Double.parseDouble(wlSimFlexibility.getFlexibility());
		}

		
		return flexibility;
	}
	
	
	public List<String> getFlexiblePersons(Integer simNumber,String sponsorGroup,Timestamp arrivalDate){
		
		List<String> persons = new ArrayList<String>();
		List<WlSimFlexibility> wlSimFlexibilityList = getDataObjectService().findMatching(WlSimFlexibility.class,QueryByCriteria.Builder.fromPredicates(
				PredicateFactory.equal("simId", simNumber),
				PredicateFactory.equal("sponsorGroup", sponsorGroup),
				PredicateFactory.isNotNull("flexibility"),
				PredicateFactory.greaterThan("flexibility", 0))).getResults();
		
		
		for(WlSimFlexibility wlSimFlexibility : wlSimFlexibilityList){

			if(!persons.contains(wlSimFlexibility.getPersonId()) && !isAbsent(wlSimFlexibility.getPersonId(),arrivalDate)){
				persons.add(wlSimFlexibility.getPersonId());
			}
		}
		
				
		return persons;
	}
		
	public int getCapacity(Integer simNumber,String oSPId){
		
		int capacity=-1;
		
		List<WlSimCapacity> wlSimCapacityList = getDataObjectService().findMatching(WlSimCapacity.class,QueryByCriteria.Builder.fromPredicates(
				PredicateFactory.equal("simId", simNumber),
				PredicateFactory.equal("personId", oSPId))).getResults();
		
		if(wlSimCapacityList != null && !wlSimCapacityList.isEmpty()){
			WlSimCapacity wlSimCapacity = wlSimCapacityList.get(0);
			capacity = wlSimCapacity.getCapacity().intValue();
		}
				
		
		return capacity;
	}
	
	public List<WLCurrentLoadSim> getWorkloadList(Integer simNumber,Date simulationStartdate,Date simulationEndDate){
		
		 List<WLCurrentLoadSim> simBeanList = new ArrayList<WLCurrentLoadSim>();
		 List<WLCurrentLoad> wLCurrentLoadList = getDataObjectService().findMatching(WLCurrentLoad.class,QueryByCriteria.Builder.fromPredicates(
		 PredicateFactory.between("arrivalDate", simulationStartdate, simulationEndDate))).getResults();
		 
		 
		 List<WlSimUnitAssignment> wlUnitAssignmentsList = (List<WlSimUnitAssignment>) getDataObjectService().findMatching(WlSimUnitAssignment.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("simId", simNumber))).getResults();
		 
		 for(WlSimUnitAssignment  wlUnitAssignment : wlUnitAssignmentsList){
			 
			 for(WLCurrentLoad wLCurrentLoad : wLCurrentLoadList){
				 
				 if(wlUnitAssignment.getUnitNum().equals(wLCurrentLoad.getLeadUnit())){
					 
					 DevelopmentProposal developmentProposal = (DevelopmentProposal) getDataObjectService().find(DevelopmentProposal.class, wLCurrentLoad.getProposalNumber());
					 if(developmentProposal!=null){
						 WLCurrentLoadSim simBean = new WLCurrentLoadSim();
						 simBean.setOspLead(wlUnitAssignment.getPersonId());
						 simBean.setRoutingNumber(wLCurrentLoad.getRoutingNumber());
						 simBean.setProposalNumber(wLCurrentLoad.getProposalNumber());
						 simBean.setOriginalApproverPersonId(wLCurrentLoad.getOriginalApprover());
						 simBean.setOriginalApproverUserId(wLCurrentLoad.getOriginalUserId());
						 simBean.setWlAssignedPersonId(wLCurrentLoad.getPerson_id());
						 simBean.setWlAssignedUserId(wLCurrentLoad.getUserId());
						 simBean.setSponsorCode(wLCurrentLoad.getSponsorCode());
						 simBean.setSponsorGroup(wLCurrentLoad.getSponsorGroup());
						 simBean.setComplexity(wLCurrentLoad.getComplexity());
						 simBean.setLeadUnit(wLCurrentLoad.getLeadUnit());
						 simBean.setActiveFlag(wLCurrentLoad.getActiveFlag());
						 simBean.setArrivalDate(wLCurrentLoad.getArrivalDate());
						 simBean.setInactiveDate(wLCurrentLoad.getInactiveDate());
						 simBean.setReroutedFlag(wLCurrentLoad.getReroutedFlag());
						 simBean.setAssignedBy(wLCurrentLoad.getAssignedBy());
						 simBean.setUpdateUser(wLCurrentLoad.getUpdateUser());
						 simBean.setActivityTypeCode(developmentProposal.getActivityTypeCode());
						 simBeanList.add(simBean);
					 }
				 }
				 
			 }
			 
		 }

		return simBeanList;
	}
	
	public String getUserId(String approverId){
		
		String userId=null;
		
		/*String sql = "select USER_NAME from OSPA.OSP$PERSON where person_id=?";*/
		
		KcPersonService kcPersonService =  KcServiceLocator.getService(KcPersonService.class);
		
		KcPerson kcPerson = kcPersonService.getKcPersonByPersonId(approverId);
		
		userId = kcPerson.getUserName();
		
		return userId;
	}
	
	
	public void insertWlSimRecords(Integer simulationNumber,
			WLCurrentLoadSim wlCurrentLoadSim){
		
		getDataObjectService().save(wlCurrentLoadSim);
	
		
	}
	public void deleteSimRecords(Integer simulationNumber) {
		 
		getDataObjectService().deleteMatching(WLCurrentLoadSim.class, QueryByCriteria.Builder.fromPredicates(
                equal("simId", simulationNumber)));
		
	}

	public WLCurrentLoadSim getPreviousRoutedBean(
			WLCurrentLoadSim wlCurrentLoadSim){

		List<WLCurrentLoadSim> wLCurrentLoadSimList = getDataObjectService().findMatching(WLCurrentLoadSim.class,QueryByCriteria.Builder.fromPredicates(
				PredicateFactory.equal("simId", wlCurrentLoadSim.getSimId()),
				PredicateFactory.equal("proposalNumber", wlCurrentLoadSim.getProposalNumber()),
				PredicateFactory.notEqual("routingNumber", wlCurrentLoadSim.getRoutingNumber()))).getResults();

		if(wLCurrentLoadSimList!=null && !wLCurrentLoadSimList.isEmpty()){

			WLCurrentLoadSim  wLCurrentLoadSimdata = wLCurrentLoadSimList.get(0);
			wlCurrentLoadSim.setSimulatedPersonId(wLCurrentLoadSimdata.getSimulatedPersonId());
			wlCurrentLoadSim.setSimulatedUserId(wLCurrentLoadSimdata.getSimulatedUserId());
		}
		return wlCurrentLoadSim;
	}
	public boolean isAbsent(String personId,Timestamp arrivalDate) {
		
		 List<WlAbsentee> wlAbsentees = getDataObjectService().findMatching(WlAbsentee.class,QueryByCriteria.Builder.fromPredicates(
				 PredicateFactory.equal("personId", personId),
				 PredicateFactory.lessThanOrEqual("leaveStartDate", arrivalDate),
				 PredicateFactory.greaterThanOrEqual("leaveEndDate", arrivalDate))).getResults();
		 
		if(wlAbsentees!=null && wlAbsentees.size()>0){
			return true;
		}
		return false;
		
	}
	public List<String> getAllOspPeople(Integer simId) {
		
		
		List<WlSimCapacity> wlSimCapacityList = getDataObjectService().findMatching(WlSimCapacity.class,QueryByCriteria.Builder.fromPredicates(
				PredicateFactory.equal("simId", simId))).getResults();
		List<String> personIds = new ArrayList<String>();
		for(WlSimCapacity wlSimCapacity : wlSimCapacityList){
			personIds.add(wlSimCapacity.getPersonId());
		}
		return personIds;
	}
	
	public void beginSimulation(Integer simulationNumber, Date simulationStartDate, Date simulationEndDate){
		
		WlSimHeader wlSimHeader = new WlSimHeader();
		wlSimHeader.setStatusCode("2");
		wlSimHeader.setSimId(simulationNumber.toString());
		wlSimHeader.setStartDate(simulationStartDate);
		wlSimHeader.setEndDate(simulationEndDate);
		
	
		getDataObjectService().flush(WlSimHeader.class);
		wlSimHeader = getDataObjectService().save(wlSimHeader,PersistenceOption.FLUSH);
		
		
	}
	public void endSimulation(Integer simulationNumber){
		
		
		WlSimHeader wlSimHeader = new WlSimHeader();
		wlSimHeader.setStatusCode("3");
		wlSimHeader.setSimId(simulationNumber.toString());
		getDataObjectService().save(wlSimHeader,PersistenceOption.FLUSH);
	}
	
	
		
	public DateTimeService getDateTimeService() {
		return dateTimeService;
	}

	public void setDateTimeService(DateTimeService dateTimeService) {
		this.dateTimeService = dateTimeService;
	}
	
	public DataObjectService getDataObjectService() {
		return dataObjectService;
	}

	public void setDataObjectService(DataObjectService dataObjectService) {
		this.dataObjectService = dataObjectService;
	}
}
