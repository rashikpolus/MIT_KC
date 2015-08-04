package edu.mit.kc.citizenship;

/*
 * Kuali Coeus, a comprehensive research administration system for higher education.
 * 
 * Copyright 2005-2015 Kuali, Inc.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */



import org.kuali.coeus.common.api.person.attr.CitizenshipVisaTypeService;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.krad.data.DataObjectService;

import edu.mit.kc.wh.WareHousePerson;


/**
 * 
 * This service has been made available for implementers who will be using an external source
 * for citizenship data. It hooks into S2SUtilService via the system parameter
 * PI_CITIZENSHIP_FROM_CUSTOM_DATA. Setting this to "0" will see that S2SUtilServiceImpl::getCitizenship receive a
 * CitizenshipTypes from this service, as opposed to KcPerson's extended attributes
 * 
 * Schools who need external citizenship data are expected to override this service with their own
 * implementation of "getCitizenshipDataFromExternalSource().
 * 
 * getEnumValueOfCitizenshipType has been included as a convenience method should it be needed.
 **/


public class CitizenshipVisaTypeServiceImpl implements CitizenshipVisaTypeService {

	public String findVisaTypeFromWarehouse(
			String proposalPersonId) {
		String visaType = null;
		WareHousePerson wareHousePersons = KcServiceLocator.getService(DataObjectService.class).find(WareHousePerson.class, proposalPersonId);
		if(wareHousePersons!=null){
			visaType = wareHousePersons.getResidencyStatusCode();
		}
		return visaType;
	}

	

}
