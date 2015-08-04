update krew_doc_hdr_t set doc_hdr_stat_cd = 'S'
where  doc_hdr_id in ( select document_number from protocol where protocol_status_code = '100' )
and  doc_hdr_stat_cd <> 'S'
/
commit
/
