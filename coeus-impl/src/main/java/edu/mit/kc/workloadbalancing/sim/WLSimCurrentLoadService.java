package edu.mit.kc.workloadbalancing.sim;



import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

import edu.mit.kc.workloadbalancing.bo.WLCurrentLoadSim;


public interface WLSimCurrentLoadService {
	
	
	public double getFlexibleLoadBySponsor(Integer simNumber,String OSPLead, String sponsorGroup, Timestamp arrivalDate);

	public double getCurrentLoadForSim(Integer simNumber,String personId, Timestamp arrivalDate);
	
	public String getLeastLoadedOspPerson(Integer simNumber,Timestamp arrivalDate) ;
	
	public List<String> getOspAdminsByCurrentLoad(Integer simNumber,String sponsorGroup,Timestamp arrivalDate);
	
	public double getFlexibility(Integer simNumber,String oSPId, String sponsorGroup);
	
	
	public List<String> getFlexiblePersons(Integer simNumber,String sponsorGroup,Timestamp arrivalDate);
		
	public int getCapacity(Integer simNumber,String oSPId);
	
	public List<WLCurrentLoadSim> getWorkloadList(Integer simNumber,Date simulationStartdate,Date simulationEndDate);
	
	public String getUserId(String approverId);
	
	
	public void insertWlSimRecords(Integer simulationNumber,WLCurrentLoadSim wlCurrentLoadSim);
	public void deleteSimRecords(Integer simulationNumber);

	public WLCurrentLoadSim getPreviousRoutedBean(WLCurrentLoadSim wlCurrentLoadSim);
	
	public boolean isAbsent(String personId,Timestamp arrivalDate);
	
	public List<String> getAllOspPeople(Integer simId);
	
	public void beginSimulation(Integer simulationNumber, Date simulationStartDate, Date simulationEndDate);
	
	public void endSimulation(Integer simulationNumber);
	
	
	
}
