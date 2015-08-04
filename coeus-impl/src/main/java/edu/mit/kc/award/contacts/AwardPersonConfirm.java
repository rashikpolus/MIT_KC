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
import java.util.List;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.kra.award.awardhierarchy.sync.AwardSyncableProperty;
import org.kuali.kra.award.contacts.AwardPerson;

/**
 * This class implements an Award Person Confirm
 */
public class AwardPersonConfirm extends KcPersistableBusinessObjectBase implements Serializable {


    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 7758526398837073772L;

    private Long awardPersonConfirmId;

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
    private Timestamp updateTimestamp;
    protected String updateUser;
    
    
    private List<AwardPersonConfirm> awardPersonRemovalHistoryList;
    
    
    public List<AwardPersonConfirm> getAwardPersonRemovalHistoryList() {
		return awardPersonRemovalHistoryList;
	}

	public void setAwardPersonRemovalHistoryList(
			List<AwardPersonConfirm> awardPersonRemovalHistoryList) {
		this.awardPersonRemovalHistoryList = awardPersonRemovalHistoryList;
	}

    public AwardPersonConfirm() {
        super();
    }    
    
    public AwardPersonConfirm(AwardPerson awardPerson) {
        super();
    }
    
   
    public Long getAwardPersonConfirmId() {
        return awardPersonConfirmId;
    }
    public void setAwardPersonConfirmId(Long awardPersonConfirmId) {
        this.awardPersonConfirmId = awardPersonConfirmId;
    }
    public Long getAwardId() {
        return awardId;
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
        return updateTimestamp;
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

	

        
}
