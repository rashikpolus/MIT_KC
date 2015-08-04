/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.mit.kc.citi;

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
import org.kuali.rice.coreservice.framework.parameter.ParameterService;
import org.kuali.rice.ken.service.NotificationService;
import org.kuali.rice.krad.service.BusinessObjectService;

import com.ibm.icu.util.Calendar;

import edu.mit.kc.common.DbFunctionExecuteService;
 
/**
 *
 * @author geot
 */
public class CitiTrainingDataFeedServiceImpl implements CitiTrainingDataFeedService {

    private static final String CITI_URL = "https://www.citiprogram.org/members/institutionaladministrators/transcriptdownload.asp?data=downloadall&ID=24927EC3-C6A7-4787-AB99-CB77A41CF86C&category=0";
    protected final Log LOG = LogFactory.getLog(CitiTrainingDataFeedServiceImpl.class);
    private BusinessObjectService businessObjectService;
    private KcNotificationService kcNotificationService;
    private ParameterService parameterService;
    private DbFunctionExecuteService dbFunctionExecuteService;
    public BusinessObjectService getBusinessObjectService() {
		return businessObjectService;
	}

	public void setBusinessObjectService(BusinessObjectService businessObjectService) {
		this.businessObjectService = businessObjectService;
	}
	@Override
	public void parseAndUpdateCiti() {
		parse();
		dbFunctionExecuteService.executeFunction("kc_package_citi", "fn_populate_pers_training", new ArrayList<Object>());
	}
	
	public void parse() {
        int firstName=0, lastName=0, email=0, curriculum=0, group=0, score=0, passingScore=0, stageNumber=0, stage=0, dateCompleted=0,
        institutionalUsername=0, customField1=0, customField2=0;
        Logger logger = Logger.getLogger(CitiTrainingDataFeedServiceImpl.class.getName());
        BufferedReader citiContentInputBuffer = null;
        try {
            URL citiurl = new URL(CITI_URL);
            citiContentInputBuffer = new BufferedReader(new InputStreamReader(citiurl.openStream()));
            String inputLine;
            int lineIndex = 0;
            List<CitiTraining> citiTrainings = new ArrayList<CitiTraining>();
            Timestamp updateTimestamp = new Timestamp(Calendar.getInstance().getTimeInMillis());
            while ((inputLine = citiContentInputBuffer.readLine()) != null) {
                if (lineIndex == 0) {
                    String headerLine = inputLine;
                    String[] headerWords = headerLine.split("\t");
                    for (int i = 0; i < headerWords.length; i++) {
                        String string = headerWords[i];
                        if (string.equals("First Name")) {
                            firstName = i;
                        } else if (string.equals("Last Name")) {
                            lastName = i;
                        } else if (string.equals("Email")) {
                            email = i;
                        } else if (string.equals("Curriculum")) {
                            curriculum = i;
                        } else if (string.equals("Group")) {
                            group = i;
                        } else if (string.equals("Score")) {
                            score = i;
                        } else if (string.equals("Stage Number")) {
                            stageNumber = i;
                        } else if (string.equals("Passing score")) {
                            passingScore = i;
                        } else if (string.equals("Stage")) {
                            stage = i;
                        } else if (string.equals("Date Completed")) {
                            dateCompleted = i;
                        } else if (string.equals("Institutional Username")) {
                            institutionalUsername = i;
                        } else if (string.equals("Custom Field 1")) {
                            customField1 = i;
                        } else if (string.equals("Custom Field 2")) {
                            customField2 = i;
                        }
                    }
                } else { 
                	CitiTraining citiTraining = new CitiTraining();
                    String[] words = new String[13]; 
                    String[] tempWords = inputLine.split("\t");
                	try{
	                    for (int i = 0; i < tempWords.length; i++) {
							words[i] = tempWords[i];
						}
	                    citiTraining.setFirstName(words[firstName]);
	                    citiTraining.setLastName(words[lastName]);
	                    citiTraining.setEmail(words[email]);
	                    citiTraining.setCurriculum(words[curriculum]);
	                    citiTraining.setTrainingGroup(words[group]);
	                    citiTraining.setScore(words[score]);
	                    citiTraining.setStageNumber(words[stageNumber]);
	                    citiTraining.setPassingScore(words[passingScore]);
	                    citiTraining.setStage(words[stage]);
	                    citiTraining.setDateCompleted(convertDate(words[dateCompleted]));
	                    citiTraining.setUserName(words[institutionalUsername]);
	                    citiTraining.setCustomField1(words[customField1]);
	                    citiTraining.setCustomField2(words[customField2]);
	                    citiTraining.setUserName(words[institutionalUsername]);
	                    citiTraining.setUpdateTimestamp(updateTimestamp);
	                    citiTrainings.add(citiTraining);
	                    
                	}catch(Exception ex){
                		String erroredRec = "Errored out record#"+lineIndex+":";
                    	for (int j = 0; j < tempWords.length; j++) {
                    		erroredRec += tempWords[j];
                    		erroredRec += ",";
						}
                    	sendCitiNotification(erroredRec);
                    	logger.log(Level.INFO, erroredRec);
                	}
                }
                lineIndex++;
            }
            List<CitiTraining> currentCitiList = (List<CitiTraining>) businessObjectService.findAll(CitiTraining.class);
            businessObjectService.delete(currentCitiList);
            businessObjectService.save(citiTrainings);
        } catch (Exception ex) {
            logger.log(Level.INFO, "Got exception:"+ex.getMessage());
            logger.log(Level.ALL, ex.getMessage(), ex);
        } finally {
            try {
                if (citiContentInputBuffer != null) {
                    citiContentInputBuffer.close();
                }
            } catch (IOException e) {
            	logger.log(Level.ALL, e.getMessage(), e);
			}
        }
    }

	private void sendCitiNotification(String erroredRec) {
		NotificationType citiNotificationType = kcNotificationService.getNotificationType("101", "501");
		List<NotificationTypeRecipient> recipients = citiNotificationType.getNotificationTypeRecipients();
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
		kcNotificationService.sendNotification("Citi daily dataload notification context", 
					citiNotificationType.getSubject(), 
					citiNotificationType.getMessage()+" "+erroredRec, recps);
		
	}

    private Timestamp convertDate(String dateCompletedValue) {
    	Timestamp convertedDate =  convertDate(dateCompletedValue,"MM/dd/yyyy");
    	return convertedDate==null?convertDate(dateCompletedValue,"dd/MM/yyyy"):convertedDate;
    }
    private Timestamp convertDate(String dateCompletedValue,String formatString) {
        SimpleDateFormat sdf = new SimpleDateFormat(formatString);
        try {
            return new Timestamp(sdf.parse(dateCompletedValue).getTime());
        } catch (ParseException ex) {
            Logger.getLogger(CitiTrainingDataFeedServiceImpl.class.getName()).log(Level.WARNING, null, ex);
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
