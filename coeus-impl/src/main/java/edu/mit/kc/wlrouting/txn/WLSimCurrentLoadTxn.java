package edu.mit.kc.wlrouting.txn;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

//import edu.mit.coeus.utils.UtilFactory;
import edu.mit.kc.wlrouting.WLCurrentLoad;
import edu.mit.kc.wlrouting.WLProperties;
import edu.mit.kc.wlrouting.WLPropertyKeys;
import edu.mit.kc.wlrouting.sim.WLCurrentLoadSimBean;
import edu.mit.kc.wlrouting.sim.WorkloadSimulator;


public class WLSimCurrentLoadTxn {
	private final static String FILE_NAME_PREFIX = WorkloadSimulator.FILE_NAME_PREFIX;
	private WLConnectionManager connectionManager;
	public WLSimCurrentLoadTxn(){
		connectionManager = WLConnectionManager.getInstance();
	}
	public double getFlexibleLoadBySponsor(Integer simNumber,String OSPLead, String sponsorGroup, Timestamp arrivalDate) throws SQLException{
		String sql = "select count(PROPOSAL_NUMBER) from OSPA.wl$sim_current_load where " +
				"SIM_ID=? AND SIM_PERSON_ID=? AND SPONSOR_GROUP=? and POC_PERSON_ID!=?" +
				"and trunc(ARRIVAL_DATE) between trunc(?-6) and trunc(?)";
		PreparedStatement prest;
		double res = 0.0;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setString(2, OSPLead);
			prest.setString(3, sponsorGroup);
			prest.setString(4, OSPLead);
			prest.setTimestamp(5, arrivalDate);
			prest.setTimestamp(6, arrivalDate);
			ResultSet rs = prest.executeQuery();
			while(rs.next()){
				String countString = rs.getString(1);
				res = countString==null?0.0:Double.parseDouble(countString);
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return res;
	}

	public double getCurrentLoadForSim(Integer simNumber,String personId, Timestamp arrivalDate)  throws SQLException{
		String sql = "select sum(COMPLEXITY) from OSPA.wl$sim_current_load where " +
				"SIM_ID=? AND SIM_PERSON_ID=? and trunc(ARRIVAL_DATE, 'DDD') between (trunc(?, 'DDD')-6) and trunc(?, 'DDD')";
		PreparedStatement prest;
		double res = 0.0;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setString(2, personId);
			prest.setTimestamp(3, arrivalDate);
			prest.setTimestamp(4, arrivalDate);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				Double sum = rs.getDouble(1);
				if(sum!=null){
					res = sum;
				}
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return res;
	}
	public String getLeastLoadedOspPerson(Integer simNumber,Timestamp arrivalDate)  throws SQLException{
		List<String> ospPersonList = getAllOspPeople(simNumber);
		List<String> unloadedPersons = new ArrayList<String>(ospPersonList);
		List<String> sortedPersonIds = new ArrayList<String>();
		String sql = "select SIM_PERSON_ID,sum(COMPLEXITY) from OSPA.wl$sim_current_load where  " +
				"SIM_ID=? AND   trunc(ARRIVAL_DATE) between trunc(?-6) and trunc(?) " +
				"group by SIM_PERSON_ID order by sum(COMPLEXITY)";
		PreparedStatement prest;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setTimestamp(2, arrivalDate);
			prest.setTimestamp(3, arrivalDate);
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
				if(!isAbsent(sortedPersonId, arrivalDate)){
					return sortedPersonId;
				}
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		//UtilFactory.log("Least leaded persons: "+sortedPersonIds, FILE_NAME_PREFIX);
		System.out.println("Least leaded persons: "+sortedPersonIds);
		return null;
	}
	
	public List<String> getOspAdminsByCurrentLoad(Integer simNumber,String sponsorGroup,Timestamp arrivalDate)  throws SQLException{
		Map<String,Double> fexMap = new HashMap<String, Double>();
		List<String> flexiblePersonIds = getFlexiblePersons(simNumber,sponsorGroup,arrivalDate);
		List<String> completeSortedPersons = new ArrayList<String>(flexiblePersonIds);
		List<String> tempSortedPersons = new ArrayList<String>();
		String sql = "select SIM_PERSON_ID,sum(COMPLEXITY) from OSPA.wl$sim_current_load a where  " +
				"SIM_ID=? AND  trunc(ARRIVAL_DATE) between trunc(?-6) and trunc(?) " +
				"and sim_person_id not in (select person_id from ospa.wl$absentee where"+ 
			            " ? >= LEAVE_START_DATE and ? <= LEAVE_END_DATE) "+
				"group by SIM_PERSON_ID order by sum(COMPLEXITY)";
		PreparedStatement prest;
		Connection conn=null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setTimestamp(2, arrivalDate);
			prest.setTimestamp(3, arrivalDate);
			prest.setTimestamp(4, arrivalDate);
			prest.setTimestamp(5, arrivalDate);
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
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		//UtilFactory.log("Sorted List: "+completeSortedPersons,FILE_NAME_PREFIX);
		return completeSortedPersons;
	}
	
	public double getFlexibility(Integer simNumber,String oSPId, String sponsorGroup)  throws SQLException{
		String sql = "select FLEXIBILITY from OSPA.WL$SIM_FLEXIBILITY where SIM_ID=? AND person_id=? and sponsor_group=?" +
						" and FLEXIBILITY is not null and FLEXIBILITY > 0";
		double flexibility=-1;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setString(2, oSPId);
			prest.setString(3, sponsorGroup);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				flexibility = rs.getDouble(1);
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return flexibility;
	}
	
	
	public List<String> getFlexiblePersons(Integer simNumber,String sponsorGroup,Timestamp arrivalDate)  throws SQLException{
		String sql = "select PERSON_ID from OSPA.WL$SIM_FLEXIBILITY" +
						" where SIM_ID=? AND sponsor_group=? and FLEXIBILITY is not null and FLEXIBILITY > 0" +
							"and PERSON_ID not in (select person_id from ospa.wl$absentee where"+ 
															" ? >= LEAVE_START_DATE and ? <= LEAVE_END_DATE)";
		PreparedStatement prest;
		Connection conn = null;
		List<String> persons = new ArrayList<String>();
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setString(2, sponsorGroup);
			prest.setTimestamp(3, arrivalDate);
			prest.setTimestamp(4, arrivalDate);
			ResultSet rs = prest.executeQuery();
			while(rs.next()){
				persons.add(rs.getString(1));
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return persons;
	}
	// Function to get the sponsor group
	// Input: Proposal Number and Activity Type
	// Output: Returns the Sponsor Group		
	public String getFellowshipSponsorGroup()  throws SQLException{
		String fellowshipSponsorCode = "999998";
		String sql = "select LEVEL1 from OSPA.OSP$SPONSOR_HIERARCHY where HIERARCHY_NAME='Workload Balancing' and sponsor_code=?";
				
		String sponsorGroup = null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, fellowshipSponsorCode);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				sponsorGroup = rs.getString("LEVEL1");
			}
		}finally{
			if(conn!=null){
				try {
					conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
					//UtilFactory.logMessage(e.getMessage(), e, "WLSimCurrentLoadTxn", "getSponsorGroup", FILE_NAME_PREFIX);
				}
				conn=null;
			}
		}
		return sponsorGroup;
	}
	
	public double getFlexibilityTotal(Integer simNumber,String personId)  throws SQLException{
		String sql = "select sum(FLEXIBILITY) from OSPA.WL$SIM_FLEXIBILITY where SIM_ID=? AND person_id=? " +
									"and FLEXIBILITY is not null and FLEXIBILITY > 0";
		PreparedStatement prest;
		Connection conn = null;
		Double sum_flexibility = 0.0;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setString(2, personId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				sum_flexibility = rs.getDouble(1);
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return sum_flexibility.doubleValue();
	}
	
	
	
	public int getCapacity(Integer simNumber,String oSPId)  throws SQLException{
		String sql = "select CAPACITY from OSPA.WL$SIM_CAPACITY where SIM_ID=? AND person_id=?";
		int capacity=-1;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setString(2, oSPId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				capacity = rs.getInt("CAPACITY");
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return capacity;
	}
	public String getOspAdmin(Integer simNumber,String unitId)  throws SQLException{
		String sql = "select PERSON_ID from OSPA.WL$SIM_UNIT_ASSIGNMENTS where SIM_ID=? AND unit_number=?";
		String ospAdmin=null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setString(2, unitId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				ospAdmin = rs.getString("PERSON_ID");
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return ospAdmin;
	}
	public List<WLCurrentLoadSimBean> getWorkloadList(Integer simNumber,Date simulationStartdate,Date simulationEndDate)  throws SQLException{
		String currentLoadTableName = getCurrentLoadtableName();
		String sql = "select a.ROUTING_NUMBER,a.PROPOSAL_NUMBER,a.ORIG_APPROVER," +
						"a.ORIG_USER_ID,a.PERSON_ID,a.USER_ID,a.SPONSOR_CODE,a.SPONSOR_GROUP," +
						"a.COMPLEXITY,a.LEAD_UNIT,a.ACTIVE_FLAG,a.ARRIVAL_DATE,a.INACTIVE_DATE," +
						"a.REROUTED_FLAG,a.ASSIGNED_BY,a.UPDATE_TIMESTAMP,a.UPDATE_USER," +
						"p.ACTIVITY_TYPE_CODE ACTIVITY_TYPE,b.person_id OSP_LEAD " +
					 " from "+currentLoadTableName+" a, ospa.osp$eps_proposal p,OSPA.WL$SIM_UNIT_ASSIGNMENTS b " +
					 "where a.proposal_number=p.proposal_number and " +
			  			"b.sim_id=? and a.lead_unit=b.unit_number and " +
			  			"trunc(ARRIVAL_DATE,'DDD') between trunc(?,'DDD') and trunc(?,'DDD') order by ARRIVAL_DATE";
		PreparedStatement prest;
		Connection conn = null;
		List<WLCurrentLoadSimBean> simBeanList = new ArrayList<WLCurrentLoadSimBean>();
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simNumber);
			prest.setDate(2, simulationStartdate);
			prest.setDate(3, simulationEndDate);
			ResultSet rs = prest.executeQuery();
			while(rs.next()){
				WLCurrentLoadSimBean simBean = new WLCurrentLoadSimBean();
				simBean.setRoutingNumber(rs.getString("ROUTING_NUMBER"));
				simBean.setProposalNumber(rs.getString("PROPOSAL_NUMBER"));
				simBean.setOriginalApproverPersonId(rs.getString("ORIG_APPROVER"));
				simBean.setOriginalApproverUserId(rs.getString("ORIG_USER_ID"));
				simBean.setWlAssignedPersonId(rs.getString("PERSON_ID"));
				simBean.setWlAssignedUserId(rs.getString("USER_ID"));
				simBean.setSponsorCode(rs.getString("SPONSOR_CODE"));
				simBean.setSponsorGroup(rs.getString("SPONSOR_GROUP"));
				simBean.setComplexity(rs.getDouble("COMPLEXITY"));
				simBean.setLeadUnit(rs.getString("LEAD_UNIT"));
				simBean.setOspLead(rs.getString("OSP_LEAD"));
				simBean.setActiveFlag(rs.getString("ACTIVE_FLAG"));
				simBean.setArrivalDate(rs.getTimestamp("ARRIVAL_DATE"));
				simBean.setInactiveDate(rs.getDate("INACTIVE_DATE"));
				simBean.setReroutedFlag(rs.getString("REROUTED_FLAG"));
				simBean.setAssignedBy(rs.getString("ASSIGNED_BY"));
				simBean.setUpdateTimestamp(rs.getDate("UPDATE_TIMESTAMP"));
				simBean.setUpdateUser(rs.getString("UPDATE_USER"));
				simBean.setActivityTypeCode(rs.getString("ACTIVITY_TYPE"));
				simBeanList.add(simBean);
			}
		}finally{
			if(conn!=null){
				if(conn!=null){
					connectionManager.close(conn);
				}
			}
		}
		return simBeanList;
	}
	private String getCurrentLoadtableName() {
		String simRunInstance = WLProperties.getProperty(WLPropertyKeys.SIM_RUN_INSTANCE);
		return simRunInstance.equals(WLPropertyKeys.SIM_RUN_INSTANCE_PROD)?"OSPA.wl$current_load":"OSPA.wl$prod_current_load";
	}
	public String getUserId(String approverId)  throws SQLException{
		String sql = "select USER_NAME from OSPA.OSP$PERSON where person_id=?";
		String userId=null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, approverId);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				userId = rs.getString("USER_NAME");
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return userId;
	}
	public void insertWlSimRecords(Integer simulationNumber,List<WLCurrentLoadSimBean> newWorkLoadList)  throws SQLException{
		String deleteSql = "delete from OSPA.wl$sim_current_load where SIM_ID=?";
		String sql = "insert into OSPA.wl$sim_current_load(" +
				"SIM_CURRENT_LOAD_ID,SIM_ID,ROUTING_NUMBER,PROPOSAL_NUMBER,POC_PERSON_ID,POC_USER_ID,"+ 
			    "APPROVER_PERSON_ID,APPROVER_USER_ID,SIM_PERSON_ID,SIM_USER_ID,SPONSOR_CODE,SPONSOR_GROUP,COMPLEXITY,LEAD_UNIT,"+ 
			    "ACTIVE_FLAG,ARRIVAL_DATE,INACTIVE_DATE,REROUTED_FLAG,ASSIGNED_BY,UPDATE_TIMESTAMP,UPDATE_USER)"+
				" values (SEQ_WL_SIM_CURR_LOAD_NUMBER.nextval,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		PreparedStatement prest;
		Connection conn = null;
		List<WLCurrentLoadSimBean> simBeanList = new ArrayList<WLCurrentLoadSimBean>();
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(deleteSql);
			prest.setInt(1, simulationNumber);
			prest.executeUpdate();
			prest = conn.prepareStatement(sql);
			for (WLCurrentLoadSimBean wlCurrentLoadSimBean : simBeanList) {
				prest.setInt(1, wlCurrentLoadSimBean.getSimId());
				prest.setString(2, wlCurrentLoadSimBean.getRoutingNumber());
				prest.setString(3, wlCurrentLoadSimBean.getProposalNumber());
				prest.setString(4, wlCurrentLoadSimBean.getOriginalApproverPersonId());
				prest.setString(5, wlCurrentLoadSimBean.getOriginalApproverUserId());
				prest.setString(6, wlCurrentLoadSimBean.getWlAssignedPersonId());
				prest.setString(7, wlCurrentLoadSimBean.getWlAssignedUserId());
				prest.setString(8, wlCurrentLoadSimBean.getSimulatedPersonId());
				prest.setString(9, wlCurrentLoadSimBean.getSimulatedUserId());
				prest.setString(10, wlCurrentLoadSimBean.getSponsorCode());
				prest.setString(11, wlCurrentLoadSimBean.getSponsorGroup());
				prest.setDouble(12, wlCurrentLoadSimBean.getComplexity());
				prest.setString(13, wlCurrentLoadSimBean.getLeadUnit());
				prest.setString(14, wlCurrentLoadSimBean.getActiveFlag());
				prest.setTimestamp(15, wlCurrentLoadSimBean.getArrivalDate());
				prest.setDate(16, wlCurrentLoadSimBean.getInactiveDate());
				prest.setString(17, wlCurrentLoadSimBean.getReroutedFlag());
				prest.setString(18, wlCurrentLoadSimBean.getAssignedBy());
				prest.setTimestamp(19, new Timestamp(wlCurrentLoadSimBean.getUpdateTimestamp().getTime()));
				prest.setString(20, wlCurrentLoadSimBean.getUpdateUser());
				prest.addBatch();
			}
			int[] count = prest.executeBatch();
			//UtilFactory.log("Number of rows inserted: "+count, FILE_NAME_PREFIX);
		} finally {
			if (conn != null) {
				if (conn != null) {
					connectionManager.close(conn);
				}
			}
		}

	}
	
	public void insertWlSimRecords(Integer simulationNumber,
			WLCurrentLoadSimBean wlCurrentLoadSimBean)  throws SQLException{
		String sql = "insert into OSPA.wl$sim_current_load(" +
				"SIM_CURRENT_LOAD_ID,SIM_ID,ROUTING_NUMBER,PROPOSAL_NUMBER,POC_PERSON_ID,POC_USER_ID,"+ 
			    "APPROVER_PERSON_ID,APPROVER_USER_ID,SIM_PERSON_ID,SIM_USER_ID,SPONSOR_CODE,SPONSOR_GROUP,COMPLEXITY,LEAD_UNIT,"+ 
			    "ACTIVE_FLAG,ARRIVAL_DATE,INACTIVE_DATE,REROUTED_FLAG,ASSIGNED_BY,UPDATE_TIMESTAMP,UPDATE_USER)"+
				" values (SEQ_WL_SIM_CURR_LOAD_NUMBER.nextval,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		PreparedStatement prest;
		Connection conn = null;
//		List<WLCurrentLoadSimBean> simBeanList = new ArrayList<WLCurrentLoadSimBean>();
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, wlCurrentLoadSimBean.getSimId());
			prest.setString(2, wlCurrentLoadSimBean.getRoutingNumber());
			prest.setString(3, wlCurrentLoadSimBean.getProposalNumber());
			prest.setString(4, wlCurrentLoadSimBean.getOriginalApproverPersonId());
			prest.setString(5, wlCurrentLoadSimBean.getOriginalApproverUserId());
			prest.setString(6, wlCurrentLoadSimBean.getWlAssignedPersonId());
			prest.setString(7, wlCurrentLoadSimBean.getWlAssignedUserId());
			prest.setString(8, wlCurrentLoadSimBean.getSimulatedPersonId());
			prest.setString(9, wlCurrentLoadSimBean.getSimulatedUserId());
			prest.setString(10, wlCurrentLoadSimBean.getSponsorCode());
			prest.setString(11, wlCurrentLoadSimBean.getSponsorGroup());
			prest.setDouble(12, wlCurrentLoadSimBean.getComplexity());
			prest.setString(13, wlCurrentLoadSimBean.getLeadUnit());
			prest.setString(14, wlCurrentLoadSimBean.getActiveFlag());
			prest.setTimestamp(15, wlCurrentLoadSimBean.getArrivalDate());
			prest.setDate(16, wlCurrentLoadSimBean.getInactiveDate());
			prest.setString(17, wlCurrentLoadSimBean.getReroutedFlag());
			prest.setString(18, wlCurrentLoadSimBean.getAssignedBy());
			prest.setTimestamp(19, new Timestamp(wlCurrentLoadSimBean.getUpdateTimestamp().getTime()));
			prest.setString(20, wlCurrentLoadSimBean.getUpdateUser());
			prest.executeUpdate();
		} finally {
			if (conn != null) {
				if (conn != null) {
					connectionManager.close(conn);
				}
			}
		}
	}
	public void deleteSimRecords(Integer simulationNumber)  throws SQLException{
		String deleteSql = "delete from OSPA.wl$sim_current_load where SIM_ID=?";
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(deleteSql);
			prest.setInt(1, simulationNumber);
			prest.executeUpdate();
		} finally {
			if (conn != null) {
				if (conn != null) {
					connectionManager.close(conn);
				}
			}
		}
	}
	public void distroyConnection() {
		connectionManager.distroyConnection();
	}
	public WLCurrentLoadSimBean getPreviousRoutedBean(
			WLCurrentLoadSimBean wlCurrentLoadSimBean)  throws SQLException{
		
		String sql = "select SIM_PERSON_ID,SIM_USER_ID from ospa.wl$sim_current_load where sim_id=? and " +
						"proposal_number=? and routing_number<? order by routing_number";
		String userId=null;
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, wlCurrentLoadSimBean.getSimId());
			prest.setString(2, wlCurrentLoadSimBean.getProposalNumber());
			prest.setString(3, wlCurrentLoadSimBean.getRoutingNumber());
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				wlCurrentLoadSimBean.setSimulatedPersonId(rs.getString("SIM_PERSON_ID"));
				wlCurrentLoadSimBean.setSimulatedUserId(rs.getString("SIM_USER_ID"));
			}else{
				return null;
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return wlCurrentLoadSimBean;
	}
	public boolean isAbsent(String personId,Timestamp arrivalDate) throws SQLException{
		String sql = "select count(*) absent_count from OSPA.WL$ABSENTEE where person_id=? and ? >= LEAVE_START_DATE and ? <= LEAVE_END_DATE";
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setString(1, personId);
			prest.setTimestamp(2, arrivalDate);
			prest.setTimestamp(3, arrivalDate);
			ResultSet rs = prest.executeQuery();
			if(rs.next()){
				String absent = rs.getString(1);
				if(absent!=null && Integer.parseInt(absent)>0){
					return true;
				}else{
					return false;
				}
			}
		}finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return false;
	}
	public List<String> getAllOspPeople(Integer simId)  throws SQLException{
		String sql = "select PERSON_ID from OSPA.WL$SIM_CAPACITY where sim_id=? and capacity>0";
		List<String> personIds = new ArrayList<String>();
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(sql);
			prest.setInt(1, simId);
			ResultSet rs = prest.executeQuery();
			while(rs.next()){
				personIds.add(rs.getString("PERSON_ID"));
			}
		} finally{
			if(conn!=null){
				connectionManager.close(conn);
			}
		}
		return personIds;
	}
	public void beginSimulation(Integer simulationNumber, Date simulationStartDate, Date simulationEndDate)  throws SQLException{
		String updateSql = "update OSPA.wl$sim_header set UPDATE_USER=user,UPDATE_TIMESTAMP=sysdate," +
				"SIM_RUN_STATUS_CODE=?,SIM_START_DATE=?,SIM_END_DATE=? where SIM_ID=?";
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(updateSql);
			prest.setString(1,"2");
			prest.setDate(2,simulationStartDate);
			prest.setDate(3,simulationEndDate);
			prest.setInt(4,simulationNumber);
			prest.executeUpdate();
		} finally {
			if (conn != null) {
				if (conn != null) {
					connectionManager.close(conn);
				}
			}
		}
	}
	public void endSimulation(Integer simulationNumber)  throws SQLException{
		String updateSql = "update OSPA.wl$sim_header set UPDATE_USER=user,UPDATE_TIMESTAMP=sysdate,SIM_RUN_STATUS_CODE=? where SIM_ID=?";
		updateSimHeader(updateSql,"3",simulationNumber);
	}
	private void updateSimHeader(String updateSql,String statusCode, Integer simulationNumber)  throws SQLException{
		PreparedStatement prest;
		Connection conn = null;
		try {
			conn = connectionManager.getConnection();
			prest = conn.prepareStatement(updateSql);
			prest.setString(1,statusCode);
			prest.setInt(2,simulationNumber);
			prest.executeUpdate();
		} finally {
			if (conn != null) {
				if (conn != null) {
					connectionManager.close(conn);
				}
			}
		}
		
	}
}
