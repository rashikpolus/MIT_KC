
declare
cursor c_protocol is
  select protocol_id, document_number, protocol_number, sequence_number, CREATE_TIMESTAMP 
  from protocol
  where protocol_number = '1303005554A005'
  and active = 'Y';
 
begin

FOR protocol_rec in c_protocol
LOOP
	INSERT INTO PROTOCOL_ACTIONS (PROTOCOL_ACTION_ID, PROTOCOL_NUMBER, SEQUENCE_NUMBER, SUBMISSION_NUMBER, 
	ACTION_ID, PROTOCOL_ACTION_TYPE_CODE, PROTOCOL_ID, SUBMISSION_ID_FK, COMMENTS, ACTION_DATE, 
	UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, ACTUAL_ACTION_DATE, 
	OBJ_ID, PREV_SUBMISSION_STATUS_CODE, 
	SUBMISSION_TYPE_CODE, PREV_PROTOCOL_STATUS_CODE, FOLLOWUP_ACTION_CODE, CREATE_USER, CREATE_TIMESTAMP) 
	VALUES (seq_protocol_id.nextval, protocol_rec.protocol_number, protocol_rec.sequence_number, NULL, 
	1, '100', protocol_rec.protocol_id, NULL, 'ProtocolBase created', protocol_rec.create_timestamp, 
	protocol_rec.create_timestamp, 'admin', 0, protocol_rec.create_timestamp, 
	sys_guid(), NULL, 
	NULL, NULL, NULL, 'admin', protocol_rec.create_timestamp); 
	

	INSERT INTO document_nextvalue(document_number,property_name,next_value,update_timestamp,
	update_user,ver_nbr,obj_id,document_next_value_type)
	VALUES(protocol_rec.document_number,'actionId',2,sysdate,'admin',1,sys_guid(),'DOC');

	UPDATE KREW_DOC_HDR_T
	SET DOC_HDR_STAT_CD = 'S'
	WHERE DOC_HDR_ID = protocol_rec.document_number;

END LOOP;

end;

/
