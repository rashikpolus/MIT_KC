declare
	li_count NUMBER;
	li_role_id KRIM_ROLE_T.ROLE_ID%type;
begin
	
	select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'Funding Source Monitor';
	if li_count = 0 then
		li_role_id := KRIM_ROLE_ID_S.NEXTVAL;		
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(li_role_id,SYS_GUID(),1,'Funding Source Monitor','KC-UNT','Funding Source Monitor','69','Y',sysdate);	
	end if;
	
	
	select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'Access_Proposal_Person_Institutional_Salaries';
	if li_count = 0 then
		li_role_id := KRIM_ROLE_ID_S.NEXTVAL;		
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(li_role_id,SYS_GUID(),1,'Access_Proposal_Person_Institutional_Salaries','KC-PD','Access Proposal Person Institutional Salaries','68','Y',sysdate);	
	end if;
	
	select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'Negotiation Administrator';
	if li_count = 0 then
		li_role_id := KRIM_ROLE_ID_S.NEXTVAL;		
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(li_role_id,SYS_GUID(),1,'Negotiation Administrator','KC-NEGOTIATION','The Negotiation Administrator role','69','Y',sysdate);	
	end if;
	
	select count(role_id) into li_count from KRIM_ROLE_T where role_nm = 'Protocol Aggregator' and nmspc_cd = 'KC-PROTOCOL-DOC';
	if li_count = 0 then
		li_role_id := KRIM_ROLE_ID_S.NEXTVAL;		
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(li_role_id,SYS_GUID(),1,'Protocol Aggregator','KC-PROTOCOL-DOC','Added to Document Qualified Role memberships for corresponding Role in KC-PROTOCOL namespace','68','Y',sysdate);	
	end if;
	
	select count(role_id) into li_count from KRIM_ROLE_T where role_nm = 'Protocol Viewer' and nmspc_cd = 'KC-PROTOCOL-DOC';
	if li_count = 0 then
		li_role_id := KRIM_ROLE_ID_S.NEXTVAL;		
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(li_role_id,SYS_GUID(),1,'Protocol Viewer','KC-PROTOCOL-DOC','Added to Document Qualified Role memberships for corresponding Role in KC-PROTOCOL namespace','68','Y',sysdate);	
	end if;
	
	select count(role_id) into li_count from KRIM_ROLE_T where role_nm = 'View Institutionally Maintained Salaries' and nmspc_cd = 'KC-PD';
	if li_count = 0 then
		li_role_id := KRIM_ROLE_ID_S.NEXTVAL;		
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(li_role_id,SYS_GUID(),1,'View Institutionally Maintained Salaries','KC-PD','View Institutionally Maintained Salaries','68','Y',sysdate);	
	end if;	
		
	commit;

end;
/
declare
li_count NUMBER;
ls_role_mbr_id VARCHAR2(40);
begin

	select count(ROLE_MBR_ID) into li_count from KRIM_ROLE_MBR_T 
	where mbr_id = 'admin' and role_id in (select role_id from krim_role_t where role_nm = 'Funding Source Monitor');
	if li_count = 0 then
	
		ls_role_mbr_id := KRIM_ROLE_MBR_ID_S.NEXTVAL;
		INSERT INTO KRIM_ROLE_MBR_T(ROLE_MBR_ID,VER_NBR,OBJ_ID,ROLE_ID,MBR_ID,MBR_TYP_CD,ACTV_FRM_DT,ACTV_TO_DT,LAST_UPDT_DT)
		VALUES(ls_role_mbr_id,1,SYS_GUID(),(select role_id from krim_role_t where role_nm = 'Funding Source Monitor'),'admin','P',NULL,NULL,SYSDATE);	
		
		INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
		VALUES(KRIM_ATTR_DATA_ID_S.NEXTVAL,sys_guid(),1,ls_role_mbr_id,'69','47','000001'); 
		
		INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
		VALUES(KRIM_ATTR_DATA_ID_S.NEXTVAL,sys_guid(),1,ls_role_mbr_id,'69','48','Y');
		
	end if;
	
	select count(ROLE_MBR_ID) into li_count from KRIM_ROLE_MBR_T 
	where mbr_id = 'admin' and role_id in (select role_id from krim_role_t where role_nm = 'IRB Administrator');
	if li_count = 0 then
	
		ls_role_mbr_id := KRIM_ROLE_MBR_ID_S.NEXTVAL;
		INSERT INTO KRIM_ROLE_MBR_T(ROLE_MBR_ID,VER_NBR,OBJ_ID,ROLE_ID,MBR_ID,MBR_TYP_CD,ACTV_FRM_DT,ACTV_TO_DT,LAST_UPDT_DT)
		VALUES(ls_role_mbr_id,1,SYS_GUID(),(select role_id from krim_role_t where role_nm = 'IRB Administrator'),'admin','P',NULL,NULL,SYSDATE);	
		
		INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
		VALUES(KRIM_ATTR_DATA_ID_S.NEXTVAL,sys_guid(),1,ls_role_mbr_id,'69','47','000001'); 
		
		INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
		VALUES(KRIM_ATTR_DATA_ID_S.NEXTVAL,sys_guid(),1,ls_role_mbr_id,'69','48','Y');
		
	end if;	
	
commit;
end;
/
