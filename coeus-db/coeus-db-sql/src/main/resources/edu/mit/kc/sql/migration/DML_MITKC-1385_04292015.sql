-- Ordering the start date in chronological order and inserting to a temp table
drop table TMP_NEGOTIATION_ACTIVITY
/
CREATE TABLE TMP_NEGOTIATION_ACTIVITY(
TMP_ID 	NUMBER(22,0),
NEGOTIATION_ACTIVITY_ID	NUMBER(22,0),
NEGOTIATION_ID	NUMBER(22,0),
LOCATION_ID	NUMBER(22,0),
ACTIVITY_TYPE_ID	NUMBER(22,0),
START_DATE	DATE
)
/
INSERT INTO tmp_negotiation_activity(tmp_id,negotiation_activity_id,negotiation_id,location_id,activity_type_id,start_date)
select 
  rownum,
  NEGOTIATION_ACTIVITY_ID,
  NEGOTIATION_ID,
  LOCATION_ID,
  ACTIVITY_TYPE_ID,
  START_DATE
from (  
    SELECT
    NEGOTIATION_ACTIVITY_ID,
    NEGOTIATION_ID,
    LOCATION_ID,
    ACTIVITY_TYPE_ID,
    START_DATE
    FROM NEGOTIATION_ACTIVITY order by NEGOTIATION_ID,START_DATE
)
/
commit
/
declare
ls_start_date negotiation_activity.start_date%type;
cursor c_nego is
  select t1.negotiation_id,t3.TMP_ID, t2.negotiation_number, t2.activity_number, t2.negotiation_activity_id,t1.start_date
  from negotiation_activity t1
  inner join temp_negotiation_act_id t2 on t2.negotiation_activity_id = t1.negotiation_activity_id
  inner join tmp_negotiation_activity t3 on t3.negotiation_activity_id = t1.negotiation_activity_id
  order by t2.negotiation_activity_id;
  r_nego c_nego%rowtype;
  
  li_nego_loc_type_code	number(3,0);
  ls_end_date	date;
  li_count number;  
begin
  open c_nego;
  loop
  fetch c_nego into r_nego;
  exit when c_nego%notfound;
  
  begin 
     	
	 SELECT t1.start_date into ls_start_date FROM tmp_negotiation_activity t1
	 WHERE t1.negotiation_id = r_nego.negotiation_id	
	 AND  t1.tmp_id IN ( SELECT MIN(t2.tmp_id) FROM tmp_negotiation_activity t2 
						 WHERE t2.negotiation_id = t2.negotiation_id
						 AND  t2.tmp_id  > r_nego.tmp_id );
    
  exception
  when others then
  ls_start_date := null;
  end;
  
  begin 
  if ls_start_date is null then  
  
		 select count(negotiation_end_date) into li_count from negotiation where negotiation_id = r_nego.negotiation_id and negotiation_end_date is not null;
		 if li_count = 1 then
			 select negotiation_end_date into ls_end_date from negotiation where negotiation_id = r_nego.negotiation_id and negotiation_end_date is not null;		 
		 else
			ls_end_date := sysdate;
		 end if;
                                           
   else 
		ls_end_date := ls_start_date;
   end if;

	begin
		select t1.negotiation_location_type_code
		into li_nego_loc_type_code
		FROM osp$negotiation_location@coeus.kuali t1
		where t1.negotiation_number = r_nego.negotiation_number
		and t1.location_number = ( select max(location_number) from osp$negotiation_location@coeus.kuali t2 
									   where t2.negotiation_number = t1.negotiation_number									 
									   and  t2.effective_date < to_date(ls_end_date)); 
	exception								   
	when others then     
		li_nego_loc_type_code := 1;
    end;								   
   
    update negotiation_activity set END_DATE = ls_end_date, LOCATION_ID = li_nego_loc_type_code
    where negotiation_activity_id =  r_nego.negotiation_activity_id;      
  -- dbms_output.put_line(r_nego.negotiation_activity_id||','|| r_nego.negotiation_number||',  '||li_nego_loc_type_code||' , '||'Updated');
   
   exception
   when others then     
    --dbms_output.put_line( r_nego.negotiation_number||',  '||r_nego.start_date||' , '||sqlerrm);
   continue;
   end;
    
  end loop;
  close c_nego;

end;
/
commit
/
DROP TABLE TMP_NEGOTIATION_ACTIVITY
/
