declare
li_max number(12,0);
cursor c_del_reports is
select award_report_terms_id,contact_type_code,rolodex_id from award_rep_terms_recnt 
group by award_report_terms_id,contact_type_code,rolodex_id having count(award_report_terms_id)>1
order by award_report_terms_id;
r_del_reports c_del_reports%rowtype;

begin 
if c_del_reports%isopen then
close c_del_reports;
end if;
open c_del_reports;
loop
fetch c_del_reports into r_del_reports;
exit when c_del_reports%notfound;

select max(award_rep_terms_recnt_id) into li_max from award_rep_terms_recnt where  award_report_terms_id= r_del_reports.award_report_terms_id and contact_type_code= r_del_reports.contact_type_code and rolodex_id= r_del_reports.rolodex_id;

delete from award_rep_terms_recnt
where award_report_terms_id= r_del_reports.award_report_terms_id
and contact_type_code= r_del_reports.contact_type_code 
and rolodex_id= r_del_reports.rolodex_id
and award_rep_terms_recnt_id <> li_max;

end loop;
close c_del_reports;
end;
/
