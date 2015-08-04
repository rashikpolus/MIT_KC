update negotiation_activity set END_DATE = null
where negotiation_id in (
select negotiation_id from negotiation where associated_document_id in ( select negotiation_number from osp$negotiations@coeus.kuali)
)
/
commit
/
