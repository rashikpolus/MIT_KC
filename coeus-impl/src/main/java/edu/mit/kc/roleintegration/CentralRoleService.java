package edu.mit.kc.roleintegration;

import java.util.List;

import rolesservice.RolesAuthorizationExt;
import rolesservice.RolesException_Exception;

public interface CentralRoleService {
	
	/**
     * This method retrieves roles from central database
     */
	public List<RolesAuthorizationExt> getCentralUserRoles(String userName) throws RolesException_Exception;


}
