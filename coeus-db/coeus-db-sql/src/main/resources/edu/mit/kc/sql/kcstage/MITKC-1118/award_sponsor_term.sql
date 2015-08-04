select ' Start time of SPONSOR_TERM is '|| localtimestamp from dual
/
ALTER TABLE AWARD_SPONSOR_TERM DISABLE CONSTRAINT FK_AWARD_SPONSOR_TERM;
ALTER TABLE AWARD_TEMPLATE_TERMS DISABLE CONSTRAINT FK2_AWARD_TEMPLATE_TERMS;
TRUNCATE TABLE SPONSOR_TERM;
commit;
INSERT INTO SPONSOR_TERM(SPONSOR_TERM_ID,VER_NBR,SPONSOR_TERM_CODE,SPONSOR_TERM_TYPE_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
select SEQ_SPONSOR_TERM.NEXTVAL,1,p.SPONSOR_TERM_CODE,p.SPONSOR_TERM_TYPE_CODE,p.DESCRIPTION,p.UPDATE_TIMESTAMP,p.UPDATE_USER,SYS_GUID() from
(SELECT ea.EQUIPMENT_APPROVAL_CODE SPONSOR_TERM_CODE,ea.DESCRIPTION DESCRIPTION,ea.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,ea.UPDATE_USER UPDATE_USER,'1' SPONSOR_TERM_TYPE_CODE FROM OSP$EQUIPMENT_APPROVAL@coeus.kuali ea UNION ALL
SELECT inv.INVENTION_CODE SPONSOR_TERM_CODE,inv.DESCRIPTION DESCRIPTION,inv.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,inv.UPDATE_USER UPDATE_USER,'2' SPONSOR_TERM_TYPE_CODE FROM OSP$INVENTION@coeus.kuali inv UNION ALL
SELECT pa.PRIOR_APPROVAL_CODE SPONSOR_TERM_CODE,pa.DESCRIPTION DESCRIPTION,pa.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,pa.UPDATE_USER UPDATE_USER,'3' SPONSOR_TERM_TYPE_CODE FROM OSP$PRIOR_APPROVAL@coeus.kuali pa UNION ALL
SELECT p.PROPERTY_CODE SPONSOR_TERM_CODE,p.DESCRIPTION DESCRIPTION,p.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,p.UPDATE_USER UPDATE_USER,'4' SPONSOR_TERM_TYPE_CODE FROM OSP$PROPERTY@coeus.kuali p UNION ALL
SELECT pu.PUBLICATION_CODE SPONSOR_TERM_CODE,pu.DESCRIPTION DESCRIPTION,pu.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,pu.UPDATE_USER UPDATE_USER,'5' SPONSOR_TERM_TYPE_CODE FROM OSP$PUBLICATION@coeus.kuali pu UNION ALL
SELECT rd.REFERENCED_DOCUMENT_CODE SPONSOR_TERM_CODE,rd.DESCRIPTION DESCRIPTION,rd.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,rd.UPDATE_USER UPDATE_USER,'6' SPONSOR_TERM_TYPE_CODE FROM OSP$REFERENCED_DOCUMENT@coeus.kuali rd UNION ALL
SELECT rid.RIGHTS_IN_DATA_CODE SPONSOR_TERM_CODE,rid.DESCRIPTION DESCRIPTION,rid.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,rid.UPDATE_USER UPDATE_USER,'7' SPONSOR_TERM_TYPE_CODE FROM OSP$RIGHTS_IN_DATA@coeus.kuali rid UNION ALL
SELECT sa.SUBCONTRACT_APPROVAL_CODE SPONSOR_TERM_CODE,sa.DESCRIPTION DESCRIPTION,sa.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,sa.UPDATE_USER UPDATE_USER,'8' SPONSOR_TERM_TYPE_CODE FROM OSP$SUBCONTRACT_APPROVAL@coeus.kuali sa UNION ALL
SELECT tr.TRAVEL_RESTRICTION_CODE SPONSOR_TERM_CODE,tr.DESCRIPTION DESCRIPTION,tr.UPDATE_TIMESTAMP UPDATE_TIMESTAMP,tr.UPDATE_USER UPDATE_USER,'9' SPONSOR_TERM_TYPE_CODE FROM OSP$TRAVEL_RESTRICTION@coeus.kuali tr)p;
commit;
/
select ' End time of SPONSOR_TERM is '|| localtimestamp from dual
/
select ' Start time of AWARD_SPONSOR_TERM script is '|| localtimestamp from dual
/
truncate table AWARD_SPONSOR_TERM
/
CREATE TABLE TEMP_AWD_EQUP_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t  left outer join OSP$AWARD_EQUIPMENT_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.EQUIPMENT_APPROVAL_CODE = st.sponsor_term_code and 1 = st.sponsor_term_type_code;


commit;
create index TEMP_AWD_EQUP_1_I on TEMP_AWD_EQUP_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_EQUP_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_EQUP_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_EQUP_1 v  where v.mit_award_number is null;
commit;


INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_EQUP_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_EQUP_1 i   inner join TEMP_AWD_EQUP_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;

-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_INV_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t left outer join OSP$AWARD_INVENTION_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.INVENTION_CODE = st.sponsor_term_code and 2 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_INV_1_I on TEMP_AWD_INV_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_INV_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_INV_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_INV_1 v  where v.mit_award_number is null;
commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_INV_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_INV_1 i   inner join TEMP_AWD_INV_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;
-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_PRI_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t left outer join OSP$AWARD_PRIOR_APPROVAL_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.PRIOR_APPROVAL_CODE = st.sponsor_term_code and 3 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_PRI_1_I on TEMP_AWD_PRI_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_PRI_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_PRI_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_PRI_1 v  where v.mit_award_number is null;
commit;


INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_PRI_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_PRI_1 i   inner join TEMP_AWD_PRI_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;
-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_PRO_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t left outer join OSP$AWARD_PROPERTY_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.PROPERTY_CODE = st.sponsor_term_code and 4 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_PRO_1_I on TEMP_AWD_PRO_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_PRO_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_PRO_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_PRO_1 v  where v.mit_award_number is null;
commit;


INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_PRO_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_PRO_1 i   inner join TEMP_AWD_PRO_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;
-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_PUB_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t left outer join  OSP$AWARD_PUBLICATION_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.PUBLICATION_CODE = st.sponsor_term_code and 5 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_PUB_1_I on TEMP_AWD_PUB_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_PUB_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_PUB_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_PUB_1 v  where v.mit_award_number is null;
commit;


INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_PUB_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_PUB_1 i   inner join TEMP_AWD_PUB_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;
-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_DOC_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD  t left outer join  OSP$AWARD_DOCUMENT_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.REFERENCED_DOCUMENT_CODE = st.sponsor_term_code and 6 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_DOC_1_I on TEMP_AWD_DOC_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_DOC_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_DOC_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_DOC_1 v  where v.mit_award_number is null;
commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_DOC_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_DOC_1 i   inner join TEMP_AWD_DOC_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;
-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_RIG_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t left outer join  OSP$AWARD_RIGHTS_IN_DATA_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.RIGHTS_IN_DATA_CODE = st.sponsor_term_code and 7 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_RIG_1_I on TEMP_AWD_RIG_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_RIG_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_RIG_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_RIG_1 v  where v.mit_award_number is null;
commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_RIG_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_RIG_1 i   inner join TEMP_AWD_RIG_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;
-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_SUB_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t left outer join  OSP$AWARD_SUBCONTRACT_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.SUBCONTRACT_APPROVAL_CODE = st.sponsor_term_code and 8 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_SUB_1_I on TEMP_AWD_SUB_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_SUB_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_SUB_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_SUB_1 v  where v.mit_award_number is null;
commit;


INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_SUB_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_SUB_1 i   inner join TEMP_AWD_SUB_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;
-------------------------------------------------------------------------------------------------------------------

CREATE TABLE TEMP_AWD_TRA_1 AS 
SELECT t.award_id,t.award_number as kuali_awd,aet.sequence_number,aet.mit_award_number,t.sequence_number as kuali_sequence_number,st.sponsor_term_id,aet.UPDATE_TIMESTAMP,aet.UPDATE_USER
FROM  AWARD t left outer join  OSP$AWARD_TRAVEL_TERMS@coeus.kuali aet 
on t.award_number = replace(aet.mit_award_number,'-','-00') and t.sequence_number = aet.sequence_number
left outer join SPONSOR_TERM st on aet.TRAVEL_RESTRICTION_CODE = st.sponsor_term_code and 9 = st.sponsor_term_type_code;

commit;
create index TEMP_AWD_TRA_1_I on TEMP_AWD_TRA_1(kuali_awd,KUALI_SEQUENCE_NUMBER,mit_award_number,sequence_number);
commit;

create table TEMP_AWD_TRA_2 as 
select kuali_awd,(select max(aw.sequence_number) from TEMP_AWD_TRA_1 aw where aw.kuali_awd= v.kuali_awd
and aw.KUALI_SEQUENCE_NUMBER<=v.KUALI_SEQUENCE_NUMBER and aw.mit_award_number is not null)  as kuali_sequence_number,v.KUALI_SEQUENCE_NUMBER SEQUENC  
from TEMP_AWD_TRA_1 v  where v.mit_award_number is null;
commit;


INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,i.kuali_sequence_number,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_TRA_1 i  where i.mit_award_number IS NOT NULL;

commit;

INSERT INTO AWARD_SPONSOR_TERM(AWARD_SPONSOR_TERM_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,SPONSOR_TERM_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_AWARD_SPONSOR_TERM.NEXTVAL,i.award_id,i. kuali_awd,v2.SEQUENC,i.sponsor_term_id,i.UPDATE_TIMESTAMP,i.UPDATE_USER,1,sys_guid()
FROM TEMP_AWD_TRA_1 i   inner join TEMP_AWD_TRA_2 v2 on i.kuali_awd=v2.kuali_awd and i.SEQUENCE_NUMBER=v2.kuali_sequence_number;

commit;

update AWARD_SPONSOR_TERM pp set pp.AWARD_ID = (select p.AWARD_ID from award p where
p.award_number = pp.award_number
and p.sequence_number = pp.sequence_number
);
commit;
drop table TEMP_AWD_EQUP_1;
drop table TEMP_AWD_EQUP_2;
drop table TEMP_AWD_INV_1;
drop table TEMP_AWD_INV_2;
drop table TEMP_AWD_PRI_1;
drop table TEMP_AWD_PRI_2;
drop table TEMP_AWD_PRO_1;
drop table TEMP_AWD_PRO_2;
drop table TEMP_AWD_PUB_1;
drop table TEMP_AWD_PUB_2;
drop table TEMP_AWD_DOC_1;
drop table TEMP_AWD_DOC_2;
drop table TEMP_AWD_RIG_1;
drop table TEMP_AWD_RIG_2;
drop table TEMP_AWD_SUB_1;
drop table TEMP_AWD_SUB_2;
drop table TEMP_AWD_TRA_1;
drop table TEMP_AWD_TRA_2;
commit;
/
ALTER TABLE AWARD_SPONSOR_TERM ENABLE CONSTRAINT FK_AWARD_SPONSOR_TERM
/
select ' End time of AWARD_SPONSOR_TERM script is '|| localtimestamp from dual
/