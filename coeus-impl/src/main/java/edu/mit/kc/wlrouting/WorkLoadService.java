package edu.mit.kc.wlrouting;
import java.io.*;
import java.util.*;

//import edu.mit.coeus.utils.UtilFactory;
import edu.mit.kc.wlrouting.txn.WLCurrentLoadTxn;

public class WorkLoadService {
	public final static String FILE_NAME_PREFIX = "WL_Blalance_Log";
	public static void main(String[] args) throws IOException {
		WorkLoadService algo = new WorkLoadService();
		String next_osp_ID = algo.getNextRoutingOSP("00005198");
		System.out.println(next_osp_ID);
	}

	public String getNextRoutingOSP(String proposalNumber) throws IOException {
		WLCurrentLoadTxn txn = new WLCurrentLoadTxn();
		String activityType = txn.getActivityType(proposalNumber);
		String sponsorGroup = txn.getSponsorGroup(proposalNumber,activityType);
		String unitId = txn.getUnitNumber(proposalNumber);
        String OSPLead = txn.getOspAdmin(unitId);
		
		// Checking whether the proposal is a fellowship and assign it to an 
		// OSP personnel that can handle the fellowships. If so, the algorithm 
		// returns the ID of this person and exits.
		if(activityType.equals("3") || activityType.equals("7")){
			List<String> fellowshipIds = txn.getOspAdminsByCurrentLoad(sponsorGroup);
			if(!fellowshipIds.isEmpty()){
				return fellowshipIds.get(0);
			}else{
				return txn.getLeastLoadedOspPerson();
			}
		}
		double capacityOSPLead = txn.getCapacity(OSPLead);
		String result;
		boolean ospAbsent=false;
		if(txn.isAbsent(OSPLead) || capacityOSPLead<=0){
			ospAbsent = true;
			result = txn.getLeastLoadedOspPerson();
		}else{
			result = OSPLead;
		}
		
		// Check if the OSP lead is beyond capacity. If so, then assign it to a 
		// flexible person with the least current load.		
		double OSPLeadCurrentLoad = txn.getCurrentLoad(OSPLead);
		//UtilFactory.log("Proposal Number: "+proposalNumber+",CA person id: "+OSPLead+",CA's Capacity: "+capacityOSPLead+",CA's Current Load: "+OSPLeadCurrentLoad, FILE_NAME_PREFIX);
		if (ospAbsent || (OSPLeadCurrentLoad > (capacityOSPLead*0.75))) {
			List<String> sortedPersonIdsByCurrentLoad = txn.getOspAdminsByCurrentLoad(sponsorGroup);
			//UtilFactory.log("Going to enter into person list sorted by current load", FILE_NAME_PREFIX);
			for (String personId : sortedPersonIdsByCurrentLoad) {
				double current_load = txn.getCurrentLoad(personId);
				double cap = txn.getCapacity(personId);
				//UtilFactory.log("Person Id: "+personId+",Capacity: "+cap+",Current Load: "+current_load, FILE_NAME_PREFIX);
				if (current_load < cap*0.75){
					double clBySponsor = txn.getFlexibleLoadBySponsor(personId, sponsorGroup);
					double flexibility = txn.getFlexibility(personId, sponsorGroup);
					//UtilFactory.log("Current load for the Sposnor Group: "+sponsorGroup+" is "+clBySponsor+" and flexibility is: "+flexibility, FILE_NAME_PREFIX);
					if (clBySponsor < flexibility) {
						//UtilFactory.log("Current load for the Sposnor Group is less than flexibility",FILE_NAME_PREFIX);
						result = personId;
						break;
					}
				}
			}
		}
		
		//UtilFactory.log("Proposal Number: "+proposalNumber+" POC Person Id: "+OSPLead+" Approver Id: "+result,FILE_NAME_PREFIX);
		return result;
	}

}	