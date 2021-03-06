declare
ls_award_number varchar2(12);
li_seq number(4,0);
ls_awd_num varchar2(12);
cursor c_refresh is
select award_id,mit_award_number,sequence_number from REFRESH_AWARD
order by award_id,mit_award_number,sequence_number;
r_refresh c_refresh%rowtype;

cursor c_cost(as_awd varchar2,as_seq number) is
select MIT_AWARD_NUMBER,SEQUENCE_NUMBER,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER
from OSP$AWARD_APPROVED_EQUIPMENT@coeus.kuali
where MIT_AWARD_NUMBER = as_awd and SEQUENCE_NUMBER = (select max(t.SEQUENCE_NUMBER) from OSP$AWARD_APPROVED_EQUIPMENT@coeus.kuali t where t.MIT_AWARD_NUMBER = as_awd and t.SEQUENCE_NUMBER<=as_seq);
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
  
   INSERT INTO AWARD_APPROVED_EQUIPMENT(AWARD_APPROVED_EQUIPMENT_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,ITEM,VENDOR,MODEL,AMOUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
   VALUES(SEQUENCE_AWARD_ID.NEXTVAL,r_refresh.AWARD_ID,ls_awd_num,r_refresh.sequence_number,r_cost.ITEM,r_cost.VENDOR,r_cost.MODEL,r_cost.AMOUNT,r_cost.UPDATE_TIMESTAMP,r_cost.UPDATE_USER,1,SYS_GUID());
   
end loop;
close c_cost;
end loop;
close c_refresh;
end;
/