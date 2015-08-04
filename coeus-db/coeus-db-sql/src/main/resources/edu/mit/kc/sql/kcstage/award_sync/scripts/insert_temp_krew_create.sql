declare
li_count number;
begin
select count(*) into li_count from user_tables where table_name='TEMP_KREW_SYNC';
if li_count>0 then
execute immediate('drop table TEMP_KREW_SYNC');
end if;
end;
/
create table TEMP_KREW_SYNC(
DOCUMENT_NUMBER VARCHAR2(40),
RTE_BRCH_ID VARCHAR2(40),
RTE_NODE_ID VARCHAR2(40),
RTE_NODE_INSTN_ID VARCHAR2(40),
MODULE VARCHAR2(20))
/