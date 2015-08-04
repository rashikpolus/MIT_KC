declare
li_max number(12,0);
cursor c_data is
select seq_owner_version_name_value,seq_owner_seq_number from version_history 
group by seq_owner_version_name_value,seq_owner_seq_number having count(seq_owner_version_name_value)>1
order by seq_owner_version_name_value;
r_data c_data%rowtype;

begin 
if c_data%isopen then
close c_data;
end if;
open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

select max(version_history_id) into li_max from version_history
where  seq_owner_version_name_value= r_data.seq_owner_version_name_value 
and    seq_owner_seq_number = r_data.seq_owner_seq_number;

delete from version_history
where seq_owner_version_name_value= r_data.seq_owner_version_name_value
and seq_owner_seq_number = r_data.seq_owner_seq_number 
and version_history_id <> li_max;

end loop;
close c_data;
end;
/
