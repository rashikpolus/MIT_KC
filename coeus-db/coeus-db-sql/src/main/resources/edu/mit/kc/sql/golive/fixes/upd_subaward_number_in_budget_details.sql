set serveroutput on;
ALTER TABLE BUDGET_DETAILS DISABLE CONSTRAINT FK2_BUDGET_DETAILS;
declare
  cursor c_data is
  select s1.sub_award_number, s2.budget_details_id from
   (
    select distinct t3.budget_period_number,t2.budget_id,t1.budget_period,t1.line_item_number,t1.sub_award_number
    from  OSP$BUDGET_DETAILS@coeus.kuali t1 
    inner join TEMP_BUDGET_MAIN t2 on t2.proposal_num = t1.proposal_number and t2.budget_ver_num = t1.VERSION_NUMBER
    inner join budget_periods t3 on t3.budget_id = t2.budget_id and t3.budget_period = t1.BUDGET_PERIOD
    where  t1.SUB_AWARD_NUMBER is not null
    ) s1 inner join budget_details s2 on s1.budget_period_number = s2.budget_period_number and s1.budget_id = s2.budget_id
    and s1.budget_period = s2.budget_period and s1.line_item_number = s2.line_item_number
    where s2.subaward_number is null;
    
  r_data c_data%rowtype;
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
    begin
    
        UPDATE budget_details
        SET subaward_number = r_data.sub_award_number
        WHERE budget_details_id = r_data.budget_details_id;
        
    exception
    when others then
        dbms_output.put_line('Error occured (subaward_number,budget_details_id) is '||r_data.sub_award_number||' , '
        ||r_data.budget_details_id||sqlerrm);
     end; 
  end loop;
  close c_data;

end;
/
commit
/
