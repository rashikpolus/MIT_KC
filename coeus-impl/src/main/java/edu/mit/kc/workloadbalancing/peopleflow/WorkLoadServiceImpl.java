package edu.mit.kc.workloadbalancing.peopleflow;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;

@Component("workLoadService")
public class WorkLoadServiceImpl implements WorkLoadService{
	protected final Log LOG = LogFactory.getLog(WorkLoadServiceImpl.class);
	
	@Autowired
	@Qualifier("wLCurrentLoadService")
	private WLCurrentLoadService wLCurrentLoadService;

	public String getNextRoutingOSP(String proposalNumber){
		String activityType = getwLCurrentLoadService().getActivityType(proposalNumber);
		String sponsorGroup = getwLCurrentLoadService().getSponsorGroup(proposalNumber,activityType);
		String unitId = getwLCurrentLoadService().getUnitNumber(proposalNumber);
        String OSPLead = getwLCurrentLoadService().getOspAdmin(unitId);
		if(OSPLead==null){
			return OSPLead;
		}
		// Checking whether the proposal is a fellowship and assign it to an 
		// OSP personnel that can handle the fellowships. If so, the algorithm 
		// returns the ID of this person and exits.
		/*if(activityType.equals("3") || activityType.equals("7")){
			List<String> fellowshipIds = getwLCurrentLoadService().getOspAdminsByCurrentLoad(sponsorGroup);
			if(!fellowshipIds.isEmpty()){
				return fellowshipIds.get(0);
			}else{
				return getwLCurrentLoadService().getLeastLoadedOspPerson();
			}
		}*/
		double capacityOSPLead = getwLCurrentLoadService().getCapacity(OSPLead);
		String result;
		boolean ospAbsent=false;
		if(getwLCurrentLoadService().isAbsent(OSPLead) || capacityOSPLead<=0){
			ospAbsent = true;
			result = getwLCurrentLoadService().getLeastLoadedOspPerson();
		}else{
			result = OSPLead;
		}
		
		// Check if the OSP lead is beyond capacity. If so, then assign it to a 
		// flexible person with the least current load.		
		double OSPLeadCurrentLoad = getwLCurrentLoadService().getCurrentLoad(OSPLead);
		LOG.info("Proposal Number: "+proposalNumber+",CA person id: "+OSPLead+",CA's Capacity: "+capacityOSPLead+",CA's Current Load: "+OSPLeadCurrentLoad);
		if (ospAbsent  || (OSPLeadCurrentLoad > (capacityOSPLead*0.75))) {
			List<String> sortedPersonIdsByCurrentLoad = getwLCurrentLoadService().getOspAdminsByCurrentLoad(sponsorGroup);
			LOG.info("Going to enter into person list sorted by current load");
			for (String personId : sortedPersonIdsByCurrentLoad) {
				double current_load = getwLCurrentLoadService().getCurrentLoad(personId);
				double cap = getwLCurrentLoadService().getCapacity(personId);
				LOG.info("Person Id: "+personId+",Capacity: "+cap+",Current Load: "+current_load);
				if (current_load < cap*0.75){
					double clBySponsor = getwLCurrentLoadService().getFlexibleLoadBySponsor(personId, sponsorGroup);
					double flexibility = getwLCurrentLoadService().getFlexibility(personId, sponsorGroup);
					LOG.info("Current load for the Sposnor Group: "+sponsorGroup+" is "+clBySponsor+" and flexibility is: "+flexibility);
					if (clBySponsor < flexibility) {
						LOG.info("Current load for the Sposnor Group is less than flexibility");
						result = personId;
						break;
					}
				}
			}
		}
		LOG.info("Proposal Number: "+proposalNumber+" POC Person Id: "+OSPLead+" Approver Id: "+result);
		return result;
	}
	
	public WLCurrentLoadService getwLCurrentLoadService() {
		return wLCurrentLoadService;
	}

	public void setwLCurrentLoadService(WLCurrentLoadService wLCurrentLoadService) {
		this.wLCurrentLoadService = wLCurrentLoadService;
	}
}
