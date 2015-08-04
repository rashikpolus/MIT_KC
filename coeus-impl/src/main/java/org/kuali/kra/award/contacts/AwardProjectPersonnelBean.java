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
package org.kuali.kra.award.contacts;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.kuali.coeus.common.framework.person.PropAwardPersonRole;
import org.kuali.coeus.common.framework.unit.Unit;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.kra.award.AwardForm;
import org.kuali.kra.award.home.Award;
import org.kuali.kra.award.home.ContactRole;
import org.kuali.rice.krad.service.BusinessObjectService;
import org.kuali.rice.krad.util.GlobalVariables;

import edu.mit.kc.award.contacts.AwardPersonConfirm;
import edu.mit.kc.award.contacts.AwardPersonRemove;

/**
 * This class provides support for the Award Contacts Project Personnel panel
 */
public class AwardProjectPersonnelBean extends AwardContactsBean {
    private static final long serialVersionUID = -8213637358006756203L;
    private transient Collection<AwardPersonConfirm> awardPersonConfirmPrimary;
    private AwardPersonUnit[] newAwardPersonUnits;
    boolean projectPersonEntryFlag=false;
    private transient String selectedLeadUnit;

    public AwardProjectPersonnelBean(AwardForm awardForm) {
        super(awardForm);
    }
    
    public AwardPersonUnit addNewProjectPersonUnit(int projectPersonIndex) {
        AwardPerson person = getAward().getProjectPersons().get(projectPersonIndex);
        AwardPersonUnitRuleAddEvent event = generateAddPersonUnitEvent(person, projectPersonIndex);
        AwardPersonUnit newUnit = newAwardPersonUnits[projectPersonIndex];
        boolean success = new AwardPersonUnitAddRuleImpl().processAddAwardPersonUnitBusinessRules(event);
        if(success) {
            person.add(newAwardPersonUnits[projectPersonIndex]);
            if(newAwardPersonUnits[projectPersonIndex].isLeadUnit()) {
                getAward().setLeadUnit(newAwardPersonUnits[projectPersonIndex].getUnit());
                setSelectedLeadUnit(newAwardPersonUnits[projectPersonIndex].getUnitName());
            }
            initNewAwardPersonUnits();
        }
        return newUnit;
    }

    
public Collection<AwardPersonConfirm> getAwardPersonConfirmPrimary() {
		return awardPersonConfirmPrimary;
	}

	public void setAwardPersonConfirmPrimary(
			Collection<AwardPersonConfirm> awardPersonConfirmPrimary) {
		this.awardPersonConfirmPrimary = awardPersonConfirmPrimary;
	}

	//  pass award id and person id and get primary key
	protected Collection<AwardPersonConfirm> AwardPersonConfirmPrimary(
			String awardId, String awardNumber, String personId) {
		Map<String, String> queryMap = new HashMap<String, String>();

		queryMap.put("awardId", awardId);
		queryMap.put("awardNumber", awardNumber);
		queryMap.put("personId", personId);
		return (Collection<AwardPersonConfirm>) getBusinessObjectService()
				.findMatching(AwardPersonConfirm.class, queryMap);

	}
    //use this for history population removal bo refer
  @SuppressWarnings("unchecked")
public
    Collection<AwardPersonRemove> getAwardPersonRemoval(String awardNumber) {
	  Collection<AwardPersonRemove> awardPersons =  new ArrayList<AwardPersonRemove>();
	  Map<String, String> queryMap = new HashMap<String, String>();
		queryMap.put("awardNumber", awardNumber);		
		awardPersons = this.getBusinessObjectService().findMatching(AwardPersonRemove.class,queryMap);
		queryMap.clear();
	  
	return awardPersons;
	  
       
    }
    /**
     * This method is for adding a project person
     */
    public void confirmProjectPeersonEntry(int lineToEdit) {
     List<AwardPerson> projectPersons = getProjectPersonnel(); 
		if (projectPersons.size() > lineToEdit) {
			AwardPersonConfirm awardPersonConfirm = new AwardPersonConfirm();
			if (projectPersons.get(lineToEdit).getAward().getAwardId() != null
					&& !(projectPersons.get(lineToEdit).getAwardNumber().isEmpty())
					&& projectPersons.get(lineToEdit).getAwardContactId() != null
					&& !(projectPersons.get(lineToEdit).getPersonId().isEmpty())
					&& projectPersons.get(lineToEdit).getSequenceNumber() != null) {
				awardPersonConfirm.setAwardId(projectPersons.get(lineToEdit).getAward().getAwardId());
				awardPersonConfirm.setAwardNumber(projectPersons.get(lineToEdit).getAwardNumber());
				awardPersonConfirm.setAwardPersonId(projectPersons.get(lineToEdit).getAwardContactId());
				awardPersonConfirm.setPersonId(projectPersons.get(lineToEdit).getPersonId());
				awardPersonConfirm.setUpdateTimestamp(projectPersons.get(lineToEdit).getUpdateTimestamp());
				awardPersonConfirm.setUpdateUser(projectPersons.get(lineToEdit).getUpdateUser());
				awardPersonConfirm.setConfirmFlag(true);
				awardPersonConfirm.setSequenceNumber(projectPersons.get(lineToEdit).getSequenceNumber());
				this.awardForm.setAlertMessage(false);
				getBusinessObjectService().save(awardPersonConfirm);
			}else{this.awardForm.setAlertMessage(true);
			
			}
		}
       
      
    }
    public BusinessObjectService getBusinessObjectService(){
        BusinessObjectService businessObjectService =  (BusinessObjectService) KcServiceLocator.getService(BusinessObjectService.class);
        return businessObjectService;
    }
    
    
    /**
     * This method is for adding a project person
     */
    public AwardPerson addProjectPerson() {
        AwardProjectPersonRuleAddEvent event = generateAddProjectPersonEvent();
        boolean success = new AwardProjectPersonAddRuleImpl().processAddAwardProjectPersonBusinessRules(event);
        if(success){
            AwardPerson awardPerson = getNewProjectPerson();
            getAward().add(awardPerson);
            init();
            if(awardPerson.isPrincipalInvestigator()) {
            	addPersonUnitToPerson(awardPerson, new AwardPersonUnit(awardPerson, getAward().getLeadUnit(), true));
            } else {
                if(awardPerson.isEmployee() && !awardPerson.isKeyPerson()) {
                    // no reason to add null unit, it just confuses things...
                    if (awardPerson.getPerson().getUnit() != null) {
                    	addPersonUnitToPerson(awardPerson, new AwardPersonUnit(awardPerson, awardPerson.getPerson().getUnit(), false));
                    }
                }
                else {
                    if (!awardPerson.isEmployee()) {
                    	addPersonUnitToPerson(awardPerson, new AwardPersonUnit(awardPerson,awardPerson.getRolodex().getUnit(),false));
                    }                    
                }
            }
            return awardPerson;
        } else {
            return null;
        }
    }
    
    public void addPersonUnitToPerson(AwardPerson awardPerson, AwardPersonUnit newPersonUnit) {
    	if (!awardPerson.getUnits().contains(newPersonUnit)) {
        	awardPerson.getUnits().add(newPersonUnit);
        }
    }

    /**
     * This method deletes a Project Person from the list
     * @param lineToDelete
     */
    public void deleteProjectPerson(int lineToDelete) {
        List<AwardPerson> projectPersons = getProjectPersonnel(); 
        if(projectPersons.size() > lineToDelete) {
        	removeConfirmationEntries(lineToDelete,projectPersons);
            projectPersons.remove(lineToDelete);
        }        
    }
   
    public void removeConfirmationEntries(int lineToDelete,List<AwardPerson> projectPersons){
        if(projectPersons.size() > lineToDelete) {
            List<AwardPersonConfirm> deleteCollection = new ArrayList<AwardPersonConfirm>();
            deleteCollection=(List<AwardPersonConfirm>) AwardPersonConfirmPrimary(projectPersons.get(lineToDelete).getAward().getAwardId().toString(),projectPersons.get(lineToDelete).getAwardNumber().toString(),projectPersons.get(lineToDelete).getPersonId());
            
            this.getBusinessObjectService().delete(deleteCollection);
           if (deleteCollection.isEmpty()) {
        	   AwardPersonRemove awardPersonRemove = new AwardPersonRemove();
        	   awardPersonRemove.setAwardId(projectPersons.get(lineToDelete).getAward().getAwardId());
               awardPersonRemove.setAwardNumber(projectPersons.get(lineToDelete).getAwardNumber().toString());
               awardPersonRemove.setAwardPersonId(projectPersons.get(lineToDelete).getAwardContactId());
               if(projectPersons.get(lineToDelete).getPersonId()!=null){
            	   awardPersonRemove.setPersonId(projectPersons.get(lineToDelete).getPersonId());
               }else{
            	   awardPersonRemove.setPersonId(projectPersons.get(lineToDelete).getRolodexId().toString());
               }
               awardPersonRemove.setConfirmFlag(false); 
               awardPersonRemove.setUpdateUser(projectPersons.get(lineToDelete).getUpdateUser()) ;
               awardPersonRemove.setSequenceNumber(projectPersons.get(lineToDelete).getSequenceNumber());
               awardPersonRemove.setUpdateTimestamp(new Timestamp(new java.util.Date().getTime()));
               this.getBusinessObjectService().save(awardPersonRemove);               
               
           }else{
        	   for(AwardPersonConfirm deleteColl : deleteCollection){
               	deleteColl.getAwardId();
               AwardPersonRemove awardPersonRemove = new AwardPersonRemove();
               awardPersonRemove.setAwardId(deleteColl.getAwardId());
               awardPersonRemove.setAwardNumber(deleteColl.getAwardNumber());
               awardPersonRemove.setAwardPersonId(deleteColl.getAwardPersonId());
               awardPersonRemove.setPersonId(deleteColl.getPersonId());
               awardPersonRemove.setUpdateTimestampConfirm(deleteColl.getUpdateTimestamp());
               awardPersonRemove.setUpdateUserConfirm(deleteColl.getUpdateUser());
               awardPersonRemove.setConfirmFlag(deleteColl.isConfirmFlag()); 
               awardPersonRemove.setUpdateUser(GlobalVariables.getUserSession().getPrincipalId()) ;
               awardPersonRemove.setSequenceNumber(deleteColl.getSequenceNumber());
               awardPersonRemove.setUpdateTimestamp(new Timestamp(new java.util.Date().getTime()));
               this.getBusinessObjectService().save(awardPersonRemove);
               }
               deleteCollection.clear();  
           }
            
            
           
           
        }  
    }
    
    /**
     * This method deletes a ProjectPersonUnit from the list 
     * @param projectPersonIndex
     * @param unitIndex
     */
    public void deleteProjectPersonUnit(int projectPersonIndex, int unitIndex) {
        getAward().getProjectPersons().get(projectPersonIndex).getUnits().remove(unitIndex);
    }
    
    /**
     * Gets the newAwardPersonUnit attribute. 
     * @return Returns the newAwardPersonUnit.
     */
    public AwardPersonUnit getNewAwardPersonUnit(int projectPersonIndex) {
        if(newAwardPersonUnits == null || newAwardPersonUnits.length < projectPersonIndex+1) {
            initNewAwardPersonUnits();
        }
        return newAwardPersonUnits[projectPersonIndex];
    }
    
    /**
     * Gets the newAwardPersonUnits attribute. 
     * @return Returns the newAwardPersonUnits.
     */
    public AwardPersonUnit[] getNewAwardPersonUnits() {
        for(AwardPersonUnit apu: newAwardPersonUnits) {
            lazyLoadUnit(apu);
        }
        return newAwardPersonUnits;
    }
    

    public AwardPerson getNewProjectPerson() {
        return (AwardPerson) newAwardContact;
    }

    /**
     * Gets the newUnitNumber attribute. 
     * @return Returns the newUnitNumber.
     */
    public String getNewUnitNumber(int projectPersonIndex) {
        return newAwardPersonUnits[projectPersonIndex].getUnit() != null ? newAwardPersonUnits[projectPersonIndex].getUnit().getUnitNumber() : null;
    }
    
    /**
     * This method finds the AwardPersons
     * @return The list; may be empty
     */
    public List<AwardPerson> getProjectPersonnel() {
        return getAward().getProjectPersons();
    }
    
    /**
     * This method finds the count of AwardContacts in the "Project Personnel" category
     * @return The count; may be 0
     */
    public int getProjectPersonnelCount() {
        return getProjectPersonnel().size();
    }
    
    /**
     * Gets the selectedLeadUnit attribute. 
     * @return Returns the selectedLeadUnit.
     */
    public String getSelectedLeadUnit() {
        selectedLeadUnit = "";
        for(AwardPerson p: getProjectPersonnel()) {
            if(p.isPrincipalInvestigator()) {
                for(AwardPersonUnit apu: p.getUnits()) {
                    if(apu.isLeadUnit()) {
                        selectedLeadUnit = apu.getUnitName(); 
                    }
                }
            }
        }
        return selectedLeadUnit;
    }
    
    public String getUnitName(int projectPersonIndex) {
        return newAwardPersonUnits[projectPersonIndex].getUnit() != null ? newAwardPersonUnits[projectPersonIndex].getUnit().getUnitName() : null; 
    }
     
    public String getUnitNumber(int projectPersonIndex) {
        return getNewUnitNumber(projectPersonIndex);
    }

    /**
     * Sets the selectedLeadUnit attribute value.
     * @param selectedLeadUnit The selectedLeadUnit to set.
     */
    public void setSelectedLeadUnit(String unitName) {
        this.selectedLeadUnit = unitName;
        setLeadUnitSelectionStates(unitName);
    }


    @Override
    protected AwardContact createNewContact() {
        return new AwardPerson();
    }
    
    @Override
    protected Class<? extends ContactRole> getContactRoleType() {
        return PropAwardPersonRole.class;
    }

    @Override
    protected void init() {
        super.init();
        initNewAwardPersonUnits();
    }
    
    private AwardPerson findPrincipalInvestigator() {
        AwardPerson awardPerson = null;
        for(AwardContact person: getAward().getProjectPersons()) {
            if(ContactRole.PI_CODE.equals(person.getRoleCode())) {
                awardPerson = (AwardPerson) person;
                break;
            }
        }
        return awardPerson;
    }
    
    private AwardPersonUnitRuleAddEvent generateAddPersonUnitEvent(AwardPerson projectPerson, int addUnitPersonIndex) {
        return new AwardPersonUnitRuleAddEvent("AwardPersonUnitRuleAddEvent", "projectPersonnelBean.newAwardPersonUnit", getDocument(), 
                projectPerson, newAwardPersonUnits[addUnitPersonIndex], addUnitPersonIndex);
    }

    private AwardProjectPersonRuleAddEvent generateAddProjectPersonEvent() {
        return new AwardProjectPersonRuleAddEvent("AddAwardProjectPersonRuleEvent", "projectPersonnelBean.newAwardContact", getDocument(), 
                                                    (AwardPerson) newAwardContact);
    }

    private void initNewAwardPersonUnits() {
        newAwardPersonUnits = new AwardPersonUnit[getAward().getProjectPersons().size()];
        int personIndex = 0;
        for(AwardPerson p: getAward().getProjectPersons()) {
            newAwardPersonUnits[personIndex++] = new AwardPersonUnit(p);
        }
    }

    /**
     * @param awardPersonUnit
     */
    private void lazyLoadUnit(AwardPersonUnit awardPersonUnit) {
        if(awardPersonUnit.getUnitNumber() != null && awardPersonUnit.getUnit() == null) {
            Map<String, Object> identifiers = new HashMap<String, Object>();
            identifiers.put("unitNumber", awardPersonUnit.getUnitNumber());
            Unit newUnit = (Unit) getBusinessObjectService().findByPrimaryKey(Unit.class, identifiers);
            awardPersonUnit.setUnit(newUnit);
        }
    }
    
    private void setLeadUnitSelectionStates(String unitName) {
        AwardPerson awardPerson = findPrincipalInvestigator();
        if(awardPerson != null) {
            for(AwardPersonUnit associatedUnit: awardPerson.getUnits()) {                
                associatedUnit.setLeadUnit(unitName.equals(associatedUnit.getUnit().getUnitName()));
            }
        }
    }
    
    public void updateLeadUnit() {
        Award award = awardForm.getAwardDocument().getAward();
        AwardPerson pi = findPrincipalInvestigator();
        if (pi == null) {
            return;
        }
        String leadUnitNumber = award.getLeadUnitNumber();
        boolean foundLeadUnit = false;
        for (AwardPersonUnit curUnit : pi.getUnits()) {
            if (StringUtils.equals(curUnit.getUnitNumber(), leadUnitNumber)) {
                if (!curUnit.isLeadUnit()) {
                    curUnit.setLeadUnit(true);
                    award.refreshReferenceObject("leadUnit");
                }
                foundLeadUnit = true;
            } else {
                curUnit.setLeadUnit(false);
            }
        }
        if (!foundLeadUnit) {
            AwardPersonUnit newLeadUnit = new AwardPersonUnit();
            newLeadUnit.setUnitNumber(leadUnitNumber);
            newLeadUnit.setLeadUnit(true);
            pi.add(newLeadUnit);
            award.refreshReferenceObject("leadUnit");
        }
    }   
    
    public void addUnitDetails(AwardPerson person) {
        person.setOptInUnitStatus(true);
        if (person.getPerson() != null && person.getPerson().getUnit() != null) {
            person.add(new AwardPersonUnit(person, person.getPerson().getUnit(), true));
        }
    }
    
    public void removeUnitDetails(AwardPerson person) {
        person.setOptInUnitStatus(false);
        person.getUnits().clear();
        person.getCreditSplits().clear();
    }
}
