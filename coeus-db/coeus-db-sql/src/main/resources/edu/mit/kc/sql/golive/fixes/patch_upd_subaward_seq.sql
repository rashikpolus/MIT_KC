declare
ls_max_val NUMBER(12,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin
 
  SELECT MAX(to_number(SUBAWARD_CODE)) INTO ls_max_val  FROM SUBAWARD;   
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select SUBAWARD_CODE_S.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence SUBAWARD_CODE_S increment by '||li_increment);
    select SUBAWARD_CODE_S.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence SUBAWARD_CODE_S increment by 1');
  end if;

end;
/
