declare
 li_count NUMBER;
begin

 UPDATE krim_role_t set nmspc_cd ='KC-UNT' where role_nm = 'IRB Administrator';
 
 select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'Protocol Aggregator';
 if li_count = 0 then
  UPDATE krim_role_t set role_nm = 'Protocol Aggregator' where role_nm = 'IRB Protocol Aggregator';
 end if;
  
 select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'ProtocolApprover';
 if li_count = 0 then
  INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
  VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'ProtocolApprover','KC-PROTOCOL','This role exists primarily to grant implicit Cancel permission to Protocol Aggregators and Admins','83','Y',sysdate); 
 end if;
 commit;

end;
/