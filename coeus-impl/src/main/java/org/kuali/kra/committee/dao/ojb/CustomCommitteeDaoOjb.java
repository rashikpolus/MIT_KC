package org.kuali.kra.committee.dao.ojb;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

import org.apache.ojb.broker.PersistenceBroker;
import org.apache.ojb.broker.accesslayer.LookupException;
import org.kuali.coeus.common.committee.impl.bo.CommitteeBase;
import org.kuali.coeus.common.committee.impl.bo.CommitteeScheduleBase;
import org.kuali.kra.committee.dao.CustomCommitteeDao;
import org.kuali.rice.core.framework.persistence.ojb.dao.PlatformAwareDaoBaseOjb;
import org.kuali.rice.kew.api.WorkflowRuntimeException;
import org.kuali.rice.krad.util.ObjectUtils;
import org.springmodules.orm.ojb.OjbFactoryUtils;

public class CustomCommitteeDaoOjb extends PlatformAwareDaoBaseOjb  implements CustomCommitteeDao {
	private static final org.apache.log4j.Logger LOG = org.apache.log4j.Logger.getLogger(CustomCommitteeDaoOjb.class); 

	@SuppressWarnings("rawtypes") 
	public void updateSubmissionsToNewCommitteeVersion(CommitteeBase committee, List<? extends CommitteeScheduleBase> schedules) { 
	if (ObjectUtils.isNull(committee)) { 
	throw new IllegalArgumentException("Committee may not be null"); 
	} 

	PersistenceBroker broker = null; 
	        Connection conn = null; 
	        PreparedStatement stmt = null; 
	        try { 
	            broker = getPersistenceBroker(false); 
	            conn = broker.serviceConnectionManager().getConnection(); 
	             
	            String query = "UPDATE protocol_submission SET committee_id_fk = ? where committee_id = ?"; 
	             
	            stmt = conn.prepareStatement(query); 
	            stmt.setLong(1, committee.getId()); 
	            stmt.setString(2, committee.getCommitteeId()); 
	            stmt.executeUpdate(); 
	             
	            query = "UPDATE protocol_submission SET schedule_id_fk = ? where schedule_id = ?"; 
	            stmt = conn.prepareStatement(query); 
	             
	            for(Object schedObj : committee.getCommitteeSchedules()) { 
	            	CommitteeScheduleBase schedule = (CommitteeScheduleBase) schedObj; 
	            	stmt.setLong(1, schedule.getId()); 
	            	stmt.setString(2, schedule.getScheduleId()); 
	            	stmt.addBatch(); 
	            } 
	             
	            stmt.executeBatch(); 
	             
	        } catch (SQLException sqle) { 
	            LOG.error("SQLException: " + sqle.getMessage(), sqle); 
	            throw new WorkflowRuntimeException(sqle); 
	        } catch (LookupException le) { 
	            LOG.error("LookupException: " + le.getMessage(), le); 
	            throw new WorkflowRuntimeException(le); 
	        } finally { 
	            try { 
	            	if(stmt != null) { 
	            	 stmt.close(); 
	            	} 
	                if (broker != null) { 
	                    OjbFactoryUtils.releasePersistenceBroker(broker, this.getPersistenceBrokerTemplate().getPbKey()); 
	                } 
	            } catch (Exception e) { 
	                LOG.error("Failed closing connection: " + e.getMessage(), e); 
	            } 
	        } 

	} 

}
