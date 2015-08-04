declare
li_doc number(10);
li_proposal_max number(10);
ls_query VARCHAR2(400);
begin
SELECT MAX(PROPOSAL_NUMBER) INTO li_proposal_max FROM PROPOSAL;
ls_query:='alter sequence SEQ_PROPOSAL_NUMBER increment by '||li_proposal_max;      
execute immediate(ls_query);  

SELECT to_number(SUBSTR(MAX(AWARD_NUMBER),1,6)) INTO li_doc  FROM AWARD;    
execute immediate('alter sequence SEQ_AWARD_AWARD_NUMBER increment by '||li_doc);

end;
/
select SEQ_PROPOSAL_NUMBER.NEXTVAL from dual
/
alter sequence SEQ_PROPOSAL_NUMBER increment by 1
/
select SEQ_AWARD_AWARD_NUMBER.NEXTVAL from dual
/
alter sequence SEQ_AWARD_AWARD_NUMBER increment by 1
/