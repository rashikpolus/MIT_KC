declare
li_seq NUMBER(4,0);
ls_content_type	VARCHAR2(255);
cursor c_data is
select t1.SUBAWARD_ID,t1.FILE_ID,t1.FILE_NAME,t1.DOCUMENT,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER from SUBAWARD_ATTACHMENTS t1 
left outer join attachment_file t2 on t1.file_id = t2.file_id
where t2.file_id is null;
r_data c_data%rowtype;

begin

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;
				
		SELECT SEQUENCE_NUMBER INTO li_seq FROM SUBAWARD WHERE SUBAWARD_ID = r_data.SUBAWARD_ID;
		 
		ls_content_type := r_data.FILE_NAME;
		select REVERSE(substr( REVERSE(ls_content_type),1,(instr( REVERSE(ls_content_type),'.',1)-1))) into ls_content_type from dual;
		if    ls_content_type='xls' or  ls_content_type='xlsx' then
		ls_content_type:='application/excel';
		elsif ls_content_type='doc' or  ls_content_type='docx' then
		ls_content_type:='application/msword';  
		elsif ls_content_type='ppt' or  ls_content_type='pptx' then
		ls_content_type:='application/powerpoint';        
		elsif ls_content_type='html'  then
		ls_content_type:='text/html'; 
		elsif ls_content_type='pdf'  then
		ls_content_type:='application/pdf';       
		elsif ls_content_type='jpg' or ls_content_type='jpeg'  then
		ls_content_type:='image/jpeg';           
		else      
		ls_content_type:='other'; 
		end if;

		INSERT INTO ATTACHMENT_FILE(FILE_ID,SEQUENCE_NUMBER,FILE_NAME,CONTENT_TYPE,FILE_DATA,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
		VALUES(r_data.FILE_ID,li_seq,r_data.FILE_NAME,ls_content_type,r_data.DOCUMENT,1,r_data.UPDATE_TIMESTAMP,r_data.UPDATE_USER,SYS_GUID());
	

end loop;
close c_data;

end;
/
commit
/
