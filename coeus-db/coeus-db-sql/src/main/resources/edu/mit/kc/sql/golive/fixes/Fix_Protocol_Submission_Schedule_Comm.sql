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
li_comm_id_fk NUMBER(12);
li_schedule_id_fk NUMBER(12);
li_comments varchar2(1000);

CURSOR c_attach IS
	select a.SUBMISSION_ID, a.SCHEDULE_ID
	from protocol_submission a where schedule_id is not null;

	r_attach c_attach%ROWTYPE;
	
BEGIN

IF c_attach%ISOPEN THEN
CLOSE c_attach;
END IF;
OPEN c_attach;
LOOP
FETCH c_attach INTO r_attach;
EXIT WHEN c_attach%notfound;

		SELECT max(id) into li_schedule_id_fk 
		FROM comm_schedule 
		WHERE SCHEDULE_ID = r_attach.SCHEDULE_ID;
		
		SELECT committee_id_fk into li_comm_id_fk 
		FROM comm_schedule 
		WHERE id = li_schedule_id_fk;
		
			begin
				UPDATE protocol_submission
				set schedule_id_fk = li_schedule_id_fk,
				committee_id_fk = li_comm_id_fk
				where SUBMISSION_ID = r_attach.SUBMISSION_ID;
				
				exception
					when others then
					dbms_output.put_line('ERROR IN Inserting minutes schedule : ' || li_schedule_id_fk||sqlerrm);
			end;
			
	
	
END LOOP;
CLOSE c_attach;
END;
/
