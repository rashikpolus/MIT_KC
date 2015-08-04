package edu.mit.kc.roleintegration;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

public class SyncLog extends KcPersistableBusinessObjectBase implements Cloneable{
	

	
	private static final long serialVersionUID = -7051545204605043569L;

		String syncLogid;
	    
		 String centralRoleName;
		 
		 String roleName;
		 
		 String roleId;
	 
  		 String principleName;
		 
		 String unitNumber;
		 
		 String nameSpace;
		 
		public String getUnitNumber() {
			return unitNumber;
		}

		public void setUnitNumber(String unitNumber) {
			this.unitNumber = unitNumber;
		}

		public String getRoleName() {
			return roleName;
		}

		public void setRoleName(String roleName) {
			this.roleName = roleName;
		}

		public String getSyncLogid() {
			return syncLogid;
		}

		public void setSyncLogid(String syncLogid) {
			this.syncLogid = syncLogid;
		}

		public String getPrincipleName() {
			return principleName;
		}

		public void setPrincipleName(String principleName) {
			this.principleName = principleName;
		}

		public String getRoleId() {
			return roleId;
		}

		public void setRoleId(String roleId) {
			this.roleId = roleId;
		}

		public String getNameSpace() {
			return nameSpace;
		}

		public void setNameSpace(String nameSpace) {
			this.nameSpace = nameSpace;
		}

		public String getCentralRoleName() {
			return centralRoleName;
		}

		public void setCentralRoleName(String centralRoleName) {
			this.centralRoleName = centralRoleName;
		}
		
		protected Object clone() throws CloneNotSupportedException {
	        return super.clone();
	    }
	}