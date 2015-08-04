update krew_rte_node_instn_t set actv_ind = 1
where doc_hdr_id in (
  select t1.document_number from eps_proposal t1 where t1.STATUS_CODE = 12
)
and actv_ind <> 1;
commit;