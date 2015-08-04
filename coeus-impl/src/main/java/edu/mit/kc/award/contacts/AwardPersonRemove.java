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
package edu.mit.kc.award.contacts;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.kuali.kra.award.awardhierarchy.sync.AwardSyncableProperty;
import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.common.framework.person.KcPersonService;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.krad.service.BusinessObjectService;

/**
 * This class implements an Award Person Confirm
 */
public class AwardPersonRemove extends KcPersistableBusinessObjectBase implements Serializable {


    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 7758526398837073772L;

    private Long awardPersonRemoveId;

    @AwardSyncableProperty(key = true)
    private Long awardId;
    @AwardSyncableProperty(key = true)
    private String awardNumber;
    @AwardSyncableProperty(key = true)
    private Long awardPersonId;
    @AwardSyncableProperty(key = true)
    protected String personId;

    private Integer sequenceNumber;

    private boolean confirmFlag;
    private Timestamp updateTimestampConfirm;
    protected String updateUserConfirm;
    private Timestamp updateTimestamp;
    protected String updateUser;
    
    private String keyPersonName;
    
    public String getKeyPersonName() {
    	KcPerson kcPerson=getKcPersonService().getKcPersonByPersonId(this.personId);
		 this.setKeyPersonName(kcPerson.getFullName());
		 this.keyPersonName=kcPerson.getFullName();
		return keyPersonName;
	}

	private KcPersonService getKcPersonService() {
		return KcServiceLocator.getService(KcPersonService.class);
	}

	public void setKeyPersonName(String keyPersonName) {
		
		this.keyPersonName = keyPersonName;
		
	}

	private List<AwardPersonRemove> awardPersonRemovalHistoryList;
    
    
    public List<AwardPersonRemove> getAwardPersonRemovalHistoryList() {
		return awardPersonRemovalHistoryList;
	}

	public void setAwardPersonRemovalHistoryList(
			List<AwardPersonRemove> awardPersonRemovalHistoryList) {
		this.awardPersonRemovalHistoryList = awardPersonRemovalHistoryList;
	}
    
    public Long getAwardId() {
        return awardId;
    }
    public Long getAwardPersonRemoveId() {
		return awardPersonRemoveId;
	}

	public void setAwardPersonRemoveId(Long awardPersonRemoveId) {
		this.awardPersonRemoveId = awardPersonRemoveId;
	}

	public Timestamp getUpdateTimestampConfirm() {
		if(updateTimestampConfirm != null){
			this.updateTimestampConfirm = convertDate(updateTimestampConfirm);
			}
			return this.updateTimestampConfirm;
	}

	public void setUpdateTimestampConfirm(Timestamp updateTimestampConfirm) {
		this.updateTimestampConfirm = updateTimestampConfirm;
	}

	public String getUpdateUserConfirm() {
		return updateUserConfirm;
	}

	public void setUpdateUserConfirm(String updateUserConfirm) {
		this.updateUserConfirm = updateUserConfirm;
	}

	
	public void setAwardId(Long awardId) {
        this.awardId = awardId;
    }
    public String getAwardNumber() {
        return awardNumber;
    }
    public void setAwardNumber(String awardNumber) {
        this.awardNumber = awardNumber;
    }
    public Long getAwardPersonId() {
        return awardPersonId;
    }
    public void setAwardPersonId(Long awardPersonId) {
        this.awardPersonId = awardPersonId;
    }
    public String getPersonId() {
        return personId;
    }
    public void setPersonId(String personId) {
        this.personId = personId;
    }
    public Integer getSequenceNumber() {
        return sequenceNumber;
    }
    public void setSequenceNumber(Integer sequenceNumber) {
        this.sequenceNumber = sequenceNumber;
    }
    public boolean isConfirmFlag() {
        return confirmFlag;
    }
    public void setConfirmFlag(boolean confirmFlag) {
        this.confirmFlag = confirmFlag;
    }
    public Timestamp getUpdateTimestamp() {
        return convertDate(updateTimestamp);
    }
    public void setUpdateTimestamp(Timestamp updateTimestamp) {
        this.updateTimestamp = updateTimestamp;
    }
    public String getUpdateUser() {
        return updateUser;
    }
    public void setUpdateUser(String updateUser) {
        this.updateUser = updateUser;
    }
    public static long getSerialversionuid() {
        return serialVersionUID;
    }

    private Timestamp convertDate(Timestamp updateTimestamp2){
        SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss a");
        try {
        	String dateString=sdf.format(updateTimestamp2);
        	  Date parsedTimeStamp = sdf.parse(dateString);
            Timestamp timestamp = new Timestamp(parsedTimeStamp.getTime());
            return timestamp;
        } catch (ParseException ex) {
            //ex.printStackTrace();
            return updateTimestamp2;
        }
		
    }

        
}
