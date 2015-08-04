/*
CREATE TABLE NOVI_LONG_SURVEY_RESP 
   (	QUESTION_DESC VARCHAR2(2000 BYTE), 
	ANSWER VARCHAR2(2000 BYTE), 
	QUESTIONINDEX NUMBER(5,0), 
	SURVEYRESPONSEID NUMBER(5,0), 
	PAGEINDEX NUMBER(5,0)
   );
delete from   NOVI_LONG_SURVEY_RESP where  QUESTIONINDEX = 1; 
Insert into NOVI_LONG_SURVEY_RESP (QUESTIONINDEX,SURVEYRESPONSEID,PAGEINDEX,QUESTION_DESC,ANSWER)
values (1,1,1,'Who has won the fifa world cup 2014','Germany');
*/
set serveroutput on;
DECLARE
li_ver_nbr NUMBER(8):=1;
ls_document_number VARCHAR2(40);
li_negotiation NUMBER(22,0);
ls_ass_doc_id proposal_log.PROPOSAL_NUMBER%type;
 ls_person_id NEGOTIATION.NEGOTIATOR_PERSON_ID%type;
 ls_full_nm   NEGOTIATION.NEGOTIATOR_FULL_NAME%type;
 
begin

  select PROPOSAL_NUMBER , PI_ID , PI_NAME  into ls_ass_doc_id  ,ls_person_id,ls_full_nm
  from proposal_log
  where PROPOSAL_NUMBER not in (select ASSOCIATED_DOCUMENT_ID  from NEGOTIATION) 
  and ROLODEX_ID is null
  and rownum = 1;  

SELECT NEGOTIATION_S.NEXTVAL INTO li_negotiation  FROM DUAL;
SELECT KREW_DOC_HDR_S.NEXTVAL INTO ls_document_number FROM DUAL;
  INSERT INTO NEGOTIATION(
  NEGOTIATION_ID,
  DOCUMENT_NUMBER,
  NEGOTATION_STATUS_ID,
  NEGOTIATION_AGREEMENT_TYPE_ID,
  NEGOTIATION_ASSC_TYPE_ID,
  NEGOTIATOR_PERSON_ID,
  NEGOTIATOR_FULL_NAME,
  UPDATE_TIMESTAMP,
  UPDATE_USER,
  VER_NBR,
  OBJ_ID,
  ASSOCIATED_DOCUMENT_ID
  )
 values ( 
  li_negotiation,
  ls_document_number,
  9,
  1,
  4, 
  ls_person_id,
  ls_full_nm,
  sysdate,
  'jenlu',
  1,
  sys_guid(),
 ls_ass_doc_id
 ); 
dbms_output.put_line('Inserted a new NEGOTIATION_ID '||li_negotiation);
dbms_output.put_line('Inserted a new ASSOCIATED_DOCUMENT_ID '||ls_ass_doc_id);

update NEGOTIATION set NEGOTATION_STATUS_ID = 4, update_user='jenlu' where NEGOTIATION_ID = li_negotiation;
dbms_output.put_line(' NEGOTIATION updated.. First notification generated ');
commit;
update LONG_SURVEY_NOTIF  set UPDATE_TIMESTAMP = sysdate, survey_id = 1 , NEGOTIATION_ID = li_negotiation
where NEGOTIATION_ID = li_negotiation;
dbms_output.put_line(' LONG_SURVEY_NOTIF updated.. Second notification generated ');
end;
/
/*
drop table LONG_SURVEY_NOTIF;
drop table LONG_SURVEY_OPT_OUT;
drop sequence SEQ_LONG_SURVEY_NOTIF_ID;
delete from KRIM_PERM_T where NM = 'GENERATE_NEGOT_SURVEY_NOTIF';
delete from NOTIFICATION_TYPE where MODULE_CODE = 5 and ACTION_CODE = '500';
delete from NOTIFICATION_TYPE where MODULE_CODE = 5 and ACTION_CODE = '501';
*/