DECLARE
li_count number;
coeus_proto_num VARCHAR2(20);
coeus_sequence NUMBER(12);
kc_seq NUMBER(12);
ls_content_type	VARCHAR2(255);
li_meeting_id	NUMBER(22);
li_ver_nbr NUMBER(8):=1;
li_pa_id NUMBER(12);
li_protocol_id NUMBER(12);
coeus_doc_id NUMBER(12);
li_att_desc	VARCHAR2(500);
li_att_max_seq NUMBER(12);
li_schedule_id_fk NUMBER(12);
li_comments varchar2(1000);

CURSOR c_attach IS
	select c.FINAL_FLAG,c.REVIEWER_ID_FK,c.COMM_SCHEDULE_MINUTES_ID,c.SCHEDULE_ID_FK,d.SCHEDULED_DATE,
   c.PROTOCOL_ID_FK,c.ENTRY_NUMBER,c.MINUTE_ENTRY_TYPE_CODE,c.SUBMISSION_ID_FK,c.PRIVATE_COMMENT_FLAG,
   c.PROTOCOL_CONTINGENCY_CODE,
   c.MINUTE_ENTRY,c.UPDATE_TIMESTAMP,c.UPDATE_USER,c.VER_NBR,c.OBJ_ID,c.PROTOCOL_ONLN_RVW_FK,
   c.COMM_SCHEDULE_ACT_ITEMS_ID_FK,c.CREATE_USER,
   c.CREATE_TIMESTAMP,c.IACUC_PROTOCOL_ID_FK,c.IACUC_SUBMISSION_ID_FK,c.IACUC_PROTOCOL_ONLN_RVW_FK,
   c.IACUC_REVIEWER_ID_FK 
   from COMM_SCHEDULE_MINUTES c, comm_schedule d
   where c.schedule_id_fk in (select schedule_id_fk from comm_schedule where committee_id_fk = '16637') and
   d.id = c.SCHEDULE_ID_FK;

	r_attach c_attach%ROWTYPE;
	
BEGIN

IF c_attach%ISOPEN THEN
CLOSE c_attach;
END IF;
OPEN c_attach;
LOOP
FETCH c_attach INTO r_attach;
EXIT WHEN c_attach%notfound;

		SELECT id into li_schedule_id_fk 
		FROM comm_schedule 
		WHERE committee_id_fk = '17355' and SCHEDULED_DATE = r_attach.SCHEDULED_DATE;
		
			begin
				select SEQ_MEETING_ID.NEXTVAL into li_meeting_id from dual;
				
			insert into COMM_SCHEDULE_MINUTES (FINAL_FLAG,REVIEWER_ID_FK,COMM_SCHEDULE_MINUTES_ID,SCHEDULE_ID_FK,
   			PROTOCOL_ID_FK,ENTRY_NUMBER,MINUTE_ENTRY_TYPE_CODE,SUBMISSION_ID_FK,PRIVATE_COMMENT_FLAG,PROTOCOL_CONTINGENCY_CODE,
   			MINUTE_ENTRY,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,PROTOCOL_ONLN_RVW_FK,COMM_SCHEDULE_ACT_ITEMS_ID_FK,CREATE_USER,
   			CREATE_TIMESTAMP,IACUC_PROTOCOL_ID_FK,IACUC_SUBMISSION_ID_FK,IACUC_PROTOCOL_ONLN_RVW_FK,IACUC_REVIEWER_ID_FK)
			values(r_attach.FINAL_FLAG,r_attach.REVIEWER_ID_FK,li_meeting_id,li_schedule_id_fk,
   			r_attach.PROTOCOL_ID_FK,r_attach.ENTRY_NUMBER,r_attach.MINUTE_ENTRY_TYPE_CODE,r_attach.SUBMISSION_ID_FK,
   			r_attach.PRIVATE_COMMENT_FLAG,r_attach.PROTOCOL_CONTINGENCY_CODE,
   			r_attach.MINUTE_ENTRY,r_attach.UPDATE_TIMESTAMP,r_attach.UPDATE_USER,1,SYS_GUID(),
   			r_attach.PROTOCOL_ONLN_RVW_FK,r_attach.COMM_SCHEDULE_ACT_ITEMS_ID_FK,r_attach.CREATE_USER,
   			r_attach.CREATE_TIMESTAMP,r_attach.IACUC_PROTOCOL_ID_FK,r_attach.IACUC_SUBMISSION_ID_FK,
   			r_attach.IACUC_PROTOCOL_ONLN_RVW_FK,r_attach.IACUC_REVIEWER_ID_FK);				
		
				
				exception
					when others then
					dbms_output.put_line('ERROR IN Inserting minutes schedule : ' || li_schedule_id_fk||sqlerrm);
			end;
			
	
	
END LOOP;
CLOSE c_attach;
END;
/
