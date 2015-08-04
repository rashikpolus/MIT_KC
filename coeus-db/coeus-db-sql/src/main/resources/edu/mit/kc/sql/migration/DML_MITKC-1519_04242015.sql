set serveroutput on
/
select ' Start time of PROTOCOL_ATTACHMENT_PERSONAL is '|| localtimestamp from dual
/
delete from ATTACHMENT_FILE where FILE_ID in ( select FILE_ID from PROTOCOL_ATTACHMENT_PERSONNEL )
/
commit
/
delete from PROTOCOL_ATTACHMENT_PERSONNEL
/
commit
/
CREATE TABLE OSP$PROTOCOL_OTHER_DOCUMENTS(	
PROTOCOL_NUMBER VARCHAR2(20), 
SEQUENCE_NUMBER NUMBER(4,0), 
DOCUMENT_ID NUMBER(3,0), 
DOCUMENT_TYPE_CODE NUMBER(3,0), 
DESCRIPTION VARCHAR2(2000), 
FILE_NAME VARCHAR2(300), 
DOCUMENT BLOB, 
UPDATE_TIMESTAMP DATE, 
UPDATE_USER VARCHAR2(8)
)
/
commit
/
truncate table OSP$PROTOCOL_OTHER_DOCUMENTS
/
insert into OSP$PROTOCOL_OTHER_DOCUMENTS(PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID,DOCUMENT_TYPE_CODE,DESCRIPTION,FILE_NAME,
DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER)
select PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID,DOCUMENT_TYPE_CODE,DESCRIPTION,FILE_NAME,DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER 
FROM OSP$PROTOCOL_OTHER_DOCUMENTS@coeus.kuali
/
commit
/
DECLARE
li_ver_nbr NUMBER(8):=1;
ls_proto_num VARCHAR2(20);
li_sequence NUMBER(4);
li_file_id	NUMBER(22,0);
li_protocol_id NUMBER(12,0);
li_count number;
ls_content_type	VARCHAR2(255);
li_seq NUMBER(4);
li_personnel_id NUMBER(12,0);
ls_proto VARCHAR2(10);
ls_number VARCHAR2(20):=null;
ls_test_number VARCHAR2(20);
li_flag NUMBER;
ls_person_id VARCHAR2(40);

CURSOR c_personnel_attach IS
SELECT PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID,DOCUMENT_TYPE_CODE,DESCRIPTION,FILE_NAME,DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER
FROM OSP$PROTOCOL_OTHER_DOCUMENTS ORDER BY PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID;
r_personnel_attach c_personnel_attach%ROWTYPE;

BEGIN



IF c_personnel_attach%ISOPEN THEN
CLOSE c_personnel_attach;
END IF;
OPEN c_personnel_attach;
LOOP
FETCH c_personnel_attach INTO r_personnel_attach;
EXIT WHEN c_personnel_attach%notfound;

ls_proto_num := r_personnel_attach.PROTOCOL_NUMBER;
li_sequence  := r_personnel_attach.SEQUENCE_NUMBER;
li_seq 		:= r_personnel_attach.SEQUENCE_NUMBER - 1;

dbms_output.put_line('PROTOCOL_NUMBER:'||ls_proto_num||'and SEQUENCE_NUMBER:'||li_seq);

ls_content_type:=r_personnel_attach.FILE_NAME;
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
ls_content_type:='other'; 
end if;

SELECT SUBSTR(ls_proto_num,11,1) INTO ls_proto FROM DUAL;

		if ls_proto is not null and ls_proto!='T' then			
			li_flag:=1;
			
			if ls_number is null then
				ls_number := ls_proto_num||li_sequence;	
				li_flag := 0;
				
			elsif ls_number!=(ls_proto_num||li_sequence) then   
				li_flag := 0;
				ls_number := ls_proto_num||li_sequence;	
			end if;

		elsif ls_proto is null then	
			begin
				SELECT PROTOCOL_ID INTO li_protocol_id FROM PROTOCOL WHERE PROTOCOL_NUMBER = ls_proto_num AND SEQUENCE_NUMBER = li_seq;
			exception
			when others then
			dbms_output.put_line('Error while fetching PROTOCOL_ID using PROTOCOL_NUMBER:'||ls_proto_num||'and SEQUENCE_NUMBER:'||li_seq||'and error is:'||sqlerrm);
			end;

			select SEQ_ATTACHMENT_ID.NEXTVAL into li_file_id from dual;
			INSERT INTO ATTACHMENT_FILE(FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
			VALUES(li_file_id,li_seq,r_personnel_attach.FILE_NAME,ls_content_type,r_personnel_attach.DOCUMENT,li_ver_nbr,
			r_personnel_attach.UPDATE_TIMESTAMP,r_personnel_attach.UPDATE_USER,SYS_GUID());
			commit;

			begin
				SELECT PROTOCOL_PERSON_ID INTO ls_person_id FROM PROTOCOL_PERSONS WHERE  PROTOCOL_NUMBER=ls_proto_num AND SEQUENCE_NUMBER=li_seq
				AND PROTOCOL_ID=li_protocol_id AND PROTOCOL_PERSON_ROLE_ID = 'PI' ;
			exception
			when others then
			dbms_output.put_line('Missing PERSON_ID in PROTOCOL_PERSONS for PROTOCOL_ID:'||li_protocol_id||'PROTOCOL_NUMBER:'||ls_proto_num||'SEQUENCE_NUMBER:'||li_seq);
			end;
			
			begin
				SELECT SEQ_PROTOCOL_ID.NEXTVAL INTO li_personnel_id FROM DUAL;
				INSERT INTO PROTOCOL_ATTACHMENT_PERSONNEL(PA_PERSONNEL_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,TYPE_CD,DOCUMENT_ID,FILE_ID,
				DESCRIPTION,PERSON_ID,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
				VALUES(li_personnel_id,li_protocol_id,ls_proto_num,li_seq,r_personnel_attach.DOCUMENT_TYPE_CODE,r_personnel_attach.DOCUMENT_ID,
				li_file_id,r_personnel_attach.DESCRIPTION,ls_person_id,li_ver_nbr,r_personnel_attach.UPDATE_TIMESTAMP,r_personnel_attach.UPDATE_USER,SYS_GUID());
			exception
			when others then
			dbms_output.put_line('ERROR IN PROTOCOL_ATTACHMENT_PERSONNEL,PROTOCOL_NUMBER:'||ls_proto_num||'SEQUENCE_NUMBER:'||li_seq||'PROTOCOL_ID:'||li_protocol_id||'PERSON_ID:'||ls_person_id||'-'||sqlerrm);
			end;

			IF li_seq > 0 THEN
				li_flag := 1;
			
				if ls_test_number is null then
					ls_test_number := ls_proto_num||li_sequence;					
					li_flag := 0;
					elsif ls_test_number!=(ls_proto_num||li_sequence) then   
					li_flag := 0;
					ls_test_number := ls_proto_num||li_sequence;
					
				end if;
				IF  li_flag=0 THEN

					INSERT INTO PROTOCOL_ATTACHMENT_PERSONNEL(PA_PERSONNEL_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,TYPE_CD,DOCUMENT_ID,FILE_ID,
					DESCRIPTION,PERSON_ID,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
					SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,PROTOCOL_NUMBER,li_seq,TYPE_CD,DOCUMENT_ID,FILE_ID,DESCRIPTION,PERSON_ID,VER_NBR,
					UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID() FROM PROTOCOL_ATTACHMENT_PERSONNEL WHERE PROTOCOL_NUMBER=ls_proto_num AND
					SEQUENCE_NUMBER=(SELECT MAX(SEQUENCE_NUMBER) FROM PROTOCOL_ATTACHMENT_PERSONNEL WHERE  PROTOCOL_NUMBER=ls_proto_num
								AND SEQUENCE_NUMBER < li_seq);
				
				END IF;
				
			END IF;
		
		end if;

END LOOP;
CLOSE c_personnel_attach;

END;
/
commit
/
select ' End time of PROTOCOL_ATTACHMENT_PERSONAL is '|| localtimestamp from dual
/
select ' Start time of PROTOCOL_ATTACHMENT_PROTOCOL is '|| localtimestamp from dual
/
delete from ATTACHMENT_FILE where FILE_ID in ( select FILE_ID from PROTOCOL_ATTACHMENT_PROTOCOL )
/
commit
/
delete from PROTOCOL_ATTACHMENT_PROTOCOL
/
commit
/
CREATE TABLE OSP$PROTOCOL_DOCUMENTS
(PROTOCOL_NUMBER VARCHAR2(20), 
SEQUENCE_NUMBER NUMBER(4,0), 
DOCUMENT_TYPE_CODE NUMBER(3,0), 
DESCRIPTION VARCHAR2(200) , 
FILE_NAME VARCHAR2(300) , 
DOCUMENT BLOB, 
UPDATE_TIMESTAMP DATE, 
UPDATE_USER VARCHAR2(8), 
VERSION_NUMBER NUMBER(3,0), 
DOCUMENT_STATUS_CODE NUMBER(3,0) , 
DOCUMENT_ID NUMBER(4,0) 
)
/
truncate table OSP$PROTOCOL_DOCUMENTS
/
insert into OSP$PROTOCOL_DOCUMENTS(PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_TYPE_CODE,VERSION_NUMBER,DOCUMENT_ID,DESCRIPTION,FILE_NAME,
DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER,DOCUMENT_STATUS_CODE)
select PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_TYPE_CODE,VERSION_NUMBER,DOCUMENT_ID,DESCRIPTION,FILE_NAME,DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER,
DOCUMENT_STATUS_CODE FROM OSP$PROTOCOL_DOCUMENTS@coeus.kuali
/
commit
/
DECLARE
li_ver_nbr NUMBER(8):=1;
ls_proto_num VARCHAR2(20);
li_sequence NUMBER(4);
li_file_id	NUMBER(22,0);
li_awd_attachment_id NUMBER(12,0);
li_protocol_id NUMBER(12,0);
li_count number;
ls_content_type	VARCHAR2(255);
li_seq NUMBER(4);
ls_proto VARCHAR2(10);
ls_number VARCHAR2(20):=null;
ls_test_number VARCHAR2(20);
li_flag NUMBER;
li_pa_id NUMBER(12,0);

CURSOR c_attach IS
	SELECT PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_TYPE_CODE,VERSION_NUMBER,DOCUMENT_ID,DESCRIPTION,FILE_NAME,DOCUMENT,
	UPDATE_TIMESTAMP,UPDATE_USER,DOCUMENT_STATUS_CODE
	FROM OSP$PROTOCOL_DOCUMENTS ORDER BY PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID;
	r_attach c_attach%ROWTYPE;

CURSOR c_ammend_attach IS
		SELECT PROTOCOL_NUMBER,SEQUENCE_NUMBER,VERSION_NUMBER,DOCUMENT_TYPE_CODE,DOCUMENT_ID,DESCRIPTION,FILE_NAME,
		DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER,DOCUMENT_STATUS_CODE
		FROM OSP$PROTOCOL_DOCUMENTS
		WHERE PROTOCOL_NUMBER = ls_proto_num 
		AND SEQUENCE_NUMBER = li_sequence 
		ORDER BY PROTOCOL_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID;									
		r_ammend_attach c_ammend_attach%ROWTYPE;



BEGIN

IF c_attach%ISOPEN THEN
CLOSE c_attach;
END IF;
OPEN c_attach;
LOOP
FETCH c_attach INTO r_attach;
EXIT WHEN c_attach%notfound;

	ls_proto_num := r_attach.PROTOCOL_NUMBER;
	li_sequence := r_attach.SEQUENCE_NUMBER;
	li_seq 		:= r_attach.SEQUENCE_NUMBER - 1;
	
	SELECT COUNT(PROTOCOL_ID) INTO li_count FROM PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND SEQUENCE_NUMBER = li_seq;
	
	IF li_count = 1 THEN
	
		SELECT PROTOCOL_ID INTO li_protocol_id FROM PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND SEQUENCE_NUMBER = li_seq;	
		ls_content_type:=r_attach.FILE_NAME;
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
			ls_content_type:='other'; 
			end if;
			
		exception
		when others then
		ls_content_type:='other'; 
		end;
	SELECT SUBSTR(ls_proto_num,11,1) INTO ls_proto FROM DUAL;

	if ls_proto is not null and ls_proto != 'T' then
		--SELECT FN_GET_KUALI_SEQ(ls_proto_num,li_sequence) INTO li_seq FROM DUAL;

			li_flag := 1;
			if ls_number is null then
				ls_number := ls_proto_num||li_sequence;			
				li_flag := 0;
				
			elsif ls_number != (ls_proto_num||li_sequence) then   
				li_flag:=0;
				ls_number := ls_proto_num||li_sequence;			
				
			end if;

			IF  li_flag = 0 THEN
				begin
							---PROC_AMMENDMENT_CHILD(ls_proto_num,li_seq,li_sequence,'PROTOCOL ATTACHMENT'); 
				
								
									
									IF c_ammend_attach%ISOPEN THEN
									CLOSE c_ammend_attach;
									END IF;
									
									OPEN c_ammend_attach;
									LOOP
									FETCH c_ammend_attach INTO r_ammend_attach;
									--li_seq := as_sequence;

									begin
									SELECT PROTOCOL_ID INTO li_protocol_id FROM PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND SEQUENCE_NUMBER = li_seq;
									exception
									when others then
									li_protocol_id := null;
									continue;
									end;
									ls_content_type := r_ammend_attach.FILE_NAME;
									
									select REVERSE(substr( REVERSE(ls_content_type),1,(instr( REVERSE(ls_content_type),'.',1)-1))) into ls_content_type 
									from dual;
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
										  ls_content_type:='other';
									end if;


									select SEQ_ATTACHMENT_ID.NEXTVAL into li_file_id from dual;

									begin
									INSERT INTO ATTACHMENT_FILE(FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,
									UPDATE_USER,OBJ_ID)
									VALUES(li_file_id,li_seq,r_ammend_attach.FILE_NAME,ls_content_type,r_ammend_attach.DOCUMENT,li_ver_nbr,
									r_ammend_attach.UPDATE_TIMESTAMP,r_ammend_attach.UPDATE_USER,SYS_GUID());
									commit;
									exception
									when others then
									dbms_output.put_line('ERROR IN ATTACHMENT_FILE '||sqlerrm);
									end;


									begin
									SELECT SEQ_PROTOCOL_ID.NEXTVAL INTO li_pa_id FROM DUAL;
									INSERT INTO PROTOCOL_ATTACHMENT_PROTOCOL(PA_PROTOCOL_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,TYPE_CD,
									DOCUMENT_ID,FILE_ID,DESCRIPTION,STATUS_CD,CONTACT_NAME,EMAIL_ADDRESS,PHONE_NUMBER,COMMENTS,VER_NBR,
									UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,DOCUMENT_STATUS_CODE,CREATE_TIMESTAMP,ATTACHMENT_VERSION)
									VALUES(li_pa_id,li_protocol_id,ls_proto_num,li_seq,r_ammend_attach.DOCUMENT_TYPE_CODE,r_ammend_attach.DOCUMENT_ID,
									li_file_id,r_ammend_attach.DESCRIPTION,NULL,NULL,NULL,NULL,NULL,li_ver_nbr,r_ammend_attach.UPDATE_TIMESTAMP,
									LOWER(r_ammend_attach.UPDATE_USER),SYS_GUID(),r_ammend_attach.DOCUMENT_STATUS_CODE,r_ammend_attach.UPDATE_TIMESTAMP,
									r_ammend_attach.VERSION_NUMBER);
									exception
									when others then
									dbms_output.put_line('ERROR IN PROTOCOL_ATTATCHMENT_PROTOCOL 1 ,PROTOCOL_NUMBER:'||ls_proto_num||'SEQUENCE_NUMBER:'||li_sequence||'-'||sqlerrm);
									end;


									SELECT COUNT(PROTOCOL_NUMBER) INTO li_count FROM PROTOCOL WHERE PROTOCOL_NUMBER = ls_proto_num ;
									li_count := li_count - 1;
									FOR li_num in 1..li_count
									LOOP
									li_seq := li_seq + 1;

										begin
										SELECT PROTOCOL_ID INTO li_protocol_id FROM PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND SEQUENCE_NUMBER=li_seq;
										INSERT INTO PROTOCOL_ATTACHMENT_PROTOCOL(PA_PROTOCOL_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,TYPE_CD,DOCUMENT_ID,FILE_ID,DESCRIPTION,STATUS_CD,CONTACT_NAME,EMAIL_ADDRESS,PHONE_NUMBER,COMMENTS,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,DOCUMENT_STATUS_CODE,CREATE_TIMESTAMP,ATTACHMENT_VERSION)
										SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,PROTOCOL_NUMBER,li_seq,TYPE_CD,DOCUMENT_ID,FILE_ID,DESCRIPTION,STATUS_CD,CONTACT_NAME,EMAIL_ADDRESS,PHONE_NUMBER,COMMENTS,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID(),DOCUMENT_STATUS_CODE,CREATE_TIMESTAMP,ATTACHMENT_VERSION FROM PROTOCOL_ATTACHMENT_PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND
										SEQUENCE_NUMBER=(SELECT MAX(SEQUENCE_NUMBER) FROM PROTOCOL_ATTACHMENT_PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND SEQUENCE_NUMBER<li_seq);
										exception
										when others then
										dbms_output.put_line('ERROR IN PROTOCOL_ATTACHMENT_PROTOCOL 1 (procedure[proc_ammendment_child]) where Protocol_number,sequence_number is '||ls_proto_num||' , '||li_seq||' error is '||sqlerrm);
										end;

									END LOOP;


									END LOOP;
									CLOSE c_ammend_attach;
				
				
				exception
				when others then
				dbms_output.put_line('Error occoured in PROC_AMMENDMENT_CHILD in protocol_attachment_protocol . Protocol number is'||ls_proto_num||'SEQUENCE_NUMBER:'||li_sequence||'-'||sqlerrm);
				end;
			END IF;

		elsif ls_proto is null then


		select SEQ_ATTACHMENT_ID.NEXTVAL into li_file_id from dual;
		
		INSERT INTO ATTACHMENT_FILE(FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
		VALUES(li_file_id,li_seq,r_attach.FILE_NAME,ls_content_type,r_attach.DOCUMENT,li_ver_nbr,r_attach.UPDATE_TIMESTAMP,LOWER(r_attach.UPDATE_USER),SYS_GUID());
		
		commit;
		
		begin
			SELECT SEQ_PROTOCOL_ID.NEXTVAL INTO li_pa_id FROM DUAL;
			INSERT INTO PROTOCOL_ATTACHMENT_PROTOCOL(PA_PROTOCOL_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,TYPE_CD,DOCUMENT_ID,FILE_ID,DESCRIPTION,STATUS_CD,CONTACT_NAME,EMAIL_ADDRESS,PHONE_NUMBER,COMMENTS,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,DOCUMENT_STATUS_CODE,CREATE_TIMESTAMP,ATTACHMENT_VERSION)
			VALUES(li_pa_id,li_protocol_id,ls_proto_num,li_seq,r_attach.DOCUMENT_TYPE_CODE,r_attach.DOCUMENT_ID,li_file_id,r_attach.DESCRIPTION,NULL,NULL,NULL,NULL,NULL,li_ver_nbr,r_attach.UPDATE_TIMESTAMP,r_attach.UPDATE_USER,SYS_GUID(),r_attach.DOCUMENT_STATUS_CODE,LOWER(r_attach.UPDATE_TIMESTAMP),r_attach.VERSION_NUMBER);
		
		exception
		when others then
		dbms_output.put_line('ERROR IN PROTOCOL_ATTATCHMENT_PROTOCOL 2 ,PROTOCOL_NUMBER: '||ls_proto_num||' SEQUENCE_NUMBER: '||li_file_id||' - '||sqlerrm);
		end;

		IF li_seq > 0 THEN
			li_flag := 1;
			if ls_test_number is null then
				ls_test_number := ls_proto_num||li_sequence;			
				li_flag:=0;
			elsif ls_test_number != (ls_proto_num||li_sequence) then   
				li_flag:=0;				
				ls_test_number := ls_proto_num||li_sequence;
			end if;
			
				IF  li_flag = 0 THEN


					INSERT INTO PROTOCOL_ATTACHMENT_PROTOCOL(PA_PROTOCOL_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,TYPE_CD,DOCUMENT_ID,FILE_ID,DESCRIPTION,STATUS_CD,CONTACT_NAME,EMAIL_ADDRESS,PHONE_NUMBER,COMMENTS,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,DOCUMENT_STATUS_CODE,CREATE_TIMESTAMP,ATTACHMENT_VERSION)
					SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,PROTOCOL_NUMBER,li_seq,TYPE_CD,DOCUMENT_ID,FILE_ID,DESCRIPTION,STATUS_CD,CONTACT_NAME,EMAIL_ADDRESS,PHONE_NUMBER,COMMENTS,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID(),DOCUMENT_STATUS_CODE,CREATE_TIMESTAMP,ATTACHMENT_VERSION FROM PROTOCOL_ATTACHMENT_PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND
					SEQUENCE_NUMBER=(SELECT MAX(SEQUENCE_NUMBER) FROM PROTOCOL_ATTACHMENT_PROTOCOL WHERE PROTOCOL_NUMBER=ls_proto_num AND SEQUENCE_NUMBER<li_seq);

				END IF;
		END IF;
		
	end if;
	ELSE
	dbms_output.put_line('PROTOCOL_ID NOT IN PROTOCOL TABLE FOR PROTOCOL_NUMBER:'||ls_proto_num||' AND SEQUENCE_NUMBER:'||li_seq);
	END IF;
END LOOP;
CLOSE c_attach;
END;
/
commit
/
select ' End time of PROTOCOL_ATTACHMENT_PROTOCOL is '|| localtimestamp from dual
/