set serveroutput on
truncate table PERSON_CUSTOM_DATA
/
declare
li_coeus_count number;
li_kuali_count number;
BEGIN
	select count(1) into li_coeus_count from OSP$PERSON_CUSTOM_DATA@coeus.kuali;
INSERT INTO PERSON_CUSTOM_DATA(PERSON_CUSTOM_DATA_ID,
PERSON_ID,
CUSTOM_ATTRIBUTE_ID,
VALUE,
UPDATE_USER,
UPDATE_TIMESTAMP,
OBJ_ID,
VER_NBR
)
SELECT SEQ_PERSON_CUSTOM_DATA_ID.NEXTVAL,
T1.PERSON_ID,
T2.ID CUSTOM_ATTRIBUTE_ID,
T1.COLUMN_VALUE,
T1.UPDATE_USER,
T1.UPDATE_TIMESTAMP,
SYS_GUID(),
1
FROM OSP$PERSON_CUSTOM_DATA@coeus.kuali T1 INNER JOIN CUSTOM_ATTRIBUTE T2
on upper(trim(T1.COLUMN_NAME)) = upper(trim(T2.NAME));
commit;
	select count(1) into li_kuali_count from person_custom_data;
	dbms_output.put_line('Row count in COEUS '||li_coeus_count);
	dbms_output.put_line('Migrated row count in KUALI '||li_kuali_count);
EXCEPTION
WHEN OTHERS THEN
	dbms_output.put_line('Error happened while inserting into PERSON_CUSTOM_DATA. The error is '||sqlerrm);
	select count(1) into li_kuali_count from person_custom_data;
	dbms_output.put_line('Row count in COEUS '||li_coeus_count);
	dbms_output.put_line('Migrated row count in KUALI '||li_kuali_count);
END;
/