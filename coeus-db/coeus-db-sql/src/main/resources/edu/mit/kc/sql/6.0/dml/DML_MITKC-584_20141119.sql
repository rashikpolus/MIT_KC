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
