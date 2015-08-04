ALTER TABLE SUBAWARD_CLOSEOUT DROP CONSTRAINT UQ_SUBAWARD_CLOSEOUT
/
DROP INDEX UQ_SUBAWARD_CLOSEOUT
/
CREATE TABLE TMP_SUAWD_CLOSEOUT_NUM(
  SUBAWARD_CLOSEOUT_ID	NUMBER(12,0),
  CLOSEOUT_NUMBER	NUMBER(3,0),
  CLOSEOUT_TYPE_CODE	NUMBER(3,0),
  SEQUENCE_NUMBER	NUMBER(4,0),
  SUBAWARD_CODE	VARCHAR2(20)
)
/
delete from TMP_SUAWD_CLOSEOUT_NUM
/
set serveroutput on;
declare
 li_closeout_number subaward_closeout.closeout_number%type;
 li_count number;
 ls_empty_date date := to_date('01/01/1901','MM/DD/YYYY')  ;
cursor c_data is
  select subaward_closeout_id,closeout_type_code, date_requested,
  date_followup, date_received, sequence_number, subaward_code
  from SUBAWARD_CLOSEOUT
  where subaward_code in (select to_number(Subcontract_code) from Osp$Subcontract_Closeout@coeus.kuali);
r_data c_data%rowtype;
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
    li_closeout_number := NULL;
    
    select count(*) into li_count from Osp$Subcontract_Closeout@coeus.kuali t1
    where to_number(t1.Subcontract_code) = r_data.subaward_code
    and t1.sequence_number = (  select max(t2.sequence_number) from Osp$Subcontract_Closeout@coeus.kuali t2 
                                where t2.Subcontract_code = t1.Subcontract_code
                                and t2.sequence_number <= r_data.sequence_number
                              )
    and t1.closeout_type_code = r_data.closeout_type_code
    and nvl(t1.date_requested,ls_empty_date) = nvl(r_data.date_requested,ls_empty_date)
    and nvl(t1.date_followup,ls_empty_date) = nvl(r_data.date_followup,ls_empty_date)
    and nvl(t1.date_received,ls_empty_date) = nvl(r_data.date_received,ls_empty_date);
    
    if li_count > 1 then
    
        select min(closeout_number) into li_closeout_number from Osp$Subcontract_Closeout@coeus.kuali t1
        where to_number(t1.Subcontract_code) = r_data.subaward_code
        and t1.sequence_number = (  select max(t2.sequence_number) from Osp$Subcontract_Closeout@coeus.kuali t2 
                                    where t2.Subcontract_code = t1.Subcontract_code
                                    and t2.sequence_number <= r_data.sequence_number
                                  )
        and t1.closeout_type_code = r_data.closeout_type_code 
        and nvl(t1.date_requested,ls_empty_date) = nvl(r_data.date_requested,ls_empty_date)
        and nvl(t1.date_followup,ls_empty_date) = nvl(r_data.date_followup,ls_empty_date)
        and nvl(t1.date_received,ls_empty_date) = nvl(r_data.date_received,ls_empty_date)
        and t1.closeout_number not in ( select closeout_number from TMP_SUAWD_CLOSEOUT_NUM 
                                        where subaward_code = r_data.subaward_code
                                        and sequence_number = r_data.sequence_number
                                        and closeout_type_code = r_data.closeout_type_code);
                                        
        INSERT INTO TMP_SUAWD_CLOSEOUT_NUM(SUBAWARD_CLOSEOUT_ID,CLOSEOUT_NUMBER,CLOSEOUT_TYPE_CODE,SEQUENCE_NUMBER,SUBAWARD_CODE)  
        VALUES(r_data.subaward_closeout_id,li_closeout_number,r_data.closeout_type_code,r_data.sequence_number,r_data.subaward_code);
     
       
      --dbms_output.put_line('Count = '||li_count||', subaward_closeout_id = '||r_data.subaward_closeout_id);
    
    elsif   li_count = 1 then
       select closeout_number into li_closeout_number from Osp$Subcontract_Closeout@coeus.kuali t1
        where to_number(t1.Subcontract_code) = r_data.subaward_code
        and t1.sequence_number = (  select max(t2.sequence_number) from Osp$Subcontract_Closeout@coeus.kuali t2 
                                    where t2.Subcontract_code = t1.Subcontract_code
                                    and t2.sequence_number <= r_data.sequence_number
                                  )
        and t1.closeout_type_code = r_data.closeout_type_code
        and nvl(t1.date_requested,ls_empty_date) = nvl(r_data.date_requested,ls_empty_date)
        and nvl(t1.date_followup,ls_empty_date) = nvl(r_data.date_followup,ls_empty_date)
        and nvl(t1.date_received,ls_empty_date) = nvl(r_data.date_received,ls_empty_date);
      
    end if;
  
  
  UPDATE SUBAWARD_CLOSEOUT SET closeout_number = li_closeout_number
  WHERE subaward_closeout_id = r_data.subaward_closeout_id;
  
  end loop;
  close c_data;
  
end;
/
commit
/
declare 
cursor c_data is
  select row_number() over (PARTITION by subaward_code,sequence_number order by subaward_code,sequence_number ) CLOSEOUT_NUM,
  subaward_code,sequence_number,subaward_closeout_id 
  from   SUBAWARD_CLOSEOUT WHERE CLOSEOUT_NUMBER IS NULL;
  r_data c_data%rowtype;
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;   

    UPDATE SUBAWARD_CLOSEOUT SET closeout_number = r_data.closeout_num
    WHERE subaward_closeout_id = r_data.subaward_closeout_id;
  
  end loop;
  close c_data;
  
end;
/
commit
/
drop table TMP_SUAWD_CLOSEOUT_NUM
/