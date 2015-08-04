declare
ls_proposal_number varchar2(8);
li_seq number(4,0);
cursor c_update is
select distinct PROPOSAL_NUMBER,KUALI_SEQUENCE_NUMBER from V_PROPOSAL_IDC
order by PROPOSAL_NUMBER,KUALI_SEQUENCE_NUMBER;
r_update c_update%rowtype;

cursor c_idc(as_prop varchar2 , as_seq number) is
select p.PROPOSAL_NUMBER,p.SEQUENCE_NUMBER,p.APPLICABLE_IDC_RATE,p.IDC_RATE_TYPE_CODE,p.FISCAL_YEAR,ON_CAMPUS_FLAG,p.SOURCE_ACCOUNT from osp$proposal_idc_rate@coeus.kuali p
where p.PROPOSAL_NUMBER=as_prop and p.SEQUENCE_NUMBER=(select max(i.sequence_number) from osp$proposal_idc_rate@coeus.kuali i 
where i.proposal_number=as_prop and i.sequence_number<=as_seq);
r_idc c_idc%rowtype;

begin
if c_update%isopen then
close c_update;
end if;
open c_update;
loop
fetch c_update into r_update;
exit when c_update%notfound;

ls_proposal_number:=r_update.PROPOSAL_NUMBER;
li_seq:=r_update.KUALI_SEQUENCE_NUMBER;

if c_idc%isopen then
close c_idc;
end if;
open c_idc(ls_proposal_number,li_seq);
loop
fetch c_idc into r_idc;
exit when c_idc%notfound;



update PROPOSAL_IDC_RATE 
set ON_CAMPUS_FLAG = r_idc.ON_CAMPUS_FLAG
Where PROPOSAL_NUMBER = ls_proposal_number 
and SEQUENCE_NUMBER = li_seq 
and APPLICABLE_IDC_RATE = r_idc.APPLICABLE_IDC_RATE
and IDC_RATE_TYPE_CODE = r_idc.IDC_RATE_TYPE_CODE
and FISCAL_YEAR = r_idc.FISCAL_YEAR
and SOURCE_ACCOUNT = r_idc.SOURCE_ACCOUNT;

end loop;
close c_idc;
end loop;
close c_update;
end;
/
commit
/
declare
li_max number(12,0);
cursor c_prop is
select PROPOSAL_NUMBER,SEQUENCE_NUMBER,APPLICABLE_IDC_RATE,IDC_RATE_TYPE_CODE,FISCAL_YEAR,SOURCE_ACCOUNT,ON_CAMPUS_FLAG from PROPOSAL_IDC_RATE GROUP BY 
PROPOSAL_NUMBER,SEQUENCE_NUMBER,APPLICABLE_IDC_RATE,IDC_RATE_TYPE_CODE,FISCAL_YEAR,SOURCE_ACCOUNT,ON_CAMPUS_FLAG HAVING COUNT(PROPOSAL_ID)>1;
r_prop c_prop%rowtype;

begin
if c_prop%isopen then
close c_prop;
end if;
open c_prop;
loop
fetch c_prop into r_prop;
exit when c_prop%notfound;

select max(PROPOSAL_IDC_RATE_ID) into li_max from PROPOSAL_IDC_RATE
where PROPOSAL_NUMBER = r_prop.PROPOSAL_NUMBER
and SEQUENCE_NUMBER= r_prop.SEQUENCE_NUMBER
and APPLICABLE_IDC_RATE = r_prop.APPLICABLE_IDC_RATE
and IDC_RATE_TYPE_CODE = r_prop.IDC_RATE_TYPE_CODE
and FISCAL_YEAR = r_prop.FISCAL_YEAR
and SOURCE_ACCOUNT = r_prop.SOURCE_ACCOUNT
and ON_CAMPUS_FLAG= r_prop.ON_CAMPUS_FLAG;

update PROPOSAL_IDC_RATE 
set ON_CAMPUS_FLAG = decode(r_prop.ON_CAMPUS_FLAG,'Y','N','N','Y')
Where PROPOSAL_NUMBER = r_prop.PROPOSAL_NUMBER
and SEQUENCE_NUMBER = r_prop.SEQUENCE_NUMBER
and APPLICABLE_IDC_RATE = r_prop.APPLICABLE_IDC_RATE
and IDC_RATE_TYPE_CODE = r_prop.IDC_RATE_TYPE_CODE
and FISCAL_YEAR = r_prop.FISCAL_YEAR
and SOURCE_ACCOUNT = r_prop.SOURCE_ACCOUNT
and ON_CAMPUS_FLAG= r_prop.ON_CAMPUS_FLAG
and PROPOSAL_IDC_RATE_ID = li_max;

end loop;
close c_prop;
end;
/
commit
/