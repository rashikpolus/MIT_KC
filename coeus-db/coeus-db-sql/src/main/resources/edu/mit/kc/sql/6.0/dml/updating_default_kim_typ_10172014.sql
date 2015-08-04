set serveroutput on;
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
