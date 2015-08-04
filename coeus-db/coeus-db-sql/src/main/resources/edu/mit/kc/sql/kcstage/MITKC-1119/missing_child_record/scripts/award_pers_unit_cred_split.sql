declare
ls_award_number varchar2(12);
li_seq number(4,0);
ls_awd_num varchar2(12);
li_award_pers_unit_id NUMBER(12,0);
cursor c_refresh is
select award_id,mit_award_number,sequence_number from REFRESH_AWARD
order by award_id,mit_award_number,sequence_number;
r_refresh c_refresh%rowtype;

cursor c_cost(as_awd varchar2,as_seq number) is
select ac.MIT_AWARD_NUMBER,ac.SEQUENCE_NUMBER,ac.PERSON_ID,r.ROLODEX_ID,ac.UNIT_NUMBER,ac.INV_CREDIT_TYPE_CODE,ac.CREDIT,ac.UPDATE_TIMESTAMP,ac.UPDATE_USER
from OSP$AWARD_UNIT_CREDIT_SPLIT@coeus.kuali ac
left outer join ROLODEX r on ac.PERSON_ID=r.ROLODEX_ID
where MIT_AWARD_NUMBER = as_awd and SEQUENCE_NUMBER = (select max(t.SEQUENCE_NUMBER) from OSP$AWARD_UNIT_CREDIT_SPLIT@coeus.kuali  t where t.MIT_AWARD_NUMBER = as_awd and t.SEQUENCE_NUMBER<=as_seq);
r_cost c_cost%rowtype;

begin
if c_refresh%isopen then
close c_refresh;
end if;
open c_refresh;
loop
fetch c_refresh into r_refresh;
exit when c_refresh%notfound;

ls_award_number:=r_refresh.mit_award_number;
li_seq:=r_refresh.sequence_number;

if c_cost%isopen then
close c_cost;
end if;
open c_cost(ls_award_number,li_seq);
loop
fetch c_cost into r_cost;
exit when c_cost%notfound;

  ls_awd_num:=replace(r_refresh.MIT_AWARD_NUMBER,'-','-00');
  
  begin
select award_person_unit_id into li_award_pers_unit_id from award_person_units a 
inner join award_persons ap ON a.award_person_id=ap.award_person_id 
where ap.award_number=ls_awd_num and ap.sequence_number=r_refresh.sequence_number
and ap.PERSON_ID=r_cost.PERSON_ID OR ap.ROLODEX_ID=r_cost.PERSON_ID and ap.contact_role_code <> 'KP';

exception
when others then
dbms_output.put_line('Error in "award_pers_unit_credit_split.sql" '||ls_awd_num||','||r_refresh.sequence_number||','||r_cost.PERSON_ID||' - '||sqlerrm);
continue;
end;
  
  INSERT INTO AWARD_PERS_UNIT_CRED_SPLITS(APU_CREDIT_SPLIT_ID,AWARD_PERSON_UNIT_ID,INV_CREDIT_TYPE_CODE,CREDIT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
  VALUES(SEQUENCE_AWARD_ID.NEXTVAL,li_award_pers_unit_id,r_cost.INV_CREDIT_TYPE_CODE,r_cost.CREDIT,r_cost.UPDATE_TIMESTAMP,r_cost.UPDATE_USER,1,SYS_GUID());

end loop;
close c_cost;
end loop;
close c_refresh;
end;
/    