delete from proposal_attachments_data where proposal_attachments_data_id not in (select PROPOSAL_ATTACHMENTS_DATA_ID from proposal_attachments)
/
commit
/
