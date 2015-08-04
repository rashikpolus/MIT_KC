declare
li_count number;
begin
  select  count(table_name) into li_count  from user_tables   where table_name = 'SYNC_AWARD_LOG';
  if li_count = 0 then
        execute immediate('CREATE TABLE SYNC_AWARD_LOG  (
                          feed_id	        NUMBER(10,0),
                          execution_date  DATE
                          )');       
       
  end if;

  select  count(table_name) into li_count  from user_tables   where table_name = 'TEMP_TAB_TO_SYNC_AWARD';
  if li_count > 0 then
   execute immediate('DROP TABLE TEMP_TAB_TO_SYNC_AWARD');
     
  end if;
  
  select  count(table_name) into li_count  from user_tables   where table_name = 'TEMP_TAB_TO_SYNC_IP';
  if li_count > 0 then
   execute immediate('DROP TABLE TEMP_TAB_TO_SYNC_IP');
     
  end if;  
  
  select  count(table_name) into li_count  from user_tables   where table_name = 'TEMP_TAB_TO_SYNC_DEV';
  if li_count > 0 then
   execute immediate('DROP TABLE TEMP_TAB_TO_SYNC_DEV');
     
  end if;    
  
  select  count(table_name) into li_count  from user_tables   where table_name = 'TEMP_TAB_TO_SYNC_BUDGET';
  if li_count > 0 then
   execute immediate('DROP TABLE TEMP_TAB_TO_SYNC_BUDGET');
     
  end if; 
 
 select  count(table_name) into li_count  from user_tables   where table_name = 'SYNC_EPS_ALREADY_PRESENT';
  if li_count > 0 then
   execute immediate('DROP TABLE SYNC_EPS_ALREADY_PRESENT');
     
  end if; 

end;
/
declare
li_count NUMBER;
ll_migration_exe_date date := sysdate;
begin
select count(feed_id) into li_count from SYNC_AWARD_LOG;

if li_count = 0 then
        INSERT INTO SYNC_AWARD_LOG(
         feed_id,
         execution_date
         )
         select distinct feed_id,ll_migration_exe_date from osp$sap_feed_details@coeus.kuali t1  
         inner join award t2 on replace(t1.mit_award_number,'-','-00') = t2.award_number
         and t1.sequence_number = t2.sequence_number
		 and t1.update_timestamp < (ll_migration_exe_date - 7);
         
         commit;
         
         INSERT INTO SYNC_AWARD_LOG(
         feed_id,
         execution_date
         )
         select distinct feed_id,ll_migration_exe_date from osp$sap_feed_details@coeus.kuali t1  
         inner join KC_MIG_AWARD_CONV t2 on replace(t1.mit_award_number,'-','-00') = t2.award_number
		 and t1.update_timestamp < (ll_migration_exe_date - 7);
         
         commit;
end if;

end;
/
CREATE TABLE TEMP_TAB_TO_SYNC_AWARD(
mit_award_number VARCHAR2(10),
sequence_number NUMBER(4,0),
feed_id	        NUMBER(10,0),
feed_type CHAR(1)
)
/
insert into TEMP_TAB_TO_SYNC_AWARD(
mit_award_number,
sequence_number,
feed_id,
feed_type
)
select t.mit_award_number,t.sequence_number,t.feed_id, t.feed_type from
(
select t1.mit_award_number,t1.sequence_number,t1.feed_id, t1.feed_type 
from osp$sap_feed_details@coeus.kuali t1 
where t1.feed_id = (select max(s1.feed_id) from osp$sap_feed_details@coeus.kuali s1
where s1.mit_award_number = t1.mit_award_number
and  s1.sequence_number = t1.sequence_number and s1.feed_type = t1.feed_type)
)t
left outer join SYNC_AWARD_LOG t2
on t.feed_id = t2.feed_id
where t2.feed_id is null
/
commit
/
CREATE INDEX TEMP_TAB_TO_SYNC_AWARD_I1 ON TEMP_TAB_TO_SYNC_AWARD(mit_award_number,sequence_number)
/
declare

cursor c_tab is
select t.mit_award_number,t.sequence_number,feed_type,a.award_number,t.feed_id from temp_tab_to_sync_award t
left outer join award a on t.mit_award_number=replace(a.award_number,'-00','-') and t.sequence_number=a.sequence_number;
--where a.award_number is null;
r_tab c_tab%rowtype;

begin
if c_tab%isopen then
close c_tab;
end if;
open c_tab;
loop
fetch c_tab into r_tab;
exit when c_tab%notfound;

if r_tab.award_number is null then
update temp_tab_to_sync_award
set feed_type='N'
where feed_id = r_tab.feed_id;

else
update temp_tab_to_sync_award
set feed_type='C'
where feed_id = r_tab.feed_id;

end if;


end loop;
close c_tab;
end;
/
commit
/
CREATE TABLE TEMP_TAB_TO_SYNC_IP(
PROPOSAL_NUMBER VARCHAR2(10),
sequence_number NUMBER(4,0),
feed_type CHAR(1)
)
/
insert into TEMP_TAB_TO_SYNC_IP(
PROPOSAL_NUMBER,
sequence_number,
feed_type
)
select distinct t1.PROPOSAL_NUMBER,
       t1.PROP_SEQUENCE_NUMBER,      
      decode( ( select count(PROPOSAL_NUMBER) from proposal 
      where proposal_number =  t1.PROPOSAL_NUMBER
      and  sequence_number = t1.PROP_SEQUENCE_NUMBER),0,'N','C' )FEED_TYPE
from OSP$AWARD_FUNDING_PROPOSALS@coeus.kuali t1
inner join TEMP_TAB_TO_SYNC_AWARD t2 on t1.mit_award_number = t2.mit_award_number and t1.sequence_number = t2.sequence_number
/
commit
/
CREATE INDEX TEMP_TAB_TO_SYNC_IP_I1 ON TEMP_TAB_TO_SYNC_IP(PROPOSAL_NUMBER,sequence_number)
/
declare

cursor c_tab is
select t.proposal_number,t.sequence_number,feed_type from temp_tab_to_sync_ip t
left outer join proposal a on t.proposal_number=a.proposal_number and t.sequence_number=a.sequence_number
where a.proposal_number is null;
r_tab c_tab%rowtype;

begin
if c_tab%isopen then
close c_tab;
end if;
open c_tab;
loop
fetch c_tab into r_tab;
exit when c_tab%notfound;


	update temp_tab_to_sync_ip
	set feed_type='N'
	where proposal_number = r_tab.proposal_number
	and  sequence_number = r_tab.sequence_number;	



end loop;
close c_tab;
end;
/
commit
/
CREATE TABLE TEMP_TAB_TO_SYNC_DEV(
PROPOSAL_NUMBER VARCHAR2(10),
feed_type CHAR(1)
)
/
insert into TEMP_TAB_TO_SYNC_DEV(
PROPOSAL_NUMBER,
feed_type
)
select distinct t3.DEV_PROPOSAL_NUMBER,      
      decode( ( select count(PROPOSAL_NUMBER) from eps_proposal 
               where proposal_number =  to_number(t3.DEV_PROPOSAL_NUMBER)
              ),0,'N','C' )FEED_TYPE
from OSP$AWARD_FUNDING_PROPOSALS@coeus.kuali t1
inner join TEMP_TAB_TO_SYNC_AWARD t2 on t1.mit_award_number = t2.mit_award_number and t1.sequence_number = t2.sequence_number
inner join OSP$PROPOSAL_ADMIN_DETAILS@coeus.kuali t3 on t3.INST_PROPOSAL_NUMBER = t1.PROPOSAL_NUMBER
/
commit
/
CREATE INDEX TEMP_TAB_TO_SYNC_DEV_I1 ON TEMP_TAB_TO_SYNC_DEV(PROPOSAL_NUMBER)
/
CREATE TABLE TEMP_TAB_TO_SYNC_BUDGET(
PROPOSAL_NUMBER VARCHAR2(10),
VERSION_NUMBER	NUMBER(3,0),
feed_type CHAR(1)
)
/
INSERT INTO TEMP_TAB_TO_SYNC_BUDGET(
PROPOSAL_NUMBER,
VERSION_NUMBER,
FEED_TYPE
)
select distinct t3.DEV_PROPOSAL_NUMBER, 
		t4.VERSION_NUMBER,
      decode( ( select count(PROPOSAL_NUMBER) from eps_proposal 
               where proposal_number =  to_number(t3.DEV_PROPOSAL_NUMBER)
              ),0,'N','C' )FEED_TYPE
from OSP$AWARD_FUNDING_PROPOSALS@coeus.kuali t1
inner join TEMP_TAB_TO_SYNC_AWARD t2 on t1.mit_award_number = t2.mit_award_number and t1.sequence_number = t2.sequence_number
inner join OSP$PROPOSAL_ADMIN_DETAILS@coeus.kuali t3 on t3.INST_PROPOSAL_NUMBER = t1.PROPOSAL_NUMBER
inner join ( select PROPOSAL_NUMBER,VERSION_NUMBER from OSP$BUDGET@coeus.kuali ) t4 on t3.DEV_PROPOSAL_NUMBER = t4.PROPOSAL_NUMBER
/
CREATE TABLE SYNC_EPS_ALREADY_PRESENT(
PROPOSAL_NUMBER VARCHAR2(10)
)
/
delete from temp_tab_to_sync_award t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_award t2 where t1.mit_award_number = t2.mit_award_number
and t2.sequence_number = t1.sequence_number and t1.feed_type = t2.feed_type
)
/
delete from temp_tab_to_sync_award t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_award t2 where t1.mit_award_number = t2.mit_award_number
and t2.sequence_number = t1.sequence_number  and t2.feed_type <> 'N'
)
/
commit
/
delete from temp_tab_to_sync_ip t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_ip t2 where t1.proposal_number = t2.proposal_number
and t2.sequence_number = t1.sequence_number and t1.feed_type = t2.feed_type
)
/
delete from temp_tab_to_sync_ip t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_ip t2 where t1.proposal_number = t2.proposal_number
and t2.sequence_number = t1.sequence_number and t2.feed_type <> 'N'
)
/
commit
/
delete from temp_tab_to_sync_dev t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_dev t2 where t1.proposal_number = t2.proposal_number
and t1.feed_type = t2.feed_type
)
/
delete from temp_tab_to_sync_dev t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_dev t2 where t1.proposal_number = t2.proposal_number and t2.feed_type <> 'N'
)
/
commit
/
delete from temp_tab_to_sync_budget t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_budget t2 where t1.proposal_number = t2.proposal_number
and t2.version_number = t1.version_number and t1.feed_type = t2.feed_type
)
/
delete from temp_tab_to_sync_budget t1 where rowid not in (
select max(t2.rowid) from temp_tab_to_sync_budget t2 where t1.proposal_number = t2.proposal_number
and t2.version_number = t1.version_number  and t2.feed_type <> 'N'
)
/
commit
/