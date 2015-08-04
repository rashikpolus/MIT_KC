set serveroutput on;
declare
li_count NUMBER;
cursor c_role is
  select role_id, role_nm from kc_role_bootstrap 
  where kim_typ_id in (select kim_typ_id from krim_typ_t where nm like 'Derived Role:%');
  r_role c_role%rowtype;

cursor c_role_perm(ls_role_id VARCHAR2) is
  select role_id, perm_id from kc_role_perm_bootstrap 
  where role_id = ls_role_id;
  r_role_perm c_role_perm%rowtype;

begin

  open c_role;
  loop
  fetch c_role into r_role;
  exit when c_role%notfound;
  
  select count(role_id) into li_count from krim_role_t where role_id = r_role.role_id;
  if li_count = 0 then
  
        insert into krim_role_t(
                          role_id,
                          obj_id,
                          ver_nbr,
                          role_nm,
                          nmspc_cd,
                          desc_txt,
                          kim_typ_id,
                          actv_ind
                          )
        select role_id,
              sys_guid(),
              ver_nbr,
              role_nm,
              nmspc_cd,
              desc_txt,
              kim_typ_id,
              actv_ind
              from kc_role_bootstrap
        where role_id = r_role.role_id;		
    
    dbms_output.put_line('Inserted Derived role: '||r_role.role_nm);
    
    open c_role_perm(r_role.role_id);
    loop
    fetch c_role_perm into r_role_perm;
    exit when c_role_perm%notfound;
          
            select count(role_id) into li_count from krim_role_perm_t 
            where role_id = r_role_perm.role_id and perm_id = r_role_perm.perm_id;
            
            if li_count = 0 then
            
              insert into krim_role_perm_t(
                      role_perm_id,
                      obj_id,
                      ver_nbr,
                      role_id,
                      perm_id,
                      actv_ind
                      )
             select  role_perm_id,
                      sys_guid(),
                      ver_nbr,
                      role_id,
                      perm_id,
                      actv_ind
            from kc_role_perm_bootstrap where role_id = r_role_perm.role_id and perm_id = r_role_perm.perm_id;
            
            dbms_output.put_line('  Inserted Permission for Derived role: '||r_role.role_nm||' is '||r_role_perm.perm_id);
            
            end if;
            
    end loop;
    close c_role_perm;
    
  end if;  
      
  end loop;
  close c_role;

end;
/
