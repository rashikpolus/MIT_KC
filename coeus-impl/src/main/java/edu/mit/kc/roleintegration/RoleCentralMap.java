package edu.mit.kc.roleintegration;


import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

public class RoleCentralMap extends KcPersistableBusinessObjectBase implements Cloneable{
	
	 
	private static final long serialVersionUID = 4891146401561593923L;

	String roleCentralMapid;
	 
	 String roleId;
    
	 String roleName;
    
 
	 String centralRoleName;
	 
   
	 String nameSpace;
	 
	 String unitNumber;


	public String getRoleCentralMapid() {
		return roleCentralMapid;
	}

	public void setRoleCentralMapid(String roleCentralMapid) {
		this.roleCentralMapid = roleCentralMapid;
	}

	public String getRoleId() {
		return roleId;
	}

	public void setRoleId(String roleId) {
		this.roleId = roleId;
	}

	public String getRoleName() {
		return roleName;
	}

	public void setRoleName(String roleName) {
		this.roleName = roleName;
	}


	public String getCentralRoleName() {
		return centralRoleName;
	}

	public void setCentralRoleName(String centralRoleName) {
		this.centralRoleName = centralRoleName;
	}

	public String getNameSpace() {
		return nameSpace;
	}

	public void setNameSpace(String nameSpace) {
		this.nameSpace = nameSpace;
	}

	public String getUnitNumber() {
		return unitNumber;
	}

	public void setUnitNumber(String unitNumber) {
		this.unitNumber = unitNumber;
	}

	protected Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

	


}
