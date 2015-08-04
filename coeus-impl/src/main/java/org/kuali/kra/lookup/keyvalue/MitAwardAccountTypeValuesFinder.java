package org.kuali.kra.lookup.keyvalue;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import org.kuali.kra.bo.AccountType;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.util.ConcreteKeyValue;
import org.kuali.rice.core.api.util.KeyValue;
import org.kuali.rice.krad.service.KeyValuesService;
import org.kuali.rice.krad.uif.control.UifKeyValuesFinderBase;

public class MitAwardAccountTypeValuesFinder extends UifKeyValuesFinderBase {
	
	 @Override
	    public List<KeyValue> getKeyValues() {
	        KeyValuesService keyValuesService = (KeyValuesService) KcServiceLocator.getService("keyValuesService");
	        Collection accountTypeCodes = keyValuesService.findAllOrderBy(AccountType.class,"accountTypeCode",true);
	        List<KeyValue> keyValues = new ArrayList<KeyValue>();
	        keyValues.add(new ConcreteKeyValue("", ""));
	        for (Iterator iter = accountTypeCodes.iterator(); iter.hasNext();) {
	        	AccountType accountTypeCode = (AccountType) iter.next();
	            keyValues.add(new ConcreteKeyValue(accountTypeCode.getAccountTypeCode().toString(), accountTypeCode.getDescription()));                            
	        }
	                
	        return keyValues;
	    }

}
