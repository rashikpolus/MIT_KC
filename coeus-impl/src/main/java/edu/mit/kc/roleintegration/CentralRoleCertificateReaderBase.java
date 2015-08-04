package edu.mit.kc.roleintegration;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.kuali.rice.core.api.config.property.ConfigurationService;

public class CentralRoleCertificateReaderBase implements CentralRoleCertificateReader {

    private static final Log LOG = LogFactory.getLog(CentralRoleCertificateReaderBase.class);

    private ConfigurationService kualiConfigurationService;

    private String keyStoreLocation;
    private String keyStorePassword;
    private String trustStoreLocation;
    private String trustStorePassword;
    private String jksType = "JKS";
    
    private KeyStore keyStore = null;
    private KeyStore trustStore = null;

    @Override
    public KeyStore getKeyStore()  {
        if(keyStore!=null) return keyStore;
        try {
            keyStore = KeyStore.getInstance(jksType);
            keyStore.load(new FileInputStream(getKualiConfigurationService().getPropertyValueAsString(keyStoreLocation)),
            		getKualiConfigurationService().getPropertyValueAsString(keyStorePassword).toCharArray());
        }catch (KeyStoreException e) {
            keyStore = null;
            LOG.error("Error while creating Keystore with cert " +keyStoreLocation, e);
        }catch (NoSuchAlgorithmException e) {
            keyStore = null;
            LOG.error("JCE provider doesnt support certificate algorithm "+keyStoreLocation, e);
        }catch (CertificateException e) {
            keyStore = null;
            LOG.error("Error while creating keystore "+keyStoreLocation, e);
        }catch (FileNotFoundException e) {
            keyStore = null;
            LOG.error("File not found "+keyStoreLocation, e);
        }catch (IOException e) {
            keyStore = null;
            LOG.error("IO Exception while reading keystore file "+keyStoreLocation, e);
        }
        return keyStore;
    }

    @Override
    public KeyStore getTrustStore()  {
        if(trustStore!=null)
            return trustStore;
        try {
            trustStore = KeyStore.getInstance(jksType);
            trustStore.load(new FileInputStream(getKualiConfigurationService().getPropertyValueAsString(trustStoreLocation)),
            		getKualiConfigurationService().getPropertyValueAsString(trustStorePassword).toCharArray());
        }catch (KeyStoreException e) {
            trustStore = null;
            LOG.error("Error while creating Keystore with cert " +trustStoreLocation, e);
        }catch (NoSuchAlgorithmException e) {
            trustStore = null;
            LOG.error("JCE provider doesnt support certificate algorithm "+trustStoreLocation, e);
        }catch (CertificateException e) {
            trustStore = null;
            LOG.error("Error while creating keystore "+trustStoreLocation, e);
        }catch (FileNotFoundException e) {
            trustStore = null;
            LOG.error("File not found "+trustStoreLocation, e);
        }catch (IOException e) {
            trustStore = null;
            LOG.error("IO Exception while reading keystore file "+trustStoreLocation, e);
        }
        return trustStore;
    }

    public String getKeyStoreLocation() {
        return keyStoreLocation;
    }

    /**
     * The configuration parameter name that defines the keystore location
     * @param keyStoreLocation
     */
    public void setKeyStoreLocation(String keyStoreLocation) {
        this.keyStoreLocation = keyStoreLocation;
    }

    public String getKeyStorePassword() {
        return keyStorePassword;
    }

    /**
     * The configuration parameter name that defines the keystore password
     * @param keyStorePassword
     */
    public void setKeyStorePassword(String keyStorePassword) {
        this.keyStorePassword = keyStorePassword;
    }

    public String getTrustStoreLocation() {
        return trustStoreLocation;
    }

    /**
     * The configuration parameter that defines the trust store location
     * @param trustStoreLocation
     */
    public void setTrustStoreLocation(String trustStoreLocation) {
        this.trustStoreLocation = trustStoreLocation;
    }

    public String getTrustStorePassword() {
        return trustStorePassword;
    }

    /**
     * The configuration parameter the defines the trust store password
     * @param trustStorePassword
     */
    public void setTrustStorePassword(String trustStorePassword) {
        this.trustStorePassword = trustStorePassword;
    }

    public String getJksType() {
        return jksType;
    }

    public void setJksType(String jksType) {
        this.jksType = jksType;
    }

	public ConfigurationService getKualiConfigurationService() {
		return kualiConfigurationService;
	}

	public void setKualiConfigurationService(
			ConfigurationService kualiConfigurationService) {
		this.kualiConfigurationService = kualiConfigurationService;
	}
}
