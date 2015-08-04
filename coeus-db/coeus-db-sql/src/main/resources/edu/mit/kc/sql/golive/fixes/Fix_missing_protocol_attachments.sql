DECLARE
li_count number;
coeus_proto_num VARCHAR2(20);
coeus_sequence NUMBER(12);
kc_seq NUMBER(12);
ls_content_type	VARCHAR2(255);
li_file_id	NUMBER(22);
li_ver_nbr NUMBER(8):=1;
li_pa_id NUMBER(12);
li_protocol_id NUMBER(12);
coeus_doc_id NUMBER(12);
li_att_desc	VARCHAR2(500);
li_att_max_seq NUMBER(12);
li_next_doc_id NUMBER(12);
li_comments varchar2(1000);

CURSOR c_attach IS
	SELECT PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_TYPE_CODE,VERSION_NUMBER,DOCUMENT_ID,DESCRIPTION,FILE_NAME,DOCUMENT,
	UPDATE_TIMESTAMP,UPDATE_USER,DOCUMENT_STATUS_CODE
	FROM OSP$PROTOCOL_DOCUMENTS
	ORDER BY PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID;

	r_attach c_attach%ROWTYPE;
	
BEGIN

IF c_attach%ISOPEN THEN
CLOSE c_attach;
END IF;
OPEN c_attach;
LOOP
FETCH c_attach INTO r_attach;
EXIT WHEN c_attach%notfound;
		coeus_proto_num := r_attach.PROTOCOL_NUMBER;
		coeus_sequence := r_attach.SEQUENCE_NUMBER;
		kc_seq 		:= r_attach.SEQUENCE_NUMBER - 1;
		coeus_doc_id := r_attach.DOCUMENT_ID;
		li_att_desc := UPPER(r_attach.description);

		SELECT MAX(SEQUENCE_NUMBER) into li_att_max_seq
		FROM PROTOCOL_ATTACHMENT_PROTOCOL 
		WHERE PROTOCOL_NUMBER = coeus_proto_num;
		
		IF li_att_max_seq IS NULL THEN
			li_att_max_seq := 0;
		END IF;
	
		SELECT COUNT(PROTOCOL_NUMBER) INTO li_count 
		FROM PROTOCOL_ATTACHMENT_PROTOCOL 
		WHERE PROTOCOL_NUMBER = coeus_proto_num AND SEQUENCE_NUMBER = li_att_max_seq and 
		UPPER(description) = li_att_desc;
		
		SELECT PROTOCOL_ID INTO li_protocol_id 
		FROM PROTOCOL 
		WHERE PROTOCOL_NUMBER = coeus_proto_num AND SEQUENCE_NUMBER = kc_seq;
		
		IF li_count = 0 THEN
			begin
				select REVERSE(substr( REVERSE(ls_content_type),1,(instr( REVERSE(ls_content_type),'.',1)-1))) into ls_content_type from dual;
				if    ls_content_type='xls' or  ls_content_type='xlsx' then
					ls_content_type:='application/excel';
				elsif ls_content_type='doc' or  ls_content_type='docx' then
					ls_content_type:='application/msword';  
				elsif ls_content_type='ppt' or  ls_content_type='pptx' then
					ls_content_type:='application/powerpoint';        
				elsif ls_content_type='html'  then
					ls_content_type:='text/html'; 
				elsif ls_content_type='pdf'  then
					ls_content_type:='application/pdf';       
				elsif ls_content_type='jpg' or ls_content_type='jpeg'  then
					ls_content_type:='image/jpeg'; 
				elsif ls_content_type='vsd' then
					ls_content_type:='application/vnd.visio';
				elsif ls_content_type='xml' then
					ls_content_type:='application/xml'; 
				elsif ls_content_type='png' then 
					ls_content_type:='image/png'; 
				elsif ls_content_type='rtf' then 
					ls_content_type:='application/rtf';
				else      
					ls_content_type:='application/octet-stream'; 
				end if;
				exception
					when others then
						ls_content_type:='application/octet-stream'; 
			end;

			begin
				select SEQ_ATTACHMENT_ID.NEXTVAL into li_file_id from dual;
				
				SELECT max(document_id) INTO li_next_doc_id 
				FROM PROTOCOL_ATTACHMENT_PROTOCOL 
				WHERE PROTOCOL_NUMBER = coeus_proto_num AND SEQUENCE_NUMBER = li_att_max_seq; 
				
				IF li_next_doc_id IS NULL THEN
					li_next_doc_id := 0;
				end if;
				
				li_next_doc_id := li_next_doc_id + 1;
				
				INSERT INTO ATTACHMENT_FILE(FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
				VALUES(li_file_id,li_att_max_seq,r_attach.FILE_NAME,ls_content_type,r_attach.DOCUMENT,li_ver_nbr,r_attach.UPDATE_TIMESTAMP,LOWER(r_attach.UPDATE_USER),SYS_GUID());
				
				SELECT SEQ_PROTOCOL_ID.NEXTVAL INTO li_pa_id FROM DUAL;
	
				INSERT INTO PROTOCOL_ATTACHMENT_PROTOCOL(PA_PROTOCOL_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,TYPE_CD,DOCUMENT_ID,FILE_ID,DESCRIPTION,STATUS_CD,CONTACT_NAME,EMAIL_ADDRESS,PHONE_NUMBER,COMMENTS,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,DOCUMENT_STATUS_CODE,CREATE_TIMESTAMP,ATTACHMENT_VERSION)
				VALUES(li_pa_id,li_protocol_id,coeus_proto_num,li_att_max_seq,r_attach.DOCUMENT_TYPE_CODE,li_next_doc_id,li_file_id,r_attach.DESCRIPTION,NULL,NULL,NULL,NULL,NULL,li_ver_nbr,r_attach.UPDATE_TIMESTAMP,r_attach.UPDATE_USER,SYS_GUID(),r_attach.DOCUMENT_STATUS_CODE,LOWER(r_attach.UPDATE_TIMESTAMP),r_attach.VERSION_NUMBER);
		
				
				exception
					when others then
					dbms_output.put_line('ERROR IN Inserting attachments protcol number : ' ||coeus_proto_num||sqlerrm);
			end;
			
		END IF;
	
	
END LOOP;
CLOSE c_attach;
END;
/
