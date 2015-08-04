select ' Started AWARD_NOTEPAD ' from dual
/
DECLARE
li_ver_nbr NUMBER(8):=1;
ls_awd_number VARCHAR2(12);
li_award_notepad NUMBER(22);
ls_award_number VARCHAR2(300);
li_entry_number NUMBER(22);
ll_comments LONG;
ls_restricted_view VARCHAR2(300);
ll_update_time DATE;
ls_update_user VARCHAR2(300);
ls_note_topic VARCHAR2(300);
ll_comm CLOB;
li_award_id NUMBER(22);
li_count number;
li_seq number(4);
li_sequence number(4);
li_sequenc number(4);
CURSOR c_notepad  IS
SELECT a.MIT_AWARD_NUMBER,ts.sequence_number,a.ENTRY_NUMBER,a.COMMENTS,a.RESTRICTED_VIEW,a.UPDATE_TIMESTAMP,a.UPDATE_USER FROM OSP$AWARD_NOTEPAD@coeus.kuali a
inner join REFRESH_AWARD ts on a.MIT_AWARD_NUMBER=ts.MIT_AWARD_NUMBER
and ts.sequence_number=(select max(t1.sequence_number) from REFRESH_AWARD t1 where t1.MIT_AWARD_NUMBER=ts.MIT_AWARD_NUMBER);
r_notepad c_notepad%ROWTYPE;

BEGIN
IF c_notepad%ISOPEN THEN
CLOSE c_notepad; 
END IF;
OPEN c_notepad; 
LOOP
FETCH c_notepad  INTO r_notepad;
EXIT WHEN c_notepad%NOTFOUND;
ls_award_number:=r_notepad.MIT_AWARD_NUMBER;
li_entry_number:=r_notepad.ENTRY_NUMBER;
ll_comments:=r_notepad.COMMENTS;
ls_restricted_view:=r_notepad.RESTRICTED_VIEW;
ll_update_time:=r_notepad.UPDATE_TIMESTAMP;
ls_update_user:=r_notepad.UPDATE_USER;
li_sequenc:=r_notepad.sequence_number;
select replace(ls_award_number,'-','-00') into ls_awd_number from dual;
select max(SEQUENCE_NUMBER) into li_sequence FROM AWARD WHERE AWARD_NUMBER=ls_awd_number;
IF li_sequence=li_sequenc THEN
SELECT count(AWARD_ID) INTO li_count FROM AWARD WHERE AWARD_NUMBER=ls_awd_number AND SEQUENCE_NUMBER=(SELECT MAX(A.SEQUENCE_NUMBER) FROM AWARD  A WHERE A.AWARD_NUMBER=ls_awd_number );
IF  li_count =1 THEN      
		SELECT SEQ_AWARD_NOTEPAD_ID.NEXTVAL INTO li_award_notepad FROM DUAL;

			begin
			SELECT AWARD_ID INTO li_award_id FROM AWARD WHERE AWARD_NUMBER=ls_awd_number AND SEQUENCE_NUMBER=(SELECT MAX(A.SEQUENCE_NUMBER) FROM AWARD  A WHERE A.AWARD_NUMBER=ls_awd_number ); 
			exception
			when others then
			dbms_output.put_line('Error in AWARD_NUMBER:'||ls_awd_number||'and the error is:'||substr(sqlerrm,1,100));
			end;

		SELECT to_char(ll_comments) INTO ll_comm FROM DUAL;
		SELECT (ls_award_number||'-'||SUBSTRB(ll_comments,1,10)) INTO ls_note_topic FROM DUAL;

			begin
			INSERT INTO AWARD_NOTEPAD(AWARD_NOTEPAD_ID,AWARD_NUMBER,ENTRY_NUMBER,COMMENTS,RESTRICTED_VIEW,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,CREATE_TIMESTAMP,NOTE_TOPIC,AWARD_ID,OBJ_ID,CREATE_USER)
			VALUES(li_award_notepad,ls_awd_number,li_entry_number,ll_comm,ls_restricted_view,ll_update_time,ls_update_user,li_ver_nbr,ll_update_time,ls_note_topic,li_award_id,SYS_GUID(),ls_update_user);
			exception
			when others then 
			dbms_output.put_line('ERROR IN AWARD_NOTEPAD,AWARD_NUMBER:'||sqlerrm);
			end;
	
ELSE
		SELECT MAX(A.SEQUENCE_NUMBER) into li_seq FROM AWARD A WHERE A.AWARD_NUMBER=ls_awd_number; 
		dbms_output.put_line('AWARD_ID NOT IN AWARD TABLE FOR AWARD_NUMBER:'||ls_awd_number||' AND SEQUENCE_NUMBER:'||li_seq);
		
END IF;
END IF;
END LOOP;
CLOSE c_notepad; 
dbms_output.put_line('Completed AWARD_NOTEPAD!!!');
END;
/
select ' Ended AWARD_NOTEPAD ' from dual
/