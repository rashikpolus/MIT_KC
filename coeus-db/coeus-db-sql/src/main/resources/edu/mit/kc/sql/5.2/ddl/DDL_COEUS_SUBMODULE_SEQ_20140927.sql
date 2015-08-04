CREATE SEQUENCE SEQ_COEUS_SUB_MODULE_ID INCREMENT BY 1 START WITH 1 NOCACHE
/
Declare
  difference INTEGER;
  sqlstmt varchar2(255);
  sequencenumber number;
begin
sqlstmt := 'ALTER SEQUENCE SEQ_COEUS_SUB_MODULE_ID INCREMENT BY ';
select max(COEUS_SUB_MODULE_ID) into difference from coeus_sub_module;
  EXECUTE IMMEDIATE sqlstmt || difference;
  select  SEQ_COEUS_SUB_MODULE_ID.NEXTVAL into sequencenumber from dual;
  EXECUTE IMMEDIATE sqlstmt || 1;
end;
/
