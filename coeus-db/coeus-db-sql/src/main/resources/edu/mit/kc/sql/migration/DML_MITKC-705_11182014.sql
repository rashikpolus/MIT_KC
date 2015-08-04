declare
li_doc number(10);
li_num number;
begin
select max(TRANSACTION_ID) into li_doc from AWARD_AMOUNT_INFO;
SELECT SEQ_TRANSACTION_ID.NEXTVAL into li_num  FROM DUAL;
li_doc:=li_doc - li_num;
execute immediate('alter sequence SEQ_TRANSACTION_ID increment by '||li_doc);

end;
/
select SEQ_TRANSACTION_ID.NEXTVAL from dual
/
alter sequence SEQ_TRANSACTION_ID increment by 1
/