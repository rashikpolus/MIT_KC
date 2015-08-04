/*
 * Copyright 2005-2014 The Kuali Foundation
 * 
 * Licensed under the GNU Affero General Public License, Version 3 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.opensource.org/licenses/ecl1.php
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kuali.kra.lookup.keyvalue;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import org.kuali.kra.award.home.AwardStatus;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.util.ConcreteKeyValue;
import org.kuali.rice.core.api.util.KeyValue;
import org.kuali.rice.krad.service.KeyValuesService;
import org.kuali.rice.krad.uif.control.UifKeyValuesFinderBase;

public class MitAwardStatusValuesFinder extends UifKeyValuesFinderBase {

    @Override
    public List<KeyValue> getKeyValues() {
        KeyValuesService keyValuesService = (KeyValuesService) KcServiceLocator.getService("keyValuesService");
        Collection statusCodeTypes = keyValuesService.findAllOrderBy(AwardStatus.class,"statusCode",true);
        List<KeyValue> keyValues = new ArrayList<KeyValue>();
        keyValues.add(new ConcreteKeyValue("", ""));
        for (Iterator iter = statusCodeTypes.iterator(); iter.hasNext();) {
            AwardStatus statusCodeType = (AwardStatus) iter.next();
            keyValues.add(new ConcreteKeyValue(statusCodeType.getStatusCode(), statusCodeType.getDescription()));                            
        }
                
        return keyValues;
    }
}
