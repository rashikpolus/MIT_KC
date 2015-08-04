package edu.mit.kc.workloadbalancing.sim;


import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;


import edu.mit.kc.workloadbalancing.bo.WLCurrentLoadSim;


//import edu.mit.coeus.utils.UtilFactory;
@Component("workloadSimulatorService")
public class WorkloadSimulatorServiceImpl implements WorkloadSimulatorService{
	public static final String FILE_NAME_PREFIX = "WL_SIM_Log";
	
	
	@Autowired
	@Qualifier("wLSimCurrentLoadService")
	private WLSimCurrentLoadService wLSimCurrentLoadService;
	
	

	public void simulateWorkload(Integer simulationNumber,Date simulationStartdate,Date simulationEndDate) throws Exception{
		
			getwLSimCurrentLoadService().beginSimulation(simulationNumber,simulationStartdate,simulationEndDate);
		List<WLCurrentLoadSim> workLoadList = getwLSimCurrentLoadService().getWorkloadList(simulationNumber,simulationStartdate,simulationEndDate);
		getwLSimCurrentLoadService().deleteSimRecords(simulationNumber);
		for (WLCurrentLoadSim wlCurrentLoadSimBean : workLoadList) {
			wlCurrentLoadSimBean.setSimId(simulationNumber);
			if(wlCurrentLoadSimBean.getReroutedFlag().equals("N")){
				String approverId = getNextRoutingOSP(simulationNumber,wlCurrentLoadSimBean);
				String paproverUserId = getwLSimCurrentLoadService().getUserId(approverId);
				wlCurrentLoadSimBean.setSimulatedPersonId(approverId);
				wlCurrentLoadSimBean.setSimulatedUserId(paproverUserId);
			}else{
				wlCurrentLoadSimBean = getwLSimCurrentLoadService().getPreviousRoutedBean(wlCurrentLoadSimBean);
			}
			if(wlCurrentLoadSimBean!=null){
				getwLSimCurrentLoadService().insertWlSimRecords(simulationNumber,wlCurrentLoadSimBean);
			}
		}
		getwLSimCurrentLoadService().endSimulation(simulationNumber);
		
	}
	private String getNextRoutingOSP(Integer simNumber,WLCurrentLoadSim wlCurrentLoadSimBean) throws IOException,SQLException {
		String proposalNumber = wlCurrentLoadSimBean.getProposalNumber();
		String activityType = wlCurrentLoadSimBean.getActivityTypeCode();
		String sponsorGroup = wlCurrentLoadSimBean.getSponsorGroup();
		String unitId = wlCurrentLoadSimBean.getLeadUnit();
		String result;
		String OSPLead = wlCurrentLoadSimBean.getOspLead();//txn.getOspAdmin(simNumber,unitId);
		Timestamp arrivalDate = wlCurrentLoadSimBean.getArrivalDate();
		/*if(activityType.equals("3") || activityType.equals("7")){
			sponsorGroup = txn.getFellowshipSponsorGroup();
			wlCurrentLoadSimBean.setSponsorGroup(sponsorGroup);
			List<String> fellowshipIds = txn.getOspAdminsByCurrentLoad(simNumber,sponsorGroup,arrivalDate);
			if(!fellowshipIds.isEmpty()){
				return fellowshipIds.get(0);
			}else{
				return txn.getLeastLoadedOspPerson(simNumber,arrivalDate);
			}
		}*/
		double capacityOSPLead = getwLSimCurrentLoadService().getCapacity(simNumber,OSPLead);
		boolean ospAbsent=false;
		if(getwLSimCurrentLoadService().isAbsent(OSPLead, arrivalDate) || capacityOSPLead<=0){
			ospAbsent = true;
			result = getwLSimCurrentLoadService().getLeastLoadedOspPerson(simNumber,arrivalDate);
		}else{
			result = OSPLead;
		}
		// Checking whether the proposal is a fellowship and assign it to an 
		// OSP personnel that can handle the fellowships. If so, the algorithm 
		// returns the ID of this person and exits.
		// Check if the OSP lead is beyond capacity. If so, then assign it to a 
		// flexible person with the least current load.
		double OSPLeadCurrentLoad = getwLSimCurrentLoadService().getCurrentLoadForSim(simNumber,OSPLead,arrivalDate);
		//System.out.println("Proposal Number: "+proposalNumber+",CA person id: "+OSPLead+",CA's Capacity: "+capacityOSPLead+",CA's Current Load: "+OSPLeadCurrentLoad);
		if (ospAbsent || (OSPLeadCurrentLoad > (capacityOSPLead*0.75))) {
			List<String> sortedPersonIdsByCurrentLoad = getwLSimCurrentLoadService().getOspAdminsByCurrentLoad(simNumber,sponsorGroup,arrivalDate);
			//System.out.println("Going to enter into person list sorted by current load");
			for (String personId : sortedPersonIdsByCurrentLoad) {
//				if(!txn.isAbsent(personId, arrivalDate)){
					double current_load = getwLSimCurrentLoadService().getCurrentLoadForSim(simNumber,personId,arrivalDate);
					double cap = getwLSimCurrentLoadService().getCapacity(simNumber,personId);
					System.out.println("Person Id: "+personId+",Capacity: "+cap+",Current Load: "+current_load);
					//UtilFactory.log("Person Id: "+personId+",Capacity: "+cap+",Current Load: "+current_load, FILE_NAME_PREFIX);
					if (current_load < cap*0.75){
						double clBySponsor = getwLSimCurrentLoadService().getFlexibleLoadBySponsor(simNumber,personId, sponsorGroup,arrivalDate);
						double flexibility = getwLSimCurrentLoadService().getFlexibility(simNumber,personId, sponsorGroup);
						System.out.println("Current load for the Sposnor Group: "+sponsorGroup+" is "+clBySponsor+" and flexibility is: "+flexibility);
						//UtilFactory.log("Current load for the Sposnor Group: "+sponsorGroup+" is "+clBySponsor+" and flexibility is: "+flexibility, FILE_NAME_PREFIX);
						if (clBySponsor < flexibility) {
							System.out.println("Current load for the Sposnor Group is less than flexibility");
							//UtilFactory.log("Current load for the Sposnor Group is less than flexibility",FILE_NAME_PREFIX);
							result = personId;
							break;
						}
					}
//				}
			}
		}
		//System.out.println("Proposal Number: "+proposalNumber+" POC Person Id: "+OSPLead+" Approver Id: "+result);
		return result;
	}
	
	public WLSimCurrentLoadService getwLSimCurrentLoadService() {
		return wLSimCurrentLoadService;
	}
	public void setwLSimCurrentLoadService(
			WLSimCurrentLoadService wLSimCurrentLoadService) {
		this.wLSimCurrentLoadService = wLSimCurrentLoadService;
	}
}
