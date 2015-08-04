package edu.mit.kc.workloadbalancing.bo;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import org.kuali.coeus.sys.framework.model.KcPersistableBusinessObjectBase;
import org.kuali.rice.krad.data.jpa.PortableSequenceGenerator;

@Entity
@Table(name = "WL_PROP_AGGREGATOR_COMPLEXITY")
public class WlPropAggregatorComplexity extends KcPersistableBusinessObjectBase{
	
	 	@PortableSequenceGenerator(name = "SEQ_WL_COMPLEXITY_ID")
	    @GeneratedValue(generator = "SEQ_WL_COMPLEXITY_ID")
		@Id
		@Column(name = "COMPLEXITY_ID")
		private String complexityId;

	 	@Column(name = "AGGREGATOR_USER_ID")
	 	private String aggregatorUserId;
	 	
	 	@Column(name = "AGGREGATOR_PERSON_ID")
	 	private String aggregatorPersonId;
	 	
	 	@Column(name = "AVERAGE_ERROR_COUNT")
	 	private Long averageErroCount;
	 	
	 	@Column(name = "COMPLEXITY")
	 	private Long  complexity;
	 	
	 	@Column(name = "PROPOSAL_COUNT")
	 	private Long proposalCount;
	 	
		public String getAggregatorUserId() {
			return aggregatorUserId;
		}

		public void setAggregatorUserId(String aggregatorUserId) {
			this.aggregatorUserId = aggregatorUserId;
		}

		public String getAggregatorPersonId() {
			return aggregatorPersonId;
		}

		public void setAggregatorPersonId(String aggregatorPersonId) {
			this.aggregatorPersonId = aggregatorPersonId;
		}

		public Long getAverageErroCount() {
			return averageErroCount;
		}

		public void setAverageErroCount(Long averageErroCount) {
			this.averageErroCount = averageErroCount;
		}

		public Long getComplexity() {
			return complexity;
		}

		public void setComplexity(Long complexity) {
			this.complexity = complexity;
		}

		public Long getProposalCount() {
			return proposalCount;
		}

		public void setProposalCount(Long proposalCount) {
			this.proposalCount = proposalCount;
		}

		
}
