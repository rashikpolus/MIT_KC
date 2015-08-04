declare
li_count number;
begin
select count(*) into li_count from user_tables where table_name = 'OSP$PROPOSAL_ATTACHMENTS';
if li_count = 0 then
execute immediate('create table osp$proposal_attachments as select * from osp$proposal_attachments@coeus.kuali');
end if;
end;
/
ALTER TABLE proposal_attachments DROP CONSTRAINT UK_PROPOSAL_ATTACHMENTS
/
delete from proposal_attachments where (proposal_number,attachment_number) in ( select proposal_number , attachment_number from osp$proposal_attachments)
/
commit
/
delete from proposal_attachments_data where ( proposal_id,attachment_number) in ( select proposal_number , attachment_number from osp$proposal_attachments)
/
commit
/
declare
ls_proposal_number  osp$proposal_attachments.proposal_number%type;
li_sequence_number  osp$proposal_attachments.sequence_number%type;
li_proposal_id      proposal.proposal_id%type;
li_prp_att_data_id  proposal_attachments_data.proposal_attachments_data_id%type;
li_loop_count number;

cursor c_prop is
select proposal_number,proposal_id,sequence_number 
from proposal where proposal_number in (select distinct proposal_number from osp$proposal_attachments);
r_prop c_prop%rowtype;

cursor c_prop_att is
select proposal_number,attachment_number,sequence_number,attachment_title,attachment_type_code,document,
file_name,mime_type,contact_name,phone_number,email_address,comments,update_user,update_timestamp,
doc_update_user,doc_update_timestamp,document_status_code from osp$proposal_attachments
where proposal_number = ls_proposal_number
and  sequence_number <= li_sequence_number
order by attachment_number;
r_prop_att c_prop_att%rowtype;

begin
 open c_prop;
 loop
 fetch c_prop into r_prop;
 exit when c_prop%notfound;
 
 ls_proposal_number := r_prop.proposal_number;
 li_sequence_number := r_prop.sequence_number;
 li_proposal_id     := r_prop.proposal_id; 
 li_loop_count := 0;
 
   open c_prop_att;
   loop
   fetch c_prop_att into r_prop_att;
   exit when c_prop_att%notfound;
    
    begin
    
    li_prp_att_data_id :=  SEQ_PROPOSAL_ATTACHMNT_DATA_ID.NEXTVAL;
    
    INSERT INTO PROPOSAL_ATTACHMENTS_DATA(
    PROPOSAL_ATTACHMENTS_DATA_ID,
    DOCUMENT,
    FILE_NAME,
    CONTENT_TYPE,
    VER_NBR,
    OBJ_ID,
    UPDATE_USER,
    UPDATE_TIMESTAMP,
	PROPOSAL_ID,
    PROPOSAL_NUMBER,    
    SEQUENCE_NUMBER,
    ATTACHMENT_NUMBER
    )
    VALUES(
    li_prp_att_data_id,
    r_prop_att.document,
    r_prop_att.file_name, 
    r_prop_att.mime_type, 
    1,
    sys_guid(),
    r_prop_att.update_user,
    r_prop_att.update_timestamp,
    li_proposal_id,
    ls_proposal_number,
    li_sequence_number,
    r_prop_att.attachment_number
    );
    
    INSERT INTO PROPOSAL_ATTACHMENTS(
    PROPOSAL_ATTACHMENTS_ID,
    PROPOSAL_ID,
    PROPOSAL_NUMBER,
    SEQUENCE_NUMBER,
    ATTACHMENT_NUMBER,
    ATTACHMENT_TITLE,
    ATTACHMENT_TYPE_CODE,
    FILE_NAME,
    CONTENT_TYPE,
    CONTACT_NAME,
    PHONE_NUMBER,
    EMAIL_ADDRESS,
    COMMENTS,
    VER_NBR,
    OBJ_ID,
    UPDATE_USER,
    UPDATE_TIMESTAMP,
    DOC_UPDATE_USER,
    DOC_UPDATE_TIMESTAMP,
    DOCUMENT_STATUS_CODE,
    PROPOSAL_ATTACHMENTS_DATA_ID    
    )
    VALUES(
    SEQ_PROPOSAL_ATTACHMENT_ID.NEXTVAL,
    li_proposal_id,
    ls_proposal_number,
    li_sequence_number,
    r_prop_att.attachment_number,
    r_prop_att.attachment_title,
    r_prop_att.attachment_type_code,
    r_prop_att.file_name,
    r_prop_att.mime_type,
    r_prop_att.contact_name,
    r_prop_att.phone_number,
    r_prop_att.email_address,
    r_prop_att.comments,
    1,
    sys_guid(),
    r_prop_att.update_user,
    r_prop_att.update_timestamp,
    r_prop_att.doc_update_user,
    r_prop_att.doc_update_timestamp,
    trim(r_prop_att.document_status_code),
    li_prp_att_data_id  
    );
    li_loop_count := li_loop_count + 1;
    if li_loop_count = 1000 then
    commit;
    li_loop_count := 0;
    end if;
    
    exception
    when others then
    dbms_output.put_line('Error while inserting to proposal_attachmensts. proposal_number =  '||ls_proposal_number
    ||', attachment_number = '||r_prop_att.attachment_number||'. Error is '||sqlerrm);
    end;
    
    
   end loop;
   close c_prop_att;
 
 end loop;
 close c_prop;
 

end;
/
commit
/
