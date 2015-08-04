declare
cursor c_update is
select PROPOSAL_NUMBER,KUALI_SEQUENCE_NUMBER from V_PROPOSAL_IDC;
r_update c_update%rowtype;

begin
if c_update%isopen then
close c_update;
end if;
open c_update;
loop
fetch c_update into r_update;
exit when c_update%notfound;

update PROPOSAL_IDC_RATE 
set ON_CAMPUS_FLAG = 'Y' 
Where PROPOSAL_NUMBER=r_update.PROPOSAL_NUMBER 
and SEQUENCE_NUMBER=r_update.KUALI_SEQUENCE_NUMBER 
and ON_CAMPUS_FLAG = 'N';

update PROPOSAL_IDC_RATE 
set ON_CAMPUS_FLAG = 'N' 
Where PROPOSAL_NUMBER=r_update.PROPOSAL_NUMBER 
and SEQUENCE_NUMBER=r_update.KUALI_SEQUENCE_NUMBER 
and ON_CAMPUS_FLAG = 'F';

end loop;
close c_update;
end;
/
commit
/
