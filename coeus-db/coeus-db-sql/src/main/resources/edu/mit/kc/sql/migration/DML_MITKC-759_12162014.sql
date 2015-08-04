ALTER TABLE COMM_MEMBER_ROLES DISABLE CONSTRAINT FK_COMM_MEMBER_ROLES
/
ALTER TABLE COMM_MEMBER_EXPERTISE DISABLE CONSTRAINT FK_COMM_MEMBER_EXPERTISE                              
/
TRUNCATE TABLE COMM_MEMBER_ROLES
/
TRUNCATE TABLE COMM_MEMBER_EXPERTISE
/
TRUNCATE TABLE COMM_MEMBERSHIPS
/
ALTER TABLE COMM_MEMBER_ROLES ENABLE CONSTRAINT FK_COMM_MEMBER_ROLES
/
ALTER TABLE COMM_MEMBER_EXPERTISE ENABLE CONSTRAINT FK_COMM_MEMBER_EXPERTISE
/
declare
cursor c_comm is
select ID,DOCUMENT_NUMBER,COMMITTEE_ID,COMMITTEE_NAME,SEQUENCE_NUMBER FROM COMMITTEE ORDER BY sequence_number;
r_comm c_comm%rowtype;

begin

open c_comm;
loop
fetch c_comm into r_comm;
exit when c_comm%notfound;

begin
	INSERT INTO COMM_MEMBERSHIPS(COMM_MEMBERSHIP_ID,COMMITTEE_ID_FK,PERSON_ID,ROLODEX_ID,PERSON_NAME,MEMBERSHIP_ID,PAID_MEMBER_FLAG,TERM_START_DATE,TERM_END_DATE,
	MEMBERSHIP_TYPE_CODE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
	SELECT SEQ_COMMITTEE_ID.NEXTVAL,r_comm.ID,decode(cm.NON_EMPLOYEE_FLAG,'Y',null,cm.PERSON_ID),decode(cm.NON_EMPLOYEE_FLAG,'Y',cm.PERSON_ID,null),
	cm.PERSON_NAME,cm.MEMBERSHIP_ID,cm.PAID_MEMBER_FLAG,
	cm.TERM_START_DATE,cm.TERM_END_DATE,cm.MEMBERSHIP_TYPE_CODE,cm.COMMENTS,
	cm.UPDATE_TIMESTAMP,cm.UPDATE_USER ,1,SYS_GUID()
	FROM OSP$COMM_MEMBERSHIPS@coeus.kuali cm
	where cm.committee_id = r_comm.COMMITTEE_ID
	and cm.sequence_number in ( SELECT  MAX(A.SEQUENCE_NUMBER) 
								FROM OSP$COMM_MEMBERSHIPS@coeus.kuali A
								WHERE A.COMMITTEE_ID = cm.COMMITTEE_ID
								AND A.MEMBERSHIP_ID = cm.MEMBERSHIP_ID
								AND a.sequence_number <= r_comm.SEQUENCE_NUMBER                            
							  );
exception
when others then
dbms_output.put_line('ERROR IN COMM_MEMBERSHIPS,COMMITTEE_ID_FK:'||r_comm.ID||'-'||sqlerrm);
end;

end loop;
close c_comm;

end;
/
commit
/
declare
	cursor c_comm is
	select t2.comm_membership_id,t2.membership_id,t1.sequence_number from committee t1 
	inner join comm_memberships t2 on t1.id = t2.committee_id_fk ORDER BY t2.membership_id,t1.sequence_number;
	r_comm c_comm%rowtype;
begin

	open c_comm;
	loop
	fetch c_comm into r_comm;
	exit when c_comm%notfound;
						

		begin
			INSERT INTO COMM_MEMBER_ROLES(COMM_MEMBER_ROLES_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,COMM_MEMBERSHIP_ID_FK,MEMBERSHIP_ROLE_CODE,
			START_DATE,END_DATE,OBJ_ID)
			SELECT SEQ_COMMITTEE_ID.NEXTVAL,t1.UPDATE_TIMESTAMP,LOWER(t1.UPDATE_USER),1,r_comm.comm_membership_id,t1.MEMBERSHIP_ROLE_CODE,
			t1.START_DATE,t1.END_DATE,SYS_GUID() FROM OSP$COMM_MEMBER_ROLES@coeus.kuali t1
			WHERE t1.MEMBERSHIP_ID = r_comm.membership_id
			AND t1.SEQUENCE_NUMBER = (select max(t2.sequence_number) from OSP$COMM_MEMBER_ROLES@coeus.kuali t2 
									where t2.membership_id = t1.membership_id
									and  t2.SEQUENCE_NUMBER <= r_comm.sequence_number
									);
		exception
		when others then
		dbms_output.put_line('ERROR IN COMM_MEMBER_ROLES,comm_membership_id:'||r_comm.comm_membership_id||'-'||sqlerrm);
		end;
		
		begin
			INSERT INTO COMM_MEMBER_EXPERTISE(COMM_MEMBER_EXPERTISE_ID,COMM_MEMBERSHIP_ID_FK,RESEARCH_AREA_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
			SELECT SEQ_COMMITTEE_ID.NEXTVAL,r_comm.comm_membership_id,t1.RESEARCH_AREA_CODE,t1.UPDATE_TIMESTAMP,LOWER(t1.UPDATE_USER),1,SYS_GUID()
			FROM OSP$COMM_MEMBER_EXPERTISE@coeus.kuali t1
			WHERE t1.MEMBERSHIP_ID = r_comm.membership_id 
			AND  t1.SEQUENCE_NUMBER = ( select max(t2.sequence_number) 
										from OSP$COMM_MEMBER_EXPERTISE@coeus.kuali t2
										where t2.membership_id = t1.MEMBERSHIP_ID
										and t2.SEQUENCE_NUMBER <= r_comm.sequence_number
									  );

		exception
		when others then
		dbms_output.put_line('ERROR IN COMM_MEMBER_EXPERTISE,comm_membership_id:'||r_comm.comm_membership_id||'-'||sqlerrm);
		end;
	
	end loop;
	close c_comm;

end;
/
commit
/
