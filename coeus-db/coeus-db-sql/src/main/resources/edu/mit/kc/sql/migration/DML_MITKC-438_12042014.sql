INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve RICE Document'),
'Y')
/
INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve Document'),
'Y')
/
INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve AwardDocument'),
'Y')
/
INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve AwardBudgetDocument'),
'Y')
/
declare
cursor c_data is
select 'Modify Negotiations' role_nm from dual
UNION ALL
select 'Negotiation Administrator' role_nm from dual
UNION ALL
select 'Negotiation SuperUser' role_nm from dual
UNION ALL
select 'Negotiator' role_nm from dual;
r_data c_data%rowtype;

li_count number;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

  select distinct count(r4.nm) into li_count
  from krim_role_t r1
  inner join krim_role_perm_t r3 on r1.role_id = r3.role_id
  inner join krim_perm_t r4 on r4.perm_id = r3.perm_id
  where  r1.role_nm = r_data.role_nm
  and  r4.nm = 'Initiate Document';
  
  if li_count = 0 then
    INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
    VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
    (select role_id from krim_role_t where  role_nm = r_data.role_nm),
    (select perm_id from krim_perm_t where nm = 'Initiate Document'),
    'Y');    
   
  end if;
  
end loop;
close c_data;

end;
/
commit
/
