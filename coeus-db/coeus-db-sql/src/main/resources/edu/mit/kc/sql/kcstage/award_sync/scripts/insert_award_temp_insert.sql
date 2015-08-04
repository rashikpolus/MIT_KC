declare
li_count number;
begin
select count(*) into li_count from user_tables where table_name='temp_award_insert';
if li_count>0 then
execute immediate('drop table temp_award_insert');
end if;
end;
/
create table temp_award_insert(
FEED_ID NUMBER(10,0),
MIT_AWARD_NUMBER CHAR(10),
SEQUENCE_NUMBER NUMBER(4,0),
FEED_TYPE  CHAR(1);
);


INSERT INTO temp_award_insert(FEED_ID,MIT_AWARD_NUMBER,SEQUENCE_NUMBER,FEED_TYPE)
SELECT FEED_ID,MIT_AWARD_NUMBER,SEQUENCE_NUMBER,FEED_TYPE from
OSP$SAP_FEED_DETAILS@coeus.kuali where FEED_ID not in (select FEED_ID FROM temp_feed_data)
and FEED_TYPE='N'; 

commit;
/