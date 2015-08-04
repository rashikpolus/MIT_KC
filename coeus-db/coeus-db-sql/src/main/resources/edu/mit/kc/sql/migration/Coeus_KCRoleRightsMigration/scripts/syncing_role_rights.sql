set serveroutput on;
begin
dbms_output.enable(6500000000);
dbms_output.put_line('Sync role rights begin!!');

end;
/
ALTER TABLE KRIM_DLGN_T DISABLE CONSTRAINT KRIM_DLGN_TR1 ;
ALTER TABLE KRIM_ROLE_MBR_T DISABLE CONSTRAINT KRIM_ROLE_MBR_TR1 ;
ALTER TABLE KRIM_PERM_ATTR_DATA_T DISABLE CONSTRAINT KRIM_PERM_ATTR_DATA_TR3 ;
ALTER TABLE KRIM_ROLE_PERM_T DISABLE CONSTRAINT KRIM_ROLE_PERM_TR1 ;
ALTER TABLE KRIM_ROLE_PERM_T DISABLE CONSTRAINT KRIM_ROLE_PERM_TP1 ;
ALTER TABLE KRIM_ROLE_PERM_T DISABLE CONSTRAINT KRIM_ROLE_PERM_TC0 ;
ALTER TABLE KRIM_PERM_T DISABLE CONSTRAINT KRIM_PERM_TP1 ;
ALTER TABLE KRIM_PERM_T DISABLE CONSTRAINT KRIM_PERM_TC0 ;
ALTER TABLE KRIM_PERM_T DISABLE CONSTRAINT KRIM_PERM_T_TC1 ;
ALTER TABLE ROLE_CNTRL_MAP_T DISABLE CONSTRAINT FK_ROLE_CNTRL_MAP_T ;
ALTER TABLE KC_ROLE_CNTRAL_MAP DISABLE CONSTRAINT FK_KC_ROLE_CNTRAL_MAP ;

delete from krim_role_mbr_attr_data_t  where role_mbr_id in (
      select role_mbr_id from krim_role_mbr_t where role_id in (
		select role_id from krim_role_t where nmspc_cd not in ('KR-BUS','KR-SYS','KR-IDM','KR-NS','KR-NTFCN','KR-WKFLW','KUALI','KR-RULE','KR-KRAD','KR-RULE-TEST','KC-SYS','KC-GEN','KC-KRMS','KC-M','KC-WKFLW')and ROLE_NM not in('OSP Administrator')
		and role_id not in (select role_id from krim_role_t where kim_typ_id in (select kim_typ_id from krim_typ_t where nm like 'Derived Role:%'))
		))
/
delete from krim_role_mbr_t where role_id in (
		select role_id from krim_role_t where nmspc_cd not in ('KR-BUS','KR-SYS','KR-IDM','KR-NS','KR-NTFCN','KR-WKFLW','KUALI','KR-RULE','KR-KRAD','KR-RULE-TEST','KC-SYS','KC-GEN','KC-KRMS','KC-M','KC-WKFLW') and ROLE_NM not in('OSP Administrator')
		and role_id not in (select role_id from krim_role_t where kim_typ_id in (select kim_typ_id from krim_typ_t where nm like 'Derived Role:%'))
		)
/
delete from krim_role_perm_t where role_id in (
		select role_id from krim_role_t where nmspc_cd not in ('KR-BUS','KR-SYS','KR-IDM','KR-NS','KR-NTFCN','KR-WKFLW','KUALI','KR-RULE','KR-KRAD','KR-RULE-TEST','KC-SYS','KC-GEN','KC-KRMS','KC-M','KC-WKFLW') and ROLE_NM not in('OSP Administrator')
		and role_id not in (select role_id from krim_role_t where kim_typ_id in (select kim_typ_id from krim_typ_t where nm like 'Derived Role:%')))
/
delete from krim_role_t where nmspc_cd not in ('KR-BUS','KR-SYS','KR-IDM','KR-NS','KR-NTFCN','KR-WKFLW','KUALI','KR-RULE','KR-KRAD','KR-RULE-TEST','KC-SYS','KC-GEN','KC-KRMS','KC-M','KC-WKFLW')
and kim_typ_id not in (select kim_typ_id from krim_typ_t where nm like 'Derived Role:%') and ROLE_NM not in('OSP Administrator')
/
commit
/
ALTER TABLE KRIM_DLGN_T ENABLE CONSTRAINT KRIM_DLGN_TR1 ;
ALTER TABLE KRIM_ROLE_MBR_T ENABLE CONSTRAINT KRIM_ROLE_MBR_TR1 ;
ALTER TABLE KRIM_PERM_ATTR_DATA_T ENABLE CONSTRAINT KRIM_PERM_ATTR_DATA_TR3 ;
ALTER TABLE KRIM_ROLE_PERM_T ENABLE CONSTRAINT KRIM_ROLE_PERM_TR1 ;
ALTER TABLE KRIM_ROLE_PERM_T ENABLE CONSTRAINT KRIM_ROLE_PERM_TP1 ;
ALTER TABLE KRIM_ROLE_PERM_T ENABLE CONSTRAINT KRIM_ROLE_PERM_TC0 ;
ALTER TABLE KRIM_PERM_T ENABLE CONSTRAINT KRIM_PERM_TP1 ;
ALTER TABLE KRIM_PERM_T ENABLE CONSTRAINT KRIM_PERM_TC0 ;
ALTER TABLE KRIM_PERM_T ENABLE CONSTRAINT KRIM_PERM_T_TC1 ;
ALTER TABLE ROLE_CNTRL_MAP_T ENABLE CONSTRAINT FK_ROLE_CNTRL_MAP_T ;
ALTER TABLE KC_ROLE_CNTRAL_MAP ENABLE CONSTRAINT FK_KC_ROLE_CNTRAL_MAP ;
-- Adding roles from Coeus which are not in role-to-role mapping table
declare
li_coeus_role_id NUMBER(5,0);
li_kc_role_id    krim_role_t.role_id%type;
li_count         NUMBER;

cursor c_role is  
   select  distinct t1.role_type ,t1.DESCRIPTION, t1.role_name 
   from  osp$role t1 
   where t1.role_name not in (select COEUS_ROLES from KC_COEUS_ROLE_MAPPING);  
   r_role c_role%rowtype;
  
ls_namespace VARCHAR2(40);
ls_kim_typ_id NUMBER(8);
li_role_count number;

begin

  open c_role;
  loop
  fetch c_role into r_role;
  exit when c_role%notfound;
  
 
  select count(role_id) into li_role_count from krim_role_t where trim(upper(role_nm)) = trim(upper(r_role.role_name));
  
  -- role is missing in KC we need to add that role to KC
  -- Adding role START
	if li_role_count = 0 then
	
		if UPPER(TRIM(r_role.role_type)) = 'P' then
			ls_namespace:='KC-PD';
			
		elsif  upper(trim(r_role.role_type))='R' or upper(trim(r_role.role_type))='I' then 
			ls_namespace:='KC-PROTOCOL';     

		elsif  upper(trim(r_role.role_type))='S'  then 	
			ls_namespace:='KC-ADM';
			
		else   	
			ls_namespace:='KC-SYS';
		end if;	
	

			  begin
				select k.KIM_TYP_ID into ls_kim_typ_id from KRIM_TYP_T k where k.nm='UnitHierarchy'; 
			  EXCEPTION
			  WHEN OTHERS THEN
			  dbms_output.put_line('There is not KIM_TYP_ID for UnitHierarchy'); 
			  continue;
			  end;	
						
			   --dbms_output.put_line('Inserting role '||r_role.role_name);			
			   BEGIN
					SELECT KRIM_ROLE_ID_S.NEXTVAL INTO li_kc_role_id FROM DUAL;
					INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND)  
					VALUES(li_kc_role_id,SYS_GUID(),1,r_role.role_name,ls_namespace,r_role.DESCRIPTION,ls_kim_typ_id,'Y');					
								
			   EXCEPTION
			   WHEN OTHERS THEN
				dbms_output.put_line('Error while inserting into KRIM_ROLE_T , role name is'||r_role.role_name||'.  The error is: '||sqlerrm);
			   continue;
			   END;
				
			
			
	end if;
	
  end loop;
  close c_role;
  
end;
/
-- Adding roles from Coeus which are in role-to-role mapping table
declare
li_coeus_role_id NUMBER(5,0);
li_kc_role_id    krim_role_t.role_id%type;
li_count         NUMBER;
ls_role_nm varchar2(80);
cursor c_role is  
   select  distinct t1.role_type ,t1.DESCRIPTION, t1.role_name 
   from  osp$role t1 
   where t1.role_name in (select COEUS_ROLES from KC_COEUS_ROLE_MAPPING);  
   r_role c_role%rowtype;
  
ls_namespace VARCHAR2(40);
ls_kim_typ_id NUMBER(8);
li_role_count number;

begin

  open c_role;
  loop
  fetch c_role into r_role;
  exit when c_role%notfound;
  
  select kc_roles into  ls_role_nm from kc_coeus_role_mapping where coeus_roles = r_role.role_name and rownum = 1;
  
 
  select count(role_id) into li_role_count from krim_role_t where trim(upper(role_nm)) = trim(upper(ls_role_nm));
  
  -- role is missing in KC we need to add that role to KC
  -- Adding role START
	if li_role_count = 0 then
	
		if UPPER(TRIM(r_role.role_type)) = 'P' then
			ls_namespace:='KC-PD';
			
		elsif  upper(trim(r_role.role_type))='R' or upper(trim(r_role.role_type))='I' then 
			ls_namespace:='KC-PROTOCOL';     

		elsif  upper(trim(r_role.role_type))='S'  then 	
			ls_namespace:='KC-ADM';
			
		else   	
			ls_namespace:='KC-SYS';
		end if;	
	

			  begin
				select k.KIM_TYP_ID into ls_kim_typ_id from KRIM_TYP_T k where k.nm='UnitHierarchy'; 
			  EXCEPTION
			  WHEN OTHERS THEN
			  dbms_output.put_line('There is not KIM_TYP_ID for UnitHierarchy'); 
			  continue;
			  end;	
						
			   --dbms_output.put_line('Inserting role '||r_role.role_name);			
			   BEGIN
					SELECT KRIM_ROLE_ID_S.NEXTVAL INTO li_kc_role_id FROM DUAL;
					INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND)  
					VALUES(li_kc_role_id,SYS_GUID(),1,r_role.role_name,ls_namespace,r_role.DESCRIPTION,ls_kim_typ_id,'Y');					
								
			   EXCEPTION
			   WHEN OTHERS THEN
				dbms_output.put_line('Error while inserting into KRIM_ROLE_T , role name is'||r_role.role_name||'.  The error is: '||sqlerrm);
			   continue;
			   END;
				

	end if;
			
	
	
  end loop;
  close c_role;
  
  Insert into KRIM_ROLE_T (ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND,LAST_UPDT_DT) 
  values (KRIM_ROLE_ID_S.NEXTVAL,sys_guid(),1,'Investigators Document Level','KC-PD','Proposal Investigator','KC10000','Y',sysdate);
  
end;
/
commit
/
-- Adding roles from final mapping which are krim_role_table
declare
li_coeus_role_id NUMBER(5,0);
li_kc_role_id    krim_role_t.role_id%type;
li_count         NUMBER;

cursor c_role is       
   select distinct t1.role_nm as role_name,t1.role_nm as DESCRIPTION, t1.role_nmspc_cd from KC_COEUS_ROLE_PERM_MAPPING t1
   left outer join krim_role_t t2 on t1.role_nm = t2.role_nm
   where t2.role_id is null;   
   r_role c_role%rowtype;
  
ls_namespace VARCHAR2(40);
ls_kim_typ_id NUMBER(8);
li_role_count number;

begin

  open c_role;
  loop
  fetch c_role into r_role;
  exit when c_role%notfound;
  
 
  select count(role_id) into li_role_count from krim_role_t where trim(upper(role_nm)) = trim(upper(r_role.role_name));
  
  -- role is missing in KC we need to add that role to KC
  -- Adding role START
	if li_role_count = 0 then
			
			if r_role.role_nmspc_cd is null then
				ls_namespace := 'KC-SYS';
			else
				ls_namespace := r_role.role_nmspc_cd;
			end if;
					

			  begin
				select k.KIM_TYP_ID into ls_kim_typ_id from KRIM_TYP_T k where k.nm='UnitHierarchy'; 
			  EXCEPTION
			  WHEN OTHERS THEN
			  dbms_output.put_line('There is not KIM_TYP_ID for UnitHierarchy'); 
			  continue;
			  end;	
						
			   --dbms_output.put_line('Inserting role '||r_role.role_name);			
			   BEGIN
					SELECT KRIM_ROLE_ID_S.NEXTVAL INTO li_kc_role_id FROM DUAL;
					INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND)  
					VALUES(li_kc_role_id,SYS_GUID(),1,r_role.role_name,ls_namespace,r_role.DESCRIPTION,ls_kim_typ_id,'Y');					
								
			   EXCEPTION
			   WHEN OTHERS THEN
				dbms_output.put_line('Error while inserting into KRIM_ROLE_T , role name is'||r_role.role_name||'.  The error is: '||sqlerrm);
			   continue;
			   END;
				
			
			
	end if;
	
  end loop;
  close c_role;
  
end;
/
commit
/
-- Adding role ENDS
-- updating the name space code from final mapping to krim_role_t
declare
li_count number;
  cursor c_data is
    select distinct t1.role_nm, t1.role_nmspc_cd, t2.nmspc_cd from  kc_coeus_role_perm_mapping t1
    inner join krim_role_t t2 on t1.role_nm = t2.role_nm
    where t1.role_nmspc_cd <> t2.nmspc_cd;
  r_data c_data%rowtype; 
 
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
    select count(role_nm) into li_count
    from krim_role_t
    where role_nm = r_data.role_nm
    and   nmspc_cd = r_data.role_nmspc_cd;
    
    if li_count = 0 then
    
        begin
          update krim_role_t set nmspc_cd = r_data.role_nmspc_cd
          where role_nm = r_data.role_nm
          and   nmspc_cd = r_data.nmspc_cd; 
		  
          commit;
        exception
        when others then
           continue;
        end;
        
    end if;    
    
  end loop;
  close c_data;

end;
/
--- deleting and renaming roles by checking the final mapping document
declare
  cursor c_data is
  select role_nm,nmspc_cd,new_role_nm,new_nmspc_cd
  from KC_ROLE_UPDATE_ACTION where action_typ = 'U';
  r_data c_data%rowtype;
  li_count number;
begin

  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
    begin
  
        update krim_role_t 
        set role_nm = r_data.new_role_nm,
        nmspc_cd = r_data.new_nmspc_cd
        where role_nm = r_data.role_nm
        and nmspc_cd =  r_data.nmspc_cd;        
               
    exception
    when others then
      continue;
    end;
  
  end loop;
  close c_data;

end;
/
commit
/
delete FROM KRIM_ROLE_MBR_T WHERE ROLE_ID IN (
  SELECT t1.role_id from krim_role_t t1
  inner join kc_role_update_action t2  on t1.role_nm = t2.role_nm and t1.nmspc_cd = t2.nmspc_cd
  where t2.action_typ = 'D'
)
/
delete FROM KRIM_ROLE_PERM_T WHERE ROLE_ID IN (
  SELECT t1.role_id from krim_role_t t1
  inner join kc_role_update_action t2  on t1.role_nm = t2.role_nm and t1.nmspc_cd = t2.nmspc_cd
  where t2.action_typ = 'D'
)
/
delete FROM KRIM_ROLE_T WHERE ROLE_ID IN (
  SELECT t1.role_id from krim_role_t t1
  inner join kc_role_update_action t2  on t1.role_nm = t2.role_nm and t1.nmspc_cd = t2.nmspc_cd
  where t2.action_typ = 'D'
)
/
commit
/
--- updating KIM typ id and namespace code
declare
li_count number;
begin

	select count(role_id) into li_count from krim_role_t where role_nm = 'Maintain Key Person' and nmspc_cd = 'KC-AWARD';
	if li_count = 0 then
		update krim_role_t set nmspc_cd = 'KC-AWARD' where role_nm = 'Maintain Key Person';
		
	end if;
	
	select count(role_id) into li_count from krim_role_t where role_nm = 'Modify All Dev Proposals' and nmspc_cd = 'KC-PD';
	if li_count = 0 then
		update krim_role_t set nmspc_cd = 'KC-PD' where role_nm = 'Modify All Dev Proposals';
		
	end if;
	
	update krim_role_t set kim_typ_id = '68' where role_nm = 'Proposal Proxy Certify';
	
	update krim_role_t set kim_typ_id = '69' where role_nm = 'View Subcontract';

	update krim_role_t set kim_typ_id = '1' where role_nm = 'View Award';
	
	update krim_role_t set kim_typ_id = '1' where role_nm = 'View Institute Proposal';
	
end;
/
commit
/

delete FROM KRIM_ROLE_MBR_T WHERE ROLE_ID IN (
  SELECT t1.role_id from krim_role_t t1 where t1.role_nm = 'Aggregator Only Document Level'
)
/
delete FROM KRIM_ROLE_PERM_T WHERE ROLE_ID IN (
 SELECT t1.role_id from krim_role_t t1 where t1.role_nm = 'Aggregator Only Document Level'
)
/
delete FROM KRIM_ROLE_T WHERE role_nm = 'Aggregator Only Document Level'
/
commit
/
delete FROM KRIM_ROLE_MBR_T WHERE ROLE_ID IN (
  SELECT t1.role_id from krim_role_t t1 where t1.role_nm = 'Access_Proposal_Person_Institutional_Salaries' and t1.kim_typ_id = '68'
)
/
delete FROM KRIM_ROLE_PERM_T WHERE ROLE_ID IN (
 SELECT t1.role_id from krim_role_t t1 where  t1.role_nm = 'Access_Proposal_Person_Institutional_Salaries' and t1.kim_typ_id = '68'
)
/
delete FROM KRIM_ROLE_T WHERE  role_nm = 'Access_Proposal_Person_Institutional_Salaries' and kim_typ_id = '68'
/
commit
/
-- inserting manager role
declare
li_count number;
begin

select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'Manager' and nmspc_cd = 'KC-SYS';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
  VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'Manager','KC-SYS','This role represents a collection of all the KC module manager roles and has permission to initiate simple maintenance documents.',
'1','Y',sysdate);	 	
end if;

end;
/
commit
/
declare
li_max number(10);
ls_query VARCHAR2(400);
li_nextval number(10);
begin
select max(to_number(ROLE_PERM_ID)) into li_max from krim_role_perm_t where role_perm_id not like '%K%';
select KRIM_ROLE_PERM_ID_S.NEXTVAL into li_nextval from dual;
if li_max > li_nextval then
	li_max := (li_max - li_nextval) + 1;
	ls_query:='alter sequence KRIM_ROLE_PERM_ID_S increment by '||li_max;      
	execute immediate(ls_query); 
end if; 

end;
/
select KRIM_ROLE_PERM_ID_S.NEXTVAL from dual
/
alter sequence KRIM_ROLE_PERM_ID_S increment by 1
/
declare
	li_count         NUMBER; 
	li_role_id 	krim_role_t.role_id%type;
	cursor c_role_right is 
		select distinct role_nm,role_nmspc_cd from KC_COEUS_ROLE_PERM_MAPPING;
	r_role_right c_role_right%rowtype;
	
	cursor c_perm is
		select distinct t2.perm_id
		from kc_coeus_role_perm_mapping t1 
		inner join krim_perm_t t2 on t1.PERM_NM = t2.nm
		where t1.role_nm = r_role_right.role_nm
		and t1.role_nmspc_cd = r_role_right.role_nmspc_cd
		and t2.perm_id not in (select perm_id from krim_role_perm_t where role_id = li_role_id);
		r_perm c_perm%rowtype;
	
begin 
 
      open c_role_right;
      loop
      fetch c_role_right into r_role_right;
      exit when c_role_right%notfound; 
	  
			BEGIN  
				select count(role_id) into li_count from krim_role_t where trim(upper(role_nm)) = trim(upper(r_role_right.role_nm));					
				if li_count = 1 then
					select role_id into li_role_id from krim_role_t where trim(upper(role_nm)) = trim(upper(r_role_right.role_nm));	
						
				elsif li_count > 1 then			
					select role_id into li_role_id from krim_role_t where trim(upper(role_nm)) = trim(upper(r_role_right.role_nm)) and nmspc_cd = r_role_right.role_nmspc_cd;	
					
				else
					dbms_output.put_line('Role is not in krim_role_t , role_nm is '||r_role_right.role_nm||' and nmspc_cd is '||r_role_right.role_nmspc_cd);
					continue;
					
				end if;				
				
			EXCEPTION
			WHEN OTHERS THEN
			   dbms_output.put_line('Role is not in krim_role_t , role_nm is '||r_role_right.role_nm||' and nmspc_cd is '||r_role_right.role_nmspc_cd||'.  The error is: '||sqlerrm);
			   continue;
			END;   
	 
	 -- delete the permission which now obsolete in the specific role
				delete from krim_role_perm_t 
				where role_id = li_role_id
				and perm_id not in (
						select t2.perm_id from kc_coeus_role_perm_mapping t1 
						inner join krim_perm_t t2 on t1.PERM_NM = t2.nm
						where t1.role_nm = r_role_right.role_nm
						and t1.role_nmspc_cd = r_role_right.role_nmspc_cd );

			

					  open c_perm;
					  loop
					  fetch c_perm into r_perm;
					  exit when c_perm%notfound;
					  
							BEGIN
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
									li_role_id,
									r_perm.perm_id,
									'Y'
								  );
								-- dbms_output.put_line('Inserted to KRIM_ROLE_PERM_T , role name is '||r_role_right.role_nm||' and perm id is '||r_perm.perm_id);  
							EXCEPTION
							WHEN OTHERS THEN
							   dbms_output.put_line('Error while inserting into KRIM_ROLE_PERM_T , role name is '||r_role_right.role_nm||' and perm id is '||r_perm.perm_id||'.  The error is: '||sqlerrm);
							   continue;
							END;
			
					 
					  end loop;
					  close c_perm;

			
      end loop;
      close c_role_right;
end;
/

/*
declare
	li_count         NUMBER;  
	
	cursor c_role_right is 
	select t3.role_id, t2.perm_id
	from kc_coeus_role_perm_mapping t1 
	inner join krim_perm_t t2 on t1.kc_perm_nm = t2.nm and (t1.nmspc_cd is null or t1.nmspc_cd = t2.nmspc_cd)
	inner join krim_role_t t3 on t1.role_nm = t3.role_nm;
	r_role_right c_role_right%rowtype;
	
begin 
 
      open c_role_right;
      loop
      fetch c_role_right into r_role_right;
      exit when c_role_right%notfound;
      
       select count(role_perm_id) into li_count 
       from KRIM_ROLE_PERM_T
       where role_id = r_role_right.role_id
       and   perm_id = r_role_right.perm_id;
       
       if li_count = 0 then
        --dbms_output.put_line('Mapping permission '||ls_perm_nm ||' to role '||r_role.kc_role);
			BEGIN
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
					r_role_right.role_id,
					r_role_right.perm_id,
					'Y'
				  );
			EXCEPTION
			WHEN OTHERS THEN
			   dbms_output.put_line('Error while inserting into KRIM_ROLE_PERM_T , role id is '||r_role_right.role_id||' and perm id is '||r_role_right.perm_id||'.  The error is: '||sqlerrm);
			   continue;
			END;
       end if; 
	 
      end loop;
      close c_role_right;

end;
/
*/
/*
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
(select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('OSP Administrator')) and rownum = 1),
(select PERM_ID from KC_PERM_BOOTSTRAP where nm = 'Allow Backdoor Login'),
'Y'
)
*/
declare
li_count NUMBER;
li_perm_id_seq KRIM_PERM_T.PERM_ID%type;
begin
select count(PERM_ID) 
into li_count 
FROM KRIM_PERM_T WHERE nm = 'Allow Backdoor Login';
  if li_count = 0 then
      Insert into KRIM_PERM_T (PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND) 
      values (KRIM_PERM_ID_S.NEXTVAL,sys_guid(),1, '1','KC-UNT','Allow Backdoor Login','Allow Backdoor Login','Y');
  end if;

end;
/
commit
/
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
(select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Technical Administrator')) and rownum = 1),
(select PERM_ID from KRIM_PERM_T where nm = 'Allow Backdoor Login'),
'Y'
)
/
commit
/
-- protocol fix
declare
	li_count NUMBER;
	li_role_id KRIM_ROLE_T.ROLE_ID%type;
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
		VALUES(li_role_id,SYS_GUID(),1,'Negotiation Administrator','KC-NEGOTIATION','The Negotiation Administrator role','1','Y',sysdate);	
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
commit
/
--MITKC-623
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
(select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Application Administrator'))and nmspc_cd ='KC-SYS'),
(select PERM_ID from KRIM_PERM_T where nm = 'Modify Unit' and nmspc_cd='KC-UNT'),
'Y'
)
/
commit
/
--MITKC-665
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
--MITKC-438
declare
	li_count NUMBER;
	li_role_id KRIM_ROLE_T.ROLE_ID%type;
begin

	select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'OSP Administrator';
	if li_count = 0 then
		INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
		VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'OSP Administrator','KC-SYS','OSP Administrator','69','Y',sysdate);	
	end if;
	
end;
/
commit
/
INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve RICE Document'),
'Y')
/
INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve Document'),
'Y')
/
INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve AwardDocument'),
'Y')
/
INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
(select role_id from krim_role_t where  role_nm = 'OSP Administrator'),
(select perm_id from krim_perm_t where nm = 'Blanket Approve AwardBudgetDocument'),
'Y')
/
declare
cursor c_data is
select 'Modify Negotiations' role_nm from dual
UNION ALL
select 'Negotiation Administrator' role_nm from dual
UNION ALL
select 'Negotiation SuperUser' role_nm from dual
UNION ALL
select 'Negotiator' role_nm from dual;
r_data c_data%rowtype;

li_count number;
li_num number;
ls_role_nm VARCHAR2(80);
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;


     ls_role_nm:= r_data.role_nm;
	 


  select distinct count(r4.nm) into li_count
  from krim_role_t r1
  inner join krim_role_perm_t r3 on r1.role_id = r3.role_id
  inner join krim_perm_t r4 on r4.perm_id = r3.perm_id
  where  r1.role_nm = ls_role_nm
  and  r4.nm = 'Initiate Document';
    
  	begin
		  if li_count = 0 then
			INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
			VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
			(select role_id from krim_role_t where  role_nm = ls_role_nm),
			(select perm_id from krim_perm_t where nm = 'Initiate Document'),
			'Y');    
		   
		  end if;
		  
	exception
	when others then
	continue;	
	end;  
  
  
end loop;
close c_data;

end;
/
commit
/
declare
  ls_role_id KRIM_ROLE_PERM_T.ROLE_ID%type;
  ls_perm_id KRIM_ROLE_PERM_T.PERM_ID%type;
  li_count number;
begin
  select role_id into ls_role_id from krim_role_t where role_nm = 'Application Administrator';
  
  FOR  r_perm IN 
    (
    SELECT PERM_ID from KRIM_PERM_T where nm in ('Add Sponsor Hierarchy','Delete Sponsor Hierarchy' ,'Modify Sponsor Hierarchy')
    )
  LOOP
    select count(role_perm_id) into li_count from KRIM_ROLE_PERM_T
    where role_id = ls_role_id
    and   role_id = r_perm.PERM_ID;
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,ls_role_id,r_perm.PERM_ID,'Y');
    
    end if;
    
  END LOOP;

end;
/
commit
/
--MITKC-620
declare
  ls_role_id KRIM_ROLE_PERM_T.ROLE_ID%type;
  ls_perm_id KRIM_ROLE_PERM_T.PERM_ID%type;
  li_count number;
begin
  select role_id into ls_role_id from krim_role_t where role_nm = 'Modify Subcontract';
  
  FOR  r_perm IN 
    (
    SELECT PERM_ID from KRIM_PERM_T where nm in ('Open Document','Open RICE Document')
    )
  LOOP
    select count(role_perm_id) into li_count from KRIM_ROLE_PERM_T
    where role_id = ls_role_id
    and   role_id = r_perm.PERM_ID;
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,ls_role_id,r_perm.PERM_ID,'Y');
    
    end if;
    
  END LOOP;

end;
/
commit
/
--MITKC-623
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Application Administrator'))and nmspc_cd ='KC-SYS')
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Add Unit' and nmspc_cd='KC-UNT');
    
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Application Administrator'))and nmspc_cd ='KC-SYS'),
      (select PERM_ID from KRIM_PERM_T where nm = 'Add Unit' and nmspc_cd='KC-UNT'),
      'Y'
      );    
    end if;

end;
/
commit
/
--MITKC-782
update krim_role_t
set nmspc_cd = 'KC-UNT' , kim_typ_id = 68
where role_nm = 'Proposal Creator'
/
delete  from krim_role_mbr_attr_data_t
where role_mbr_id in ( select role_mbr_id from krim_role_mbr_t 
                              where role_id in (select role_id  from krim_role_t 
                                                  where role_nm = 'Proposal Creator')
) and kim_attr_defn_id = 48
/
commit
/
--MITKC-681
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
(select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('OSP Administrator')) and nmspc_cd ='KC-ADM'),
(select PERM_ID from KRIM_PERM_T where nm = 'Export Any Record' and nmspc_cd='KR-NS'),
'Y'
)
/
declare
li_count NUMBER;
li_perm_id_seq KRIM_PERM_T.PERM_ID%type;
begin
select count(PERM_ID) 
into li_count 
FROM KRIM_PERM_T WHERE nm = 'NOTIFY_PROPOSAL_PERSONS' and nmspc_cd = 'KC-PD';
  if li_count = 0 then
      Insert into KRIM_PERM_T (PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND) 
      values (KRIM_PERM_ID_S.NEXTVAL,sys_guid(),1,'58','KC-PD','NOTIFY_PROPOSAL_PERSONS','Allows user to send person ceritification notifications','Y');
  end if;

end;
/
commit
/
delete from krim_role_perm_t
where role_id in (select role_id from krim_role_t where role_nm = 'Aggregator Document Level')
and perm_id in (select perm_id from krim_perm_t where nm ='Certify')
/
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Aggregator Document Level')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'NOTIFY_PROPOSAL_PERSONS');
    
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
      (select PERM_ID from KRIM_PERM_T where nm = 'NOTIFY_PROPOSAL_PERSONS'),
      'Y'
      );    
    end if;

end;
/
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Investigators Document Level')) and nmspc_cd ='KC-PD')
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Investigators Document Level'))and nmspc_cd ='KC-PD'),
      (select PERM_ID from KRIM_PERM_T where nm = 'Certify'),
      'Y'
      );    
    end if;

end;
/
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Proposal Proxy certify')))
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
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Proposal Proxy certify'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'Certify'),
      'Y'
      );    
    end if;

end;
/
commit
/
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Aggregator Document Level')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Delete Proposal');
    
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
      (select PERM_ID from KRIM_PERM_T where nm = 'Delete Proposal'),
      'Y'
      );    
    end if;
dbms_output.put_line('Sync role rights end!!');
end;
/
update krim_role_t set kim_typ_id = 1 where role_nm = 'Negotiation Administrator'
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
delete from KRIM_ROLE_PERM_T
where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('PI')) and nmspc_cd ='KC-WKFLW')
and   PERM_ID in (select PERM_ID from krim_perm_t where upper(nm) like '%NEGOTIATION%')
/
delete from KRIM_ROLE_PERM_T
where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('COI')) and nmspc_cd ='KC-WKFLW')
and   PERM_ID in (select PERM_ID from krim_perm_t where upper(nm) like '%NEGOTIATION%')
/
delete from KRIM_ROLE_PERM_T
where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('KP')) and nmspc_cd ='KC-WKFLW')
and   PERM_ID in (select PERM_ID from krim_perm_t where upper(nm) like '%NEGOTIATION%')
/
commit
/
declare
cursor c_data is
  select trim(nvl(t2.coeus_roles,t1.role_nm)) role_nm
  from KC_ROLE_BOOTSTRAP t1 left outer join KC_COEUS_ROLE_MAPPING t2 on t1.role_nm = t2.kc_roles
  where t1.kim_typ_id = '1'
  and t1.nmspc_cd in ('KC-QUESTIONNAIRE','KC-PROTOCOL','KC-PD','KC-NEGOTIATION','KC-AWARD','KC-SUBAWARD','KC-COIDISCLOSURE','KC-IACUC');
r_data c_data%rowtype;

ls_role_id krim_role_t.role_id%type;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;
  
  begin  
    select role_id into ls_role_id from krim_role_t where role_nm = r_data.role_nm;
    
    update krim_role_t 
    set  kim_typ_id = '1'
    where role_id = ls_role_id;  
  
  exception
  when others then
  dbms_output.put_line('Error while updating kim_typ_id '||r_data.role_nm||'. Exception is '||sqlerrm);
  end;

end loop;
close c_data;

end;
/
--update and insert new permissions for WL
delete from KRIM_ROLE_PERM_T where role_id in(select role_id from KRIM_ROLE_T where role_nm like 'WL Super User')
/
delete from KRIM_ROLE_T where role_nm like 'WL Super User'
/
delete from KRIM_PERM_T where nm like 'Run_WL_Simulation'
/
delete from KRIM_PERM_T where nm like 'Edit_WL'
/
delete from KRIM_PERM_T where nm like 'View_WL'
/
INSERT INTO KRIM_PERM_T(
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
KRIM_PERM_ID_S.nextval,
sys_guid(),
1,
1,
'KC-PD',
'View_WL',
'Allow the user to see the WL screens except the simulation functionality',
'Y'
)
/
INSERT INTO KRIM_PERM_T(
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
KRIM_PERM_ID_S.nextval,
sys_guid(),
1,
1,
'KC-PD',
'Edit_WL',
'Allow the user to see and edit the WL screens except the simulation functionality',
'Y'
)
/
INSERT INTO KRIM_PERM_T(
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
KRIM_PERM_ID_S.nextval,
sys_guid(),
1,
1,
'KC-PD',
'Run_WL_Simulation',
'Allow the user to see and edit the WL screens, including the Simulation functionality both in the production and the simulation modes',
'Y'
)
/
commit
/
--create superuser role to WL and assign permissions to the role
INSERT INTO KRIM_ROLE_T(
ROLE_ID,
OBJ_ID,
VER_NBR,
ROLE_NM,
NMSPC_CD,
DESC_TXT,
KIM_TYP_ID,
ACTV_IND
)  
VALUES(
KRIM_ROLE_ID_S.NEXTVAL,
SYS_GUID(),
1,
'WL Super User',
'KC-PD',
'Provide user with View_WL,Edit_WL and Run_WL_Simulation rights',
69,
'Y'
)
/
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-PD'),
(select PERM_ID from KRIM_PERM_T where      nm = 'View_WL'),
'Y'
)
/
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-PD'),
(select PERM_ID from KRIM_PERM_T where      nm = 'Edit_WL'),
'Y'
)
/
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
(select ROLE_ID from KRIM_ROLE_T where role_nm = 'WL Super User' and NMSPC_CD='KC-PD'),
(select PERM_ID from KRIM_PERM_T where      nm = 'Run_WL_Simulation'),
'Y'
)
/
--- MITKC-799
declare
li_count PLS_INTEGER;
begin
select count(perm_id) into li_count from KRIM_PERM_T where nm = 'MAINTAIN_INST_PROPOSAL_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-IP','MAINTAIN_INST_PROPOSAL_DOC','Maintain Institute Proposal Document','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_INST_PROPOSAL_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-IP','VIEW_INST_PROPOSAL_DOC','View Institute Proposal Document','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'MAINTAIN_AWARD_DOCUMENTS';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-AWARD','MAINTAIN_AWARD_DOCUMENTS','Maintain Award Documents','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_AWARD_DOCUMENTS';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-AWARD','VIEW_AWARD_DOCUMENTS','View Award Documents','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SUBAWARD_DOCUMENTS';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-SUBAWARD','VIEW_SUBAWARD_DOCUMENTS','View Subaward Documents','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_DEV_PROPOSAL_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-PD','VIEW_DEV_PROPOSAL_DOC','View Dev Proposal Attachments','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SHARED_SUBAWARD_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-SUBAWARD','VIEW_SHARED_SUBAWARD_DOC','View Shared Subaward Attachments','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SHARED_AWARD_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-AWARD','VIEW_SHARED_AWARD_DOC','View Shared Award Documents','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SHARED_INST_PROPOSAL_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-IP','VIEW_SHARED_INST_PROPOSAL_DOC','View Shared Institute Proposal Documents','Y');
	
end if;

select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_ALL_SHARED_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-SYS','VIEW_ALL_SHARED_DOC','View All Shared Documents','Y');
	
end if;

select count(role_id) 
into li_count 
from KRIM_ROLE_T where ROLE_NM = 'View Subcontract Attachments';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View Subcontract Attachments','KC-SUBAWARD','View Subcontract Documents','69','Y',sysdate);	
end if;

select count(role_perm_id)
  into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Subcontract Attachments')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SUBAWARD_DOCUMENTS' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Subcontract Attachments'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SUBAWARD_DOCUMENTS' ),
      'Y');    
    end if;
end;
/
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
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-AWARD','VIEW_SHARED_AWARD_DOC','View Shared Award Attachments','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View Shared Award Attachments';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View Shared Award Attachments','KC-AWARD','View Shared Award Attachments','69','Y',sysdate);	
end if;
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Award Attachments')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_AWARD_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Award Attachments'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_AWARD_DOC' ),
      'Y');    
    end if;




select count(perm_id) into li_count from KRIM_PERM_T where nm = 'VIEW_SHARED_INST_PROPOSAL_DOC';
if li_count = 0 then  
    insert into KRIM_PERM_T(PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND)
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-IP','VIEW_SHARED_INST_PROPOSAL_DOC','View Shared Institute Proposal Attachments','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View Shared Institute Proposal Attachments';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View Shared Institute Proposal Attachments','KC-IP','View Shared Institute Proposal Attachments','69','Y',sysdate);	
end if;
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Institute Proposal Attachments')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_SHARED_INST_PROPOSAL_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View Shared Institute Proposal Attachments'))),
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
    VALUES(KRIM_PERM_ID_S.NEXTVAL,SYS_GUID(),1,NULL,'KC-SYS','VIEW_ALL_SHARED_DOC','View All Shared Attachments','Y');
	
end if;
select count(role_id) into li_count from KRIM_ROLE_T where ROLE_NM = 'View All Shared Attachments';
if li_count = 0 then
	INSERT INTO KRIM_ROLE_T(ROLE_ID,OBJ_ID,VER_NBR,ROLE_NM,NMSPC_CD,DESC_TXT,KIM_TYP_ID,ACTV_IND, LAST_UPDT_DT)  
	VALUES(KRIM_ROLE_ID_S.NEXTVAL,SYS_GUID(),1,'View All Shared Attachments','KC-SYS','View All Shared Attachments','69','Y',sysdate);	
end if;
    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View All Shared Attachments')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_ALL_SHARED_DOC' );
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(ROLE_PERM_ID,OBJ_ID,VER_NBR,ROLE_ID,PERM_ID,ACTV_IND)
      VALUES(KRIM_ROLE_PERM_ID_S.nextval,sys_guid(),1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('View All Shared Attachments'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'VIEW_ALL_SHARED_DOC' ),
      'Y');    
    end if;



end;
/
--MITKC-1610
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
