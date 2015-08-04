create or replace package kc_sap_feed_pkg as
  function  generate_feed  (ai_sap_feed_batch_id number, ai_batch_id in number, ai_feed_id in number,
										  as_award_number in AWARD.AWARD_NUMBER%TYPE,
                                ai_sequence_number in AWARD.SEQUENCE_NUMBER%TYPE,
                                as_feed_type in SAP_FEED_DETAILS.FEED_TYPE%TYPE,
										  as_transaction_id in SAP_FEED_DETAILS.TRANSACTION_ID%TYPE,
										  ai_sort_id   in SAP_FEED.SORT_ID%TYPE) return number;

end;
/
create or replace package body kc_sap_feed_pkg as

gs_unit_number    						varchar2(8);
gs_fiscal_year    						char(4);
gs_PI_id      							KRIM_PRNCPL_T.PRNCPL_ID%TYPE;
gs_pi_name 								AWARD_PERSONS.FULL_NAME%TYPE;
gs_pi_room    							VARCHAR2(30);
gc_eb_on     							number(5,2);
gc_eb_off    							number(5,2);
gc_oh_on     							number(5,2);
gc_oh_off    							number(5,2);
gs_oh_adjustment_key					char(6);
gs_eb_adjustment_key					char(6);
gs_costing_sheet						char(6);  --08/10/00
gs_addresse_id 							KRIM_PRNCPL_T.PRNCPL_ID%TYPE;
gs_addresse_room    					VARCHAR2(30);
gs_sponsor_name							SPONSOR.SPONSOR_NAME%TYPE;

gs_account_number 					AWARD.ACCOUNT_NUMBER%TYPE;
gs_parent_award_number        	    AWARD.AWARD_NUMBER%TYPE;
gs_Parent_account_number     	 	AWARD.ACCOUNT_NUMBER%TYPE;
gs_award_number  					AWARD.AWARD_NUMBER%TYPE;
gi_sequence_number 					AWARD.SEQUENCE_NUMBER%TYPE;
gi_award_id 						AWARD.AWARD_ID%TYPE;
gi_feed_id 							SAP_FEED_DETAILS.FEED_ID%TYPE;
gi_batch_id							SAP_FEED_BATCH_LIST.BATCH_ID%TYPE;
gi_sap_feed_batch_id				SAP_FEED_BATCH_LIST.SAP_FEED_BATCH_ID%TYPE;
gi_sponsor_type 					SPONSOR.SPONSOR_TYPE_CODE%TYPE;
gi_prime_sponsor_type 				SPONSOR.SPONSOR_TYPE_CODE%TYPE;     --Added on 8/27/98
grec_award 							AWARD%ROWTYPE; --one record from AWARD
gd_exp_date 						AWARD_AMOUNT_INFO.OBLIGATION_EXPIRATION_DATE%TYPE;
gn_anticipated_total 				AWARD_AMOUNT_INFO.ANTICIPATED_TOTAL_AMOUNT%TYPE;
gn_obligated_total 					AWARD_AMOUNT_INFO.AMOUNT_OBLIGATED_TO_DATE%TYPE;
gs_transaction_id 					SAP_FEED_DETAILS.TRANSACTION_ID%TYPE;

TYPE FreqTabType IS TABLE OF FREQUENCY.FREQUENCY_CODE%TYPE
INDEX BY BINARY_INTEGER;

function fn_is_valid_award return number;
function fn_get_agree_type return char;
function fn_get_money_and_dates return number;
function fn_get_fiscal_year  return number;
function fn_get_rates  return number;
function fn_get_billing_type  return varchar2;
function fn_get_billing_form return varchar2;
function fn_format_name (as_old_name varchar2)  return varchar2;
function fn_format_room (as_old_room varchar2)  return varchar2;

function fn_init_lead_unit return number;
function fn_get_costing_sheet_key return number;  --This function was returning a char,
																  --now sets a global for costing sheet
function fn_get_lab_allocation return char;
function fn_get_customer return char;
function fn_get_dfafs return char;
function fn_get_auth_total return number;
function fn_is_in(ai_value in number, at_table in FreqTabType) return boolean;
function fn_generate_comment1 return varchar2;
function fn_get_cost_share  return varchar2;
function fn_get_custom_element_value (as_CustomElement in
		 							 CUSTOM_ATTRIBUTE.NAME%TYPE)  return varchar2;
/***************************************************************************************/
function  generate_feed  (ai_sap_feed_batch_id number, ai_batch_id in number, ai_feed_id in number,
										  as_award_number in AWARD.AWARD_NUMBER%TYPE,
                                ai_sequence_number in AWARD.SEQUENCE_NUMBER%TYPE,
                                as_feed_type in SAP_FEED_DETAILS.FEED_TYPE%TYPE,
										  as_transaction_id in SAP_FEED_DETAILS.TRANSACTION_ID%TYPE,
										  ai_sort_id   in SAP_FEED.SORT_ID%TYPE) return number is
/***************************************************************************************/

	li_ret 					number;
	ls_temp 				char(1);
	ls_amount 				varchar2(13);
	lc_auth_total			number(12,2);
	ls_cfda					varchar2(7);
	ls_CustomElementValue   varchar2(2000);
	li_sp_feed_id 			number(12,0);
    feed_record 		SAP_FEED%ROWTYPE;   --this is one record of the sap_feed table

	begin
/******************************************************************************************
	Initialize all the global variables here
	Set all globals to NULL
******************************************************************************************/
	gs_unit_number    					:= NULL;
	gs_fiscal_year    					:= NULL;
	gs_PI_id      						:= NULL;
	gs_pi_name 							:= NULL;
	gs_pi_room    						:= NULL;

	gc_eb_on     							:= NULL;
	gc_eb_off    							:= NULL;
	gc_oh_on     							:= NULL;
	gc_oh_off    							:= NULL;
	gs_oh_adjustment_key					:= NULL;
	gs_eb_adjustment_key					:= NULL;
	gs_costing_sheet						:= NULL;  --Added on 8/10/00

	gs_addresse_id 							:= NULL;
	gs_addresse_room    					:= NULL;

	gs_account_number 					:= NULL;
	gs_parent_award_number        		:= NULL;
	gs_Parent_account_number     	 	:= NULL;
	gs_award_number  					:= NULL;
	gi_award_id                         := NULL; 
	gi_sequence_number 					:= NULL;
	gi_feed_id 							:= NULL;
	gi_batch_id							:= NULL;
	gi_sap_feed_batch_id				:= NULL;
	gi_sponsor_type 					:= NULL;
	grec_award 							:= NULL;
	gd_exp_date 						:= NULL;
	gn_anticipated_total 				:= NULL;
	gn_obligated_total 					:= NULL;
	gs_transaction_id 					:= NULL;
/*****************************************************************************************
	End of Initialization
*****************************************************************************************/


     gi_feed_id := ai_feed_id;
	 gi_batch_id := ai_batch_id;
	 gi_sap_feed_batch_id := ai_sap_feed_batch_id;
	 gs_award_number := as_award_number;
     gi_sequence_number := ai_sequence_number;
	 gs_transaction_id := as_transaction_id;

		 SELECT AWARD_ID
   		 INTO gi_award_id
  		 FROM AWARD
  		 WHERE  AWARD.AWARD_NUMBER = gs_award_number AND
				AWARD.SEQUENCE_NUMBER = gi_sequence_number  AND
				AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED';	 
	 
	 
		SELECT *
   		 INTO grec_award
  		  FROM AWARD
  		 WHERE ( AWARD.AWARD_NUMBER = gs_award_number ) AND
         ( AWARD.SEQUENCE_NUMBER = gi_sequence_number ) AND
		 ( AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED' )		 ;

		li_ret := fn_is_valid_award;
		IF li_ret = -1 THEN
         Return (-1);
		END IF;
----upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 1');
--get current fiscal year from KRCR_PARM_T table.
		li_ret := fn_get_fiscal_year;
		IF li_ret = -1 THEN
         Return (-1);
		END IF;
----upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 2');
--get IDC and OH rates for this fiscal year
		li_ret := fn_get_rates;
		IF li_ret = -1 THEN
         Return (-1);
		END IF;
----upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 3');
--moved following check after the get unit information on 9/22/00
--Following check for costing sheet key was added on 8/10/00
--Get Costing sheet key and validate it.
--		li_ret := fn_get_costing_sheet_key;
--		IF li_ret = -1 THEN
--			Return(-1);
--		END IF;


--get sponsor type

		SELECT SPONSOR.SPONSOR_TYPE_CODE
      INTO gi_sponsor_type
   	 FROM SPONSOR
   	WHERE SPONSOR.SPONSOR_CODE = grec_award.sponsor_code   ;

--get unit information
--dbms_output.put_line('before fn_init_lead_unit');

		li_ret := fn_init_lead_unit;
		IF li_ret = -1 THEN
         Return (-1);
		END IF;
----upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 4');
--Following check for costing sheet key was added on 8/10/00
--Get Costing sheet key and validate it.
		li_ret := fn_get_costing_sheet_key;
		IF li_ret = -1 THEN
			Return(-1);
		END IF;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 4A');

--get money and end dates

		li_Ret := fn_get_money_and_dates;
		IF li_Ret = -1 THEN
			Return(-1);
		END IF;

--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 5');
		feed_record.batch_id := ai_batch_id;
		feed_record.feed_id := gi_feed_id;
		feed_record.sap_feed_batch_id := ai_sap_feed_batch_id;

		IF as_feed_type = 'N' THEN
			feed_record.sap_transaction := 'ZCO1';  --Create new account in SAP
		ELSE
			feed_record.sap_transaction := 'ZCO2';  --modify existing account in SAP
		END IF;

--SET PROJECT TYPE.
/***********************************************************************************
PROJECT_TYPE column is dropped as of 5/6/02
		ls_temp := fn_get_project_type;
		feed_record.project_type := ls_temp;
************************************************************************************/

--SET WBS_TYPE

		IF (SUBSTR(gs_account_number, 1, 1) = '3') THEN
			feed_record.wbs_type := 'O';
		ELSIF grec_award.activity_type_code = 1 THEN
			feed_record.wbs_type := 'R';
		ELSE
			feed_record.wbs_type := 'F';
		END IF;

--SET LEVEL
/***************************************************************************************
	This logic is Ok for the time being since we deal with only two levels of hierarchy.
	Should be modified later to accomodate more levels.
***************************************************************************************/

		IF gs_parent_award_number = '000000-00000' THEN
			feed_record.account_level := '1';
		ELSE
			feed_record.account_level := '2';
		END IF;

--SET MIT_SAP_ACCOUNT

		feed_record.mit_sap_account := gs_account_number;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 6');
--SET DEPTNO.

--No more 99 logic on Unit number 7/21/98
/*
		IF (gs_account_number < '5000000') and
			(gs_unit_number < '320000') and
		   (gc_oh_on = 0) AND (gc_oh_off = 0) THEN
			feed_record.deptno := CONCAT(SUBSTR(gs_unit_number, 1, 4), '99');
		ELSE
			feed_record.deptno := gs_unit_number;
		END IF;
*/

--Should pass a leading 'P' to treat unit_number as profit center
--This is part of feed cange of March 2000

		feed_record.deptno := 'P' || gs_unit_number;

--dbms_output.put_line('after unit assign');

--SET BILLING_ELEMENT

		IF (as_feed_type = 'N' AND feed_record.account_level = '1') OR
			(grec_award.sponsor_code = '009906') THEN          --This OR condition added on 12/4/00 by sabari
			feed_record.billing_element := 'X' ;
		ELSE                                             --Following Else block added on 4/14/05
			ls_CustomElementValue := fn_get_custom_element_value('BILLING_ELEMENT');
			if (upper(ls_CustomElementValue) = 'YES') then
			   feed_record.billing_element := 'X';
			else
				feed_record.billing_element := ' ';
			end if;
		END IF;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 7');
--SET BILLING_TYPE

		feed_record.billing_type := fn_get_billing_type;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 8');
--dbms_output.put_line('done BILLING_TYPE');

--SET BILLING_FORM

--More logic comming from Steve (10-09-97)

		feed_record.billing_form := fn_get_billing_form;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 9');
--dbms_output.put_line('done BILLING_FORM');


--SET SPON_CODE

--Sponsor code is 5 digits in Coeus.
--The feed takes 6 so prefix sponsor code with a '0'

--		feed_record.spon_code := '0' || grec_award.sponsor_code;

--Sponsor code is 6 digit in Coeus 3.0
--Need not have to prefix sponsor code with a '0'

		feed_record.spon_code := grec_award.sponsor_code;

--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 10');
--dbms_output.put_line('done SPON_CODE');

--SET PRIMARY_SPONSOR
--Prime Sponsor code is 5 digits in Coeus.
--The feed takes 6 so prefix prime sponsor code with a '0'

		IF grec_award.prime_sponsor_code IS NULL THEN
			feed_record.primary_sponsor := '      '; --6 space
		ELSE
--			feed_record.primary_sponsor := '0' || grec_award.prime_sponsor_code;

--Prime sponsor code is 6 char in Coeus 3
--no need to prefix with '0'

			feed_record.primary_sponsor := grec_award.prime_sponsor_code;
		END IF;

--dbms_output.put_line('done PRIMARY_SPONSOR');

--SET CONTRACT

--		feed_record.contract := SUBSTR(grec_award.sponsor_award_number, 1, 24);
--  Don't need to SUBSTR any more.  Contract column in sap_feed is made char(70)
 
     --Replace special characters from CONTRACT
     --COEUSDEV-851

     		feed_record.contract := regexp_replace(grec_award.sponsor_award_number, '[^ -~]', ' ') ;
       --upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 11');
--dbms_output.put_line('done CONTRACT');
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 12');
--SET CUSTOMER
		feed_record.customer := fn_get_customer;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 13');
		--get the mapping from steve

--SET TERM_CODE

		IF (grec_award.status_code = 4) THEN
			feed_record.term_code := '1';
		ELSIF (grec_award.status_code = 5) THEN
			feed_record.term_code := '3';
		ELSIF (grec_award.status_code = 7) THEN   --Award status is Restricted  added 11/8/05
			feed_record.term_code := '2';
		ELSE
			feed_record.term_code := ' '; 	--Blank
		END IF;

--SET PARENT_ACCOUNT

--		feed_record.parent_account := SUBSTR(gs_parent_account_number, 1, 5);
--used to feed only first five characters of parent_account
--now on, we will send all 7 characters...change made on 4/16/99

		feed_record.parent_account := gs_parent_account_number;

--dbms_output.put_line('done PARENT_ACCOUNT');

/*
--to_account and from_account is removed from the feed layout
--change requested on 4/15/99

--SET TO_ACCOUNT
--This field is not in use, so send a minus sign in the first character of this field

		feed_record.to_account := '-    '; --5 characters

--SET FROM_ACCOUNT
--This field is not in use, so send a minus sign in the first character of this field

		feed_record.from_account := '-    '; --5 characters
*/

--SET ACCT_NAME

--		Replace all double quotes from the title 05/15/98

		grec_award.title := REPLACE(grec_award.title, '"');
        
--   Replace Special characters from title COEUSDEV-851
        grec_award.title := regexp_replace(grec_award.title, '[^ -~]', ' ');     
        
-- we were taking first 60 characters of title till 4/8/99, changed to 40 on 4/8/99

		feed_record.acctname := SUBSTR(grec_award.title, 1, 40) ;

--dbms_output.put_line('done ACCT_NAME');
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 14');
--SET EFFECT_DATE

		IF grec_award.pre_award_effective_date is not NULL THEN
			feed_record.effect_date := TO_CHAR(grec_award.pre_award_effective_date, 'YYYYMMDD');
		ELSE
			feed_record.effect_date := TO_CHAR(grec_award.award_effective_date, 'YYYYMMDD');
		END IF;

--dbms_output.put_line('done EFFECT_DATE');

--SET EXPIRATION

		feed_record.expiration := TO_CHAR(gd_exp_date, 'YYYYMMDD');
--dbms_output.put_line('done EXPIRATION');

--SET SUB_PLAN

		IF grec_award.sub_plan_flag = 'Y' THEN
			feed_record.sub_plan := 'Y';
		ELSE
			feed_record.sub_plan := 'N';
		END IF;
--dbms_output.put_line('done SUB_PLAN');

--SET MAIL_CODE

		IF (grec_award.status_code = 5) THEN --Closed
			feed_record.mail_code := '5';

		ELSIF as_feed_type <> 'N' THEN        --This condition added on 6/13/02
			feed_record.mail_code := '-';      --Transaction is change and status <> 5

      ELSIF gs_unit_number = '097500' THEN        --This Condition added on 02/21/01
         feed_record.mail_code := '5';

	  ELSIF gs_unit_number = '069400' THEN     -- This condition added on 06/07/04
         feed_record.mail_code := '5';

		ELSIF gs_unit_number = '152000' THEN
			feed_record.mail_code := '4';

		ELSIF gs_unit_number in ('064000', '065000', '066000', '069800',
										'153000', '069850', '062000', '166000', '068400') THEN
			feed_record.mail_code := '1';
            
        ELSIF gs_unit_number = '161000' THEN  --COEUSDEV-596
            feed_record.mail_code := '4'; -- This was 6 -- COEUSDEV-1103
            
        ELSIF gs_unit_number in ('061094', '061095') THEN  --COEUSDEV-669 
            feed_record.mail_code := '3';
            
        ELSIF gs_unit_number in ('061090', '061091', '061092',
                                '061093', '061096', '061097', '061098', '061099') THEN  --COEUSDEV-669 
            feed_record.mail_code := '1'; -- This was 1 -- COEUSDEV-1103
        
        ELSIF  gs_unit_number = '065003' THEN  --COEUSDEV-700  
            feed_record.mail_code := '4';
        
        ELSIF  gs_unit_number = '417000' THEN  --COEUS-320  
            feed_record.mail_code := '4';
            
		ELSE
			feed_record.mail_code := '1'; -- This was 1 -- COEUSDEV-1103
		END IF;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 15');
--dbms_output.put_line('done MAIL_CODE');

--SET SUPERVISOR

--		feed_record.supervisor := fn_format_name(gs_pi_name);
-- Not passing Name anymore. Will pass MITID of the PI

		feed_record.supervisor := gs_pi_id;

--dbms_output.put_line('done SUPERVISOR');

--SET SUPER_ROOM

		feed_record.super_room := fn_format_room(gs_pi_room);
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 16');
--dbms_output.put_line('done SUPER_ROOM');

--SET ADDRESSEE

--		feed_record.addressee := fn_format_name(gs_addresse_name);
-- We are not passing Name anymore. Will pass MITID of the person - March 2000

	IF gs_addresse_id IS NULL THEN
		gs_addresse_id := '         ';
	END IF;

		feed_record.addressee := gs_addresse_id;


--dbms_output.put_line('done ADDRESSEE');

--SET ADDR_ROOM

		feed_record.addr_room := fn_format_room(gs_addresse_room);
--dbms_output.put_line('done ADDR_ROOM');
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 17');
--SET AGREE_TYPE
		--check logic with steve.
--		ls_temp := fn_get_agree_type;
		feed_record.agree_type := fn_get_agree_type;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 18');
--dbms_output.put_line('after agree type');

--SET AUTH_TOTAL


		--verify the format
		--There might be an easy way to get this format right.

			lc_auth_total := fn_get_auth_total;
			ls_amount := LTRIM(TO_CHAR(lc_auth_total, '0000000000D00'));
			feed_record.auth_total := CONCAT(SUBSTR(ls_amount, 1, 10), SUBSTR(ls_amount, 12, 2));


--dbms_output.put_line('after total');
--SET COST_SHARE

		feed_record.cost_share := fn_get_cost_share;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 19');
--dbms_output.put_line('done COST_SHARE');

--SET FUND_CLASS

		IF (gs_account_number >= '5000000') OR (grec_award.activity_type_code = 1) THEN
			feed_record.fund_class := '616';
		ELSIF (grec_award.activity_type_code = 3) AND  (grec_award.award_type_code = 7) THEN
			feed_record.fund_class := '644';
		ELSIF (grec_award.activity_type_code = 7) AND  (grec_award.award_type_code = 7) THEN
			feed_record.fund_class := '648';
		ELSE
			feed_record.fund_class := '610';
		END IF;
--dbms_output.put_line('done FUND_CLASS');

--SET POOL_CODE

/* Old logic Commented out on 08/27/98
		IF (gi_sponsor_type = 0) OR (gi_prime_sponsor_type = 0) THEN         --Fedral
			feed_record.pool_code := 'O';
		ELSE
			feed_record.pool_code := 'D';
		END IF;
*/

--New logic for Pool Code

--Pool code logic changed on 7/12/01
--Acct number range changed for C. changed >= 3669000 and <= 4000000 changed to <= 4999999


		IF (to_number(gs_account_number) >= 3000000) AND (to_number(gs_account_number) <= 3668999) THEN
			feed_record.pool_code := 'A';
		ELSIF (to_number(gs_account_number) >= 3669000) AND (to_number(gs_account_number) <= 4999999) THEN
			feed_record.pool_code := 'C';
		ELSIF (gi_sponsor_type = 0) THEN
			feed_record.pool_code := 'O';
		ELSE
			feed_record.pool_code := 'D';
		END IF;

--dbms_output.put_line('done POOL_CODE');


--SET PENDING_CODE

		IF grec_award.status_code = 3 THEN         --Award status is pending
			feed_record.pending_code := 'P';
		ELSE
			feed_record.pending_code := ' ';
		END IF;
--dbms_output.put_line('done PENDING_CODE');

--SET FS_CODE

		ls_temp := SUBSTR(gs_account_number, 1, 1);

		IF (to_number(gs_account_number) >= 3000000) AND (to_number(gs_account_number) <= 3668999) THEN
			feed_record.fs_code := 'R';
		ELSIF (to_number(gs_account_number) > 3668999) AND (to_number(gs_account_number) <= 4044999) THEN --Changed on 7/16/01
			feed_record.fs_code := 'U';
		ELSIF ls_temp = '2' THEN
			feed_record.fs_code := 'U';
		ELSE
			feed_record.fs_code := ' ';
		END IF;


--dbms_output.put_line('done FS_CODE');

--SET DFAFS

		feed_record.dfafs := fn_get_dfafs;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 20');
--dbms_output.put_line('done DFAFS');


--SET CALC_CODE

		IF grec_award.account_type_code = 2 THEN
			feed_record.calc_code := '2';
		ELSIF grec_award.account_type_code = 3 THEN
			feed_record.calc_code := '7';
		ELSIF grec_award.account_type_code = 4 THEN
			feed_record.calc_code := '6';
		ELSIF (grec_award.account_type_code = 7) OR
				(gs_unit_number = '401750') OR (gs_unit_number = '401710') THEN
			feed_record.calc_code := '1';
		ELSE
			feed_record.calc_code := ' ';
		END IF;

--dbms_output.put_line('done CALC_CODE');

--SET CFDANO

		ls_cfda := LTRIM(RTRIM(grec_award.cfda_number));

		IF (LENGTH(ls_cfda) > 3)  THEN
			if(SUBSTR(ls_cfda, 3, 1) <> '.') THEN			
				ls_Cfda := SUBSTR(ls_cfda, 1, 2) || '.' || SUBSTR(ls_cfda, 3);
			END IF;
			feed_record.cfdano := ls_Cfda;
--dbms_output.put_line('done CFDANO');
		END IF;

--SET COSTING_SHEET_KEY

  		feed_record.COSTING_SHEET_KEY := gs_costing_sheet;

--dbms_output.put_line('done COSTING_SHEET_KEY');

--SET LAB_ALLOCATION_KEY

		feed_record.lab_allocation_key := fn_get_lab_allocation;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 21');
--dbms_output.put_line('done LAB_ALLOCATION_KEY');

--SET EB_ADJUSTMENT_KEY

		feed_record.eb_adjustment_key := gs_eb_adjustment_key;

--dbms_output.put_line('done EB_ADJUSTMENT_KEY');

--SET OH_ADJUSTMENT_KEY

		feed_record.oh_adjustment_key := gs_oh_adjustment_key;

--dbms_output.put_line('done OH_ADJUSTMENT_KEY');

--SET COMMENT1

		feed_record.comment1 := fn_generate_comment1;
--upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Pass 22');
--SET COMMENT2

		feed_record.comment2 := '-';

--SET COMMENT3

		feed_record.comment3 := '-';

--SET TITLE

		-- feed_record.title := grec_award.title;
        --Award title truncated to 150 chars Case 4560
        feed_record.title := SUBSTR(grec_award.title, 1, 150) ;

--SET SORT_ID

		feed_record.sort_id := ai_sort_id;

--Now insert the feed record to SAP_FEED_BATCH_LIST
select SEQ_SAP_ID.nextval into li_sp_feed_id from dual;
  INSERT INTO SAP_FEED(
					SAP_FEED_ID,
					BATCH_ID,
					SAP_FEED_BATCH_ID,
					FEED_ID,		
					SAP_TRANSACTION,
					WBS_TYPE,
					ACCOUNT_LEVEL,
					MIT_SAP_ACCOUNT,
					DEPTNO,
					BILLING_ELEMENT,
					BILLING_TYPE,
					BILLING_FORM,
					SPON_CODE,
					PRIMARY_SPONSOR,
					CONTRACT,
					CUSTOMER,
					TERM_CODE,
					PARENT_ACCOUNT,
					ACCTNAME,
					EFFECT_DATE,
					EXPIRATION,
					SUB_PLAN,
					MAIL_CODE,
					SUPERVISOR,
					SUPER_ROOM,
					ADDRESSEE,
					ADDR_ROOM,
					AGREE_TYPE,
					AUTH_TOTAL,
					COST_SHARE,
					FUND_CLASS,
					POOL_CODE,
					PENDING_CODE,
					FS_CODE,
					DFAFS,
					CALC_CODE,
					CFDANO,
					COSTING_SHEET_KEY,
					LAB_ALLOCATION_KEY,
					EB_ADJUSTMENT_KEY,
					OH_ADJUSTMENT_KEY,
					COMMENT1,
					COMMENT2,
					COMMENT3,
					TITLE,
					SORT_ID,
					UPDATE_USER,
					UPDATE_TIMESTAMP,
					VER_NBR,
					OBJ_ID				
					)
	VALUES( li_sp_feed_id, 
	        feed_record.BATCH_ID,
			feed_record.SAP_FEED_BATCH_ID,
            feed_record.FEED_ID,
            feed_record.SAP_TRANSACTION,
            feed_record.WBS_TYPE,
            feed_record.ACCOUNT_LEVEL,
            feed_record.MIT_SAP_ACCOUNT,
            feed_record.DEPTNO,
			feed_record.BILLING_ELEMENT,
            feed_record.BILLING_TYPE,
            feed_record.BILLING_FORM,
            feed_record.SPON_CODE,
            feed_record.PRIMARY_SPONSOR,
            feed_record.CONTRACT,
            feed_record.CUSTOMER,
            feed_record.TERM_CODE,
            feed_record.PARENT_ACCOUNT,
            feed_record.ACCTNAME,
            feed_record.EFFECT_DATE,
            feed_record.EXPIRATION,
            feed_record.SUB_PLAN,
            feed_record.MAIL_CODE,
            feed_record.SUPERVISOR,
            feed_record.SUPER_ROOM,
            feed_record.ADDRESSEE,
            feed_record.ADDR_ROOM,
            feed_record.AGREE_TYPE,
            feed_record.AUTH_TOTAL,
            feed_record.COST_SHARE,
            feed_record.FUND_CLASS,
            feed_record.POOL_CODE,
            feed_record.PENDING_CODE,
            feed_record.FS_CODE,
            feed_record.DFAFS,
            feed_record.CALC_CODE,
            feed_record.CFDANO,
            feed_record.COSTING_SHEET_KEY,
            feed_record.LAB_ALLOCATION_KEY,
            feed_record.EB_ADJUSTMENT_KEY,
            feed_record.OH_ADJUSTMENT_KEY,
				feed_record.COMMENT1,
				feed_record.COMMENT2,
				feed_record.COMMENT3 ,
				feed_record.TITLE,
				feed_record.sort_id,
        USER,
        SYSDATE,
        1,
        SYS_GUID());


   return (0);
	EXCEPTION 
	WHEN OTHERS THEN
	  upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Exception happened while inserting to SAP_FEED, award number = '||gs_award_number||', sequence number = '||gi_sequence_number||'. Error is '||substr(SQLERRM,1,250));
	  Return (-1);
	end generate_feed;

/***************************************************************************/
function fn_is_valid_award  return number is
/***************************************************************************/

-----------------------------------------------------------------------------------------------------
--This function is called for every entry in the sap_feed_details table.
--Return 0 if the award is Valid.
--return -1 if this award is Invalid.
--Any edit checks which has to be done from Coeus side shold be done from this function.
--This function also sets some global variables, like gs_account_number, gs_parent_award_number
-- gs_Parent_account_number  etc.
------------------------------------------------------------------------------------------------------

award_not_found               EXCEPTION;
null_account_number           EXCEPTION;
invalid_account_number        EXCEPTION;
parent_not_found              EXCEPTION;
null_parent_account_number    EXCEPTION;
invalid_parent_account_number EXCEPTION;
invalid_sponsor					EXCEPTION;

--This exception will be raised if the account is a consortium.
--Should be removed later once we figure out how to deal with consortium accounts

consortium_account				EXCEPTION;

--This exception will be raised if the status of the award is 'Inactive (2)' or 'Hold(6)'

hold_account						EXCEPTION;           --added on 03/16/98


error_message                 varchar2(350);
li_count                      Number;

begin

--Check if this award is in Hold or Inactive
IF (grec_award.status_code = 2)  OR (grec_award.status_code = 6) THEN --added on 03/16/98
	raise hold_account;
END IF;


  SELECT AWARD.ACCOUNT_NUMBER
    INTO gs_account_number
    FROM AWARD
   WHERE ( AWARD.AWARD_NUMBER = gs_award_number ) AND
         ( AWARD.SEQUENCE_NUMBER = gi_sequence_number ) AND
		 ( AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED') 	 ;

IF gs_account_number is null THEN
   raise null_account_number;
END IF;

IF LENGTH(LTRIM(RTRIM(gs_account_number))) < 7 THEN
   raise invalid_account_number;
END IF;

--Following Edit check added on 3/22/01.
--Account numbers less than 1000000 should not be fed to sap

IF TO_NUMBER(gs_account_number) < 1000000 THEN
	raise invalid_account_number;
END IF;

--Check if parent award exsits for this award

SELECT  count(AWARD_HIERARCHY.PARENT_AWARD_NUMBER)
INTO  li_Count
   FROM AWARD_HIERARCHY
   WHERE (AWARD_HIERARCHY.AWARD_NUMBER = gs_award_number ) 
   AND ACTIVE = 'Y';

IF li_Count = 0 THEN
	raise parent_not_found;
END IF;

--Now since we know that there is an entry in AWARD_HIERARCHY table
--get the parent_mit_award_number



SELECT  AWARD_HIERARCHY.PARENT_AWARD_NUMBER
INTO gs_parent_award_number
   FROM AWARD_HIERARCHY
   WHERE (AWARD_HIERARCHY.AWARD_NUMBER = gs_award_number )
   AND ACTIVE = 'Y'   ;

--IF Parent award_number = '000000-00000' then this award is a level 1 award.
--ELSE get the parent award's account_number.

IF gs_parent_award_number <> '000000-00000' THEN
	SELECT AWARD.ACCOUNT_NUMBER
    INTO gs_parent_account_number
    FROM AWARD
   WHERE ( AWARD.AWARD_NUMBER = gs_parent_award_number AND AWARD.AWARD_SEQUENCE_STATUS = 'ACTIVE') AND
         ( AWARD.SEQUENCE_NUMBER = (SELECT MAX(AWARD2.SEQUENCE_NUMBER)
													FROM AWARD AWARD2		 WHERE
													AWARD2.AWARD_NUMBER =AWARD.AWARD_NUMBER AND AWARD2.AWARD_SEQUENCE_STATUS = AWARD.AWARD_SEQUENCE_STATUS));
ELSE

/**********************************************************************************************
The following logic is commented out on 12/15/99
Now on, don;t have to apply any logic for parent account number if award is at -001 level
always send blank

	--gs_award_number is an -001 award.
	--Check is this award has any children, if yes parent_account_number = account_number
	--else parent_account_number = blank

	SELECT  count(AWARD_HIERARCHY.MIT_AWARD_NUMBER)
		INTO  li_Count
   FROM AWARD_HIERARCHY
   WHERE (AWARD_HIERARCHY.PARENT_MIT_AWARD_NUMBER = gs_award_number );

	IF li_Count = 0 THEN
	--gs_award_number does not have any children

		gs_parent_account_number := '       ';
	ELSE
		gs_parent_account_number := gs_account_number;
	END IF;
**************************************************************************************************/

	gs_parent_account_number := '       ';

END IF;

IF gs_parent_account_number is null THEN
   raise null_parent_account_number;
END IF;

IF LENGTH(LTRIM(RTRIM(gs_parent_account_number))) < 7 THEN
   raise invalid_parent_account_number;
END IF;


--Check if this is a consortium account
IF grec_award.award_type_code = 8 THEN
	raise consortium_account;
END IF;

BEGIN

	select sponsor_name
	into gs_sponsor_name
	from sponsor
	where rtrim(sponsor_code) = rtrim(grec_award.sponsor_code);

	EXCEPTION
		WHEN others THEN
		upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid sponsor code for award number = '||gs_award_number||', sequence number = '||gi_sequence_number||', Sponsr cd = '||grec_award.sponsor_code);
    	return (-1);
END;



return (0);

EXCEPTION

WHEN null_account_number THEN
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Account Number is Null for award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
    return (-1);

WHEN invalid_account_number THEN
    error_message := 'Invalid Account Number. Account number should be 7 character long and shoule be >= 1000000.';
	error_message := error_message ||' Award number = '||gs_award_number||', sequence number = '||gi_sequence_number;
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, error_message);
    return (-1);

WHEN null_parent_account_number THEN
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Parent Account Number is Null for award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
    return (-1);

WHEN invalid_parent_account_number THEN
    error_message := 'Invalid Parent Account Number. Account number should be 7 character long.';
	error_message := error_message|| ' for award number = '||gs_award_number||', sequence number = '||gi_sequence_number;
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, error_message);
    return (-1);

WHEN parent_not_found THEN
     upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Parent MIT award number not found in AWARD_HIERARCHY table. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
	  return (-1);

WHEN consortium_account THEN
     upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Feed for consortium accounts not implemented. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
	  return (-1);

WHEN hold_account THEN																	--added on 03/16/98
     upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'The Account is in Hold or Inactive. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
	  return (-1);

WHEN OTHERS THEN
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Exception in fn_is_valid_award, Award number = '||gs_award_number||', sequence number = '||gi_sequence_number||'. Error is '||SUBSTR(SQLERRM, 1, 200));
    return (-1);

/*===========================*/
end fn_is_valid_award;
/*===========================*/

/***************************************************************************/
--Function to return the Agreement type.

function fn_get_agree_type  return char is
/***************************************************************************/

/*****************************************************************************
5/6/2002
Name of the funtion is changed to fn_get_agree_type
New logic to return Agreement type
Prior to this change this function was used to return project type used in
project_type as well as agree_type
AGREE_TYPE is not char(2) instead of char(1)
*****************************************************************************/

ls_agree_type char(2);
li_award_type number;
ls_first_char char;

begin

	li_award_type := grec_award.award_type_code;

	IF (grec_award.sponsor_code = '009904') OR (grec_award.sponsor_code = '009906') THEN
		ls_agree_type := '14';
	ELSIF (li_award_type = 1) THEN
		ls_agree_type := '01';
	ELSIF (li_award_type = 2) THEN
		ls_agree_type := '01';
	ELSIF (li_award_type = 3) THEN
		ls_agree_type := '02';
	ELSIF (li_award_type = 4) THEN
		ls_agree_type := '15';
	ELSIF (li_award_type = 5) THEN
		ls_agree_type := '12';
	ELSIF (li_award_type = 6) THEN
		ls_agree_type := '04';
	ELSIF (li_award_type = 7) THEN
		ls_agree_type := '06';
	ELSIF (li_award_type = 8) THEN
		ls_agree_type := '02';
	ELSIF (li_award_type = 9) THEN
		ls_agree_type := '13';
	ELSIF (li_award_type = 10) THEN
		ls_agree_type := '01';
	ELSIF (li_award_type = 11) THEN
		ls_agree_type := '14';
	ELSIF (li_award_type = 12) THEN
		ls_agree_type := '03';
	ELSIF (li_award_type = 13) THEN
		ls_agree_type := '16';
	END IF;

return (ls_agree_type);

/******************************************************************************
Old logic for project type commented out

   ls_first_char := substr(gs_account_number, 1, 1);
	ls_project_type := ' ';
	li_award_type := grec_award.award_type_code;

	IF (ls_first_char = '1') THEN
		ls_project_type := '4';
	ELSIF ((ls_first_char = '2') OR (ls_first_char = '3')) THEN
		ls_project_type := '6';
	ELSE
		IF ((li_award_type = 1) OR (li_award_type = 5)) THEN
			ls_project_type := '1';
		ELSIF (li_award_type = 2) THEN
			ls_project_type := '5';
		ELSIF (li_award_type = 6) THEN
			ls_project_type := '4';
		ELSIF (li_award_type = 7) THEN
			ls_project_type := '6';
		ELSIF ((li_award_type = 3) OR (li_award_type = 4) OR (li_award_type = 8) OR (li_award_type = 9)) THEN
			IF (grec_award.basis_of_payment_code = 2) THEN
				ls_project_type := '2';
			ELSE
				ls_project_type := '3';
			END IF;
		ELSE
			ls_project_type := '1';   --Fall thru condition
		END IF;
	END IF;

	return (ls_project_type);
******************************************************************************/


/*===========================*/
end fn_get_agree_type;
/*===========================*/


/***************************************************************************/
--Retrieves lead unit number from the database and
--assigns it to the glogab variable gs_unit_number;

function fn_init_lead_unit return number is
/***************************************************************************/

v_award_person_id NUMBER(12);

pi_not_found    	EXCEPTION;
pi_name_too_long	EXCEPTION;
lu_not_found    	EXCEPTION;

--ls_person_id 	AWARD_PERSONS.PERSON_ID%TYPE;

cursor cur_pi is
  SELECT AWARD_PERSONS.AWARD_PERSON_ID, AWARD_PERSONS.PERSON_ID,
         AWARD_PERSONS.FULL_NAME
         FROM AWARD_PERSONS INNER JOIN AWARD on AWARD_PERSONS.AWARD_ID = AWARD.AWARD_ID
	 WHERE AWARD_PERSONS.AWARD_NUMBER = gs_award_number
	 and AWARD_PERSONS.CONTACT_ROLE_CODE = 'PI'
	 AND AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED'
      AND AWARD_PERSONS.SEQUENCE_NUMBER =		 (SELECT MAX(INV2.SEQUENCE_NUMBER)
          FROM AWARD_PERSONS INV2 WHERE
            INV2.AWARD_NUMBER =			 AWARD_PERSONS.AWARD_NUMBER	and
				INV2.SEQUENCE_NUMBER <= gi_sequence_number	)
	 order by AWARD_PERSON_ID desc;

begin

	OPEN cur_pi;
	FETCH cur_pi INTO v_award_person_id, gs_pi_id, gs_pi_name;

	IF cur_pi%NOTFOUND THEN
		raise pi_not_found;
	END IF;

	CLOSE cur_pi;
/***************************************************
--This check commented out on 8/15/05 by Sabari
	IF Length(gs_pi_name) > 30 THEN
		raise pi_name_too_long;
	END IF;
****************************************************/
/************************************************
	IF ls_non_mit_flag <> 'Y' THEN   -- MIT person

	Do not check for PI office location yet
	Commented out on 11/14/03.
   This logic is moved down in this function *****

	ELSE
       gs_pi_room := '          '; --10 spaces
	END IF;

*************************************************/

BEGIN

	SELECT LTRIM(RTRIM(AWARD_PERSON_UNITS.UNIT_NUMBER))
	INTO gs_unit_number
	FROM AWARD_PERSON_UNITS
	WHERE AWARD_PERSON_ID = v_award_person_id
	AND LEAD_UNIT_FLAG = 'Y';
	

	/*
	SELECT LTRIM(RTRIM(AWARD_PERSON_UNITS.UNIT_NUMBER))
	INTO gs_unit_number
	FROM AWARD_PERSON_UNITS,AWARD_PERSONS
	WHERE AWARD_PERSON_UNITS.AWARD_PERSON_ID=AWARD_PERSONS.AWARD_PERSON_ID and
 AWARD_PERSONS.AWARD_NUMBER = gs_award_number and
	AWARD_PERSON_UNITS.LEAD_UNIT_FLAG = 'Y' AND
	RTRIM(AWARD_PERSONS.PERSON_ID) = RTRIM(gs_pi_id)
	AND	AWARD_PERSONS.SEQUENCE_NUMBER =		 (SELECT MAX(UNIT2.SEQUENCE_NUMBER)
	FROM AWARD_PERSONS UNIT2		 WHERE
	UNIT2.AWARD_NUMBER =			AWARD_PERSONS.AWARD_NUMBER	and
	UNIT2.SEQUENCE_NUMBER <= gi_sequence_number	);
	*/
	

EXCEPTION
		WHEN OTHERS THEN
   	 upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Lead Unit Information not found for this Award. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
   	 return (-1);
END;

/* Now that we have the lead unit we should get pi_room now **/
IF gs_pi_id <> NULL THEN   -- MIT person
	BEGIN

		IF (gs_pi_id = '900006550') and (ltrim(rtrim(gs_unit_number)) like '0698%') THEN

--For certain PIs and LU combination take secondry office location

			SELECT PERSON_EXT_T.SECONDRY_OFFICE_LOCATION
			INTO gs_pi_room
			  FROM PERSON_EXT_T
			 WHERE RTRIM(PERSON_EXT_T.PERSON_ID) = RTRIM(gs_pi_id)   ;

		ELSE

			SELECT PERSON_EXT_T.OFFICE_LOCATION
			INTO gs_pi_room
			  FROM PERSON_EXT_T
			 WHERE RTRIM(PERSON_EXT_T.PERSON_ID) = RTRIM(gs_pi_id)   ;
		END IF;

	EXCEPTION
			WHEN OTHERS THEN
			gs_pi_room := '          '; --10 spaces
	END;

ELSE
      gs_pi_room := '          '; --10 spaces
END IF;



BEGIN   --Have the select within a BEGIN-END block so that it does not raise an exception.


	SELECT PERSON_EXT_T.PERSON_ID,
         PERSON_EXT_T.OFFICE_LOCATION
	INTO gs_addresse_id,
		  gs_addresse_room
    FROM PERSON_EXT_T,
         UNIT_ADMINISTRATOR
   WHERE ( RTRIM(UNIT_ADMINISTRATOR.PERSON_ID) = RTRIM(PERSON_EXT_T.PERSON_ID) ) and
         ( ( RTRIM(UNIT_ADMINISTRATOR.UNIT_NUMBER) = gs_unit_number ) ) and
		 UNIT_ADMINISTRATOR.UNIT_ADMINISTRATOR_TYPE_CODE='5' ;

EXCEPTION
		WHEN OTHERS THEN
   	 	gs_addresse_id := NULL;
END;

--IF there is no Other_individual to notify, use room and name
--of administrative officer

IF (gs_addresse_id is NULL) OR  (LTRIM(RTRIM(gs_addresse_id)) = '') THEN

BEGIN

	SELECT PERSON_EXT_T.PERSON_ID,
         PERSON_EXT_T.OFFICE_LOCATION
	INTO gs_addresse_id,
		  gs_addresse_room
    FROM PERSON_EXT_T,
         UNIT_ADMINISTRATOR
   WHERE ( RTRIM(UNIT_ADMINISTRATOR.PERSON_ID) = RTRIM(PERSON_EXT_T.PERSON_ID) ) and
         ( ( RTRIM(UNIT_ADMINISTRATOR.UNIT_NUMBER) = gs_unit_number ) ) and
		 UNIT_ADMINISTRATOR.UNIT_ADMINISTRATOR_TYPE_CODE='1';

EXCEPTION
		WHEN OTHERS THEN
   	 	gs_addresse_id := NULL;

END;

END IF;


return 0;

EXCEPTION

WHEN pi_not_found THEN
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'PI Information not found for this Award. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
    return (-1);

WHEN pi_name_too_long THEN
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'PI name is more than 30 characters. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
    return (-1);

WHEN lu_not_found THEN
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Lead Unit Information not found for this Award. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
    return (-1);

WHEN OTHERS THEN
    upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id,'Exception in fn_init_lead_unit, Award number = '||gs_award_number||', sequence number = '||gi_sequence_number||',Error is'|| SUBSTR(SQLERRM, 1, 200));
    return (0);

/*===========================*/
end fn_init_lead_unit;
/*===========================*/


/***************************************************************************/
function fn_get_money_and_dates return number is
/***************************************************************************/

li_Count					NUMBER;
begin

--Change made for March 2000 release.
--Need to get the amount for the transaction_id.
--earlier we were retrieving max amount sequence for the given sequence_number
BEGIN
	
SELECT count(s0.DOC_HDR_ID) INTO li_Count  from KREW_DOC_HDR_T s0
	inner join award_amount_info s1 on s0.DOC_HDR_ID = s1.TNM_DOCUMENT_NUMBER
	where s1.AWARD_NUMBER = gs_award_number
	and s0.DOC_HDR_STAT_CD = 'F';

  IF(li_Count > 0 ) THEN
  		SELECT AWARD_AMOUNT_INFO.OBLIGATION_EXPIRATION_DATE,
         AWARD_AMOUNT_INFO.ANTICIPATED_TOTAL_AMOUNT,
         AWARD_AMOUNT_INFO.AMOUNT_OBLIGATED_TO_DATE
		INTO  gd_exp_date,
		  gn_anticipated_total,
		  gn_obligated_total
    	FROM AWARD_AMOUNT_INFO
		WHERE AWARD_AMOUNT_INFO.AWARD_NUMBER = gs_award_number
		AND AWARD_AMOUNT_INFO.AWARD_AMOUNT_INFO_ID = ( select max(t1.AWARD_AMOUNT_INFO_ID) from AWARD_AMOUNT_INFO t1
														where t1.AWARD_NUMBER =	AWARD_AMOUNT_INFO.AWARD_NUMBER and t1.TNM_DOCUMENT_NUMBER in 
                                  (select DOC_HDR_ID from KREW_DOC_HDR_T where DOC_HDR_ID = TNM_DOCUMENT_NUMBER and DOC_HDR_STAT_CD = 'F'));
		-- Changed for MITKC-1840						  
		-- AND		TO_NUMBER(nvl(AWARD_AMOUNT_INFO.TRANSACTION_ID,0)) = ( SELECT MAX(TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)))
		--															FROM   AWARD_AMOUNT_INFO AMOUNT3
		--													WHERE  AMOUNT3.AWARD_NUMBER 	 = AWARD_AMOUNT_INFO.AWARD_NUMBER
		--													 AND    AWARD_AMOUNT_INFO.SEQUENCE_NUMBER  = AMOUNT3.SEQUENCE_NUMBER
		--													 AND TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)) <= TO_NUMBER(nvl(gs_transaction_id,0)));
	ELSE
  		SELECT AWARD_AMOUNT_INFO.OBLIGATION_EXPIRATION_DATE,
         AWARD_AMOUNT_INFO.ANTICIPATED_TOTAL_AMOUNT,
         AWARD_AMOUNT_INFO.AMOUNT_OBLIGATED_TO_DATE
		INTO  gd_exp_date,
		  gn_anticipated_total,
		  gn_obligated_total
    	FROM AWARD_AMOUNT_INFO
		WHERE AWARD_AMOUNT_INFO.AWARD_NUMBER = gs_award_number AND AWARD_AMOUNT_INFO.TNM_DOCUMENT_NUMBER IS NULL
		AND AWARD_AMOUNT_INFO.originating_award_version is not null 
		AND	AWARD_AMOUNT_INFO.SEQUENCE_NUMBER =		 ( SELECT MAX(AMOUNT2.SEQUENCE_NUMBER) FROM AWARD_AMOUNT_INFO AMOUNT2
													WHERE AMOUNT2.TNM_DOCUMENT_NUMBER IS NULL AND AMOUNT2.AWARD_NUMBER = AWARD_AMOUNT_INFO.AWARD_NUMBER
													and	AMOUNT2.SEQUENCE_NUMBER <= gi_sequence_number)
		AND	TO_NUMBER(nvl(AWARD_AMOUNT_INFO.TRANSACTION_ID,0)) = ( SELECT MAX(TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)))
																	FROM   AWARD_AMOUNT_INFO AMOUNT3
															WHERE  AMOUNT3.AWARD_NUMBER 	 = AWARD_AMOUNT_INFO.AWARD_NUMBER
															 AND    AWARD_AMOUNT_INFO.SEQUENCE_NUMBER  = AMOUNT3.SEQUENCE_NUMBER
															 AND TO_NUMBER(nvl(AMOUNT3.TRANSACTION_ID,0)) <= TO_NUMBER(nvl(gs_transaction_id,0)));

	END IF;
	
EXCEPTION
WHEN OTHERS THEN
 upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id,'Exception in fn_get_money_and_dates, Award number = '||gs_award_number||', sequence number = '||gi_sequence_number ||', transaction id = '||gs_transaction_id||',Error is'|| SUBSTR(SQLERRM, 1, 200));
 return -1;
END;

return 0;

/*===========================*/
end fn_get_money_and_dates;
/*===========================*/


/***************************************************************************/
function fn_get_lab_allocation return CHAR is
/***************************************************************************/

--As part of march layout change Lab allocation is char(6)
--Prefix '01' to all lab_allocation

ls_allocation char(6);

begin

	ls_allocation := '      ';

 IF grec_award.account_type_code <> 2 THEN  -- logic changed 4-3-98 - steve

    --Following accounts does not get lab allocation.
    --Logic added on 4/1/13 JIRA COEUS-345
    --1276108 added to exception list on 8/13/13
    IF gs_account_number not in ('1276086', '1276087', '1276099', '1276108') then

        IF gs_unit_number ='061011' THEN
            ls_allocation := '010001';
        ELSIF gs_unit_number ='061040' THEN
            ls_allocation := '010002';
        ELSIF gs_unit_number ='068500' THEN
            ls_allocation := '010003';
        ELSIF gs_unit_number ='068600' THEN
            ls_allocation := '010004';
        ELSIF gs_unit_number ='068700' THEN
            ls_allocation := '010005';
        ELSIF gs_unit_number ='069300' THEN
            ls_allocation := '010006';
        ELSIF gs_unit_number ='069400' THEN
            ls_allocation := '010007';
        ELSIF gs_unit_number ='069500' THEN
            ls_allocation := '010008';
        ELSIF (gs_unit_number ='159600') OR (gs_unit_number ='159601') THEN  -- OR condition added on 10/18/04
            ls_allocation := '010009';
        ELSIF (gs_unit_number ='243000')  OR (gs_unit_number ='243010') OR (gs_unit_number ='243020') THEN
            ls_allocation := '010010';
        ELSIF gs_unit_number ='265000' THEN
            ls_allocation := '010011';
        ELSIF (gs_unit_number ='267000') OR (gs_unit_number ='267100') OR (gs_unit_number ='267200') OR
               (gs_unit_number ='267300') OR (gs_unit_number ='267400') THEN
            ls_allocation := '010012';
        ELSIF gs_unit_number ='320000'  or  (gs_unit_number = '320010') THEN   -- changed on 7-14-99
            ls_allocation := '010013';
        ELSIF gs_unit_number ='401710' THEN
            ls_allocation := '010014';
        ELSIF gs_unit_number ='401750' THEN
            ls_allocation := '010015';
        ELSIF (gs_unit_number ='069850') OR (gs_unit_number ='069890') THEN -- OR condition added on 1/22/10
            ls_allocation := '010017';
        ELSIF gs_unit_number ='243500' THEN
            ls_allocation := '010018';
            
        ELSIF gs_unit_number in ('067900', '067910', '067912', '067913', '067914', '067915', 
                                '067920', '067921', '067930', '067941', '067950', '067951', 
                                 '067952', '067960', '067961', '067962', '067971', 
                                 '067972', '067973', '067944' )  THEN       --COEUSDEV-704
                                 
            ls_allocation := '010019';
            
        ELSIF gs_unit_number ='159900' THEN       --Added on 3/9/05
            ls_allocation := '010020';
        ELSIF (gs_unit_number ='267600') OR (gs_unit_number ='267900')  OR  --JIRA coeusdev-668
              (gs_unit_number ='268000')  THEN -- coeusdev-673 
            ls_allocation := '010012'; 
        ELSIF gs_unit_number ='267500' THEN       --COEUSDEV-1062 
            ls_allocation := '010012';
        ELSIF gs_unit_number ='243021' THEN       --COEUS-492 
            ls_allocation := '010010';
        ELSIF gs_unit_number in ('267110', '267700', '267800') then --COEUSDEV-1216
            ls_allocation := '010012';
        ELSIF gs_unit_number = '267111' then
            ls_allocation := '010012';
        END IF;
    end if;
 end if;


return ls_allocation;

/*===========================*/
end fn_get_lab_allocation;
/*===========================*/


/***************************************************************************/
function fn_get_dfafs return CHAR is
--This function was created on 03-16-98.
--Logic provided by steve.
/***************************************************************************/

ls_dfafs 			char(20);
ls_coeusDfafs 		AWARD.DFAFS_NUMBER%TYPE;
ls_SponAwardNum	AWARD.SPONSOR_AWARD_NUMBER%TYPE;


begin

	ls_dfafs := '                    ';

	ls_coeusDfafs := grec_award.dfafs_number;
	IF (ls_coeusDfafs IS NULL) THEN
		ls_coeusDfafs := '                    ';
	END IF;

	ls_dfafs := ls_coeusDfafs ;

--6/26/00
--Do not apply the following logic to DFAFS, send whatever is in Coeus

/*
	ls_SponAwardNum := grec_award.sponsor_award_number;

--IF sponsor award number is null, return dfafs number
	IF (ls_SponAwardNum IS NULL)  OR (LENGTH(ls_SponAwardNum) < 16) THEN
		Return(ls_dfafs);
	END IF;

	IF LENGTH(LTRIM(RTRIM(ls_coeusDfafs))) >= 3 AND (grec_award.sponsor_code = '000340') THEN

		ls_dfafs := SUBSTR(ls_coeusDfafs, 1, 2) || SUBSTR(ls_SponAwardNum, 3, 1) ||
					  SUBSTR(ls_SponAwardNum, 5, 1) || SUBSTR(ls_SponAwardNum, 7, 7) ||
					  SUBSTR(ls_coeusDfafs, 3, 1) || ' ';

	END IF;
*/

return ls_dfafs;

/*===========================*/
end fn_get_dfafs;
/*===========================*/



/***************************************************************************/
--Function to calculate the costing sheet key

function fn_get_costing_sheet_key return number is
/***************************************************************************/

ls_costing_sheet char(6);
ls_description	  varchar2(200);
ls_Temp			  char(4);

--Declare a cursor to retrieve IDC rate types description
--for fiscal_year <= gs_fiscal_year

cursor cur_idc is
		SELECT AWARD_IDC_RATE.fiscal_year,
				 idc_rate_type.description
    FROM AWARD_IDC_RATE,idc_rate_type
   WHERE (AWARD_IDC_RATE.idc_rate_type_code =idc_rate_type.idc_rate_type_code) AND
		(AWARD_IDC_RATE.AWARD_ID = gi_award_id ) AND
         (AWARD_IDC_RATE.START_DATE <= SYSDATE )                 --Added on 8/13/03	     
	order by AWARD_IDC_RATE.start_date DESC;             --Changed order by to start_date

begin

--Check if IDC is present for this sequence of the award
--if not do not open the cursor.

--	IF (SUBSTR(grec_award.fy_recover_idc_indicator, 1, 1) = 'P') THEN (3.0)

--		IF (SUBSTR(grec_award.idc_indicator, 1, 1) = 'P') THEN
		OPEN cur_idc;

		--Fetch only once. We only need the first row that is returned.

		FETCH cur_idc INTO ls_temp,  ls_description;

		IF cur_idc%NOTFOUND THEN
			ls_description := ' ';
		END IF;

		close cur_idc;
--	ELSE
--		ls_description := ' ';
--	END IF;


--check if this award has an underrecovery for the current fiscal_year or earlier.
--if yes take the description of idc_rate_type_code and assign to costing_sheet.


		IF (ls_description IS NOT NULL) AND (ls_description <> ' ') THEN

			ls_costing_sheet := LTRIM(RTRIM(SUBSTR(ls_description, 1, 6)));
			IF gs_account_number >= '1000000' AND gs_account_number <= '1999999' THEN
				IF (SUBSTR(ls_costing_sheet, 1, 1) <> 'E') AND (SUBSTR(ls_costing_sheet, 1, 1) <> 'G')
					AND (SUBSTR(ls_costing_sheet, 1, 1) <> 'B') AND -- 'B' Added on 10/30/03
					(SUBSTR(ls_costing_sheet, 1, 5) <> 'RESEB') THEN   -- RESEB Added on 5/24/06
					upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid Costing sheet assigned. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
			    	return (-1);
				END IF;
			ELSIF gs_account_number >= '2000000' AND gs_account_number <= '4999999' THEN
				IF (SUBSTR(ls_costing_sheet, 1, 1) <> 'E') AND (SUBSTR(ls_costing_sheet, 1, 1) <> 'F') AND
					(SUBSTR(ls_costing_sheet, 1, 1) <> 'S') THEN
					upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid Costing sheet assigned. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
			    	return (-1);
				END IF;
			ELSIF gs_account_number >= '5000000' THEN
				IF (SUBSTR(ls_costing_sheet, 1, 1) <> 'E') AND (SUBSTR(ls_costing_sheet, 1, 1) <> 'R')
                   AND (SUBSTR(ls_costing_sheet, 1, 1) <> 'B') THEN
					upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid Costing sheet assigned. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
			    	return (-1);
				END IF;
			END IF;

		ELSE
			IF grec_award.account_type_code = 2 THEN
				ls_costing_sheet := 'EXCLU';

			ELSIF grec_award.account_type_code = 3 THEN
				ls_costing_sheet := 'FUNSAX';

			ELSIF grec_award.account_type_code = 4 THEN
				ls_costing_sheet := 'RESEB';

			ELSIF (SUBSTR(gs_account_number, 1, 1) = '1') THEN
				ls_costing_sheet := 'GENSN';

			ELSIF (((gs_unit_number = '401750') OR (gs_unit_number = '401710')) AND
					(gs_account_number >= '5000000')) THEN
				ls_costing_sheet := 'RESMFF';

			ELSIF (gs_account_number >= '2000000') AND (gs_account_number <= '4999999') AND --added on 10/6/98
					((gs_unit_number = '401750') OR (gs_unit_number = '401710')) THEN          --added on 10/6/98
				ls_costing_sheet := 'FUNNXF';																  --added on 10/6/98

			ELSIF (gs_account_number >= '2000000') AND (gs_account_number <= '4999999') AND
					(gs_unit_number > '321099')  AND
					(gs_unit_number <> '401811') AND                                     --added on 9/9/98
					(gs_unit_number <> '401812') AND (gs_unit_number <> '401813') AND   --added on 9/9/98
					(gs_unit_number <> '400600') AND (gs_unit_number <> '417000') AND   -- Added on 3/26/04
					(gs_unit_number <> '418000') AND (gs_unit_number <> '401511')	AND		-- Added on 3/26/04
					(gs_unit_number <> '430000') AND 				 					--Added on 2/24/2006
					(gs_unit_number <> '401900') AND                                    -- Added on 7/24/2006
                    (gs_unit_number <> '414000') AND --Added on 4/29/10 COEUSDEV-516
                    (NOT ((gs_unit_number >= '440100') and (gs_unit_number <= '440199'))) and --added on 4/11/12 JIRA coeusdev-1082
					(NOT ((gs_unit_number >= '419000') and (gs_unit_number <= '419099'))) THEN -- Added on 3/26/04
				ls_costing_sheet := 'FUNNX';

			ELSIF (gs_unit_number >= '121000') AND  (gs_unit_number <= '122999') AND   --Changed the range to 122999 6/27/00
					(gs_account_number < '5000000')  THEN

				ls_costing_sheet := 'SLNSN';

			ELSIF (gs_unit_number = '271000') AND (gs_account_number < '5000000') THEN
				ls_costing_sheet := 'FUNFN';
/*   Commented out on 10/2/2008
    ** We will no longer default any type of fellowship to the FUNSNX costing sheet. **

			ELSIF (SUBSTR(gs_account_number, 1, 1) = '2') AND  ((grec_award.activity_type_code = 3)
									or (grec_award.activity_type_code = 7)) THEN
				ls_costing_sheet := 'FUNSNX';
*/
			ELSIF (gs_account_number < '5000000')  AND (grec_award.account_type_code = 7) THEN
				ls_costing_sheet := 'FUNNXF';

			ELSIF (gs_account_number < '5000000')  THEN
				ls_costing_sheet := 'FUNSN';

			ELSIF (grec_award.account_type_code = 7) THEN
				ls_costing_sheet := 'RESMF';

			ELSE
				ls_costing_sheet := 'RESMN';

			END IF;

		END IF;

		gs_costing_sheet := ls_costing_sheet;

return 0;

/*===========================*/
end fn_get_costing_sheet_key;
/*===========================*/


/***************************************************************************/
function fn_get_fiscal_year return number is
/***************************************************************************/

li_ret number;
ls_temp KRCR_PARM_T.VAL%TYPE;

begin
	  SELECT LTRIM(RTRIM(KRCR_PARM_T.VAL))
	  INTO ls_temp
    FROM KRCR_PARM_T
   WHERE KRCR_PARM_T.PARM_NM = 'SAP_FEED_CURRENT_FISCAL_YEAR'  ;

--dbms_output.put_line(ls_temp);


	gs_fiscal_year := SUBSTR(ls_temp, 1, 4);
--dbms_output.put_line(gs_fiscal_year);

	return (0);

EXCEPTION

when NO_DATA_FOUND THEN
	upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Entry for SAP_FEED_CURRENT_FISCAL_YEAR missing from KRCR_PARM_T table.');
    return (-1);
WHEN others THEN
	upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Exception in fn_get_fiscal_year, award number = '||gs_award_number||', sequence number = '||gi_sequence_number||'. Error is '||SUBSTR(SQLERRM, 1, 350));
    return (-1);

/*===========================*/
end fn_get_fiscal_year;
/*===========================*/


/***************************************************************************/
--Function to retrieve IDC rates and OH rates

function fn_get_rates  return number is
/***************************************************************************/

	lc_eb_on number(5,2);
	lc_eb_off number(5,2);
	li_count number;
	ls_FiscalYear			AWARD_IDC_RATE.FISCAL_YEAR%TYPE;
	ldt_StartDate			AWARD_IDC_RATE.START_DATE%TYPE;      --Added on 8/13/03

--Declare a cursor to retrieve IDC On campus rates rates
--for fiscal_year <= gs_fiscal_year

cursor cur_idc_on is
		SELECT AWARD_IDC_RATE.APPLICABLE_IDC_RATE, AWARD_IDC_RATE.FISCAL_YEAR,
				AWARD_IDC_RATE.START_DATE
    FROM AWARD_IDC_RATE
   WHERE ( AWARD_IDC_RATE.AWARD_ID = gi_award_id ) AND
         ( AWARD_IDC_RATE.START_DATE <= SYSDATE )   AND         --Added on 8/13/03
         ( AWARD_IDC_RATE.ON_CAMPUS_FLAG = 'N' )
	order by AWARD_IDC_RATE.START_DATE DESC;

--Declare a cursor to retrieve IDC Off campus rates rates
--for a given fiscal year. We need to declare a cursor with argument
--since we need to get off campus rate for the same fy as the on campus rate

cursor cur_idc_off (as_fy in AWARD_IDC_RATE.FISCAL_YEAR%TYPE,
						  ad_sd in AWARD_IDC_RATE.START_DATE%TYPE ) is
		SELECT AWARD_IDC_RATE.APPLICABLE_IDC_RATE
    FROM AWARD_IDC_RATE
   WHERE ( AWARD_IDC_RATE.AWARD_ID = gi_award_id ) AND
         ( AWARD_IDC_RATE.FISCAL_YEAR = as_fy)   AND
         ( AWARD_IDC_RATE.START_DATE = ad_sd)   AND  -- Added on 8/13/03
         ( AWARD_IDC_RATE.ON_CAMPUS_FLAG = 'F' )
	order by AWARD_IDC_RATE.START_DATE DESC;



begin

SELECT AWARD.SPECIAL_EB_RATE_OFF_CAMPUS,
         AWARD.SPECIAL_EB_RATE_ON_CAMPUS
		INTO gc_eb_off, gc_eb_on
    FROM AWARD
   WHERE ( AWARD.AWARD_NUMBER = gs_award_number ) AND
         ( AWARD.SEQUENCE_NUMBER = gi_sequence_number ) AND
		 ( AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED' );

IF ((gc_eb_off is NULL) and (gc_eb_on is NULL)) or
   ((gc_eb_off = 999.99) and (gc_eb_on = 999.99)) THEN

	gs_eb_adjustment_key := '      ';

ELSE
	BEGIN

		select adjustment_key
		into gs_eb_adjustment_key
		from valid_rates
		where on_campus_rate = gc_eb_on and off_campus_rate = gc_eb_off
		and rate_class_type = 'E';

		EXCEPTION
			WHEN others THEN
				upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid EB Rates. Cannot find a valid EB Adjustment Key. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
    			return (-1);
	END;

END IF;

IF gs_eb_adjustment_key is NULL THEN
	gs_eb_adjustment_key := '      ';
END IF;

--get idc rate on campus
--Check IF IDC exists for this sequence of the award
--IF not set idc_on and off to null

--	IF (SUBSTR(grec_award.idc_indicator, 1, 1) = 'P') THEN

		OPEN cur_idc_on;

		--Fetch only once. We only need the first row that is returned.

		FETCH cur_idc_on INTO gc_oh_on, ls_FiscalYear, ldt_StartDate;


   	IF cur_idc_on%NOTFOUND THEN
			gs_oh_adjustment_key := '      ';
		ELSE
			OPEN cur_idc_off (ls_FiscalYear, ldt_StartDate);
			FETCH cur_idc_off INTO gc_oh_off;

			IF cur_idc_off%NOTFOUND THEN
				close cur_idc_on;
				close cur_idc_off;
				upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid OH Rates. No Off campus rate available for FY ' || ls_FiscalYear||', Award number = '||gs_award_number||', sequence number = '||gi_sequence_number );
    			return (-1);
			END IF ;

			IF gc_oh_on = 999.99 AND gc_oh_off = 999.99 THEN
				gs_oh_adjustment_key := '      ';
			ELSE
				BEGIN

					select adjustment_key
					into gs_oh_adjustment_key
					from valid_rates
					where on_campus_rate = gc_oh_on and off_campus_rate = gc_oh_off
					and rate_class_type = 'O';

				EXCEPTION
					WHEN others THEN
						close cur_idc_on;
						close cur_idc_off;
						upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid OH Rates. Cannot find a valid OH Adjustment Key. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
						upd_sap_feed_log_error(gi_sap_feed_batch_id,gi_batch_id, gi_feed_id, 'Invalid OH Rates. Cannot find a valid OH Adjustment Key. Award number = '||gs_award_number||', sequence number = '||gi_sequence_number);
		    			return (-1);
				END; --END For Begin block
			END IF;

			close cur_idc_off;

		END IF ;

		close cur_idc_on;




--	ELSE  --Fist character of indicator was 'N'. i.e no IDC

--		gs_oh_adjustment_key := '      ';

--	END IF;

	return (0);

/*===========================*/
end fn_get_rates;
/*===========================*/


/***************************************************************************/
function fn_get_customer return char is
/***************************************************************************/

ls_customer char(10);
li_rolodex_id AWARD_SPONSOR_CONTACTS.ROLODEX_ID%TYPE;

cursor cur_customer is
  SELECT AWARD_SPONSOR_CONTACTS.ROLODEX_ID
    FROM AWARD_SPONSOR_CONTACTS INNER JOIN AWARD  on AWARD_SPONSOR_CONTACTS.AWARD_ID = AWARD.AWARD_ID
	 WHERE AWARD_SPONSOR_CONTACTS.AWARD_NUMBER = gs_award_number
	 and AWARD_SPONSOR_CONTACTS.CONTACT_ROLE_CODE = 3
	 AND AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED'
      AND AWARD_SPONSOR_CONTACTS.SEQUENCE_NUMBER =		 (SELECT MAX(CONTACT2.SEQUENCE_NUMBER)
          FROM AWARD_SPONSOR_CONTACTS CONTACT2 WHERE
            CONTACT2.AWARD_NUMBER =			 AWARD_SPONSOR_CONTACTS.AWARD_NUMBER	and
				CONTACT2.SEQUENCE_NUMBER <= gi_sequence_number	);
begin
	ls_customer := '          '; --10 spaces

		OPEN cur_customer;
		FETCH cur_customer INTO li_rolodex_id;
		Close cur_customer;

	IF (grec_award.method_of_payment_code = 13 ) THEN

		IF 	((grec_award.sponsor_code >= '000100') AND (grec_award.sponsor_code <= '000110')) THEN
			ls_customer := '8690005458';

		ELSIF ((grec_award.sponsor_code >= '000120') AND (grec_award.sponsor_code <= '000128')) THEN
			ls_customer := '8690005457';

		ELSIF ((grec_award.sponsor_code >= '000141') AND (grec_award.sponsor_code <= '000149')) THEN
			ls_customer := '8690005456';

		END IF;

	ELSIF (grec_award.method_of_payment_code = 1 )  OR
			(grec_award.method_of_payment_code = 9 ) THEN   --The Or condition added on 03-16-98

		IF ((grec_award.sponsor_code = '000200') OR
			(grec_award.sponsor_code = '000201') OR  --Added on 5/23/00
			(grec_award.sponsor_code = '000202')) THEN  --Added on 5/23/00
			ls_customer := '8000000000';

		ELSIF ((grec_award.sponsor_code >= '000100') AND (grec_award.sponsor_code <= '000119'))THEN
			ls_customer := '8000000031';                           --The range added on 5/26/98

		ELSIF (grec_award.sponsor_code = '000120') THEN
			ls_customer := '8000000032';

		ELSIF (grec_award.sponsor_code = '000160') THEN
			ls_customer := '8000000005';

		ELSIF (grec_award.sponsor_code = '000211') THEN
			ls_customer := '8000000028';

		ELSIF (grec_award.sponsor_code = '000216') THEN  --This else block added on 6/27/07
			ls_customer := '8000000040';

        ELSIF (grec_award.sponsor_code = '000225') THEN  --This else block added on 6/27/07
            ls_customer := '8000000045';  --Changed to 45 from 41 as per steve

		ELSIF (grec_award.sponsor_code = '000600') THEN
			ls_customer := '8000000027';              --Changed to 8000000027 on 1/12/06 was 0007

		ELSIF (grec_award.sponsor_code = '000610') THEN
			ls_customer := '8000000006';

--		ELSIF (grec_award.sponsor_code = '000210') THEN    --This is commented out on 12/20/00
--			ls_customer := '8000000026';						   --This is commented out on 12/20/00

		ELSIF (grec_award.sponsor_code = '000220') THEN  --Added on 6/23/09   
			ls_customer := '8000000026';			

		ELSIF (grec_award.sponsor_code = '000205') THEN
			ls_customer := '8000000023';

		ELSIF (grec_award.sponsor_code = '000634') THEN
			ls_customer := '8000000001';

		ELSIF (grec_award.sponsor_code = '000212') THEN
			ls_customer := '8000000029';

		ELSIF (grec_award.sponsor_code = '000410') THEN
			ls_customer := '8000000011';

		ELSIF (grec_award.sponsor_code = '000400') THEN
			ls_customer := '8000000013';

		ELSIF (grec_award.sponsor_code = '000438') THEN
			ls_customer := '8000000010';

		ELSIF (grec_award.sponsor_code = '000432') THEN
			ls_customer := '8000000012';

		ELSIF (grec_award.sponsor_code = '000430') THEN
			ls_customer := '8000000008';

		ELSIF (grec_award.sponsor_code = '000420') THEN
			ls_customer := '8000000015';

		ELSIF (grec_award.sponsor_code = '000607') THEN   --Added on 02/04/02
			ls_customer := '8000000016';

		ELSIF (grec_award.sponsor_code = '000431') THEN
			ls_customer := '8000000014';

		ELSIF (grec_award.sponsor_code = '000411') THEN
			ls_customer := '8000000009';

		ELSIF (grec_award.sponsor_code = '000500') THEN
			ls_customer := '8000000020';

--		ELSIF (grec_award.sponsor_code = '000810') THEN  --Commented out for JIRA COEUSDEV-793
--			ls_customer := '8000000018';

		ELSIF (grec_award.sponsor_code = '000340') OR
				(grec_award.sponsor_code = '000360') THEN  --This OR condition added on 4/11/01
			ls_customer := '8000000017';

		ELSIF (grec_award.sponsor_code = '000688') THEN   
			ls_customer := '8000000002';

		ELSIF (grec_award.sponsor_code = '000618') THEN
			ls_customer := '8000000022';

        ELSIF (grec_award.sponsor_code = '000860') THEN  --JIRA COEUS-591 
            ls_customer := '8000000025';

		ELSIF (grec_award.sponsor_code = '000213') OR
				(grec_award.sponsor_code = '000215') THEN  --This OR condition added on 4/8/02
			ls_customer := '8000000003';

		ELSIF (grec_award.sponsor_code = '000651') THEN    --Added on 8/5/03
			ls_customer := '8000000024';


		ELSIF ((grec_award.sponsor_code = '000620')  OR   --Added on 5/23/00
				(grec_award.sponsor_code = '000780')) THEN   --Added on 5/23/00

			IF li_rolodex_id is NOT NULL THEN
				ls_customer := CONCAT('86', LTRIM(TO_CHAR(li_rolodex_id, '00000000')));
			END IF;

		ELSIF ((grec_award.sponsor_code >= '000141') AND (grec_award.sponsor_code <= '000149'))THEN
			ls_customer := '8000000004';                 --This conition added on 5/26/98

		END IF;

	ELSIF (grec_award.award_type_code = 1) THEN --This ELSIF added on 5/26/98

		IF ((grec_award.sponsor_code >= '000100') AND (grec_award.sponsor_code <= '000119'))THEN
			ls_customer := '8000000031';
		END IF;

	END IF;

--If a customer if not assigned by the above logic...

	IF ls_customer = '          ' THEN

		IF li_rolodex_id is NOT NULL THEN
			ls_customer := CONCAT('86', LTRIM(TO_CHAR(li_rolodex_id, '00000000')));
		END IF;

	END IF;

   return ls_customer;

/*===========================*/
end fn_get_customer;
/*===========================*/


/***************************************************************************/
--Calculate the auth total.
--auth_total = Obligated amount + cost sharing amount + underrecover of IDC
--After the change of 5/10/00 auth_total will be
--auth_total = Obligated amount + cost sharing amount

function fn_get_auth_total return number is
/***************************************************************************/

lc_auth_total number(12, 2);
lc_temp_amt   number(12, 2);
begin

lc_auth_total := gn_obligated_total;

IF lc_auth_total IS NULL THEN
	lc_auth_total := 0;
END IF;

--Should not add IDC to authorized total
--This change goes to production on 7/3/00


--Check if Costsharing exists for this sequence of the award.

--IF (SUBSTR(grec_award.cost_sharing_indicator , 1, 1) = 'P') THEN

  	SELECT SUM(AWARD_COST_SHARE.COMMITMENT_AMOUNT)
		INTO lc_temp_amt
    	FROM AWARD_COST_SHARE
		WHERE ( AWARD_COST_SHARE.AWARD_ID = gi_award_id ) AND
         	( AWARD_COST_SHARE.PROJECT_PERIOD <= gs_fiscal_year )   AND
			(SUBSTR(LTRIM(SOURCE), 1, 1) <> '0') ;      --SUBSTR condition added on 4/11/03

	IF lc_temp_amt IS NULL THEN
		lc_temp_amt := 0;
	END IF;

	lc_auth_total := lc_auth_total + lc_temp_amt;
--END IF;

return lc_auth_total;

/*===========================*/
end fn_get_auth_total;
/*===========================*/


/***************************************************************************/
function fn_format_name (as_old_name varchar2)  return varchar2 is
/***************************************************************************/

ls_new_name varchar2(30);
li_comma_position number;
li_Pos number;

begin

	ls_new_name := as_old_name;

--Remove any periods from the name
	ls_new_name := REPLACE(ls_new_name, '.');


	li_Pos :=  INSTR(UPPER(ls_new_name), ', PROF ');
	IF li_Pos <> 0 THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_Pos - 1)) ||
							' /' || LTRIM(SUBSTR(ls_new_name, li_Pos + 7 ));
		li_pos := 0;
	END IF;


	li_Pos :=  INSTR(UPPER(ls_new_name), ' JR,');
	IF li_Pos <> 0 THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_Pos - 1)) ||
							' /' || LTRIM(SUBSTR(ls_new_name, li_Pos + 4 ));
		li_pos := 0;
	END IF;

	li_Pos :=  INSTR(UPPER(ls_new_name), ' SR,');
	IF li_Pos <> 0 THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_Pos - 1)) ||
							' /' || LTRIM(SUBSTR(ls_new_name, li_Pos + 4 ));
		li_pos := 0;
	END IF;

	li_Pos :=  INSTR(UPPER(ls_new_name), ' II,');
	IF li_Pos <> 0 THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_Pos - 1)) ||
							' /' || LTRIM(SUBSTR(ls_new_name, li_Pos + 4 ));
		li_pos := 0;
	END IF;

	li_Pos :=  INSTR(UPPER(ls_new_name), ' III,');
	IF li_Pos <> 0 THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_Pos - 1)) ||
							' /' || LTRIM(SUBSTR(ls_new_name, li_Pos + 5 ));
		li_pos := 0;
	END IF;

--Check for IV added on 9/27/99

	li_Pos :=  INSTR(UPPER(ls_new_name), ' IV,');
	IF li_Pos <> 0 THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_Pos - 1)) ||
							' /' || LTRIM(SUBSTR(ls_new_name, li_Pos + 4 ));
		li_pos := 0;
	END IF;

	li_comma_position := 0;
	li_comma_position := INSTR(ls_new_name, ',');

   IF li_comma_position <> 0 THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_comma_position - 1)) ||
		' /' || LTRIM(SUBSTR(ls_new_name, li_comma_position + 1 ));
 	END IF;

--After all the formating if the new name ends with /
--remove / from the name. This happens when the person does not have a last name or
--middle initial

	ls_new_name := RTRIM(ls_new_name);
	li_pos := INSTR(ls_new_name, '/');
	IF li_pos = LENGTH(ls_new_name) THEN
		ls_new_name := RTRIM(SUBSTR(ls_new_name, 1, li_pos -1));
	END IF;

return (ls_new_name);

/*===========================*/
end fn_format_name;
/*===========================*/


/***************************************************************************/
--fn_format_room
--Function to format the address room.
--This function replaces the spaces in the address_room with a single '-'

function fn_format_room (as_old_room varchar2)  return varchar2 is
/***************************************************************************/


ls_old_room 			varchar2(10);
ls_new_room 			varchar2(10);
li_space_position 	number;

begin
	ls_old_room := LTRIM(RTRIM(SUBSTR(as_old_room, 1, 10)));

	li_space_position := INSTR(ls_old_room, ' ');

   IF li_space_position <> 0 THEN

		ls_new_room := RTRIM(SUBSTR(ls_old_room, 1, li_space_position - 1)) ||
		'-' || LTRIM(SUBSTR(ls_old_room, li_space_position + 1 ));

	ELSE
		ls_new_room := ls_old_room;
 	END IF;

return (ls_new_room);

/*===========================*/
end fn_format_room;
/*===========================*/


/***************************************************************************/
--fn_get_billing_type
--Function to translate billing mechanisms from Coeus into
--Billing_Types in SAP.

function fn_get_billing_type return varchar2 is
/***************************************************************************/

ls_BillingType 			Varchar2(2);

begin


	IF (grec_award.sponsor_code = '000651') THEN -- Added on 06/10/03

			ls_BillingType := '06';       --Changed from 05 to 06 on 8/4/03

	ELSIF 	((gs_account_number = '6892967')   OR        --Added on 7/17/02
         (gs_account_number = '6893962')  OR     --OR Added on 01/24/03
		 (gs_account_number = '6897021') OR      --OR Added on 10/19/06
		 (gs_account_number = '6898707') OR    --OR Added on 10/19/06
         (gs_account_number = '6922698') OR    --COEUSDEV-721
         (gs_account_number = '6898673') ) THEN --COEUSDEV-721
			ls_BillingType := '01';                      --Set to '01' on 10/09/02

	ELSIF ((gs_account_number = '6680100')   OR        --Added on 03/11/03
         (gs_account_number = '6763200')    OR        --Added on 03/11/03
			(gs_account_number = '6890057')) THEN        --Added on 03/11/03

			ls_BillingType := '02';

   ELSIF ((grec_award.sponsor_code = '000780') and   --Added on 11/10/2005
         (substr(gs_account_number ,1, 1) = '1')) then

            ls_BillingType := '01';

   ELSIF    ((grec_award.sponsor_code = '000200') OR
			(grec_award.sponsor_code = '000201') OR
			(grec_award.sponsor_code = '000202') OR
			(grec_award.sponsor_code = '000212') OR      --Added on 5/23/00
            (grec_award.sponsor_code = '000216') OR      --Added on 6/27/07
			(grec_award.sponsor_code = '000620') OR		--Added on 5/23/00
			(grec_award.sponsor_code = '000618') OR		--Added on 8/02/00
            (grec_award.sponsor_code = '000225') OR        --Added on 11/2/13  COEUS-633 
			(grec_award.sponsor_code = '000780'))	THEN	--Added on 5/23/00
--							AND												This condition commented out on 5/23/00
--			(grec_award.award_type_code = 1) THEN

			ls_BillingType := '06';

--Seperated the logic for sponsor code 000215 on 5/30/02

   ELSIF (grec_award.sponsor_code = '000215') THEN

			IF (grec_award.award_type_code = 1) OR (grec_award.award_type_code = 5) OR
				(grec_award.award_type_code = 7) THEN

				ls_BillingType := '06';
			ELSE
				ls_BillingType := '01';

			END IF;

	ELSIF (grec_award.sponsor_code = '005410') THEN  --Added on 12/09/02

			ls_BillingType := '01';

	ELSIF (grec_award.sponsor_code = '000682') THEN  --Added on 7/12/02. This was getting '06'

			ls_BillingType := '02';

   ELSIF (grec_award.sponsor_code = '000210') OR --Added on 10/17/02
         (grec_award.sponsor_code = '000220') THEN  --OR condition added on 6/23/09

			ls_BillingType := '06';

	ELSIF	((grec_award.sponsor_code = '000610')  OR
			(grec_award.sponsor_code = '000607') ) THEN   --Added on 02/04/02

			ls_BillingType := '06';

	ELSIF (grec_award.sponsor_code = '000634') AND
			(grec_award.award_type_code <> 7) THEN

			ls_BillingType := '06';

	ELSIF (grec_award.sponsor_code = '009001') THEN   --Added on 4/8/99

			ls_BillingType := '99';

	ELSIF (grec_award.sponsor_code = '005678') AND        --Added on 4/8/99
			(grec_award.account_type_code  = 3) THEN    --Added on 4/8/99 Changed on 11/23/99. We were checking
                                                            --for award_type_code = 7

			ls_BillingType := '99';

	ELSIF (grec_award.method_of_payment_code = 1 ) THEN --There were a bunch of sponsors here
                                                              --With and AND condition. All removed on 9/17/98
			ls_BillingType := '05';

	ELSIF (grec_award.method_of_payment_code IN (2, 13, 14, 18) )  THEN   -- 18 added for COEUSDEV-1018

			ls_BillingType := '01';

	ELSIF (grec_award.method_of_payment_code = 9 ) THEN --There were a bunch of sponsor codes here
                                                              --with an OR condition. They are all removed on 5/26/98
			ls_BillingType := '02';

	ELSIF (grec_award.method_of_payment_code = 6 ) THEN

			ls_BillingType := '04';

	ELSIF (grec_award.method_of_payment_code =  12 ) THEN

			ls_BillingType := '99';

	ELSIF ((grec_award.method_of_payment_code = 3 ) OR
			(grec_award.method_of_payment_code = 5 ) OR
			(grec_award.method_of_payment_code = 7 ) OR
			(grec_award.method_of_payment_code = 11 )) THEN

			ls_BillingType := '03';

	ELSIF (grec_award.method_of_payment_code = 8 )
								AND
			((grec_award.sponsor_code = '000124') OR
			(grec_award.sponsor_code = '000120') OR	--This sponsor added on 3/19/02
			(grec_award.sponsor_code = '000106') OR
			(grec_award.sponsor_code = '002080') OR
			(grec_award.sponsor_code = '007350') OR
			(grec_award.sponsor_code = '002067') OR
			(grec_award.sponsor_code = '000634') OR
			(grec_award.sponsor_code = '007384')) THEN

			ls_BillingType := '07';

	ELSIF (grec_award.award_type_code = 7 ) OR
			(grec_award.award_type_code = 11 ) THEN

			ls_BillingType := '99';

	ELSIF (grec_award.basis_of_payment_code = 2) AND            --Added on 4/2/01
			(grec_award.method_of_payment_code = 10) THEN         --Added on 4/2/01

			ls_BillingType := '01';													--Added on 4/2/01
	ELSE

			ls_BillingType := '98';

	END IF;

Return (ls_BillingType);

/*===========================*/
end fn_get_billing_type;
/*===========================*/


/***************************************************************************/
--fn_get_billing_form

function fn_get_billing_form return varchar2 is
/***************************************************************************/

ls_BillingForm 			Varchar2(2);

/*****
A bunch of hard codes is deleted on 8/13/03
All hardcoded accounts that were getting F2 thru G9 will now get G1
Based on method of payment code -
Get Version 1.34 from PVCS to see hardcodes that were removed
******/

begin

	ls_BillingForm := '  ';   --2 Spaces

	IF (grec_award.sponsor_code = '000651') THEN -- Added on 06/10/03

		ls_BillingForm := '99';

	ELSIF ( to_number(gs_account_number) >= 1880000) and ( to_number(gs_account_number) <= 1880499 )  THEN  --Case COEUS-327 - added on 3/5/13
        
          ls_BillingForm := 'C1';
          
    ELSIF (gs_account_number = '6897021') OR (gs_account_number = '6898707')    --Account number specific logic added on 10/19/06
		  OR (gs_account_number = '6334400')                                --This account added on 7/5/07 , this hard code used to be further down in the logic
          OR (gs_account_number = '6922249')                       --This account added on 9/28/10 COEUSDEV-619
          OR  (gs_account_number = '6922698')          --COEUSDEV-721
          OR (gs_account_number = '6898673') THEN      --COEUSDEV-721 
          
		ls_BillingForm := 'C1';

	ELSIF (gs_account_number = '6890870') THEN   --Account number specific logic added on 7/17/02

		ls_BillingForm := 'C2';

	ELSIF (gs_account_number = '6893430') THEN         --Added on 11/1/02

		ls_BillingForm := 'C3';                         --Was C2, changed to C3 on 11/7/02

	ELSIF gs_account_number IN ('6893432', '6893434', '6893444', '6893445',
										 '6893446', '6893447', '6893448', '6893449',   --Added on 11/1/02
										 '6893653', '6896583', '6897250', '6897251', '6897253', '6897254', -- Added on 8/4/05
										 '6897255', '6897256', '6897257', '6897258', '6897320', '6897966' )  THEN -- Added on 8/4/05
		ls_BillingForm := 'C4';

	ELSIF ((gs_account_number = '6892967') OR           --Added on 10/09/02
		  (grec_award.method_of_payment_code = 19 )) THEN  -- Added on 3/30/2006

		ls_BillingForm := 'A1';

	ELSIF ((gs_account_number = '6680100') OR 				--Added on 03/11/03
			(gs_account_number = '6763200') OR
         (gs_account_number = '6890057')) THEN

		ls_BillingForm := 'H1';

	ELSIF ((grec_award.sponsor_code = '009001') OR   --Added on 4/8/99
		(grec_award.sponsor_code = '000200') OR   --Added on 5/23/00
		(grec_award.sponsor_code = '000201') OR   --Added on 5/23/00
		(grec_award.sponsor_code = '000202') OR   --Added on 5/23/00
		(grec_award.sponsor_code = '000212') OR   --Added on 5/23/00
		(grec_award.sponsor_code = '000216') OR   --Added on 6/27/07
		(grec_award.sponsor_code = '000618') OR   --Added on 8/02/00
		(grec_award.sponsor_code = '000620') OR   --Added on 5/23/00
        (grec_award.sponsor_code = '000225') OR   --Added on 11/27/13 - COEUSQA-633 
		((grec_award.sponsor_code = '000780') and (substr(gs_account_number, 1, 1) <> '1')) OR   --Added on 5/23/00
	   (grec_award.sponsor_code = '000607') ) THEN --Added on 02/04/02

			ls_BillingForm := '99';

	ELSIF (grec_award.sponsor_code = '005678') AND        --Added on 4/8/99
			(grec_award.account_type_code  = 3) THEN    --Added on 4/8/99, Changed on 23/11/99. We were checking for
                                                            -- award_type_code = 7

			ls_BillingForm := '99';

	ELSIF (grec_award.method_of_payment_code = 1 ) THEN  --We were checking for some sponsors here
		ls_BillingForm := '99';                               --Removed it on 5/26/98

	ELSIF (grec_award.method_of_payment_code = 13 ) THEN --We were checking for some sponsors here
		ls_BillingForm := 'E1';                                  --Removed it on 5/26/98

	ELSIF (grec_award.method_of_payment_code = 12 ) THEN
		ls_BillingForm := '99';

	ELSIF (grec_award.method_of_payment_code = 14 ) THEN
		ls_BillingForm := 'G1';


	ELSIF (grec_award.award_type_code = 1) AND           --The range added on 5/26/98
			((grec_award.sponsor_code >= '000140') AND (grec_award.sponsor_code <= '000149')) THEN

		ls_BillingForm := 'I1';

	ELSIF (grec_award.method_of_payment_code = 9 ) THEN   --USed to check for (AND award_type = 1)
                                                                --Changed on 5/26/98
		ls_BillingForm := 'H1';

/***************************************************************************
--Commented out on 3/19/02
	ELSIF ((grec_award.award_type_code = 3) AND             --New Condition added on 9/17/98
			(grec_award.sponsor_code = '007360')) OR
			(gs_account_number = '6334400')  THEN                    --Acct number logic added on 10/06/98
***************************************************************************/

	ELSIF ((grec_award.award_type_code <> 8) AND             --ELSEIF condition added on 3/19/02
			((grec_award.sponsor_code = '007360') OR
		    (grec_award.sponsor_code = '007380') ))  THEN

		ls_BillingForm := 'C1';

	ELSIF (gi_sponsor_type = 0) AND
			(grec_award.award_type_code = 3) AND
			( ((grec_award.sponsor_code >= '000100') AND (grec_award.sponsor_code <= '000199')) OR
			  ((grec_award.sponsor_code >= '000400') AND (grec_award.sponsor_code <= '000499')) ) THEN

		ls_BillingForm := 'D1';

	ELSIF (gi_sponsor_type IN  (0, 1, 2) ) AND
			(grec_award.award_type_code in (3, 4))  THEN   --Added 4 in COEUS-699

		ls_BillingForm := 'A3';


	ELSIF (gi_sponsor_type > 2) AND
			(grec_award.method_of_payment_code in (2, 18) ) THEN  -- added 18 for coeusdev-1018

		ls_BillingForm := 'F1';

	ELSIF (grec_award.award_type_code = 3) AND
			(grec_award.method_of_payment_code > 2 ) THEN

		ls_BillingForm := '99';

	ELSE
		ls_BillingForm := '98';
	END IF;


Return (ls_BillingForm);

/*===========================*/
end fn_get_billing_form;
/*===========================*/

/***************************************************************************/
--fn_is_in
--Function to check if a given numeric value is present in the table at_table
--Returns true if the number is present else false

function fn_is_in(ai_value in number, at_table in FreqTabType) return boolean is
/***************************************************************************/

lb_Return 			BOOLEAN := FALSE;
li_Index 			NUMBER;
li_Count 			NUMBER;


begin

	li_Count := at_table.Count;

	FOR li_Index IN 1..li_Count LOOP
		IF at_table(li_Index) = ai_value THEN
			lb_Return := TRUE;
			EXIT;
		END IF;
	END LOOP;

Return lb_Return;

/*===========================*/
end fn_is_in;
/*===========================*/


/***************************************************************************/
--fn_generate_comment1
--Function to generate a comment string. which will be used
--in Comment1 coulmnn of the feed
--A comment line will be generated of the form 'Change in: ******'
--Where ****** will be 'Cost Sharing, IDC, Payment Schedule, Billing'

function fn_generate_comment1  return varchar2 is
/***************************************************************************/


ls_Comment	 			varchar2(60);
li_Count					NUMBER;

begin

	ls_Comment := 'COEUS Change In: ';

--Check if there is a change in Indirect Cost
--	IF (SUBSTR(grec_award.fy_recover_idc_indicator, 2, 1) = '1') THEN (3.0)

		select count(*) into li_Count from (           
			select applicable_idc_rate,idc_rate_type_code,fiscal_year,
			on_campus_flag,underrecovery_of_idc,source_account,destination_account,start_date,decode(end_date,null,'0',end_date) as  end_date
			from award_idc_rate INNER JOIN AWARD  on award_idc_rate.AWARD_ID = AWARD.AWARD_ID 
			where award_idc_rate.award_number = gs_award_number 
			and award_idc_rate.sequence_number = gi_sequence_number
			and AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED'
			
			minus           
			 select applicable_idc_rate,idc_rate_type_code,fiscal_year,
			on_campus_flag,underrecovery_of_idc,source_account,destination_account,start_date,decode(end_date,null,'0',end_date) as  end_date
			from award_idc_rate INNER JOIN AWARD  on award_idc_rate.AWARD_ID = AWARD.AWARD_ID 
			where award_idc_rate.award_number = gs_award_number 
			and award_idc_rate.sequence_number = ( gi_sequence_number - 1 )   
			and AWARD.AWARD_SEQUENCE_STATUS <> 'CANCELED'	
			
		) idc_rate ;       

		IF li_Count > 0 THEN
			ls_Comment := ls_Comment || 'IDC ';
		END IF;

--Check if there is a change in CostSharing
		select count(*) into li_Count from (  
			select decode(verification_date,null,'0',verification_date) verification_date,decode(cost_share_met,null,'0',cost_share_met) cost_share_met,
			decode(project_period,null,'0',project_period) project_period, decode(cost_share_percentage,null,'0',cost_share_percentage) cost_share_percentage,
			decode(cost_share_type_code,null,'0',cost_share_type_code) cost_share_type_code,decode(source,null,'0',source) source,
			decode(destination,null,'0',destination) destination, decode(commitment_amount,null,'0',commitment_amount) commitment_amount,
			decode(unit_number,null,'0',unit_number) unit_number
			from award_cost_share inner join award  on award_cost_share.award_id = award.award_id
			where award_cost_share.award_number = gs_award_number 
			and award_cost_share.sequence_number = gi_sequence_number
			and award.award_sequence_status <> 'CANCELED'
		minus
			select decode(verification_date,null,'0',verification_date) verification_date,decode(cost_share_met,null,'0',cost_share_met) cost_share_met,
			decode(project_period,null,'0',project_period) project_period, decode(cost_share_percentage,null,'0',cost_share_percentage) cost_share_percentage,
			decode(cost_share_type_code,null,'0',cost_share_type_code) cost_share_type_code,decode(source,null,'0',source) source,
			decode(destination,null,'0',destination) destination, decode(commitment_amount,null,'0',commitment_amount) commitment_amount,
			decode(unit_number,null,'0',unit_number) unit_number
			from award_cost_share  inner join award  on award_cost_share.award_id = award.award_id
			where award_cost_share.award_number = gs_award_number
			and award_cost_share.sequence_number = ( gi_sequence_number - 1 )
			and award.award_sequence_status <> 'CANCELED'			
		) cost_share;

		IF li_Count > 0 THEN
			ls_Comment := ls_Comment || 'Cost Sharing ';
		END IF;

--Check if there is a change in Payment Schedule

	
--Check if there is invoice instructions for this sequence number.
	select count(*) into li_Count from (  
		select decode(due_date,null,'0',due_date) due_date,decode(amount,null,'0',amount) amount,decode(submit_date,null,'0',submit_date) submit_date,
		decode(submitted_by,null,'0',submitted_by) submitted_by,decode(invoice_number,null,'0',invoice_number) invoice_number,
		decode(status_description,null,'0',status_description) status_description,decode(status,null,'0',status) status,
		decode(overdue,null,'0',overdue) overdue,decode(report_status_code,null,'0',report_status_code) report_status_code,
		decode(submitted_by_person_id,null,'0',submitted_by_person_id) submitted_by_person_id,
		decode(award_report_term_desc,null,'0',award_report_term_desc) award_report_term_desc
		from award_payment_schedule  inner join award  on award_payment_schedule.award_id = award.award_id
		where award_payment_schedule.award_number = gs_award_number 
		and award_payment_schedule.sequence_number = gi_sequence_number
		and award.award_sequence_status <> 'CANCELED'
			minus
			
		select decode(due_date,null,'0',due_date) due_date,decode(amount,null,'0',amount) amount,decode(submit_date,null,'0',submit_date) submit_date,
		decode(submitted_by,null,'0',submitted_by) submitted_by,decode(invoice_number,null,'0',invoice_number) invoice_number,
		decode(status_description,null,'0',status_description) status_description,decode(status,null,'0',status) status,
		decode(overdue,null,'0',overdue) overdue,decode(report_status_code,null,'0',report_status_code) report_status_code,
		decode(submitted_by_person_id,null,'0',submitted_by_person_id) submitted_by_person_id,
		decode(award_report_term_desc,null,'0',award_report_term_desc) award_report_term_desc
		from award_payment_schedule   inner join award  on award_payment_schedule.award_id = award.award_id
		where award_payment_schedule.award_number = gs_award_number 
		and award_payment_schedule.sequence_number = (gi_sequence_number-1)
		and award.award_sequence_status <> 'CANCELED'
		)	payment_schedule;

		IF li_Count > 0 THEN
			ls_Comment := ls_Comment || 'Payment Schedule ';
		END IF;

	SELECT COUNT(AWARD_NUMBER)
   		 INTO li_Count
  		  FROM AWARD_COMMENT
  		 WHERE ( AWARD_COMMENT.AWARD_ID = gi_award_id ) AND       	 
				 ( AWARD_COMMENT.COMMENT_TYPE_CODE = '1') ;

	IF li_Count > 0 THEN
		ls_Comment := ls_Comment || 'Billing';
	END IF;

	IF ls_Comment = 'COEUS Change In: ' THEN
		ls_Comment := '-';
	END IF;

return (ls_Comment);

/*===========================*/
end fn_generate_comment1;
/*===========================*/

/***************************************************************************/
--fn_get_cost_share

function fn_get_cost_share return varchar2 is
/***************************************************************************/

ls_CostShare 			Varchar2(1);
li_Count					NUMBER;
ls_Comment				award_comment.comments%type;

begin

	ls_CostShare := '1';


--	IF SUBSTR(grec_award.cost_sharing_indicator, 1, 1) = 'P' THEN

		select count(award_number)
		into li_count
		from award_cost_share
		where award_id = gi_award_id and
				cost_share_type_code = 2;

		IF li_Count > 0 THEN
			ls_CostShare := '2';
			Return (ls_CostShare);
		END IF;

		select count(award_number)
		into li_count
		from award_cost_share
		where award_id = gi_award_id and
		cost_share_type_code = 3;

		IF li_Count > 0 THEN
			ls_CostShare := '3';
			Return (ls_CostShare);
		END IF;

		select count(award_number)
		into li_count
		from award_cost_share
		where award_id = gi_award_id and			
				cost_share_type_code = 4;

		IF li_Count > 0 THEN
			ls_CostShare := '4';
			Return (ls_CostShare);
		END IF;

		select count(award_number)
		into li_count
		from award_cost_share
		where award_id = gi_award_id and				
				cost_share_type_code = 5;

		IF li_Count > 0 THEN
			ls_CostShare := '2';
			Return (ls_CostShare);
		END IF;

		select count(award_number)
		into li_count
		from award_cost_share
		where award_id = gi_award_id and			
				cost_share_type_code = 6;

		IF li_Count > 0 THEN
			ls_CostShare := '3';
			Return (ls_CostShare);
		END IF;

		select count(award_number)
		into li_count
		from award_cost_share
		where award_id = gi_award_id and				
				cost_share_type_code = 7;

		IF li_Count > 0 THEN
			ls_CostShare := '4';
			Return (ls_CostShare);
		END IF;

		select count(award_number)
		into li_count
		from award_cost_share
		where award_id = gi_award_id and				
				cost_share_type_code = 1;

		IF li_Count > 0 THEN
			ls_CostShare := '5';
			Return (ls_CostShare);
		END IF;

	--ELSE   --IF indicator is N0 or N1
		--There are no cost sharing rows, but check to see if there is a cost sharing comment
		-- if cost sharing comment exists set cost_share to 5 else set to 1

		begin
			select comments
			into ls_comment
			from award_comment
			where award_id = gi_award_id and				
				comment_type_code = 9;

			IF ls_comment is null then
				ls_CostShare := '1';
			else
				ls_CostShare := '5';
			end if;

		exception
			when others then
				ls_CostShare := '1';
				Return (ls_CostShare);
		end;

--	END IF;


Return (ls_CostShare);

/*===========================*/
end fn_get_cost_share;
/*===========================*/

/***************************************************************************/
--fn_get_custom_element_value
--Function to retrieve value of a custom element

function fn_get_custom_element_value (as_CustomElement in
		 							 custom_attribute.NAME%TYPE)  return varchar2 is
/***************************************************************************/


ls_Value	 			varchar2(2000);

begin

	ls_Value := ' ';

	select value
		into ls_Value
		from award_custom_data, custom_attribute, award
		where award_custom_data.custom_attribute_id=custom_attribute.id
		and award.award_id = award_custom_data.award_id
		and award.award_sequence_status <> 'CANCELED'
		and  award_custom_data.award_number = gs_award_number and
		      upper(custom_attribute.name) = upper( as_CustomElement ) and
				award_custom_data.sequence_number = (select max(ac.sequence_number) from
										 award_custom_data ac
										 where award_custom_data.award_number = ac.award_number and
										 ac.sequence_number <= gi_sequence_number);


return (ls_Value);

exception
	when others then
		ls_Value := ' ';
		return (ls_Value);

/*=============================*/
end fn_get_custom_element_value ;
/*=============================*/

/*===========================*/
end kc_sap_feed_pkg;
/*===========================*/
/