ALTER TABLE VALID_NARR_FORMS DISABLE CONSTRAINT FK_VALID_NARR_FORMS
/
TRUNCATE TABLE VALID_NARR_FORMS
/
INSERT INTO VALID_NARR_FORMS(
          VALID_NARR_FORMS_ID,
          FORM_NAME,
          NARRATIVE_TYPE_CODE,
          MANDATORY,
          UPDATE_TIMESTAMP,
          UPDATE_USER,OBJ_ID
)
SELECT SEQ_VALID_NARR_FORMS_ID.NEXTVAL,
t1.FORM_NAME,
t1.NARRATIVE_TYPE_CODE,
t1.MANDATORY,
sysdate,
t1.UPDATE_USER,
SYS_GUID()
from osp$valid_narr_forms@coeus.kuali t1
/
commit
/
ALTER TABLE VALID_NARR_FORMS ENABLE CONSTRAINT FK_VALID_NARR_FORMS
/