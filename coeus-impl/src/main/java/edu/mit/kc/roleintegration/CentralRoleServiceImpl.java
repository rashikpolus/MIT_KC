package edu.mit.kc.roleintegration;

import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.util.ArrayList;
import java.util.List;

import javax.net.ssl.KeyManager;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;
import javax.xml.ws.soap.SOAPFaultException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.cxf.configuration.jsse.TLSClientParameters;
import org.apache.cxf.configuration.security.FiltersType;
import org.apache.cxf.endpoint.Client;
import org.apache.cxf.frontend.ClientProxy;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.http.HTTPConduit;
import org.apache.cxf.transports.http.configuration.HTTPClientPolicy;
import org.kuali.kra.infrastructure.Constants;
import org.kuali.rice.core.api.config.property.ConfigurationService;
import org.kuali.rice.coreservice.framework.parameter.ParameterService;

import edu.mit.kc.infrastructure.KcMitConstants;

import rolesservice.Roles;
import rolesservice.RolesAuthorizationExt;
import rolesservice.RolesException_Exception;

public class CentralRoleServiceImpl implements CentralRoleService {
	
    protected static final Log LOG = LogFactory.getLog(CentralRoleServiceImpl.class);

    private CentralRoleCertificateReader centralRoleCertificateReader;
    
    private ConfigurationService kualiConfigurationService;

    private ParameterService parameterService;
    protected String serviceHost;
    protected String servicePort;

    /**
     * This method retrieves roles from central datbase
     */
    public List<RolesAuthorizationExt> getCentralUserRoles(String userName) throws RolesException_Exception{
    	Roles port = configureApplicantIntegrationSoapPort();

    	List<RolesAuthorizationExt> rolesAuthorizationExt = new ArrayList<RolesAuthorizationExt>();
    	
    	try {
    		String category = parameterService.getParameterValueAsString(Constants.KC_GENERIC_PARAMETER_NAMESPACE, 
    				Constants.KC_ALL_PARAMETER_DETAIL_TYPE_CODE, KcMitConstants.ROLE_CENTRAL_DB_CATEGORY_CODE);
    		rolesAuthorizationExt = port.listAuthorizationsByPersonExt(userName,category,true,false,userName);
    	} catch (SOAPFaultException | NullPointerException e) {
			 LOG.error(e.getMessage(), e);
		}
    	
    	return rolesAuthorizationExt;
    }

	
    protected Roles configureApplicantIntegrationSoapPort()    		{
    	System.clearProperty("java.protocol.handler.pkgs");
    	JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
    	factory.setAddress(getSoapHost());
    	factory.setServiceClass(Roles.class);
    	Roles roleService = (Roles)factory.create();
    	Client client = ClientProxy.getClient(roleService); 
    	HTTPClientPolicy httpClientPolicy = new HTTPClientPolicy();
    	httpClientPolicy.setConnectionTimeout(0);
    	httpClientPolicy.setReceiveTimeout(0);
    	httpClientPolicy.setAllowChunking(false);
    	HTTPConduit conduit = (HTTPConduit) client.getConduit();
    	conduit.setClient(httpClientPolicy);
    	TLSClientParameters tlsConfig = new TLSClientParameters();
    	setPossibleCypherSuites(tlsConfig);
    	configureKeyStoreAndTrustStore(tlsConfig);
    	conduit.setTlsClientParameters(tlsConfig);
    	return roleService;
    }
    
    
    protected void setPossibleCypherSuites(TLSClientParameters tlsConfig) {
        FiltersType filters = new FiltersType();
        filters.getInclude().add("SSL_RSA_WITH_RC4_128_MD5");
        filters.getInclude().add("SSL_RSA_WITH_RC4_128_SHA");
        filters.getInclude().add("SSL_RSA_WITH_3DES_EDE_CBC_SHA");
        filters.getInclude().add(".*_EXPORT_.*");
        filters.getInclude().add(".*_EXPORT1024_.*");
        filters.getInclude().add(".*_WITH_DES_.*");
        filters.getInclude().add(".*_WITH_3DES_.*");
        filters.getInclude().add(".*_WITH_RC4_.*");
        filters.getInclude().add(".*_WITH_NULL_.*");
        filters.getInclude().add(".*_DH_anon_.*");

        tlsConfig.setDisableCNCheck(true); 
        tlsConfig.setCipherSuitesFilter(filters);
    }
    
    
    protected void configureKeyStoreAndTrustStore(TLSClientParameters tlsConfig){
    	
        KeyStore keyStore = getCentralRoleCertificateReader().getKeyStore();
        KeyManagerFactory keyManagerFactory;
        try {
            keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
            keyManagerFactory.init(keyStore, getKualiConfigurationService().getPropertyValueAsString(centralRoleCertificateReader.getKeyStorePassword()).toCharArray());
            KeyManager[] km = keyManagerFactory.getKeyManagers();
            tlsConfig.setKeyManagers(km);
            KeyStore trustStore = getCentralRoleCertificateReader().getTrustStore();
            TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
            trustManagerFactory.init(trustStore);
            TrustManager[] tm = trustManagerFactory.getTrustManagers();
            tlsConfig.setTrustManagers(tm);
        }catch (NoSuchAlgorithmException e){
            LOG.error(e.getMessage(), e);
        }catch (KeyStoreException e) {
            LOG.error(e.getMessage(), e);
        }catch (UnrecoverableKeyException e) {
            LOG.error(e.getMessage(), e);
        }
    }


	public CentralRoleCertificateReader getCentralRoleCertificateReader() {
		return centralRoleCertificateReader;
	}


	public void setCentralRoleCertificateReader(
			CentralRoleCertificateReader centralRoleCertificateReader) {
		this.centralRoleCertificateReader = centralRoleCertificateReader;
	}

	public ConfigurationService getKualiConfigurationService() {
		return kualiConfigurationService;
	}


	public void setKualiConfigurationService(
			ConfigurationService kualiConfigurationService) {
		this.kualiConfigurationService = kualiConfigurationService;
	}


    
	
	public String getServiceHost() {
		return serviceHost;
	}


	public void setServiceHost(String serviceHost) {
		this.serviceHost = serviceHost;
	}


	public String getServicePort() {
		return servicePort;
	}


	public void setServicePort(String servicePort) {
		this.servicePort = servicePort;
	}


	/**
     * 
     * This method returns the Host URL for role web services
     * 
     * @return {@link String} host URL
     * 
     */

    private String getSoapHost() {
        StringBuilder host = new StringBuilder();
        host.append(getKualiConfigurationService().getPropertyValueAsString(getServiceHost()));
        String port = getKualiConfigurationService().getPropertyValueAsString(getServicePort());
        if ((!host.toString().endsWith("/")) && (!port.startsWith("/"))) {
            host.append("/");
        }
        host.append(port);
        return host.toString();
    }


	public ParameterService getParameterService() {
		return parameterService;
	}


	public void setParameterService(ParameterService parameterService) {
		this.parameterService = parameterService;
	}

}
