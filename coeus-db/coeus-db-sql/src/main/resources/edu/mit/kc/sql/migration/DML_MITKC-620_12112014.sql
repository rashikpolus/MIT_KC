declare
  ls_role_id KRIM_ROLE_PERM_T.ROLE_ID%type;
  ls_perm_id KRIM_ROLE_PERM_T.PERM_ID%type;
  li_count number;
begin
  select role_id into ls_role_id from krim_role_t where role_nm = 'Application Administrator';
  
  FOR  r_perm IN 
    (
    SELECT PERM_ID from KRIM_PERM_T where nm in ('Add Sponsor Hierarchy','Delete Sponsor Hierarchy' ,'Modify Sponsor Hierarchy')
    )
  LOOP
    select count(role_perm_id) into li_count from KRIM_ROLE_PERM_T
    where role_id = ls_role_id
    and   role_id = r_perm.PERM_ID;
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,ls_role_id,r_perm.PERM_ID,'Y');
    
    end if;
    
  END LOOP;
end;
/
commit
/
declare
  ls_role_id KRIM_ROLE_PERM_T.ROLE_ID%type;
  ls_perm_id KRIM_ROLE_PERM_T.PERM_ID%type;
  li_count number;
begin
  select role_id into ls_role_id from krim_role_t where role_nm = 'Modify Subcontract';
  
  FOR  r_perm IN 
    (
    SELECT PERM_ID from KRIM_PERM_T where nm in ('Open Document','Open RICE Document')
    )
  LOOP
    select count(role_perm_id) into li_count from KRIM_ROLE_PERM_T
    where role_id = ls_role_id
    and   role_id = r_perm.PERM_ID;
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,ls_role_id,r_perm.PERM_ID,'Y');
    
    end if;
    
  END LOOP;
end;
/
commit
/