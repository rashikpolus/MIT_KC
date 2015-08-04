declare
li_count PLS_INTEGER;
begin

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SHARED_SUBAWARD_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-SUBAWARD','VIEW_SHARED_SUBAWARD_DOC','View Shared Subaward Attachments','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View Shared Subaward Attachments';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View Shared Subaward Attachments','KC-SUBAWARD','View Shared Subaward Attachments','69','Y',sysdate);	
end if;

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Subaward Attachments')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_SUBAWARD_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Subaward Attachments'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_SUBAWARD_DOC' ),
      'Y');    
    end if;

	
select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SHARED_AWARD_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-AWARD','VIEW_SHARED_AWARD_DOC','View Shared Award Documents','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View Shared Award Documents';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View Shared Award Documents','KC-AWARD','View Shared Award Documents','69','Y',sysdate);	
end if;
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Award Documents')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_AWARD_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Award Documents'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_AWARD_DOC' ),
      'Y');    
    end if;




select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SHARED_INST_PROPOSAL_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-IP','VIEW_SHARED_INST_PROPOSAL_DOC','View Shared Institute Proposal Documents','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View Shared Institute Proposal Documents';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View Shared Institute Proposal Documents','KC-IP','View Shared Institute Proposal Documents','69','Y',sysdate);	
end if;
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Institute Proposal Documents')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_INST_PROPOSAL_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Institute Proposal Documents'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_INST_PROPOSAL_DOC' ),
      'Y');    
    end if;






select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_DEV_PROPOSAL_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-PD','VIEW_DEV_PROPOSAL_DOC','View Dev Proposal Attachments','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View Dev Proposal Attachments';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View Dev Proposal Attachments','KC-PD','View Dev Proposal Attachments','69','Y',sysdate);	
end if;
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Dev Proposal Attachments')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_DEV_PROPOSAL_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Dev Proposal Attachments'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_DEV_PROPOSAL_DOC' ),
      'Y');    
    end if;



select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_ALL_SHARED_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-SYS','VIEW_ALL_SHARED_DOC','View All Shared Documents','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View All Shared Documents';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View All Shared Documents','KC-SYS','View All Shared Documents','69','Y',sysdate);	
end if;
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View All Shared Documents')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_ALL_SHARED_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View All Shared Documents'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_ALL_SHARED_DOC' ),
      'Y');    
    end if;



end;
/
