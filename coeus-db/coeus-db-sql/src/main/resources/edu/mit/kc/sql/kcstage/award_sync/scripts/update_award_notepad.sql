select ' Started UPDATE_AWARD_NOTEPAD  ' from dual
/
DECLARE

li_award NUMBER(12,0);
ls_award_number CHAR(10 BYTE):=NULL;
ls_awd_number CHAR(10 BYTE);
ll_comments LONG;
ls_note_topic VARCHAR2(300);
ll_comm CLOB;


CURSOR c_notepad  IS
SELECT a.MIT_AWARD_NUMBER,a.ENTRY_NUMBER,a.COMMENTS,a.RESTRICTED_VIEW,a.UPDATE_TIMESTAMP,a.UPDATE_USER FROM OSP$AWARD_NOTEPAD@coeus.kuali a
inner join TEMP_TAB_TO_SYNC_AWARD ts on a.MIT_AWARD_NUMBER=ts.MIT_AWARD_NUMBER
where ts.FEED_TYPE='C';
r_notepad c_notepad%ROWTYPE;

BEGIN
IF c_notepad%ISOPEN THEN
CLOSE c_notepad; 
END IF;
OPEN c_notepad; 
LOOP
FETCH c_notepad  INTO r_notepad;
EXIT WHEN c_notepad%NOTFOUND;


ll_comments:=r_notepad.COMMENTS;

select replace(r_notepad.MIT_AWARD_NUMBER,'-','-00') into ls_awd_number from dual;
SELECT AWARD_ID INTO li_award FROM AWARD WHERE AWARD_NUMBER=ls_awd_number AND SEQUENCE_NUMBER=(SELECT MAX(A.SEQUENCE_NUMBER) FROM AWARD  A WHERE A.AWARD_NUMBER=ls_awd_number ); 

SELECT to_char(ll_comments) INTO ll_comm FROM DUAL;
SELECT (ls_award_number||'-'||SUBSTRB(ll_comments,1,10)) INTO ls_note_topic FROM DUAL;


UPDATE AWARD_NOTEPAD
SET COMMENTS=ll_comm,
RESTRICTED_VIEW=r_notepad.RESTRICTED_VIEW,
UPDATE_TIMESTAMP=r_notepad.UPDATE_TIMESTAMP,
UPDATE_USER=r_notepad.UPDATE_USER,
CREATE_TIMESTAMP=r_notepad.UPDATE_TIMESTAMP,
NOTE_TOPIC=ls_note_topic,
CREATE_USER=r_notepad.UPDATE_USER
WHERE AWARD_NUMBER=r_notepad.MIT_AWARD_NUMBER
AND ENTRY_NUMBER=r_notepad.ENTRY_NUMBER;

END LOOP;
CLOSE c_notepad;
END;
/
select ' Ended UPDATE_AWARD_NOTEPAD ' from dual
/