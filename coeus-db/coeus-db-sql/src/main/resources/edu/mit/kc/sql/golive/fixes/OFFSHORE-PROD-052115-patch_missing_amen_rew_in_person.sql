declare
  li_count number;
  li_protocol_id protocol.protocol_id%type;
  cursor c_data is
	select t1.proto_amend_ren_number,t1.protocol_number,t1.sequence_number
	from proto_amend_renewal t1
	left outer join protocol_persons t2 on t2.PROTOCOL_NUMBER = t1.proto_amend_ren_number 
	where t2.PROTOCOL_NUMBER is null;	
   r_data c_data%rowtype;
begin
 open c_data;
 loop
 fetch c_data into r_data;
 exit when c_data%notfound;
 
	begin
		select protocol_id into li_protocol_id from protocol where protocol_number = r_data.proto_amend_ren_number
		and sequence_number = 0;
		
	exception
	when others then
		continue;
	end;
 
 
 --- PROTOCOL_PERSONS
    select count(*) into li_count from protocol_persons
    where protocol_number = r_data.proto_amend_ren_number;    
    if li_count = 0 then 
        begin
            INSERT INTO PROTOCOL_PERSONS(PROTOCOL_PERSON_ID,PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,
            PERSON_ID,PERSON_NAME,PROTOCOL_PERSON_ROLE_ID,ROLODEX_ID,AFFILIATION_TYPE_CODE,UPDATE_TIMESTAMP,
            UPDATE_USER,VER_NBR,OBJ_ID,COMMENTS,SSN,LAST_NAME,FIRST_NAME,MIDDLE_NAME,FULL_NAME,PRIOR_NAME,
            USER_NAME,EMAIL_ADDRESS,DATE_OF_BIRTH,AGE,AGE_BY_FISCAL_YEAR,GENDER,RACE,EDUCATION_LEVEL,DEGREE,
            MAJOR,IS_HANDICAPPED,HANDICAP_TYPE,IS_VETERAN,VETERAN_TYPE,VISA_CODE,VISA_TYPE,VISA_RENEWAL_DATE,
            HAS_VISA,OFFICE_LOCATION,OFFICE_PHONE,SECONDRY_OFFICE_LOCATION,SECONDRY_OFFICE_PHONE,SCHOOL,
            YEAR_GRADUATED,DIRECTORY_DEPARTMENT,SALUTATION,COUNTRY_OF_CITIZENSHIP,PRIMARY_TITLE,DIRECTORY_TITLE,
            HOME_UNIT,IS_FACULTY,IS_GRADUATE_STUDENT_STAFF,IS_RESEARCH_STAFF,IS_SERVICE_STAFF,IS_SUPPORT_STAFF,
            IS_OTHER_ACCADEMIC_GROUP,IS_MEDICAL_STAFF,VACATION_ACCURAL,IS_ON_SABBATICAL,ID_PROVIDED,ID_VERIFIED,
            ADDRESS_LINE_1,ADDRESS_LINE_2,ADDRESS_LINE_3,CITY,COUNTY,STATE,POSTAL_CODE,COUNTRY_CODE,FAX_NUMBER,
            PAGER_NUMBER,MOBILE_PHONE_NUMBER,ERA_COMMONS_USER_NAME)        
            SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,r_data.proto_amend_ren_number,0,PERSON_ID,PERSON_NAME,
            PROTOCOL_PERSON_ROLE_ID,ROLODEX_ID,AFFILIATION_TYPE_CODE,UPDATE_TIMESTAMP,
            UPDATE_USER,1,sys_guid(),COMMENTS,SSN,LAST_NAME,FIRST_NAME,MIDDLE_NAME,FULL_NAME,PRIOR_NAME,
            USER_NAME,EMAIL_ADDRESS,DATE_OF_BIRTH,AGE,AGE_BY_FISCAL_YEAR,GENDER,RACE,EDUCATION_LEVEL,DEGREE,
            MAJOR,IS_HANDICAPPED,HANDICAP_TYPE,IS_VETERAN,VETERAN_TYPE,VISA_CODE,VISA_TYPE,VISA_RENEWAL_DATE,
            HAS_VISA,OFFICE_LOCATION,OFFICE_PHONE,SECONDRY_OFFICE_LOCATION,SECONDRY_OFFICE_PHONE,SCHOOL,
            YEAR_GRADUATED,DIRECTORY_DEPARTMENT,SALUTATION,COUNTRY_OF_CITIZENSHIP,PRIMARY_TITLE,DIRECTORY_TITLE,
            HOME_UNIT,IS_FACULTY,IS_GRADUATE_STUDENT_STAFF,IS_RESEARCH_STAFF,IS_SERVICE_STAFF,IS_SUPPORT_STAFF,
            IS_OTHER_ACCADEMIC_GROUP,IS_MEDICAL_STAFF,VACATION_ACCURAL,IS_ON_SABBATICAL,ID_PROVIDED,ID_VERIFIED,
            ADDRESS_LINE_1,ADDRESS_LINE_2,ADDRESS_LINE_3,CITY,COUNTY,STATE,POSTAL_CODE,COUNTRY_CODE,FAX_NUMBER,
            PAGER_NUMBER,MOBILE_PHONE_NUMBER,ERA_COMMONS_USER_NAME
            FROM PROTOCOL_PERSONS
            WHERE PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER
            AND SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER; 
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_PERSONS ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
    end if;  
    
	select count(*) into li_count from PROTOCOL_UNITS
    where protocol_number = r_data.proto_amend_ren_number;  
  
    if li_count = 0 then 
       begin
        
         INSERT INTO PROTOCOL_UNITS(PROTOCOL_UNITS_ID,PROTOCOL_PERSON_ID,VER_NBR,PROTOCOL_NUMBER,SEQUENCE_NUMBER,
         UNIT_NUMBER,LEAD_UNIT_FLAG,PERSON_ID,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
         SELECT SEQ_PROTOCOL_ID.NEXTVAL,  
         (
           SELECT MAX(PROTOCOL_PERSON_ID) FROM PROTOCOL_PERSONS 
           WHERE PROTOCOL_NUMBER = r_data.proto_amend_ren_number
           AND SEQUENCE_NUMBER = 0 
           AND PROTOCOL_ID = li_protocol_id  
           AND ( PERSON_ID = t1.PERSON_ID OR to_char(ROLODEX_ID)= t1.PERSON_ID) 
           AND (PROTOCOL_PERSON_ROLE_ID ='PI' OR PROTOCOL_PERSON_ROLE_ID='COI')
         ),
         1 ,r_data.proto_amend_ren_number,0, UNIT_NUMBER,
         LEAD_UNIT_FLAG,PERSON_ID,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID()
         FROM PROTOCOL_UNITS t1
         WHERE t1.PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER 
         AND t1.SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_UNITS ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
     end if; 
	
 end loop;
 close c_data;

end;
/