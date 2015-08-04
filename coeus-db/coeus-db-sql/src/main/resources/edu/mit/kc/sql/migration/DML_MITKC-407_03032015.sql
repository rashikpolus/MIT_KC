declare
li_attach number;
cursor c_attachment is
select SUBAWARD_CODE,SEQUENCE_NUMBER,ATTACHMENT_TYPE_CODE,DOCUMENT_ID FROM SUBAWARD_ATTACHMENTS 
GROUP BY SUBAWARD_CODE,SEQUENCE_NUMBER,ATTACHMENT_TYPE_CODE,DOCUMENT_ID
HAVING COUNT(SUBAWARD_CODE)>1;
r_attachment c_attachment%rowtype;

begin
if c_attachment%isopen then
close c_attachment;
end if;
open c_attachment;
loop
fetch c_attachment into r_attachment;
exit when c_attachment%notfound;
 select max(attachment_id) into li_attach from SUBAWARD_ATTACHMENTS
 where SUBAWARD_CODE = r_attachment.SUBAWARD_CODE and SEQUENCE_NUMBER = r_attachment.SEQUENCE_NUMBER
 and ATTACHMENT_TYPE_CODE = r_attachment.ATTACHMENT_TYPE_CODE and DOCUMENT_ID = r_attachment.DOCUMENT_ID;
 
 delete from SUBAWARD_ATTACHMENTS
 where SUBAWARD_CODE = r_attachment.SUBAWARD_CODE and SEQUENCE_NUMBER = r_attachment.SEQUENCE_NUMBER
 and ATTACHMENT_TYPE_CODE = r_attachment.ATTACHMENT_TYPE_CODE and DOCUMENT_ID = r_attachment.DOCUMENT_ID and ATTACHMENT_ID <> li_attach;
 
end loop;
close c_attachment;
end;
/
