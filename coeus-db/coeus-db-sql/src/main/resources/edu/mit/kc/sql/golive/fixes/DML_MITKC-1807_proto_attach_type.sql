set serveroutput on
/
alter table PROTOCOL_ATTACHMENT_PERSONNEL disable constraint FK_PA_PERSONNEL_TYPE
/
alter table PROTOCOL_ATTACHMENT_PROTOCOL disable constraint FK_PROTOCOL_ATTACHMENT_TYPE
/
CREATE TABLE PROTOCOL_ATTACHMENT_PERS_BAK AS ( SELECT * FROM PROTOCOL_ATTACHMENT_PERSONNEL )
/
CREATE TABLE PROTOCOL_ATTACHMENT_PROT_BAK AS ( SELECT * FROM PROTOCOL_ATTACHMENT_PROTOCOL )
/
declare
	li_count NUMBER;
begin
	select count(TYPE_CD) into li_count from PROTOCOL_ATTACHMENT_TYPE where TYPE_CD = '18' and DESCRIPTION = 'AE Report';
	if li_count = 0 then
	  INSERT INTO PROTOCOL_ATTACHMENT_TYPE(TYPE_CD,DESCRIPTION,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
	  VALUES('18','AE Report',1,sysdate,'admin',sys_guid());
	end if;
end;
/
declare
ls_type_code VARCHAR2(3);
li_count number;
cursor c_proto_attach_type is
select distinct pa.PA_PERSONNEL_ID,pa.PROTOCOL_ID_FK,pa.PROTOCOL_NUMBER,pa.SEQUENCE_NUMBER,pa.TYPE_CD from PROTOCOL_ATTACHMENT_PERSONNEL pa 
inner join TEMP_SEQ_LOG t on t.MODULE_ITEM_KEY = pa.PROTOCOL_NUMBER
where pa.TYPE_CD in('9','10','11','12','13','14','15','16','17')
and t.MODULE='IRB'
order by pa.PROTOCOL_NUMBER,pa.SEQUENCE_NUMBER,pa.TYPE_CD;
r_proto_attach_type c_proto_attach_type%rowtype;

begin
			if c_proto_attach_type%isopen then
			close c_proto_attach_type;
			end if;
			open c_proto_attach_type;
			loop
			fetch c_proto_attach_type into r_proto_attach_type;
			exit when c_proto_attach_type%notfound;

				  if r_proto_attach_type.TYPE_CD = '9' then
					  ls_type_code := '120';
				  elsif r_proto_attach_type.TYPE_CD = '10' then
						ls_type_code := '130';
				  elsif r_proto_attach_type.TYPE_CD = '11' then
						ls_type_code := '140';
				  elsif r_proto_attach_type.TYPE_CD = '12'then
						ls_type_code := '150';
				  elsif r_proto_attach_type.TYPE_CD = '13' then
						ls_type_code := '160';
				  elsif r_proto_attach_type.TYPE_CD = '14' then
						ls_type_code := '170';
				  elsif r_proto_attach_type.TYPE_CD = '15' then
						ls_type_code := '180';		
				  elsif r_proto_attach_type.TYPE_CD = '16' or r_proto_attach_type.TYPE_CD ='17' then
						ls_type_code := '90';
				  end if;
				 
				begin 
				  update PROTOCOL_ATTACHMENT_PERSONNEL
				  set TYPE_CD = ls_type_code
				  where TYPE_CD = r_proto_attach_type.TYPE_CD
				  and PROTOCOL_NUMBER = r_proto_attach_type.PROTOCOL_NUMBER
				  and SEQUENCE_NUMBER = r_proto_attach_type.SEQUENCE_NUMBER
				  and PROTOCOL_ID_FK = r_proto_attach_type.PROTOCOL_ID_FK
				  and PA_PERSONNEL_ID = r_proto_attach_type.PA_PERSONNEL_ID;
				  
				exception
				when others then
				dbms_output.put_line('Error PROTOCOL_ATTACHMENT_PERSONNEL (PROTOCOL_ID_FK,PA_PERSONNEL_ID) is '||r_proto_attach_type.PROTOCOL_ID_FK||' , '
					||r_proto_attach_type.PA_PERSONNEL_ID||sqlerrm);
				end;	 
				 
			end loop;
			close c_proto_attach_type;
		
end;
/
declare
li_count number;
ls_type_code VARCHAR2(3);
cursor c_proto_attach_type is
select distinct pa.PA_PROTOCOL_ID,pa.PROTOCOL_ID_FK,pa.PROTOCOL_NUMBER,pa.SEQUENCE_NUMBER,pa.TYPE_CD from PROTOCOL_ATTACHMENT_PROTOCOL pa 
inner join TEMP_SEQ_LOG t on t.MODULE_ITEM_KEY = pa.PROTOCOL_NUMBER
where pa.TYPE_CD in('9','10','11','12','13','14','15','16','17')
and t.MODULE='IRB'
order by pa.PROTOCOL_NUMBER,pa.SEQUENCE_NUMBER,pa.TYPE_CD;
r_proto_attach_type c_proto_attach_type%rowtype;

begin

				if c_proto_attach_type%isopen then
				close c_proto_attach_type;
				end if;
				open c_proto_attach_type;
				loop
				fetch c_proto_attach_type into r_proto_attach_type;
				exit when c_proto_attach_type%notfound;

					  if r_proto_attach_type.TYPE_CD = '9' then
						  ls_type_code := '120';
					  elsif r_proto_attach_type.TYPE_CD = '10' then
							ls_type_code := '130';
					  elsif r_proto_attach_type.TYPE_CD = '11' then
							ls_type_code := '140';
					  elsif r_proto_attach_type.TYPE_CD = '12' then
							ls_type_code := '150';
					  elsif r_proto_attach_type.TYPE_CD = '13' then
							ls_type_code := '160';
					  elsif r_proto_attach_type.TYPE_CD = '14' then
							ls_type_code := '170';
					  elsif r_proto_attach_type.TYPE_CD = '15' then
							ls_type_code := '180';	
					  elsif r_proto_attach_type.TYPE_CD = '16' or r_proto_attach_type.TYPE_CD ='17' then
							ls_type_code := '90';
					  end if;
					
					begin
					  update PROTOCOL_ATTACHMENT_PROTOCOL
					  set TYPE_CD = ls_type_code
					  where TYPE_CD = r_proto_attach_type.TYPE_CD
					  and PROTOCOL_NUMBER = r_proto_attach_type.PROTOCOL_NUMBER
					  and SEQUENCE_NUMBER = r_proto_attach_type.SEQUENCE_NUMBER
					  and PROTOCOL_ID_FK = r_proto_attach_type.PROTOCOL_ID_FK
					  and PA_PROTOCOL_ID = r_proto_attach_type.PA_PROTOCOL_ID;
					  
					exception
					when others then
					dbms_output.put_line('Error PROTOCOL_ATTACHMENT_PROTOCOL (PROTOCOL_ID_FK,PA_PROTOCOL_ID) is '||r_proto_attach_type.PROTOCOL_ID_FK||' , '
						||r_proto_attach_type.PA_PROTOCOL_ID||sqlerrm);
					end;	
					  
				end loop;
				close c_proto_attach_type;
				
end;
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '12'
WHERE TYPE_CD = '120'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '12'
WHERE TYPE_CD = '120'
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '13'
WHERE TYPE_CD = '130'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '13'
WHERE TYPE_CD = '130'
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '14'
WHERE TYPE_CD = '140'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '14'
WHERE TYPE_CD = '140'
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '15'
WHERE TYPE_CD = '150'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '15'
WHERE TYPE_CD = '150'
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '16'
WHERE TYPE_CD = '160'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '16'
WHERE TYPE_CD = '160'
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '17'
WHERE TYPE_CD = '170'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '17'
WHERE TYPE_CD = '170'
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '9'
WHERE TYPE_CD = '90'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '9'
WHERE TYPE_CD = '90'
/
UPDATE PROTOCOL_ATTACHMENT_PERSONNEL
SET TYPE_CD = '18'
WHERE TYPE_CD = '180'
/
UPDATE PROTOCOL_ATTACHMENT_PROTOCOL
SET TYPE_CD = '18'
WHERE TYPE_CD = '180'
/
ALTER TABLE PROTOCOL_ATTACHMENT_PERSONNEL ENABLE CONSTRAINT FK_PA_PERSONNEL_TYPE
/
ALTER TABLE PROTOCOL_ATTACHMENT_PROTOCOL ENABLE CONSTRAINT FK_PROTOCOL_ATTACHMENT_TYPE
/