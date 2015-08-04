INSERT INTO KRIM_TYP_T (KIM_TYP_ID, OBJ_ID, VER_NBR, NM, SRVC_NM, ACTV_IND, NMSPC_CD) 
VALUES( KRIM_TYP_ID_S.NEXTVAL, SYS_GUID(), 1, 'Derived Role: Principle Investigator', 'proposalPersonDerivedRoleTypeService', 'Y', 'KC-PD')
/
INSERT INTO KRIM_ROLE_T (ROLE_ID, OBJ_ID, VER_NBR, ROLE_NM, NMSPC_CD, DESC_TXT, KIM_TYP_ID, ACTV_IND, LAST_UPDT_DT) 
VALUES (KRIM_ROLE_PERM_ID_S.NEXTVAL, SYS_GUID(), 1, 'Principle Investigator', 'KC-PD', 'Principle Investigator for PD', (SELECT KIM_TYP_ID FROM KRIM_TYP_T WHERE NMSPC_CD = 'KC-PD' AND NM = 'Derived Role: Principle Investigator'), 'Y', SYSDATE)
/
declare
  li_count1 number; 
begin
select count(perm_id) into li_count1 from KRIM_PERM_T where nm = 'Certify';
if li_count1 = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-PD','Certify','Certify for viewing certification questionnaire','Y');
	
end if;
end;
/
declare
  li_count number;
begin
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Principle Investigator')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Certify');
    
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Principle Investigator'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'Certify'),
      'Y'
      );    
    end if;
end;
/