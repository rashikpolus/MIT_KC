alter table subaward_attachment_type add ATTACHMENT_TYPE_CODE_NEW VARCHAR2(3)
/
update subaward_attachment_type set ATTACHMENT_TYPE_CODE_NEW = ATTACHMENT_TYPE_CODE
/
alter table subaward_attachment_type drop column ATTACHMENT_TYPE_CODE
/
alter table subaward_attachment_type rename column ATTACHMENT_TYPE_CODE_NEW to ATTACHMENT_TYPE_CODE
/
alter table subaward_attachment_type modify ATTACHMENT_TYPE_CODE NOT NULL
/
