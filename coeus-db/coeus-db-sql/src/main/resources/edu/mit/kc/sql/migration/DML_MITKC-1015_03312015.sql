DROP TABLE OSP$AWARD_KEY_PERS_CONFIRM
/
CREATE TABLE OSP$AWARD_KEY_PERS_CONFIRM(
MIT_AWARD_NUMBER VARCHAR2(12), 
SEQUENCE_NUMBER NUMBER(4,0), 
PERSON_ID VARCHAR2(9), 
CONFIRM_FLAG CHAR(1), 
UPDATE_TIMESTAMP DATE , 
UPDATE_USER VARCHAR2(8))
/
INSERT INTO OSP$AWARD_KEY_PERS_CONFIRM(
MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
PERSON_ID,
CONFIRM_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER)
SELECT MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
PERSON_ID,
CONFIRM_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER
FROM OSP$AWARD_KEY_PERS_CONFIRM@coeus.kuali
/
COMMIT
/
INSERT INTO OSP$AWARD_KEY_PERS_CONFIRM
SELECT t0.mit_award_number,
b0.sequence_number,
t0.PERSON_ID,
t0.CONFIRM_FLAG,
t0.update_timestamp,
t0.update_user
from OSP$AWARD_KEY_PERS_CONFIRM@coeus.kuali t0 inner join 
(
select t1.mit_award_number,t1.sequence_number
from osp$award@coeus.kuali t1 left outer join OSP$AWARD_KEY_PERS_CONFIRM@coeus.kuali t2 on t1.mit_award_number = t2.mit_award_number 
and t1.sequence_number = t2.sequence_number
where t2.mit_award_number is null
) b0
on t0.mit_award_number = b0.mit_award_number
and t0.sequence_number = ( select max(s1.sequence_number) from OSP$AWARD_KEY_PERS_CONFIRM@coeus.kuali s1
                           where s1.mit_award_number = b0.mit_award_number 
                           and  s1.sequence_number <= b0.sequence_number)
/
COMMIT
/
UPDATE OSP$AWARD_KEY_PERS_CONFIRM SET MIT_AWARD_NUMBER = replace(MIT_AWARD_NUMBER,'-','-00')
/
COMMIT
/
ALTER TABLE OSP$AWARD_KEY_PERS_CONFIRM ADD CONSTRAINT pAWARD_KEY_PERS_CONFIRM PRIMARY KEY (MIT_AWARD_NUMBER,SEQUENCE_NUMBER,PERSON_ID)
/
--delete from AWARD_PERSON_CONFIRM WHERE AWARD_NUMBER in ( select distinct MIT_AWARD_NUMBER from OSP$AWARD_KEY_PERS_CONFIRM)
--/
commit
/
SET SERVEROUTPUT ON
/
DECLARE
cursor c_data IS
  SELECT award_id,award_number,sequence_number from award
  where award_number in ( select distinct MIT_AWARD_NUMBER from OSP$AWARD_KEY_PERS_CONFIRM);
  r_data c_data%rowtype;
  
BEGIN
  OPEN c_data;
  LOOP
  FETCH c_data INTO r_data;
  EXIT WHEN c_data%notfound;
    BEGIN
      INSERT INTO AWARD_PERSON_CONFIRM(
       AWARD_PERSON_CONFIRM_ID,
        AWARD_PERSON_ID,
        AWARD_ID,
        AWARD_NUMBER,
        SEQUENCE_NUMBER,
        PERSON_ID,
        CONFIRM_FLAG,
        UPDATE_TIMESTAMP,
        UPDATE_USER,
        VER_NBR,
        OBJ_ID)
      SELECT SEQ_AWARD_PERSON_CONFIRM_ID.NEXTVAL,
      t2.AWARD_PERSON_ID,
      r_data.AWARD_ID,
      t1.MIT_AWARD_NUMBER,
      t1.SEQUENCE_NUMBER,
      t1.PERSON_ID,
      t1.CONFIRM_FLAG,
      t1.UPDATE_TIMESTAMP,
      t1.UPDATE_USER,
      1,
      SYS_GUID()
      FROM OSP$AWARD_KEY_PERS_CONFIRM t1
      INNER JOIN AWARD_PERSONS t2 ON t1.MIT_AWARD_NUMBER = t2.AWARD_NUMBER
              AND t1.SEQUENCE_NUMBER = t2.SEQUENCE_NUMBER AND (t1.PERSON_ID = t2.PERSON_ID OR t1.PERSON_ID = t2.ROLODEX_ID )   
      WHERE t1.MIT_AWARD_NUMBER = r_data.award_number
      AND t1.SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;
    
    EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('Error OSP$AWARD_KEY_PERS_CONFIRM, AWARD_ID = '||r_data.AWARD_ID||'. '||sqlerrm);
    END;  
  END LOOP;
  CLOSE c_data;
  
END;
/
COMMIT
/
DROP TABLE OSP$AWARD_KEY_PERS_REMOVED
/
CREATE TABLE OSP$AWARD_KEY_PERS_REMOVED
(	AWARD_KP_REMOVED_NUMBER NUMBER(10,0), 
MIT_AWARD_NUMBER VARCHAR2(12), 
SEQUENCE_NUMBER NUMBER(4,0), 
PERSON_ID VARCHAR2(9), 
CONFIRM_FLAG CHAR(1), 
CONFIRM_TIMESTAMP DATE, 
CONFIRM_USER VARCHAR2(8), 
DELETE_TIMESTAMP DATE, 
DELETE_USER VARCHAR2(8)
)
/
INSERT INTO OSP$AWARD_KEY_PERS_REMOVED(
AWARD_KP_REMOVED_NUMBER,
MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
PERSON_ID,
CONFIRM_FLAG,
CONFIRM_TIMESTAMP,
CONFIRM_USER,
DELETE_TIMESTAMP,
DELETE_USER
)
SELECT AWARD_KP_REMOVED_NUMBER,
MIT_AWARD_NUMBER,
SEQUENCE_NUMBER,
PERSON_ID,
CONFIRM_FLAG,
CONFIRM_TIMESTAMP,
CONFIRM_USER,
DELETE_TIMESTAMP,
DELETE_USER
FROM OSP$AWARD_KEY_PERS_REMOVED@coeus.kuali
/
COMMIT
/
UPDATE OSP$AWARD_KEY_PERS_REMOVED SET MIT_AWARD_NUMBER = replace(MIT_AWARD_NUMBER,'-','-00')
/
COMMIT
/
INSERT INTO AWARD_PERSON_REMOVE(
AWARD_PERSON_REMOVE_ID,
AWARD_PERSON_ID,
AWARD_ID,
AWARD_NUMBER,
PERSON_ID,
CONFIRM_FLAG,
UPDATE_TIMESTAMP,
UPDATE_USER,
VER_NBR,
OBJ_ID,
UPDATE_TIMESTAMP_CONFIRM,
UPDATE_USER_CONFIRM,
SEQUENCE_NUMBER
)
SELECT
SEQ_AWARD_PERSON_REMOVE_ID.NEXTVAL,
t2.AWARD_PERSON_ID,
t3.AWARD_ID,
t3.AWARD_NUMBER,
t1.PERSON_ID,
t1.CONFIRM_FLAG,
t1.DELETE_TIMESTAMP,
t1.DELETE_USER,
1,
sys_guid(),
t1.CONFIRM_TIMESTAMP,
t1.CONFIRM_USER,
t3.SEQUENCE_NUMBER
 FROM OSP$AWARD_KEY_PERS_REMOVED t1
 INNER JOIN AWARD_PERSONS t2 ON t1.MIT_AWARD_NUMBER = t2.AWARD_NUMBER
              AND t1.SEQUENCE_NUMBER = t2.SEQUENCE_NUMBER AND (t1.PERSON_ID = t2.PERSON_ID OR t1.PERSON_ID = t2.ROLODEX_ID )
 INNER JOIN AWARD t3 on t1.MIT_AWARD_NUMBER = t3.AWARD_NUMBER AND t1.SEQUENCE_NUMBER = t3.SEQUENCE_NUMBER 
 /
 commit
 /
 