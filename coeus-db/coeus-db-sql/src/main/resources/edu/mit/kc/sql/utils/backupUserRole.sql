set heading off;
set verify off;
set serveroutput on;
DECLARE
LS_MODULE_NAME VARCHAR(100);
li_count number;
ls_prncpl_id VARCHAR2(40);
li_exception PLS_INTEGER;
BEGIN
 LS_MODULE_NAME:='&&prncpl_nm';	
 
 li_exception := 0;
 begin
	select prncpl_id into ls_prncpl_id from KRIM_PRNCPL_T where upper(trim(prncpl_nm)) = upper(trim(LS_MODULE_NAME));	
	
 exception
 when others then
 li_exception := 1;
 dbms_output.put_line('Not prncpl id was found for the input pncpl name '||LS_MODULE_NAME);
 end;
 
select  count(MBR_ID) into li_count from BAKUP_KRIM_ROLE_MBR where MBR_ID=ls_prncpl_id;
if li_count > 0 then
 li_exception := 1;
 dbms_output.put_line('The pncpl name '||LS_MODULE_NAME|| ' has already copied.');
end if; 
  
 
if li_exception = 0 then
  select  count(table_name) into li_count  from all_tables   where table_name = 'BAKUP_KRIM_ROLE_MBR';
  if li_count = 0 then
    execute immediate('CREATE TABLE BAKUP_KRIM_ROLE_MBR
   (	ROLE_MBR_ID VARCHAR2(40), 
	VER_NBR NUMBER(8,0), 
	OBJ_ID VARCHAR2(36), 
	ROLE_ID VARCHAR2(40), 
	MBR_ID VARCHAR2(40) , 
	MBR_TYP_CD CHAR(1), 
	ACTV_FRM_DT DATE, 
	ACTV_TO_DT DATE, 
	LAST_UPDT_DT DATE)');
  end if;
  
  select  count(table_name) into li_count  from all_tables   where table_name = 'BAKUP_KRIM_ROLE_MBR_ATTR_DATA';
  if li_count = 0 then
execute immediate('CREATE TABLE BAKUP_KRIM_ROLE_MBR_ATTR_DATA
(	ATTR_DATA_ID VARCHAR2(40), 
OBJ_ID VARCHAR2(36) , 
VER_NBR NUMBER(8,0), 
ROLE_MBR_ID VARCHAR2(40), 
KIM_TYP_ID VARCHAR2(40), 
KIM_ATTR_DEFN_ID VARCHAR2(40), 
ATTR_VAL VARCHAR2(400)
)');
  end if;
  
  insert into BAKUP_KRIM_ROLE_MBR(
	ROLE_MBR_ID,
	VER_NBR,
	OBJ_ID,
	ROLE_ID,
	MBR_ID,
	MBR_TYP_CD,
	ACTV_FRM_DT,
	ACTV_TO_DT,
	LAST_UPDT_DT
  )
  select 
  	ROLE_MBR_ID,
	VER_NBR,
	OBJ_ID,
	ROLE_ID,
	MBR_ID,
	MBR_TYP_CD,
	ACTV_FRM_DT,
	ACTV_TO_DT,
	LAST_UPDT_DT
 FROM KRIM_ROLE_MBR_T
 WHERE  MBR_ID = ls_prncpl_id;
 
 commit;
  
insert into BAKUP_KRIM_ROLE_MBR_ATTR_DATA(
	ATTR_DATA_ID,
	OBJ_ID,
	VER_NBR,
	ROLE_MBR_ID,
	KIM_TYP_ID,
	KIM_ATTR_DEFN_ID,
	ATTR_VAL
) 
select 
	t2.ATTR_DATA_ID,
	t2.OBJ_ID,
	t2.VER_NBR,
	t2.ROLE_MBR_ID,
	t2.KIM_TYP_ID,
	t2.KIM_ATTR_DEFN_ID,
	t2.ATTR_VAL
	from
KRIM_ROLE_MBR_T t1 inner join KRIM_ROLE_MBR_ATTR_DATA_T t2 on t1.ROLE_MBR_ID = t2.ROLE_MBR_ID
where t1.MBR_ID = ls_prncpl_id;
commit;

 dbms_output.put_line('Backup for  '||LS_MODULE_NAME||' is completed and the backup table is BAKUP_KRIM_ROLE_MBR,BAKUP_KRIM_ROLE_MBR_ATTR_DATA.');
 
end if; 
 
END;
/