/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package citi;

//import java.io.BufferedReader;
//import java.io.IOException;
//import java.io.InputStreamReader;
//import java.net.MalformedURLException;
import java.net.URL;
import java.io.*;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;
 
/**
 *
 * @author ele
 */
//public class Main {
public class GetCitiContent {

    int firstName, lastName, email, curriculum, group, score, passingScore, stageNumber, stage, dateCompleted,
            institutionalUsername, customField1, customField2;
    String str, userid, pw, db;

    private void parseAndUpdateCiti() {

        //read property file for oracle connection
        Logger logger = Logger.getLogger(GetCitiContent.class.getName());
        Connection conn = null;
        PreparedStatement stmt = null;
        try {

            boolean append = true;
            FileHandler handler = new FileHandler("/home/coeus/citi/citi.log", append);
            handler.setFormatter(new SimpleFormatter());

            // Add to the desired logger

            logger.addHandler(handler);
            logger.log(Level.INFO, "starting GetCitiContent.java");

     //       logger.log(Level.INFO, "before reading id");
             //BufferedReader propfile = new BufferedReader(new FileReader("c:/MITOnly/Citi/id.txt"));
            BufferedReader propfile = new BufferedReader(new FileReader("/home/coeus/ospauser/id"));
     //       logger.log(Level.INFO, "after reading id");

            String temp[];
            String temp2[];
    //        logger.log(Level.INFO, "propfile == null ? "+(propfile==null));

            while ((str = propfile.readLine()) != null) {
                if(str.trim().length() == 0) break;
    //            logger.log(Level.INFO, str);
                //str has this format user/pw@dbinstance
                temp = str.split("/");
                userid = temp[0];
                temp2 = temp[1].split("@");
                pw = temp2[0];
                db = temp2[1];
            }
    //        logger.log(Level.INFO, "before propfile close");
            propfile.close();

            URL citiurl = new URL("https://www.citiprogram.org/members/institutionaladministrators/transcriptdownload.asp?data=downloadall&ID=24927EC3-C6A7-4787-AB99-CB77A41CF86C&category=0");
          
            BufferedReader in = new BufferedReader(new InputStreamReader(citiurl.openStream()));
            String inputLine;
            int lineIndex = 0;
            
            

            // connect to oracle

            Class.forName("oracle.jdbc.driver.OracleDriver");

            //get connection string from file

           //conn = DriverManager.getConnection("jdbc:oracle:oci8:@coeusqa", "ospa", "ctqaso");
           conn = DriverManager.getConnection("jdbc:oracle:oci8:@" + db, userid, pw);
           //  logger.log(Level.INFO, "got database connection");

            //delete all from citi_training table

            Statement deleteStmt = conn.createStatement();

            String sql = "DELETE FROM CITI_TRAINING";
            deleteStmt.executeUpdate(sql);

        //    logger.log(Level.INFO, "after delete ");

            String insertString = "insert into CITI_TRAINING(FIRST_NAME,LAST_NAME,EMAIL,CURRICULUM,TRAINING_GROUP,SCORE,PASSING_SCORE,"
                    + "STAGE_NUMBER, STAGE, DATE_COMPLETED,USER_NAME,CUSTOM_FIELD1,CUSTOM_FIELD2,UPDATE_TIMESTAMP) values(?, ?, ?,?,?, ?, ?,?,?, ?, ?,?,?,?)";

            stmt = conn.prepareStatement(insertString);

            while ((inputLine = in.readLine()) != null) {
                //System.out.println(inputLine);
                if (lineIndex == 0) {
                    //header line
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
                } else {  //content line
                    String[] words = new String[13]; 
                    String[] tempWords = inputLine.split("\t");
                	try{
	                    for (int i = 0; i < tempWords.length; i++) {
							words[i] = tempWords[i];
						}
	                	String firstNameValue = words[firstName];
	                	String lastNameValue = words[lastName];
	                	String emailValue = words[email];
	                	String curriculumValue = words[curriculum];
	                    String groupValue = words[group];
	                    String scoreValue = words[score];
	                    String stageNumberValue = words[stageNumber];
	                    String passingScoreValue = words[passingScore];
	                    String stageValue = words[stage];
	                    String dateCompletedValue = words[dateCompleted];
	                    String institutionalUsernameValue = words[institutionalUsername];
	                    String customField1Value = words[customField1];
	                    String customField2Value = words[customField2];
	                    //       System.out.println(firstNameValue);
	
	                    // insert into table
	
	                    stmt.setString(1, firstNameValue);
	                    stmt.setString(2, lastNameValue);
	                    stmt.setString(3, emailValue);
	                    stmt.setString(4, curriculumValue);
	                    stmt.setString(5, groupValue);
	                    stmt.setString(6, scoreValue);
	                    stmt.setString(7, passingScoreValue);
	                    stmt.setString(8, stageNumberValue);
	                    stmt.setString(9, stageValue);
	                    stmt.setTimestamp(10, convertDate(dateCompletedValue));
	                    stmt.setString(11, institutionalUsernameValue);
	                    stmt.setString(12, customField1Value);
	                    stmt.setString(13, customField2Value);
	                    stmt.setTimestamp(14, new Timestamp(System.currentTimeMillis()));
	                    stmt.executeUpdate();
                	}catch(Exception ex){
//                		System.out.print("Errored out record#"+lineIndex+":");
                		String erroredRec = "Errored out record#"+lineIndex+":";
                    	for (int j = 0; j < tempWords.length; j++) {
                    		erroredRec += tempWords[j];
                    		erroredRec += ",";
//							System.out.print(tempWords[j]);
//							System.out.print(",");
						}
                    	logger.log(Level.INFO, erroredRec);
//                    	System.out.println();
                	}
                }
                lineIndex++;

            }
     //       logger.log(Level.INFO, "Line Index: "+lineIndex);
            conn.commit();
 
            in.close();

        } catch (Exception ex) {
            logger.log(Level.INFO, "Got exception:"+ex.getMessage());
            logger.log(Level.ALL, ex.getMessage(), ex);
        } finally {
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException ex) {
                logger.log(Level.ALL, ex.getMessage(), ex);
            }
        }
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception {

       new GetCitiContent().parseAndUpdateCiti();
       // System.out.println(new GetCitiContent().convertDate( "8/12/2010 12:51:43 PM"));


    }

    private Timestamp convertDate(String dateCompletedValue) {
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss a");
        try {
            return new Timestamp(sdf.parse(dateCompletedValue).getTime());
        } catch (ParseException ex) {
            Logger.getLogger(GetCitiContent.class.getName()).log(Level.SEVERE, null, ex);
            return null;
        }
    }
}
