set serveroutput on
/
declare
li_rolodex_id VARCHAR2(9);  
cursor c_data is
select to_number(s1.proposal_number) as proposal_number,s1.module_number,s1.file_name 
from osp$narrative_pdf@coeus.kuali s1 
inner join narrative s2 on to_number(s1.proposal_number) = s2.proposal_number and s1.module_number = s2.module_number
where  s2.file_name is null;
r_data c_data%rowtype;
begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;


update narrative set file_name = r_data.file_name
where proposal_number = r_data.proposal_number
and module_number = r_data.module_number;

end loop;
close c_data;

end;
/
commit
/
update narrative set module_title = 'migrated module title'
where narrative_type_code = 8 and module_title is null
/
commit
/
update narrative set comments = 'migrated comments'
where narrative_type_code = 8 and module_title is null
/
commit
/
