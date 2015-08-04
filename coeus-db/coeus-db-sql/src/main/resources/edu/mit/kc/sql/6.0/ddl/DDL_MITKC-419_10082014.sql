CREATE SEQUENCE SEQ_AWARD_PERSON_CONFIRM_ID
MINVALUE 1
MAXVALUE 9999999999999999999999999999
INCREMENT BY 1 
START WITH 1   
NOCACHE 
ORDER NOCYCLE
/
CREATE SEQUENCE SEQ_AWARD_PERSON_REMOVE_ID
MINVALUE 1
MAXVALUE 9999999999999999999999999999
INCREMENT BY 1 
START WITH 1   
NOCACHE 
ORDER NOCYCLE
/
/*
UPDATE award_person_confirm t1 SET t1.award_person_id = (
SELECT s1.award_person_id  FROM award_persons s1
WHERE s1.award_id = t1.award_id
AND s1.person_id = t1.person_id
AND s1.contact_role_code = 'KP'
)
WHERE t1.award_person_id is null
/
UPDATE award_person_confirm t1 SET t1.sequence_number  = (
     SELECT s1.SEQUENCE_NUMBER  FROM award s1
      WHERE s1.award_id = t1.award_id     
)
WHERE t1.sequence_number is null
/ 
UPDATE award_person_remove t1 SET t1.award_person_id = (
      SELECT s1.award_person_id  FROM award_persons s1
      WHERE s1.award_id = t1.award_id
      AND s1.person_id = t1.person_id
      AND s1.contact_role_code = 'KP'
      )
WHERE t1.award_person_id is null
/
UPDATE award_person_remove t1 SET t1.sequence_number  = (
     SELECT s1.SEQUENCE_NUMBER  FROM award s1
      WHERE s1.award_id = t1.award_id     
)
WHERE t1.sequence_number is null
/
ALTER TABLE  award_person_remove DROP COLUMN remove_flag
/
ALTER TABLE  award_person_confirm MODIFY AWARD_ID NOT NULL
/
ALTER TABLE  award_person_confirm MODIFY AWARD_NUMBER NOT NULL
/
ALTER TABLE  award_person_confirm MODIFY PERSON_ID NOT NULL
/
ALTER TABLE  award_person_confirm MODIFY SEQUENCE_NUMBER NOT NULL
/
ALTER TABLE  award_person_remove MODIFY AWARD_ID NOT NULL
/
ALTER TABLE  award_person_remove MODIFY AWARD_NUMBER NOT NULL
/
ALTER TABLE  award_person_remove MODIFY PERSON_ID NOT NULL
/
ALTER TABLE  award_person_remove MODIFY SEQUENCE_NUMBER NOT NULL
/
ALTER TABLE  award_person_remove MODIFY UPDATE_TIMESTAMP_CONFIRM  NULL
/*/
/

