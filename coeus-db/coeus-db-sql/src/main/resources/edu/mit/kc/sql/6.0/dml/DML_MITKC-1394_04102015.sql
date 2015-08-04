CREATE TABLE TMP_MIG_PROTO_DOC_MAPING(
DOCUMENT_NUMBER VARCHAR2(40),
NEW_DOC_NUMBER  VARCHAR2(40)
)
/
INSERT INTO TMP_MIG_PROTO_DOC_MAPING(DOCUMENT_NUMBER, NEW_DOC_NUMBER)
SELECT document_number,'MP'||document_number FROM protocol 
WHERE SUBSTR(document_number,1,2) <> 'MP'
AND protocol_number in ( select distinct protocol_number from osp$protocol@coeus.kuali)
/
commit
/
ALTER TABLE TMP_MIG_PROTO_DOC_MAPING ADD CONSTRAINT PK_DOCUMENT_NUMBER PRIMARY KEY(DOCUMENT_NUMBER)
/
ALTER TABLE PROTOCOL DISABLE CONSTRAINT FK_PROTOCOL_DOCUMENT
/
UPDATE ( select t1.document_number, t2.new_doc_number from protocol_document t1 , tmp_mig_proto_doc_maping t2 where t1.document_number = t2.document_number  )
SET document_number = new_doc_number
/
commit
/
UPDATE ( select t1.document_number, t2.new_doc_number from protocol t1 , tmp_mig_proto_doc_maping t2 where t1.document_number = t2.document_number  )
SET document_number = new_doc_number
/
UPDATE ( select t1.doc_hdr_id, t2.new_doc_number from krew_doc_hdr_t t1 , tmp_mig_proto_doc_maping t2 where t1.doc_hdr_id = t2.document_number  )
SET doc_hdr_id = new_doc_number
/
UPDATE ( select t1.doc_hdr_id, t2.new_doc_number from krns_doc_hdr_t t1 , tmp_mig_proto_doc_maping t2 where t1.doc_hdr_id = t2.document_number  )
SET doc_hdr_id = new_doc_number
/
UPDATE ( select t1.doc_hdr_id, t2.new_doc_number from krew_doc_hdr_cntnt_t t1 , tmp_mig_proto_doc_maping t2 where t1.doc_hdr_id = t2.document_number  )
SET doc_hdr_id = new_doc_number
/
UPDATE ( select t1.doc_hdr_id, t2.new_doc_number from krew_rte_node_instn_t t1 , tmp_mig_proto_doc_maping t2 where t1.doc_hdr_id = t2.document_number  )
SET doc_hdr_id = new_doc_number
/
UPDATE ( select t1.doc_hdr_id, t2.new_doc_number from krew_init_rte_node_instn_t t1 , tmp_mig_proto_doc_maping t2 where t1.doc_hdr_id = t2.document_number  )
SET doc_hdr_id = new_doc_number
/
UPDATE ( select t1.doc_hdr_id, t2.new_doc_number from krew_actn_rqst_t t1 , tmp_mig_proto_doc_maping t2 where t1.doc_hdr_id = t2.document_number  )
SET doc_hdr_id = new_doc_number
/
UPDATE ( select t1.doc_hdr_id, t2.new_doc_number from krew_actn_tkn_t t1 , tmp_mig_proto_doc_maping t2 where t1.doc_hdr_id = t2.document_number  )
SET doc_hdr_id = new_doc_number
/
commit
/
ALTER TABLE PROTOCOL ENABLE CONSTRAINT FK_PROTOCOL_DOCUMENT
/
