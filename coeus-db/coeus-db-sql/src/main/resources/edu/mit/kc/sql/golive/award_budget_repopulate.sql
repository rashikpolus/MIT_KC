DELETE FROM AWARD_BUDGET_DETAILS_EXT where BUDGET_DETAILS_ID in ( SELECT BUDGET_DETAILS_ID FROM BUDGET_DETAILS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping))
/
DELETE FROM AWARD_BUDGET_PERIOD_EXT where BUDGET_PERIOD_NUMBER in ( SELECT BUDGET_PERIOD_NUMBER FROM BUDGET_PERIODS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping) )
/
DELETE FROM AWARD_BUDGET_LIMIT where BUDGET_ID in (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM AWARD_BUDGET_LIMIT where AWARD_ID in (select prod_award_id from go_live_awd_bgt_mapping)
/
DELETE FROM AWARD_BUDGET_EXT where budget_id in (select PROD_BUDGET_ID from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_RATE_AND_BASE WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PER_DET_RATE_AND_BASE WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERSON_SALARY_DETAILS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERSONNEL_CAL_AMTS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERSONNEL_DETAILS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_DETAILS_CAL_AMTS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_MODULAR_IDC WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_DETAILS WHERE BUDGET_details_id IN (select prod_budget_details_id from go_live_bud_detail_mapping)
/
DELETE FROM BUDGET_PERSONS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_MODULAR WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERIODS WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET WHERE BUDGET_ID IN (select prod_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_DOCUMENT WHERE DOCUMENT_NUMBER IN (select prod_bud_doc_id from go_live_awd_bgt_mapping)
/
truncate table go_live_awd_bgt_mapping
/
truncate table go_live_bud_detail_mapping
/
truncate table go_live_bud_period_mapping
/
truncate table go_live_bud_person_mapping
/
--create table go_live_awd_bgt_mapping(
--stage_budget_id number(12,0),
--stage_award_id number(22,0),
--stage_bud_doc_id varchar2(40),
--prod_budget_id number(12,0),
--prod_award_id number(22,0),
--prod_bud_doc_id varchar2(40),
--prod_old_budget_id number(12,0),
--prod_old_bud_doc_id varchar2(40),
--award_number varchar2(12),
--sequence_number number(4,0)
--)
--/
--create table go_live_bud_detail_mapping(
--stage_budget_details_id NUMBER(12,0),
--prod_budget_details_id NUMBER(12,0)
--)
--/
--create table go_live_bud_period_mapping(
--stage_budget_period_number NUMBER(12,0),
--prod_budget_period_number NUMBER(12,0)
--)
--/
--create table go_live_bud_person_mapping(
--stage_person_sequence_num NUMBER(3,0),
--stage_budget_id number(12,0),
--prod_budget_id number(12,0),
--prod_person_sequence_num NUMBER(3,0)
--)
--/
declare
  cursor c_data is
  select t1.budget_id,t1.award_id,t2.award_number,t2.sequence_number,t3.document_number from award_budget_ext@KC_STAG_DB_LINK t1
  inner join award@KC_STAG_DB_LINK t2 on t1.award_id = t2.award_id
  inner join budget@KC_STAG_DB_LINK t3 on t1.budget_id = t3.budget_id;
  r_data c_data%rowtype; 
  li_count pls_integer;
  li_award_id award.award_id%type;
  li_old_budget_id number(12,0);
  ls_old_document_number varchar2(40);
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
    begin
      select award_id into li_award_id 
      from award  where award_number = r_data.award_number  and sequence_number = r_data.sequence_number;
      
    exception
    when others then
     li_award_id := 0;
    end;
    
    if li_award_id <> 0 then
      begin
        select t1.budget_id,t2.document_number into li_old_budget_id,ls_old_document_number
        from award_budget_ext t1  
        inner join budget t2 on t1.budget_id = t2.budget_id
        WHERE t1.award_id = li_award_id; 
    exception
    when others then
     li_old_budget_id := null;
     ls_old_document_number := null;
    end;  
    
      INSERT INTO go_live_awd_bgt_mapping(
          stage_budget_id,
          stage_award_id,
          stage_bud_doc_id,  
          prod_budget_id,
          prod_award_id,
          prod_bud_doc_id,
		  prod_old_budget_id,
		  prod_old_bud_doc_id,
          award_number,
          sequence_number
      )
      VALUES(
        r_data.budget_id,
        r_data.award_id,
        r_data.document_number,
        seq_budget_id.nextval,
        li_award_id,
        krew_doc_hdr_s.nextval,
		li_old_budget_id,
		ls_old_document_number,
        r_data.award_number,
        r_data.sequence_number        
      );
    
    end if;
  
  end loop;
  close c_data;

end;
/
DELETE FROM AWARD_BUDGET_EXT where budget_id in (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM AWARD_BUDGET_LIMIT where BUDGET_ID in (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM AWARD_BUDGET_LIMIT where AWARD_ID in (select prod_award_id from go_live_awd_bgt_mapping)
/
DELETE FROM AWARD_BUDGET_PERIOD_EXT where BUDGET_PERIOD_NUMBER in ( SELECT BUDGET_PERIOD_NUMBER FROM BUDGET_PERIODS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping) )
/
DELETE FROM AWARD_BUDGET_DETAILS_EXT where BUDGET_DETAILS_ID in ( SELECT BUDGET_DETAILS_ID FROM BUDGET_DETAILS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping))
/
DELETE FROM BUDGET_SUB_AWARD_PERIOD_DETAIL WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_SUB_AWARD_FILES WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_SUB_AWARD_ATT WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_SUB_AWARDS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PROJECT_INCOME WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_RATE_AND_BASE WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PER_DET_RATE_AND_BASE WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERSON_SALARY_DETAILS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERSONNEL_CAL_AMTS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERSONNEL_DETAILS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_DETAILS_CAL_AMTS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_MODULAR_IDC WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_DETAILS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERSONS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_MODULAR WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_PERIODS WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET WHERE BUDGET_ID IN (select prod_old_budget_id from go_live_awd_bgt_mapping)
/
DELETE FROM BUDGET_DOCUMENT WHERE DOCUMENT_NUMBER IN (select prod_old_bud_doc_id from go_live_awd_bgt_mapping)
/
commit
/
INSERT INTO BUDGET_DOCUMENT(DOCUMENT_NUMBER,PARENT_DOCUMENT_KEY,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,PARENT_DOCUMENT_TYPE_CODE,OBJ_ID,BUDGET_DELETED)
SELECT t1.prod_bud_doc_id, t2.parent_document_key,t2.ver_nbr,t2.update_timestamp,t2.update_user,t2.parent_document_type_code,sys_guid(),t2.budget_deleted
from go_live_awd_bgt_mapping t1 inner join BUDGET_DOCUMENT@KC_STAG_DB_LINK t2 on t1.stage_bud_doc_id = t2.DOCUMENT_NUMBER;
/
commit
/
CREATE TABLE TMP_STAG_BUDGET AS SELECT BUDGET_ID,BUDGET_JUSTIFICATION,COMMENTS FROM BUDGET@KC_STAG_DB_LINK
/
declare
cursor c_data is
	SELECT t1.prod_budget_id,t2.BUDGET_ID,t2.on_off_campus_flag,t2.version_number,t1.prod_bud_doc_id,t2.parent_document_type_code,
	t2.start_date,t2.end_date,t2.total_cost,t2.total_direct_cost,t2.total_indirect_cost,t2.cost_sharing_amount,t2.underrecovery_amount,t2.residual_funds,
	t2.total_cost_limit,t2.oh_rate_class_code,t2.oh_rate_type_code,t2.final_version_flag,t2.update_timestamp,t2.update_user,t2.ur_rate_class_code,
	t2.modular_budget_flag,t2.ver_nbr,sys_guid(),t2.total_direct_cost_limit,t2.submit_cost_sharing
	from go_live_awd_bgt_mapping t1 inner join BUDGET@KC_STAG_DB_LINK t2 on t1.stage_budget_id = t2.budget_id;
r_data c_data%rowtype;

ll_bgt_justi_clob clob;
ll_comment clob;
begin
	open c_data;
	loop
	fetch c_data into r_data;
	exit when c_data%notfound;
	
	
	INSERT INTO BUDGET(BUDGET_ID,BUDGET_JUSTIFICATION,ON_OFF_CAMPUS_FLAG,VERSION_NUMBER,DOCUMENT_NUMBER,PARENT_DOCUMENT_TYPE_CODE,
	START_DATE,END_DATE,TOTAL_COST,TOTAL_DIRECT_COST,TOTAL_INDIRECT_COST,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,RESIDUAL_FUNDS,
	TOTAL_COST_LIMIT,OH_RATE_CLASS_CODE,OH_RATE_TYPE_CODE,COMMENTS,FINAL_VERSION_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,UR_RATE_CLASS_CODE,
	MODULAR_BUDGET_FLAG,VER_NBR,OBJ_ID,TOTAL_DIRECT_COST_LIMIT,SUBMIT_COST_SHARING)
	VALUES(r_data.prod_budget_id,empty_clob() ,r_data.on_off_campus_flag,r_data.version_number,r_data.prod_bud_doc_id,r_data.parent_document_type_code,
	r_data.start_date,r_data.end_date,r_data.total_cost,r_data.total_direct_cost,r_data.total_indirect_cost,r_data.cost_sharing_amount,r_data.underrecovery_amount,r_data.residual_funds,
	r_data.total_cost_limit,r_data.oh_rate_class_code,r_data.oh_rate_type_code,empty_clob(),r_data.final_version_flag,r_data.update_timestamp,r_data.update_user,r_data.ur_rate_class_code,
	r_data.modular_budget_flag,r_data.ver_nbr,sys_guid(),r_data.total_direct_cost_limit,r_data.submit_cost_sharing);
	
	
	end loop;
	close c_data;


end;

/
drop table TMP_STAG_BUDGET
/
commit
/
declare
	cursor c_data is
	SELECT t1.budget_period_number,t2.prod_budget_id as budget_id,t1.BUDGET_PERIOD,t1.START_DATE,t1.END_DATE,t1.TOTAL_COST,t1.TOTAL_DIRECT_COST,
	t1.TOTAL_INDIRECT_COST,t1.COST_SHARING_AMOUNT,t1.UNDERRECOVERY_AMOUNT,t1.TOTAL_COST_LIMIT,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,t1.VER_NBR,t1.TOTAL_DIRECT_COST_LIMIT
	FROM BUDGET_PERIODS@KC_STAG_DB_LINK t1 inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
	r_data c_data%rowtype;
	
	li_budget_period_number budget_periods.budget_period_number%type;
begin

	open c_data;
	loop
	fetch c_data into r_data;
	exit when c_data%notfound;
		begin
			li_budget_period_number := SEQ_BUDGET_PERIOD_NUMBER.NEXTVAL;
			INSERT INTO BUDGET_PERIODS(BUDGET_PERIOD_NUMBER,BUDGET_ID,BUDGET_PERIOD,START_DATE,END_DATE,TOTAL_COST,TOTAL_DIRECT_COST,
			TOTAL_INDIRECT_COST,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,TOTAL_COST_LIMIT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,TOTAL_DIRECT_COST_LIMIT)
			VALUES(li_budget_period_number,r_data.budget_id,r_data.BUDGET_PERIOD,r_data.START_DATE,r_data.END_DATE,r_data.TOTAL_COST,r_data.TOTAL_DIRECT_COST,
				r_data.TOTAL_INDIRECT_COST,r_data.COST_SHARING_AMOUNT,r_data.UNDERRECOVERY_AMOUNT,r_data.TOTAL_COST_LIMIT,r_data.UPDATE_TIMESTAMP,r_data.UPDATE_USER,r_data.VER_NBR,
				sys_guid(),r_data.TOTAL_DIRECT_COST_LIMIT);
				
			insert into	go_live_bud_period_mapping(stage_budget_period_number,prod_budget_period_number)
			values(r_data.budget_period_number,li_budget_period_number);
		
		exception
		when others then
			dbms_output.put_line('Exception in BUDGET_PERIODS,Stage BUDGET_PERIOD_NUMBER = '||r_data.budget_period_number||', error is '||sqlerrm);
		end;
		
	end loop;
	close c_data;

end;
/
commit
/
INSERT INTO BUDGET_MODULAR(BUDGET_PERIOD_NUMBER,BUDGET_ID,BUDGET_PERIOD,DIRECT_COST_LESS_CONSOR_FNA,CONSORTIUM_FNA,TOTAL_DIRECT_COST,
UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT t3.budget_period_number, t3.budget_id,t3.budget_period,t1.direct_cost_less_consor_fna,t1.consortium_fna,t1.total_direct_cost,
t1.update_timestamp,t1.update_user,t1.ver_nbr,sys_guid() FROM BUDGET_MODULAR@KC_STAG_DB_LINK t1 
inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id
INNER JOIN BUDGET_PERIODS t3 on t3.BUDGET_ID = t2.prod_budget_id
/
commit
/
INSERT INTO BUDGET_MODULAR_IDC(BUDGET_PERIOD_NUMBER,RATE_NUMBER,BUDGET_ID,BUDGET_PERIOD,DESCRIPTION,IDC_RATE,IDC_BASE,FUNDS_REQUESTED,
UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT t3.budget_period_number,t1.rate_number,t3.budget_id,t1.budget_period,t1.description,t1.idc_rate,t1.idc_base,t1.funds_requested,
t1.update_timestamp,t1.update_user,t1.ver_nbr,sys_guid()
FROM BUDGET_MODULAR_IDC@KC_STAG_DB_LINK t1 
inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id
INNER JOIN BUDGET_PERIODS t3 on t3.BUDGET_ID = t2.prod_budget_id
/

declare
	cursor c_data is
	SELECT t1.PERSON_SEQUENCE_NUMBER,t1.BUDGET_ID,t2.prod_budget_id,t1.ROLODEX_ID,t1.APPOINTMENT_TYPE_CODE,t1.TBN_ID,
	t1.HIERARCHY_PROPOSAL_NUMBER,t1.HIDE_IN_HIERARCHY,t1.PERSON_ID,t1.JOB_CODE,t1.EFFECTIVE_DATE,t1.CALCULATION_BASE,
	t1.PERSON_NAME,t1.NON_EMPLOYEE_FLAG,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,t1.VER_NBR,t1.SALARY_ANNIVERSARY_DATE
	FROM BUDGET_PERSONS@KC_STAG_DB_LINK t1 inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
	r_data c_data%rowtype;
	li_per_seq_number NUMBER(3,0);
begin
	OPEN c_data;
	loop
	fetch c_data into r_data;
	exit when c_data%notfound;
	
	BEGIN
	li_per_seq_number := FN_DOCUMENT_NEXTVAL(r_data.prod_budget_id,'personSequenceNumber');
	EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('BUDGET_ID:'||r_data.prod_budget_id);
	END;
	
	BEGIN
	
	INSERT INTO go_live_bud_person_mapping(stage_person_sequence_num,stage_budget_id,prod_budget_id,prod_person_sequence_num)
	VALUES(r_data.person_sequence_number,r_data.budget_id,r_data.prod_budget_id,li_per_seq_number);
	

	INSERT INTO  BUDGET_PERSONS(PERSON_SEQUENCE_NUMBER,BUDGET_ID,ROLODEX_ID,APPOINTMENT_TYPE_CODE,TBN_ID,HIERARCHY_PROPOSAL_NUMBER,
	HIDE_IN_HIERARCHY,PERSON_ID,JOB_CODE,EFFECTIVE_DATE,CALCULATION_BASE,PERSON_NAME,NON_EMPLOYEE_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,
	VER_NBR,OBJ_ID,SALARY_ANNIVERSARY_DATE)
	Values(li_per_seq_number,r_data.prod_budget_id,r_data.ROLODEX_ID,r_data.APPOINTMENT_TYPE_CODE,r_data.TBN_ID,
	r_data.HIERARCHY_PROPOSAL_NUMBER,r_data.HIDE_IN_HIERARCHY,r_data.PERSON_ID,r_data.JOB_CODE,r_data.EFFECTIVE_DATE,r_data.CALCULATION_BASE,
	r_data.PERSON_NAME,r_data.NON_EMPLOYEE_FLAG,r_data.UPDATE_TIMESTAMP,r_data.UPDATE_USER,r_data.VER_NBR,sys_guid(),r_data.SALARY_ANNIVERSARY_DATE);	
	
	EXCEPTION
	WHEN OTHERS THEN
	dbms_output.put_line('BUDGET_PERSONS : '||r_data.prod_budget_id ||', error is '||sqlerrm);	
	END;
	
	
	end loop;
	close c_data;
	

end;
/
-- BUDGET_DETAILS
declare
	cursor c_data is
	select t1.BUDGET_DETAILS_ID,t1.GROUP_NAME,t1.budget_id,t1.HIERARCHY_PROPOSAL_NUMBER,t1.HIDE_IN_HIERARCHY,
	t1.BUDGET_PERIOD,t1.LINE_ITEM_NUMBER,t1.BUDGET_CATEGORY_CODE,t1.COST_ELEMENT,t1.LINE_ITEM_DESCRIPTION,t1.BASED_ON_LINE_ITEM,t1.LINE_ITEM_SEQUENCE,t1.START_DATE,
	t1.END_DATE,t1.LINE_ITEM_COST,t1.COST_SHARING_AMOUNT,t1.UNDERRECOVERY_AMOUNT,t1.ON_OFF_CAMPUS_FLAG,t1.APPLY_IN_RATE_FLAG,t1.BUDGET_JUSTIFICATION,
	t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,t1.QUANTITY,t1.VER_NBR,t1.SUBMIT_COST_SHARING,t1.SUBAWARD_NUMBER
	from BUDGET_DETAILS@KC_STAG_DB_LINK t1 inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
	r_data c_data%rowtype;

li_budget_period_number budget_periods.budget_period_number%type;
li_budget_id budget_periods.budget_id%type;
li_budget_details_id BUDGET_DETAILS.BUDGET_DETAILS_ID%type;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

	begin
		select budget_period_number , budget_id
		into li_budget_period_number , li_budget_id
		from budget_periods t1 
		inner join go_live_awd_bgt_mapping t2 on t1.budget_id = t2.prod_budget_id
		where t2.stage_budget_id = r_data.budget_id
		and t1.budget_period = r_data.budget_period;
			
		li_budget_details_id := SEQ_BUDGET_DETAILS_ID.NEXTVAL;
		INSERT INTO BUDGET_DETAILS(BUDGET_DETAILS_ID,BUDGET_PERIOD_NUMBER,GROUP_NAME,BUDGET_ID,HIERARCHY_PROPOSAL_NUMBER,HIDE_IN_HIERARCHY,
		BUDGET_PERIOD,LINE_ITEM_NUMBER,BUDGET_CATEGORY_CODE,COST_ELEMENT,LINE_ITEM_DESCRIPTION,BASED_ON_LINE_ITEM,LINE_ITEM_SEQUENCE,START_DATE,
		END_DATE,LINE_ITEM_COST,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,ON_OFF_CAMPUS_FLAG,APPLY_IN_RATE_FLAG,BUDGET_JUSTIFICATION,
		UPDATE_TIMESTAMP,UPDATE_USER,QUANTITY,VER_NBR,OBJ_ID,SUBMIT_COST_SHARING,SUBAWARD_NUMBER)
		VALUES(li_budget_details_id,li_budget_period_number,r_data.GROUP_NAME,li_budget_id,r_data.HIERARCHY_PROPOSAL_NUMBER,r_data.HIDE_IN_HIERARCHY,
		r_data.BUDGET_PERIOD,r_data.LINE_ITEM_NUMBER,r_data.BUDGET_CATEGORY_CODE,r_data.COST_ELEMENT,r_data.LINE_ITEM_DESCRIPTION,r_data.BASED_ON_LINE_ITEM,r_data.LINE_ITEM_SEQUENCE,r_data.START_DATE,
		r_data.END_DATE,r_data.LINE_ITEM_COST,r_data.COST_SHARING_AMOUNT,r_data.UNDERRECOVERY_AMOUNT,r_data.ON_OFF_CAMPUS_FLAG,r_data.APPLY_IN_RATE_FLAG,r_data.BUDGET_JUSTIFICATION,
		r_data.UPDATE_TIMESTAMP,r_data.UPDATE_USER,r_data.QUANTITY,r_data.VER_NBR,sys_guid(),r_data.SUBMIT_COST_SHARING,r_data.SUBAWARD_NUMBER);
		
		insert into go_live_bud_detail_mapping(stage_budget_details_id,prod_budget_details_id)
		values(r_data.budget_details_id,li_budget_details_id);
	
	exception
	when others then
	dbms_output.put_line('Exception in BUDGET_DETAILS,Stage BUDGET_DETAILS_ID = '||r_data.BUDGET_DETAILS_ID||', error is '||sqlerrm);
	end;



end loop;
close c_data;

end;
/
---BUDGET_DETAILS_CAL_AMTS
declare
cursor c_data is
select t1.BUDGET_DETAILS_CAL_AMTS_ID,t1.BUDGET_ID,t1.BUDGET_PERIOD_NUMBER,t1.BUDGET_PERIOD,t1.LINE_ITEM_NUMBER,t1.RATE_CLASS_CODE,t1.RATE_TYPE_CODE,t1.APPLY_RATE_FLAG,
t1.CALCULATED_COST,t1.CALCULATED_COST_SHARING,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,t1.VER_NBR,t1.BUDGET_DETAILS_ID,t1.RATE_TYPE_DESCRIPTION
from BUDGET_DETAILS_CAL_AMTS@KC_STAG_DB_LINK t1
inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
r_data c_data%rowtype;

li_budget_period_number budget_periods.budget_period_number%type;
li_budget_id budget_periods.budget_id%type;
li_budget_details_id budget_details.budget_details_id%type;

begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

	begin
		select budget_period_number , budget_id	into li_budget_period_number , li_budget_id
		from budget_periods t1 
		inner join go_live_awd_bgt_mapping t2 on t1.budget_id = t2.prod_budget_id
		where t2.stage_budget_id = r_data.budget_id
		and t1.budget_period = r_data.budget_period;
		
		select budget_details_id into li_budget_details_id
		from budget_details t1
		where t1.budget_id = li_budget_id
		and t1.budget_period = li_budget_period_number
		and t1.line_item_number = r_data.LINE_ITEM_NUMBER;
		
		INSERT INTO BUDGET_DETAILS_CAL_AMTS(BUDGET_DETAILS_CAL_AMTS_ID,BUDGET_ID,BUDGET_PERIOD_NUMBER,BUDGET_PERIOD,LINE_ITEM_NUMBER,
		RATE_CLASS_CODE,RATE_TYPE_CODE,APPLY_RATE_FLAG,CALCULATED_COST,CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,
		UPDATE_USER,VER_NBR,BUDGET_DETAILS_ID,OBJ_ID,RATE_TYPE_DESCRIPTION)
		VALUES(SEQ_BUDGET_DETAILS_CAL_AMTS_ID.NEXTVAL, li_budget_id , li_budget_period_number,r_data.budget_period,r_data.line_item_number,
		r_data.rate_class_code,r_data.rate_type_code,r_data.apply_rate_flag,r_data.calculated_cost,r_data.calculated_cost_sharing,r_data.update_timestamp,
		r_data.update_user,r_data.ver_nbr,li_budget_details_id,sys_guid(),r_data.rate_type_description);
		
			
	exception
	when others then
	dbms_output.put_line('Exception in BUDGET_DETAILS_CAL_AMTS,Stage BUDGET_DETAILS_CAL_AMTS_ID = '||r_data.BUDGET_DETAILS_CAL_AMTS_ID||', error is '||sqlerrm);
	end;


end loop;
close c_data;

end;
/
---BUDGET_RATE_AND_BASE
declare
cursor c_data is
	SELECT t1.budget_rate_and_base_id,t1.budget_period_number,t1.budget_id,t1.budget_period,t1.line_item_number,t1.rate_number,t1.start_date,t1.end_date,
	t1.rate_class_code,t1.rate_type_code,t1.on_off_campus_flag,t1.applied_rate,t1.base_cost,t1.base_cost_sharing,t1.calculated_cost,t1.calculated_cost_sharing,
	t1.update_timestamp,t1.update_user,t1.ver_nbr,t1.budget_details_cal_amts_id,t1.budget_details_id
	FROM BUDGET_RATE_AND_BASE@KC_STAG_DB_LINK t1 inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
r_data c_data%rowtype;

li_budget_period_number budget_periods.budget_period_number%type;
li_budget_id budget_periods.budget_id%type;
li_budget_details_id budget_details.budget_details_id%type;
li_budget_details_cal_amts_id budget_details_cal_amts.budget_details_cal_amts_id%type;

begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

	begin
		select budget_period_number , budget_id	into li_budget_period_number , li_budget_id
		from budget_periods t1 
		inner join go_live_awd_bgt_mapping t2 on t1.budget_id = t2.prod_budget_id
		where t2.stage_budget_id = r_data.budget_id
		and t1.budget_period = r_data.budget_period;
		
		select budget_details_id into li_budget_details_id
		from budget_details t1
		where t1.budget_id = li_budget_id
		and t1.budget_period = li_budget_period_number
		and t1.line_item_number = r_data.line_item_number;
		
		select budget_details_cal_amts_id into li_budget_details_cal_amts_id
		from budget_details_cal_amts t1
		where t1.budget_id = li_budget_id
		and t1.budget_period = li_budget_period_number
		and t1.line_item_number = r_data.line_item_number
		and t1.rate_class_code = r_data.rate_class_code
		and t1.rate_type_code = r_data.rate_type_code;
					
		
		INSERT INTO BUDGET_RATE_AND_BASE(BUDGET_RATE_AND_BASE_ID,BUDGET_PERIOD_NUMBER,BUDGET_ID,BUDGET_PERIOD,LINE_ITEM_NUMBER,RATE_NUMBER,
		START_DATE,END_DATE,RATE_CLASS_CODE,RATE_TYPE_CODE,ON_OFF_CAMPUS_FLAG,APPLIED_RATE,BASE_COST,BASE_COST_SHARING,CALCULATED_COST,
		CALCULATED_COST_SHARING,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,BUDGET_DETAILS_CAL_AMTS_ID,BUDGET_DETAILS_ID,OBJ_ID)
		VALUES(SEQ_BUDGET_RATE_AND_BASE_ID.NEXTVAL,li_budget_period_number,li_budget_id,r_data.budget_period,r_data.line_item_number,r_data.rate_number,
		r_data.start_date,r_data.end_date,r_data.rate_class_code,r_data.rate_type_code,r_data.on_off_campus_flag,r_data.applied_rate,r_data.base_cost,
		r_data.base_cost_sharing,r_data.calculated_cost,r_data.calculated_cost_sharing,r_data.update_timestamp,r_data.update_user,
		r_data.ver_nbr,li_budget_details_cal_amts_id,li_budget_details_id,sys_guid());
		
		
			
	exception
	when others then
	dbms_output.put_line('Exception in BUDGET_RATE_AND_BASE,Stage budget_rate_and_base_id = '||r_data.budget_rate_and_base_id||', error is '||sqlerrm);
	end;


end loop;
close c_data;

end;
/
-- BUDGET_PERSONNEL_DETAILS
CREATE TABLE TMP_STAG_BUD_PER_DET AS SELECT budget_personnel_details_id,BUDGET_JUSTIFICATION 
FROM budget_personnel_details@KC_STAG_DB_LINK
/
declare
	cursor c_data is
	select t1.budget_personnel_details_id,t1.person_sequence_number,t1.budget_period_number,t1.budget_id,t1.line_item_number,
  t1.person_number,t1.person_id,t1.job_code,t1.start_date,t1.end_date,	t1.period_type,t1.line_item_description,
  t1.sequence_number,t1.salary_requested,t1.percent_charged,t1.percent_effort,t1.cost_sharing_percent,
  t1.cost_sharing_amount,t1.underrecovery_amount,	t1.on_off_campus_flag,t1.apply_in_rate_flag,
  t1.update_timestamp,t1.update_user,t1.ver_nbr,t1.budget_period,t1.budget_details_id,t1.submit_cost_sharing
	from budget_personnel_details@KC_STAG_DB_LINK  t1 
  inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
	r_data c_data%rowtype;

	li_budget_period_number budget_periods.budget_period_number%type;
	li_budget_id budget_periods.budget_id%type;
	li_person_sequence_number budget_persons.person_sequence_number%type;	
	li_budget_details_id budget_details.budget_details_id%type;
	ll_bgt_justi_clob clob;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

	begin
  
  
		select budget_period_number , budget_id	into li_budget_period_number , li_budget_id
		from budget_periods t1 
		inner join go_live_awd_bgt_mapping t2 on t1.budget_id = t2.prod_budget_id
		where t2.stage_budget_id = r_data.budget_id
		and t1.budget_period = r_data.budget_period;
			
	
		select prod_person_sequence_num into li_person_sequence_number
		from go_live_bud_person_mapping t1 		
		where t1.stage_budget_id = r_data.budget_id
		and t1.stage_person_sequence_num = r_data.person_sequence_number;
		
		begin
			select budget_details_id into li_budget_details_id 
			from budget_details
			where budget_id = li_budget_id 
			and budget_period = r_data.budget_period
			and line_item_number = r_data.line_item_number;
		exception
		when others then
			li_budget_details_id := null;
		end;
		
		
		INSERT INTO BUDGET_PERSONNEL_DETAILS(BUDGET_PERSONNEL_DETAILS_ID,PERSON_SEQUENCE_NUMBER,BUDGET_PERIOD_NUMBER,BUDGET_ID,LINE_ITEM_NUMBER,
		PERSON_NUMBER,PERSON_ID,JOB_CODE,START_DATE,END_DATE,PERIOD_TYPE,LINE_ITEM_DESCRIPTION,SEQUENCE_NUMBER,SALARY_REQUESTED,PERCENT_CHARGED,
		PERCENT_EFFORT,COST_SHARING_PERCENT,COST_SHARING_AMOUNT,UNDERRECOVERY_AMOUNT,ON_OFF_CAMPUS_FLAG,APPLY_IN_RATE_FLAG,BUDGET_JUSTIFICATION,
		UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,BUDGET_PERIOD,BUDGET_DETAILS_ID,OBJ_ID)
		VALUES(seq_budget_per_det_id.NEXTVAL,li_person_sequence_number,li_budget_period_number,li_budget_id,r_data.line_item_number,
		r_data.person_number,r_data.person_id,r_data.job_code,r_data.start_date,r_data.end_date,r_data.period_type,
    r_data.line_item_description,r_data.sequence_number,r_data.salary_requested,r_data.percent_charged,
		r_data.percent_effort,r_data.cost_sharing_percent,r_data.cost_sharing_amount,r_data.underrecovery_amount,
    r_data.on_off_campus_flag,r_data.apply_in_rate_flag,empty_clob(),
		r_data.update_timestamp,r_data.update_user,r_data.ver_nbr,r_data.budget_period,li_budget_details_id,sys_guid());				
		
	
	exception
	when others then
	dbms_output.put_line('Exception in BUDGET_PERSONNEL_DETAILS,Stage BUDGET_PERSONNEL_DETAILS_ID = '||r_data.BUDGET_PERSONNEL_DETAILS_ID||', error is '||sqlerrm);
	end;



end loop;
close c_data;

end;
/
drop table TMP_STAG_BUD_PER_DET
/
-- BUDGET_PERSONNEL_CAL_AMTS
declare
	cursor c_data is
	select budget_personnel_cal_amts_id,budget_period_number,budget_id,budget_period,
	line_item_number,person_number,rate_class_code,rate_type_code,apply_rate_flag,calculated_cost,calculated_cost_sharing,
	update_timestamp,update_user,ver_nbr,budget_personnel_details_id,rate_type_description
	from budget_personnel_cal_amts@kc_stag_db_link  t1 inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
	r_data c_data%rowtype;

	li_budget_period_number budget_periods.budget_period_number%type;
	li_budget_id budget_periods.budget_id%type;
	li_person_sequence_number budget_persons.person_sequence_number%type;	
	li_budget_personnel_details_id budget_personnel_details.budget_personnel_details_id%type;
	
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

	begin
	
		select budget_period_number , budget_id	into li_budget_period_number , li_budget_id
		from budget_periods t1 
		inner join go_live_awd_bgt_mapping t2 on t1.budget_id = t2.prod_budget_id
		where t2.stage_budget_id = r_data.budget_id
		and t1.budget_period = r_data.budget_period;
	
		
		begin
			select budget_personnel_details_id into li_budget_personnel_details_id 
			from budget_personnel_details
			where budget_id = li_budget_id 
			and budget_period = r_data.budget_period
			and person_number = r_data.person_number
			and line_item_number = r_data.line_item_number;
		exception
		when others then
			li_budget_personnel_details_id := null;
		end;
		
		INSERT INTO BUDGET_PERSONNEL_CAL_AMTS(budget_personnel_cal_amts_id,budget_period_number,budget_id,budget_period,
		line_item_number,person_number,rate_class_code,rate_type_code,apply_rate_flag,calculated_cost,calculated_cost_sharing,
		update_timestamp,update_user,ver_nbr,budget_personnel_details_id,obj_id,rate_type_description)		
		VALUES(SEQ_BUDGET_PER_CAL_AMTS_ID.NEXTVAL,li_budget_period_number,li_budget_id,r_data.budget_period,
		r_data.line_item_number,r_data.person_number,r_data.rate_class_code,r_data.rate_type_code,r_data.apply_rate_flag,
    r_data.calculated_cost,r_data.calculated_cost_sharing,r_data.update_timestamp,r_data.update_user,r_data.ver_nbr,
    li_budget_personnel_details_id,sys_guid(),r_data.rate_type_description);										
	
	
	exception
	when others then
	dbms_output.put_line('Exception in BUDGET_PERSONNEL_CAL_AMTS,Stage budget_personnel_cal_amts_id = '||r_data.budget_personnel_cal_amts_id||', error is '||sqlerrm);
	end;

end loop;
close c_data;

end;
/
-- BUDGET_PER_DET_RATE_AND_BASE
declare
	cursor c_data is
	select bgt_per_det_rate_and_base_id,budget_id,budget_period,line_item_number,person_number,rate_number,person_id,start_date,end_date,rate_class_code,
	rate_type_code,on_off_campus_flag,applied_rate,salary_requested,base_cost_sharing,calculated_cost,calculated_cost_sharing,update_timestamp,update_user,
	ver_nbr,underrecovery_amount,budget_period_number,budget_personnel_details_id,budget_personnel_cal_amts_id
	from budget_per_det_rate_and_base@kc_stag_db_link t1 inner join go_live_awd_bgt_mapping t2 on t1.BUDGET_ID = t2.stage_budget_id;
	r_data c_data%rowtype;

	li_budget_period_number budget_periods.budget_period_number%type;
	li_budget_id budget_periods.budget_id%type;
	li_person_sequence_number budget_persons.person_sequence_number%type;	
	li_budget_personnel_details_id budget_personnel_details.budget_personnel_details_id%type;
	li_budget_pers_cal_amts_id budget_personnel_cal_amts.budget_personnel_cal_amts_id%type;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

	begin
	
		select budget_period_number , budget_id	into li_budget_period_number , li_budget_id
		from budget_periods t1 
		inner join go_live_awd_bgt_mapping t2 on t1.budget_id = t2.prod_budget_id
		where t2.stage_budget_id = r_data.budget_id
		and t1.budget_period = r_data.budget_period;
	
		
		begin
			select budget_personnel_details_id into li_budget_personnel_details_id 
			from budget_personnel_details
			where budget_id = li_budget_id 
			and budget_period = r_data.budget_period
			and person_number = r_data.person_number
			and line_item_number = r_data.line_item_number;
		exception
		when others then
			li_budget_personnel_details_id := null;
		end;
		
		begin
			select budget_personnel_cal_amts_id into li_budget_pers_cal_amts_id
			from budget_personnel_cal_amts
			where budget_id = li_budget_id 
			and budget_period = r_data.budget_period
			and person_number = r_data.person_number
			and line_item_number = r_data.line_item_number
			and rate_class_code = r_data.rate_class_code
			and rate_type_code = r_data.rate_type_code;
			
		exception
		when others then
			li_budget_pers_cal_amts_id := null;
		end;
		
		INSERT INTO budget_per_det_rate_and_base(bgt_per_det_rate_and_base_id,budget_id,budget_period,line_item_number,person_number,
		rate_number,person_id,start_date,end_date,rate_class_code,rate_type_code,on_off_campus_flag,applied_rate,salary_requested,base_cost_sharing,
		calculated_cost,calculated_cost_sharing,update_timestamp,update_user,ver_nbr,underrecovery_amount,budget_period_number,budget_personnel_details_id,
		budget_personnel_cal_amts_id,obj_id)
		values(seq_bgt_per_det_rate_base_id.nextval,li_budget_id,r_data.budget_period,r_data.line_item_number,r_data.person_number,
		r_data.rate_number,r_data.person_id,r_data.start_date,r_data.end_date,r_data.rate_class_code,r_data.rate_type_code,r_data.on_off_campus_flag,
		r_data.applied_rate,r_data.salary_requested,r_data.base_cost_sharing,r_data.calculated_cost,r_data.calculated_cost_sharing,
		r_data.update_timestamp,r_data.update_user,r_data.ver_nbr,r_data.underrecovery_amount,li_budget_period_number,li_budget_personnel_details_id,
		li_budget_pers_cal_amts_id,sys_guid());
	
	
	exception
	when others then
	dbms_output.put_line('Exception in BUDGET_PER_DET_RATE_AND_BASE,Stage bgt_per_det_rate_and_base_id = '||r_data.bgt_per_det_rate_and_base_id||', error is '||sqlerrm);
	end;

end loop;
close c_data;

end;
/


INSERT INTO AWARD_BUDGET_EXT(budget_id,award_budget_status_code,award_budget_type_code,ver_nbr,update_timestamp,update_user,
obligated_amount,budget_initiator,description,document_number,obj_id,award_id)
SELECT t2.prod_budget_id,award_budget_status_code,award_budget_type_code,ver_nbr,update_timestamp,update_user,obligated_amount,budget_initiator,
description,t2.prod_bud_doc_id,sys_guid(),prod_award_id
FROM AWARD_BUDGET_EXT@kc_stag_db_link t1
inner join go_live_awd_bgt_mapping t2 on t1.budget_id = t2.stage_budget_id
/
commit
/
INSERT INTO AWARD_BUDGET_DETAILS_EXT(budget_details_id,obligated_amount,ver_nbr,update_timestamp,update_user,obj_id)
SELECT t2.prod_budget_details_id,t1.obligated_amount,t1.ver_nbr,t1.update_timestamp,t1.update_user,sys_guid() 
FROM AWARD_BUDGET_DETAILS_EXT@kc_stag_db_link t1
INNER JOIN go_live_bud_detail_mapping t2 on t1.budget_details_id = t2.stage_budget_details_id
/
commit
/
INSERT INTO AWARD_BUDGET_PERIOD_EXT(BUDGET_PERIOD_NUMBER,OBLIGATED_AMOUNT,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,RATE_OVERRIDE_FLAG,TOTAL_FRINGE_AMOUNT)
SELECT t2.prod_budget_period_number,t1.obligated_amount,t1.ver_nbr,t1.update_timestamp,t1.update_user,sys_guid(),t1.rate_override_flag,t1.total_fringe_amount
FROM AWARD_BUDGET_PERIOD_EXT@kc_stag_db_link t1
INNER JOIN go_live_bud_period_mapping t2 ON t1.BUDGET_PERIOD_NUMBER = t2.stage_budget_period_number
/
commit
/
INSERT INTO AWARD_BUDGET_LIMIT(BUDGET_LIMIT_ID,AWARD_ID,BUDGET_ID,LIMIT_TYPE,LIMIT_AMOUNT,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
select SEQ_AWRD_BDGT_LMT_ID.nextval,t2.prod_award_id,t3.prod_budget_id,t1.limit_type,t1.limit_amount,t1.ver_nbr,t1.update_timestamp,t1.update_user,sys_guid()
from award_budget_limit@kc_stag_db_link t1
left outer join go_live_awd_bgt_mapping t2 on t1.award_id = t2.stage_award_id
left outer join go_live_awd_bgt_mapping t3 on t1.budget_id = t3.stage_budget_id
where t1.budget_limit_id in (
select budget_limit_id from  award_budget_limit@kc_stag_db_link	where award_id in ( select award_id from AWARD_BUDGET_EXT@kc_stag_db_link )
union
select budget_limit_id from  award_budget_limit@kc_stag_db_link	where budget_id in ( select budget_id from AWARD_BUDGET_EXT@kc_stag_db_link )
)
/
commit
/
--- inserting to KREW
declare 
li_krew_rnt_brch number(12,0);
li_krew_rnt_node number(12,0);
li_krew_rne_node_instn number(12,0);
ls_doc_typ_id varchar2(40);

cursor c_budeget_krew is
select stage_bud_doc_id,prod_bud_doc_id from go_live_awd_bgt_mapping;
r_budeget_krew c_budeget_krew%rowtype;

begin
     if c_budeget_krew%isopen then
	    close c_budeget_krew;
	 end if;
	 open c_budeget_krew;
	 loop
	 fetch c_budeget_krew into r_budeget_krew;
	 exit when c_budeget_krew%notfound;
	 
		begin
	             select KREW_RTE_NODE_S.nextval into li_krew_rnt_brch from dual ; 
                 select KREW_RTE_NODE_S.nextval into li_krew_rnt_node from dual ;
                 select KREW_RTE_NODE_S.nextval into li_krew_rne_node_instn from dual ; 
				 select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM = 'AwardBudgetDocument';
	 
	             insert into KREW_DOC_HDR_T(DOC_HDR_ID,
                                            DOC_TYP_ID,
											DOC_HDR_STAT_CD,
											RTE_LVL,
											STAT_MDFN_DT,
											CRTE_DT,
											APRV_DT,
											FNL_DT,
											RTE_STAT_MDFN_DT,
											TTL,
											APP_DOC_ID,
											DOC_VER_NBR,
											INITR_PRNCPL_ID,
											VER_NBR,
											RTE_PRNCPL_ID,
											DTYPE,
											OBJ_ID,
											APP_DOC_STAT,
											APP_DOC_STAT_MDFN_DT)
									 select r_budeget_krew.prod_bud_doc_id,
									        ls_doc_typ_id,
											DOC_HDR_STAT_CD,
											RTE_LVL,
											STAT_MDFN_DT,
											CRTE_DT,
											APRV_DT,
											FNL_DT,
											RTE_STAT_MDFN_DT,
											TTL,
											APP_DOC_ID,
											DOC_VER_NBR,
											INITR_PRNCPL_ID,
											VER_NBR,
											RTE_PRNCPL_ID,
											DTYPE,
											sys_guid(),
											APP_DOC_STAT,
											APP_DOC_STAT_MDFN_DT
									   from KREW_DOC_HDR_T@KC_STAG_DB_LINK
									   where DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;
									   
			 insert into KREW_DOC_HDR_CNTNT_T(DOC_HDR_ID,
                                              DOC_CNTNT_TXT)
                                       select r_budeget_krew.prod_bud_doc_id,
                                              DOC_CNTNT_TXT
                                         from KREW_DOC_HDR_CNTNT_T@KC_STAG_DB_LINK
									     where DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;

             insert into KRNS_DOC_HDR_T(DOC_HDR_ID,
                                        OBJ_ID,
										VER_NBR,
										FDOC_DESC,
										ORG_DOC_HDR_ID,
										TMPL_DOC_HDR_ID,
										EXPLANATION	)
                                 select	r_budeget_krew.prod_bud_doc_id,
                                        sys_guid(),
                                        VER_NBR,
										FDOC_DESC,
										ORG_DOC_HDR_ID,
										TMPL_DOC_HDR_ID,
										EXPLANATION	
                                   from KRNS_DOC_HDR_T@KC_STAG_DB_LINK
								   where DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;										
			        begin
			            insert into KREW_RTE_BRCH_T(RTE_BRCH_ID,
						                            NM,
                                                    PARNT_ID,
							                        INIT_RTE_NODE_INSTN_ID,
							                        SPLT_RTE_NODE_INSTN_ID,
							                        JOIN_RTE_NODE_INSTN_ID,
							                        VER_NBR)
                                             select li_krew_rnt_brch,
                                                    r.NM,
                                                    r.PARNT_ID,
							                        r.INIT_RTE_NODE_INSTN_ID,
							                        r.SPLT_RTE_NODE_INSTN_ID,
							                        r.JOIN_RTE_NODE_INSTN_ID,
							                        r.VER_NBR
											   from KREW_RTE_BRCH_T@KC_STAG_DB_LINK r 
											   inner join KREW_RTE_NODE_INSTN_T@KC_STAG_DB_LINK t
											   on r.RTE_BRCH_ID = t.BRCH_ID
											   where t.DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;
											   
                        insert into KREW_RTE_NODE_T(RTE_NODE_ID,
                                                    DOC_TYP_ID,
							                        NM,
							                        TYP,
							                        RTE_MTHD_NM,
							                        RTE_MTHD_CD,
							                        FNL_APRVR_IND,
							                        MNDTRY_RTE_IND,
							                        ACTVN_TYP,
							                        BRCH_PROTO_ID,
							                        VER_NBR,
							                        CONTENT_FRAGMENT,
							                        GRP_ID,
							                        NEXT_DOC_STAT)
                                             select li_krew_rnt_node,
					                                ls_doc_typ_id,
							                        r.NM,
							                        r.TYP,
							                        r.RTE_MTHD_NM,
							                        r.RTE_MTHD_CD,
							                        r.FNL_APRVR_IND,
							                        r.MNDTRY_RTE_IND,
							                        r.ACTVN_TYP,
							                        r.BRCH_PROTO_ID,
							                        r.VER_NBR,
							                        r.CONTENT_FRAGMENT,
							                        r.GRP_ID,
							                        r.NEXT_DOC_STAT
                                               from KREW_RTE_NODE_T@KC_STAG_DB_LINK r 
											   inner join KREW_RTE_NODE_INSTN_T@KC_STAG_DB_LINK t
											   on r.RTE_NODE_ID = t.RTE_NODE_ID
											   where t.DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;
											   
					exception
                    when others then
                    null;
                    end;					
											   
                        insert into KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,
                                                          DOC_HDR_ID,
								                          RTE_NODE_ID,
								                          BRCH_ID,
								                          PROC_RTE_NODE_INSTN_ID,
								                          ACTV_IND,
								                          CMPLT_IND,
								                          INIT_IND,
								                          VER_NBR)
                                                   select li_krew_rne_node_instn,
						                                  r_budeget_krew.prod_bud_doc_id,
								                          li_krew_rnt_node,
								                          li_krew_rnt_brch,
								                          PROC_RTE_NODE_INSTN_ID,
								                          ACTV_IND,
								                          CMPLT_IND,
								                          INIT_IND,
								                          VER_NBR
													 from KREW_RTE_NODE_INSTN_T@KC_STAG_DB_LINK
								                     where DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;	

                        insert into KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,
                                                               RTE_NODE_INSTN_ID)
                                                        values(r_budeget_krew.prod_bud_doc_id,
								                               li_krew_rne_node_instn);

                        insert into KREW_ACTN_RQST_T(ACTN_RQST_ID,
                                                     PARNT_ID,
							                         ACTN_RQST_CD,
							                         DOC_HDR_ID,
							                         RULE_ID,
							                         STAT_CD,
							                         RSP_ID,
							                         PRNCPL_ID,
							                         ROLE_NM,
							                         QUAL_ROLE_NM,
							                         QUAL_ROLE_NM_LBL_TXT,
							                         RECIP_TYP_CD,
							                         PRIO_NBR,
							                         RTE_TYP_NM,
							                         RTE_LVL_NBR,
							                         RTE_NODE_INSTN_ID,
							                         ACTN_TKN_ID,
							                         DOC_VER_NBR,
							                         CRTE_DT,
							                         RSP_DESC_TXT,
							                         FRC_ACTN,
							                         ACTN_RQST_ANNOTN_TXT,
							                         DLGN_TYP,
							                         APPR_PLCY,
							                         CUR_IND,
							                         VER_NBR,
							                         GRP_ID,
							                         RQST_LBL)
                                              select KREW_ACTN_RQST_S.NEXTVAL,
					                                 PARNT_ID,
							                         ACTN_RQST_CD,
							                         r_budeget_krew.prod_bud_doc_id,
							                         RULE_ID,
							                         STAT_CD,
							                         RSP_ID,
							                         PRNCPL_ID,
							                         ROLE_NM,
							                         QUAL_ROLE_NM,
							                         QUAL_ROLE_NM_LBL_TXT,
							                         RECIP_TYP_CD,
							                         PRIO_NBR,
							                         RTE_TYP_NM,
							                         RTE_LVL_NBR,
							                         li_krew_rne_node_instn,
							                         ACTN_TKN_ID,
							                         DOC_VER_NBR,
							                         CRTE_DT,
							                         RSP_DESC_TXT,
							                         FRC_ACTN,
							                         ACTN_RQST_ANNOTN_TXT,
							                         DLGN_TYP,
							                         APPR_PLCY,
							                         CUR_IND,
							                         VER_NBR,
							                         GRP_ID,
							                         RQST_LBL
												from KREW_ACTN_RQST_T@KC_STAG_DB_LINK
								                where DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;
						 

                        insert into KREW_ACTN_TKN_T(ACTN_TKN_ID,
                                                    DOC_HDR_ID,
							                        PRNCPL_ID,
							                        DLGTR_PRNCPL_ID,
							                        ACTN_CD,
							                        ACTN_DT,
							                        DOC_VER_NBR,
							                        ANNOTN,
							                        CUR_IND,
							                        VER_NBR,
							                        DLGTR_GRP_ID)
                                             select KREW_ACTN_TKN_S.NEXTVAL,
					                                r_budeget_krew.prod_bud_doc_id,
							                        PRNCPL_ID,
							                        DLGTR_PRNCPL_ID,
							                        ACTN_CD,
							                        ACTN_DT,
							                        DOC_VER_NBR,
							                        ANNOTN,
							                        CUR_IND,
							                        VER_NBR,
							                        DLGTR_GRP_ID
											   from KREW_ACTN_TKN_T@KC_STAG_DB_LINK
								               where DOC_HDR_ID = r_budeget_krew.stage_bud_doc_id;
		exception
		when others then
		continue;
		end;	
		
		
	 end loop;
	 close c_budeget_krew;
end;
/
commit
/
