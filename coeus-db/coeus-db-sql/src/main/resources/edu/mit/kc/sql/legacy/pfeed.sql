set heading off;
set echo off;
--***********************************************************************
--   *********      C H A N G E     L O G  ****************** 
--***********************************************************************
-- 9/26/06 
--  Removed InitCap from varchar2 columns while retrieving data from warehouse.
-- 
--***********************************************************************
--***********************************************************************
--  Switched to view COEUS_PERSON on 11/19/03
--***********************************************************************
-- Change on 5/25/04
-- Changed feed logic to bring user_name in osp$person table from 
-- wareuser.krb_person.krb_name.
-- Inaddition to bringing user_name from krb_person  table, this script
-- will check for all persons in osp$person table which are not in warehouse_person
-- table.  For all these people user_name will be set to NULL.  With this change
-- there will be no duplicate rows in osp$person table for any kerberos ID.
--
--  A backup of osp$person table is saved as osp$person_save_250504 in production
-- database.
--***********************************************************************
--  Changed degree data selection to a new view
--selecting from indifvidual tables in WH side was causing the connections to hang.
--***********************************************************************
--
select 'Person Feed from warehouse at ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS AM') from dual
/
rem
rem
rem  refresh warehouse_person from the current Production
rem  warehouse data
rem
rem
select 'Purging all rows from  warehouse_person ' from dual
/
delete from warehouse_person
/
commit
/
rem
select 'Populating warehouse_person from warehouse ' from dual
/
insert into warehouse_person
( PERSON_ID,                      
 SSN,                            
 LAST_NAME,                      
 FIRST_NAME,                     
 MIDDLE_NAME ,                   
 FULL_NAME,                      
 PRIOR_NAME,                     
 USER_NAME ,                     
 EMAIL_ADDRESS,                  
 DATE_OF_BIRTH ,                 
 AGE,                            
 AGE_BY_FISCAL_YEAR ,            
 GENDER,                         
 RACE,                           
 EDUCATION_LEVEL,                
 DEGREE,                         
 MAJOR,                          
 IS_HANDICAPPED,                 
 HANDICAP_TYPE,                  
 IS_VETERAN,                     
 VETERAN_TYPE,                   
 VISA_CODE,                      
 VISA_TYPE,                      
 VISA_RENEWAL_DATE,              
 HAS_VISA,                       
 OFFICE_LOCATION,                
 OFFICE_PHONE,                   
 SECONDRY_OFFICE_LOCATION,       
 SECONDRY_OFFICE_PHONE,          
 SCHOOL,                         
 YEAR_GRADUATED,                 
 DIRECTORY_DEPARTMENT,           
 SALUTATION,                     
 COUNTRY_OF_CITIZENSHIP,         
 PRIMARY_TITLE,                  
 DIRECTORY_TITLE,                
 HOME_UNIT,                      
 IS_FACULTY,                     
 IS_GRADUATE_STUDENT_STAFF,      
 IS_RESEARCH_STAFF,              
 IS_SERVICE_STAFF,               
 IS_SUPPORT_STAFF,               
 IS_OTHER_ACCADEMIC_GROUP,       
 IS_MEDICAL_STAFF,               
 VACATION_ACCURAL,               
 IS_ON_SABBATICAL,               
 ID_PROVIDED,                    
 ID_VERIFIED,                    
 UPDATE_TIMESTAMP,               
 UPDATE_USER,
 RESIDENCY_STATUS_CODE,
 RESIDENCY_STATUS)                    
select 
 CP.mit_id,                         
 CP.SSN ,                           
 substr(RTRIM(CP.LAST_NAME), 1, 30),                   
 RTRIM(CP.FIRST_NAME),                     
 RTRIM(CP.MIDDLE_NAME),                    
 RTRIM(CP.FULL_NAME),                      
 RTRIM(CP.PRIOR_NAME),
 LOWER(RTRIM(KP.KRB_NAME)),                      
 LOWER(RTRIM(CP.EMAIL_ADDRESS)),                  
 CP.DATE_OF_BIRTH,                  
 CP.AGE,                            
 CP.AGE_BY_FISCAL_YEAR,             
 CP.GENDER,                         
 CP.RACE,                           
 CP.EDUCATION_LEVEL,   
-- DEGREE,                         
null,
 CP.MAJOR,                          
 CP.IS_HANDICAPPED,                 
 CP.HANDICAP_TYPE,                  
 CP.IS_VETRAN ,                     
 CP.VETERAN_TYPE,                   
 CP.VISA_CODE,                      
 CP.VISA_TYPE,                      
 CP.VISA_RENEWAL_DATE,              
 CP.HAS_VISA,                       
 CP.OFFICE_LOCATION,                
 CP.OFFICE_PHONE,                   
 CP.SECONDARY_OFFICE_LOCATION,     
 CP.SECONDARY_OFFICE_PHONE,         
 CP.SCHOOL,                         
 CP.YEAR_GRADUATED,                 
-- INITCAP(DIRECTORY_DEPARTMENT),           
 null,
 CP.SALUTATION,                     
 CP.COUNTRY_OF_CITIZENSHIP,         
 CP.PRIMARY_TITLE,                  
 CP.DIRECTORY_TITLE,                
 CP.DEPARTMENT_NUMBER,              
 CP.IS_FACULTY,                     
 CP.IS_GRADUATE_STUDENT_STAFF,   
 null,   
 CP.IS_SERVICE_STAFF,               
 CP.IS_SUPPORT_STAFF,               
 CP.IS_OTHER_ACADEMIC_GROUP,        
 CP.IS_MEDICAL_STAFF,               
 CP.VACATION_ACCRUAL,               
 CP.IS_ON_SABATICAL,                
 CP.ID_PROVIDED,                    
 CP.ID_VERIFIED,
 SYSDATE,
 USER,
 RESIDENCY_STATUS_CODE,
 RESIDENCY_STATUS
FROM WAREUSER.COEUS_PERSON@WAREHOUSE_COEUS.MIT.EDU cp,
     WAREUSER.KRB_PERSON@WAREHOUSE_COEUS.MIT.EDU kp
 WHERE CP.MIT_ID = KP.MIT_ID (+)            
/
commit
/
select 'Inserting new rows into osp$person ' from dual
/
insert into osp$person
select PERSON_ID,                      
 SSN,                            
 LAST_NAME,                      
 FIRST_NAME,                     
 MIDDLE_NAME ,                   
 FULL_NAME,                      
 PRIOR_NAME,                     
 USER_NAME ,                     
 EMAIL_ADDRESS,                  
 DATE_OF_BIRTH ,                 
 AGE,                            
 AGE_BY_FISCAL_YEAR ,            
 GENDER,                         
 RACE,                           
 EDUCATION_LEVEL,                
 DEGREE,                         
 MAJOR,                          
 IS_HANDICAPPED,                 
 HANDICAP_TYPE,                  
 IS_VETERAN,                     
 VETERAN_TYPE,                   
 VISA_CODE,                      
 VISA_TYPE,                      
 VISA_RENEWAL_DATE,              
 HAS_VISA,                       
 OFFICE_LOCATION,                
 OFFICE_PHONE,                   
 SECONDRY_OFFICE_LOCATION,       
 SECONDRY_OFFICE_PHONE,          
 SCHOOL,                         
 YEAR_GRADUATED,                 
 DIRECTORY_DEPARTMENT,           
 SALUTATION,                     
 COUNTRY_OF_CITIZENSHIP,         
 PRIMARY_TITLE,                  
 DIRECTORY_TITLE,                
 HOME_UNIT,                      
 IS_FACULTY,                     
 IS_GRADUATE_STUDENT_STAFF,      
 IS_RESEARCH_STAFF,              
 IS_SERVICE_STAFF,               
 IS_SUPPORT_STAFF,               
 IS_OTHER_ACCADEMIC_GROUP,       
 IS_MEDICAL_STAFF,               
 VACATION_ACCURAL,               
 IS_ON_SABBATICAL,               
 ID_PROVIDED,                    
 ID_VERIFIED,                    
 UPDATE_TIMESTAMP,               
 UPDATE_USER,
 '77 Massachusetts Ave.',
 OFFICE_LOCATION,
 null,
 'Cambridge',
 'Middlesex',
 'MA',
 '02139',
 'USA',
 null,
 null,
 null,
 null,
'A',
null
from   warehouse_person
where  to_number(person_id) in
       (select to_number(person_id)
        from   warehouse_person
        minus
        select to_number(person_id)
        from   osp$person)
/
commit
/
rem
rem
rem  update any data that may have changed for rows of
rem  data already included in osp$person
rem
rem  for performance, a temporary table is created and
rem  dropped at each comparison
rem
rem    Sync full_name
select 'Sync full_name.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        full_name
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        full_name
 from   osp$person)
/
rem
update osp$person x
set full_name = (select full_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync last_name
rem
select 'Sync last_name.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        last_name
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        last_name
 from   osp$person)
/
rem
update osp$person x
set last_name = (select last_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync first_name
rem
select 'Sync first_name.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        first_name
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        first_name
 from   osp$person)
/
rem
update osp$person x
set first_name = (select first_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync middle_name
rem
select 'Sync middle_name.' from dual
/
drop   table temp 
/
rem
create table temp 
as
(select to_number(person_id) person_id,
        middle_name
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        middle_name
 from   osp$person)
/
rem
update osp$person x
set middle_name = (select middle_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync prior_name
rem
select 'Sync prior_name.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        prior_name
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        prior_name
 from   osp$person)
/
rem
update osp$person x
set prior_name = (select prior_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync user_name
rem
select 'Sync user_name.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        user_name
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        user_name
 from   osp$person)
/
rem
update osp$person x
set user_name = (select user_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem Set User_name to null
rem
select 'Set user_name as NULL for all incative people.' from dual
/
rem  Call the function fn_inactive_users_pfeed to generate emails with list of 
rem persons who are now inactive
rem This function will also update user_name column in osp$person table
var li_ret number;
exec :li_ret := fn_inactive_users_pfeed('coeus-dev-team@mit.edu', 'Coeus Person Feed Kerberos ID cleanup ** Production **');
commit;
rem
rem
rem
rem
rem	 Sync email_address
rem
select 'Sync email_address.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        email_address
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        email_address
 from   osp$person)
/
rem
update osp$person x
set email_address = (select email_address
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync date_of_birth
rem
select 'Sync date_of_birth.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        date_of_birth
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        date_of_birth
 from   osp$person)
/
rem
update osp$person x
set date_of_birth = (select date_of_birth
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync age
rem
select 'Sync age.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        age
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        age
 from   osp$person)
/
rem
update osp$person x
set age = (select age
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync age_by_fiscal_year
rem
select 'Sync age_by_fiscal_year.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        age_by_fiscal_year
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        age_by_fiscal_year
 from   osp$person)
/
rem
update osp$person x
set age_by_fiscal_year = (select age_by_fiscal_year
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync gender
rem
select 'Sync gender.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        gender
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        gender
 from   osp$person)
/
rem
update osp$person x
set gender = (select gender
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync race
rem
select 'Sync race.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        race
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        race
 from   osp$person)
/
rem
update osp$person x
set race = (select race
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync education_level
rem
select 'Sync education_level.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        education_level
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        education_level
 from   osp$person)
/
rem
update osp$person x
set education_level = (select education_level
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync degree
rem
rem Degree sync is commented on 10/1/03 this shouyld be uncommented
--select 'Sync degree.' from dual
--/
--drop   table temp
--/
--rem
--create table temp
--as
--(select to_number(person_id) person_id,
--        degree
-- from   warehouse_person
-- minus
-- select to_number(person_id) person_id,
--        degree
-- from   osp$person)
--/
--rem
--update osp$person x
--set degree = (select degree
--                 from   temp
--                 where  to_number(person_id) = to_number(x.person_id))
--where to_number(person_id) in (select to_number(person_id)
--                            from   temp)
--/
rem
rem	 Sync major
rem
select 'Sync major.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        major
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        major
 from   osp$person)
/
rem
update osp$person x
set major = (select major
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_handicapped
rem
select 'Sync is_handicapped.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_handicapped
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_handicapped
 from   osp$person)
/
rem
update osp$person x
set is_handicapped = (select is_handicapped
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync handicap_type
rem
select 'Sync handicap_type.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        handicap_type
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        handicap_type
 from   osp$person)
/
rem
update osp$person x
set handicap_type = (select handicap_type
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_veteran
rem
select 'Sync is_veteran.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_veteran
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_veteran
 from   osp$person)
/
update osp$person x
set is_veteran = (select is_veteran
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync veteran_type
rem
select 'Sync veteran_type.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        veteran_type
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        veteran_type
 from   osp$person)
/
rem
update osp$person x
set veteran_type = (select veteran_type
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync visa_code
rem
select 'Sync visa_code.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        visa_code
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        visa_code
 from   osp$person)
/
rem
update osp$person x
set visa_code = (select visa_code
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync visa_type
rem
select 'Sync visa_type.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        visa_type
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        visa_type
 from   osp$person)
/
rem
update osp$person x
set visa_type = (select visa_type
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync visa_renewal_date
rem
select 'Sync visa_renewal_date.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        visa_renewal_date
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        visa_renewal_date
 from   osp$person)
/
rem
update osp$person x
set visa_renewal_date = (select visa_renewal_date
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync has_visa
rem
select 'Sync has_visa.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        has_visa
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        has_visa
 from   osp$person)
/
rem
update osp$person x
set has_visa = (select has_visa
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync office_location
rem
select 'Sync office_location.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        office_location
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        office_location
 from   osp$person)
/
rem
update osp$person x
set office_location = (select office_location
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync office_phone
rem
select 'Sync office_phone.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        office_phone
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        office_phone
 from   osp$person)
/
rem
update osp$person x
set office_phone = (select office_phone
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync secondry_office_location
rem
select 'Sync secondry_office_location.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        secondry_office_location
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        secondry_office_location
 from   osp$person)
/
rem
update osp$person x
set secondry_office_location = (select secondry_office_location
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync secondry_office_phone
rem
select 'Sync secondry_office_phone.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        secondry_office_phone
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        secondry_office_phone
 from   osp$person)
/
rem
update osp$person x
set secondry_office_phone = (select secondry_office_phone
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync school
rem
select 'Sync school.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        school
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        school
 from   osp$person)
/
rem
update osp$person x
set school = (select school
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync year_graduated
rem
select 'Sync year_graduated.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        year_graduated
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        year_graduated
 from   osp$person)
/
rem
update osp$person x
set year_graduated = (select year_graduated
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync directory_department
rem
rem DIRECTORY_DEPARTMENT sync is commented out on 10/1/03
--select 'Sync directory_department.' from dual
--/
--drop   table temp
--/
--rem
--create table temp
--as
--(select to_number(person_id) person_id,
--        directory_department
-- from   warehouse_person
-- minus
-- select to_number(person_id) person_id,
--        directory_department
-- from   osp$person)
--/
--rem
--update osp$person x
--set directory_department = (select directory_department
--                 from   temp
--                 where  to_number(person_id) = to_number(x.person_id))
--where to_number(person_id) in (select to_number(person_id)
--                            from   temp)
--/
rem
rem	 Sync salutation
rem
select 'Sync salutation.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        salutation
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        salutation
 from   osp$person)
/
rem
update osp$person x
set salutation = (select salutation
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync country_of_citizenship
rem
select 'Sync country_of_citizenship.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        country_of_citizenship
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        country_of_citizenship
 from   osp$person)
/
rem
update osp$person x
set country_of_citizenship = (select country_of_citizenship
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync primary_title
rem
select 'Sync primary_title.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        primary_title
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        primary_title
 from   osp$person)
/
rem
update osp$person x
set primary_title = (select primary_title
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync directory_title
rem
select 'Sync directory_title.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        directory_title
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        directory_title
 from   osp$person)
/
rem
update osp$person x
set directory_title = (select directory_title
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync home_unit
rem
select 'Sync home_unit.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        home_unit
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        home_unit
 from   osp$person)
/
rem
update osp$person x
set home_unit = (select home_unit
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_faculty
rem
select 'Sync home_unit.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_faculty
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_faculty
 from   osp$person)
/
rem
update osp$person x
set is_faculty = (select is_faculty
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_graduate_student_staff
rem
select 'Sync is_graduate_student_staff.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_graduate_student_staff
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_graduate_student_staff
 from   osp$person)
/
rem
update osp$person x
set is_graduate_student_staff = (select is_graduate_student_staff
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_research_staff
rem
select 'Sync is_research_staff.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_research_staff
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_research_staff
 from   osp$person)
/
rem
update osp$person x
set is_research_staff = (select is_research_staff
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_service_staff
rem
select 'Sync is_service_staff.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_service_staff
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_service_staff
 from   osp$person)
/
rem
update osp$person x
set is_service_staff = (select is_service_staff
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_support_staff
rem
select 'Sync is_support_staff.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_support_staff
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_support_staff
 from   osp$person)
/
rem
update osp$person x
set is_support_staff = (select is_support_staff
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync IS_OTHER_ACCADEMIC_GROUP
rem
select 'Sync IS_OTHER_ACCADEMIC_GROUP.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        IS_OTHER_ACCADEMIC_GROUP
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        IS_OTHER_ACCADEMIC_GROUP
 from   osp$person)
/
rem
update osp$person x
set IS_OTHER_ACCADEMIC_GROUP = (select IS_OTHER_ACCADEMIC_GROUP
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_medical_staff
rem
select 'Sync is_medical_staff.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_medical_staff
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_medical_staff
 from   osp$person)
/
rem
update osp$person x
set is_medical_staff = (select is_medical_staff
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync vacation_accural
rem
select 'Sync vacation_accural.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        vacation_accural
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        vacation_accural
 from   osp$person)
/
rem
update osp$person x
set vacation_accural = (select vacation_accural
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync is_on_sabbatical
rem
select 'Sync is_on_sabbatical.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        is_on_sabbatical
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        is_on_sabbatical
 from   osp$person)
/
rem
update osp$person x
set is_on_sabbatical = (select is_on_sabbatical
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync id_provided
rem
select 'Sync id_provided.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        id_provided
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        id_provided
 from   osp$person)
/
rem
update osp$person x
set id_provided = (select id_provided
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem	 Sync id_verified
rem
select 'Sync id_verified.' from dual
/
drop   table temp
/
rem
create table temp
as
(select to_number(person_id) person_id,
        id_verified
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        id_verified
 from   osp$person)
/
rem
update osp$person x
set id_verified = (select id_verified
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/
rem
rem     Sync address_line2
rem

select 'Sync address_line2.' from dual
/
drop   table temp
/
rem

create table temp
as
(select to_number(person_id) person_id,
        OFFICE_LOCATION as ADDRESS_LINE_2
 from   warehouse_person
 minus
 select to_number(person_id) person_id,
        ADDRESS_LINE_2
 from   osp$person)
/
rem
update osp$person x
set ADDRESS_LINE_2 = (select ADDRESS_LINE_2
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp)
/
commit
/

rem
update osp$person
set home_unit = '999999'
where home_unit is null
/
commit
/
rem
rem
rem
select 'refreshing denormalised tables' from dual
/
rem
rem
select 'Sync osp$award_investigators.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct to_number(osp$person.person_id) person_id,  osp$person.full_name full_name
from osp$person, osp$award_investigators
where osp$person.person_id = osp$award_investigators.person_id
and osp$award_investigators.non_mit_person_flag = 'N' and
trim(osp$award_investigators.person_name) <> trim(osp$person.full_name)
/
rem
select * from temp
/
rem
update osp$award_investigators x
set person_name = (select full_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp) and non_mit_person_flag = 'N'
/
commit
/
rem
rem
rem
select 'Sync OSP$AWARD_APPRVD_FOREIGN_TRIP.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct to_number(osp$person.person_id) person_id,  osp$person.full_name full_name
from osp$person, osp$award_apprvd_foreign_trip
where osp$person.person_id = osp$award_apprvd_foreign_trip.person_id and 
trim(osp$award_apprvd_foreign_trip.person_name) <> trim(osp$person.full_name)
/
rem
rem
select * from temp
/
rem
update osp$award_apprvd_foreign_trip x
set person_name = (select full_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp) 
/
commit
/
rem
rem
rem
select 'Sync OSP$PROPOSAL_INVESTIGATORS.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct to_number(osp$person.person_id) person_id,  osp$person.full_name full_name
from osp$person, osp$proposal_investigators
where osp$person.person_id = osp$proposal_investigators.person_id and 
osp$proposal_investigators.non_mit_person_flag = 'N' and
trim(osp$proposal_investigators.person_name) <> trim(osp$person.full_name)
/
rem
rem
rem
update osp$proposal_investigators x
set person_name = (select full_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp) and
non_mit_person_flag = 'N'
/
commit
/
rem
rem
rem
select 'Sync osp$eps_prop_investigators.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct to_number(osp$person.person_id) person_id,  osp$person.full_name full_name
from osp$person, osp$eps_prop_investigators
where osp$person.person_id = osp$eps_prop_investigators.person_id
and osp$eps_prop_investigators.non_mit_person_flag = 'N' and
trim(osp$eps_prop_investigators.person_name) <> trim(osp$person.full_name)
/
rem
update osp$eps_prop_investigators x
set person_name = (select full_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp) and
non_mit_person_flag = 'N'
/
commit
/
rem
rem
rem
select 'Sync osp$proposal_log.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct to_number(osp$person.person_id) person_id,  osp$person.full_name full_name
from osp$person, osp$proposal_log
where osp$person.person_id = osp$proposal_log.pi_id
and osp$proposal_log.non_mit_person_flag = 'N' and
trim(osp$proposal_log.pi_name) <> trim(osp$person.full_name)
/
rem
update osp$proposal_log x
set pi_name = (select full_name
                 from   temp
                 where  to_number(person_id) = to_number(x.pi_id))
where to_number(pi_id) in (select to_number(person_id)
                            from   temp) and
non_mit_person_flag = 'N'
/
commit
/
rem
rem
rem
select 'Sync osp$user.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct to_number(osp$person.person_id) person_id,  osp$person.full_name full_name
from osp$person, osp$user
where osp$person.person_id = osp$user.person_id
and osp$user.non_mit_person_flag = 'N' and
trim(osp$user.user_name) <> trim(osp$person.full_name)
/
rem
rem
update osp$user x
set user_name = (select full_name
                 from   temp
                 where  to_number(person_id) = to_number(x.person_id))
where to_number(person_id) in (select to_number(person_id)
                            from   temp) and
non_mit_person_flag = 'N'
/
commit
/
rem
rem
rem ** After warehouse switched to SAP, job codes were prefixed with 'HR-'
rem ** when we get the feed we will remove the HR- prefix from job codes

select 'Starting Appointment Feed from warehouse at '  from dual
/
rem
rem
select 'Purge all rows from  warehouse_appointment ' from dual
/
delete from warehouse_appointment
/
rem
rem
rem
select 'Populate warehouse_appointment from warehouse ' from dual
/
insert into warehouse_appointment
( PERSON_ID,
  UNIT_NUMBER,
  PRIMARY_SECONDARY_INDICATOR,
  APPOINTMENT_START_DATE,
  APPOINTMENT_END_DATE,
  APPOINTMENT_TYPE,
  JOB_TITLE,
  PREFERED_JOB_TITLE,
  JOB_CODE)                    
select 
 mit_id,                         
 UNIT_ID,                           
 decode(PRIMARY_SECONDARY_INDICATOR, null, 'Unknown', PRIMARY_SECONDARY_INDICATOR),                   
 APPOINTMENT_START_DATE,                     
 APPOINTMENT_END_DATE,                    
 APPOINTMENT_TYPE,                      
 JOB_TITLE,
 PREFERED_JOB_TITLE,
 JOB_CODE
FROM WAREUSER.COEUS_APPOINTMENT@warehouse_coeus.MIT.EDU                    
/
commit
/
rem
rem
rem
rem **Should not delete appointments for people with ID > 999999983
rem **These are all TBAs
rem
select 'Purge all rows from  osp$appointments ' from dual
/
delete from osp$appointments
where person_id < '999999983'
/
commit
/
rem
rem
rem
select 'Populate osp$appointments from warehouse_appointment ' from dual
/
insert into osp$appointments
( PERSON_ID,
  UNIT_NUMBER,
  PRIMARY_SECONDARY_INDICATOR,
  APPOINTMENT_START_DATE,
  APPOINTMENT_END_DATE,
  APPOINTMENT_TYPE,
  JOB_TITLE,
  PREFERED_JOB_TITLE,
  JOB_CODE,
  SALARY,
  UPDATE_TIMESTAMP,
  UPDATE_USER)                    
select 
 PERSON_ID,                         
 UNIT_NUMBER,                           
 PRIMARY_SECONDARY_INDICATOR,                   
 APPOINTMENT_START_DATE,                     
 APPOINTMENT_END_DATE,                    
 decode(ltrim(rtrim(APPOINTMENT_TYPE)), '11 Months', '11M DURATION', '12 Months', '12M DURATION', '9 Months', '9M DURATION', 'Temporary (< 12 months)', 'TMP EMPLOYEE', 'Term (=> 12 months)', 'REG EMPLOYEE', NULL) ,                      
 JOB_TITLE,
 PREFERED_JOB_TITLE,
 decode(substr(JOB_CODE, 3, 1), '-', SUBSTR(JOB_CODE, 4), JOB_CODE),
 NULL,
 SYSDATE,
 USER
FROM warehouse_appointment                   
/
rem
commit
/
rem ************************************************
rem following update is a temp fix for issue COEUSQA-3815
rem ************************************************
update osp$appointments
set appointment_type = 'REG EMPLOYEE'
where APPOINTMENT_TYPE is null
/
rem
commit
/
rem
rem 
rem 
rem ******************************************************************
rem                DEGREE FEED FROM WAREHOUSE                         
rem ******************************************************************
rem 
rem 
rem *** Purge all rows from WAREHOUSE_DEGREE table
delete from WAREHOUSE_DEGREE
/
rem
rem

/****************
insert into warehouse_degree (PERSON_ID ,     
DEGREE_CODE ,   
GRADUATION_DATE,
DEGREE ,        
FIELD_OF_STUDY ,
SPECIALIZATION ,
SCHOOL ,        
SCHOOL_ID )
select p.mit_id, d.hr_degree_code, 
to_date(decode(pd.degree_completion_month, '00', '01', pd.degree_completion_month) || '/01/' || 
       decode(pd.degree_completion_year, '0000', '1900', pd.degree_completion_year), 'mm/dd/yyyy'), 
 dt.hr_degree_type_code || '.' || d.hr_degree_code || '.' ||  d.hr_degree,
cip.hr_cip_four_digit_code_desc, cip.hr_cip_program_desc, s.hr_edu_institution_name, 
s.hr_edu_institution_id 
from coeus_person@warehouse_coeus.mit.edu p, hr_degree@warehouse_coeus.mit.edu d, 
hr_education_detail@warehouse_coeus.mit.edu pd, hr_degree_type@warehouse_coeus.mit.edu dt, 
hr_cip@warehouse_coeus.mit.edu cip, hr_edu_institution@warehouse_coeus.mit.edu s
where p.mit_id = pd.mit_id and
pd.hr_degree_key = d.hr_degree_key and
pd.hr_degree_type_key = dt.hr_degree_type_key and
pd.cip_key = cip.hr_cip_key and
pd.hr_edu_institution_key = s.hr_edu_institution_key
***********************************************************/

insert into warehouse_degree (PERSON_ID ,     
DEGREE_CODE ,   
GRADUATION_DATE,
DEGREE ,        
FIELD_OF_STUDY ,
SPECIALIZATION ,
SCHOOL ,        
SCHOOL_ID )
select * from coeus_degree@warehouse_coeus.mit.edu
/
commit
/
rem 
rem 
rem **** Purge data from osp$person_degree table
rem *** do not delete any rows that were updated by Coeus users.  
rem 
rem 
delete from osp$person_degree
where update_user = 'OSPA'
/
rem  *** Populate osp$person_degree
rem 
insert into osp$person_degree 
select d.PERSON_ID     , 
decode(m.grantsdotgov_degree_code, NULL, 'UKNW',   m.grantsdotgov_degree_code),
d.GRADUATION_DATE,
d.DEGREE   ,      
d.FIELD_OF_STUDY ,
d.SPECIALIZATION, 
d.SCHOOL,         
2,
d.SCHOOL_ID,
sysdate,
user      from osp$person p, warehouse_degree d, warehouse_degree_type_mapping m
where p.person_id = d.person_id and d.degree_code = m.warehouse_degree_code (+)
/
rem 
commit
/
rem 
rem 
exit;

