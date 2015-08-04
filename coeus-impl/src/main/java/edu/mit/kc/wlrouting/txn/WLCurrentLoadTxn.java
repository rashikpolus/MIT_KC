package edu.mit.kc.wlrouting.txn;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//import edu.mit.coeus.utils.UtilFactory;
import edu.mit.kc.wlrouting.WLCurrentLoad;
import edu.mit.kc.wlrouting.WorkLoadService;
import edu.mit.kc.wlrouting.sim.WorkloadSimulator;


public class WLCurrentLoadTxn {
	private WLConnectionManager connectionManager;
	private final static String FILE_NAME_PREFIX = WorkLoadService.FILE_NAME_PREFIX;
	public WLCurrentLoadTxn(){
		connectionManager = WLConnectionManager.getInstance();
	}
	
	
	public WLCurrentLoad getProposal(String proposalId) {
		String sql = "select ROUTING_NUMBER,PROPOSAL_NUMBER,PERSON_ID,USER_ID,SPONSOR_CODE,LEAD_UNIT from OSPA.wl$current_load where PROPOSAL_NUMBER=?";
		PreparedStatement prest;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, proposalId);
			ResultSet rs = prest.executeQuery();
			WLCurrentLoad currentLoad = new WLCurrentLoad();
			if (rs.next()) {
				currentLoad.setRoutingNumber(rs.getString("ROUTING_NUMBER"));
				currentLoad.setProposalNumber(rs.getString("PROPOSAL_NUMBER"));
				currentLoad.setPerson_id(rs.getString("PERSON_ID"));
				currentLoad.setUserId(rs.getString("USER_ID"));
				currentLoad.setSponsorCode(rs.getString("SPONSOR_CODE"));
				currentLoad.setLeadUnit(rs.getString("LEAD_UNIT"));
				return currentLoad;
			}else{
				throw new RuntimeException("Proposal '"+proposalId+"' cannot be found in WL$CURRENT_LOAD table");
			}
		} catch (SQLException e) {
			throw new RuntimeException("Something went wrong while querying the proposal"+proposalId+". Route cause: "+e.getMessage());
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getProposal", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
	}

	
	// Function to get Flexible Load by Sponsor
	// Input: OSPLead, and Sponsor Group
	// Output: Number of proposals that the OSP person is working on as a flexible assignment
	public double getFlexibleLoadBySponsor(String personId, String sponsorGroup) {
		String sql = "select count(PROPOSAL_NUMBER) from OSPA.WL$CURRENT_LOAD " +
						"where PERSON_ID=? AND SPONSOR_GROUP=? and ORIG_APPROVER!=? AND REROUTED_FLAG='N'" +
							"and trunc(ARRIVAL_DATE, 'DDD') between (trunc(sysdate, 'DDD')-6) and trunc(sysdate, 'DDD')";
		PreparedStatement prest;
		double res = 0.0;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, personId);
			prest.setString(2, sponsorGroup);
			prest.setString(3, personId);
			ResultSet rs = prest.executeQuery();
			while(rs.next()){
				String countString = rs.getString(1);
				res = countString==null?0.0:Double.parseDouble(countString);
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexibleLoadBySponsor", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexibleLoadBySponsor", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return res;
	}

	// Function to get Current Load 
	// Input: OSPLead
	// Output: Number of proposals weighted by complexity that the OSP person is working on in total 	
	public double getCurrentLoad(String personId) {
		String sql = "select sum(COMPLEXITY) from OSPA.WL$CURRENT_LOAD " +
				"where PERSON_ID=? and trunc(ARRIVAL_DATE, 'DDD') between (trunc(sysdate, 'DDD')-6) and trunc(sysdate, 'DDD')";
		PreparedStatement prest;
		double res = 0.0;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, personId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				Double sum = rs.getDouble(1);
				if(sum!=null){
					res = sum;
				}
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getCurrentLoad", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getCurrentLoad", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return res;
	}
	
	// Function to get Unit Number
	// Input: Proposal Number
	// Output: The Unit ID for this proposal	
	public String getUnitNumber(String proposalId) {
		
		String sql = "select UNIT_NUMBER from OSPA.osp$eps_prop_units where proposal_number=? and lead_unit_flag='Y'";
		String unitNumber=null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, proposalId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				unitNumber = rs.getString("UNIT_NUMBER");
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getUnitNumber", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getUnitNumber", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return unitNumber;
	}
	
	
	//Nataly
	// Function to get list of all people at OSP with a positive capcity
	// Input : None
	// Output: Returns a sorted list of person IDs	
	public List<String> getAllOspPeople() {
		String sql = "select PERSON_ID from OSPA.WL$CAPACITY where capacity>0";
		List<String> personIds = new ArrayList<String>();
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			ResultSet rs = prest.executeQuery();
			while(rs.next()){
				personIds.add(rs.getString("PERSON_ID"));
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getOspAdmin", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return personIds;
	}
	
	
	//Nataly
	// Function to sort the current load of OSP CAs accross OSP
	// Input : None
	// Output: Returns a sorted list of person IDs	
	public String getLeastLoadedOspPerson() {
		List<String> ospPersonList = getAllOspPeople();
		List<String> unloadedPersons = new ArrayList<String>(ospPersonList);
		List<String> sortedPersonIds = new ArrayList<String>();
		// Changed by Nataly - Added ARRIVAL_DATE
		String sql = "select PERSON_ID,sum(COMPLEXITY) from OSPA.wl$current_load where  " +
		"trunc(ARRIVAL_DATE, 'DDD') between (trunc(sysdate, 'DDD')-6) and trunc(sysdate, 'DDD')" +
		"group by PERSON_ID order by sum(COMPLEXITY)";
		PreparedStatement prest;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			ResultSet rs = prest.executeQuery();
			while (rs.next()) {
				String currLoadedPerson = rs.getString(1);
				if(ospPersonList.contains(currLoadedPerson)){
					unloadedPersons.remove(currLoadedPerson);
					sortedPersonIds.add(currLoadedPerson);
				}
			}
			unloadedPersons.addAll(sortedPersonIds);
			for (String sortedPersonId : unloadedPersons) {
				if(!isAbsent(sortedPersonId)){
					return sortedPersonId;
				}
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getLeastLoadedOspPerson", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		//UtilFactory.log("Least leaded persons: "+sortedPersonIds, FILE_NAME_PREFIX);
		return null;
	}
	// Function to sort the CAs who can handle fellowships by their current workload
	// Input: Sponsor Group
	// Output: Returns a sorted list of person IDs	
	public List<String> getFellowshipAdminsByCurrentLoad(String sponsorGroup) {
		List<String> flexiblePersonIds = getFlexiblePersons(sponsorGroup);
		List<String> sortedPersonIds = new ArrayList<String>();
		String sql = "select PERSON_ID,sum(COMPLEXITY) from OSPA.WL$CURRENT_LOAD where trunc(ARRIVAL_DATE, 'DDD') between (trunc(sysdate, 'DDD')-6) " +
				"and trunc(sysdate, 'DDD') group by PERSON_ID order by sum(COMPLEXITY)";
		PreparedStatement prest;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			ResultSet rs = prest.executeQuery();
			while (rs.next()) {
				String currLoadedPerson = rs.getString(1);
				if(flexiblePersonIds.contains(currLoadedPerson)){
					sortedPersonIds.add(currLoadedPerson);
				}
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFellowshipAdminsByCurrentLoad", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFellowshipAdminsByCurrentLoad", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		System.out.println(sortedPersonIds);
		return sortedPersonIds;
	}

	//Nataly
	// Function to tell if someone is absent on the arrival date
	// Input : None
	// Output: Returns a sorted list of person IDs
	public boolean isAbsent(String personId){
		String sql = "select count(*) absent_count from OSPA.WL$ABSENTEE where person_id=? and sysdate >= LEAVE_START_DATE and sysdate <= LEAVE_END_DATE";
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, personId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				String absent = rs.getString(1);
				if(absent!=null && Integer.parseInt(absent)>0){
					return true;
				}else{
					return false;
				}
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "isAbsent", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return false;
	}

	
	// Nataly
	// Function to sort the current load of OSP CAs for a particular sponsor group
	// Input: Sponsor Group
	// Output: Returns a sorted list of person IDs	
	public List<String> getOspAdminsByCurrentLoad(String sponsorGroup) {
		List<String> flexiblePersonIds = getFlexiblePersons(sponsorGroup);
		List<String> completeSortedPersons = new ArrayList<String>(flexiblePersonIds);
		List<String> tempSortedPersons = new ArrayList<String>();
		Map<String,Double> fexMap = new HashMap<String, Double>();
		String sql = "select PERSON_ID,sum(COMPLEXITY) from OSPA.WL$CURRENT_LOAD where  " +
					 "trunc(ARRIVAL_DATE, 'DDD') between (trunc(sysdate, 'DDD')-6) and trunc(sysdate, 'DDD') " +
					 "and person_id not in (select person_id from ospa.wl$absentee where"+ 
					 " ARRIVAL_DATE >= LEAVE_START_DATE and ARRIVAL_DATE <= LEAVE_END_DATE) "+
		             "group by PERSON_ID order by sum(COMPLEXITY)";
		PreparedStatement prest;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			ResultSet rs = prest.executeQuery();
			
			while (rs.next()) {
				String currLoadedPerson = rs.getString(1);
				Double complexity = rs.getDouble(2);
				fexMap.put(currLoadedPerson, complexity);
				if(flexiblePersonIds.contains(currLoadedPerson)){
					completeSortedPersons.remove(currLoadedPerson);
					tempSortedPersons.add(currLoadedPerson);
				}
			}
			for (String unsortedPersonId : completeSortedPersons) {
				fexMap.put(unsortedPersonId, Double.valueOf(0));
			}
			completeSortedPersons.addAll(tempSortedPersons);
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getOspAdminsByCurrentLoad", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getOspAdminsByCurrentLoad", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		//UtilFactory.log("Sorted List: "+completeSortedPersons,FILE_NAME_PREFIX);
		return completeSortedPersons;
	}
	
	
	// Function to get the sponsor group
	// Input: Proposal Number and Activity Type
	// Output: Returns the Sponsor Group		
	public String getSponsorGroup(String proposalNumber, String activityType) {
		String fellowshipSponsorCode = "(select sponsor_code from OSPA.osp$eps_proposal where proposal_number=?)";
		if(activityType.equals("3") || activityType.equals("7")){
			fellowshipSponsorCode = "'999998'";
		}
		String sql = "select LEVEL1 from OSPA.OSP$SPONSOR_HIERARCHY where HIERARCHY_NAME='Workload Balancing' and sponsor_code="+fellowshipSponsorCode;
				
		String sponsorGroup = null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			if(!fellowshipSponsorCode.equals("'999998'")){
				prest.setString(1, proposalNumber);
			}
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				sponsorGroup = rs.getString("LEVEL1");
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getSponsorGroup", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getSponsorGroup", FILE_NAME_PREFIX);
				}
				conn=null;
			}
		}
		return sponsorGroup;
	}

	// Function to get the Activity Type
	// Input: Proposal Number
	// Output: Returns activity type	
	public String getActivityType(String proposalNumber) {
		String sql = "select ACTIVITY_TYPE_CODE from OSPA.osp$eps_proposal where proposal_number=? ";
		String activityType=null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, proposalNumber);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				activityType = rs.getString("ACTIVITY_TYPE_CODE");
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getActivityType", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getActivityType", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return activityType;
	}

	// Function to get the flexibility of a CA for a particular sponsor group
	// Input: Person ID and Sponsor Group
	// Output: Returns flexibility number	
	public double getFlexibility(String personId, String sponsorGroup) {
		String sql = "select FLEXIBILITY from OSPA.WL$FLEXIBILITY where person_id=? and sponsor_group=?"+
				" and FLEXIBILITY is not null and FLEXIBILITY > 0";
		double flexibility=-1;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, personId);
			prest.setString(2, sponsorGroup);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				flexibility = rs.getDouble(1);
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexibility", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexibility", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return flexibility;
	}
	
	// Nataly
	// Function to get the flexible persons of a particular sponsor group that are not absent
	// Input: Person ID and Sponsor Group
	// Output: Returns flexibility number
	public List<String> getFlexiblePersons(String sponsorGroup) {
		//String sql = "select PERSON_ID from OSPA.WL$FLEXIBILITY where sponsor_group=?";
		String sql = "select PERSON_ID from OSPA.WL$FLEXIBILITY" +
					 " where sponsor_group=? and FLEXIBILITY is not null and FLEXIBILITY > 0" +
		             "and PERSON_ID not in (select person_id from ospa.wl$absentee where"+ 
		             " sysdate >= LEAVE_START_DATE and sysdate <= LEAVE_END_DATE)";
		PreparedStatement prest;
		Connection conn = null;
		List<String> persons = new ArrayList<String>();
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, sponsorGroup);
			ResultSet rs = prest.executeQuery();
			while(rs.next()){
				persons.add(rs.getString(1));
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexiblePersons", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexiblePersons", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return persons;
	}
	
	public double getFlexibilityTotal(String personId) {
		String sql = "select sum(FLEXIBILITY) from OSPA.WL$FLEXIBILITY where person_id=?";
		PreparedStatement prest;
		Connection conn = null;
		Double sum_flexibility = 0.0;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, personId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				sum_flexibility = rs.getDouble(1);
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexibilityTotal", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getFlexibilityTotal", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return sum_flexibility.doubleValue();
	}
	
	// Function to get the capacity of OSP CA
	// Input: Person ID
	// Output: Returns capacity		
	public int getCapacity(String personId) {
		String sql = "select CAPACITY from OSPA.WL$CAPACITY where person_id=?";
		int capacity=-1;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, personId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				capacity = rs.getInt("CAPACITY");
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getCapacity", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getCapacity", FILE_NAME_PREFIX);
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return capacity;
	}
	
	// Function to get OSP lead of a certain unit 
	// Input: Unit ID
	// Output: Returns OSP lead ID		
	public String getOspAdmin(String unitId) {
		String sql = "select OSP_ADMINISTRATOR from OSPA.OSP$UNIT where unit_number=?";
		String ospAdmin=null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, unitId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				ospAdmin = rs.getString("OSP_ADMINISTRATOR");
			}
		} catch (SQLException e) {
			//UtilFactory.logMessage(e.getMessage(), e, "WLCurrentLoadTxn", "getOspAdmin", FILE_NAME_PREFIX);
			e.printStackTrace();
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
				conn=null;
			}
		}
		return ospAdmin;
	}
}
