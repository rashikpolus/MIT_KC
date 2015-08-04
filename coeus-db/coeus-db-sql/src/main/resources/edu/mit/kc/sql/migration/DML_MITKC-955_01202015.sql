declare
cursor c_dev is
select to_number(proposal_number) proposal_number,person_id, non_mit_person_flag 
from osp$eps_prop_investigators@coeus.kuali
where multi_pi_flag = 'Y'
and principal_investigator_flag = 'N';
r_dev c_dev%rowtype;

cursor c_ip is
select  t1.proposal_number,t2.sequence_number ,t1.person_id,t1.non_mit_person_flag
from osp$proposal_investigators@coeus.kuali t1
inner join osp$proposal@coeus.kuali t2 on t1.proposal_number = t2.proposal_number
where t1.multi_pi_flag = 'Y'
and t1.principal_investigator_flag = 'N'
and t1.sequence_number = ( select max(s1.sequence_number) from osp$proposal_investigators@coeus.kuali s1
                            where s1.proposal_number = t1.proposal_number 
                            and s1.sequence_number <= t2.sequence_number);
r_ip c_ip%rowtype;

cursor c_award is
select  replace(t1.mit_award_number,'-','-00') award_number,t2.sequence_number ,t1.person_id,t1.non_mit_person_flag
from OSP$AWARD_INVESTIGATORS@coeus.kuali t1
inner join OSP$AWARD@coeus.kuali t2 on t1.mit_award_number = t2.mit_award_number
where t1.multi_pi_flag = 'Y'
and t1.principal_investigator_flag = 'N'
and t1.sequence_number = ( select max(s1.sequence_number) from OSP$AWARD_INVESTIGATORS@coeus.kuali s1
                            where s1.mit_award_number = t1.mit_award_number 
                            and s1.sequence_number <= t2.sequence_number);
r_award c_award%rowtype;


begin

open c_dev;
loop
fetch c_dev into r_dev;
exit when c_dev%notfound;

  if r_dev.non_mit_person_flag = 'N' then
    update eps_prop_person set prop_person_role_id = 'MPI' 
    where proposal_number = r_dev.proposal_number
    and person_id = r_dev.person_id;
    
  else
    update eps_prop_person set prop_person_role_id = 'MPI' 
    where proposal_number = r_dev.proposal_number
    and rolodex_id = r_dev.person_id;
    
  end if;

end loop;
close c_dev;


open c_ip;
loop
fetch c_ip into r_ip;
exit when c_ip%notfound;

  if r_ip.non_mit_person_flag = 'N' then
    update PROPOSAL_PERSONS set CONTACT_ROLE_CODE = 'MPI' 
    where proposal_number = r_ip.proposal_number
    and  sequence_number = r_ip.sequence_number
    and person_id = r_ip.person_id;
    
  else
    update PROPOSAL_PERSONS set CONTACT_ROLE_CODE = 'MPI' 
    where proposal_number = r_ip.proposal_number
    and  sequence_number = r_ip.sequence_number
    and rolodex_id = r_ip.person_id;
    
  end if;

end loop;
close c_ip;

open c_award;
loop
fetch c_award into r_award;
exit when c_award%notfound;

  if r_award.non_mit_person_flag = 'N' then
    update AWARD_PERSONS set CONTACT_ROLE_CODE = 'MPI' 
    where award_number = r_award.award_number
    and  sequence_number = r_award.sequence_number
    and person_id = r_award.person_id;
    
  else
    update AWARD_PERSONS set CONTACT_ROLE_CODE = 'MPI' 
    where award_number = r_award.award_number
    and  sequence_number = r_award.sequence_number
    and rolodex_id = r_award.person_id;
    
  end if;

end loop;
close c_award;

end;
/
commit
/
