declare
  li_count number;
begin

	select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_INST_PROPOSAL_DOC';
	if li_count = 0 then  
		insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
		VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-IP','VIEW_INST_PROPOSAL_DOC','View Institute Proposal Documents','Y');	
	end if;

	select count(perm_id) into li_count from KRIM_PERM_T where nm = 'MAINTAIN_INST_PROPOSAL_DOC';
	if li_count = 0 then  
		insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
		VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-IP','MAINTAIN_INST_PROPOSAL_DOC','Maintain Institute Proposal Documents','Y');	
	end if;

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Institute Proposal Document')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_INST_PROPOSAL_DOC');
    
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Institute Proposal Document'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_INST_PROPOSAL_DOC'),
      'Y'
      );    
    end if;
    
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Maintain Institute Proposal Document')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'MAINTAIN_INST_PROPOSAL_DOC');
    
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Maintain Institute Proposal Document'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'MAINTAIN_INST_PROPOSAL_DOC'),
      'Y'
      );    
    end if;
    
    delete from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Institute Proposal Document')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Open Intellectual Property Review');

end;
/
