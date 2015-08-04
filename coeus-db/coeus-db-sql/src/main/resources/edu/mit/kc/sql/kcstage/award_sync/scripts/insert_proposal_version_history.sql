select ' Started insert_proposal_version_history ' from dual
/
declare
li_max_sequence_num NUMBER;
li_ver_nbr pls_integer:=1;
ls_version_status  VARCHAR2(16);  
cursor c_prop is
select proposal_number,sequence_number,status_code,update_timestamp,update_user  from proposal order by proposal_number,sequence_number;
r_prop c_prop%ROWTYPE;
BEGIN     
INSERT INTO VERSION_HISTORY(VERSION_HISTORY_ID,SEQ_OWNER_CLASS_NAME,SEQ_OWNER_VERSION_NAME_FIELD,SEQ_OWNER_VERSION_NAME_VALUE,SEQ_OWNER_SEQ_NUMBER,VERSION_STATUS,VERSION_DATE,USER_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
select SEQ_VERSION_HISTORY_ID.NEXTVAL,'org.kuali.kra.institutionalproposal.home.InstitutionalProposal','proposalNumber',r_prop.proposal_number,r_prop.SEQUENCE_NUMBER,
decode((select max(a.sequence_number) from proposal a  where a.proposal_number = r_prop.proposal_number),r_prop.sequence_number,decode(r_prop.STATUS_CODE,3,'PENDING','ACTIVE'),'ARCHIVED') version_status,
r_prop.UPDATE_TIMESTAMP,lower(r_prop.UPDATE_USER),r_prop.UPDATE_TIMESTAMP,lower(r_prop.UPDATE_USER),1,SYS_GUID()
from proposal  r_prop INNER JOIN TEMP_TAB_TO_SYNC_IP t ON r_prop.PROPOSAL_NUMBER =t.PROPOSAL_NUMBER and r_prop.SEQUENCE_NUMBER=t.SEQUENCE_NUMBER  
where t.FEED_TYPE='N';

dbms_output.put_line('Completed VERSION_HISTORY !!!');

exception
when others then
dbms_output.put_line('ERROR IN VERSION_HISTORY,PROPOSAL_NUMBER/SEQUENCE NUMBER:'||sqlerrm);    
END;
/   
select ' Ended insert_proposal_version_history ' from dual
/