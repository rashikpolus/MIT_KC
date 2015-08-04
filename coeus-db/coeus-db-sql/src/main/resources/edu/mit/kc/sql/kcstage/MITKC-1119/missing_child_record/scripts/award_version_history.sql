declare
li_max_sequence_num NUMBER;
li_ver_nbr pls_integer:=1;
ls_version_status  VARCHAR2(16);  
li_commit_count number:=0;
BEGIN

INSERT INTO VERSION_HISTORY(VERSION_HISTORY_ID,SEQ_OWNER_CLASS_NAME,SEQ_OWNER_VERSION_NAME_FIELD,SEQ_OWNER_VERSION_NAME_VALUE,SEQ_OWNER_SEQ_NUMBER,VERSION_STATUS,VERSION_DATE,USER_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
 select  SEQ_VERSION_HISTORY_ID.NEXTVAL,'org.kuali.kra.award.home.Award','awardNumber',awd.award_number,awd.sequence_number,
decode((select max(a.sequence_number) from award a  where a.award_number = awd.award_number),awd.sequence_number,'ACTIVE','ARCHIVED') version_status ,
 awd.update_timestamp,LOWER(awd.update_user),awd.update_timestamp,lower(awd.update_user),1,SYS_GUID()
 from award awd INNER JOIN REFRESH_AWARD t ON awd.AWARD_NUMBER = replace(t.MIT_AWARD_NUMBER,'-','-00') and awd.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER;  

commit;
dbms_output.put_line('Completed VERSION_HISTORY!!!');

exception
when others then
dbms_output.put_line('ERROR IN VERSION_HISTORY,AWARD_NUMBER/SEQUENCE NUMBER:');
END;
/
