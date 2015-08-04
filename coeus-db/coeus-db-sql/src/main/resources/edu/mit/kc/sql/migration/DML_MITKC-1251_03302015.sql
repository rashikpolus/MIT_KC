ALTER TABLE document_access DISABLE CONSTRAINT UQ_DOCUMENT_ACCESS1
/
drop index UQ_DOCUMENT_ACCESS1
/
UPDATE document_access SET  role_nm = 'Aggregator Document Level' WHERE role_nm = 'Aggregator'
/
commit
/
DECLARE
  CURSOR c_data IS
  select DOC_HDR_ID, PRNCPL_ID, ROLE_NM, NMSPC_CD
  from document_access
  group by DOC_HDR_ID, PRNCPL_ID, ROLE_NM, NMSPC_CD
  having count(DOC_HDR_ID) > 1;
  r_data c_data%rowtype;
BEGIN
  OPEN c_data;
  LOOP
  fetch c_data into r_data;
  exit when c_data%notfound;
  
        delete   from document_access t1
        where t1.doc_hdr_id = r_data.doc_hdr_id 
        and t1.prncpl_id = r_data.prncpl_id
        and t1.role_nm = r_data.role_nm
        and t1.nmspc_cd = r_data.nmspc_cd
        and t1.doc_access_id not in (
          select max(t2.doc_access_id)
          from document_access t2
          where t2.doc_hdr_id = t1.doc_hdr_id
          and t2.prncpl_id = t1.prncpl_id
          and t2.role_nm = t1.role_nm
          and t2.nmspc_cd = t1.nmspc_cd
        );
        
  end loop;
  close c_data;

END;
/
commit
/
CREATE UNIQUE INDEX UQ_DOCUMENT_ACCESS1 ON DOCUMENT_ACCESS (DOC_HDR_ID, PRNCPL_ID, ROLE_NM, NMSPC_CD)
/
ALTER TABLE document_access ENABLE CONSTRAINT UQ_DOCUMENT_ACCESS1
/
