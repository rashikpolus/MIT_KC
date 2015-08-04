set serveroutput on;
begin
dbms_output.enable(6500000000);
end;
/
DECLARE
ls_actv_ind VARCHAR2(2):='Y';
ls_mbr_typ_cd VARCHAR2(2):='P';
li_ver_nbr NUMBER(8):=1;
ls_krim_typ_nm VARCHAR2(50);
ls_kim_typ_id NUMBER(8);
ls_role_id VARCHAR2(40);
ls_namespace VARCHAR2(40);
ls_attr_def_id VARCHAR2(40);
ls_attr_def_nm VARCHAR2(100);
ls_attr_def_lbl VARCHAR2(40);
ls_mbr_id VARCHAR2(40);
ls_role_mbr_id VARCHAR2(40);
ls_attr_data_id VARCHAR2(40);
ls_role_seq_id VARCHAR2(40);
li_error_loop NUMBER(8):=0;
li_count_krim_role number;
li_count_krim_role_mbr number;
li_count_krim_role_mbr_at number;
li_loop_check_flag number;
ls_role_name 	VARCHAR2(50);
li_count NUMBER;
ls_role_nm varchar2(80);
CURSOR c_role is
select distinct r.role_name ,r.DESCRIPTION,r.role_type,ur.USER_ID,ur.UNIT_NUMBER,ur.DESCEND_FLAG,ur.UPDATE_TIMESTAMP,ur.UPDATE_USER 
from osp$user_roles@coeus.kuali ur 
inner join osp$role r on r.role_id= ur.role_id
where ur.user_id = 'hudak';

r_role c_role%ROWTYPE;

CURSOR c_kim_attr(kim_type VARCHAR2) is
select kt.KIM_ATTR_DEFN_ID from KRIM_TYP_ATTR_T kt where kt.KIM_TYP_ID=kim_type;
r_kim_attr c_kim_attr%ROWTYPE;

BEGIN

if c_role%ISOPEN then
close c_role;
end if;
OPEN c_role;

LOOP              
FETCH c_role INTO r_role;
EXIT WHEN c_role%NOTFOUND;   
			                    
				
					   BEGIN                  
						   select p.PRNCPL_ID INTO ls_mbr_id from KRIM_PRNCPL_T p where UPPER(p.PRNCPL_NM)=UPPER(r_role.USER_ID);
					   EXCEPTION
					   WHEN OTHERS THEN
						  dbms_output.put_line('PrincipleId missing '||r_role.USER_ID||'. The Error is: '||sqlerrm);
						   -- insert to error log
						   continue;					   
					   END;			 
					
							
													
					   BEGIN 
							ls_role_nm := r_role.role_name;
							select count(kc_roles) into  li_count from kc_coeus_role_mapping where coeus_roles = r_role.DESCRIPTION;
							
							if li_count > 0 then
								select kc_roles into  ls_role_nm from kc_coeus_role_mapping where coeus_roles = r_role.role_name and rownum = 1;
								
							end if;
					   					   
						   select rl.ROLE_ID , rl.KIM_TYP_ID into ls_role_id , ls_kim_typ_id 
						   from KRIM_ROLE_T rl 	where  UPPER(rl.role_nm) = UPPER(ls_role_nm)
						   and rownum = 1; 
						  
					   EXCEPTION
					   WHEN OTHERS THEN
						dbms_output.put_line('Missing ROLE_ID in KRIM_ROLE_T for ROLE_NM '||ls_role_nm||'. The Error is: '||SQLERRM);
						continue;
					   END;
					   
					-- check whether the user with the role already exist or not					
					--select count(role_mbr_id) into li_count from KRIM_ROLE_MBR_T where ROLE_ID = ls_role_id and MBR_ID = ls_mbr_id;
					--if li_count = 0 then
						   BEGIN
									  li_loop_check_flag:=0;
									  IF c_kim_attr%ISOPEN THEN
										   CLOSE c_kim_attr;
									  END IF;
									  -- if kim type id is 'default'(1) then setting it to 'UnitHierarchy'(69) start
									  if ls_kim_typ_id = '1' then
											ls_kim_typ_id := '69';											
									  end if;
									  -- if kim type id is 'default'(1) then setting it to 'UnitHierarchy'(69) end
									  OPEN c_kim_attr(ls_kim_typ_id);
										 LOOP
										 FETCH c_kim_attr INTO r_kim_attr;
										 EXIT WHEN c_kim_attr%NOTFOUND;
										 
											  SELECT ka.KIM_ATTR_DEFN_ID,ka.NM,ka.LBL   INTO   ls_attr_def_id, ls_attr_def_nm,ls_attr_def_lbl from KRIM_ATTR_DEFN_T ka where ka.KIM_ATTR_DEFN_ID=r_kim_attr.KIM_ATTR_DEFN_ID;                    
											   
											  if li_loop_check_flag=0 then
												  SELECT KRIM_ROLE_MBR_ID_S.NEXTVAL INTO ls_role_mbr_id FROM DUAL;
												  INSERT INTO KRIM_ROLE_MBR_T(ROLE_MBR_ID,VER_NBR,OBJ_ID,ROLE_ID,MBR_ID,MBR_TYP_CD,ACTV_FRM_DT,ACTV_TO_DT,LAST_UPDT_DT)
												  VALUES(ls_role_mbr_id,li_ver_nbr,SYS_GUID(),ls_role_id,ls_mbr_id,ls_mbr_typ_cd,NULL,NULL,SYSDATE);
												  li_loop_check_flag:=1;
											  end if; 
											   
											   IF ls_attr_def_nm ='subunits' AND r_role.DESCEND_FLAG IS NOT NULL THEN
													 
													 SELECT KRIM_ATTR_DATA_ID_S.NEXTVAL INTO ls_attr_data_id FROM DUAL;
													 INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
													 VALUES(ls_attr_data_id,sys_guid(),li_ver_nbr,ls_role_mbr_id,ls_kim_typ_id,ls_attr_def_id,r_role.DESCEND_FLAG);
													 
											   ELSIF ls_attr_def_nm='unitNumber' THEN
											   
													 SELECT KRIM_ATTR_DATA_ID_S.NEXTVAL INTO ls_attr_data_id FROM DUAL;
													 INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
													 VALUES(ls_attr_data_id,sys_guid(),li_ver_nbr,ls_role_mbr_id,ls_kim_typ_id,ls_attr_def_id,r_role.UNIT_NUMBER);
													 
											   END IF;
											   
										END LOOP;
										CLOSE   c_kim_attr;
							EXCEPTION 
								 WHEN OTHERS THEN
								 dbms_output.put_line('Error while inserting into KRIM_ROLE_MBR_T or KRIM_ROLE_MBR_ATTR_DATA_T, KIM_ATTR_DEFN_ID is '||r_kim_attr.KIM_ATTR_DEFN_ID||', role id is'||ls_role_id||', member id is '||ls_mbr_id||'. The error is: '||SQLERRM);
								 CLOSE   c_kim_attr;                                                  
							END;
				--	end if;
					
END LOOP;
CLOSE   c_role; 
dbms_output.put_line('Loading user roles Completed!!');
END; 
/
update krim_role_t set role_nm = 'Award Modifier', nmspc_cd = 'KC-AWARD' where role_nm = 'Modify Award'
/
commit
/
declare
li_count NUMBER;
ls_role_mbr_id VARCHAR2(40);
begin
	select count(ROLE_MBR_ID) into li_count from KRIM_ROLE_MBR_T 
	where mbr_id = 'admin' and role_id in (select role_id from krim_role_t where role_nm = 'Award Modifier');
	if li_count = 0 then
		INSERT INTO KRIM_ROLE_MBR_T(ROLE_MBR_ID,VER_NBR,OBJ_ID,ROLE_ID,MBR_ID,MBR_TYP_CD,ACTV_FRM_DT,ACTV_TO_DT,LAST_UPDT_DT)
		VALUES(KRIM_ROLE_MBR_ID_S.NEXTVAL,1,SYS_GUID(),(select role_id from krim_role_t where role_nm = 'Award Modifier'),'admin','P',NULL,NULL,SYSDATE);
	end if;

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
--MITKC-584
declare
li_count NUMBER;
ls_role_mbr_id VARCHAR2(40);
cursor c_data is
	select distinct mbr_id from KRIM_ROLE_MBR_T 
	where role_id in (select role_id from krim_role_t where role_nm = 'Maintain Sponsor Hierarchy');
r_data c_data%rowtype;

begin

delete from KRIM_ROLE_MBR_T 
where role_id in (select role_id from krim_role_t where role_nm = 'Maintain Sponsor Hierarchy')
and mbr_id  in  (
select t2.mbr_id from krim_prncpl_t t1 right outer join 
( select mbr_id from KRIM_ROLE_MBR_T 
where role_id in (select role_id from krim_role_t where role_nm = 'Maintain Sponsor Hierarchy')) t2 
on t2.mbr_id = t1.prncpl_id
where t1.prncpl_id is null
);
commit;

open  c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

  select count(ROLE_MBR_ID) into li_count from KRIM_ROLE_MBR_ATTR_DATA_T  
  WHERE ROLE_MBR_ID in (
    select ROLE_MBR_ID from KRIM_ROLE_MBR_T 
    where mbr_id = r_data.mbr_id and role_id in (select role_id from krim_role_t where role_nm = 'Maintain Sponsor Hierarchy')
  );
      
 if li_count = 0 then
    
    select ROLE_MBR_ID INTO ls_role_mbr_id from KRIM_ROLE_MBR_T 
    where mbr_id = r_data.mbr_id and role_id in (select role_id from krim_role_t where role_nm = 'Maintain Sponsor Hierarchy') and rownum = 1;
    
  INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
  VALUES(KRIM_ATTR_DATA_ID_S.NEXTVAL,sys_guid(),1,ls_role_mbr_id,'69','47','000001'); 
  
  INSERT INTO KRIM_ROLE_MBR_ATTR_DATA_T(ATTR_DATA_ID,OBJ_ID,VER_NBR,ROLE_MBR_ID,KIM_TYP_ID,KIM_ATTR_DEFN_ID,ATTR_VAL)
  VALUES(KRIM_ATTR_DATA_ID_S.NEXTVAL,sys_guid(),1,ls_role_mbr_id,'69','48','Y');
  
 end if; 
  
end loop;
close c_data;
  
commit;
end;
/
--MITKC-584
--MITKC-816
delete from krim_role_mbr_attr_data_t where role_mbr_id in ( select role_mbr_id from krim_role_mbr_t where role_id in (select role_id  from krim_role_t where role_nm = 'Negotiation SuperUser'))
/
commit
/
declare
li_fdoc KRIM_PND_ROLE_MBR_MT.FDOC_NBR%type;
li_count number;
cursor c_data is
select role_id , mbr_id, role_mbr_id from krim_role_mbr_t
where role_id in (select role_id  from krim_role_t where role_nm = 'Negotiation SuperUser');
r_data c_data%rowtype;
begin


select max(fdoc_nbr) into li_fdoc from krim_role_document_t 
where role_id in (select role_id  from krim_role_t where role_nm = 'Negotiation SuperUser');

li_count := 1;

if li_fdoc is null then
li_count := 0;
end if;
if li_count = 1 then
  if c_data%isopen then 
   close c_data;
  end if;
  open c_data;
  loop
  fetch  c_data into r_data;
  exit when c_data%notfound;
  
  select count(FDOC_NBR) into li_count from KRIM_PND_ROLE_MBR_MT 
  where role_mbr_id = r_data.role_mbr_id
  and FDOC_NBR = li_fdoc;
  
  if li_count = 0 then
  
  INSERT INTO KRIM_PND_ROLE_MBR_MT(FDOC_NBR,ROLE_MBR_ID,VER_NBR,OBJ_ID,ROLE_ID,MBR_ID,MBR_TYP_CD,ACTV_FRM_DT,ACTV_TO_DT,EDIT_FLAG)
  VALUES(li_fdoc,r_data.role_mbr_id,1,SYS_GUID(),r_data.role_id,r_data.mbr_id,'P',NULL,NULL,'N');
  
  end if;
  
  end loop;
  close c_data; 
end if;

end;
/
commit
/
delete from krim_role_mbr_attr_data_t where role_mbr_id
in (
select role_mbr_id from krim_role_mbr_t where role_id in  (select role_id from KRIM_ROLE_T where kim_typ_id='KC10000') 
)
/
commit
/
delete from krim_role_mbr_t where role_id in  (select role_id from KRIM_ROLE_T where kim_typ_id='KC10000')
/
commit
/