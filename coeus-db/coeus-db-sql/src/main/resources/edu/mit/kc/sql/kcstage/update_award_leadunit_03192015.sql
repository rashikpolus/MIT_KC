declare
  cursor c_awd is
  select replace(award_number,'-00','-') mit_award_number, award_id, sequence_number
  from award  where lead_unit_number is null
  order by 1,2;
  r_awd c_awd%ROWTYPE;
  ls_lead_unit_num  VARCHAR2(8);
begin
open c_awd;
loop
fetch c_awd into r_awd;
exit when c_awd%notfound;

  BEGIN			
			select b.unit_number INTO ls_lead_unit_num from osp$award_units@coeus.kuali b
			where b.lead_unit_flag = 'Y'
			and   b.mit_award_number = r_awd.MIT_AWARD_NUMBER
			and   b.sequence_number = ( select max(s1.sequence_number) 
										from osp$award_units@coeus.kuali s1
										where s1.mit_award_number = r_awd.MIT_AWARD_NUMBER
										and   s1.sequence_number <= r_awd.SEQUENCE_NUMBER
									  )
			and rownum < 2;
			
	EXCEPTION
	WHEN OTHERS THEN
		ls_lead_unit_num:=NULL;
	END;
	
update award set lead_unit_number = ls_lead_unit_num where award_id = r_awd.award_id;


commit;


end loop;
close c_awd;
end;
/
