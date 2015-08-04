declare
ls_msg clob;
ls_sub varchar2(6000);
ls_temp_msg clob;
li_count NUMBER;
ls_receipt varchar2(100) := 'kc-notifications@mit.edu';
cursor c_award is
  select t2.mit_award_number ||' - ' ||t1.sequence_number as project_details  
  from award t1
  inner join TEMP_TAB_TO_SYNC_AWARD t2 on t1.award_number = replace(t2.mit_award_number,'-','-00')
  and t1.sequence_number = t2.sequence_number;
  
r_award  c_award%rowtype;

cursor c_ip is
  select t1.proposal_number||' - ' || t1.sequence_number as project_details
  from proposal t1
  inner join TEMP_TAB_TO_SYNC_IP t2 on t1.proposal_number = t2.proposal_number
  and t1.sequence_number = t2.sequence_number;
  
r_ip  c_ip%rowtype;


cursor c_eps is
  select t2.proposal_number as project_details  
  from eps_proposal t1
  inner join TEMP_TAB_TO_SYNC_DEV t2 on t1.proposal_number = to_number(t2.proposal_number);
  
r_eps  c_eps%rowtype;

cursor c_bud is
  select distinct t3.proposal_number||' - ' ||t3.version_number as project_details  
  into ls_temp_msg
  from eps_proposal t1 
  inner join budget_document t2 on t1.document_number = t2.parent_document_key
  inner join budget t4 on t4.document_number = t2.document_number
  inner join TEMP_TAB_TO_SYNC_BUDGET t3 on t1.proposal_number = to_number(t3.proposal_number);
  
cursor c_already_present is
  select proposal_number from SYNC_EPS_ALREADY_PRESENT;
 r_already_present  c_already_present%rowtype; 
  
r_bud  c_bud%rowtype;


begin
  ls_sub := 'Projects are Synced from Coeus on '||sysdate;
  ls_msg := 'Hello,'||'<br/>'||'<br/>'||'Following projects are synced from Coeus Production on '||sysdate||'<br/>'|| '<br/>';
  
  ls_temp_msg := '<u>Award</u>'||'<br/>';  
  open c_award;
  loop
  fetch c_award into r_award;
  exit when c_award%notfound;
  
    ls_temp_msg :=  ls_temp_msg || r_award.project_details;
    ls_temp_msg := ls_temp_msg || '<br/>';
    
  end loop;
  close c_award;
  ls_msg := ls_msg || ls_temp_msg|| '<br/>';
  
  ls_temp_msg := '<u>Institute Proposal</u>'||'<br/>';  
  open c_ip;
  loop
  fetch c_ip into r_ip;
  exit when c_ip%notfound;
  
    ls_temp_msg :=  ls_temp_msg || r_ip.project_details;
    ls_temp_msg := ls_temp_msg || '<br/>';
    
  end loop;
  close c_ip;
  ls_msg := ls_msg || ls_temp_msg|| '<br/>';
  
  ls_temp_msg := '<u>Development Proposal</u>'||'<br/>';  
  open c_eps;
  loop
  fetch c_eps into r_eps;
  exit when c_eps%notfound;
  
    ls_temp_msg :=  ls_temp_msg || r_eps.project_details;
    ls_temp_msg := ls_temp_msg || '<br/>';
    
  end loop;
  close c_eps;   
  ls_msg := ls_msg || ls_temp_msg|| '<br/>';
  
  ls_temp_msg := '<u>Budget</u>'||'<br/>';  
  
  open c_bud;
  loop
  fetch c_bud into r_bud;
  exit when c_bud%notfound;
  
    ls_temp_msg :=  ls_temp_msg || r_bud.project_details;
    ls_temp_msg := ls_temp_msg || '<br/>';
    
  end loop;
  close c_bud; 
  
  select count(*) into li_count from SYNC_EPS_ALREADY_PRESENT;
  if li_count > 0 then
  
	    ls_temp_msg := '<u>Proposal already created in kc and ignore copying</u>'||'<br/>';  
		  
	  open c_already_present;
	  loop
	  fetch c_already_present into r_already_present;
	  exit when c_already_present%notfound;
	  
		ls_temp_msg :=  ls_temp_msg || r_already_present.proposal_number;
		ls_temp_msg := ls_temp_msg || '<br/>';
		
	  end loop;
	  close c_already_present; 
	  
  end if;
  
  ls_msg := ls_msg || ls_temp_msg|| '<br/>'||'<br/>'||'Thank you';
  
  KC_MAIL_GENERIC_PKG.SEND_MAIL(null,ls_receipt,null,null,ls_sub,ls_msg);

end;
/