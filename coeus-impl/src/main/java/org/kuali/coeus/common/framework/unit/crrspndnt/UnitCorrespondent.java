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
package org.kuali.coeus.common.framework.unit.crrspndnt;

import org.kuali.coeus.common.framework.crrspndnt.Correspondent;
import org.kuali.coeus.common.framework.unit.Unit;

public class UnitCorrespondent extends Correspondent {

    private static final long serialVersionUID = 1L;

	private String unitNumber;
	
    private Unit unit;
    
    public UnitCorrespondent() {
    }

    public Unit getUnit() {
        return unit;
    }

    public void setUnit(Unit unit) {
        this.unit = unit;
    }
    
    public String getUnitNumber() {
    	return unitNumber;
    }
    
    public void setUnitNumber(String unitNumber) {
    	this.unitNumber = unitNumber;
    }
    
    public org.kuali.kra.irb.correspondence.CorrespondentType getCorrespondentType() {
        return (org.kuali.kra.irb.correspondence.CorrespondentType) correspondentType;
    }

    public void setCorrespondentType(org.kuali.kra.irb.correspondence.CorrespondentType correspondentType) {
        this.correspondentType = correspondentType;
    }

}
