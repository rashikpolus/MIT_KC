declare
cursor c_data is
select to_number(subcontract_code) as subcontract_code,sequence_number,account_number 
from osp$subcontract@coeus.kuali where account_number is not null;
r_data c_data%rowtype;
begin
open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

update subaward set account_number = r_data.account_number 
where subaward_code = r_data.subcontract_code
and sequence_number = r_data.sequence_number
and account_number is null;

end loop;
close c_data;

end;
/
commit
/
