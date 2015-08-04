package org.kuali.coeus.propdev.impl.proposalperson;



import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.sql.DataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jacorb.idl.runtime.char_token;
import org.kuali.coeus.common.dbfunctionmanager.DbFunctionExecuteService;
import org.kuali.coeus.common.impl.krms.StoredFunctionDao;
import org.kuali.coeus.propdev.proposalperson.CoiDbFunctionService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.coreservice.api.parameter.Parameter;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

public class CoiDbFunctionServiceImpl implements CoiDbFunctionService{
	
	protected final Log LOG = LogFactory.getLog(CoiDbFunctionServiceImpl.class);
	Logger LOGGER;

	private DbFunctionExecuteService dbFunctionExecuteService;
	private ParameterService parameterService;

	protected static final String KC_COI_DB_LINK = "KC_COI_DB_LINK"; 
	protected static final String KC_GENERAL_NAMESPACE = "KC-GEN";
	protected static final String DOCUMENT_COMPONENT_NAME = "Document";

	public CoiDbFunctionServiceImpl() {
		super();
		LOGGER = Logger.getLogger(CoiDbFunctionServiceImpl.class.getName());
	}

	public ParameterService getParameterService() {
		return parameterService;
	}

	public void setParameterService(ParameterService parameterService) {
		this.parameterService = parameterService;
	}

	public DbFunctionExecuteService getDbFunctionExecuteService() {
		if (dbFunctionExecuteService == null) {
			dbFunctionExecuteService = KcServiceLocator.getService(DbFunctionExecuteService.class);
		}

		return dbFunctionExecuteService;
	}

	public void setDbFunctionExecuteService(
			DbFunctionExecuteService dbFunctionExecuteService) {
		this.dbFunctionExecuteService = dbFunctionExecuteService;
	}

	protected String getDBLink() {
	
		try {
			Parameter parm = this.getParameterService().getParameter(KC_GENERAL_NAMESPACE, DOCUMENT_COMPONENT_NAME,KC_COI_DB_LINK);
			
			if (!parm.getValue().isEmpty()) {
				return '@' + parm.getValue();
			}
			
		

		} catch (NullPointerException e) {
			LOGGER.log(Level.ALL, e.getMessage(), e);
			LOGGER.log(Level.ALL,
					"DBLINK is not accessible or the parameter value returning null");
		} 

		return "";
	}

		
	/**
	 * @description:		 For retrieving coi disclosure status of each person added to the development proposal
	 * @function FN_PROP_PERSON_COI_STATUS
	 * @param   	PROPOSAL_NUMBER
	 * 				PERSON-ID
	 * @referenced PL/SQL function fn_check_prop_event_sub_to_coi
	 */
	public String getKeyPersonnelCoiDisclosureStatus(String developmentProposalNumber,String keyPersonId,boolean isQuestionnairesCompleted){
	
		
		List<Object> paramValues = new ArrayList<Object>();
		String status = "";
		
		paramValues.add(0, developmentProposalNumber);
		paramValues.add(1, keyPersonId);
		paramValues.add(2,isQuestionnairesCompleted == true ?1:0);
		
		try {
			status =  getDbFunctionExecuteService().executeFunction("fn_prop_person_coi_status"+this.getDBLink(),paramValues);
		} catch (Exception ex) {
			LOGGER.log(Level.INFO, "Got exception:" + ex.getMessage());
			LOGGER.log(Level.ALL, ex.getMessage(), ex);
			LOG.error("fn_check_prop_event_sub_to_coi throws exception", ex);
		} finally {
			try {
				if (!status.isEmpty()) {
					LOGGER.log(Level.INFO, "Function Successfully Invoked");
			
				}
			} catch (Exception e) {
				LOGGER.log(Level.ALL, e.getMessage(), e);
			}
		}
		return status;
	
	}
	
	
	/**
	 * @description:		 For checking coi disclosure is submitted
	 * @function FN_check_disc_done_rule
	 * @param   	PROPOSAL_NUMBER
	 * @referenced PL/SQL function FN_check_disc_done_rule
	 */
	public boolean isCoiDisclosureSubmitted(String developmentProposalNumber){
		
		List<Object> paramValues = new ArrayList<Object>();
		String result = "";	
    	Integer newResult=0;
		paramValues.add(0, developmentProposalNumber);
		try {
			result =  getDbFunctionExecuteService().executeFunction("FN_check_disc_done_rule"+this.getDBLink(),paramValues);
		} catch (Exception ex) {
			LOGGER.log(Level.INFO, "Got exception:" + ex.getMessage());
			LOGGER.log(Level.ALL, ex.getMessage(), ex);
			LOG.error("FN_check_disc_done_rule throws exception", ex);
		} finally {
			try {
				if (!result.isEmpty()) {
					LOGGER.log(Level.INFO, "Function Successfully Invoked");
			
				}
			} catch (Exception e) {
				LOGGER.log(Level.ALL, e.getMessage(), e);
			}
		}
		if(result.equals("")){
    		return false;
    	}
    	if(result!=null){
    		newResult=Integer.parseInt(result);}
    	if (newResult ==-1 ) {
    		return false;
    	}else
    	{
    		return true;
    	}
	}
	
}
