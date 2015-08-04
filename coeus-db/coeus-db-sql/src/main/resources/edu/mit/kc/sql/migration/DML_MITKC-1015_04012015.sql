DECLARE
cursor c_data IS
	select t1.award_id, t1.award_number,t1.sequence_number from  award t1
	inner join 
	(
	select award_number,max(sequence_number) sequence_number 
	from  award_person_confirm group by award_number
	) t2
	on t1.award_number = t2.award_number and t1.sequence_number > t2.sequence_number
	where t1.award_number in (select distinct award_number from award_person_confirm)
	order by t1.award_number,t1.sequence_number;
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