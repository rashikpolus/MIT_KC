declare
li_award_attachment number(12);
cursor c_del is
select AWARD_ID,TYPE_CODE,DOCUMENT_ID,FILE_ID FROM AWARD_ATTACHMENT GROUP BY AWARD_ID,TYPE_CODE,DOCUMENT_ID,FILE_ID
HAVING COUNT(AWARD_ID)>1;
r_del c_del%rowtype;

begin
if c_del%isopen then
close c_del;
end if;
open c_del;
loop
fetch c_del into r_del;
exit when c_del%notfound;

select max(award_attachment_id) into li_award_attachment 
from award_attachment 
where award_id=r_del.award_id 
and type_code=r_del.type_code 
and document_id=r_del.document_id 
and file_id=r_del.file_id;

delete from award_attachment
where award_id=r_del.award_id 
and type_code=r_del.type_code 
and document_id=r_del.document_id 
and file_id=r_del.file_id
and award_attachment_id<>li_award_attachment;

end loop;
close c_del;
end;
/
commit
/
