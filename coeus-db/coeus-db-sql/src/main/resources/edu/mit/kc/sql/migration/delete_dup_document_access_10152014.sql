DELETE FROM document_access t1
WHERE  t1.rowid not in ( SELECT  min(t2.rowid) 
                          FROM  DOCUMENT_ACCESS t2
                          WHERE t1.DOC_HDR_ID = t2.DOC_HDR_ID
                          AND   t1.PRNCPL_ID = t2.PRNCPL_ID
                          AND   t1.ROLE_NM = t2.ROLE_NM
                          AND   t1.NMSPC_CD = t2.NMSPC_CD)
/
commit
/
alter table document_access enable constraint UQ_DOCUMENT_ACCESS1
/
