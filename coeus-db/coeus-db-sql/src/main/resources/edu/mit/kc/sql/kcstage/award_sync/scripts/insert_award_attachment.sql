select ' Started AWARD_ATTACHMENT ' from dual
/
declare
li_count number;
begin
select count(*) into li_count from user_tables where table_name='OSP$AWARD_DOCUMENTS';
if li_count>0 then
execute immediate('drop table OSP$AWARD_DOCUMENTS');
end if;
end;
/
CREATE TABLE OSP$AWARD_DOCUMENTS
(	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
"DOCUMENT_ID" NUMBER(3,0) NOT NULL ENABLE, 
"DOCUMENT_TYPE_CODE" NUMBER(3,0) NOT NULL ENABLE, 
"DESCRIPTION" VARCHAR2(200 BYTE), 
"FILE_NAME" VARCHAR2(300 BYTE) NOT NULL ENABLE, 
"DOCUMENT" BLOB, 
"DOCUMENT_STATUS_CODE" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
"UPDATE_TIMESTAMP" DATE, 
"UPDATE_USER" VARCHAR2(8 BYTE), 
"MIME_TYPE" VARCHAR2(100 BYTE)
)
/   
INSERT INTO OSP$AWARD_DOCUMENTS(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID,DOCUMENT_TYPE_CODE,DESCRIPTION,FILE_NAME,DOCUMENT,DOCUMENT_STATUS_CODE,UPDATE_TIMESTAMP,UPDATE_USER,MIME_TYPE)
SELECT t1.MIT_AWARD_NUMBER,t1.SEQUENCE_NUMBER,t1.DOCUMENT_ID,t1.DOCUMENT_TYPE_CODE,t1.DESCRIPTION,t1.FILE_NAME,t1.DOCUMENT,t1.DOCUMENT_STATUS_CODE,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,t1.MIME_TYPE FROM OSP$AWARD_DOCUMENTS@coeus.kuali t1
WHERE t1.MIT_AWARD_NUMBER IN(SELECT MIT_AWARD_NUMBER FROM TEMP_TAB_TO_SYNC_AWARD WHERE FEED_TYPE='N')
/
COMMIT
/
declare
li_count number;
begin
select count(*) into li_count from user_tables where table_name='TEMP_ATTACHMENT_FILE';
if li_count>0 then
execute immediate('drop table TEMP_ATTACHMENT_FILE');
end if;
end;
/
CREATE TABLE "TEMP_ATTACHMENT_FILE" 
(
"AWARD_NUMBER" CHAR(20) ,
"AWARD_ID" NUMBER(12,0),	
"KUALI_SEQUENCE_NUMBER" NUMBER(4,0), 	
"MIT_AWARD_NUMBER" CHAR(10), 
"SEQUENCE_NUMBER" NUMBER(4,0), 
"DOCUMENT_ID" NUMBER(3,0), 
"DOCUMENT_TYPE_CODE" NUMBER(3,0), 
"DESCRIPTION" VARCHAR2(200), 
"FILE_NAME" VARCHAR2(300), 
"DOCUMENT" BLOB, 
"DOCUMENT_STATUS_CODE" VARCHAR2(1), 
"UPDATE_TIMESTAMP" DATE, 
"UPDATE_USER" VARCHAR2(8), 
"MIME_TYPE" VARCHAR2(100)
)
/
commit
/
insert into TEMP_ATTACHMENT_FILE(AWARD_NUMBER,AWARD_ID,KUALI_SEQUENCE_NUMBER,MIT_AWARD_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID,DOCUMENT_TYPE_CODE,DESCRIPTION,FILE_NAME,DOCUMENT,DOCUMENT_STATUS_CODE,UPDATE_TIMESTAMP,UPDATE_USER,MIME_TYPE)
select a.AWARD_NUMBER,a.AWARD_ID,a.SEQUENCE_NUMBER,aat.MIT_AWARD_NUMBER,aat.SEQUENCE_NUMBER,aat.DOCUMENT_ID,aat.DOCUMENT_TYPE_CODE,aat.DESCRIPTION,aat.FILE_NAME,aat.DOCUMENT,aat.DOCUMENT_STATUS_CODE,aat.UPDATE_TIMESTAMP,aat.UPDATE_USER,aat.MIME_TYPE
from AWARD a inner join 
TEMP_TAB_TO_SYNC_AWARD ts on replace(a.AWARD_NUMBER,'-00','-') = ts.MIT_AWARD_NUMBER and a.SEQUENCE_NUMBER=ts.SEQUENCE_NUMBER
left outer join OSP$AWARD_DOCUMENTS aat on ts.MIT_AWARD_NUMBER=aat.MIT_AWARD_NUMBER and ts.SEQUENCE_NUMBER = aat.SEQUENCE_NUMBER
where ts.FEED_TYPE='N'
/
commit
/  
DECLARE
li_ver_nbr number:=1;
li_file_id	NUMBER(22,0);
li_awd_attachment_id NUMBER(12,0);
li_awd_id NUMBER(22,0);
ls_content_type	VARCHAR2(255);
li_seq NUMBER(4);
ls_mit_awd_num VARCHAR2(12);


CURSOR c_attach IS
select AWARD_NUMBER,AWARD_ID,KUALI_SEQUENCE_NUMBER,MIT_AWARD_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID,DOCUMENT_TYPE_CODE,DESCRIPTION,FILE_NAME,DOCUMENT,DOCUMENT_STATUS_CODE,UPDATE_TIMESTAMP,UPDATE_USER,MIME_TYPE
from TEMP_ATTACHMENT_FILE
where AWARD_NUMBER IS NOT NULL AND KUALI_SEQUENCE_NUMBER IS NOT NULL
ORDER BY MIT_AWARD_NUMBER,SEQUENCE_NUMBER,DOCUMENT_ID;
r_attach c_attach%ROWTYPE;

BEGIN


		IF c_attach%ISOPEN THEN
		CLOSE c_attach;
		END IF;
		OPEN c_attach;
		LOOP
		FETCH c_attach INTO r_attach;
		EXIT WHEN c_attach%NOTFOUND;

			if r_attach.MIT_AWARD_NUMBER is not null then
			-- insert
					begin
						ls_content_type:=r_attach.MIME_TYPE;
						if ls_content_type is null then  
						ls_content_type:=r_attach.FILE_NAME;
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
							else      
								  ls_content_type:='other'; 
							end if;
						end if;
		
						ls_mit_awd_num := r_attach.MIT_AWARD_NUMBER;
						li_seq := r_attach.SEQUENCE_NUMBER;
						select SEQ_ATTACHMENT_ID.NEXTVAL into li_file_id from dual;
						INSERT INTO ATTACHMENT_FILE(FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
						VALUES(li_file_id,li_seq,r_attach.FILE_NAME,ls_content_type,r_attach.DOCUMENT,li_ver_nbr,r_attach.UPDATE_TIMESTAMP,r_attach.UPDATE_USER,SYS_GUID());

						select SEQ_AWARD_ATTACHMENT_ID.NEXTVAL into li_awd_attachment_id from dual;  
						INSERT INTO AWARD_ATTACHMENT(AWARD_ATTACHMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TYPE_CODE,DOCUMENT_ID,FILE_ID,DESCRIPTION,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
						VALUES(li_awd_attachment_id,r_attach.AWARD_ID,r_attach.MIT_AWARD_NUMBER,li_seq,r_attach.DOCUMENT_TYPE_CODE,r_attach.DOCUMENT_ID,li_file_id,r_attach.DESCRIPTION,li_ver_nbr,r_attach.UPDATE_TIMESTAMP,r_attach.UPDATE_USER,SYS_GUID());

						exception
						when others then
						dbms_output.put_line('Error occured Award Number,SequenceNumber  and Document Id is '||r_attach.MIT_AWARD_NUMBER||' , '||r_attach.SEQUENCE_NUMBER||' , '||r_attach.DOCUMENT_ID||' . '||sqlerrm);
						end; 
			
			else
			-- copy
			INSERT INTO AWARD_ATTACHMENT(AWARD_ATTACHMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,TYPE_CODE,DOCUMENT_ID,FILE_ID,DESCRIPTION,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
			SELECT SEQ_AWARD_ATTACHMENT_ID.NEXTVAL,r_attach.AWARD_ID,AWARD_NUMBER,r_attach.KUALI_SEQUENCE_NUMBER,TYPE_CODE,DOCUMENT_ID,FILE_ID,DESCRIPTION,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID()
			FROM AWARD_ATTACHMENT 
			WHERE AWARD_NUMBER = r_attach.AWARD_NUMBER
			AND  SEQUENCE_NUMBER= (SELECT MAX(s1.SEQUENCE_NUMBER) FROM AWARD_ATTACHMENT s1 WHERE s1.AWARD_NUMBER = r_attach.AWARD_NUMBER
											AND s1.SEQUENCE_NUMBER < r_attach.KUALI_SEQUENCE_NUMBER
									);
			
			end if;
			 

		END LOOP;
		CLOSE c_attach;


commit; 
dbms_output.put_line('Completed AWARD_ATTACHMENT!!!');
END;
/
select ' Ended AWARD_ATTACHMENT ' from dual
/