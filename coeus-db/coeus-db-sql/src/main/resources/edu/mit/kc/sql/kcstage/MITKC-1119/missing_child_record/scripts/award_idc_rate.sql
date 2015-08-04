declare
ls_award_number varchar2(12);
li_seq number(4,0);
ls_awd_num varchar2(12);
cursor c_refresh is
select award_id,mit_award_number,sequence_number from REFRESH_AWARD
order by award_id,mit_award_number,sequence_number;
r_refresh c_refresh%rowtype;

cursor c_cost(as_awd varchar2,as_seq number) is
select MIT_AWARD_NUMBER,SEQUENCE_NUMBER,APPLICABLE_IDC_RATE,IDC_RATE_TYPE_CODE,FISCAL_YEAR,START_DATE,DECODE(ON_CAMPUS_FLAG,'Y','N','N','F') ON_CAMPUS_FLAG,SOURCE_ACCOUNT,DESTINATION_ACCOUNT,UNDERRECOVERY_OF_IDC,END_DATE,UPDATE_TIMESTAMP,UPDATE_USER
from OSP$AWARD_IDC_RATE@coeus.kuali 
where MIT_AWARD_NUMBER = as_awd and SEQUENCE_NUMBER = (select max(t.SEQUENCE_NUMBER) from OSP$AWARD_IDC_RATE@coeus.kuali  t where t.MIT_AWARD_NUMBER = as_awd and t.SEQUENCE_NUMBER<=as_seq);
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
  
  INSERT INTO AWARD_IDC_RATE(AWARD_IDC_RATE_ID,AWARD_NUMBER,SEQUENCE_NUMBER,AWARD_ID,APPLICABLE_IDC_RATE,IDC_RATE_TYPE_CODE,FISCAL_YEAR,ON_CAMPUS_FLAG,UNDERRECOVERY_OF_IDC,SOURCE_ACCOUNT,DESTINATION_ACCOUNT,START_DATE,END_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
  VALUES(SEQUENCE_AWARD_ID.NEXTVAL,ls_awd_num,r_refresh.sequence_number,r_refresh.AWARD_ID,r_cost.APPLICABLE_IDC_RATE,r_cost.IDC_RATE_TYPE_CODE,r_cost.FISCAL_YEAR,r_cost.ON_CAMPUS_FLAG,r_cost.UNDERRECOVERY_OF_IDC,r_cost.SOURCE_ACCOUNT,r_cost.DESTINATION_ACCOUNT,r_cost.START_DATE,r_cost.END_DATE,1,r_cost.UPDATE_TIMESTAMP,r_cost.UPDATE_USER,SYS_GUID());
  
end loop;
close c_cost;
end loop;
close c_refresh;
end;
/    