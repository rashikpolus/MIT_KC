UPDATE KRIM_ROLE_T
SET nmspc_cd = 'KC-UNT'
WHERE role_nm = 'IRB Reviewer'
/
declare
li_count NUMBER;
li_perm_id_seq KRIM_PERM_T.PERM_ID%type;
begin
select count(PERM_ID) into li_count FROM KRIM_PERM_T WHERE nm = 'Export Any Record' and nmspc_cd = 'KR-NS';
  if li_count = 0 then
    li_perm_id_seq := KRIM_PERM_ID_S.NEXTVAL;
    insert into KRIM_PERM_T(
    PERM_ID,
    OBJ_ID,
    VER_NBR,
    PERM_TMPL_ID,
    NMSPC_CD,
    NM,
    DESC_TXT,
    ACTV_IND
    )
    VALUES(
    li_perm_id_seq,
    SYS_GUID(),
    1,
    NULL,
    'KR-NS',
    'Export Any Record',
    'Export Any Record',
    'Y'
    );
    
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
  (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('KC Superuser'))and nmspc_cd ='KC-SYS'),
  li_perm_id_seq,
  'Y'
  );    
  
  end if;

end;
/
commit
/
