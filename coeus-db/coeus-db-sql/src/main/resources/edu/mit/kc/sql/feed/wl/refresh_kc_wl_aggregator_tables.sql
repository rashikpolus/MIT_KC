--Script to populate WL aggregator tables.
-- This script will be called from a CRON job daily
--
set heading off;
set echo off;

	select 'Deleting all rows from WL_PROP_AGGREGATOR_ERR_COUNT' from dual;

		DELETE FROM wl_prop_aggregator_err_count;

	select 'Load WL_PROP_AGGREGATOR_ERR_COUNT. Aggregator Error Count for all routed proposals.' from dual;

		  INSERT INTO wl_prop_aggregator_err_count(
		  COUNT_ID,                                                                                                                                                                      
		  PROPOSAL_NUMBER,                                                                                                                                                                                   
		  ROUTING_NUMBER,                                                                                                                                                                      
		  AGGREGATOR_USER_ID,                                                                                                                                                                   
		  AGGREGATOR_PERSON_ID,                                                                                                                                                                             
		  ROUTING_START_DATE,                                                                                                                                                                               
		  NUM_OF_ERRORS,                                                                                                                                                                 
		  VER_NBR,                                                                                                                                                                      
		  OBJ_ID
		  )  
		  SELECT seq_wl_aggreg_count_id.nextval,
		  t1.proposal_number,
		  t3.rte_node_id,
		  t4.prncpl_nm,
		  t4.prncpl_id,
		  t2.rte_stat_mdfn_dt,
		  fn_wl_prop_error_count@coeus.kuali( trim(to_char(t1.proposal_number,'00000000'))),
		  1,
		  sys_guid()
		  FROM eps_proposal t1
		  INNER JOIN krew_doc_hdr_t t2 on t1.document_number = t2.doc_hdr_id
		  INNER JOIN krew_rte_node_instn_t t3 on t2.doc_hdr_id = t3.doc_hdr_id
		  INNER JOIN krim_prncpl_t t4 on t2.rte_prncpl_id = t4.prncpl_id
		  WHERE t1.creation_status_code <> 1
		  AND t2.rte_stat_mdfn_dt is not null
		  AND t3.rte_node_id in ( select min(s1.rte_node_id) from krew_rte_node_instn_t s1 where s1.doc_hdr_id = t2.doc_hdr_id );
        
rem
rem
	select 'Deleting all rows from WL_PROP_AGGREGATOR_COMPLEXITY' from dual;
	
		DELETE FROM wl_prop_aggregator_complexity;
rem
rem
	select 'Load WL_PROP_AGGREGATOR_COMPLEXITY - Proposals routed after ' || to_char(trunc(add_months(sysdate, -12)), 'mm/dd/yyyy')  from dual;

		INSERT INTO WL_PROP_AGGREGATOR_COMPLEXITY(
		COMPLEXITY_ID,
		AGGREGATOR_USER_ID,
		AGGREGATOR_PERSON_ID,
		AVERAGE_ERROR_COUNT,
		COMPLEXITY,
		PROPOSAL_COUNT,
		VER_NBR,
		OBJ_ID
		)
		SELECT SEQ_WL_COMPLEXITY_ID.NEXTVAL,
		t1.aggregator_user_id,
		t1.aggregator_person_id,
		t1.average_error_count,
		NULL,
		t1.proposal_count,
		1,
		SYS_GUID()
		FROM
			( select
			  aggregator_user_id,
			  aggregator_person_id,
			  AVG(num_of_errors) average_error_count,         
			  count(distinct proposal_number) proposal_count         
			  FROM WL_PROP_AGGREGATOR_ERR_COUNT
			  WHERE  ROUTING_START_DATE > = trunc(add_months(sysdate, -12))
			  GROUP BY AGGREGATOR_USER_ID, AGGREGATOR_PERSON_ID
		  )t1; 

--Update Complexity


select 'Set Complexity = 3 when proposal count <= 5' from dual;
    UPDATE wl_prop_aggregator_complexity
    SET complexity = 3
    WHERE  proposal_count <= 5;
	

select 'Set Complexity = 1 when average error count >= 0 and < 2' from dual;
    UPDATE wl_prop_aggregator_complexity
    SET complexity = 1
    WHERE average_error_count >= 0 and average_error_count < 2
    and proposal_count > 5;
	

select 'Set Complexity = 2 when average error count >=2 and < 3' from dual;
	UPDATE wl_prop_aggregator_complexity
    SET complexity = 2
    WHERE average_error_count >= 2 and average_error_count < 3
    and proposal_count > 5;
	

select 'Set Complexity = 3 when average error count >=3' from dual;
    UPDATE wl_prop_aggregator_complexity
    SET complexity = 3
    WHERE average_error_count >= 3
    AND proposal_count > 5;


commit;
rem
rem
exit;