update KREW_DOC_HDR_T set doc_hdr_stat_cd = 'F'
where doc_hdr_id in ( select t1.document_number from negotiation t1
                      inner join TEMP_NEGOTIATION_ID t2 on t1.negotiation_id = t2.negotiation_id)
/
commit
/
