package org.kuali.coeus.common.training;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

public class TrainingModules extends KcPersistableBusinessObjectBase {

	/**
	 * This class for fetching training module object from database.
	 */
private static final long serialVersionUID = -7533720133936640896L;
private long trainingModulesId;
private String trainingCode;
private String moduleCode;
private String subModuleCode;
private String description;

public String getTrainingCode() {
	return trainingCode;
}
public void setTrainingCode(String trainingCode) {
	this.trainingCode = trainingCode;
}
public String getModuleCode() {
	return moduleCode;
}
public void setModuleCode(String moduleCode) {
	this.moduleCode = moduleCode;
}

public String getSubModuleCode() {
	return subModuleCode;
}
public void setSubModuleCode(String subModuleCode) {
	this.subModuleCode = subModuleCode;
}
public String getDescription() {
	return description;
}
public void setDescription(String description) {
	this.description = description;
}
public long getTrainingModulesId() {
	return trainingModulesId;
}
public void setTrainingModulesId(long trainingModulesId) {
	this.trainingModulesId = trainingModulesId;
}

}
