CREATE TABLE WAREHOUSE_PERSON 
(	"PERSON_ID" VARCHAR2(9 BYTE) NOT NULL ENABLE, 
"SSN" VARCHAR2(9 BYTE), 
"LAST_NAME" VARCHAR2(30 BYTE), 
"FIRST_NAME" VARCHAR2(30 BYTE), 
"MIDDLE_NAME" VARCHAR2(30 BYTE), 
"FULL_NAME" VARCHAR2(90 BYTE), 
"PRIOR_NAME" VARCHAR2(30 BYTE), 
"USER_NAME" VARCHAR2(60 BYTE), 
"EMAIL_ADDRESS" VARCHAR2(60 BYTE), 
"DATE_OF_BIRTH" DATE, 
"AGE" NUMBER(3,0), 
"AGE_BY_FISCAL_YEAR" NUMBER(3,0), 
"GENDER" VARCHAR2(30 BYTE), 
"RACE" VARCHAR2(30 BYTE), 
"EDUCATION_LEVEL" VARCHAR2(30 BYTE), 
"DEGREE" VARCHAR2(11 BYTE), 
"MAJOR" VARCHAR2(30 BYTE), 
"IS_HANDICAPPED" CHAR(1 BYTE), 
"HANDICAP_TYPE" VARCHAR2(30 BYTE), 
"IS_VETERAN" CHAR(1 BYTE), 
"VETERAN_TYPE" VARCHAR2(30 BYTE), 
"VISA_CODE" VARCHAR2(20 BYTE), 
"VISA_TYPE" VARCHAR2(30 BYTE), 
"VISA_RENEWAL_DATE" DATE, 
"HAS_VISA" CHAR(1 BYTE), 
"OFFICE_LOCATION" VARCHAR2(30 BYTE), 
"OFFICE_PHONE" VARCHAR2(20 BYTE), 
"SECONDRY_OFFICE_LOCATION" VARCHAR2(30 BYTE), 
"SECONDRY_OFFICE_PHONE" VARCHAR2(20 BYTE), 
"SCHOOL" VARCHAR2(50 BYTE), 
"YEAR_GRADUATED" VARCHAR2(30 BYTE), 
"DIRECTORY_DEPARTMENT" VARCHAR2(30 BYTE), 
"SALUTATION" VARCHAR2(30 BYTE), 
"COUNTRY_OF_CITIZENSHIP" VARCHAR2(30 BYTE), 
"PRIMARY_TITLE" VARCHAR2(51 BYTE), 
"DIRECTORY_TITLE" VARCHAR2(50 BYTE), 
"HOME_UNIT" VARCHAR2(8 BYTE), 
"IS_FACULTY" CHAR(1 BYTE), 
"IS_GRADUATE_STUDENT_STAFF" CHAR(1 BYTE), 
"IS_RESEARCH_STAFF" CHAR(1 BYTE), 
"IS_SERVICE_STAFF" CHAR(1 BYTE), 
"IS_SUPPORT_STAFF" CHAR(1 BYTE), 
"IS_OTHER_ACCADEMIC_GROUP" CHAR(1 BYTE), 
"IS_MEDICAL_STAFF" CHAR(1 BYTE), 
"VACATION_ACCURAL" CHAR(1 BYTE), 
"IS_ON_SABBATICAL" CHAR(1 BYTE), 
"ID_PROVIDED" VARCHAR2(30 BYTE), 
"ID_VERIFIED" VARCHAR2(30 BYTE), 
"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
"UPDATE_USER" VARCHAR2(8 BYTE) NOT NULL ENABLE, 
"RESIDENCY_STATUS_CODE" VARCHAR2(1 BYTE), 
"RESIDENCY_STATUS" VARCHAR2(30 BYTE)
)
/
CREATE TABLE WAREHOUSE_APPOINTMENT
(	"PERSON_ID" VARCHAR2(9 BYTE) NOT NULL ENABLE, 
"UNIT_NUMBER" VARCHAR2(8 BYTE), 
"PRIMARY_SECONDARY_INDICATOR" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
"APPOINTMENT_START_DATE" DATE, 
"APPOINTMENT_END_DATE" DATE, 
"APPOINTMENT_TYPE" VARCHAR2(30 BYTE), 
"JOB_TITLE" VARCHAR2(50 BYTE), 
"PREFERED_JOB_TITLE" VARCHAR2(51 BYTE), 
"JOB_CODE" VARCHAR2(9 BYTE)
)
/
CREATE TABLE WAREHOUSE_DEGREE 
(	"PERSON_ID" VARCHAR2(9 BYTE) NOT NULL ENABLE, 
"DEGREE_CODE" VARCHAR2(6 BYTE) NOT NULL ENABLE, 
"GRADUATION_DATE" DATE NOT NULL ENABLE, 
"DEGREE" VARCHAR2(80 BYTE) NOT NULL ENABLE, 
"FIELD_OF_STUDY" VARCHAR2(80 BYTE), 
"SPECIALIZATION" VARCHAR2(80 BYTE), 
"SCHOOL" VARCHAR2(50 BYTE), 
"SCHOOL_ID" VARCHAR2(20 BYTE)
)
/
CREATE TABLE WAREHOUSE_DEGREE_TYPE_MAPPING 
(	"WAREHOUSE_DEGREE_CODE" VARCHAR2(6 BYTE) NOT NULL ENABLE, 
"GRANTSDOTGOV_DEGREE_CODE" VARCHAR2(6 BYTE) NOT NULL ENABLE
)
/