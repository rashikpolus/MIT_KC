package edu.mit.kc.roleintegration;

import java.security.KeyStore;

public interface CentralRoleCertificateReader {
	
	KeyStore getKeyStore();
    KeyStore getTrustStore();
    String getKeyStoreLocation();
    String getKeyStorePassword();
    String getTrustStoreLocation();
    String getTrustStorePassword();
    String getJksType();
}
