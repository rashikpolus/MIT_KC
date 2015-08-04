declare
	li_count NUMBER;
	li_perm_id_seq KRIM_PERM_T.PERM_ID%type;
begin

	select count(PERM_ID) 
	into li_count 
	FROM KRIM_PERM_T WHERE nm = 'Maintain Keyperson' AND NMSPC_CD = 'KC-AWARD';
	
	if li_count = 0 then
      Insert into KRIM_PERM_T (PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND) 
      values (KRIM_PERM_ID_S.NEXTVAL,sys_guid(),1, '1','KC-AWARD','Maintain Keyperson','Maintain Keyperson','Y');
	  
	end if;
    commit;
	
	select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Maintain Key Person'))and nmspc_cd ='KC-AWARD')
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Maintain Keyperson' and nmspc_cd='KC-AWARD');
    
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Maintain Key Person'))and nmspc_cd ='KC-AWARD'),
      (select PERM_ID from KRIM_PERM_T where nm = 'Maintain Keyperson' and nmspc_cd='KC-AWARD'),
      'Y'
      );    
    end if;

end;
/
