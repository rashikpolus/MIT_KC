set serveroutput on
/
declare

  li_doc_typ_id krew_doc_typ_t.doc_typ_id%type;

cursor c_doc_typ is
  select distinct doc_typ_id from krew_doc_hdr_t;
r_doc_typ  c_doc_typ%rowtype;
begin

  open c_doc_typ;
  loop
  fetch c_doc_typ into r_doc_typ;
  exit when c_doc_typ%notfound;
  
  begin
   
    select max(to_number(doc_typ_id)) into li_doc_typ_id from krew_doc_typ_t
    where doc_typ_nm in ( select DOC_TYP_NM from krew_doc_typ_t where doc_typ_id = r_doc_typ.doc_typ_id);
 
    if li_doc_typ_id <> r_doc_typ.doc_typ_id then
    
       update krew_doc_hdr_t set doc_typ_id = li_doc_typ_id
       where doc_typ_id = r_doc_typ.doc_typ_id;
       
       dbms_output.put_line('updated doc_typ_id from '||r_doc_typ.doc_typ_id||' to  '||li_doc_typ_id);  
    
        commit;
        
    end if;
      
  exception
  when others then
  dbms_output.put_line('Error occured for doc_typ_id '||r_doc_typ.doc_typ_id||'. '||sqlerrm);  
  end;
  
  end loop;
  close c_doc_typ;

end;
/
