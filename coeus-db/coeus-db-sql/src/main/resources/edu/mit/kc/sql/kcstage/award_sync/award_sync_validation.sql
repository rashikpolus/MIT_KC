set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
set heading off;
DECLARE
li_count number;
BEGIN
select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_CUSTOM_DATA';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_CUSTOM_DATA');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_IDC_RATE';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_IDC_RATE');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_APPROVED_EQUIPMENT';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_APPROVED_EQUIPMENT');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_APPRVD_FOREIGN_TRIP';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_APPRVD_FOREIGN_TRIP');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_APPROVED_SUBCONTRACT';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_APPROVED_SUBCONTRACT');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_CLOSEOUT';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_CLOSEOUT');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_COST_SHARING';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_COST_SHARING');
END IF;

select count(1) into li_count from user_tables where TABLE_NAME='OSP$AWARD_PAYMENT_SCHEDULE';
IF li_count>0 then
EXECUTE IMMEDIATE('DROP TABLE OSP$AWARD_PAYMENT_SCHEDULE');
END IF;
END;
/
CREATE TABLE "OSP$AWARD_APPROVED_EQUIPMENT" 
   ("MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"ITEM" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"VENDOR" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"MODEL" VARCHAR2(50 BYTE) NOT NULL ENABLE, 
	"AMOUNT" NUMBER(12,2), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE);	
	commit
	/
insert into OSP$AWARD_APPROVED_EQUIPMENT(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER)
select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,aae.ITEM,aae.VENDOR,aae.MODEL,aae.AMOUNT,aae.UPDATE_TIMESTAMP,aae.UPDATE_USER from OSP$AWARD_APPROVED_EQUIPMENT@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
 CREATE TABLE "OSP$AWARD_APPROVED_SUBCONTRACT" 
   (	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"SUBCONTRACTOR_NAME" VARCHAR2(60 BYTE) NOT NULL ENABLE, 
	"AMOUNT" NUMBER(12,2), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE);	
	commit
	/
insert into OSP$AWARD_APPROVED_SUBCONTRACT(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,SUBCONTRACTOR_NAME,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER)
select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,aae.SUBCONTRACTOR_NAME,aae.AMOUNT,aae.UPDATE_TIMESTAMP,aae.UPDATE_USER from OSP$AWARD_APPROVED_SUBCONTRACT@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
CREATE TABLE "OSP$AWARD_APPRVD_FOREIGN_TRIP" 
   (	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"PERSON_ID" VARCHAR2(9 BYTE) NOT NULL ENABLE, 
	"PERSON_NAME" VARCHAR2(90 BYTE), 
	"DESTINATION" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"DATE_FROM" DATE NOT NULL ENABLE, 
	"DATE_TO" DATE, 
	"AMOUNT" NUMBER(12,2), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE)
/
commit
/
insert into OSP$AWARD_APPRVD_FOREIGN_TRIP(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,PERSON_ID,DESTINATION,DATE_FROM,PERSON_NAME,DATE_TO,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER)
select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,aae.PERSON_ID,aae.DESTINATION,aae.DATE_FROM,aae.PERSON_NAME,aae.DATE_TO,aae.AMOUNT,aae.UPDATE_TIMESTAMP,aae.UPDATE_USER from OSP$AWARD_APPRVD_FOREIGN_TRIP@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
CREATE TABLE "OSP$AWARD_COST_SHARING" 
   (	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"FISCAL_YEAR" CHAR(4 BYTE) NOT NULL ENABLE, 
	"COST_SHARING_PERCENTAGE" NUMBER(5,2), 
	"COST_SHARING_TYPE_CODE" NUMBER(3,0) NOT NULL ENABLE, 
	"SOURCE_ACCOUNT" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"DESTINATION_ACCOUNT" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"AMOUNT" NUMBER(12,2), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE)
/
commit
/
insert into OSP$AWARD_COST_SHARING(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,FISCAL_YEAR,COST_SHARING_TYPE_CODE,SOURCE_ACCOUNT,DESTINATION_ACCOUNT,COST_SHARING_PERCENTAGE,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER)
select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,aae.FISCAL_YEAR,aae.COST_SHARING_TYPE_CODE,aae.SOURCE_ACCOUNT,aae.DESTINATION_ACCOUNT,aae.COST_SHARING_PERCENTAGE,aae.AMOUNT,aae.UPDATE_TIMESTAMP,aae.UPDATE_USER from OSP$AWARD_COST_SHARING@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
CREATE TABLE "OSP$AWARD_IDC_RATE" 
   (	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"APPLICABLE_IDC_RATE" NUMBER(5,2) NOT NULL ENABLE, 
	"IDC_RATE_TYPE_CODE" NUMBER(3,0) NOT NULL ENABLE, 
	"FISCAL_YEAR" CHAR(4 BYTE) NOT NULL ENABLE, 
	"ON_CAMPUS_FLAG" CHAR(1 BYTE) NOT NULL ENABLE, 
	"UNDERRECOVERY_OF_IDC" NUMBER(12,2), 
	"SOURCE_ACCOUNT" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"DESTINATION_ACCOUNT" VARCHAR2(100 BYTE) NOT NULL ENABLE, 
	"START_DATE" DATE NOT NULL ENABLE, 
	"END_DATE" DATE, 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE)
/
commit
/
insert into	OSP$AWARD_IDC_RATE(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,APPLICABLE_IDC_RATE,IDC_RATE_TYPE_CODE,FISCAL_YEAR,START_DATE,ON_CAMPUS_FLAG,SOURCE_ACCOUNT,
DESTINATION_ACCOUNT,UNDERRECOVERY_OF_IDC,END_DATE,UPDATE_TIMESTAMP,UPDATE_USER)
select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,aae.APPLICABLE_IDC_RATE,aae.IDC_RATE_TYPE_CODE,aae.FISCAL_YEAR,aae.START_DATE,aae.ON_CAMPUS_FLAG,aae.SOURCE_ACCOUNT,
aae.DESTINATION_ACCOUNT,aae.UNDERRECOVERY_OF_IDC,aae.END_DATE,aae.UPDATE_TIMESTAMP,aae.UPDATE_USER from OSP$AWARD_IDC_RATE@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
CREATE TABLE "OSP$AWARD_PAYMENT_SCHEDULE" 
   ("MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"DUE_DATE" DATE NOT NULL ENABLE, 
	"AMOUNT" NUMBER(12,2), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
	"SUBMIT_DATE" DATE, 
	"SUBMITTED_BY" VARCHAR2(9 BYTE), 
	"INVOICE_NUMBER" VARCHAR2(10 BYTE), 
	"STATUS_DESCRIPTION" VARCHAR2(50 BYTE));
	commit
	/
insert into OSP$AWARD_PAYMENT_SCHEDULE(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,DUE_DATE,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,SUBMIT_DATE,SUBMITTED_BY,INVOICE_NUMBER,STATUS_DESCRIPTION)	
select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,aae.DUE_DATE,aae.AMOUNT,aae.UPDATE_TIMESTAMP,aae.UPDATE_USER,aae.SUBMIT_DATE,aae.SUBMITTED_BY,aae.INVOICE_NUMBER,aae.STATUS_DESCRIPTION from OSP$AWARD_PAYMENT_SCHEDULE@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
commit
/
CREATE TABLE "OSP$AWARD_CLOSEOUT" 
   (	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"FINAL_INV_SUBMISSION_DATE" DATE, 
	"FINAL_TECH_SUBMISSION_DATE" DATE, 
	"FINAL_PATENT_SUBMISSION_DATE" DATE, 
	"FINAL_PROP_SUBMISSION_DATE" DATE, 
	"ARCHIVE_LOCATION" VARCHAR2(50 BYTE), 
	"CLOSEOUT_DATE" DATE, 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE);
	commit
	/
insert into OSP$AWARD_CLOSEOUT(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,FINAL_INV_SUBMISSION_DATE,FINAL_TECH_SUBMISSION_DATE,FINAL_PATENT_SUBMISSION_DATE,
FINAL_PROP_SUBMISSION_DATE,ARCHIVE_LOCATION,CLOSEOUT_DATE,UPDATE_TIMESTAMP,UPDATE_USER)
 select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,FINAL_INV_SUBMISSION_DATE,FINAL_TECH_SUBMISSION_DATE,FINAL_PATENT_SUBMISSION_DATE,
FINAL_PROP_SUBMISSION_DATE,ARCHIVE_LOCATION,CLOSEOUT_DATE,UPDATE_TIMESTAMP,UPDATE_USER from OSP$AWARD_CLOSEOUT@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
CREATE TABLE "OSP$AWARD_CUSTOM_DATA" 
   (	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
	"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
	"COLUMN_NAME" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"COLUMN_VALUE" VARCHAR2(2000 BYTE), 
	"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
	"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE);
	commit
	/
	insert into osp$award_custom_data(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,COLUMN_NAME,COLUMN_VALUE,UPDATE_TIMESTAMP,UPDATE_USER) 
	select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,aae.COLUMN_NAME,aae.COLUMN_VALUE,aae.UPDATE_TIMESTAMP,aae.UPDATE_USER from osp$award_custom_data@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/
CREATE TABLE "OSP$AWARD" 
(	"MIT_AWARD_NUMBER" CHAR(10 BYTE) NOT NULL ENABLE, 
"SEQUENCE_NUMBER" NUMBER(4,0) NOT NULL ENABLE, 
"MODIFICATION_NUMBER" VARCHAR2(50 BYTE), 
"SPONSOR_AWARD_NUMBER" VARCHAR2(70 BYTE), 
"STATUS_CODE" NUMBER(3,0) NOT NULL ENABLE, 
"TEMPLATE_CODE" NUMBER(5,0), 
"AWARD_EXECUTION_DATE" DATE, 
"AWARD_EFFECTIVE_DATE" DATE, 
"BEGIN_DATE" DATE, 
"SPONSOR_CODE" CHAR(6 BYTE) NOT NULL ENABLE, 
"ACCOUNT_NUMBER" VARCHAR2(100 BYTE), 
"APPRVD_EQUIPMENT_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"APPRVD_FOREIGN_TRIP_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"APPRVD_SUBCONTRACT_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"PAYMENT_SCHEDULE_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"IDC_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"TRANSFER_SPONSOR_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"COST_SHARING_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
"SPECIAL_REVIEW_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"SCIENCE_CODE_INDICATOR" CHAR(2 BYTE) NOT NULL ENABLE, 
"NSF_CODE" VARCHAR2(15 BYTE), 
"KEY_PERSON_INDICATOR" CHAR(2 BYTE) DEFAULT 'N0' NOT NULL ENABLE
)
/
commit
/
insert into OSP$AWARD(MIT_AWARD_NUMBER,SEQUENCE_NUMBER,MODIFICATION_NUMBER,SPONSOR_AWARD_NUMBER,STATUS_CODE,TEMPLATE_CODE,AWARD_EXECUTION_DATE,AWARD_EFFECTIVE_DATE,
BEGIN_DATE,SPONSOR_CODE,ACCOUNT_NUMBER,APPRVD_EQUIPMENT_INDICATOR,APPRVD_FOREIGN_TRIP_INDICATOR,APPRVD_SUBCONTRACT_INDICATOR,PAYMENT_SCHEDULE_INDICATOR,IDC_INDICATOR,
TRANSFER_SPONSOR_INDICATOR,COST_SHARING_INDICATOR,UPDATE_TIMESTAMP,UPDATE_USER,SPECIAL_REVIEW_INDICATOR,SCIENCE_CODE_INDICATOR,NSF_CODE,KEY_PERSON_INDICATOR)
select aae.MIT_AWARD_NUMBER,aae.SEQUENCE_NUMBER,MODIFICATION_NUMBER,SPONSOR_AWARD_NUMBER,STATUS_CODE,TEMPLATE_CODE,AWARD_EXECUTION_DATE,AWARD_EFFECTIVE_DATE,
BEGIN_DATE,SPONSOR_CODE,ACCOUNT_NUMBER,APPRVD_EQUIPMENT_INDICATOR,APPRVD_FOREIGN_TRIP_INDICATOR,APPRVD_SUBCONTRACT_INDICATOR,PAYMENT_SCHEDULE_INDICATOR,IDC_INDICATOR,
TRANSFER_SPONSOR_INDICATOR,COST_SHARING_INDICATOR,UPDATE_TIMESTAMP,UPDATE_USER,SPECIAL_REVIEW_INDICATOR,SCIENCE_CODE_INDICATOR,NSF_CODE,KEY_PERSON_INDICATOR
from OSP$AWARD@coeus.kuali aae
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON aae.MIT_AWARD_NUMBER=t.MIT_AWARD_NUMBER AND aae.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER
/ 
create index custom_i on OSP$AWARD_CUSTOM_DATA(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/
create index equip_i on OSP$AWARD_APPROVED_EQUIPMENT(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/
create index subawd_i on OSP$AWARD_APPROVED_SUBCONTRACT(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/  
create index foreign_i on OSP$AWARD_APPRVD_FOREIGN_TRIP(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/ 
create index share_i on OSP$AWARD_COST_SHARING(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/
create index rate_i on OSP$AWARD_IDC_RATE(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/ 
create index payment_i on OSP$AWARD_PAYMENT_SCHEDULE(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/ 
create index closeout_i on OSP$AWARD_CLOSEOUT(MIT_AWARD_NUMBER,SEQUENCE_NUMBER)
/
create index award_i on osp$award(mit_award_number,sequence_number)
/
DECLARE
ls_award_number VARCHAR2(12);
li_coeus_count number;
li_kuali_count number;
ls_mit_award_number CHAR(10);
li_seq number(4);
li_count number;

CURSOR c_award IS
 select distinct a.award_number,a.sequence_number from AWARD a
INNER JOIN TEMP_TAB_TO_SYNC_AWARD t ON a.AWARD_NUMBER=replace(t.MIT_AWARD_NUMBER,'-','-00') AND a.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER 
order by a.award_number,a.sequence_number;
r_award c_award%rowtype;

BEGIN
IF c_award%ISOPEN THEN
CLOSE c_award;
END IF;
OPEN c_award;
LOOP
FETCH c_award INTO r_award;
EXIT WHEN c_award%NOTFOUND;

ls_award_number:=r_award.award_number;
li_seq:=r_award.sequence_number;
select replace(r_award.award_number,'-00','-') into ls_mit_award_number  from dual;

--begin


     

    select count(*) Coeus_AwardCustom_Count into li_coeus_count from
    osp$award_custom_data ac,osp$award aw where ac.mit_award_number=ls_mit_award_number and aw.mit_award_number=ac.mit_award_number and ac.sequence_number=
    (select max(sequence_number) from osp$award_custom_data where mit_award_number=aw.mit_award_number and sequence_number<=aw.sequence_number)
    and aw.sequence_number=li_seq; 
    
	select count(*) KC_AwardCustom_Count into li_kuali_count from award_custom_data  where 
    award_number=ls_award_number and sequence_number=li_seq; 
    


 

IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_custom_data row count for award_number:'|| ls_award_number);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count from
    osp$award_idc_rate ac,osp$award aw where ac.mit_award_number=ls_mit_award_number and aw.mit_award_number=ac.mit_award_number
    and ac.sequence_number=
    (select max(sequence_number) from osp$award_idc_rate where mit_award_number=ac.mit_award_number and sequence_number<=aw.sequence_number)
	and aw.sequence_number=li_seq and aw.IDC_INDICATOR not in ('N0','N1'); 

	select count(1) KC_AwardCustom_Count into li_kuali_count from award_idc_rate  where 
    award_number=ls_award_number and sequence_number=li_seq;

IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_idc_rate row count for award_number:'|| ls_award_number);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count from
    osp$award_approved_equipment ac,osp$award aw where ac.mit_award_number=ls_mit_award_number and aw.mit_award_number=ac.mit_award_number
    and ac.sequence_number=
    (select max(sequence_number) from osp$award_approved_equipment where mit_award_number=ac.mit_award_number and sequence_number<=aw.sequence_number)
	and aw.sequence_number=li_seq and aw.APPRVD_EQUIPMENT_INDICATOR not in ('N0','N1'); 

	select count(1) KC_AwardCustom_Count into li_kuali_count from award_approved_equipment  where 
    award_number=ls_award_number and sequence_number=li_seq;

IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_approved_equipment row count for award_number:'|| ls_award_number);
END IF;

select count(1) Coeus_AwardCustom_Count into li_coeus_count from
 osp$award_apprvd_foreign_trip ac,osp$award aw where ac.mit_award_number=ls_mit_award_number and aw.mit_award_number=ac.mit_award_number
 and ac.sequence_number=
 (select max(sequence_number) from osp$award_apprvd_foreign_trip where mit_award_number=ac.mit_award_number and sequence_number<=aw.sequence_number)
 and aw.sequence_number=li_seq and aw.APPRVD_FOREIGN_TRIP_INDICATOR not in ('N0','N1'); 

	select count(1) KC_AwardCustom_Count into li_kuali_count from AWARD_APPROVED_FOREIGN_TRAVEL  where 
    award_number=ls_award_number and sequence_number=li_seq;

IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_apprvd_foreign_travel row count for award_number:'|| ls_award_number);
END IF;	

select count(1) Coeus_AwardCustom_Count into li_coeus_count from
 osp$award_approved_subcontract ac,osp$award aw where ac.mit_award_number=ls_mit_award_number and aw.mit_award_number=ac.mit_award_number
 and ac.sequence_number=
 (select max(sequence_number) from osp$award_approved_subcontract where mit_award_number=ac.mit_award_number and sequence_number<=aw.sequence_number)
 and aw.sequence_number=li_seq and aw.APPRVD_SUBCONTRACT_INDICATOR not in ('N0','N1');

	select count(1) KC_AwardCustom_Count into li_kuali_count from award_approved_subawards  where 
    award_number=ls_award_number and sequence_number=li_seq;

IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_approved_subawards row count for award_number:'|| ls_award_number);
END IF;	

select (count(1)*4) Coeus_AwardCustom_Count into li_coeus_count  from osp$award_closeout  where 
    mit_award_number=ls_mit_award_number and sequence_number=li_seq;

	select count(1) KC_AwardCustom_Count into li_kuali_count from award_closeout  where 
    award_number=ls_award_number and sequence_number=li_seq;
	
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_closeout row count for award_number:'|| ls_award_number);
END IF;	
	
select count(1) Coeus_AwardCustom_Count into li_coeus_count from
 osp$award_cost_sharing ac,osp$award aw where ac.mit_award_number=ls_mit_award_number and aw.mit_award_number=ac.mit_award_number
 and ac.sequence_number=
 (select max(sequence_number) from osp$award_cost_sharing where mit_award_number=ac.mit_award_number and sequence_number<=aw.sequence_number)
 and aw.sequence_number=li_seq and aw.COST_SHARING_INDICATOR not in ('N0','N1');

	select count(1) KC_AwardCustom_Count into li_kuali_count from award_cost_share  where 
    award_number=ls_award_number and sequence_number=li_seq;

IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_cost_share row count for award_number:'|| ls_award_number);
END IF;	

select count(1) Coeus_AwardCustom_Count into li_coeus_count from
  osp$award_payment_schedule ac,osp$award aw where ac.mit_award_number=ls_mit_award_number and aw.mit_award_number=ac.mit_award_number
 and ac.sequence_number=
 (select max(sequence_number) from  osp$award_payment_schedule where mit_award_number=ac.mit_award_number and sequence_number<=aw.sequence_number)
 and aw.sequence_number=li_seq and aw.PAYMENT_SCHEDULE_INDICATOR not in ('N0','N1');

	select count(1) KC_AwardCustom_Count into li_kuali_count from award_payment_schedule  where 
    award_number=ls_award_number and sequence_number=li_seq;
	
IF li_kuali_count!=li_coeus_count THEN
dbms_output.put_line('change in award_payment_schedule row count for award_number:'|| ls_award_number);
END IF;	

commit;
END LOOP;
CLOSE c_award;
END;
/
DROP TABLE OSP$AWARD
/
DROP TABLE OSP$AWARD_CUSTOM_DATA
/
DROP TABLE OSP$AWARD_APPROVED_EQUIPMENT
/
DROP TABLE OSP$AWARD_APPROVED_SUBCONTRACT
/
DROP TABLE OSP$AWARD_APPRVD_FOREIGN_TRIP
/
DROP TABLE OSP$AWARD_COST_SHARING
/
DROP TABLE OSP$AWARD_IDC_RATE
/
DROP TABLE OSP$AWARD_PAYMENT_SCHEDULE
/
DROP TABLE OSP$AWARD_CLOSEOUT
/