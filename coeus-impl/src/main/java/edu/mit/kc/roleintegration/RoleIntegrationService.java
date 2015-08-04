package edu.mit.kc.roleintegration;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchProviderException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.util.List;

import rolesservice.RolesAuthorizationExt;
import rolesservice.RolesException_Exception;


public interface RoleIntegrationService {
	
	/**
     * This method update kc role table with the roles from central db
     */	
	public void updateUserRoles(String userName) throws UnrecoverableKeyException, KeyManagementException, KeyStoreException, CertificateException, NoSuchProviderException, IOException, RolesException_Exception;
	
	/**
     * This method retrieve roles from central database
     */
	public List<RolesAuthorizationExt> getUserRoles(String userName) throws UnrecoverableKeyException, KeyManagementException, KeyStoreException, CertificateException,IOException, NoSuchProviderException, RolesException_Exception;

}
