declare
cursor c_data is
select 'Initiate Document' nm from dual
UNION ALL
select 'VIEW NEGOTIATION - UNRESTRICTED' nm from dual
UNION ALL
select 'CREATE NEGOTIATION' nm from dual
UNION ALL
select 'MODIFY NEGOTIATION' nm from dual;
r_data c_data%rowtype;

li_count number;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

  select distinct count(r4.role_nm) into li_count
  from krim_perm_t r1
  inner join krim_role_perm_t r3 on r1.perm_id = r3.perm_id
  inner join krim_role_t r4 on r4.role_id = r3.role_id
  where  r1.nm = r_data.nm
  and  r4.role_nm = 'Negotiation Administrator';
  
  if li_count = 0 then
    INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
    VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
    (select role_id from krim_role_t where role_nm = 'Negotiation Administrator'),
    (select perm_id from krim_perm_t where  nm = r_data.nm),    
    'Y');    
   
  end if;
  
end loop;
close c_data;

end;
/
commit
/
