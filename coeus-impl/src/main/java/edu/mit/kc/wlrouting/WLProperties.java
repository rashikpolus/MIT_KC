/*
 * CoeusProperties.java
 *
 * Created on November 29, 2004, 11:34 AM
 */

package edu.mit.kc.wlrouting;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 *
 * @author  geot
 */
public class WLProperties {
    private static Properties props = null;
    
    private static final String WL_PROP_FILE="/workload.properties";
    
    /** Creates a new instance of WLProperties */
    private WLProperties() {}
    /**
     * Get a property value from the <code>workload.properties</code> file.
     *
     * @param key An key value
     * @return The property value or null if no property exists
     * @throws IOException
     */
    public static String getProperty(String key) {
        return getProperty(key,null);
    }
    /**
     * Get a property value from the <code>workload.properties</code> file.
     *
     * @param key An key value
     * @return The property value or default value if no property exists
     * @throws IOException
     */
    public static String getProperty(String key,String defaultValue) {
        if (props == null) {
            synchronized (WLProperties.class) {
                if (props == null) {
                    try {
						props = loadProperties();
					} catch (IOException e) {
						e.printStackTrace();
						throw new RuntimeException("Could not load Workload Properties");
					}
                }
            }
            
        }
        return props.getProperty(key,defaultValue);
    }
    /**
     * Load Properties
     *
     * @return The Properties
     * @throws IOException
     */
    private static Properties loadProperties() throws IOException {
        InputStream stream = null;
        try {
                props = new Properties();
                stream = new WLProperties().getClass().getResourceAsStream(WL_PROP_FILE);
                props.load( stream );
        } finally {
            try {
                stream.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        return props;
    }
}
