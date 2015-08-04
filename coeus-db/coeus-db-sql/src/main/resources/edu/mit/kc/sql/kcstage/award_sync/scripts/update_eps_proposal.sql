select ' Started insert to EPS_PROPOSAL ' from dual
/
DECLARE
ls_submit_flag CHAR(1):='N';
ls_is_hierarchy CHAR(1):='N';
ls_hierarchy_prop_num VARCHAR2(12):=null;
ls_hierarchy_hash_cd NUMBER(10,0):=null;
ls_hierarchy_bgt_typ CHAR(1);
li_child_type_code	NUMBER(3,0);
ls_hierarchy_orig_child VARCHAR2(12):=null;
ls_doc_nbr VARCHAR2(40);
li_ver_nbr number:=1;
li_loop_count number;
li_loop_error_count number;
ls_proposal_num varchar2(20);
ls_proposal_type_cd VARCHAR2(3);
li_status_cd NUMBER(3,0);
ls_budget_status varchar2(2);
li_budget_status_cd number;
ls_cfda_num VARCHAR2(7);
li_hier_count number;


CURSOR c_eps_proposal IS
SELECT OSP$EPS_PROPOSAL.* FROM OSP$EPS_PROPOSAL@coeus.kuali INNER JOIN TEMP_TAB_TO_SYNC_DEV t on OSP$EPS_PROPOSAL.PROPOSAL_NUMBER = t.PROPOSAL_NUMBER 
WHERE t.FEED_TYPE = 'C' ;
r_eps_proposal c_eps_proposal%ROWTYPE;

BEGIN
IF c_eps_proposal%ISOPEN THEN
CLOSE c_eps_proposal;
END IF;
OPEN c_eps_proposal;
li_loop_count:=0;
li_loop_error_count:=0;
execute immediate('ALTER TABLE EPS_PROPOSAL DISABLE CONSTRAINT EPS_PROPOSAL_FK1');
LOOP
FETCH c_eps_proposal INTO r_eps_proposal;
EXIT WHEN c_eps_proposal%NOTFOUND;



	BEGIN
	SELECT  to_number(parent_proposal_number) INTO ls_hierarchy_prop_num FROM osp$eps_proposal_hierarchy@coeus.kuali WHERE child_proposal_number = (r_eps_proposal.PROPOSAL_NUMBER);
	ls_is_hierarchy:='C';
	EXCEPTION
	WHEN OTHERS THEN	
	SELECT  count(to_number(child_proposal_number)) INTO li_hier_count FROM osp$eps_proposal_hierarchy@coeus.kuali WHERE parent_proposal_number = (r_eps_proposal.PROPOSAL_NUMBER); 
	ls_hierarchy_prop_num:=NULL;
	ls_is_hierarchy:='N';
	if li_hier_count > 0 then
	ls_is_hierarchy := 'P';
	end if;

	END;   
 
--hierarchy budget type
	BEGIN
	SELECT  child_type_code INTO li_child_type_code FROM osp$eps_proposal_hierarchy@coeus.kuali WHERE child_proposal_number = (r_eps_proposal.PROPOSAL_NUMBER);
	if   li_child_type_code=1 then
	ls_hierarchy_bgt_typ:='B';
	else
	ls_hierarchy_bgt_typ:='P';
	end if;     
	EXCEPTION
	WHEN OTHERS THEN
	ls_hierarchy_bgt_typ:=NULL;   
	END;    
-- proposal_type code
	ls_proposal_type_cd := r_eps_proposal.PROPOSAL_TYPE_CODE;
/*
if    r_eps_proposal.PROPOSAL_TYPE_CODE=1 then
ls_proposal_type_cd:='1';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=3 then
ls_proposal_type_cd:='4';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=4 then
ls_proposal_type_cd:='5';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=5 then
ls_proposal_type_cd:='3';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=6 then
ls_proposal_type_cd:='2';
elsif r_eps_proposal.PROPOSAL_TYPE_CODE=9 then
ls_proposal_type_cd:='6';
end if; 
*/     
/*
mapping of coeus -Kc status code
				KC
4	Approved	13
3	Rejected	12
1	In Progress	1
2	Approval In Progress	2
5	Submitted	6
6	Post-Submission Approval	8
7	Post-Submission Rejection	9
8	Recalled	12
*/
	li_status_cd:=r_eps_proposal.CREATION_STATUS_CODE; 
	if    li_status_cd = 4 then li_status_cd := 13;
	elsif li_status_cd = 3 then li_status_cd := 12;
	elsif li_status_cd = 5 then li_status_cd := 6;
	elsif li_status_cd = 6 then li_status_cd := 8;
	elsif li_status_cd = 7 then li_status_cd := 9;
	elsif li_status_cd = 8 then li_status_cd := 12;
	end if;

	ls_cfda_num:=r_eps_proposal.CFDA_NUMBER;  

	if  ls_cfda_num IS NOT NULL then         
	select substr(trim(ls_cfda_num),1,2)||'.'||substr(trim(ls_cfda_num),3) into ls_cfda_num from dual;
	end if;

	BEGIN
	select to_number(r_eps_proposal.PROPOSAL_NUMBER) into ls_proposal_num from dual;    
	
	UPDATE	EPS_PROPOSAL SET
			SUBMIT_FLAG = ls_submit_flag,
			IS_HIERARCHY = ls_is_hierarchy,
			HIERARCHY_PROPOSAL_NUMBER = ls_hierarchy_prop_num,	
			HIERARCHY_BUDGET_TYPE	=	ls_hierarchy_bgt_typ,
			PROGRAM_ANNOUNCEMENT_NUMBER = r_eps_proposal.PROGRAM_ANNOUNCEMENT_NUMBER,
			PROGRAM_ANNOUNCEMENT_TITLE = r_eps_proposal.PROGRAM_ANNOUNCEMENT_TITLE,
			ACTIVITY_TYPE_CODE = r_eps_proposal.ACTIVITY_TYPE_CODE,
			REQUESTED_START_DATE_INITIAL = r_eps_proposal.REQUESTED_START_DATE_INITIAL,
			REQUESTED_START_DATE_TOTAL = r_eps_proposal.REQUESTED_START_DATE_TOTAL,
			REQUESTED_END_DATE_INITIAL = r_eps_proposal.REQUESTED_END_DATE_INITIAL,
			REQUESTED_END_DATE_TOTAL = r_eps_proposal.REQUESTED_END_DATE_TOTAL,
			DURATION_MONTHS = r_eps_proposal.DURATION_MONTHS,
			NUMBER_OF_COPIES = r_eps_proposal.NUMBER_OF_COPIES,
			DEADLINE_DATE = r_eps_proposal.DEADLINE_DATE,
			DEADLINE_TYPE = r_eps_proposal.DEADLINE_TYPE,
			MAILING_ADDRESS_ID = r_eps_proposal.MAILING_ADDRESS_ID,
			MAIL_BY = r_eps_proposal.MAIL_BY,
			MAIL_TYPE = r_eps_proposal.MAIL_TYPE,
			CARRIER_CODE_TYPE = r_eps_proposal.CARRIER_CODE_TYPE,
			CARRIER_CODE = r_eps_proposal.CARRIER_CODE,
			MAIL_DESCRIPTION = r_eps_proposal.MAIL_DESCRIPTION,
			SUBCONTRACT_FLAG = r_eps_proposal.SUBCONTRACT_FLAG,
			NARRATIVE_STATUS = r_eps_proposal.NARRATIVE_STATUS,
			BUDGET_STATUS = r_eps_proposal.BUDGET_STATUS,
			OWNED_BY_UNIT = r_eps_proposal.OWNED_BY_UNIT,
			UPDATE_TIMESTAMP = r_eps_proposal.UPDATE_TIMESTAMP,
			UPDATE_USER = r_eps_proposal.UPDATE_USER,
			NSF_CODE = r_eps_proposal.NSF_CODE,
			PRIME_SPONSOR_CODE = r_eps_proposal.PRIME_SPONSOR_CODE,
			CFDA_NUMBER = ls_cfda_num,
			AGENCY_PROGRAM_CODE = r_eps_proposal.AGENCY_PROGRAM_CODE,
			AGENCY_DIVISION_CODE = r_eps_proposal.AGENCY_DIVISION_CODE,
			PROPOSAL_TYPE_CODE = ls_proposal_type_cd,
			STATUS_CODE = li_status_cd,
			CREATION_STATUS_CODE = r_eps_proposal.CREATION_STATUS_CODE,
			BASE_PROPOSAL_NUMBER = r_eps_proposal.BASE_PROPOSAL_NUMBER,
			CONTINUED_FROM = r_eps_proposal.CONTINUED_FROM,
			TEMPLATE_FLAG = r_eps_proposal.TEMPLATE_FLAG,
			ORGANIZATION_ID = r_eps_proposal.ORGANIZATION_ID,
			PERFORMING_ORGANIZATION_ID = r_eps_proposal.PERFORMING_ORGANIZATION_ID,
			CURRENT_ACCOUNT_NUMBER = r_eps_proposal.CURRENT_ACCOUNT_NUMBER,
			CURRENT_AWARD_NUMBER = REPLACE(trim(r_eps_proposal.CURRENT_AWARD_NUMBER),'-','-00'),
			TITLE = SUBSTRB(r_eps_proposal.TITLE,1,150),
			SPONSOR_CODE = r_eps_proposal.SPONSOR_CODE,
			SPONSOR_PROPOSAL_NUMBER = r_eps_proposal.SPONSOR_PROPOSAL_NUMBER,
			INTR_COOP_ACTIVITIES_FLAG = r_eps_proposal.INTR_COOP_ACTIVITIES_FLAG,
			INTR_COUNTRY_LIST = r_eps_proposal.INTR_COUNTRY_LIST,
			OTHER_AGENCY_FLAG = r_eps_proposal.OTHER_AGENCY_FLAG,
			NOTICE_OF_OPPORTUNITY_CODE = r_eps_proposal.NOTICE_OF_OPPORTUNITY_CODE,
			HIERARCHY_ORIG_CHILD_PROP_NBR = ls_hierarchy_orig_child,
			ANTICIPATED_AWARD_TYPE_CODE = r_eps_proposal.AWARD_TYPE_CODE
	  WHERE PROPOSAL_NUMBER = ls_proposal_num;
	
	EXCEPTION 
	WHEN OTHERS THEN
		dbms_output.put_line('Error while updating proposal(EPS_PROPOSAL) '||r_eps_proposal.PROPOSAL_NUMBER||' and exception is '||substr(sqlerrm,1,200));
	END;


	BEGIN     

		ls_budget_status :=r_eps_proposal.BUDGET_STATUS; 
		if    ls_budget_status ='C' then
		li_budget_status_cd:=1;
		elsif ls_budget_status ='I' then
		li_budget_status_cd:=2;
		elsif ls_budget_status ='N' then
		li_budget_status_cd:=null;       
		else
		li_budget_status_cd:=null;
		end if;  

		UPDATE EPS_PROPOSAL_BUDGET_STATUS SET
		BUDGET_STATUS_CODE = li_budget_status_cd ,
		UPDATE_TIMESTAMP = r_eps_proposal.UPDATE_TIMESTAMP,
		UPDATE_USER = r_eps_proposal.UPDATE_USER
		WHERE PROPOSAL_NUMBER = to_number(r_eps_proposal.PROPOSAL_NUMBER);	
	

	EXCEPTION 
	WHEN OTHERS THEN     
	dbms_output.put_line('Error while updating EPS_PROPOSAL_BUDGET_STATUS , proposal number is '||ls_proposal_num||' and exception is '||substr(sqlerrm,1,200));
	END; 
------------------- KREW-------------------- 

END LOOP;
CLOSE c_eps_proposal;  
execute immediate('ALTER TABLE EPS_PROPOSAL ENABLE CONSTRAINT EPS_PROPOSAL_FK1');
EXCEPTION
WHEN OTHERS THEN
dbms_output.put_line('Error while updating EPS_PROPOSAL or EPS_PROPOSAL_DOCUMENT  and exception is '||substr(sqlerrm,1,200));
END;
/
select ' Ended updating EPS_PROPOSAL ' from dual
/
commit
/