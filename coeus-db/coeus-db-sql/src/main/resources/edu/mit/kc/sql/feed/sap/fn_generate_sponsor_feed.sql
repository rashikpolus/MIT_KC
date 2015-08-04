create or replace
function fn_generate_sponsor_feed (as_path in varchar2, as_user in VARCHAR2) return number is

lrec_feed       						TEMP_SAP_SPON_CD%ROWTYPE;
ls_filename 							VARCHAR2(120);
ls_ControlFileName						VARCHAR2(120);
batch_file 								UTL_fILE.FILE_TYPE;
control_file							UTL_fILE.FILE_TYPE;
ls_output_line 						varchar2(70);
ls_control_line						varchar2(112);
li_batch_id								number(3);
ld_now									DATE;
li_RecordCount							number(6);

cursor cur_feeds  is
     	SELECT *
   	FROM TEMP_SAP_SPON_CD
  	   ORDER BY sponsor_code  ;

begin

SELECT seq_spon_batch_id.NEXTVAL, sysdate
	INTO li_batch_id, ld_now
	FROM DUAL;

ls_filename := concat(concat(concat('dospfspc.', ltrim(to_char(li_batch_id, '000'))), '.'),
															to_char(ld_now, 'YYYYMMDDHH24MISS'));

--open the batch file.

batch_file := UTL_fILE.fopen(as_path, ls_filename, 'w');

dbms_output.put_line('after_open');

--delete all rows from zsponcd

DELETE FROM TEMP_SAP_SPON_CD;

--Populate zsponcd with rows from osp$sponsor tables

INSERT INTO TEMP_SAP_SPON_CD
     (sponsor_code, sponsor_name,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
      SELECT sponsor_code,
             substr(sponsor_name, 1, 60),SYSDATE,USER,1,SYS_GUID()
      FROM   sponsor
		WHERE sponsor_code <> '999999';   --Where condition added for Fix230 on 3/15/02

--Update admin_activity_code

update TEMP_SAP_SPON_CD
   set    admin_activity_code = '01'
   where  to_number(sponsor_code) between 120 and 139;


update TEMP_SAP_SPON_CD
   set    admin_activity_code = '02'
   where  to_number(sponsor_code) between 140 and 159;

update TEMP_SAP_SPON_CD
   set    admin_activity_code = '03'
   where  to_number(sponsor_code) between 100 and 119;


update TEMP_SAP_SPON_CD
   set    admin_activity_code = '04'
   where  to_number(sponsor_code) = 638;


update TEMP_SAP_SPON_CD
   set    admin_activity_code = '05'
   where  to_number(sponsor_code) between 200 and 299;


update TEMP_SAP_SPON_CD
   set    admin_activity_code = '07'
   where  to_number(sponsor_code) between 400 and 499;

update TEMP_SAP_SPON_CD
   set    admin_activity_code = '08'
   where  to_number(sponsor_code) between 500 and 599;

update TEMP_SAP_SPON_CD
   set    admin_activity_code = '09'
   where  to_number(sponsor_code) between 300 and 399;

update TEMP_SAP_SPON_CD
   set    admin_activity_code = '10'
   where  to_number(sponsor_code) between 160 and 199;

update TEMP_SAP_SPON_CD
   set    admin_activity_code = '11'
   where  to_number(sponsor_code) = 634;

update TEMP_SAP_SPON_CD
   set    admin_activity_code = '12'
   where  to_number(sponsor_code) = 5410;

open cur_feeds;

loop
	FETCH cur_feeds INTO lrec_feed;
	EXIT WHEN cur_feeds%NOTFOUND;

	ls_output_line := NULL;

IF lrec_feed.admin_activity_code IS NULL THEN
	lrec_feed.admin_activity_code := '  ';
END IF;

--Create output record.

ls_output_line := LPAD(lrec_feed.sponsor_code, 6, '0')   || ' ' ||
            		RPAD(lrec_feed.sponsor_name, 60, ' ')  || ' ' ||
            		LPAD(lrec_feed.admin_activity_code, 2, ' ');

--Replace all hard returns in the data with spaces
ls_output_line := REPLACE(REPLACE(ls_output_line, CHR(13), ' '), CHR(10), ' ');

--Replace all Double quotes with spaces
ls_output_line := REPLACE(ls_output_line, '"', ' ');


UTL_fILE.Put_Line(batch_file, ls_output_line);

end loop;

li_RecordCount := cur_feeds%ROWCOUNT;

CLOSE cur_feeds;

UTL_fILE.fclose(batch_file);

ls_ControlFileName := CONCAT('c', SUBSTR(ls_FileName, 2, 26));

control_file := UTL_fILE.fopen(as_path, ls_ControlFileName, 'w');


--calculate the number of bytes in datafile
--No of records * size of record
--size of record = 68 + 1. last char is end of line

ls_control_line := LTRIM(TO_CHAR(li_RecordCount * 69, '0000000000000000'));
ls_control_line := CONCAT(ls_control_line, LTRIM(TO_CHAR(li_RecordCount, '0000000000000000')));

UTL_fILE.Put_Line(control_file, ls_control_line);

UTL_fILE.fclose(control_file);

UPDATE krcr_parm_t SET VAL = as_user WHERE  parm_nm = 'SAP_FEED_SPONSOR_FEED_USER';
UPDATE krcr_parm_t SET VAL = to_char(sysdate,'Mon-DD-yyyy hh:mi:ss am') WHERE  parm_nm = 'SAP_FEED_SPONSOR_FEED_DATE';

COMMIT;

return (0);

EXCEPTION
	when utl_file.invalid_path then
		raise_application_error(-20100, 'Invalid path');
		ROLLBACK;
		return (-1);

	when utl_file.invalid_mode then
		raise_application_error(-20101, 'Invalid mode');
		ROLLBACK;
		return (-1);

	when utl_file.invalid_operation then
		raise_application_error(-20102, 'Invalid operation');
		ROLLBACK;
		return (-1);

	when others then
		ROLLBACK;
		return (-1);

end fn_generate_sponsor_feed;
/