/*
 * Copyright 2005-2010 The Kuali Foundation
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
package edu.mit.kc.citi;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

import java.sql.Timestamp;

public class CitiTraining extends KcPersistableBusinessObjectBase { 
    
    private static final long serialVersionUID = 1L;

    private Long citiTrainingId;
    private String firstName; 
    private String lastName; 
    private String email; 
    private String curriculum; 
    private String trainingGroup; 
    private String score; 
    private String passingScore; 
    private String stageNumber; 
    private String stage; 
    private Timestamp dateCompleted; 
    private String userName; 
    private String customField1; 
    private String customField2; 
    
    
    public CitiTraining() { 

    } 
    
	public Long getCitiTrainingId() {
		return citiTrainingId;
	}

	public void setCitiTrainingId(Long citiTrainingId) {
		this.citiTrainingId = citiTrainingId;
	}

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCurriculum() {
        return curriculum;
    }

    public void setCurriculum(String curriculum) {
        this.curriculum = curriculum;
    }

    public String getTrainingGroup() {
        return trainingGroup;
    }

    public void setTrainingGroup(String trainingGroup) {
        this.trainingGroup = trainingGroup;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public String getPassingScore() {
        return passingScore;
    }

    public void setPassingScore(String passingScore) {
        this.passingScore = passingScore;
    }

    public String getStageNumber() {
        return stageNumber;
    }

    public void setStageNumber(String stageNumber) {
        this.stageNumber = stageNumber;
    }

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    public Timestamp getDateCompleted() {
        return dateCompleted;
    }

    public void setDateCompleted(Timestamp dateCompleted) {
        this.dateCompleted = dateCompleted;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getCustomField1() {
        return customField1;
    }

    public void setCustomField1(String customField1) {
        this.customField1 = customField1;
    }

    public String getCustomField2() {
        return customField2;
    }

    public void setCustomField2(String customField2) {
        this.customField2 = customField2;
    }
    @Override
    protected void prePersist() {
//        super.prePersist();
        this.setVersionNumber(new Long(0));
    }
}