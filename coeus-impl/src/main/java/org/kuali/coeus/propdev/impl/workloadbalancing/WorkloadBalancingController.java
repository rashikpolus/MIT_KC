/**
 * Copyright 2005-2014 The Kuali Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.opensource.org/licenses/ecl2.php
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.kuali.coeus.propdev.impl.workloadbalancing;


import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.kuali.coeus.common.framework.person.KcPerson;
import org.kuali.coeus.common.framework.person.KcPersonService;
import org.kuali.coeus.common.framework.unit.Unit;
import org.kuali.coeus.common.framework.unit.admin.UnitAdministrator;
import org.kuali.coeus.common.impl.sponsor.hierarchy.SponsorHierarchyDao;
import org.kuali.coeus.sys.framework.service.KcServiceLocator;
import org.kuali.rice.core.api.criteria.OrderByField;
import org.kuali.rice.core.api.criteria.OrderDirection;
import org.kuali.rice.core.api.criteria.QueryByCriteria;
import org.kuali.rice.core.api.criteria.QueryResults;
import org.kuali.rice.krad.data.PersistenceOption;
import org.kuali.rice.krad.uif.UifParameters;
import org.kuali.rice.krad.uif.field.AttributeQueryResult;
import org.kuali.rice.krad.uif.util.ObjectPropertyUtils;
import org.kuali.rice.krad.web.controller.MethodAccessible;
import org.kuali.rice.krad.web.form.UifFormBase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import edu.mit.kc.workloadbalancing.bo.AbsenteeWrapper;
import edu.mit.kc.workloadbalancing.bo.WlAbsentee;
import edu.mit.kc.workloadbalancing.bo.WlCapacity;
import edu.mit.kc.workloadbalancing.bo.WlFlexibility;
import edu.mit.kc.workloadbalancing.bo.WlSimCapacity;
import edu.mit.kc.workloadbalancing.bo.WlSimFlexibility;
import edu.mit.kc.workloadbalancing.bo.WlSimHeader;
import edu.mit.kc.workloadbalancing.bo.WlSimUnitAssignment;
import edu.mit.kc.workloadbalancing.bo.WorkloadBalancing;
import edu.mit.kc.workloadbalancing.core.WorkloadForm;
import edu.mit.kc.workloadbalancing.sim.WorkloadSimulatorService;
import edu.mit.kc.workloadbalancing.util.WorkloadUtils;

@Controller("workloadBalancingController")
@RequestMapping(value = "/workloadbalancing")
public class WorkloadBalancingController extends WorkloadBalancingControllerBase {

    @Autowired
    @Qualifier("kcPersonService")
    private KcPersonService kcPersonService;

    @Autowired
    @Qualifier("sponsorHierarchyDao")
    private SponsorHierarchyDao sponsorHierarchyDao;

    private static final String WL_UNIT_ADMIN_TYPE_CODE = "2";
    private static final String WL_HIERARCHY_NAME = "Workload Balancing";
    private static final String PERSON_ID = "personId";
    private static final String UNIT_NUMBER = "unitNumber";
    private static final String UNIT_ADMIN_TYPE_CODE = "unitAdministratorTypeCode";

    @Transactional
    @RequestMapping(params = "methodToCall=defaultMapping")
    public ModelAndView defaultMapping(
            @ModelAttribute("KualiForm") WorkloadForm form,
            BindingResult result, HttpServletRequest request,
            HttpServletResponse response) {
        return getTransactionalDocumentControllerService().start(form);
    }

    protected UifFormBase createInitialForm(HttpServletRequest request) {
        WorkloadForm form = new WorkloadForm();
        return form;
    }

    @Transactional
    @RequestMapping(params = "methodToCall=start")
    public ModelAndView start(
            @ModelAttribute("KualiForm") WorkloadForm form){
    	boolean canView=hasEditPermission(form);
    	form.setHasAccess(canView);
    	if(!canView){
        form.setCanEdit(false);
        getGlobalVariableService().getMessageMap().putError("Workload-Table", "workload.error.authorization");
    	}
    	// Get collection of sponsors
    	List<String> sponsors = getSponsorHierarchyDao().getUniqueNamesAtLevel(WL_HIERARCHY_NAME, 1);
        Collections.sort(sponsors);
        form.setSponsors(sponsors);

        // Build initial items
        updateWorkloadItems(form);

        return getRefreshControllerService().refresh(form);
    }

    @ModelAttribute(value = "KualiForm")
    public UifFormBase initForm(HttpServletRequest request,
                                HttpServletResponse response) throws Exception {
        UifFormBase form = getKcCommonControllerService().initForm(
                this.createInitialForm(request), request, response);
        return form;
    }

    /**
     * Updates the workload informaton used in the workload balancing table to the most recent data from either the
     * in memory simulation data or current data from the database.
     *
     * @param form
     */
    private void updateWorkloadItems(WorkloadForm form) {
        form.getWorkloadLineItems().clear();

        List<WlCapacity> capacities = findAll(WlCapacity.class, form);
        WorkloadBalancing workloadLineItem;

        for (WlCapacity capacity : capacities) {
            workloadLineItem = new WorkloadBalancing();
            workloadLineItem.setAdminId(capacity.getPersonId());
            workloadLineItem.setWlCapacity(capacity);

            HashMap<String, String> criteria = new HashMap<String, String>();
            criteria.put(PERSON_ID, capacity.getPersonId());
            List<WlFlexibility> flexibilities = findMatching(WlFlexibility.class, criteria, form);
            flexibilities = new ArrayList<>(flexibilities);
            workloadLineItem.setWlflexibilityList(flexibilities);

            KcPerson person = kcPersonService.getKcPersonByPersonId(capacity.getPersonId());
            workloadLineItem.setPersonName(person.getLastName() + ", " + person.getFirstName());
            workloadLineItem.setUserName(person.getUserName());

            List<WlAbsentee> absences = getDataObjectService().findMatching(WlAbsentee.class,
                    QueryByCriteria.Builder.andAttributes(criteria).build()).getResults();

            Date currentDate = new Date();
            for (WlAbsentee absence : absences) {
                if (currentDate.getTime() > absence.getLeaveStartDate().getTime()
                        && currentDate.getTime() < absence.getLeaveEndDate().getTime()) {
                    workloadLineItem.setCurrentlyAbsent(true);
                    break;
                }
            }

            // Create flexibilities if a flexibility does not exist for all sponsors
            if (flexibilities.size() < form.getSponsors().size()) {

                for (String sponsor : form.getSponsors()) {
                    boolean sponsorFound = false;
                    for (WlFlexibility flexibility : flexibilities) {
                        if (flexibility.getSponsorGroup().equals(sponsor)) {
                            sponsorFound = true;
                            break;
                        }
                    }

                    if (!sponsorFound) {
                        WlFlexibility newFlexibility = new WlFlexibility();
                        newFlexibility.setPersonId(capacity.getPersonId());
                        newFlexibility.setSponsorGroup(sponsor);

                        if (!form.isSimulationMode()) {
                            getDataObjectService().save(newFlexibility);
                        }

                        flexibilities.add(newFlexibility);
                    }
                }
            }

            Collections.sort(flexibilities, new Comparator<WlFlexibility>() {
                @Override
                public int compare(WlFlexibility o1, WlFlexibility o2) {
                    return o1.getSponsorGroup().compareTo(o2.getSponsorGroup());
                }
            });

            form.getWorkloadLineItems().add(workloadLineItem);
        }
    }

    /**
     * The refresh method of processes the refreshes of the workload components and retrieves/sets data related to those
     * components
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=refresh")
    public ModelAndView refresh(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String refreshId = request.getParameter("updateComponentId");
        String editLineItem = request.getParameter("editLineItem");

        // Check for component being refreshed by id
        if (refreshId.equals("Workload-Table") || refreshId.equals("WorkloadBalancing-Page")) {
            // Make sure data is latest
            updateWorkloadItems(form);

        } else if (StringUtils.isNotBlank(editLineItem)) {
            int index = Integer.valueOf(editLineItem);
            form.setWorkloadLineItemEdit(form.getWorkloadLineItems().get(index));
            String personId = form.getWorkloadLineItemEdit().getWlCapacity().getPersonId();

            if (refreshId.equals("Workload-Unit-Edit")) {
                updateUnitAssignmentList(form, personId);
            } else if (refreshId.equals("Workload-Absentee-Edit")) {
                updateAbsenteeList(form, personId);
            }

        } else if (refreshId.equals("Workload-Unit-AssignedTo_add")) {
            form.setUnitAssignedTo("");
            Map<String, String> criteria = new HashMap<String, String>();
            Object newLine = form.getNewCollectionLines().get("unitListEdit");
            // Fill out currently assigned to list by matching unit selected to UnitAdministrators which may exist
            if (newLine != null) {
                String unitNumber = ((UnitAdministrator) newLine).getUnitNumber();
                criteria.put(UNIT_NUMBER, unitNumber);
                criteria.put(UNIT_ADMIN_TYPE_CODE, WL_UNIT_ADMIN_TYPE_CODE);
                List<UnitAdministrator> unitAssignments = findMatching(UnitAdministrator.class, criteria, form);

                String assignedTo = "";
                for (UnitAdministrator unitAdmin : unitAssignments) {
                    if (StringUtils.isBlank(unitAdmin.getPersonId())) {
                        continue;
                    }

                    KcPerson person = getKcPersonService().getKcPersonByPersonId(unitAdmin.getPersonId());
                    if (person == null) {
                        continue;
                    }

                    assignedTo = assignedTo + person.getFullName() + "(" + person.getUserName() + "), ";
                }

                if (StringUtils.isNotBlank(assignedTo)) {
                    assignedTo = "Unit currently assigned to: " + assignedTo;
                    assignedTo = StringUtils.removeEnd(assignedTo, ", ");
                    form.setUnitAssignedTo(assignedTo);
                }
            }
        } else if (refreshId.equals("Workload-ReassignUnit-Dialog")) {
            String reassignUnitItem = request.getParameter("reassignUnitItem");
            if (reassignUnitItem != null) {
                //Fresh dialog so reset data
                int index = Integer.valueOf(reassignUnitItem);
                UnitAdministrator unit = form.getUnitListEdit().get(index);
                form.setUnitAssignmentEdit(unit);
                form.setUnitAssignmentEditIndex(index);
                form.getReassignPersonInfo().setTempPersonId("");
                form.getReassignPersonInfo().setTempPersonName("");
                form.getReassignPersonInfo().setTempUserName("");

            } else if (!StringUtils.isBlank(form.getReassignPersonInfo().getTempUserName())) {
                // Dialog has been edited so find person
                KcPerson person = kcPersonService.getKcPersonByUserName(form.getReassignPersonInfo().getTempUserName());
                if (person != null) {
                    form.getReassignPersonInfo().setTempPersonName(person.getFullName());
                    form.getReassignPersonInfo().setTempPersonId(person.getPersonId());
                }
            }

        } else if (refreshId.equals("Workload-Add-Dialog")
                && StringUtils.isNotBlank(form.getAddPersonInfo().getTempUserName())) {
            KcPerson person = kcPersonService.getKcPersonByUserName(form.getAddPersonInfo().getTempUserName());

            if (person != null) {
                // Dialog has been edited
                form.getAddPersonInfo().setTempPersonId(person.getPersonId());
                form.getAddPersonInfo().setTempPersonName(person.getFullName());

            } else {
                //Fresh dialog
                form.getAddPersonInfo().setTempPersonId("");
                form.getAddPersonInfo().setTempPersonName("");
            }
        } else if (refreshId.equals("Workload-AbsenceEdit-Dialog")) {
            String absenceItemIndex = request.getParameter("absenceEditItem");
            int index = Integer.valueOf(absenceItemIndex);
            AbsenteeWrapper absenteeWrapper = form.getAbsenteeListEdit().get(index);
            form.setAbsenteeEdit(absenteeWrapper);
        }

        return getRefreshControllerService().refresh(form);
    }

    /**
     * Update the Unit assignment list with the latest data
     *
     * @param form
     * @param personId
     */
    private void updateUnitAssignmentList(WorkloadForm form, String personId) {
        form.getUnitListEdit().clear();
        Map<String, String> criteria = new HashMap<String, String>();
        criteria.put(PERSON_ID, personId);
        criteria.put(UNIT_ADMIN_TYPE_CODE, WL_UNIT_ADMIN_TYPE_CODE);
        List<UnitAdministrator> unitAssignments = findMatching(UnitAdministrator.class, criteria, form);

        form.getUnitListEdit().addAll(unitAssignments);
    }

    /**
     * Update the absentee list with the latest data
     *
     * @param form
     * @param personId
     */
    private void updateAbsenteeList(WorkloadForm form, String personId) {
        form.getAbsenteeListEdit().clear();
        Map<String, Object> criteria = new HashMap<String, Object>();
        criteria.put(PERSON_ID, personId);
        OrderByField sort = OrderByField.Builder.create("leaveStartDate", OrderDirection.DESCENDING).build();
        QueryResults<WlAbsentee> absentees = getDataObjectService().findMatching(WlAbsentee.class,
                QueryByCriteria.Builder.andAttributes(criteria).setOrderByFields(sort).build());

        for (WlAbsentee absentee : absentees.getResults()) {
            AbsenteeWrapper absenteeWrapper = new AbsenteeWrapper(absentee);
            absenteeWrapper.setLeaveStartHour(WorkloadUtils.translateDateToTimeKey(absentee.getLeaveStartDate()));
            absenteeWrapper.setLeaveEndHour(WorkloadUtils.translateDateToTimeKey(absentee.getLeaveEndDate()));
            form.getAbsenteeListEdit().add(absenteeWrapper);
        }
    }

    /** Contract Administrator actions **/

    /**
     * Add an administrator which adds new capacity and flexibility objects for that person by id
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=addAdministrator")
    public ModelAndView addAdministrator(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String personId = null;
        KcPerson person = null;
        if (!StringUtils.isBlank(form.getAddPersonInfo().getTempUserName())) {
            person = kcPersonService.getKcPersonByUserName(form.getAddPersonInfo().getTempUserName());
            if (person != null) {
                personId = person.getPersonId();
            }
        }

        // Show message for missing person
        if (StringUtils.isBlank(personId)) {
            getGlobalVariableService().getMessageMap().putError("addPersonInfo.tempUserName", "workload.error.missingPerson");
            form.setUpdateComponentId("Workload-Add-Dialog");
            return getRefreshControllerService().refresh(form);
        }

        // Find any capacity item that may exist for this person, if one show error
        HashMap<String, String> attributes = new HashMap<String, String>();
        attributes.put(PERSON_ID, personId);
        List<WlCapacity> existingCapacity = findMatching(WlCapacity.class, attributes, form);

        // Show message for duplicate person
        if (!existingCapacity.isEmpty()) {
            getGlobalVariableService().getMessageMap().putError("addPersonInfo.tempUserName", "workload.error.duplicatePerson");
            form.setUpdateComponentId("Workload-Add-Dialog");
            return getRefreshControllerService().refresh(form);
        }

        WorkloadBalancing workloadLineItem = new WorkloadBalancing();

        WlCapacity newCapacity = new WlCapacity();
        newCapacity.setPersonId(personId);
        newCapacity.setCapacity(0);

        // if not in simulation mode, save directly to the database
        if (!form.isSimulationMode()) {
            newCapacity = getDataObjectService().save(newCapacity, PersistenceOption.FLUSH);
        }
        
        WlSimHeader wlSimHeader = new WlSimHeader();
		wlSimHeader.setStatusCode("2");
		wlSimHeader.setSimId("15");
		
		wlSimHeader = getDataObjectService().save(wlSimHeader,PersistenceOption.FLUSH);

        workloadLineItem.setWlflexibilityList(new ArrayList<WlFlexibility>());

        // Add a flexibility item for each sponsor which exists for Workload Balancing
        for (String sponsor : form.getSponsors()) {
            WlFlexibility newFlexibility = new WlFlexibility();
            newFlexibility.setPersonId(personId);
            newFlexibility.setSponsorGroup(sponsor);

            if (!form.isSimulationMode()) {
                newFlexibility = getDataObjectService().save(newFlexibility);
            }

            workloadLineItem.getWlflexibilityList().add(newFlexibility);
        }

        if (!form.isSimulationMode()) {
            getDataObjectService().flush(WlFlexibility.class);
        }

        workloadLineItem.setWlCapacity(newCapacity);
        workloadLineItem.setAdminId(personId);
        workloadLineItem.setPersonName(person.getLastName() + ", " + person.getFirstName());
        workloadLineItem.setUserName(person.getUserName());

        HashMap<String, BigDecimal> fcInput = new HashMap<>();

        // Add the new workload item
        form.getWorkloadLineItems().add(workloadLineItem);

        // Reset temporary person data for add dialog
        form.getAddPersonInfo().setTempPersonId("");
        form.getAddPersonInfo().setTempPersonName("");
        form.getAddPersonInfo().setTempUserName("");

        // Update the data in the simulation if in simulation mode
        if (form.isSimulationMode()) {
            updateFlexCapacitySimulationData(form);
        }

        return getRefreshControllerService().refresh(form);
    }

    /**
     * Delete the Contract administrator and all related data for Workload Balancing
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=deleteAdministrator")
    public ModelAndView deleteAdministrator(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String deleteLineItem = request.getParameter("deleteLineItem");
        WorkloadBalancing lineItem = form.getWorkloadLineItems().get(Integer.valueOf(deleteLineItem));

        // Delete from database if not in simulation mode
        if (!form.isSimulationMode()) {
            // Delete capacity and flexibility
            getDataObjectService().delete(lineItem.getWlCapacity());
            for (WlFlexibility flexibility : lineItem.getWlflexibilityList()) {
                getDataObjectService().delete(flexibility);
            }

            // Delete absentee information
            Map<String, Object> criteria = new HashMap<String, Object>();
            criteria.put(PERSON_ID, lineItem.getAdminId());
            getDataObjectService().deleteMatching(WlAbsentee.class,
                    QueryByCriteria.Builder.andAttributes(criteria).build());

            // Delete unit administrator entries
            criteria.put(UNIT_ADMIN_TYPE_CODE, WL_UNIT_ADMIN_TYPE_CODE);
            getDataObjectService().deleteMatching(UnitAdministrator.class,
                    QueryByCriteria.Builder.andAttributes(criteria).build());
        }

        // Remove the line from the form
        form.getWorkloadLineItems().remove(lineItem);

        // Update the data in the simulation if in simulation mode
        if (form.isSimulationMode()) {
            updateFlexCapacitySimulationData(form);
        }

        return getRefreshControllerService().refresh(form);
    }

    /**
     * Save flexibility and capacity changes for Contract Administrator
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=saveFlexCapacity")
    public ModelAndView saveFlexCapacity(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        WlCapacity capacity = form.getWorkloadLineItemEdit().getWlCapacity();

        if (!form.isSimulationMode()) {
            getDataObjectService().save(capacity);

            List<WlFlexibility> flexibilityList = form.getWorkloadLineItemEdit().getWlflexibilityList();
            for (WlFlexibility flexibility : flexibilityList) {
                getDataObjectService().save(flexibility);
            }
        } else {
            updateFlexCapacitySimulationData(form);
        }

        return getModelAndViewService().getModelAndView(form);
    }

    /**
     * Absentee related controller methods
     */

    /**
     * Add an absence for a person
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=addAbsence")
    public ModelAndView addAbsence(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String personId = form.getWorkloadLineItemEdit().getWlCapacity().getPersonId();
        AbsenteeWrapper wrapper = (AbsenteeWrapper) form.getNewCollectionLines().get("absenteeListEdit");

        WlAbsentee newAbsentee = wrapper.getAbsentee();
        newAbsentee.setPersonId(personId);

        // Translate the time into the date value and set
        newAbsentee.setLeaveStartDate(WorkloadUtils.translateTimeToDate(newAbsentee.getLeaveStartDate(), wrapper.getLeaveStartHour()));
        newAbsentee.setLeaveEndDate(WorkloadUtils.translateTimeToDate(newAbsentee.getLeaveEndDate(), wrapper.getLeaveEndHour()));

        if (newAbsentee.getLeaveEndDate().getTime() < newAbsentee.getLeaveStartDate().getTime()) {
            form.getAbsenteeListEdit().remove(wrapper);
            getGlobalVariableService().getMessageMap().putError("newCollectionLines['absenteeListEdit'].absentee.leaveEndDate", "workload.error.endDateLessThanStart");
            form.setUpdateComponentId("Workload-Absentee-Add-Dialog");
            return getRefreshControllerService().refresh(form);
        } else if (newAbsentee.getLeaveStartDate().getTime() < System.currentTimeMillis()) {
            form.getAbsenteeListEdit().remove(wrapper);
            getGlobalVariableService().getMessageMap().putError("newCollectionLines['absenteeListEdit'].absentee.leaveStartDate", "workload.error.startDateLessThanToday");
            form.setUpdateComponentId("Workload-Absentee-Add-Dialog");
            return getRefreshControllerService().refresh(form);
        }

        ModelAndView modelAndView = getCollectionControllerService().addLine(form);
        //AbsenteeWrapper wrapper = ((AbsenteeWrapper) form.getAddedCollectionItems().get(form.getAddedCollectionItems().size() - 1));

        getDataObjectService().save(newAbsentee);

        updateAbsenteeList(form, personId);

        return modelAndView;
    }


    /**
     * Delete an absence
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=deleteAbsence")
    public ModelAndView deleteAbsence(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        int selectedLineIndex;
        String selectedLine = form.getActionParamaterValue(UifParameters.SELECTED_LINE_INDEX);

        if (StringUtils.isNotBlank(selectedLine)) {
            selectedLineIndex = Integer.parseInt(selectedLine);
        } else {
            selectedLineIndex = -1;
        }

        getDataObjectService().delete(form.getAbsenteeListEdit().get(selectedLineIndex).getAbsentee());
        ModelAndView modelAndView = getCollectionControllerService().deleteLine(form);

        return modelAndView;
    }

    /**
     * Update an absence with new data
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=updateAbsence")
    public ModelAndView updateAbsence(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        AbsenteeWrapper wrapper = form.getAbsenteeEdit();
        String personId = wrapper.getAbsentee().getPersonId();

        WlAbsentee updatedAbsentee = wrapper.getAbsentee();
        updatedAbsentee.setPersonId(personId);

        // Translate the time into the date value and set
        updatedAbsentee.setLeaveStartDate(WorkloadUtils.translateTimeToDate(updatedAbsentee.getLeaveStartDate(), wrapper.getLeaveStartHour()));
        updatedAbsentee.setLeaveEndDate(WorkloadUtils.translateTimeToDate(updatedAbsentee.getLeaveEndDate(), wrapper.getLeaveEndHour()));

        if (updatedAbsentee.getLeaveEndDate().getTime() < updatedAbsentee.getLeaveStartDate().getTime()) {
            getGlobalVariableService().getMessageMap().putError("absenteeEdit.absentee.leaveEndDate", "workload.error.endDateLessThanStart");
            form.setUpdateComponentId("Workload-AbsenceEdit-Dialog");
            return getRefreshControllerService().refresh(form);
        }  else if (updatedAbsentee.getLeaveStartDate().getTime() < System.currentTimeMillis()) {
            getGlobalVariableService().getMessageMap().putError("absenteeEdit.absentee.leaveStartDate", "workload.error.startDateLessThanToday");
            form.setUpdateComponentId("Workload-AbsenceEdit-Dialog");
            return getRefreshControllerService().refresh(form);
        }

        getDataObjectService().save(updatedAbsentee);

        return getRefreshControllerService().refresh(form);
    }

    /**
     * Unit assignment controller methods *
     */

    /**
     * Add a new unit administrator for the unit selected
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=addUnitAssignment")
    public ModelAndView addUnitAssignment(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String personId = form.getWorkloadLineItemEdit().getWlCapacity().getPersonId();

        UnitAdministrator newLine = (UnitAdministrator) form.getNewCollectionLines().get("unitListEdit");
        Unit unit = getDataObjectService().find(Unit.class, newLine.getUnitNumber());

        // Show error message for bad unit number
        if (unit == null) {
            form.setUpdateComponentId("Workload-Unit-Add-Dialog");
            getGlobalVariableService().getMessageMap().putError("newCollectionLines['unitListEdit'].unitNumber",
                    "workload.error.badUnit");
            return getRefreshControllerService().refresh(form);
        }

        ModelAndView modelAndView = getCollectionControllerService().addLine(form);
        UnitAdministrator newAssignment = ((UnitAdministrator) form.getAddedCollectionItems().get(form.getAddedCollectionItems().size() - 1));

        newAssignment.setPersonId(personId);
        newAssignment.setUnitAdministratorTypeCode(WL_UNIT_ADMIN_TYPE_CODE);

        // Save new unit admin data
        if (form.isSimulationMode()) {
            addUnitAssignmentSimulationData(form, newAssignment);
        } else {
            getDataObjectService().save(newAssignment);
        }

        updateUnitAssignmentList(form, personId);

        return modelAndView;
    }

    /**
     * Delete the unit administrator data for a person for a unit
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=deleteUnitAssignment")
    public ModelAndView deleteUnitAssignment(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        int selectedLineIndex;
        String selectedLine = form.getActionParamaterValue(UifParameters.SELECTED_LINE_INDEX);
        if (StringUtils.isNotBlank(selectedLine)) {
            selectedLineIndex = Integer.parseInt(selectedLine);
        } else {
            selectedLineIndex = -1;
        }

        UnitAdministrator unitAssignment = form.getUnitListEdit().get(selectedLineIndex);

        if (form.isSimulationMode()) {
            deleteUnitAssignmentSimulationData(form, unitAssignment);
        } else {
            getDataObjectService().delete(unitAssignment);
        }

        ModelAndView modelAndView = getCollectionControllerService().deleteLine(form);
        return modelAndView;
    }

    /**
     * Reassign a unit to another administrator
     *
     * @param form
     * @param result
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
    @Transactional
    @RequestMapping(params = "methodToCall=reassignUnitAssignment")
    public ModelAndView reassignUnitAssignment(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String personId = null;
        KcPerson person = null;
        if (!StringUtils.isBlank(form.getReassignPersonInfo().getTempUserName())) {
            person = kcPersonService.getKcPersonByUserName(form.getReassignPersonInfo().getTempUserName());
            if (person != null) {
                personId = person.getPersonId();
            }
        }

        // Show error message for bad username
        if (StringUtils.isBlank(personId)) {
            getGlobalVariableService().getMessageMap().putError("reassignPersonInfo.tempUserName", "workload.error.missingPerson");
            form.setUpdateComponentId("Workload-ReassignUnit-Dialog");
            return getRefreshControllerService().refresh(form);
        }

        UnitAdministrator editedUnitAssignment = form.getUnitListEdit().get(form.getUnitAssignmentEditIndex());
        editedUnitAssignment.setUnitAdministratorTypeCode(WL_UNIT_ADMIN_TYPE_CODE);

        // When in simulation mode change the data directly, otherwise delete the old data and save the new
        // administrator to the db
        if (form.isSimulationMode()) {
            editedUnitAssignment.setPersonId(personId);
            reassignUnitAssignmentSimulationData(form, form.getWorkloadLineItemEdit().getAdminId(), editedUnitAssignment);
        } else {
            // Delete old assignment
            editedUnitAssignment.setPersonId(form.getWorkloadLineItemEdit().getAdminId());
            getDataObjectService().delete(editedUnitAssignment);

            // Save new assignment
            editedUnitAssignment = new UnitAdministrator();
            editedUnitAssignment.setPersonId(personId);
            editedUnitAssignment.setUnitNumber(form.getUnitAssignmentEdit().getUnitNumber());
            editedUnitAssignment.setUnitAdministratorTypeCode(WL_UNIT_ADMIN_TYPE_CODE);
            getDataObjectService().save(editedUnitAssignment, PersistenceOption.FLUSH);


        }

        form.getUnitListEdit().remove(form.getUnitAssignmentEditIndex());

        return getRefreshControllerService().refresh(form);
    }

    /**
     * Simulation controller methods *
     */

    @Transactional
    @RequestMapping(params = "methodToCall=enterSimulationMode")
    public ModelAndView enterSimulationMode(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
    	if(hasSimulationPermission()){
        form.setSimulationMode(true);
        copyCurrentWorkloadToSimulation(form);
        getGlobalVariableService().getMessageMap().putInfoForSectionId("Workload-Table", "workload.info.simulationFromCurrent");
    	}else{
    	getGlobalVariableService().getMessageMap().putInfoForSectionId("Workload-Table", "workload.info.simulationPermission");
    	}
        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=exitSimulationMode")
    public ModelAndView exitSimulationMode(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        form.setSimulationMode(false);
        updateWorkloadItems(form);

        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=saveSimulation")
    public ModelAndView saveSimulation(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        // Blank out all ids to force new entries
        for (WlSimCapacity simCapacity : form.getSimulation().getCapacities()) {
            simCapacity.setSimId(null);
            simCapacity.setCapacityId(null);
        }

        for (WlSimFlexibility simFlexibility : form.getSimulation().getFlexibilities()) {
            simFlexibility.setSimId(null);
            simFlexibility.setFlexibilityId(null);
        }

        for (WlSimUnitAssignment unitAssignment : form.getSimulation().getUnitAssignments()) {
            unitAssignment.setSimId(null);
            unitAssignment.setUnitAssignmentId(null);
        }

        form.getSimulation().setSimId(null);

        WlSimHeader savedSimulation = getDataObjectService().save(form.getSimulation());

        form.setSimulationSaved(true);

        form.getSimulation().setSimId(savedSimulation.getSimId());

        getGlobalVariableService().getMessageMap().putInfoForSectionId("Workload-Table", "workload.info.simulationSaved",
                "#" + savedSimulation.getSimId() + " - " + savedSimulation.getDescription());

        return runSimulation(form, result, request, response);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=runSimulation")
    public ModelAndView runSimulation(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        KcServiceLocator.getService(WorkloadSimulatorService.class).simulateWorkload(Integer.parseInt(form.getSimulation().getSimId()), form.getSimulation().getStartDate(),  form.getSimulation().getEndDate());
        return getRefreshControllerService().refresh(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=loadSimulation")
    public ModelAndView loadSimulation(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        WlSimHeader simulation = getDataObjectService().find(WlSimHeader.class, form.getSimulation().getSimId());

        if (simulation != null) {
            form.setSimulation(simulation);
        }

        updateWorkloadItems(form);
        getGlobalVariableService().getMessageMap().putInfoForSectionId("Workload-Table", "workload.info.simulationFromLoaded",
                "#" + form.getSimulation().getSimId() + " - " + form.getSimulation().getDescription());

        return getRefreshControllerService().refresh(form);
    }

    /** Data related helper methods **/

    /**
     * Copies the current workload items to a new simulation
     *
     * @param form
     */
    private void copyCurrentWorkloadToSimulation(WorkloadForm form) {
        form.setSimulation(new WlSimHeader());

        List<WlSimCapacity> simCapacities = new ArrayList<>();
        List<WlSimFlexibility> simFlexibilities = new ArrayList<>();
        List<WlSimUnitAssignment> simUnitAssignments = new ArrayList<>();

        for (WorkloadBalancing item : form.getWorkloadLineItems()) {
            simCapacities.add(new WlSimCapacity(item.getWlCapacity()));
            for (WlFlexibility flexibility : item.getWlflexibilityList()) {
                simFlexibilities.add(new WlSimFlexibility(flexibility));
            }
        }

        Map<String, Object> criteria = new HashMap<String, Object>();
        criteria.put(UNIT_ADMIN_TYPE_CODE, WL_UNIT_ADMIN_TYPE_CODE);
        QueryResults<UnitAdministrator> unitAssignments = getDataObjectService().findMatching(UnitAdministrator.class,
                QueryByCriteria.Builder.andAttributes(criteria).build());

        for (UnitAdministrator assignment : unitAssignments.getResults()) {
            simUnitAssignments.add(new WlSimUnitAssignment(assignment));
        }

        form.getSimulation().setCapacities(simCapacities);
        form.getSimulation().setFlexibilities(simFlexibilities);
        form.getSimulation().setUnitAssignments(simUnitAssignments);
    }

    /**
     * This method finds objects in simulation data if in simulation mode so it can be populated into
     * the workload form compatible objects, or returns the objects from the database if not in simulation mode.
     *
     * @param clazz
     * @param form
     * @param <T>
     * @return
     */
    private <T> List<T> findAll(Class<T> clazz, WorkloadForm form) {
        List<T> results = new ArrayList<>();
        if (form.isSimulationMode()) {
            if (clazz.equals(WlCapacity.class)) {
                for (WlSimCapacity capacity : form.getSimulation().getCapacities()) {
                    results.add(clazz.cast(new WlCapacity(capacity)));
                }
            } else if (clazz.equals(WlFlexibility.class)) {
                for (WlSimFlexibility flexibility : form.getSimulation().getFlexibilities()) {
                    results.add(clazz.cast(new WlFlexibility(flexibility)));
                }

            } else if (clazz.equals(UnitAdministrator.class)) {
                for (WlSimUnitAssignment unitAssignment : form.getSimulation().getUnitAssignments()) {
                    UnitAdministrator unitAdministrator = new UnitAdministrator();
                    unitAdministrator.setPersonId(unitAssignment.getPersonId());
                    unitAdministrator.setUnitNumber(unitAssignment.getUnitNum());
                    unitAdministrator.setUnit(unitAssignment.getUnit());
                    unitAdministrator.setUnitAdministratorTypeCode(WL_UNIT_ADMIN_TYPE_CODE);
                    results.add(clazz.cast(unitAdministrator));
                }
            }
        } else {
            return getDataObjectService().findAll(clazz).getResults();
        }

        return results;
    }

    /**
     * This method finds the matching class in simulation data if in simulation mode so it can be populated into
     * the workload form compatible objects, or returns the objects from the database if not in simulation mode.
     *
     * @param clazz
     * @param criteria
     * @param form
     * @param <T>
     * @return
     */
    private <T> List<T> findMatching(Class<T> clazz, Map<String, String> criteria, WorkloadForm form) {
        List<T> results = new ArrayList<>();
        if (form.isSimulationMode()) {
            if (clazz.equals(WlCapacity.class)) {
                for (WlSimCapacity capacity : form.getSimulation().getCapacities()) {
                    if (matchesCriteria(capacity, criteria)) {
                        results.add(clazz.cast(new WlCapacity(capacity)));
                    }
                }
            } else if (clazz.equals(WlFlexibility.class)) {
                for (WlSimFlexibility flexibility : form.getSimulation().getFlexibilities()) {
                    if (matchesCriteria(flexibility, criteria)) {
                        results.add(clazz.cast(new WlFlexibility(flexibility)));
                    }
                }

            } else if (clazz.equals(UnitAdministrator.class)) {
                criteria.remove(UNIT_ADMIN_TYPE_CODE);
                for (WlSimUnitAssignment unitAssignment : form.getSimulation().getUnitAssignments()) {
                    if (matchesCriteria(unitAssignment, criteria)) {
                        UnitAdministrator unitAdministrator = new UnitAdministrator();
                        unitAdministrator.setPersonId(unitAssignment.getPersonId());
                        unitAdministrator.setUnitNumber(unitAssignment.getUnitNum());
                        unitAdministrator.setUnit(unitAssignment.getUnit());
                        unitAdministrator.setUnitAdministratorTypeCode(WL_UNIT_ADMIN_TYPE_CODE);
                        results.add(clazz.cast(unitAdministrator));
                    }
                }
            }
        } else {
            return getDataObjectService().findMatching(clazz,
                    QueryByCriteria.Builder.andAttributes(criteria).build()).getResults();
        }

        return results;
    }

    /**
     * Check to see if the object satisfies the criteria given
     *
     * @param object
     * @param criteria
     * @return
     */
    private boolean matchesCriteria(Object object, Map<String, String> criteria) {
        boolean match = true;
        for (String property : criteria.keySet()) {
            match = match && ObjectPropertyUtils.getPropertyValue(object, property).equals(criteria.get(property));
        }

        return match;
    }

    /**
     * Update flexibility and capacity data in simulation data in memory
     *
     * @param form
     */
    private void updateFlexCapacitySimulationData(WorkloadForm form) {
        List<WlSimCapacity> simCapacities = new ArrayList<>();
        List<WlSimFlexibility> simFlexibilities = new ArrayList<>();

        for (WorkloadBalancing item : form.getWorkloadLineItems()) {
            WlSimCapacity simCapacity = new WlSimCapacity(item.getWlCapacity());
            simCapacity.setCapacityId(item.getWlCapacity().getCapacityId());
            //simCapacity.setSimId(form.getSimulation().getSimId());
            simCapacities.add(simCapacity);

            for (WlFlexibility flexibility : item.getWlflexibilityList()) {
                WlSimFlexibility simFlexibility = new WlSimFlexibility(flexibility);
                simFlexibility.setFlexibilityId(flexibility.getFlexibilityId());
                //simFlexibility.setSimId(form.getSimulation().getSimId());

                simFlexibilities.add(simFlexibility);
            }
        }

        form.getSimulation().setCapacities(simCapacities);
        form.getSimulation().setFlexibilities(simFlexibilities);
    }

    /**
     * Delete unit assignment data in simulation data in memory
     *
     * @param workloadForm
     */
    private void deleteUnitAssignmentSimulationData(WorkloadForm workloadForm, UnitAdministrator unitAdministrator) {
        WlSimUnitAssignment itemToRemove = null;
        for (WlSimUnitAssignment unitAssignment : workloadForm.getSimulation().getUnitAssignments()) {
            if (unitAssignment.getPersonId().equals(unitAdministrator.getPersonId())
                    && unitAssignment.getUnitNum().equals(unitAdministrator.getUnitNumber())) {
                itemToRemove = unitAssignment;
                break;
            }
        }

        if (itemToRemove != null) {
            workloadForm.getSimulation().getUnitAssignments().remove(itemToRemove);
        }
    }

    /**
     * Add unit assignment data in simulation data in memory
     *
     * @param workloadForm
     */
    private void addUnitAssignmentSimulationData(WorkloadForm workloadForm, UnitAdministrator unitAdministrator) {
        WlSimUnitAssignment simUnitAssignment = new WlSimUnitAssignment(unitAdministrator);
        //simUnitAssignment.setSimId(workloadForm.getSimulation().getSimId());
        workloadForm.getSimulation().getUnitAssignments().add(simUnitAssignment);
    }

    /**
     * Update unit assignment data in simulation data in memory
     *
     * @param workloadForm
     * @param oldPersonId
     * @param newUnitAdministrator
     */
    private void reassignUnitAssignmentSimulationData(WorkloadForm workloadForm, String oldPersonId, UnitAdministrator newUnitAdministrator) {
        UnitAdministrator oldUnitAdministrator = new UnitAdministrator();
        oldUnitAdministrator.setPersonId(oldPersonId);
        oldUnitAdministrator.setUnitNumber(newUnitAdministrator.getUnitNumber());
        deleteUnitAssignmentSimulationData(workloadForm, oldUnitAdministrator);

        WlSimUnitAssignment simUnitAssignment = new WlSimUnitAssignment(newUnitAdministrator);
        //simUnitAssignment.setSimId(workloadForm.getSimulation().getSimId());

        workloadForm.getSimulation().getUnitAssignments().add(simUnitAssignment);
    }

    @MethodAccessible
    @Transactional
    @RequestMapping(params = "methodToCall=performFieldSuggest")
    public
    @ResponseBody
    AttributeQueryResult performFieldSuggest(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request,
                                             HttpServletResponse response) {
        return getQueryControllerService().performFieldSuggest(form);
    }

    @MethodAccessible
    @Transactional
    @RequestMapping(params = "methodToCall=performFieldQuery")
    public
    @ResponseBody
    AttributeQueryResult performFieldQuery(@ModelAttribute("KualiForm") WorkloadForm form, BindingResult result, HttpServletRequest request,
                                           HttpServletResponse response) {
        return getQueryControllerService().performFieldQuery(form);
    }

    @Transactional
    @RequestMapping(params = "methodToCall=retrieveEditLineDialog")
    public ModelAndView retrieveEditLineDialog(UifFormBase form) {
        return getCollectionControllerService().retrieveEditLineDialog(form);
    }

    public KcPersonService getKcPersonService() {
        return kcPersonService;
    }

    public void setKcPersonService(KcPersonService kcPersonService) {
        this.kcPersonService = kcPersonService;
    }


    public SponsorHierarchyDao getSponsorHierarchyDao() {
        return sponsorHierarchyDao;
    }

    public void setSponsorHierarchyDao(SponsorHierarchyDao sponsorHierarchyDao) {
        this.sponsorHierarchyDao = sponsorHierarchyDao;
    }
}
