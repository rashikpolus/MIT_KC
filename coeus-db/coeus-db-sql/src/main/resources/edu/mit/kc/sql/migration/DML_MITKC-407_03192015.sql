DELETE FROM ATTACHMENT_FILE WHERE FILE_ID IN (SELECT FILE_ID FROM SUBAWARD_AMOUNT_INFO WHERE SUBAWARD_CODE IN (SELECT to_number(SUBCONTRACT_CODE) from OSP$SUBCONTRACT_AMOUNT_INFO@coeus.kuali))
/
DELETE FROM SUBAWARD_AMOUNT_INFO WHERE SUBAWARD_CODE IN (SELECT to_number(SUBCONTRACT_CODE) from OSP$SUBCONTRACT_AMOUNT_INFO@coeus.kuali);
/
COMMIT
/
DROP TABLE TEMP_SUBAWARD_AMT_INFO
/
DROP TABLE TEMP_SUBAWARD_AMT_RELEASE
/
COMMIT
/
CREATE TABLE "TEMP_SUBAWARD_AMT_INFO" 
   (	"SUBCONTRACT_CODE" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"LINE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"OBLIGATED_AMOUNT" NUMBER(12,2), 
	"OBLIGATED_CHANGE" NUMBER(12,2), 
	"ANTICIPATED_AMOUNT" NUMBER(12,2), 
	"ANTICIPATED_CHANGE" NUMBER(12,2), 
	"EFFECTIVE_DATE" DATE, 
	"COMMENTS" VARCHAR2(300 BYTE), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"FILE_NAME" VARCHAR2(150 BYTE), 
	"DOCUMENT" BLOB, 
	"MIME_TYPE" VARCHAR2(100 BYTE), 
	"PERFORMANCE_START_DATE" DATE, 
	"PERFORMANCE_END_DATE" DATE, 
	"MODIFICATION_NUMBER" VARCHAR2(50 BYTE), 
	"MODIFICATION_EFFECTIVE_DATE" DATE);
	commit;
	insert into TEMP_SUBAWARD_AMT_INFO(SUBCONTRACT_CODE,LINE_NUMBER,SEQUENCE_NUMBER,OBLIGATED_AMOUNT,OBLIGATED_CHANGE,ANTICIPATED_AMOUNT,ANTICIPATED_CHANGE,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,FILE_NAME,DOCUMENT,MIME_TYPE,PERFORMANCE_START_DATE,PERFORMANCE_END_DATE,MODIFICATION_NUMBER,MODIFICATION_EFFECTIVE_DATE)
	SELECT SUBCONTRACT_CODE,LINE_NUMBER,SEQUENCE_NUMBER,OBLIGATED_AMOUNT,OBLIGATED_CHANGE,ANTICIPATED_AMOUNT,ANTICIPATED_CHANGE,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,FILE_NAME,DOCUMENT,MIME_TYPE,PERFORMANCE_START_DATE,PERFORMANCE_END_DATE,MODIFICATION_NUMBER,MODIFICATION_EFFECTIVE_DATE FROM OSP$SUBCONTRACT_AMOUNT_INFO@Coeus.Kuali;
    commit;	
  CREATE TABLE "TEMP_SUBAWARD_AMT_RELEASE" 
   (	"SUBCONTRACT_CODE" VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"LINE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"AMOUNT_RELEASED" NUMBER(12,2) NOT NULL ENABLE, 
	"EFFECTIVE_DATE" DATE NOT NULL ENABLE, 
	"COMMENTS" VARCHAR2(300 BYTE), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"INVOICE_NUMBER" VARCHAR2(50 BYTE), 
	"START_DATE" DATE, 
	"END_DATE" DATE, 
	"STATUS_CODE" VARCHAR2(1 BYTE), 
	"APPROVAL_COMMENTS" VARCHAR2(2000 BYTE), 
	"APPROVED_BY_USER" VARCHAR2(8 BYTE), 
	"APPROVAL_DATE" DATE, 
	"DOCUMENT" BLOB, 
	"FILE_NAME" VARCHAR2(150 BYTE), 
	"CREATED_BY" VARCHAR2(8 BYTE), 
	"CREATED_DATE" DATE, 
	"MIME_TYPE" VARCHAR2(100 BYTE));
	commit;
	insert into TEMP_SUBAWARD_AMT_RELEASE(SUBCONTRACT_CODE,LINE_NUMBER,SEQUENCE_NUMBER,AMOUNT_RELEASED,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,INVOICE_NUMBER,START_DATE,END_DATE,STATUS_CODE,APPROVAL_COMMENTS,APPROVED_BY_USER,APPROVAL_DATE,DOCUMENT,FILE_NAME,CREATED_BY,CREATED_DATE,MIME_TYPE)
	SELECT SUBCONTRACT_CODE,LINE_NUMBER,SEQUENCE_NUMBER,AMOUNT_RELEASED,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,INVOICE_NUMBER,START_DATE,END_DATE,STATUS_CODE,APPROVAL_COMMENTS,APPROVED_BY_USER,APPROVAL_DATE,DOCUMENT,FILE_NAME,CREATED_BY,CREATED_DATE,MIME_TYPE FROM OSP$SUBCONTRACT_AMT_RELEASED@Coeus.Kuali;
	commit
  /
DECLARE
li_ver_nbr NUMBER(8):=1;
li_amt_info NUMBER(12,0);
li_seq NUMBER(4);
li_subaward_id NUMBER(12,0);
li_seq_attachment NUMBER(22,0);
ls_file_name VARCHAR2(150 BYTE);
ls_subaward_code VARCHAR2(20);
ls_content_type	VARCHAR2(255);
ls_sub_awd VARCHAR2(20);
li_mit_seq NUMBER(4);

CURSOR c_subaward IS
SELECT SUBAWARD_CODE,SEQUENCE_NUMBER FROM SUBAWARD ORDER BY SUBAWARD_CODE,SEQUENCE_NUMBER;
r_subaward c_subaward%ROWTYPE;

CURSOR c_amt_info(as_mit varchar2,as_seq number) IS
SELECT sa.SUBCONTRACT_CODE,sa.LINE_NUMBER,as_seq as SEQUENCE_NUMBER,sa.OBLIGATED_AMOUNT,sa.OBLIGATED_CHANGE,sa.ANTICIPATED_AMOUNT,sa.ANTICIPATED_CHANGE,sa.EFFECTIVE_DATE,sa.COMMENTS,sa.UPDATE_TIMESTAMP,sa.UPDATE_USER,sa.FILE_NAME,sa.DOCUMENT,sa.MIME_TYPE,sa.PERFORMANCE_START_DATE,sa.PERFORMANCE_END_DATE,sa.MODIFICATION_NUMBER,sa.MODIFICATION_EFFECTIVE_DATE FROM TEMP_SUBAWARD_AMT_INFO sa
where sa.SUBCONTRACT_CODE=as_mit and SEQUENCE_NUMBER =(
select max(aw.sequence_number) from TEMP_SUBAWARD_AMT_INFO aw where  aw.SUBCONTRACT_CODE=sa.SUBCONTRACT_CODE and aw.sequence_number<=as_seq);
r_amt_info c_amt_info%ROWTYPE;

BEGIN

IF c_subaward%ISOPEN THEN
CLOSE c_subaward;
END IF;
OPEN c_subaward;
LOOP
FETCH c_subaward INTO r_subaward;
EXIT WHEN c_subaward%NOTFOUND;
select LTRIM(TO_CHAR(r_subaward.SUBAWARD_CODE, '00000000')) into ls_sub_awd from dual;
--SELECT FN_GET_SEQ(r_subaward.SUBAWARD_CODE,r_subaward.SEQUENCE_NUMBER) INTO li_mit_seq FROM DUAL;
li_mit_seq:=r_subaward.SEQUENCE_NUMBER;

IF c_amt_info%ISOPEN THEN
CLOSE c_amt_info;
END IF;
OPEN c_amt_info(ls_sub_awd,li_mit_seq);
LOOP
FETCH c_amt_info INTO r_amt_info;
EXIT WHEN c_amt_info%NOTFOUND;
li_seq:=r_subaward.SEQUENCE_NUMBER;
--SELECT FN_GET_KUALI_SEQ(r_amt_info.SUBCONTRACT_CODE,r_amt_info.SEQUENCE_NUMBER) INTO li_seq FROM DUAL;
SELECT SUBAWARD_AMT_INFO_ID_S.NEXTVAL INTO li_amt_info FROM DUAL; 
BEGIN
SELECT SUBAWARD_ID INTO li_subaward_id FROM SUBAWARD WHERE SUBAWARD_CODE=r_subaward.SUBAWARD_CODE AND SEQUENCE_NUMBER=li_seq;
EXCEPTION 
WHEN OTHERS THEN 
dbms_output.put_line('MISSING SUBAWARD_ID,SUBAWARD_CODE:'||to_number(r_amt_info.SUBCONTRACT_CODE) ||'SEQUENCE_NUMBER:'||li_seq||'-'||sqlerrm);
END;
SELECT SEQ_ATTACHMENT_ID.NEXTVAL INTO li_seq_attachment FROM DUAL;
SELECT to_number(r_amt_info.SUBCONTRACT_CODE) INTO ls_subaward_code FROM dual;
ls_file_name:=r_amt_info.FILE_NAME;
ls_content_type:=r_amt_info.MIME_TYPE;
if ls_content_type is null then  
ls_content_type:=r_amt_info.FILE_NAME;
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

IF ls_file_name IS NOT NULL THEN

BEGIN

INSERT INTO ATTACHMENT_FILE (FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
VALUES(li_seq_attachment,li_seq,r_amt_info.FILE_NAME,ls_content_type,r_amt_info.DOCUMENT,li_ver_nbr,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,SYS_GUID());

INSERT INTO SUBAWARD_AMOUNT_INFO(SUBAWARD_AMOUNT_INFO_ID,SUBAWARD_ID,OBLIGATED_AMOUNT,OBLIGATED_CHANGE,ANTICIPATED_AMOUNT,ANTICIPATED_CHANGE,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,FILE_NAME,DOCUMENT,MIME_TYPE,PERFORMANCE_START_DATE,PERFORMANCE_END_DATE,MODIFICATION_NUMBER,MODIFICATION_EFFECTIVE_DATE,VER_NBR,OBJ_ID,FILE_ID,SEQUENCE_NUMBER,SUBAWARD_CODE)
VALUES(li_amt_info,li_subaward_id,r_amt_info.OBLIGATED_AMOUNT,r_amt_info.OBLIGATED_CHANGE,r_amt_info.ANTICIPATED_AMOUNT,r_amt_info.ANTICIPATED_CHANGE,r_amt_info.EFFECTIVE_DATE,r_amt_info.COMMENTS,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,r_amt_info.FILE_NAME,r_amt_info.DOCUMENT,null,r_amt_info.PERFORMANCE_START_DATE,r_amt_info.PERFORMANCE_END_DATE,r_amt_info.MODIFICATION_NUMBER,r_amt_info.MODIFICATION_EFFECTIVE_DATE,li_ver_nbr,SYS_GUID(),li_seq_attachment,li_seq,ls_subaward_code);
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('ERROR IN SUBAWARD_AMOUNT_INFO,SUBAWARD_CODE:'||r_amt_info.SUBCONTRACT_CODE||'SEQUENCE_NUMBER:'||r_amt_info.SEQUENCE_NUMBER||'-'||sqlerrm);
END;

ELSE
BEGIN

INSERT INTO SUBAWARD_AMOUNT_INFO(SUBAWARD_AMOUNT_INFO_ID,SUBAWARD_ID,OBLIGATED_AMOUNT,OBLIGATED_CHANGE,ANTICIPATED_AMOUNT,ANTICIPATED_CHANGE,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,FILE_NAME,DOCUMENT,MIME_TYPE,PERFORMANCE_START_DATE,PERFORMANCE_END_DATE,MODIFICATION_NUMBER,MODIFICATION_EFFECTIVE_DATE,VER_NBR,OBJ_ID,FILE_ID,SEQUENCE_NUMBER,SUBAWARD_CODE)
VALUES(li_amt_info,li_subaward_id,r_amt_info.OBLIGATED_AMOUNT,r_amt_info.OBLIGATED_CHANGE,r_amt_info.ANTICIPATED_AMOUNT,r_amt_info.ANTICIPATED_CHANGE,r_amt_info.EFFECTIVE_DATE,r_amt_info.COMMENTS,r_amt_info.UPDATE_TIMESTAMP,r_amt_info.UPDATE_USER,r_amt_info.FILE_NAME,r_amt_info.DOCUMENT,null,r_amt_info.PERFORMANCE_START_DATE,r_amt_info.PERFORMANCE_END_DATE,r_amt_info.MODIFICATION_NUMBER,r_amt_info.MODIFICATION_EFFECTIVE_DATE,li_ver_nbr,SYS_GUID(),null,li_seq,ls_subaward_code);
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('ERROR IN SUBAWARD_AMOUNT_INFO,SUBAWARD_CODE:'||r_amt_info.SUBCONTRACT_CODE||'SEQUENCE_NUMBER:'||r_amt_info.SEQUENCE_NUMBER||'-'||sqlerrm);
END;

END IF;

END LOOP;
CLOSE c_amt_info;
END LOOP;
CLOSE c_subaward;
END;
/
DELETE FROM SUBAWARD_AMT_RELEASED WHERE SUBAWARD_CODE IN (SELECT to_number(SUBCONTRACT_CODE) from OSP$SUBCONTRACT_AMT_RELEASED@coeus.kuali);
/
COMMIT
/
DECLARE
li_ver_nbr NUMBER(8):=1;
li_amt_released NUMBER(12,0);
li_seq NUMBER(4);
li_subaward_id NUMBER(12,0);
ls_subaward_code VARCHAR2(20);
ls_app_id VARCHAR2(40 BYTE);
ls_create_id VARCHAR2(40 BYTE);
ls_app_comm VARCHAR2(2000 BYTE);
ls_invoice VARCHAR2(50 BYTE);
ls_sub_awd VARCHAR2(20);
li_mit_seq NUMBER(4);

CURSOR c_subaward IS
SELECT SUBAWARD_CODE,SEQUENCE_NUMBER FROM SUBAWARD ORDER BY SUBAWARD_CODE,SEQUENCE_NUMBER;
r_subaward c_subaward%ROWTYPE;

CURSOR c_amt(as_mit varchar2,as_seq number) IS
SELECT SUBCONTRACT_CODE,LINE_NUMBER,as_seq as SEQUENCE_NUMBER,AMOUNT_RELEASED,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,INVOICE_NUMBER,START_DATE,END_DATE,STATUS_CODE,APPROVAL_COMMENTS,APPROVED_BY_USER,APPROVAL_DATE,DOCUMENT,FILE_NAME,CREATED_BY,CREATED_DATE,MIME_TYPE
FROM TEMP_SUBAWARD_AMT_RELEASE
where SUBCONTRACT_CODE =as_mit
 and SEQUENCE_NUMBER =(
select max(aw.sequence_number) from TEMP_SUBAWARD_AMT_RELEASE aw where  aw.SUBCONTRACT_CODE=TEMP_SUBAWARD_AMT_RELEASE.SUBCONTRACT_CODE and aw.sequence_number<=as_seq);
r_amt c_amt%ROWTYPE;

BEGIN

IF c_subaward%ISOPEN THEN
CLOSE c_subaward;
END IF;
OPEN c_subaward;
LOOP
FETCH c_subaward INTO r_subaward;
EXIT WHEN c_subaward%NOTFOUND;
select LTRIM(TO_CHAR(r_subaward.SUBAWARD_CODE, '00000000')) into ls_sub_awd from dual;
--SELECT FN_GET_SEQ(r_subaward.SUBAWARD_CODE,r_subaward.SEQUENCE_NUMBER) INTO li_mit_seq FROM DUAL;
li_mit_seq:=r_subaward.SEQUENCE_NUMBER;


			IF c_amt%ISOPEN THEN
			CLOSE c_amt;
			END IF;
			OPEN c_amt(ls_sub_awd,li_mit_seq);
			LOOP
			FETCH c_amt INTO r_amt;
			EXIT WHEN c_amt%NOTFOUND;
			li_seq:=r_subaward.SEQUENCE_NUMBER;
			--SELECT FN_GET_KUALI_SEQ(r_amt.SUBCONTRACT_CODE,r_amt.SEQUENCE_NUMBER) INTO li_seq FROM DUAL;
			SELECT SUBAWARD_AMT_REL_ID_S.NEXTVAL INTO li_amt_released FROM DUAL;
			BEGIN
			SELECT SUBAWARD_ID INTO li_subaward_id FROM SUBAWARD WHERE SUBAWARD_CODE=r_subaward.SUBAWARD_CODE AND SEQUENCE_NUMBER=r_subaward.SEQUENCE_NUMBER;
			EXCEPTION 
			WHEN OTHERS THEN 
			dbms_output.put_line('MISSING SUBAWARD_ID,SUBAWARD_CODE:'||to_number(r_amt.SUBCONTRACT_CODE) ||'SEQUENCE_NUMBER:'||li_seq||'-'||sqlerrm);
			END;
			SELECT to_number(r_amt.SUBCONTRACT_CODE) INTO ls_subaward_code FROM dual;
			BEGIN
			SELECT PRNCPL_ID INTO ls_create_id  FROM KRIM_PRNCPL_T WHERE PRNCPL_NM=lower(r_amt.CREATED_BY);
			EXCEPTION
			WHEN OTHERS THEN
			ls_create_id:=Null;
			END;
			BEGIN
			SELECT to_number(substr(r_amt.APPROVAL_COMMENTS,1,9)) INTO ls_app_comm  FROM DUAL;
			EXCEPTION
			WHEN OTHERS THEN
			ls_app_comm:=1;
			END;

			BEGIN
			SELECT to_number(r_amt.INVOICE_NUMBER) INTO ls_invoice FROM DUAL;
			EXCEPTION
			WHEN OTHERS THEN
			ls_invoice:=1;
			END;

			BEGIN
			INSERT INTO SUBAWARD_AMT_RELEASED(SUBAWARD_AMT_RELEASED_ID,SUBAWARD_ID,AMOUNT_RELEASED,EFFECTIVE_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,INVOICE_NUMBER,START_DATE,END_DATE,STATUS_CODE,APPROVAL_COMMENTS,APPROVED_BY_USER,APPROVAL_DATE,DOCUMENT,FILE_NAME,CREATED_BY,CREATED_DATE,MIME_TYPE,VER_NBR,OBJ_ID,SEQUENCE_NUMBER,SUBAWARD_CODE,DOCUMENT_NUMBER,INVOICE_STATUS)
			VALUES(li_amt_released,li_subaward_id,r_amt.AMOUNT_RELEASED,r_amt.EFFECTIVE_DATE,r_amt.COMMENTS,r_amt.UPDATE_TIMESTAMP,r_amt.UPDATE_USER,ls_invoice,r_amt.START_DATE,r_amt.END_DATE,r_amt.STATUS_CODE,ls_app_comm,r_amt.APPROVED_BY_USER,r_amt.APPROVAL_DATE,r_amt.DOCUMENT,r_amt.FILE_NAME,ls_create_id,r_amt.CREATED_DATE,null,li_ver_nbr, SYS_GUID(),r_subaward.SEQUENCE_NUMBER,ls_subaward_code,null,null);

			EXCEPTION
			WHEN OTHERS THEN
			ls_app_id:=null;
			dbms_output.put_line('ERROR IN SUBAWARD_AMT_RELEASED,SUBAWARD_CODE:'||r_amt.SUBCONTRACT_CODE||'SEQUENCE_NUMBER:'||r_amt.SEQUENCE_NUMBER);
			END;

			END LOOP;
			CLOSE c_amt;
			
END LOOP;
CLOSE c_subaward;
			
END;
/