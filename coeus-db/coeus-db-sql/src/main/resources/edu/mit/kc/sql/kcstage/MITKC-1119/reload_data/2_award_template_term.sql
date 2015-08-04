select ' Start time of AWARD_TEMPLATE_TERMS is '|| localtimestamp from dual
/
truncate table AWARD_TEMPLATE_TERMS
/
INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,te.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,te.UPDATE_USER,te.UPDATE_TIMESTAMP,SYS_GUID()
from OSP$TEMPLATE_EQUIPMENT_TERMS@coeus.kuali te  inner join SPONSOR_TERM st on te.EQUIPMENT_APPROVAL_CODE=st.SPONSOR_TERM_CODE AND 1=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,ti.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,ti.UPDATE_USER UPDATE_USER,ti.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,
SYS_GUID()
from OSP$TEMPLATE_INVENTION_TERMS@coeus.kuali  ti inner join SPONSOR_TERM st on ti.INVENTION_CODE=st.SPONSOR_TERM_CODE AND 2=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,tpt.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,tpt.UPDATE_USER UPDATE_USER,tpt.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,
SYS_GUID()
from OSP$TEMPLATE_PRIOR_TERMS@coeus.kuali tpt inner join SPONSOR_TERM st on tpt.PRIOR_APPROVAL_CODE=st.SPONSOR_TERM_CODE AND 3=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,tp.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,tp.UPDATE_USER UPDATE_USER,tp.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,
SYS_GUID()
from OSP$TEMPLATE_PROPERTY_TERMS@coeus.kuali tp  inner join SPONSOR_TERM st on tp.PROPERTY_CODE=st.SPONSOR_TERM_CODE AND 4=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,tbt.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,tbt.UPDATE_USER UPDATE_USER,tbt.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,
SYS_GUID()
from OSP$TEMPLATE_PUBLICATION_TERMS@coeus.kuali tbt  inner join SPONSOR_TERM st on tbt.PUBLICATION_CODE=st.SPONSOR_TERM_CODE AND 5=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,tdt.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,tdt.UPDATE_USER UPDATE_USER,tdt.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,
SYS_GUID()
from OSP$TEMPLATE_DOCUMENT_TERMS@coeus.kuali tdt  inner join SPONSOR_TERM st on tdt.REFERENCED_DOCUMENT_CODE=st.SPONSOR_TERM_CODE AND 6=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,trt.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,trt.UPDATE_USER ,trt.UPDATE_TIMESTAMP,SYS_GUID()
from OSP$TEMPLATE_RIGHTS_TERMS@coeus.kuali trt  inner join SPONSOR_TERM st on trt.RIGHTS_IN_DATA_CODE=st.SPONSOR_TERM_CODE AND 7=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,tst.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,tst.UPDATE_USER UPDATE_USER,tst.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,
SYS_GUID()
from OSP$TEMPLATE_SUBCONTRACT_TERMS@coeus.kuali tst  inner join SPONSOR_TERM st on tst.SUBCONTRACT_APPROVAL_CODE=st.SPONSOR_TERM_CODE AND 8=st.SPONSOR_TERM_TYPE_CODE;

INSERT INTO AWARD_TEMPLATE_TERMS(AWARD_TEMPLATE_TERMS_ID,VER_NBR,AWARD_TEMPLATE_CODE,SPONSOR_TERM_ID,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
SELECT  SEQ_AWARD_TEMPLATE.NEXTVAL,1,ttt.TEMPLATE_CODE TEMPLATE_CODE,st.SPONSOR_TERM_ID
,ttt.UPDATE_USER UPDATE_USER,ttt.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,
SYS_GUID()
from OSP$TEMPLATE_TRAVEL_TERMS@coeus.kuali ttt inner join SPONSOR_TERM st on ttt.TRAVEL_RESTRICTION_CODE=st.SPONSOR_TERM_CODE AND 9=st.SPONSOR_TERM_TYPE_CODE;
commit;
/
ALTER TABLE AWARD_TEMPLATE_TERMS ENABLE CONSTRAINT FK2_AWARD_TEMPLATE_TERMS
/
select ' End time of AWARD_TEMPLATE_TERMS is '|| localtimestamp from dual
/