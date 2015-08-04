package edu.mit.kc.workloadbalancing.core;

import edu.mit.kc.workloadbalancing.bo.*;
import org.kuali.coeus.common.framework.unit.admin.UnitAdministrator;
import org.kuali.rice.krad.web.form.UifFormBase;

import java.util.ArrayList;
import java.util.List;

public class WorkloadForm extends UifFormBase {
    private List<WorkloadBalancing> workloadLineItems = new ArrayList<WorkloadBalancing>();

    // Simulation variables
    private boolean simulationMode;
    private WlSimHeader simulation = new WlSimHeader();
    private boolean simulationSaved = false;

    // Line Item editing variables
    private WorkloadBalancing workloadLineItemEdit = new WorkloadBalancing();
    private boolean canEdit=false;
    private boolean hasAccess=false;

    private List<String> sponsors = new ArrayList<String>();

    // Person editing variables
    private TempPersonInfo addPersonInfo = new TempPersonInfo();
    private TempPersonInfo reassignPersonInfo = new TempPersonInfo();

    // Unit editing variables
    private List<UnitAdministrator> unitListEdit = new ArrayList<UnitAdministrator>();
    private String unitAssignedTo;

    // Unit Reassignment editing variables
    private UnitAdministrator unitAssignmentEdit = new UnitAdministrator();
    private int unitAssignmentEditIndex;

    // Absentee editing variables
    private List<AbsenteeWrapper> absenteeListEdit = new ArrayList<>();
    private AbsenteeWrapper absenteeEdit = new AbsenteeWrapper();

    public List<WorkloadBalancing> getWorkloadLineItems() {
        return workloadLineItems;
    }

    public void setWorkloadLineItems(
            List<WorkloadBalancing> workloadLineItems) {
        this.workloadLineItems = workloadLineItems;
    }

    public boolean isSimulationMode() {
        return simulationMode;
    }

    public void setSimulationMode(boolean isSimulationMode) {
        this.simulationMode = isSimulationMode;
    }

    public WlSimHeader getSimulation() {
        return simulation;
    }

    public void setSimulation(WlSimHeader simulation) {
        this.simulation = simulation;
    }

    public boolean isSimulationSaved() {
        return simulationSaved;
    }

    public void setSimulationSaved(boolean simulationSaved) {
        this.simulationSaved = simulationSaved;
    }

    public List<String> getSponsors() {
        return sponsors;
    }

    public void setSponsors(List<String> sponsors) {
        this.sponsors = sponsors;
    }

    public TempPersonInfo getAddPersonInfo() {
        return addPersonInfo;
    }

    public void setAddPersonInfo(TempPersonInfo addPersonInfo) {
        this.addPersonInfo = addPersonInfo;
    }

    public TempPersonInfo getReassignPersonInfo() {
        return reassignPersonInfo;
    }

    public void setReassignPersonInfo(TempPersonInfo reassignPersonInfo) {
        this.reassignPersonInfo = reassignPersonInfo;
    }

    public WorkloadBalancing getWorkloadLineItemEdit() {
        return workloadLineItemEdit;
    }

    public void setWorkloadLineItemEdit(WorkloadBalancing workloadLineItemEdit) {
        this.workloadLineItemEdit = workloadLineItemEdit;
    }

    public List<UnitAdministrator> getUnitListEdit() {
        return unitListEdit;
    }

    public void setUnitListEdit(List<UnitAdministrator> unitListEdit) {
        this.unitListEdit = unitListEdit;
    }

    public String getUnitAssignedTo() {
        return unitAssignedTo;
    }

    public void setUnitAssignedTo(String unitAssignedTo) {
        this.unitAssignedTo = unitAssignedTo;
    }

    public UnitAdministrator getUnitAssignmentEdit() {
        return unitAssignmentEdit;
    }

    public void setUnitAssignmentEdit(UnitAdministrator unitAssignmentEdit) {
        this.unitAssignmentEdit = unitAssignmentEdit;
    }

    public int getUnitAssignmentEditIndex() {
        return unitAssignmentEditIndex;
    }

    public void setUnitAssignmentEditIndex(int unitAssignmentEditIndex) {
        this.unitAssignmentEditIndex = unitAssignmentEditIndex;
    }

    public List<AbsenteeWrapper> getAbsenteeListEdit() {
        return absenteeListEdit;
    }

    public void setAbsenteeListEdit(List<AbsenteeWrapper> absenteeListEdit) {
        this.absenteeListEdit = absenteeListEdit;
    }

    public AbsenteeWrapper getAbsenteeEdit() {
        return absenteeEdit;
    }

    public void setAbsenteeEdit(AbsenteeWrapper absenteeEdit) {
        this.absenteeEdit = absenteeEdit;
    }


    public boolean isCanEdit() {
		return canEdit;
	}

	public void setCanEdit(boolean canEdit) {
		this.canEdit = canEdit;
	}


	public boolean isHasAccess() {
		return hasAccess;
	}

	public void setHasAccess(boolean hasAccess) {
		this.hasAccess = hasAccess;
	}


	public class TempPersonInfo {
        private String tempPersonId = "";
        private String tempUserName = "";
        private String tempPersonName = "";

        public String getTempPersonId() {
            return tempPersonId;
        }

        public void setTempPersonId(String tempPersonId) {
            this.tempPersonId = tempPersonId;
        }

        public String getTempUserName() {
            return tempUserName;
        }

        public void setTempUserName(String tempUserName) {
            this.tempUserName = tempUserName;
        }

        public String getTempPersonName() {
            return tempPersonName;
        }

        public void setTempPersonName(String tempPersonName) {
            this.tempPersonName = tempPersonName;
        }
    }
}
