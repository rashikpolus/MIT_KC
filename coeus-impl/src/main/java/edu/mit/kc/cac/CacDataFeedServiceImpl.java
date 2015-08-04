/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.mit.kc.cac;

import java.net.URL;
import java.io.*;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.kuali.coeus.common.notification.impl.bo.NotificationType;
import org.kuali.coeus.common.notification.impl.bo.NotificationTypeRecipient;
import org.kuali.coeus.common.notification.impl.service.KcNotificationService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.CoreApiServiceLocator;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.ken.service.NotificationService;
import org.kuali.rice.krad.service.BusinessObjectService;

import com.ibm.icu.util.Calendar;

import edu.mit.kc.common.DbFunctionExecuteService;
 

public class CacDataFeedServiceImpl implements CacDataFeedService {

    //private static final String CITI_URL = "https://www.citiprogram.org/members/institutionaladministrators/transcriptdownload.asp?data=downloadall&ID=24927EC3-C6A7-4787-AB99-CB77A41CF86C&category=0";
    protected final Log LOG = LogFactory.getLog(CacDataFeedServiceImpl.class);
    private BusinessObjectService businessObjectService;
    private KcNotificationService kcNotificationService;
    private ParameterService parameterService;
    private DbFunctionExecuteService dbFunctionExecuteService;
    private ConfigurationService configurationService;
    //private String erroredRec;
    
    public BusinessObjectService getBusinessObjectService() {
		return businessObjectService;
	}

	public void setBusinessObjectService(BusinessObjectService businessObjectService) {
		this.businessObjectService = businessObjectService;
	}
	@Override
	public void parseAndUpdateCac() {
		parse();
		//dbFunctionExecuteService = KcServiceLocator.getService(DbFunctionExecuteService.class);
		dbFunctionExecuteService.executeFunction("kc_cac_feed_pkg", "fn_cacapp", new ArrayList<Object>());
		//sendCacNotification(erroredRec);
	}
	
	public void parse() {
        Logger logger = Logger.getLogger(CacDataFeedServiceImpl.class.getName());
        BufferedReader cacContentInputBuffer = null;
        try {
        	ConfigurationService configurationService = CoreApiServiceLocator.getKualiConfigurationService();
        	String loadFile = configurationService.getPropertyValueAsString("CAC.FILE");
        	System.out.println(loadFile );
        	cacContentInputBuffer = new BufferedReader(new FileReader(loadFile));
            //cacContentInputBuffer = new BufferedReader(new InputStreamReader(citiurl.openStream()));
            String inputLine;
            int lineIndex = 0;
            String[] words = null;
            List<Cac> cacs = new ArrayList<Cac>();
            Timestamp updateTimestamp = new Timestamp(Calendar.getInstance().getTimeInMillis());
            while ((inputLine = cacContentInputBuffer.readLine()) != null) {
            	try{
                	Cac cac = new Cac();
                	words = inputLine.split("\t", 30);
	                cac.setApprovalDate(words[0]);
	                cac.setContactEmail(words[1]);
	                cac.setDept(words[2]);
	                cac.setExpirationDate(words[3]);
	                cac.setFundingAgency(words[4]);
	                cac.setFundingAgency2(words[5]);
	                cac.setFundingAgency3(words[6]);
	                cac.setFundingAgency4(words[7]);
	                cac.setFundingAgency5(words[8]);
	                cac.setFundingAgency6(words[9]);
	                cac.setGrantNumber(words[10]);
	                cac.setGrantNumber2(words[11]);
	                cac.setGrantNumber3(words[12]);
	                cac.setGrantNumber4(words[13]);
	                cac.setGrantNumber5(words[14]);
	                cac.setGrantNumber6(words[15]);
	                cac.setPiEmail(words[16]);
	                cac.setPiFirstName(words[17]);
	                cac.setPiLastName(words[18]);
	                cac.setPreviousProtocolNumber(words[19]);
	                cac.setProposalType(words[20]);
	                cac.setProtocolNumber(words[21]);
	                cac.setReviewLevel(words[22]);
	                cac.setSubmissionDate(words[23]);
	                cac.setWbsIp1(words[24]);
	                cac.setWbsIp2(words[25]);
	                cac.setWbsIp3(words[26]);
	                cac.setWbsIp4(words[27]);
	                cac.setWbsIp5(words[28]);
	                cac.setWbsIp6(words[29]);
	                cacs.add(cac);
                	}catch(Exception ex){
                		String erroredRec = "Errored out record#"+lineIndex+":";
                		//erroredRec = "Errored out record#"+lineIndex+":";
                    	for (int j = 0; j < words.length; j++) {
                    		erroredRec += words[j];
                    		erroredRec += ",";
						}
                		//erroredRec = words[];
                    	sendCacNotification(erroredRec);
                    	logger.log(Level.INFO, erroredRec);
                	}
               // }
                lineIndex++;
           }
            //businessObjectService =  KcServiceLocator.getService(BusinessObjectService.class);
            List<Cac> currentCacList = (List<Cac>) businessObjectService.findAll(Cac.class);
            businessObjectService.delete(currentCacList);
            businessObjectService.save(cacs);
        } catch (Exception ex) {
        	ex.printStackTrace();
            logger.log(Level.INFO, "Got exception:"+ex.getMessage());
            logger.log(Level.ALL, ex.getMessage(), ex);
        } finally {
            try {
                if (cacContentInputBuffer != null) {
                    cacContentInputBuffer.close();
                }
            } catch (IOException e) {
            	logger.log(Level.ALL, e.getMessage(), e);
			}
        } 
	}

    

	private void sendCacNotification(String erroredRec) {
		//kcNotificationService = KcServiceLocator.getService(KcNotificationService.class);
		NotificationType cacNotificationType = kcNotificationService.getNotificationType("200", "504"); 
		List<NotificationTypeRecipient> recipients = cacNotificationType.getNotificationTypeRecipients();
		List<String> recps = new ArrayList<String>();
		for (NotificationTypeRecipient notificationTypeRecipient : recipients) {
			recps.add(notificationTypeRecipient.getPersonId());
		}
//		NotificationContext citiNotifContext = new NotificationContextBase(new NotificationRenderer() {
//			@Override
//			public String render(String text) {
//				return text;
//			}
//			
//			@Override
//			public Map<String, String> getDefaultReplacementParameters() {
//				return null;
//			}
//		}) {
//			
//			@Override
//			public String getModuleCode() {
//				return "101";
//			}
//			
//			@Override
//			public List<EmailAttachment> getEmailAttachments() {
//				return null;
//			}
//			
//			@Override
//			public String getDocumentNumber() {
//				return null;
//			}
//			
//			@Override
//			public String getContextName() {
//				return "Citi daily dataload notification context";
//			}
//			
//			@Override
//			public String getActionTypeCode() {
//				return "501";
//			}
//		};
		kcNotificationService.sendNotification("Cac daily dataload notification context", 
					cacNotificationType.getSubject(), 
					cacNotificationType.getMessage()+" "+erroredRec, recps);
		
	}

    private Timestamp convertDate(String dateCompletedValue) {
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
        try {
            return new Timestamp(sdf.parse(dateCompletedValue).getTime());
        } catch (ParseException ex) {
            Logger.getLogger(CacDataFeedServiceImpl.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }

	public KcNotificationService getKcNotificationService() {
		return kcNotificationService;
	}

	public void setKcNotificationService(KcNotificationService kcNotificationService) {
		this.kcNotificationService = kcNotificationService;
	}

	public ParameterService getParameterService() {
		return parameterService;
	}

	public void setParameterService(ParameterService parameterService) {
		this.parameterService = parameterService;
	}

	public DbFunctionExecuteService getDbFunctionExecuteService() {
		return dbFunctionExecuteService;
	}

	public void setDbFunctionExecuteService(DbFunctionExecuteService dbFunctionExecuteService) {
		this.dbFunctionExecuteService = dbFunctionExecuteService;
	}

}
