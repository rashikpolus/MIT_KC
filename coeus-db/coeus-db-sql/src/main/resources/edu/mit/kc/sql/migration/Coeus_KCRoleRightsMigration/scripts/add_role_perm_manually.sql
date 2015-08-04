set serveroutput on;
declare
  cursor c_data is
    select role_id, 'Add Unit' as perm_nm from krim_role_t where lower(role_nm) like '%unit%'
    union
    select role_id, 'Modify Unit' as perm_nm from krim_role_t where lower(role_nm) like '%unit%'
    union
    select role_id, 'Initiate Document' as perm_nm from krim_role_t where lower(role_nm) like '%maintain%'
    union
    select role_id, 'Initiate Document' as perm_nm from krim_role_t where lower(role_nm) like '%creat%'
    union
    select role_id, 'Initiate Document' as perm_nm from krim_role_t where lower(role_nm) like '%modif%';   
    
  r_data c_data%rowtype;  
 
 ls_perm_id krim_perm_t.perm_id%type;
 li_count number;
  
begin
  open c_data;
  loop
  fetch c_data into r_data;
  exit when c_data%notfound;
  
    begin  
         select perm_id into ls_perm_id from krim_perm_t where nm = r_data.perm_nm;
          
                
         select count(role_perm_id) into li_count 
         from KRIM_ROLE_PERM_T
         where role_id = r_data.role_id
         and   perm_id = ls_perm_id;
         
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
                    r_data.role_id,
                    ls_perm_id,
                    'Y'
                    );
                EXCEPTION
                WHEN OTHERS THEN
                   dbms_output.put_line('Error while inserting into KRIM_ROLE_PERM_T , role id is '||r_data.role_id||' and perm id is '||ls_perm_id||'.  The error is: '||sqlerrm);
                   continue;
                END;
                
         end if; 
         
    exception
    when others then
      dbms_output.put_line('Error '||sqlerrm||' perm_nm '||r_data.perm_nm);
    end;
    
  end loop;
  close c_data;
  
end;
/
