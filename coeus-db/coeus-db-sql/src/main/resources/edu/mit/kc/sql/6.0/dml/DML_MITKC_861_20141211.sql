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
