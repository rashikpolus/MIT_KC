create or replace function fn_generate_rolodex_feed (as_path in varchar2,as_user in VARCHAR2) return number is

TYPE t_rolodex_feed IS RECORD (
		LAST_NAME 				VARCHAR2(20),
		FIRST_NAME 			VARCHAR2(20),
        SUFFIX 					VARCHAR2(10),
        PREFIX 					VARCHAR2(10),
        TITLE 					VARCHAR2(35),
        ORGANIZATION 			VARCHAR2(200),
        ADDRESS_LINE_1 		VARCHAR2(80),
        ADDRESS_LINE_2 		VARCHAR2(80),
        ADDRESS_LINE_3 		VARCHAR2(80),
  		FAX_NUMBER 			VARCHAR2(20),
        EMAIL_ADDRESS 		VARCHAR2(60),
        CITY 					VARCHAR2(30),
        STATE 					VARCHAR2(30),
        POSTAL_CODE 			VARCHAR2(15),
        PHONE_NUMBER 			VARCHAR2(20),
        COUNTRY_CODE 			CHAR(3),
		SPONSOR_CODE			CHAR(6),
		DUMMY					CHAR(2),
		ROLODEX_ID			   number(6) ,
	    DUN_AND_BRADSTREET_NUMBER  VARCHAR2(20));


lrec_feed       						t_rolodex_Feed;

ls_filename 							VARCHAR2(120);
ls_ControlFileName					VARCHAR2(120);
batch_file 								UTL_fILE.FILE_TYPE;
control_file							UTL_fILE.FILE_TYPE;

ls_output_line 						varchar2(1000);
ls_control_line						varchar2(112);
li_batch_id								number(3);
ld_now									DATE;
li_RecordCount							number(6);

ls_PostalCode                       ROLODEX.POSTAL_CODE%type;
ls_PostalCodeOrig                   ROLODEX.POSTAL_CODE%type;
ls_CountryCode                      ROLODEX.COUNTRY_CODE%type;

cursor cur_feeds  is
  SELECT RPAD(DECODE(ROLODEX.LAST_NAME , NULL, ' ', regexp_replace(ROLODEX.LAST_NAME,'[^ -~]', ' ')), 20, ' ' ) ,
		RPAD(DECODE(ROLODEX.FIRST_NAME, NULL, ' ', regexp_replace(ROLODEX.FIRST_NAME,'[^ -~]', ' ')),  20, ' ' ) ,
		RPAD(DECODE(ROLODEX.SUFFIX,  NULL, ' ', regexp_replace(ROLODEX.SUFFIX,'[^ -~]', ' ')), 10, ' ') ,
		RPAD(DECODE(ROLODEX.PREFIX, NULL, ' ', regexp_replace(ROLODEX.PREFIX,'[^ -~]', ' ')), 10, ' ') ,
		RPAD(DECODE(ROLODEX.TITLE, NULL, ' ', regexp_replace(ROLODEX.TITLE,'[^ -~]', ' ') ), 35, ' ') ,
		RPAD(DECODE(ROLODEX.ORGANIZATION, NULL, ' ', regexp_replace(ROLODEX.ORGANIZATION,'[^ -~]', ' ') ), 80, ' ') ,
		RPAD(DECODE(ROLODEX.ADDRESS_LINE_1, NULL, ' ', regexp_replace(ROLODEX.ADDRESS_LINE_1,'[^ -~]', ' ') ), 80, ' ') ,
		RPAD(DECODE(ROLODEX.ADDRESS_LINE_2, NULL, ' ', regexp_replace(ROLODEX.ADDRESS_LINE_2,'[^ -~]', ' ')), 80, ' ') ,
		RPAD(DECODE(ROLODEX.ADDRESS_LINE_3, NULL, ' ', regexp_replace(ROLODEX.ADDRESS_LINE_3,'[^ -~]', ' ')), 80, ' ') ,
		RPAD(DECODE(ROLODEX.FAX_NUMBER,  NULL, ' ', ROLODEX.FAX_NUMBER), 20, ' ') ,
		RPAD(DECODE(ROLODEX.EMAIL_ADDRESS, NULL, ' ', ROLODEX.EMAIL_ADDRESS), 60, ' ') ,
		RPAD(DECODE(ROLODEX.CITY, NULL, ' ', regexp_replace(ROLODEX.CITY,'[^ -~]', ' ')), 30, ' ') ,
		RPAD(DECODE(ROLODEX.STATE, NULL, ' ', ROLODEX.STATE), 30, ' ') ,
		RPAD(DECODE(ROLODEX.POSTAL_CODE,  NULL, ' ', ROLODEX.POSTAL_CODE), 15, ' ') ,		
		RPAD(DECODE(ROLODEX.PHONE_NUMBER, NULL, ' ', ROLODEX.PHONE_NUMBER), 20, ' ') ,
		RPAD(DECODE(ROLODEX.COUNTRY_CODE, NULL, ' ', ROLODEX.COUNTRY_CODE), 3, ' ') ,
		RPAD(DECODE(ROLODEX.SPONSOR_CODE, NULL, ' ', ROLODEX.SPONSOR_CODE), 6, ' ') ,
		'86' ,TO_CHAR(ROLODEX.ROLODEX_ID),
		RPAD(DECODE(SPONSOR.DUN_AND_BRADSTREET_NUMBER, NULL, ' ', SPONSOR.DUN_AND_BRADSTREET_NUMBER), 20, ' ')
	FROM ROLODEX, SPONSOR
	WHERE ROLODEX.ROLODEX_ID >= 0
  AND	ROLODEX.SPONSOR_CODE = SPONSOR.SPONSOR_CODE (+)
  and	ROLODEX.ROLODEX_ID in		(select rolodex_id from AWARD_SPONSOR_CONTACTS	where CONTACT_ROLE_CODE = 3) ; 
begin

SELECT seq_rolo_feed_id.NEXTVAL, sysdate
	INTO li_batch_id, ld_now
	FROM DUAL;

ls_filename := concat(concat(concat('dospfrlx.', ltrim(to_char(li_batch_id, '000'))), '.'),
															to_char(ld_now, 'YYYYMMDDHH24MISS'));

--open the batch file.

batch_file := UTL_fILE.fopen(as_path, ls_filename, 'w');

open cur_feeds;

loop
	FETCH cur_feeds INTO lrec_feed;
	EXIT WHEN cur_feeds%NOTFOUND;

	ls_output_line := NULL;

--Create output record.
	-- Added for MITKC-1442
		--Coeus-935 Begin
			ls_PostalCodeOrig := lrec_feed.postal_code;
			ls_PostalCode := trim(lrec_feed.postal_code);
			ls_CountryCode := trim(lrec_feed.country_code);
			
			if upper(ls_CountryCode) = 'USA' then
				if length (ls_PostalCode) = 9 then
				
					--Check if last 4 digits are 00000
					if substr(ls_PostalCode, 6, 4) = '0000' then
						ls_PostalCode := substr(ls_PostalCode, 1, 5);
					else
						ls_PostalCode := substr(ls_PostalCode, 1, 5) || '-' || substr(ls_PostalCode, 6, 4);
					end if;
				else
					ls_PostalCode := ls_PostalCodeOrig;
					
				end if;
			else
				ls_PostalCode := ls_PostalCodeOrig;
			end if;
		  
		--Coeus-935 End
	

ls_output_line := lrec_feed.last_name   ||
            		lrec_feed.first_name  ||
            		lrec_feed.suffix     ||
						lrec_feed.prefix  ||
						lrec_feed.title ||
						lrec_feed.organization  ||
						lrec_feed.address_line_1 ||
						lrec_feed.address_line_2  ||
						lrec_feed.address_line_3  ||
						lrec_feed.fax_number  ||
						lrec_feed.email_address  ||
						lrec_feed.city ||
						lrec_feed.state ||
						RPAD(ls_PostalCode, 15, ' ') ||
						lrec_feed.phone_number ||
						lrec_feed.country_code  ||
						lrec_feed.sponsor_code  ||
						'86' ||
						 lpad(lrec_feed.rolodex_id ,8 ,'0') ||
						lrec_feed.dun_and_bradstreet_number;

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


UPDATE krcr_parm_t SET VAL = as_user WHERE  parm_nm = 'SAP_FEED_ROLODEX_FEED_USER';
UPDATE krcr_parm_t SET VAL = to_char(sysdate,'Mon-DD-yyyy hh:mi:ss am') WHERE  parm_nm = 'SAP_FEED_ROLODEX_FEED_DATE';

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

end fn_generate_rolodex_feed;
/