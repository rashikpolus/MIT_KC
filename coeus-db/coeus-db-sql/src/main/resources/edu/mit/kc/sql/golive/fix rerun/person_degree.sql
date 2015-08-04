truncate table PERSON_DEGREE
/
declare
li_coeus_count number;
li_kuali_count number;
BEGIN
	select count(1) into li_coeus_count from OSP$PERSON_DEGREE@coeus.kuali;
	INSERT INTO PERSON_DEGREE(DEGREE_ID,
	PERSON_ID,
	GRADUATION_YEAR,
	DEGREE_CODE,
	DEGREE,
	FIELD_OF_STUDY,
	SPECIALIZATION,
	SCHOOL,
	SCHOOL_ID_CODE,
	SCHOOL_ID,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID)
	SELECT SEQ_PERSON_DEGREE.NEXTVAL,
	PERSON_ID,
	to_char(GRADUATION_DATE,'YYYY') GRADUATION_YEAR,
	DEGREE_CODE,
	DEGREE,
	FIELD_OF_STUDY,
	SPECIALIZATION,
	SCHOOL,
	SCHOOL_ID_CODE,
	SCHOOL_ID,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	1,
	SYS_GUID()
	FROM OSP$PERSON_DEGREE@coeus.kuali;
	commit;
	select count(1) into li_kuali_count from PERSON_DEGREE;
	dbms_output.put_line('Row count in COEUS '||li_coeus_count);
	dbms_output.put_line('Migrated row count in KUALI '||li_kuali_count);
EXCEPTION
WHEN OTHERS THEN
	dbms_output.put_line('Error happened while inserting into PERSON_DEGREE. The error is '||sqlerrm);
	select count(1) into li_kuali_count from PERSON_DEGREE;
	dbms_output.put_line('Row count in COEUS '||li_coeus_count);
	dbms_output.put_line('Migrated row count in KUALI '||li_kuali_count);
END;
/