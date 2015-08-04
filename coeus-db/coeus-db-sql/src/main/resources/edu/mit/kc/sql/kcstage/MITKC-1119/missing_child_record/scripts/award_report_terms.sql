declare
ls_award_number varchar2(12);
li_seq number(4,0);
ls_awd_num varchar2(12);
li_award_reports_id number(12,0);
ls_distribution_code VARCHAR2(3);
li_num number;
li_count number;
cursor c_refresh is
select award_id,mit_award_number,sequence_number from REFRESH_AWARD
order by award_id,mit_award_number,sequence_number;
r_refresh c_refresh%rowtype;

cursor c_cost(as_awd varchar2,as_seq number) is
select MIT_AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,CONTACT_TYPE_CODE,ROLODEX_ID,DUE_DATE,NUMBER_OF_COPIES,UPDATE_TIMESTAMP,UPDATE_USER
from OSP$AWARD_REPORT_TERMS@coeus.kuali 
where MIT_AWARD_NUMBER = as_awd and SEQUENCE_NUMBER = (select max(t.SEQUENCE_NUMBER) from OSP$AWARD_REPORT_TERMS@coeus.kuali  t where t.MIT_AWARD_NUMBER = as_awd and t.SEQUENCE_NUMBER<=as_seq);
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
  
  
  select count(OSP_DISTRIBUTION_CODE) into li_count FROM DISTRIBUTION WHERE OSP_DISTRIBUTION_CODE=r_cost.OSP_DISTRIBUTION_CODE;
  IF li_count=0 THEN
    ls_distribution_code:= null;
	ELSE
	  ls_distribution_code:=r_cost.OSP_DISTRIBUTION_CODE;
  END IF;
  IF ls_distribution_code = -1 Then
	ls_distribution_code := null;
  end if;
   
   select count(award_report_terms_id) into li_num from award_report_terms where award_number=ls_award_number and sequence_number=r_refresh.SEQUENCE_NUMBER 
and report_class_code=r_cost.report_class_code and report_code=r_cost.report_code and frequency_code=r_cost.frequency_code 
and frequency_base_code=r_cost.frequency_base_code and osp_distribution_code=r_cost.osp_distribution_code and due_date=r_cost.due_date;

if li_num=0 then
   select SEQUENCE_AWARD_ID.NEXTVAL into li_award_reports_id from dual;
   INSERT INTO AWARD_REPORT_TERMS(AWARD_REPORT_TERMS_ID,AWARD_ID,AWARD_NUMBER,SEQUENCE_NUMBER,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	   VALUES(li_award_reports_id,r_refresh.AWARD_ID,ls_awd_num,r_refresh.sequence_number,r_cost.REPORT_CLASS_CODE,r_cost.REPORT_CODE,r_cost.FREQUENCY_CODE,r_cost.FREQUENCY_BASE_CODE,ls_distribution_code,r_cost.DUE_DATE,1,r_cost.UPDATE_TIMESTAMP,r_cost.UPDATE_USER,SYS_GUID());

end if;
	   
	   INSERT INTO AWARD_REP_TERMS_RECNT(AWARD_REP_TERMS_RECNT_ID,CONTACT_ID,AWARD_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID) 
       VALUES(SEQ_AWARD_REP_TERMS_RECNT_ID.NEXTVAL,null,li_award_reports_id,r_cost.CONTACT_TYPE_CODE,r_cost.ROLODEX_ID,r_cost.NUMBER_OF_COPIES,1,r_cost.UPDATE_TIMESTAMP,r_cost.UPDATE_USER,SYS_GUID());
	  commit; 
end loop;
close c_cost;
end loop;
close c_refresh;
end;
/	   