-- deprecated
-- Need to set the  utl_file_dir in oracle prameter
-- Alter system set UTL_FILE_DIR='/u01/app/oracle' scope=SPFILE;
-- SELECT * FROM V$PARAMETER where name ='utl_file_dir'
--user directory 
--create or replace directory DIR_KC_SAP_FEED as '/u01/app/oracle/oradata'
--grant read, write on directory DIR_KC_SAP_FEED to km60010215

set serveroutput on;

DECLARE
li_ret number;
BEGIN

li_ret:=fn_generate_master_sap_feed('TEST','admin');
dbms_output.put_line(li_ret);
end;
/

DECLARE
li_ret number;
li_batch_id 				SAP_FEED_BATCH_LIST.BATCH_ID%TYPE;
ld_now						DATE;
ret_sap						number;
ret_sap_bud					number;
ret 						varchar2(30);
BEGIN
	SELECT seq_sap_batch_id.NEXTVAL, sysdate
	INTO li_batch_id, ld_now
	FROM DUAL;

  li_ret:=fn_generate_sap_feed('TEST','admin',li_batch_id,ld_now);
  dbms_output.put_line(li_ret);
end;
/

DECLARE
li_ret number;
BEGIN

li_ret:=fn_generate_rolodex_feed('TEST1','admin');
dbms_output.put_line(li_ret);
end;
/
DECLARE
li_ret number;
BEGIN

li_ret:=fn_generate_sponsor_feed('TEST','admin');
dbms_output.put_line(li_ret);
end;
/

declare
batch_file UTL_fILE.FILE_TYPE;
begin
batch_file := utl_file.fopen('TEST','testKCSAP1.txt','W');
end;

--SELECT * FROM all_directories

select * from dba_directories where directory_name = 'PROD'

grant read, write on directory TEST to PUBLIC;
