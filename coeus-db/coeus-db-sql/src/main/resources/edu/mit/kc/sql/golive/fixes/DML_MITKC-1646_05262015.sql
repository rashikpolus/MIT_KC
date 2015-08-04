set serveroutput on;
declare
	li_count number;
	li_document_id number;
	ls_subawd_code varchar2(20);
	li_seq number(4,0);
cursor c_subawd is
	select s.subaward_id,s.subaward_code,s.sequence_number
	from subaward s 
	where s.subaward_code in (select s1.subaward_code from SUBAWARD_ATTACHMENTS s1)
	and s.sequence_number <> 1
	order by s.subaward_code,s.sequence_number;
	r_subawd c_subawd%rowtype;

cursor c_attach(as_sub varchar2,as_seq number) is
	select ATTACHMENT_ID,SUBAWARD_ID,SUBAWARD_CODE,SEQUENCE_NUMBER,ATTACHMENT_TYPE_CODE,DOCUMENT_ID,FILE_ID,
	DESCRIPTION,FILE_NAME,DOCUMENT,UPDATE_TIMESTAMP,UPDATE_USER,DOCUMENT_STATUS_CODE
	from SUBAWARD_ATTACHMENTS where SUBAWARD_CODE = as_sub 
	and SEQUENCE_NUMBER = ( select max(a.SEQUENCE_NUMBER) from SUBAWARD_ATTACHMENTS a where  a.SUBAWARD_CODE = as_sub and a.SEQUENCE_NUMBER < as_seq )
	order by SUBAWARD_CODE,SEQUENCE_NUMBER,DOCUMENT_ID;
r_attach c_attach%rowtype;

begin
if c_subawd%isopen then
close c_subawd;
end if;
open c_subawd;
loop
fetch c_subawd into r_subawd;
exit when c_subawd%notfound;

     ls_subawd_code := r_subawd.subaward_code;
	 li_seq := r_subawd.sequence_number;
     
     if c_attach%isopen then
        close c_attach;
     end if;
     open c_attach(ls_subawd_code,li_seq);
     loop
     fetch c_attach into r_attach;
     exit when c_attach%notfound;
	 
	       select count(ATTACHMENT_ID) into li_count from SUBAWARD_ATTACHMENTS 
		   where SUBAWARD_ID = r_subawd.SUBAWARD_ID 
		   and  ATTACHMENT_TYPE_CODE = r_attach.ATTACHMENT_TYPE_CODE 
		   and FILE_ID = r_attach.FILE_ID;
		   
		   if li_count = 0 then		   
		   
			   select (MAX(DOCUMENT_ID) + 1 ) into li_document_id from SUBAWARD_ATTACHMENTS 
			   where SUBAWARD_CODE = r_subawd.subaward_code
			   and SEQUENCE_NUMBER = r_subawd.sequence_number; 
			   
			   if li_document_id is null then
				  li_document_id := 1;
			   end if;
             
       			   begin
		   
		           insert into SUBAWARD_ATTACHMENTS(ATTACHMENT_ID,
                                                    SUBAWARD_ID,
													SUBAWARD_CODE,
													SEQUENCE_NUMBER,
													ATTACHMENT_TYPE_CODE,
													DOCUMENT_ID,
													FILE_ID,
													DESCRIPTION,
													FILE_NAME,
													DOCUMENT,
													UPDATE_TIMESTAMP,
													UPDATE_USER,
													VER_NBR,
													OBJ_ID,
													DOCUMENT_STATUS_CODE)
											 values(SEQ_SUBAWARD_ATTACHMENT_ID.NEXTVAL,
											        r_subawd.SUBAWARD_ID,
												    r_subawd.SUBAWARD_CODE,
													r_subawd.SEQUENCE_NUMBER,
													r_attach.ATTACHMENT_TYPE_CODE,
													li_document_id,
													r_attach.FILE_ID,
													r_attach.DESCRIPTION,
													r_attach.FILE_NAME,
													r_attach.DOCUMENT,
													r_attach.UPDATE_TIMESTAMP,
													r_attach.UPDATE_USER,
													1,
													sys_guid(),
													r_attach.DOCUMENT_STATUS_CODE);
					exception
                    when others then
                     dbms_output.put_line('SUBAWARD_CODE:'||r_subawd.SUBAWARD_CODE||'SEQUENCE_NUMBER:'||r_subawd.SEQUENCE_NUMBER||' , '||sqlerrm);
                    end;				 
													
					commit;											
													
		   end if;
			
	end loop;
    close c_attach;

end loop;
close c_subawd;
end;
/

		   
