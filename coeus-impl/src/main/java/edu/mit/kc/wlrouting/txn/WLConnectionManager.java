package edu.mit.kc.wlrouting.txn;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

import edu.mit.kc.wlrouting.WLProperties;
import edu.mit.kc.wlrouting.WLPropertyKeys;

public class WLConnectionManager {
	static private WLConnectionManager instance;
	private static Connection connection;
	static private DataSource ds ;
	private static final String dbString = "jdbc:oracle:thin:@(description=(address=(host=coeus-traindb.mit.edu)(protocol=tcp)(port=1521))(connect_data=( SERVICE_NAME = COEUSQA.Coeus-TrainDB.mit.edu)(server=DEDICATED)))";
	private static final String userid = "ergfdhfgdh";
	private static final String pwd = "nataly";
//	private static final String dbString = "jdbc:oracle:thin:@(description=(address=(host=osp-award.mit.edu)(protocol=tcp)(port=1521))(connect_data=(SID=OSPA)(server=DEDICATED)))";
//	private static final String userid = "ospa";
//	private static final String pwd = "sadsfadsfads";

	public static synchronized WLConnectionManager getInstance(){
		if (instance == null) {
            instance = new WLConnectionManager();
        }
        return instance;
	}
	
	private WLConnectionManager(){
		try{
			String connectionMode = WLProperties.getProperty(WLPropertyKeys.CONNECTION_MODE);
			if(connectionMode.equals("DATASOURCE")){
				String jndiName = WLProperties.getProperty(WLPropertyKeys.DS_JNDI_NAME);            
	            Properties p = new Properties();
	            Context envContext;
	            Context initContext = new InitialContext();
	            envContext  = (Context)initContext.lookup("java:comp/env");
	            ds = (DataSource)envContext.lookup(jndiName);
			}
        }catch(Exception e) {
           e.printStackTrace();
        }
	}
	public Connection getConnection() throws SQLException{
		String connectionMode = WLProperties.getProperty(WLPropertyKeys.CONNECTION_MODE);
        Connection con = null ;
        if(connectionMode.equals("DATASOURCE")){
	        if(ds!=null){
	        	con = ds.getConnection();
	        }else{
	        	throw new RuntimeException("Datasource is null");
	        }
        }else{
        	con = getConnectionLocal();
        }
        return con;        
    }
	public void close(Connection conn){
		try{
			if(connection==null){
				conn.close();
			}else{
				conn.commit();
			}
		}catch(SQLException ex){
			ex.printStackTrace();
		}
	}
	public Connection getConnectionLocal(){
		
		try {
			if(connection!=null && !connection.isClosed()){
				return connection;
			}else{
				return DriverManager.getConnection(dbString,userid,pwd);
			}
		} catch (SQLException e) {
			if(connection!=null){
				try {
					connection.close();
				} catch (SQLException e1) {
					e1.printStackTrace();
				}
				connection=null;
			}
			e.printStackTrace();
		}
		return null;
	}

	public void distroyConnection() {
		try {
			if(connection!=null && !connection.isClosed()){
				connection.close();
				connection=null;
			}
		}catch(SQLException ex){
			connection=null;
		}
	}
}
