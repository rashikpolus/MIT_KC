package edu.mit.kc.wlrouting.sim;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

//import edu.mit.coeus.utils.UtilFactory;
import edu.mit.kc.wlrouting.txn.WLSimCurrentLoadTxn;

public class WorkloadSimulator implements IWorkloadSimulator{
	public static final String FILE_NAME_PREFIX = "WL_SIM_Log";
	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception{
		String simIdStr = args[0];
		String startdateStr = args[1];
		String endDateStr = args[2];
//		String simIdStr = "4";
//		String startdateStr = "03/15/2014";
//		String endDateStr = "03/30/2014";
		Integer simId = Integer.parseInt(simIdStr);
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
		Date simulationStartdate = new Date(sdf.parse(startdateStr).getTime());
		Date simulationEndDate = new Date(sdf.parse(endDateStr).getTime());
		WorkloadSimulator wls = new WorkloadSimulator();
		wls.simulateWorkload(simId,simulationStartdate, simulationEndDate);
		
	}
	public void simulateWorkload(Integer simulationNumber,Date simulationStartdate,Date simulationEndDate) throws Exception{
		WLSimCurrentLoadTxn txn = new WLSimCurrentLoadTxn();
		try{
		txn.beginSimulation(simulationNumber,simulationStartdate,simulationEndDate);
		List<WLCurrentLoadSimBean> workLoadList = txn.getWorkloadList(simulationNumber,simulationStartdate,simulationEndDate);
		txn.deleteSimRecords(simulationNumber);
		for (WLCurrentLoadSimBean wlCurrentLoadSimBean : workLoadList) {
			wlCurrentLoadSimBean.setSimId(simulationNumber);
			if(wlCurrentLoadSimBean.getReroutedFlag().equals("N")){
				String approverId = getNextRoutingOSP(simulationNumber,wlCurrentLoadSimBean);
				String paproverUserId = txn.getUserId(approverId);
				wlCurrentLoadSimBean.setSimulatedPersonId(approverId);
				wlCurrentLoadSimBean.setSimulatedUserId(paproverUserId);
			}else{
				wlCurrentLoadSimBean = txn.getPreviousRoutedBean(wlCurrentLoadSimBean);
			}
			if(wlCurrentLoadSimBean!=null){
				txn.insertWlSimRecords(simulationNumber,wlCurrentLoadSimBean);
			}
		}
		txn.endSimulation(simulationNumber);
		txn.distroyConnection();
		}catch(SQLException e){
			//UtilFactory.logMessage(e.getMessage(), e, "WorkloadSimulator", "simulateWorkload", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			txn.endSimulation(simulationNumber);
			txn.distroyConnection();
		}
	}
	private String getNextRoutingOSP(Integer simNumber,WLCurrentLoadSimBean wlCurrentLoadSimBean) throws IOException,SQLException {
		WLSimCurrentLoadTxn txn = new WLSimCurrentLoadTxn();
		String proposalNumber = wlCurrentLoadSimBean.getProposalNumber();
		String activityType = wlCurrentLoadSimBean.getActivityTypeCode();
		String sponsorGroup = wlCurrentLoadSimBean.getSponsorGroup();
		String unitId = wlCurrentLoadSimBean.getLeadUnit();
		String result;
		String OSPLead = wlCurrentLoadSimBean.getOspLead();//txn.getOspAdmin(simNumber,unitId);
		Timestamp arrivalDate = wlCurrentLoadSimBean.getArrivalDate();
		if(activityType.equals("3") || activityType.equals("7")){
			sponsorGroup = txn.getFellowshipSponsorGroup();
			wlCurrentLoadSimBean.setSponsorGroup(sponsorGroup);
			List<String> fellowshipIds = txn.getOspAdminsByCurrentLoad(simNumber,sponsorGroup,arrivalDate);
			if(!fellowshipIds.isEmpty()){
				return fellowshipIds.get(0);
			}else{
				return txn.getLeastLoadedOspPerson(simNumber,arrivalDate);
			}
		}
		double capacityOSPLead = txn.getCapacity(simNumber,OSPLead);
		boolean ospAbsent=false;
		if(txn.isAbsent(OSPLead, arrivalDate) || capacityOSPLead<=0){
			ospAbsent = true;
			result = txn.getLeastLoadedOspPerson(simNumber,arrivalDate);
		}else{
			result = OSPLead;
		}
		// Checking whether the proposal is a fellowship and assign it to an 
		// OSP personnel that can handle the fellowships. If so, the algorithm 
		// returns the ID of this person and exits.
		// Check if the OSP lead is beyond capacity. If so, then assign it to a 
		// flexible person with the least current load.
		double OSPLeadCurrentLoad = txn.getCurrentLoadForSim(simNumber,OSPLead,arrivalDate);
		System.out.println("Proposal Number: "+proposalNumber+",CA person id: "+OSPLead+",CA's Capacity: "+capacityOSPLead+",CA's Current Load: "+OSPLeadCurrentLoad);
		//UtilFactory.log("Proposal Number: "+proposalNumber+",CA person id: "+OSPLead+",CA's Capacity: "+capacityOSPLead+",CA's Current Load: "+OSPLeadCurrentLoad, FILE_NAME_PREFIX);
		if (ospAbsent || (OSPLeadCurrentLoad > (capacityOSPLead*0.75))) {
			List<String> sortedPersonIdsByCurrentLoad = txn.getOspAdminsByCurrentLoad(simNumber,sponsorGroup,arrivalDate);
			System.out.println("Going to enter into person list sorted by current load");
			//UtilFactory.log("Going to enter into person list sorted by current load", FILE_NAME_PREFIX);
			for (String personId : sortedPersonIdsByCurrentLoad) {
//				if(!txn.isAbsent(personId, arrivalDate)){
					double current_load = txn.getCurrentLoadForSim(simNumber,personId,arrivalDate);
					double cap = txn.getCapacity(simNumber,personId);
					System.out.println("Person Id: "+personId+",Capacity: "+cap+",Current Load: "+current_load);
					//UtilFactory.log("Person Id: "+personId+",Capacity: "+cap+",Current Load: "+current_load, FILE_NAME_PREFIX);
					if (current_load < cap*0.75){
						double clBySponsor = txn.getFlexibleLoadBySponsor(simNumber,personId, sponsorGroup,arrivalDate);
						double flexibility = txn.getFlexibility(simNumber,personId, sponsorGroup);
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
		System.out.println("Proposal Number: "+proposalNumber+" POC Person Id: "+OSPLead+" Approver Id: "+result);
		//UtilFactory.log("Proposal Number: "+proposalNumber+" POC Person Id: "+OSPLead+" Approver Id: "+result,FILE_NAME_PREFIX);
		return result;
	}
}
