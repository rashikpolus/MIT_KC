declare
  li_count number;
begin
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Aggregator Document Level')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'View Certification');
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(
           ROLE_PERM_ID,
           OBJ_ID,
           VER_NBR,
           ROLE_ID,
           PERM_ID,
           ACTV_IND
            )
      VALUES(
      KRIM_ROLE_PERM_ID_S.nextval,
      sys_guid(),
      1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Aggregator Document Level'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'View Certification'),
      'Y'
      );    
    end if;
end;
/