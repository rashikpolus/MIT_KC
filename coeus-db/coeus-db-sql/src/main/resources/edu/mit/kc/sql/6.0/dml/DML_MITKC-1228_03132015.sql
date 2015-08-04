declare
li_count number;
begin
  select count(cost_element) into li_count from cost_element where cost_element = 'PCARRY';
  if li_count = 0 then
    INSERT INTO cost_element(
    cost_element,
    description,
    budget_category_code,
    on_off_campus_flag,
    update_timestamp,
    update_user,
    ver_nbr,
    obj_id,
    active_flag,
    fin_object_code
    )
    VALUES(
    'PCARRY',
    'Carryforward adjustment',
    19,--Other Operating Expenses
    'N',
    sysdate,
    'admin',
    1,
    sys_guid(),
    'Y',
    null
    );
  end if;
  
  select count(cost_element) into li_count from cost_element where cost_element = 'PCLOSE';
  if li_count = 0 then
    INSERT INTO cost_element(
    cost_element,
    description,
    budget_category_code,
    on_off_campus_flag,
    update_timestamp,
    update_user,
    ver_nbr,
    obj_id,
    active_flag,
    fin_object_code
    )
    VALUES(
    'PCLOSE',
    'Closeout adjustment',
    19,----Other Operating Expenses
    'N',
    sysdate,
    'admin',
    1,
    sys_guid(),
    'Y',
    null
    );
  end if;

  select count(cost_element) into li_count from cost_element where cost_element = 'PINCRT';
  if li_count = 0 then
    INSERT INTO cost_element(
    cost_element,
    description,
    budget_category_code,
    on_off_campus_flag,
    update_timestamp,
    update_user,
    ver_nbr,
    obj_id,
    active_flag,
    fin_object_code
    )
    VALUES(
    'PINCRT',
    'Increment adjustment',
    19,--Other Operating Expenses
    'N',
    sysdate,
    'admin',
    1,
    sys_guid(),
    'Y',
    null
    );
  end if;

end;
/
commit
/
