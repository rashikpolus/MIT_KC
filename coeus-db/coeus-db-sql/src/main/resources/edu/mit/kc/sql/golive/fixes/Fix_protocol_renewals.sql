DECLARE
li_count number;
li_ren_id NUMBER(12);
li_ren_mod_id NUMBER(12);
li_summary VARCHAR2(500) := 'Standard Renewal';
li_rec_ind number;
li_ren_pos number;
li_proto_num VARCHAR2(20);
 
CURSOR c_protocol IS
 	SELECT DOCUMENT_NUMBER, PROTOCOL_ID, PROTOCOL_NUMBER,SEQUENCE_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER, INITIAL_SUBMISSION_DATE
	FROM PROTOCOL WHERE PROTOCOL_NUMBER LIKE '%R%' AND DOCUMENT_NUMBER LIKE 'MP%' AND ACTIVE = 'Y';

CURSOR c_renewal(v_ren_num IN VARCHAR2) IS
  	SELECT a.PROTO_AMEND_RENEWAL_ID, a.PROTO_AMEND_REN_NUMBER, a.protocol_number, a.summary, a.SEQUENCE_NUMBER, a.DATE_CREATED, a.UPDATE_TIMESTAMP,a.UPDATE_USER
  	FROM PROTO_AMEND_RENEWAL a
	WHERE PROTO_AMEND_REN_NUMBER = v_ren_num and
	sequence_number in (SELECT MAX(sequence_number) from PROTO_AMEND_RENEWAL 
	where PROTO_AMEND_REN_NUMBER = v_ren_num);

CURSOR c_renemod(v_ren_id IN VARCHAR2) IS
  	SELECT a.PROTO_AMEND_RENEWAL_NUMBER, a.PROTO_AMEND_RENEWAL_ID, a.PROTOCOL_NUMBER, 
	a.PROTOCOL_MODULE_CODE, a.UPDATE_TIMESTAMP, a.UPDATE_USER
  	FROM PROTO_AMEND_RENEW_MODULES a
	WHERE PROTO_AMEND_RENEWAL_ID = v_ren_id;
	
	r_protocol c_protocol%ROWTYPE;

BEGIN

IF c_protocol%ISOPEN THEN
CLOSE c_protocol;
END IF;
OPEN c_protocol;
LOOP
FETCH c_protocol INTO r_protocol;
EXIT WHEN c_protocol%notfound;

		SELECT COUNT(PROTOCOL_NUMBER) INTO li_count 
		FROM PROTO_AMEND_RENEWAL 
		WHERE PROTO_AMEND_REN_NUMBER = r_protocol.protocol_number AND 
		PROTOCOL_ID = r_protocol.protocol_id;
		
		-- no records found in renewal for given protocol id
		IF li_count = 0 THEN
			begin
				li_rec_ind := 0;
				FOR r_renewal IN c_renewal(r_protocol.PROTOCOL_NUMBER)
  				LOOP
					li_rec_ind := 1;
					
					SELECT SEQ_PROTOCOL_ID.NEXTVAL INTO li_ren_id FROM DUAL;
				
					-- amendment renewal
					INSERT INTO PROTO_AMEND_RENEWAL(PROTO_AMEND_RENEWAL_ID,PROTO_AMEND_REN_NUMBER,DATE_CREATED,SUMMARY,
					PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,
					VER_NBR,OBJ_ID)
					VALUES(li_ren_id,r_protocol.protocol_number,r_renewal.date_created,r_renewal.summary,
					r_protocol.protocol_id,r_renewal.protocol_number,r_renewal.sequence_number+1,r_renewal.update_timestamp,r_renewal.update_user,
					1,SYS_GUID());

					-- amendment renewal modules
					FOR r_renemod IN c_renemod(r_renewal.PROTO_AMEND_RENEWAL_ID)
  					LOOP
						SELECT SEQ_PROTOCOL_ID.NEXTVAL INTO li_ren_mod_id FROM DUAL;
					
						INSERT INTO PROTO_AMEND_RENEW_MODULES(PROTO_AMEND_RENEW_MODULES_ID,PROTO_AMEND_RENEWAL_NUMBER,PROTO_AMEND_RENEWAL_ID,PROTOCOL_NUMBER,
   						PROTOCOL_MODULE_CODE,UPDATE_TIMESTAMP,UPDATE_USER,
						VER_NBR,OBJ_ID)
						VALUES(li_ren_mod_id,r_renemod.PROTO_AMEND_RENEWAL_NUMBER,li_ren_id,r_renemod.protocol_number,
						r_renemod.PROTOCOL_MODULE_CODE,r_renemod.UPDATE_TIMESTAMP,r_renemod.UPDATE_USER,
						1,SYS_GUID());
  					END LOOP;

				END LOOP;	
				
				IF li_rec_ind = 0 THEN
					SELECT SEQ_PROTOCOL_ID.NEXTVAL INTO li_ren_id FROM DUAL;
				
					li_ren_pos := INSTR(r_protocol.protocol_number,'R',1) - 1;
					li_proto_num := SUBSTRB(r_protocol.protocol_number,1,li_ren_pos);
					
					-- create new amendment renewal
					INSERT INTO PROTO_AMEND_RENEWAL(PROTO_AMEND_RENEWAL_ID,PROTO_AMEND_REN_NUMBER,DATE_CREATED,SUMMARY,
					PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,
					VER_NBR,OBJ_ID)
					VALUES(li_ren_id,r_protocol.protocol_number,r_protocol.INITIAL_SUBMISSION_DATE,li_summary,
					r_protocol.protocol_id,li_proto_num,0,r_protocol.update_timestamp,r_protocol.update_user,
					1,SYS_GUID());
				END IF;
				
				exception
					when others then
						dbms_output.put_line('Error processing renewal ' || r_protocol.protocol_number);
			end;

			
		END IF;

	
END LOOP;
CLOSE c_protocol;
END;
/
