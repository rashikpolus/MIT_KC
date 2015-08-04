package edu.mit.kc.bo;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;

/**
 * This class is only for Krms functions lookup
 */

@Entity
@Table(name = "KRMS_FUNC_PARM_T")
public final class KrmsFunctionsParams extends KcPersistableBusinessObjectBase  {

	 @Id
     @Column(name = "FUNC_PARM_ID")
     private String functionParamId;
	
	 @Column(name = "NM")
	 private String namespace;
	  
	 @Column(name = "DESC_TXT")
	 private String description;
	  
	 @Column(name = "TYP")
	 private String type;
	  
	 @Column(name = "FUNC_ID")
	 private String id;
	  
	 @Column(name = "SEQ_NO")
	 private Integer sequenceNo;
	  
	 @ManyToOne(cascade = { CascadeType.REFRESH })
	 @JoinColumn(name = "FUNC_ID", referencedColumnName = "FUNC_ID", insertable = false, updatable = false)
	 private KrmsFunctions function;
	  
	 public KrmsFunctions getFunction() {
		return function;
	 }

	 public void setFunction(KrmsFunctions function) {
		this.function = function;
	 }

	 public String getFunctionParamId() {
		return functionParamId;
	 }

	 public void setFunctionParamId(String functionParamId) {
		this.functionParamId = functionParamId;
	 }

	 public String getNamespace() {
		return namespace;
	 }

	 public void setNamespace(String namespace) {
		this.namespace = namespace;
	 }

	 public String getDescription() {
		return description;
	 }

	 public void setDescription(String description) {
		this.description = description;
	 }

	 public String getType() {
		return type;
	 }

	 public void setType(String type) {
		this.type = type;
	 }

     public String getId() {
		return id;
	 }

	 public void setId(String id) {
		this.id = id;
	 }

	 public Integer getSequenceNo() {
		return sequenceNo;
	 }

	 public void setSequenceNo(Integer sequenceNo) {
		this.sequenceNo = sequenceNo;
	 }
}
