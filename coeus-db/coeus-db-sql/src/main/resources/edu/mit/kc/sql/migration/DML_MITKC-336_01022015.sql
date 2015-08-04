declare
cursor c_data is
  select unit_number, osp_administrator, update_timestamp, update_user from osp$unit@coeus.kuali
  where osp_administrator is not null;
r_data c_data%rowtype;
li_count number;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

select count(unit_number) into li_count from unit_administrator 
where unit_number = r_data.unit_number 
and  unit_administrator_type_code= 2; --OSP_ADMINISTRATOR

if li_count = 0 then
  INSERT INTO UNIT_ADMINISTRATOR(
  UNIT_NUMBER,
  PERSON_ID,
  UNIT_ADMINISTRATOR_TYPE_CODE,
  UPDATE_TIMESTAMP,
  UPDATE_USER,
  VER_NBR,
  OBJ_ID)
  VALUES(
  r_data.unit_number,
  r_data.osp_administrator,
  2,
  r_data.update_timestamp,
  r_data.update_user,
  1,
  sys_guid()
  );
else
  UPDATE UNIT_ADMINISTRATOR
  SET PERSON_ID = r_data.osp_administrator
  WHERE unit_number = r_data.unit_number 
  AND  unit_administrator_type_code= 2; --OSP_ADMINISTRATOR 
  
end if;

end loop;
close c_data;

end;
/
commit
/
