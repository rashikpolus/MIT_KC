create or replace
function fn_spool_awd_budget_batch (ai_sap_budget_feed_batch_id in number, as_path in varchar2) return number is
lrec_batch_list 						sap_budget_feed_batch_list%ROWTYPE;
ls_filename 							SAP_FEED_BATCH_LIST.BATCH_FILE_NAME%TYPE;
ls_controlfilename 						SAP_FEED_BATCH_LIST.BATCH_FILE_NAME%TYPE;
batch_file 								UTL_fILE.FILE_TYPE;
control_file							UTL_fILE.FILE_TYPE;
ls_output_line 							varchar2(665);
ls_control_line							varchar2(112);

cursor cur_feeds  is
		SELECT  SAP_BUDGET_FEED_ID,
				SAP_BUDGET_FEED_DETAILS_ID,
				BATCH_ID,
				FISCAL_YEAR,
				ACCOUNT_NUMBER,
				COST_ELEMENT,
				AMOUNT
		FROM SAP_BUDGET_FEED
		WHERE SAP_BUDGET_FEED.SAP_BUDGET_FEED_BATCH_ID = ai_sap_budget_feed_batch_id
		ORDER BY SAP_BUDGET_FEED.SAP_BUDGET_FEED_DETAILS_ID ASC ;
rec_feed cur_feeds%rowtype;

begin

	begin
		SELECT *
		INTO lrec_batch_list
		FROM sap_budget_feed_batch_list
		WHERE sap_budget_feed_batch_list.SAP_BUDGET_FEED_BATCH_ID = ai_sap_budget_feed_batch_id ;
		
	exception   
    when others then		
     return (-1);
    end;
	--open the batch file.

	ls_filename := lrec_batch_list.batch_file_name;

	batch_file := UTL_fILE.fopen(as_path, ls_filename, 'w');


	OPEN cur_feeds;
	LOOP
		FETCH cur_feeds INTO  rec_feed;
		EXIT WHEN cur_feeds%NOTFOUND;	
		ls_output_line := NULL;
	   
		--dbms_output.put_line(ls_MITAwardNumber);
		--if any of the columns in the feed_record is null, it should be initialized with a single space.
		--This is don't to avoid an error while concatenating a null value
		--Create output record.
			ls_output_line := 	' ' || 
								RPAD(rec_feed.FISCAL_YEAR,4,' ') || 
								' ' ||
								'00' ||
								' ' ||
								RPAD(NVL(rec_feed.ACCOUNT_NUMBER,' '),12,' ') ||
								' ' ||
								RPAD(rec_feed.COST_ELEMENT,10,' ') ||
								' ' ||
								RPAD(rec_feed.AMOUNT,15,' ');

		--Replace all hard returns in the data with spaces
			ls_output_line := REPLACE(REPLACE(ls_output_line, CHR(13), ' '), CHR(10), ' ');

		--dbms_output.put_line(substr(ls_output_line, 1, 100));
			UTL_fILE.PUT_LINE(batch_file, ls_output_line);

	END LOOP;
	CLOSE cur_feeds;

	UTL_fILE.fclose(batch_file);

	--Not that the data file is created, create the control file associated with the batch.
	--replace first character in data file name with 'c' to get control file name

	ls_controlfilename := CONCAT('c', SUBSTR(ls_filename, 2, 26));
	control_file := UTL_fILE.fopen(as_path, ls_controlfilename, 'w');

	--calculate the number of bytes in datafile
	--No of records * size of record
	--size of record = 654 + 1. last char is end of line
	--ls_control_line := LTRIM(TO_CHAR(lrec_batch_list.no_of_records * 655, '0000000000000000'));
	
	ls_control_line := LTRIM(TO_CHAR(lrec_batch_list.no_of_records * 665, '0000000000000000'));
	ls_control_line := CONCAT(ls_control_line, LTRIM(TO_CHAR(lrec_batch_list.no_of_records, '0000000000000000')));

	UTL_fILE.PUT_LINE(control_file, ls_control_line);
	UTL_fILE.FCLOSE(control_file);

return 0;

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
		raise_application_error(-20103, 'Invalid operation' || SQLERRM);
		return (-1);

end fn_spool_awd_budget_batch;
/
