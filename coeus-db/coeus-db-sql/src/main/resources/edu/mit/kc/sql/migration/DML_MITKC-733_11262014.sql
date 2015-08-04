declare 
li_award_science number(12,0);
cursor c_science is
select AWARD_ID,SCIENCE_KEYWORD_CODE from AWARD_SCIENCE_KEYWORD group by AWARD_ID,SCIENCE_KEYWORD_CODE
having count(AWARD_ID)>1;
r_science c_science%rowtype;

begin

if c_science%isopen then
close c_science;
end if;
open c_science;
loop
fetch c_science into r_science;
exit when c_science%notfound;


delete from AWARD_SCIENCE_KEYWORD t1 where rowid not in (
    select max(t2.rowid) from AWARD_SCIENCE_KEYWORD t2 where t1.AWARD_ID = t2.AWARD_ID
    and t2.SCIENCE_KEYWORD_CODE = t1.SCIENCE_KEYWORD_CODE 
    )
    and t1.AWARD_ID = r_science.AWARD_ID
    and t1.SCIENCE_KEYWORD_CODE = r_science.SCIENCE_KEYWORD_CODE;

end loop;
close c_science;
end;
/
commit
/