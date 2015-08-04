declare
  li_count number; 
begin
select count(perm_id) into li_count from KRIM_PERM_T where nm = 'View Certification';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-PD','View Certification','For Only Viewing certification questionnaire','Y');	
end if;
end;
/
UPDATE KRIM_TYP_T SET SRVC_NM='{http://kc.kuali.org/core/v5_0}proposalPiTypeDerivedRoleTypeService' WHERE NM='Derived Role: Principle Investigator' AND
NMSPC_CD='KC-PD'
/
DELETE
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Principle Investigator')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Certify');
/
declare
  li_count number;
begin
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Principle Investigator')))
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Principle Investigator'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'View Certification'),
      'Y'
      );    
    end if;
end;
/