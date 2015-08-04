set serveroutput on
/
declare
ls_start_date negotiation_activity.start_date%type;
cursor c_nego is
  select t2.negotiation_number, t2.activity_number, t2.negotiation_activity_id,t1.start_date
  from negotiation_activity t1
  inner join temp_negotiation_act_id t2 on t2.negotiation_activity_id = t1.negotiation_activity_id
  order by t2.negotiation_activity_id;
  r_nego c_nego%rowtype;
  
  li_nego_loc_type_code	number(3,0);
  ls_effective_date	date;
  
begin
  open c_nego;
  loop
  fetch c_nego into r_nego;
  exit when c_nego%notfound;
  
  begin
    select ACTIVITY_DATE into ls_start_date from osp$negotiation_activities@coeus.kuali
    where NEGOTIATION_NUMBER = r_nego.negotiation_number
    and activity_number = ( r_nego.activity_number + 1);
    
  exception
  when others then
  ls_start_date := null;
  end;
  
   begin 
  if ls_start_date is null then  
          select t1.negotiation_location_type_code, t1.effective_date
          into li_nego_loc_type_code,ls_effective_date
          FROM osp$negotiation_location@coeus.kuali t1
          where t1.negotiation_number = r_nego.negotiation_number
          and t1.location_number = ( select min(location_number) from osp$negotiation_location@coeus.kuali t2 
                                     where t2.negotiation_number = t2.negotiation_number
                                     and  t2.effective_date  >= r_nego.start_date);  
                                     
   else                                   
        select t1.negotiation_location_type_code, t1.effective_date
        into li_nego_loc_type_code,ls_effective_date
        FROM osp$negotiation_location@coeus.kuali t1
        where t1.negotiation_number = r_nego.negotiation_number
        and t1.location_number = ( select max(location_number) from osp$negotiation_location@coeus.kuali t2 
                                   where t2.negotiation_number = t2.negotiation_number
                                   and  t2.effective_date  >= r_nego.start_date
                                   and  t2.effective_date <= ls_start_date);  
   
   end if;  
   update negotiation_activity set END_DATE = ls_effective_date, LOCATION_ID = li_nego_loc_type_code
   where negotiation_activity_id =  r_nego.negotiation_activity_id;      
  -- dbms_output.put_line(r_nego.negotiation_activity_id||','|| r_nego.negotiation_number||',  '||li_nego_loc_type_code||' , '||'Updated');
   
   exception
   when others then     
    dbms_output.put_line( r_nego.negotiation_number||',  '||r_nego.start_date||' , '||sqlerrm);
   continue;
   end;
    
  end loop;
  close c_nego;

end;
/
commit
/

