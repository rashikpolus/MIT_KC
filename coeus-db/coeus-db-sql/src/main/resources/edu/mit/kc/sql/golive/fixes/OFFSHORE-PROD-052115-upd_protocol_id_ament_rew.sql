declare
li_protocol_id number(12);
cursor c_amend_renew is
 select t2.PROTOCOL_ID, t1.proto_amend_ren_number
 from proto_amend_renewal t1
 inner join protocol t2 on t2.PROTOCOL_NUMBER = t1.proto_amend_ren_number
 where t1.PROTOCOL_ID <> t2.PROTOCOL_ID;

r_amend_renew c_amend_renew%rowtype;

begin
if c_amend_renew%isopen then
close c_amend_renew;
end if;
open c_amend_renew;
loop
fetch c_amend_renew into r_amend_renew;
exit when c_amend_renew%notfound;

    update proto_amend_renewal 
	set protocol_id = r_amend_renew.protocol_id
	where proto_amend_ren_number = r_amend_renew.proto_amend_ren_number;
	
end loop;
close c_amend_renew;
end;
/
