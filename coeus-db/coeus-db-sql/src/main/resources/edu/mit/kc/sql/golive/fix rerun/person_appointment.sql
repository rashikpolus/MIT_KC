truncate table PERSON_APPOINTMENT
/
declare
li_coeus_count number;
li_kuali_count number;
BEGIN
	select count(1) into li_coeus_count from OSP$APPOINTMENTS@coeus.kuali;
	INSERT INTO PERSON_APPOINTMENT(APPOINTMENT_ID,
	PERSON_ID,
	UNIT_NUMBER,
	APPOINTMENT_START_DATE,
	APPOINTMENT_END_DATE,
	APPOINTMENT_TYPE_CODE,
	JOB_TITLE,
	PREFERED_JOB_TITLE,
	JOB_CODE,
	SALARY,
	UPDATE_TIMESTAMP,
	UPDATE_USER,
	VER_NBR,
	OBJ_ID)
	SELECT SEQ_PERSON_APPOINTMENT.NEXTVAL,
	T1.PERSON_ID,
	T1.UNIT_NUMBER,
	T1.APPOINTMENT_START_DATE,
	T1.APPOINTMENT_END_DATE,
	nvl(T2.appointment_type_code,6),--12M EMPLOYEE
	T1.JOB_TITLE,
	T1.PREFERED_JOB_TITLE,
	T1.JOB_CODE,
	T1.SALARY,
	T1.UPDATE_TIMESTAMP,
	T1.UPDATE_USER,
	1,
	SYS_GUID()
	FROM OSP$APPOINTMENTS@coeus.kuali T1 LEFT OUTER join appointment_type T2
	on upper(trim(T1.APPOINTMENT_TYPE)) = upper(trim(T2.description));

	commit;
	select count(1) into li_kuali_count from PERSON_APPOINTMENT;
	dbms_output.put_line('Row count in COEUS '||li_coeus_count);
	dbms_output.put_line('Migrated row count in KUALI '||li_kuali_count);
EXCEPTION
WHEN OTHERS THEN
	dbms_output.put_line('Error happened while inserting into PERSON_APPOINTMENT. The error is '||sqlerrm);
	select count(1) into li_kuali_count from PERSON_APPOINTMENT;
	dbms_output.put_line('Row count in COEUS '||li_coeus_count);
	dbms_output.put_line('Migrated row count in KUALI '||li_kuali_count);
END;
/