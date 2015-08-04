declare
  li_count number;
begin
  select count(special_review_code) into li_count from special_review where special_review_code = 16;
  if li_count = 0 then
    INSERT INTO special_review(special_review_code,description,update_timestamp,update_user,ver_nbr,obj_id,sort_id)
    VALUES(16,'Human Subjects Ceded',sysdate,'admin',1,sys_guid(),16);
  end if;  
  
end;
/
commit
/
