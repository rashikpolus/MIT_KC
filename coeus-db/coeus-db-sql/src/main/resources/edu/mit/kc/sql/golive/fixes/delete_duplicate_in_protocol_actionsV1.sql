CREATE TABLE PROTOCOL_ACTIONS_BAK_0526 AS SELECT * FROM PROTOCOL_ACTIONS
/
CREATE TABLE TMP_PROTOCOL_ACTIONS_DEL_ID AS
select t1.* from PROTOCOL_ACTIONS t1 inner join
(  
select MIN(PROTOCOL_ACTION_ID) PROTOCOL_ACTION_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,ACTION_ID,PROTOCOL_ID,PROTOCOL_ACTION_TYPE_CODE
from PROTOCOL_ACTIONS
GROUP BY PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,ACTION_ID,PROTOCOL_ID,PROTOCOL_ACTION_TYPE_CODE
HAVING COUNT(PROTOCOL_ACTION_ID)> 1
) t2
on t1.PROTOCOL_NUMBER = t2.PROTOCOL_NUMBER
and t1.SEQUENCE_NUMBER = t2.SEQUENCE_NUMBER
and t1.SUBMISSION_NUMBER = t2.SUBMISSION_NUMBER
and t1.ACTION_ID = t2.ACTION_ID
and t1.PROTOCOL_ID = t2.PROTOCOL_ID
and t1.PROTOCOL_ACTION_TYPE_CODE = t2.PROTOCOL_ACTION_TYPE_CODE
and t1.PROTOCOL_ACTION_ID <> t2.PROTOCOL_ACTION_ID
order by t1.PROTOCOL_NUMBER,t1.SEQUENCE_NUMBER,t1.SUBMISSION_NUMBER,t1.ACTION_ID,t1.PROTOCOL_ID,t1.PROTOCOL_ACTION_TYPE_CODE
/
-- test this query whether we have row in child tables of PROTOCOL_ACTIONS
-- select count(*) from protocol_correspondence where action_id_fk in ( select t1.PROTOCOL_ACTION_ID from TMP_PROTOCOL_ACTIONS_DEL_ID t1 )
-- select count(*) from comm_batch_corresp_detail where PROTOCOL_ACTION_ID in ( select t1.PROTOCOL_ACTION_ID from TMP_PROTOCOL_ACTIONS_DEL_ID t1 )
DELETE FROM PROTOCOL_ACTIONS
WHERE PROTOCOL_ACTION_ID in ( select t1.PROTOCOL_ACTION_ID from TMP_PROTOCOL_ACTIONS_DEL_ID t1 )
/
/*
--test script
select MIN(PROTOCOL_ACTION_ID) PROTOCOL_ACTION_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,ACTION_ID,PROTOCOL_ID,PROTOCOL_ACTION_TYPE_CODE
from PROTOCOL_ACTIONS
GROUP BY PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,ACTION_ID,PROTOCOL_ID,PROTOCOL_ACTION_TYPE_CODE
HAVING COUNT(PROTOCOL_ACTION_ID)> 1
-- restore script

insert into PROTOCOL_ACTIONS(PROTOCOL_ACTION_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,ACTION_ID,PROTOCOL_ACTION_TYPE_CODE,
PROTOCOL_ID,SUBMISSION_ID_FK,COMMENTS,ACTION_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ACTUAL_ACTION_DATE,OBJ_ID,PREV_SUBMISSION_STATUS_CODE,
SUBMISSION_TYPE_CODE,PREV_PROTOCOL_STATUS_CODE,FOLLOWUP_ACTION_CODE,CREATE_USER,CREATE_TIMESTAMP)
SELECT PROTOCOL_ACTION_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,SUBMISSION_NUMBER,ACTION_ID,PROTOCOL_ACTION_TYPE_CODE,
PROTOCOL_ID,SUBMISSION_ID_FK,COMMENTS,ACTION_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,ACTUAL_ACTION_DATE,OBJ_ID,PREV_SUBMISSION_STATUS_CODE,
SUBMISSION_TYPE_CODE,PREV_PROTOCOL_STATUS_CODE,FOLLOWUP_ACTION_CODE,CREATE_USER,CREATE_TIMESTAMP
FROM PROTOCOL_ACTIONS_BAK_0526
WHERE PROTOCOL_ACTION_ID IN (SELECT PROTOCOL_ACTION_ID FROM TMP_PROTOCOL_ACTIONS_DEL_ID)


*/
