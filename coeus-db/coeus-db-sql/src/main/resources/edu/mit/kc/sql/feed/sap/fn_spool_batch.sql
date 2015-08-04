create or replace function fn_spool_batch (ai_sap_feed_batch_id number, ai_batch_id in number, as_path in varchar2) return number is
lrec_batch_list 						SAP_FEED_BATCH_LIST%ROWTYPE;
lrec_feed       						SAP_FEED%ROWTYPE;
ls_AwardNumber                       	sap_feed_details.AWARD_NUMBER%type;

ls_filename 							SAP_FEED_BATCH_LIST.BATCH_FILE_NAME%TYPE;
ls_ControlFileName 						SAP_FEED_BATCH_LIST.BATCH_FILE_NAME%TYPE;
batch_file 								UTL_fILE.FILE_TYPE;
control_file							UTL_fILE.FILE_TYPE;
ls_output_line 							varchar2(665);
ls_control_line							varchar2(112);


	cursor cur_feeds  is
         	SELECT *
    					 FROM SAP_FEED
  						 WHERE SAP_FEED.SAP_FEED_BATCH_ID = ai_sap_feed_batch_id
						 ORDER BY SAP_FEED.SORT_ID ASC ;

begin

--get the record from osp$sap_feed_batch_list

  SELECT *
	INTO lrec_batch_list
    FROM SAP_FEED_BATCH_LIST
	WHERE SAP_FEED_BATCH_LIST.SAP_FEED_BATCH_ID = ai_sap_feed_batch_id  ;

--open the batch file.

ls_filename := lrec_batch_list.batch_file_name;
--batch_file := UTL_fILE.fopen('/usr/local/OSP-PROD/R3-FEEDS', ls_filename, 'w');

dbms_output.put_line('before open');
--batch_file := UTL_fILE.fopen('/usr/local/OSP-Prod/R3-Feeds', ls_filename, 'w');
batch_file := UTL_fILE.fopen(as_path, ls_filename, 'w');

dbms_output.put_line('after_open');

open cur_feeds;

loop
	FETCH cur_feeds INTO  lrec_feed;
	EXIT WHEN cur_feeds%NOTFOUND;
	dbms_output.put_line(lrec_feed.mit_sap_account);

	ls_output_line := NULL;
    begin
    --Get MIT Award Number for the feed record
        select award_number
        into ls_AwardNumber
        from sap_feed_details
        where feed_id =lrec_feed.feed_id;

        exception
          when others then
            ls_AwardNumber := null;
    end;

    --dbms_output.put_line(ls_MITAwardNumber);
--if any of the columns in the feed_record is null, it should be initialized with a singel space.
--This is dont to avoid an error while concatinating a null value

IF ls_AwardNumber IS NULL THEN
	ls_AwardNumber := ' ';
	
END IF;

   ls_AwardNumber := replace(ls_AwardNumber,'-00','-');	
	
IF lrec_feed.SAP_TRANSACTION IS NULL THEN
	lrec_feed.SAP_TRANSACTION := ' ';
END IF;

/*****************************************
IF lrec_feed.PROJECT_TYPE  IS NULL THEN
	lrec_feed.PROJECT_TYPE := ' ';
END IF;
*****************************************/

IF lrec_feed.WBS_TYPE  IS NULL THEN
	lrec_feed.WBS_TYPE := ' ';
END IF;

IF lrec_feed.ACCOUNT_LEVEL  IS NULL THEN
	lrec_feed.ACCOUNT_LEVEL := ' ';
END IF;
IF lrec_feed.MIT_SAP_ACCOUNT   IS NULL THEN
	lrec_feed.MIT_SAP_ACCOUNT := ' ';
END IF;
IF lrec_feed.DEPTNO  IS NULL THEN
	lrec_feed.DEPTNO := ' ';
END IF;
IF lrec_feed.BILLING_ELEMENT  IS NULL THEN
	lrec_feed.BILLING_ELEMENT := ' ';
END IF;
IF lrec_feed.BILLING_TYPE  IS NULL THEN
	lrec_feed.BILLING_TYPE := ' ';
END IF;
IF lrec_feed.BILLING_FORM  IS NULL THEN
	lrec_feed.BILLING_FORM := ' ';
END IF;
IF lrec_feed.SPON_CODE  IS NULL THEN
	lrec_feed.SPON_CODE := ' ';
END IF;
IF lrec_feed.PRIMARY_SPONSOR   IS NULL THEN
	lrec_feed.PRIMARY_SPONSOR := ' ';
END IF;
IF lrec_feed.CONTRACT  IS NULL THEN
	lrec_feed.CONTRACT := ' ';
END IF;
IF lrec_feed.CUSTOMER  IS NULL THEN
	lrec_feed.CUSTOMER := ' ';
END IF;
IF lrec_feed.TERM_CODE IS NULL THEN
	lrec_feed.TERM_CODE := ' ';
END IF;
IF lrec_feed.PARENT_ACCOUNT  IS NULL THEN
	lrec_feed.PARENT_ACCOUNT := ' ';
END IF;
IF lrec_feed.ACCTNAME IS NULL THEN
	lrec_feed.ACCTNAME := ' ';
END IF;
IF lrec_feed.EFFECT_DATE  IS NULL THEN
	lrec_feed.EFFECT_DATE := ' ';
END IF;
IF lrec_feed.EXPIRATION   IS NULL THEN
	lrec_feed.EXPIRATION := ' ';
END IF;
IF lrec_feed.SUB_PLAN   IS NULL THEN
	lrec_feed.SUB_PLAN := ' ';
END IF;
IF lrec_feed.MAIL_CODE  IS NULL THEN
	lrec_feed.MAIL_CODE := ' ';
END IF;
IF lrec_feed.SUPERVISOR   IS NULL THEN
	lrec_feed.SUPERVISOR := ' ';
END IF;
IF lrec_feed.SUPER_ROOM  IS NULL THEN
	lrec_feed.SUPER_ROOM := ' ';
END IF;
IF lrec_feed.ADDRESSEE  IS NULL THEN
	lrec_feed.ADDRESSEE := ' ';
END IF;
IF lrec_feed.ADDR_ROOM   IS NULL THEN
	lrec_feed.ADDR_ROOM := ' ';
END IF;
IF lrec_feed.AGREE_TYPE  IS NULL THEN
	lrec_feed.AGREE_TYPE := ' ';
END IF;
IF lrec_feed.AUTH_TOTAL  IS NULL THEN
	lrec_feed.AUTH_TOTAL := ' ';
END IF;
IF lrec_feed.COST_SHARE IS NULL THEN
	lrec_feed.COST_SHARE := ' ';
END IF;
IF lrec_feed.FUND_CLASS IS NULL THEN
	lrec_feed.FUND_CLASS := ' ';
END IF;
IF lrec_feed.POOL_CODE  IS NULL THEN
	lrec_feed.POOL_CODE := ' ';
END IF;
IF lrec_feed.PENDING_CODE  IS NULL THEN
	lrec_feed.PENDING_CODE := ' ';
END IF;
IF lrec_feed.FS_CODE  IS NULL THEN
	lrec_feed.FS_CODE := ' ';
END IF;
IF lrec_feed.DFAFS   IS NULL THEN
	lrec_feed.DFAFS := ' ';
END IF;
IF lrec_feed.CALC_CODE   IS NULL THEN
	lrec_feed.CALC_CODE := ' ';
END IF;
IF lrec_feed.CFDANO   IS NULL THEN
	lrec_feed.CFDANO := ' ';
END IF;
IF lrec_feed.COSTING_SHEET_KEY   IS NULL THEN
	lrec_feed.COSTING_SHEET_KEY := ' ';
END IF;
IF lrec_feed.LAB_ALLOCATION_KEY  IS NULL THEN
	lrec_feed.LAB_ALLOCATION_KEY := ' ';
END IF;
IF lrec_feed.OH_ADJUSTMENT_KEY  IS NULL THEN
	lrec_feed.OH_ADJUSTMENT_KEY := ' ';
END IF;
IF lrec_feed.EB_ADJUSTMENT_KEY  IS NULL THEN
	lrec_feed.EB_ADJUSTMENT_KEY := ' ';
END IF;
IF lrec_feed.COMMENT1   IS NULL THEN
	lrec_feed.COMMENT1 := ' ';
END IF;
IF lrec_feed.COMMENT2   IS NULL THEN
	lrec_feed.COMMENT2 := ' ';
END IF;

IF lrec_feed.COMMENT3   IS NULL THEN
	lrec_feed.COMMENT3 := ' ';
END IF;

IF lrec_feed.TITLE   IS NULL THEN
	lrec_feed.TITLE := ' ';
END IF;

--Create output record.

ls_output_line := RPAD(ls_AwardNumber, 10, ' ') ||
         RPAD(lrec_feed.SAP_TRANSACTION, 4, ' ') ||
         RPAD(lrec_feed.WBS_TYPE, 1, ' ') ||
         RPAD(lrec_feed.ACCOUNT_LEVEL, 1, ' ') ||
         RPAD(lrec_feed.MIT_SAP_ACCOUNT, 12, ' ') ||
         RPAD(lrec_feed.DEPTNO, 7, ' ') ||
         RPAD(lrec_feed.BILLING_ELEMENT, 1, ' ') ||
         RPAD(lrec_feed.BILLING_TYPE, 2, ' ') ||
         RPAD(lrec_feed.BILLING_FORM, 2, ' ') ||
         RPAD(lrec_feed.SPON_CODE, 6, ' ') ||
         RPAD(lrec_feed.PRIMARY_SPONSOR, 6, ' ') ||
         RPAD(lrec_feed.CONTRACT, 70, ' ') ||
         RPAD(lrec_feed.CUSTOMER, 10, ' ') ||
         RPAD(lrec_feed.TERM_CODE, 1, ' ') ||
         RPAD(lrec_feed.PARENT_ACCOUNT, 12, ' ') ||
         RPAD(lrec_feed.ACCTNAME, 60, ' ') ||
         RPAD(lrec_feed.EFFECT_DATE, 8, ' ') ||
         RPAD(lrec_feed.EXPIRATION, 8, ' ') ||
         RPAD(lrec_feed.SUB_PLAN, 1, ' ') ||
         RPAD(lrec_feed.MAIL_CODE, 1, ' ') ||
         RPAD(lrec_feed.SUPERVISOR, 9, ' ') ||
         RPAD(lrec_feed.SUPER_ROOM, 10, ' ') ||
         RPAD(lrec_feed.ADDRESSEE, 9, ' ') ||
         RPAD(lrec_feed.ADDR_ROOM, 10, ' ') ||
         RPAD(lrec_feed.AGREE_TYPE, 2, ' ') ||
         RPAD(lrec_feed.AUTH_TOTAL, 12, ' ') ||
         RPAD(lrec_feed.COST_SHARE, 1, ' ') ||
         RPAD(lrec_feed.FUND_CLASS, 3, ' ') ||
         RPAD(lrec_feed.POOL_CODE, 1, ' ') ||
         RPAD(lrec_feed.PENDING_CODE, 1, ' ') ||
         RPAD(lrec_feed.FS_CODE, 1, ' ') ||
         RPAD(lrec_feed.DFAFS, 20, ' ') ||
         RPAD(lrec_feed.CALC_CODE, 1, ' ') ||
         RPAD(lrec_feed.CFDANO, 7, ' ') ||
         RPAD(lrec_feed.COSTING_SHEET_KEY, 6, ' ') ||
         RPAD(lrec_feed.LAB_ALLOCATION_KEY, 6, ' ') ||
         RPAD(lrec_feed.EB_ADJUSTMENT_KEY, 6, ' ') ||
         RPAD(lrec_feed.OH_ADJUSTMENT_KEY, 6, ' ') ||
			RPAD(lrec_feed.COMMENT1, 60, ' ') ||
			RPAD(lrec_feed.COMMENT2, 60, ' ') ||
         RPAD(lrec_feed.COMMENT3, 60, ' ') ||
         RPAD(lrec_feed.TITLE, 150, ' ') ;

--Replace all hard returns in the data with spaces
ls_output_line := REPLACE(REPLACE(ls_output_line, CHR(13), ' '), CHR(10), ' ');

--dbms_output.put_line(substr(ls_output_line, 1, 100));

UTL_fILE.Put_Line(batch_file, ls_output_line);

end loop;

CLOSE cur_feeds;

UTL_fILE.fclose(batch_file);

--Not that the data file is created, create the control file associated with the batch.
--replace first caracter in data file name with 'c' to get control file name

ls_ControlFileName := CONCAT('c', SUBSTR(ls_FileName, 2, 26));

control_file := UTL_fILE.fopen(as_path, ls_ControlFileName, 'w');


--calculate the number of bytes in datafile
--No of records * size of record
--size of record = 654 + 1. last char is end of line

--ls_control_line := LTRIM(TO_CHAR(lrec_batch_list.no_of_records * 655, '0000000000000000'));
ls_control_line := LTRIM(TO_CHAR(lrec_batch_list.no_of_records * 665, '0000000000000000'));
ls_control_line := CONCAT(ls_control_line, LTRIM(TO_CHAR(lrec_batch_list.no_of_records, '0000000000000000')));

UTL_fILE.Put_Line(control_file, ls_control_line);

UTL_fILE.fclose(control_file);

return (0);

EXCEPTION
	when utl_file.invalid_path then
		raise_application_error(-20100, 'Invalid path');
		return (-1);

	when utl_file.invalid_mode then
		raise_application_error(-20101, 'Invalid mode');
		return (-1);

	when utl_file.invalid_operation then
		raise_application_error(-20102, 'Invalid operation');
		return (-1);

    when others then
		raise_application_error(-20102, 'Invalid operation' || SQLERRM);
		return (-1);

end fn_spool_batch;
/