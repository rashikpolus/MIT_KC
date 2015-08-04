DELETE FROM  COMM_MEMBER_ROLES
/
DELETE FROM COMM_MEMBER_EXPERTISE
/
DELETE FROM COMM_MEMBERSHIPS
/
commit
/
DECLARE
li_ver_nbr NUMBER(8):=1;
li_membership_id NUMBER(12,0);
li_rolodex_id NUMBER(12,0);
ls_person_id VARCHAR2(40);
li_rolodex_count NUMBER;
li_committee NUMBER(12,0);
li_sequence NUMBER(4);
ls_memb_id VARCHAR2(10);
li_member_role NUMBER(12,0);
li_member_expertise NUMBER(12,0);
CURSOR c_member IS
SELECT cm.MEMBERSHIP_ID,cm.SEQUENCE_NUMBER,cm.COMMITTEE_ID,cm.PERSON_ID,cm.PERSON_NAME,cm.NON_EMPLOYEE_FLAG,cm.PAID_MEMBER_FLAG,cm.TERM_START_DATE,cm.TERM_END_DATE,cm.MEMBERSHIP_TYPE_CODE,cm.COMMENTS,cm.UPDATE_TIMESTAMP,cm.UPDATE_USER 
FROM OSP$COMM_MEMBERSHIPS@coeus.kuali cm WHERE SEQUENCE_NUMBER=(SELECT MAX(SEQUENCE_NUMBER) FROM OSP$COMM_MEMBERSHIPS@coeus.kuali WHERE COMMITTEE_ID=cm.COMMITTEE_ID);
r_member c_member%ROWTYPE;

CURSOR c_member_role(as_membership_id VARCHAR2,as_sequence NUMBER) IS
SELECT MEMBERSHIP_ID,SEQUENCE_NUMBER,MEMBERSHIP_ROLE_CODE,START_DATE,END_DATE,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$COMM_MEMBER_ROLES@coeus.kuali
WHERE MEMBERSHIP_ID=as_membership_id AND SEQUENCE_NUMBER=(select max(sequence_number) from OSP$COMM_MEMBER_ROLES@coeus.kuali where membership_id=as_membership_id);
r_member_role c_member_role%ROWTYPE;

CURSOR c_expertise(as_membership_id VARCHAR2,as_sequence NUMBER) IS
SELECT MEMBERSHIP_ID,SEQUENCE_NUMBER,RESEARCH_AREA_CODE,UPDATE_TIMESTAMP,UPDATE_USER FROM OSP$COMM_MEMBER_EXPERTISE@coeus.kuali
WHERE MEMBERSHIP_ID=as_membership_id AND SEQUENCE_NUMBER=(select max(sequence_number) from OSP$COMM_MEMBER_EXPERTISE@coeus.kuali where membership_id=as_membership_id);
r_expertise c_expertise%ROWTYPE;


BEGIN
IF c_member%ISOPEN THEN
CLOSE c_member;
END IF;
OPEN c_member;
LOOP
FETCH c_member INTO r_member;
EXIT WHEN c_member%NOTFOUND;
ls_memb_id:=r_member.MEMBERSHIP_ID;
li_sequence:=r_member.SEQUENCE_NUMBER;
SELECT SEQ_COMMITTEE_ID.NEXTVAL INTO li_membership_id FROM DUAL;

begin
SELECT ID INTO li_committee FROM COMMITTEE WHERE COMMITTEE_ID=r_member.COMMITTEE_ID AND SEQUENCE_NUMBER=(SELECT MAX(c.SEQUENCE_NUMBER) FROM COMMITTEE c WHERE c.COMMITTEE_ID=r_member.COMMITTEE_ID);
exception
when others then
dbms_output.put_line('Error while fetching ID from COMMITTEE where COMMITTEE_ID is '||r_member.COMMITTEE_ID||' and error is '||sqlerrm);
end;


li_rolodex_id:=null;
ls_person_id:=null;
IF  r_member.NON_EMPLOYEE_FLAG='Y' THEN
select count(rolodex_id) into li_rolodex_count from ROLODEX where to_char(rolodex_id)=r_member.PERSON_ID;
if li_rolodex_count>0 then
li_rolodex_id:=r_member.PERSON_ID;
ls_person_id:=null;
else
ls_person_id:=r_member.PERSON_ID;
li_rolodex_id:=null;

end if;
ELSE     
ls_person_id:=r_member.PERSON_ID;      

END IF;  

begin
INSERT INTO COMM_MEMBERSHIPS(COMM_MEMBERSHIP_ID,COMMITTEE_ID_FK,PERSON_ID,ROLODEX_ID,PERSON_NAME,MEMBERSHIP_ID,PAID_MEMBER_FLAG,TERM_START_DATE,TERM_END_DATE,MEMBERSHIP_TYPE_CODE,COMMENTS,CONTACT_NOTES,TRAINING_NOTES,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_membership_id,li_committee,ls_person_id,li_rolodex_id,r_member.PERSON_NAME,r_member.MEMBERSHIP_ID,r_member.PAID_MEMBER_FLAG,r_member.TERM_START_DATE,r_member.TERM_END_DATE,r_member.MEMBERSHIP_TYPE_CODE,r_member.COMMENTS,NULL,NULL,r_member.UPDATE_TIMESTAMP,r_member.UPDATE_USER,li_ver_nbr,SYS_GUID());
exception
when others then
dbms_output.put_line('ERROR IN COMM_MEMBERSHIPS,COMM_MEMBERSHIP_ID:'||li_membership_id||'-'||sqlerrm);
end;
begin
IF c_member_role%ISOPEN THEN
CLOSE c_member_role;
END IF;
OPEN c_member_role(ls_memb_id,li_sequence);
LOOP
FETCH c_member_role INTO r_member_role;
EXIT WHEN c_member_role%NOTFOUND;


SELECT SEQ_COMMITTEE_ID.NEXTVAL INTO li_member_role FROM DUAL;

begin
INSERT INTO COMM_MEMBER_ROLES(COMM_MEMBER_ROLES_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,COMM_MEMBERSHIP_ID_FK,MEMBERSHIP_ROLE_CODE,START_DATE,END_DATE,OBJ_ID)
VALUES(li_member_role,r_member_role.UPDATE_TIMESTAMP,LOWER(r_member_role.UPDATE_USER),li_ver_nbr,li_membership_id,r_member_role.MEMBERSHIP_ROLE_CODE,r_member_role.START_DATE,r_member_role.END_DATE,SYS_GUID());
exception
when others then
dbms_output.put_line('ERROR IN COMM_MEMBER_ROLES,COMM_MEMBER_ROLES_ID:'||li_member_role||'-'||sqlerrm);
end;
END LOOP;
CLOSE c_member_role;
end;

begin
IF c_expertise%ISOPEN THEN 
CLOSE c_expertise;
END IF;
OPEN c_expertise(ls_memb_id,li_sequence);
LOOP
FETCH c_expertise INTO r_expertise;
EXIT WHEN c_expertise%NOTFOUND;

SELECT SEQ_COMMITTEE_ID.NEXTVAL INTO li_member_expertise FROM DUAL;
begin
INSERT INTO COMM_MEMBER_EXPERTISE(COMM_MEMBER_EXPERTISE_ID,COMM_MEMBERSHIP_ID_FK,RESEARCH_AREA_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
VALUES(li_member_expertise,li_membership_id,r_expertise.RESEARCH_AREA_CODE,r_expertise.UPDATE_TIMESTAMP,LOWER(r_expertise.UPDATE_USER),li_ver_nbr,SYS_GUID());
exception
when others then
dbms_output.put_line('RESEARCH_AREA_CODE:'||r_expertise.RESEARCH_AREA_CODE||  'NOT IN PARENT TABLE');
end;
END LOOP;
CLOSE c_expertise;
end;

END LOOP;
CLOSE c_member;
dbms_output.put_line('COMPLETED COMM_MEMBERSHIPS');
END;
/