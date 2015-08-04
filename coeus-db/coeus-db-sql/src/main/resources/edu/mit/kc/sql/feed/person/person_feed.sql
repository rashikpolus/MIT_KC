set heading off;
set echo off;
set serveroutput on;
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
select 'Purging all rows from  warehouse_person.' from dual
/
truncate table warehouse_person
/
commit
/
rem
select 'Populating warehouse_person from warehouse.' from dual
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
--select 'Inserting new rows into kcperson tables.'  from dual
--/
DECLARE
li_seq_entity_id NUMBER(8);
li_seq_entity_afltn_id NUMBER(8);
li_seq_entity_emp_id NUMBER(8);
li_seq_entity_addr_id NUMBER(8);
li_seq_entity_phn_id NUMBER(8);
li_seq_entity_email_id NUMBER(8);
li_seq_entity_nm_id NUMBER(8);
li_seq_entity_visa_id NUMBER(8);
li_seq_entity_prncpl_id NUMBER(15);
li_seq_fdoc_nbr VARCHAR2(14);
li_seq_person_training_id NUMBER(12,0);

ls_ent_typ_cd VARCHAR2(8):='PERSON';
li_ver_nbr NUMBER(8):=1;
ls_actv_ind VARCHAR2(2):='Y';
ls_dflt_ind VARCHAR2(2):='N';
ls_emp_aftn_typ_ind CHAR(2):='N';
ls_aftn_code VARCHAR2(20);
ls_phn_code  VARCHAR2(20);
ls_user_id VARCHAR2(100);
ls_person_id VARCHAR2(20);
ls_bio_description VARCHAR2(200);
ll_bio_file BLOB;
ls_bio_filename VARCHAR2(150);
ls_bio_file_type VARCHAR2(100);
ls_suppress_nm_ind VARCHAR2(1):='N';
ls_suppress_email_ind VARCHAR2(1):='N';
ls_suppress_addr_ind VARCHAR2(1):='N';
ls_suppress_phone_ind VARCHAR2(1):='N';
ls_suppress_prsnl_ind VARCHAR2(1):='N';
ls_edit_flag  VARCHAR2(1):='N';
li_krim_flag NUMBER(2);
ls_country_code VARCHAR2(3);
li_loop NUMBER(8);
ls_campus_code VARCHAR2(2):='UN';
ls_emp_stat VARCHAR2(40);
li_deflt_flag_check NUMBER;
li_count_phn NUMBER;
ls_display_sort VARCHAR2(2);
li_user_count NUMBER;
li_per_no_data_count NUMBER; 
li_random_num number(10);
li_user_name_null_flag number;
li_firstname_null_flag number;
li_email_null_flag number;
/* count variables*/
li_count_krim_per_training number;
li_count_krim_priv number;
li_count_krim_entity_bio number;
li_count_per_ext number;
li_count_krim_per_doc number;
li_count_krim_prncl number;
li_count_krim_entity_nm number;
li_count_krim_entity_email number;
li_count_krim_entity_phone number;
li_count_krim_phone_typ number;
li_count_krim_entity_addr number;
li_count_krim_entity_ent_typ number;
li_count_krim_entity_emp_info number;
li_count_krim_entity_afltn number;
li_count_krim_entity number;
ls_person varchar2(40);
---------------
ll_stat_mdfn_dt DATE:=sysdate;
li_doc_ver_nbr 	NUMBER(8,0):=1;
li_krew_ver_nbr NUMBER(8,0):=1;
ls_dtype VARCHAR2(50):=null;
ls_app_doc_stat VARCHAR2(64):=null;
ls_award_num varchar2(20);

ll_upd_dt DATE;

ls_hierarchy_sync_child varchar2(2):='N';
ls_award_number VARCHAR2(12);
ls_krew_type varchar2(255):='IdentityManagementPersonDocument';
-- N1 versioning variables
li_changed_seq NUMBER(4,0);
li_new_seq NUMBER(4,0):=0;
li_change_occured pls_integer;
ls_change_indicator VARCHAR2(2);
li_orig_seq NUMBER(4,0);
--li_test_seq NUMBER(4,0):=0;
ls_test_number VARCHAR2(12):=null;
ls_award_sequence_status VARCHAR2(10):='PENDING';
ls_error_page VARCHAR2(20);
li_commit_count number:=0;
ll_rt_stat_mdfn_dt DATE:=sysdate;
-------------
ls_app_doc_stat_mdfn_dt DATE:=null;
ls_doc_nbr VARCHAR2(40);
li_doc_typ_id NUMBER(19,0); 
ls_doc_hdr_stat_cd VARCHAR2(1):='S';
li_rte_lvl NUMBER(8,0):=0;
ll_crte_dt DATE:=sysdate;
ll_aprv_dt DATE:=sysdate;
ll_fnl_dt DATE:=null;
ll_rte_lvl_mdfn_dt DATE:=null;
ls_title VARCHAR2(255);
ls_app_doc_id VARCHAR2(255):=null;
ls_initr_prncpl_id VARCHAR2(40);
ls_rte_prncpl_id VARCHAR2(40):=null;
li_max_sequence_num NUMBER;
ls_version_status  VARCHAR2(16);   
li_pending  NUMBER;
ls_lead_unit_num  VARCHAR2(8);
ls_proposal_number VARCHAR2(12);
ls_protocol_number VARCHAR2(20);
ls_sub_award VARCHAR2(20);
li_krew_rnt_brch NUMBER(19,0);
li_krew_rnt_node NUMBER(19,0);
li_krew_rne_node_instn NUMBER(19,0);
li_krew_actn_rqst NUMBER(19,0);
li_krew_actn_tkn NUMBER(19,0); 
ls_prncpl_nm	VARCHAR2(100);
li_country_cd varchar2(2);
li_us_count number;
ls_new_user_flag char(1);
ls_user_name VARCHAR2(100);
ls_phone_number varchar2(20);
v_code  NUMBER;
v_errm  VARCHAR2(64);
ls_prncpl_id   VARCHAR2(40);

CURSOR c_pers IS
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
 '77 Massachusetts Ave.' ADDRESS_LINE_1,
 OFFICE_LOCATION ADDRESS_LINE_2,
 null ADDRESS_LINE_3,
 'Cambridge' CITY,
 'Middlesex' COUNTY,
 'MA' STATE,
 '021394307' POSTAL_CODE,
 'USA' COUNTRY_CODE,
 null FAX_NUMBER,
 null PAGER_NUMBER,
 null MOBILE_PHONE_NUMBER,
 null ERA_COMMONS_USER_NAME,
'A' STATUS,
null SALARY_ANNIVERSARY_DATE
FROM  warehouse_person
WHERE person_id IN
       (select person_id
        from   warehouse_person
        minus
        select PRNCPL_ID
        from   KRIM_PRNCPL_T);
r_pers c_pers%ROWTYPE;

CURSOR c1_data(para_personID VARCHAR2) is
SELECT  TRAINING_NUMBER,TRAINING_CODE,DATE_REQUESTED,DATE_SUBMITTED,DATE_ACKNOWLEDGED,
FOLLOWUP_DATE,SCORE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER  from  PERSON_TRAINING where PERSON_ID=para_personID;   
r_perT c1_data%ROWTYPE;

BEGIN
    IF c_pers%ISOPEN THEN
      CLOSE c_pers;
    END IF;
    OPEN c_pers;
    LOOP
    FETCH c_pers INTO r_pers;
    EXIT WHEN c_pers%NOTFOUND;
	
	
	IF r_pers.USER_NAME IS NULL THEN	  
	  ls_user_name := r_pers.person_id;
	  
	ELSE
      ls_user_name:= lower(r_pers.USER_NAME);
	  
	      begin
	          select prncpl_id into ls_prncpl_id from krim_prncpl_t where prncpl_nm = ls_user_name;
		  exception
		  when others then
		    ls_prncpl_id := null;
			
		  end;
		  
		     if ls_prncpl_id is not null then
			 
			    update KRIM_PRNCPL_T
				set ACTV_IND = 'N',
				    PRNCPL_NM = ls_prncpl_id
				where PRNCPL_ID = ls_prncpl_id;
				
				update KRIM_PERSON_DOCUMENT_T
				set ACTV_IND = 'N',
				    PRNCPL_NM = ls_prncpl_id
				where PRNCPL_ID = ls_prncpl_id;
				
			  end if;
		
    END IF;
    
    select KRIM_ENTITY_ID_S.NEXTVAL into li_seq_entity_id from dual;          
    select KRIM_ENTITY_EMP_ID_S.NEXTVAL into li_seq_entity_emp_id from dual; 
    select KRIM_ENTITY_NM_ID_S.NEXTVAL into li_seq_entity_nm_id from dual;
    
    INSERT INTO KRIM_ENTITY_T(ENTITY_ID,OBJ_ID,VER_NBR,ACTV_IND,LAST_UPDT_DT) 
    VALUES( li_seq_entity_id,SYS_GUID(),li_ver_nbr,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
	
	     


    begin
            select KREW_DOC_HDR_S.NEXTVAL into li_seq_fdoc_nbr from dual;

            INSERT INTO KRIM_PERSON_DOCUMENT_T(FDOC_NBR,ENTITY_ID,OBJ_ID,VER_NBR,PRNCPL_ID,PRNCPL_NM,PRNCPL_PSWD,UNIV_ID,ACTV_IND)
            VALUES(li_seq_fdoc_nbr,li_seq_entity_id,SYS_GUID(),li_ver_nbr,r_pers.person_id,ls_user_name,NULL,NULL,decode(r_pers.status,'A','Y','N'));

            INSERT INTO KRIM_PRNCPL_T(PRNCPL_ID,OBJ_ID,VER_NBR,PRNCPL_NM,ENTITY_ID,PRNCPL_PSWD,ACTV_IND,LAST_UPDT_DT)
            VALUES(r_pers.person_id,SYS_GUID(),li_ver_nbr,ls_user_name,li_seq_entity_id,NULL,decode(r_pers.status,'A','Y','N'),r_pers.UPDATE_TIMESTAMP);

    exception
    when others then    
    dbms_output.put_line('Error for person_id'||r_pers.person_id||' '||sqlerrm);  
    end;


    li_deflt_flag_check:=0;
    li_krim_flag:=0;
     BEGIN
			   IF UPPER(TRIM(r_pers.IS_MEDICAL_STAFF))='Y' then                          
			      li_krim_flag:=1;
			      select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
			      ls_aftn_code:='MED_STAFF';
			      INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			      VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
		   
          END IF;
			    IF UPPER(TRIM(r_pers.IS_OTHER_ACCADEMIC_GROUP))='Y' then                       
			       li_krim_flag:=1;
			       select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
			       ls_aftn_code:='OTH_ACADMC_GRP';
			       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			       VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
			 
			     END IF;  
		       IF UPPER(TRIM(r_pers.IS_SUPPORT_STAFF))='Y' then                     
		            li_krim_flag:=1;
			          select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
			          ls_aftn_code:='SUPPRT_STAFF';
			          INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			          VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
		   
			      END IF; 
		        IF UPPER(TRIM(r_pers.IS_SERVICE_STAFF))='Y' then                     
		          li_krim_flag:=1;
			        select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id  from dual;
			        ls_aftn_code:='SRVC_STAFF';
			        INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				      VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
			 
			       END IF;  
		         IF UPPER(TRIM(r_pers.IS_RESEARCH_STAFF))='Y' then                     
		            li_krim_flag:=1;
			          select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
			          ls_aftn_code:='RSRCH_STAFF';
			          INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				        VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
			
             END IF;    
		         IF UPPER(TRIM(r_pers.IS_GRADUATE_STUDENT_STAFF))='Y' then                     
		            li_krim_flag:=1;
			          select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
			          ls_aftn_code:='GRD_STDNT_STAFF';
			          INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				        VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
		   
		         END IF;  
		         IF UPPER(TRIM(r_pers.IS_FACULTY))  ='Y' then           
		 
                li_krim_flag:=1;
			          select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
			          ls_aftn_code:='FCLTY';
			          INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			          VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
			   
		          ELSIF   UPPER(TRIM(r_pers.IS_FACULTY))  ='N' then 
				         li_krim_flag:=1;
				         select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
				         ls_aftn_code:='STAFF';
				         INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				         VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
			  
		          END IF;  
--Added to fix the application UI Issue			 
			        IF  li_krim_flag = 0 THEN
			
				         li_krim_flag:=1;
				         select KRIM_ENTITY_AFLTN_ID_S.NEXTVAL into li_seq_entity_afltn_id from dual;
				         ls_aftn_code:='AFLT';
				         INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				         VALUES(li_seq_entity_afltn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_aftn_code,ls_campus_code,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);				   
			
			        END IF;
--Added to fix the application UI Issue	
		
    EXCEPTION
    WHEN OTHERS THEN 
 	v_code := SQLCODE;
	v_errm := SUBSTR(SQLERRM, 1, 64);
	DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
    dbms_output.put_line('Error occoured for KRIM_ENTITY_AFLTN_T  for the person '||r_pers.person_id);
    END;


    BEGIN
      INSERT INTO KRIM_ENTITY_ENT_TYP_T(ENT_TYP_CD,ENTITY_ID,ACTV_IND,OBJ_ID,VER_NBR,LAST_UPDT_DT) 
      VALUES(ls_ent_typ_cd,li_seq_entity_id,ls_actv_ind,SYS_GUID(),li_ver_nbr,r_pers.UPDATE_TIMESTAMP);   
    EXCEPTION
    WHEN OTHERS THEN 
 	v_code := SQLCODE;
	v_errm := SUBSTR(SQLERRM, 1, 64);
	DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
    
    dbms_output.put_line('Error occoured for KRIM_ENTITY_ENT_TYP_T  for the person '||r_pers.person_id); 
    END; 

    IF  r_pers.COUNTRY_CODE IS NOT NULL OR r_pers.ADDRESS_LINE_1 IS NOT NULL OR r_pers.ADDRESS_LINE_2 IS NOT NULL OR r_pers.ADDRESS_LINE_3 IS NOT NULL OR r_pers.CITY  IS NOT NULL OR r_pers.STATE IS NOT NULL OR r_pers.POSTAL_CODE IS NOT NULL THEN
        begin
           select POSTAL_CNTRY_CD into li_country_cd from KRLC_CNTRY_T where upper(ALT_POSTAL_CNTRY_CD) = upper(r_pers.COUNTRY_CODE);
        exception
        when others then
         li_country_cd := null;
        end;

        BEGIN

           select KRIM_ENTITY_ADDR_ID_S.NEXTVAL into li_seq_entity_addr_id from dual;  
           INSERT INTO KRIM_ENTITY_ADDR_T(ENTITY_ADDR_ID,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,ADDR_TYP_CD,ADDR_LINE_1,ADDR_LINE_2,ADDR_LINE_3,CITY,STATE_PVC_CD,POSTAL_CD,LAST_UPDT_DT,ATTN_LINE,ADDR_FMT,MOD_DT,VALID_DT,VALID_IND,NOTE_MSG) 
           VALUES(li_seq_entity_addr_id,li_country_cd,'Y',ls_actv_ind,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_ent_typ_cd,'WRK',SUBSTRB(r_pers.ADDRESS_LINE_1,1,45),SUBSTRB(r_pers.ADDRESS_LINE_2,1,45),SUBSTRB(r_pers.ADDRESS_LINE_3,1,45),r_pers.CITY,r_pers.STATE,r_pers.POSTAL_CODE,r_pers.UPDATE_TIMESTAMP,NULL,NULL,r_pers.UPDATE_TIMESTAMP,NULL,NULL,NULL);
        EXCEPTION
        WHEN OTHERS THEN 
     	v_code := SQLCODE;
		v_errm := SUBSTR(SQLERRM, 1, 64);
		DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
          dbms_output.put_line('Error occoured for KRIM_ENTITY_ADDR_T  for the person '||r_pers.person_id); 
        END;      

     END IF; 

     BEGIN

        IF r_pers.OFFICE_PHONE IS NOT NULL THEN
				      select KRIM_ENTITY_PHONE_ID_S.NEXTVAL into li_seq_entity_phn_id from dual;
				      ls_phn_code:='WRK';
				
					    SELECT COUNT(PHONE_TYP_CD) INTO li_count_phn FROM KRIM_PHONE_TYP_T WHERE PHONE_TYP_CD='WRK';
					    IF li_count_phn=0 THEN
					         SELECT COUNT(*) INTO li_count_phn  FROM KRIM_PHONE_TYP_T;
					         SELECT CHR(97+li_count_phn) INTO ls_display_sort  FROM DUAL;
					         INSERT INTO KRIM_PHONE_TYP_T (ACTV_IND,DISPLAY_SORT_CD,LAST_UPDT_DT,OBJ_ID,PHONE_TYP_CD,PHONE_TYP_NM,VER_NBR)
					         VALUES ('Y',ls_display_sort,r_pers.UPDATE_TIMESTAMP,SYS_GUID(),'WRK','Work',1);
					    END IF;
              IF  li_deflt_flag_check=0 THEN
					         ls_dflt_ind:='Y';
					         li_deflt_flag_check:=1;
					    END IF; 
				      select replace(translate(r_pers.OFFICE_PHONE,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;

              select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) into ls_phone_number from dual;

				      INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				      VALUES(li_seq_entity_phn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_ent_typ_cd,ls_phn_code,ls_phone_number,NULL,NULL,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
				      ls_dflt_ind:='N';  
		      END IF;  
		
		      IF r_pers.SECONDRY_OFFICE_PHONE IS NOT NULL THEN
				           select KRIM_ENTITY_PHONE_ID_S.NEXTVAL into li_seq_entity_phn_id from dual;
				           ls_phn_code:='HM';
				   
                   SELECT COUNT(PHONE_TYP_CD) INTO li_count_phn FROM KRIM_PHONE_TYP_T WHERE PHONE_TYP_CD='HM';
					         IF li_count_phn=0 THEN
					            SELECT COUNT(*) INTO li_count_phn  FROM KRIM_PHONE_TYP_T;
					            SELECT CHR(97+li_count_phn) INTO ls_display_sort  FROM DUAL;
					            INSERT INTO KRIM_PHONE_TYP_T (ACTV_IND,DISPLAY_SORT_CD,LAST_UPDT_DT,OBJ_ID,PHONE_TYP_CD,PHONE_TYP_NM,VER_NBR)
                      VALUES ('Y',ls_display_sort,r_pers.UPDATE_TIMESTAMP,SYS_GUID(),'HM','Home',1);
					          END IF;
				
				
					          IF  li_deflt_flag_check=0 THEN
						            ls_dflt_ind:='Y';
						            li_deflt_flag_check:=1;
					           END IF;
				             select replace(translate(r_pers.SECONDRY_OFFICE_PHONE,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;

                     select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) into ls_phone_number from dual; 				
				             INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				             VALUES(li_seq_entity_phn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_ent_typ_cd,ls_phn_code,ls_phone_number,NULL,NULL,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
				             ls_dflt_ind:='N';     
		          END IF;

          EXCEPTION
          WHEN OTHERS THEN 
	     	v_code := SQLCODE;
			v_errm := SUBSTR(SQLERRM, 1, 64);
			DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
          dbms_output.put_line('Error occoured for KRIM_ENTITY_PHONE_T OR KRIM_PHONE_TYP_T  for the person '||r_pers.person_id); 
          END;  

          IF r_pers.EMAIL_ADDRESS IS NOT NULL THEN

             BEGIN

                  select KRIM_ENTITY_EMAIL_ID_S.NEXTVAL into li_seq_entity_email_id from dual;
                  INSERT INTO KRIM_ENTITY_EMAIL_T(ENTITY_EMAIL_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,EMAIL_TYP_CD,EMAIL_ADDR,DFLT_IND,ACTV_IND,LAST_UPDT_DT) 
                  VALUES(li_seq_entity_email_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_ent_typ_cd,'WRK',r_pers.EMAIL_ADDRESS,'Y',ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
              EXCEPTION
              WHEN OTHERS THEN 
             	v_code := SQLCODE;
    			v_errm := SUBSTR(SQLERRM, 1, 64);
    			DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
                  dbms_output.put_line('Error occoured for KRIM_ENTITY_EMAIL_T  for the person '||r_pers.person_id); 
              END;   

           END IF;  

           BEGIN   
              INSERT INTO KRIM_ENTITY_NM_T(ENTITY_NM_ID,OBJ_ID,VER_NBR,ENTITY_ID,NM_TYP_CD,FIRST_NM,MIDDLE_NM,LAST_NM,SUFFIX_NM,TITLE_NM,DFLT_IND,ACTV_IND,LAST_UPDT_DT,PREFIX_NM,NOTE_MSG,NM_CHNG_DT)  
              VALUES(li_seq_entity_nm_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,'PRFR',r_pers.FIRST_NAME,r_pers.MIDDLE_NAME,r_pers.LAST_NAME,NULL,NULL,'Y',ls_actv_ind,r_pers.UPDATE_TIMESTAMP,NULL,NULL,NULL);

           EXCEPTION
           WHEN OTHERS THEN 
         	v_code := SQLCODE;
			v_errm := SUBSTR(SQLERRM, 1, 64);
			DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
           dbms_output.put_line('Error occoured for KRIM_ENTITY_NM_T  for the person '||r_pers.person_id); 
           END;     

            ls_person_id:=r_pers.person_id;
            BEGIN
               INSERT INTO KRIM_ENTITY_EMP_INFO_T(ENTITY_EMP_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENTITY_AFLTN_ID,EMP_STAT_CD,EMP_TYP_CD,BASE_SLRY_AMT,PRMRY_IND,ACTV_IND,PRMRY_DEPT_CD,EMP_ID,EMP_REC_ID,LAST_UPDT_DT) 
               VALUES(li_seq_entity_emp_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,li_seq_entity_afltn_id,r_pers.STATUS,'O',0.00,'Y',ls_actv_ind,r_pers.home_unit,ls_person_id,'1',r_pers.UPDATE_TIMESTAMP);

-- END IF;
            EXCEPTION
            WHEN OTHERS THEN 
         	v_code := SQLCODE;
			v_errm := SUBSTR(SQLERRM, 1, 64);
			DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
            dbms_output.put_line('Error occoured for KRIM_ENTITY_EMP_INFO_T  for the person '||r_pers.person_id); 
            END;

            BEGIN
/*        select BIO_PDF,FILE_NAME,MIME_TYPE,DESCRIPTION into ll_bio_file,ls_bio_filename,ls_bio_file_type,ls_bio_description  from temp_person_ext where PERSON_ID= ls_person_id;           

exception 
when others then
*/
                 ls_bio_description:=null;
                 ll_bio_file:=null;
                 ls_bio_filename:=null;
                 ls_bio_file_type:=null;	


                 INSERT INTO PERSON_EXT_T(PERSON_ID,VER_NBR,AGE_BY_FISCAL_YEAR,RACE,EDUCATION_LEVEL,DEGREE,MAJOR,IS_HANDICAPPED,HANDICAP_TYPE,IS_VETERAN,VETERAN_TYPE,VISA_CODE,VISA_TYPE,VISA_RENEWAL_DATE,HAS_VISA,OFFICE_LOCATION,SECONDRY_OFFICE_LOCATION,SCHOOL,YEAR_GRADUATED,DIRECTORY_DEPARTMENT,PRIMARY_TITLE,DIRECTORY_TITLE,IS_RESEARCH_STAFF,VACATION_ACCURAL,IS_ON_SABBATICAL,ID_PROVIDED,ID_VERIFIED,UPDATE_TIMESTAMP,UPDATE_USER,COUNTY,OBJ_ID,CITIZENSHIP_TYPE_CODE,SALARY_ANNIVERSARY_DATE,ERA_COMMON_USER_NAME) 
                 VALUES(ls_person_id,li_ver_nbr,r_pers.AGE_BY_FISCAL_YEAR,r_pers.RACE,r_pers.EDUCATION_LEVEL,r_pers.DEGREE,r_pers.MAJOR,r_pers.IS_HANDICAPPED,r_pers.HANDICAP_TYPE,r_pers.IS_VETERAN,r_pers.VETERAN_TYPE,r_pers.VISA_CODE,r_pers.VISA_TYPE,r_pers.VISA_RENEWAL_DATE,r_pers.HAS_VISA,r_pers.OFFICE_LOCATION,r_pers.SECONDRY_OFFICE_LOCATION,r_pers.SCHOOL,r_pers.YEAR_GRADUATED,r_pers.DIRECTORY_DEPARTMENT,r_pers.PRIMARY_TITLE,r_pers.DIRECTORY_TITLE,r_pers.IS_RESEARCH_STAFF,r_pers.VACATION_ACCURAL,r_pers.IS_ON_SABBATICAL,r_pers.ID_PROVIDED,r_pers.ID_VERIFIED,r_pers.UPDATE_TIMESTAMP,r_pers.UPDATE_USER,r_pers.COUNTY,SYS_GUID(),1,r_pers.SALARY_ANNIVERSARY_DATE,r_pers.ERA_COMMONS_USER_NAME);
             EXCEPTION
             WHEN OTHERS THEN 
             	v_code := SQLCODE;
    			v_errm := SUBSTR(SQLERRM, 1, 64);
    			DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
                 dbms_output.put_line('Error occoured for PERSON_EXT_T  for the person '||r_pers.person_id);        
             END; 

             BEGIN
               INSERT INTO KRIM_ENTITY_BIO_T(ENTITY_ID,DECEASED_DT,MARITAL_STATUS,PRIM_LANG_CD,SEC_LANG_CD,BIRTH_CNTRY_CD,BIRTH_STATE_PVC_CD,BIRTH_CITY,GEO_ORIGIN,OBJ_ID,VER_NBR,BIRTH_DT,GNDR_CD,LAST_UPDT_DT,NOTE_MSG,GNDR_CHG_CD) 
               VALUES(li_seq_entity_id,NULL,NULL,NULL,NULL,NULL,r_pers.STATE,r_pers.CITY,NULL,SYS_GUID(),li_ver_nbr,r_pers.DATE_OF_BIRTH,NVL2(r_pers.GENDER,SUBSTRB(r_pers.GENDER,1,1),' '),r_pers.UPDATE_TIMESTAMP,NULL,NULL);
             EXCEPTION
             WHEN OTHERS THEN 
             	v_code := SQLCODE;
    			v_errm := SUBSTR(SQLERRM, 1, 64);
    			DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
                  dbms_output.put_line('Error occoured for KRIM_ENTITY_BIO_T  for the person '||r_pers.person_id);        
             END; 

             BEGIN
               INSERT INTO KRIM_ENTITY_PRIV_PREF_T(ENTITY_ID,OBJ_ID,VER_NBR,SUPPRESS_NM_IND,SUPPRESS_EMAIL_IND,SUPPRESS_ADDR_IND,SUPPRESS_PHONE_IND,SUPPRESS_PRSNL_IND,LAST_UPDT_DT) 
               VALUES(li_seq_entity_id,SYS_GUID(),li_ver_nbr,ls_suppress_nm_ind,ls_suppress_email_ind,ls_suppress_addr_ind,ls_suppress_phone_ind,ls_suppress_prsnl_ind,r_pers.UPDATE_TIMESTAMP);

             EXCEPTION
             WHEN OTHERS THEN 
             	v_code := SQLCODE;
    			v_errm := SUBSTR(SQLERRM, 1, 64);
    			DBMS_OUTPUT.PUT_LINE (v_code || ' ' || v_errm);
                 dbms_output.put_line('Error occoured for KRIM_ENTITY_PRIV_PREF_T for the person '||r_pers.person_id);        
             END;
			 
			    INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
                values(r_pers.person_id,'DELEGATOR_FILTER','Secondary Delegators on Action List Page',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DocSearch.LastSearch.Holding1','{"documentStatuses":[],"documentStatusCategories":[],"additionalDocumentTypeNames":[],"dateCreatedFrom":1430862406767,"documentAttributeValues":{},"isAdvancedSearch":"NO","searchOptions":{},"applicationDocumentStatuses":[]}',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'EMAIL_NOTIFICATION','immediate',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'NOTIFY_APPROVE','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_C','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOC_TYPE_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'INITIATOR_COL_SHOW_NEW',null,1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'CURRENT_NODE_COL_SHOW_NEW','no',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'LAST_APPROVED_DATE_COL_SHOW_NEW','no',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'TITLE_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'ACTION_REQUESTED_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'ACTION_LIST_SIZE_NEW','10',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'NOTIFY_ACKNOWLEDGE',null,1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'NOTIFY_COMPLETE',null,1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DELEGATOR_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_D','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_I','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_R','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DATE_CREATED_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_P','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'NOTIFY_FYI',null,1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'EMAIL_NOTIFY_PRIMARY','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_E','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'CLEAR_FYI_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'WORKGROUP_REQUEST_COL_SHOW_NEW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'OPEN_ITEMS_NEW_WINDOW','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_F','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_X','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'APP_DOC_STATUS_COL_SHOW_NEW',null,1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'REFRESH_RATE','15',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_A','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DOCUMENT_STATUS_COLOR_S','white',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'USE_OUT_BOX','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'EMAIL_NOTIFY_SECONDARY','yes',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DocSearch.LastSearch.Order','DocSearch.LastSearch.Holding1,DocSearch.LastSearch.Holding0',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'DocSearch.LastSearch.Holding0','{"documentStatuses":[],"documentStatusCategories":[],"additionalDocumentTypeNames":[],"dateCreatedFrom":1430679105372,"documentAttributeValues":{},"isAdvancedSearch":"NO","searchOptions":{},"applicationDocumentStatuses":[]}',1);

				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				values(r_pers.person_id,'PRIMARY_DELEGATE_FILTER','Primary Delegates on Action List Page',1);
				
				INSERT INTO KREW_USR_OPTN_T(PRNCPL_ID,PRSN_OPTN_ID,VAL,VER_NBR)
				VALUES(r_pers.person_id,'ProtocolDocument.DocumentTypeNotificationcommit','no',1);

                commit;

             BEGIN
               IF c1_data%ISOPEN THEN
		            CLOSE c1_data;
		           END IF;
               OPEN c1_data(ls_person_id);
		           LOOP
		           FETCH c1_data INTO r_perT;
		           EXIT WHEN c1_data%NOTFOUND;
		               select SEQ_PERSON_TRAINING_ID.NEXTVAL into li_seq_person_training_id from dual;
	 
		               INSERT INTO PERSON_TRAINING(PERSON_TRAINING_ID,
		                                           PERSON_ID,
		                                           TRAINING_NUMBER,
		                                           TRAINING_CODE,
                                               DATE_REQUESTED,
		                                           DATE_SUBMITTED,
                                               DATE_ACKNOWLEDGED,
		                                           FOLLOWUP_DATE,
		                                           SCORE,
		                                           COMMENTS,
		                                           UPDATE_TIMESTAMP,
                                               UPDATE_USER,
		                                           VER_NBR,
		                                           OBJ_ID,
		                                           ACTIVE_FLAG) 
                    VALUES(li_seq_person_training_id,
		                       ls_person_id,
		                       r_perT.TRAINING_NUMBER,
		                       r_perT.TRAINING_CODE,
		                       r_perT.DATE_REQUESTED,
		                       r_perT.DATE_SUBMITTED,
		                       r_perT.DATE_ACKNOWLEDGED,
		                       r_perT.FOLLOWUP_DATE,
		                       r_perT.SCORE,
		                       r_perT.COMMENTS,
		                       r_perT.UPDATE_TIMESTAMP,
		                       r_perT.UPDATE_USER,
		                       li_ver_nbr,
		                       SYS_GUID(),
		                       ls_actv_ind);
		 
		            END LOOP;
		     EXCEPTION 
		     WHEN OTHERS THEN
		       dbms_output.put_line('error occoured for PERSON_TRAINING '||SQLERRM);                    
                CLOSE   c1_data;
          END;
    END LOOP;
    CLOSE c_pers;
END;
/

commit
/
--select 'Completed Inserting new rows into kcperson tables.'  from dual
--/
--select 'Updation of changed last_name begins.'  from dual
/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
 t1.last_name, 
 (select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.last_nm as last_name,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_NM_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.last_name <> nvl(t2.last_name,'-888');
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;



    SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_NM_T WHERE ENTITY_ID=r_update.ENTITY_ID;

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
       
	   
       INSERT INTO KRIM_ENTITY_NM_T(ENTITY_NM_ID,ENTITY_ID,NM_TYP_CD,LAST_NM,OBJ_ID,VER_NBR,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
       VALUES(KRIM_ENTITY_NM_ID_S.NEXTVAL,r_update.ENTITY_ID,'PRFR',r_update.last_name,sys_guid(),1,'Y','Y',sysdate);
	   
       
    ELSE
    
       UPDATE KRIM_ENTITY_NM_T
       SET LAST_NM=r_update.last_name
       WHERE ENTITY_ID=r_update.ENTITY_ID;
       
    END IF;



END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed last_name ends.'  from dual
--/
--select 'Updation of changed first_name begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
 t1.first_name, 
 (select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.first_nm as first_name,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_NM_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.first_name <> nvl(t2.first_name,'-888');
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;



    SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_NM_T WHERE ENTITY_ID=r_update.ENTITY_ID;

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
       
	   
       INSERT INTO KRIM_ENTITY_NM_T(ENTITY_NM_ID,ENTITY_ID,NM_TYP_CD,FIRST_NM,OBJ_ID,VER_NBR,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
       VALUES(KRIM_ENTITY_NM_ID_S.NEXTVAL,r_update.ENTITY_ID,'PRFR',r_update.first_name,sys_guid(),1,'Y','Y',sysdate);
	   
       
    ELSE
    
       UPDATE KRIM_ENTITY_NM_T
       SET FIRST_NM=r_update.first_name
       WHERE ENTITY_ID=r_update.ENTITY_ID;
       
    END IF;



END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed first_name ends.'  from dual
--/
--select 'Updation of changed middle_name begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
 t1.middle_name, 
 (select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.middle_nm as middle_name,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_NM_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.middle_name <> nvl(t2.middle_name,'-888');
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;



    SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_NM_T WHERE ENTITY_ID=r_update.ENTITY_ID;

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
       
	  
       INSERT INTO KRIM_ENTITY_NM_T(ENTITY_NM_ID,ENTITY_ID,NM_TYP_CD,MIDDLE_NM,OBJ_ID,VER_NBR,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
       VALUES(KRIM_ENTITY_NM_ID_S.NEXTVAL,r_update.ENTITY_ID,'PRFR',r_update.middle_name,sys_guid(),1,'Y','Y',sysdate);
	   
       
    ELSE
    
       UPDATE KRIM_ENTITY_NM_T
       SET MIDDLE_NM=r_update.middle_name
       WHERE ENTITY_ID=r_update.ENTITY_ID;
       
    END IF;



END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed middle_name ends.'  from dual
--/
--select 'Updation of changed user_name begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.user_name, 
 (select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select prncpl_id as person_id,
        prncpl_nm as user_name
        from   KRIM_PRNCPL_T ) t2 on t1.person_id = t2.person_id
 where t1.user_name <> nvl(t2.user_name,'-888');
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;




IF r_update.user_name IS NOT NULL THEN

SELECT COUNT(PRNCPL_ID) into li_count FROM KRIM_PRNCPL_T WHERE PRNCPL_NM=r_update.user_name;
  IF li_count=0 THEN
    IF r_update.ENTITY_ID IS NOT NULL THEN
       
	     UPDATE KRIM_PRNCPL_T
       SET PRNCPL_NM=r_update.user_name
       WHERE ENTITY_ID=r_update.ENTITY_ID;
       
    END IF;
  END IF;  
END IF;


END LOOP;
CLOSE c_update;
END;
/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.user_name, 
 (select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select prncpl_id as person_id,
        prncpl_nm as user_name
        from   KRIM_PERSON_DOCUMENT_T ) t2 on t1.person_id = t2.person_id
 where t1.user_name <> nvl(t2.user_name,'-888');
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

IF r_update.user_name IS NOT NULL THEN

 SELECT COUNT(PRNCPL_ID) into li_count FROM KRIM_PRNCPL_T WHERE PRNCPL_NM=r_update.user_name;
 IF li_count=0 THEN
  IF r_update.ENTITY_ID IS NOT NULL THEN
       
	     UPDATE KRIM_PERSON_DOCUMENT_T
       SET PRNCPL_NM=r_update.user_name
       WHERE ENTITY_ID=r_update.ENTITY_ID;
       
   END IF;
 END IF;
END IF;

END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed user_name ends.'  from dual
--/
--select 'Set people as inactive if username is NULL in warehouse.' from dual
--/
DECLARE
li_ret number;
BEGIN
li_ret:=fn_inactive_users_pfeed();
END;
/
--select 'Updation of changed email_address begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
 t1.email_address, 
 (select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.email_addr as email_address,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_EMAIL_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.email_address <> nvl(t2.email_address,'-888');
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

IF r_update.email_address IS NOT NULL  THEN

       SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_EMAIL_T WHERE ENTITY_ID=r_update.ENTITY_ID AND EMAIL_TYP_CD = 'WRK';

       IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
       
	  
             INSERT INTO KRIM_ENTITY_EMAIL_T(ENTITY_EMAIL_ID,ENTITY_ID,ENT_TYP_CD,EMAIL_TYP_CD,EMAIL_ADDR,OBJ_ID,VER_NBR,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
             VALUES(KRIM_ENTITY_EMAIL_ID_S.NEXTVAL,r_update.ENTITY_ID,'PERSON','WRK',r_update.email_address,sys_guid(),1,'Y','Y',sysdate);
	   
       
       ELSE
    
              UPDATE KRIM_ENTITY_EMAIL_T
              SET EMAIL_ADDR=r_update.email_address
              WHERE ENTITY_ID=r_update.ENTITY_ID
			  AND EMAIL_TYP_CD = 'WRK';
       
       END IF;

END IF;

END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed email_address ends.'  from dual
--/
--select 'Updation of changed date_of_birth begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
 t1.date_of_birth,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.BIRTH_DT as date_of_birth,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_BIO_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t2.date_of_birth IS NOT NULL;
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;




      SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_BIO_T WHERE ENTITY_ID=r_update.ENTITY_ID;

      IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
       
	       IF r_update.date_of_birth IS NOT NULL  THEN
               INSERT INTO KRIM_ENTITY_BIO_T(ENTITY_ID,BIRTH_DT,OBJ_ID,VER_NBR,LAST_UPDT_DT)
               VALUES(r_update.ENTITY_ID,r_update.date_of_birth,sys_guid(),1,sysdate);
	       END IF;
       
      ELSE
    
           UPDATE KRIM_ENTITY_BIO_T
           SET BIRTH_DT=r_update.date_of_birth
           WHERE ENTITY_ID=r_update.ENTITY_ID;
       
      END IF;



END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed date_of_birth ends.'  from dual
--/
--select 'Updation of changed age_by_fiscal_year begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.age_by_fiscal_year 
from warehouse_person t1 left outer join 
 ( select person_id,
          age_by_fiscal_year
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.age_by_fiscal_year <>t2.age_by_fiscal_year;
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET age_by_fiscal_year=r_update.age_by_fiscal_year
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed age_by_fiscal_year ends.'  from dual
--/
--select 'Updation of changed gender_cd begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
 t1.gender, 
 (select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
 from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.GNDR_CD as gender,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_BIO_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.gender<>nvl(t2.gender,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

IF r_update.gender IS NOT NULL THEN

       SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_BIO_T WHERE ENTITY_ID=r_update.ENTITY_ID;

       IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
       
	  
              INSERT INTO KRIM_ENTITY_BIO_T(ENTITY_ID,GNDR_CD,OBJ_ID,VER_NBR,LAST_UPDT_DT)
              VALUES(r_update.ENTITY_ID,r_update.gender,sys_guid(),1,sysdate);
	   
       
       ELSE
    
              UPDATE KRIM_ENTITY_BIO_T
              SET GNDR_CD=r_update.gender
              WHERE ENTITY_ID=r_update.ENTITY_ID;
       
       END IF;
	   
END IF;	   



END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed gender_cd ends.'  from dual
--/
--select 'Updation of changed race begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.race 
from warehouse_person t1 left outer join 
 ( select person_id,
          race
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.race <>nvl(t2.race,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET race=r_update.race
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed race ends.'  from dual
--/
--select 'Updation of changed education level begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.education_level 
from warehouse_person t1 left outer join 
 ( select person_id,
          education_level
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.education_level <>nvl(t2.education_level,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET education_level=r_update.education_level
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed education level ends.'  from dual
--/
--select 'Updation of changed major begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.major 
from warehouse_person t1 left outer join 
 ( select person_id,
          major
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.major <>nvl(t2.major,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET major=r_update.major
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed major ends.'  from dual
--/
--select 'Updation of changed is_handicapped begins.'  from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.is_handicapped 
from warehouse_person t1 left outer join 
 ( select person_id,
          is_handicapped
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.is_handicapped <>nvl(t2.is_handicapped,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET is_handicapped=r_update.is_handicapped
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_handicapped ends.'  from dual
--/
--select 'Updation of changed handicap_type begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.handicap_type 
from warehouse_person t1 left outer join 
 ( select person_id,
          handicap_type
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.handicap_type <>nvl(t2.handicap_type,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET handicap_type=r_update.handicap_type
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed handicap_type ends.' from dual
--/
--select 'Updation of changed is_veteran begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.is_veteran 
from warehouse_person t1 left outer join 
 ( select person_id,
          is_veteran
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.is_veteran <>nvl(t2.is_veteran,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET is_veteran=r_update.is_veteran
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_veteran ends.' from dual
--/
--select 'Updation of changed veteran_type begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.veteran_type 
from warehouse_person t1 left outer join 
 ( select person_id,
          veteran_type
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.veteran_type <>nvl(t2.veteran_type,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET veteran_type=r_update.veteran_type
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed veteran_type ends.' from dual
--/
--select 'Updation of changed visa_code begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.visa_code 
from warehouse_person t1 left outer join 
 ( select person_id,
          visa_code
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.visa_code <>nvl(t2.visa_code,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET visa_code=r_update.visa_code
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed visa_code ends.' from dual
--/
--select 'Updation of changed visa_type begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.visa_type 
from warehouse_person t1 left outer join 
 ( select person_id,
          visa_type
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.visa_type <>nvl(t2.visa_type,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET visa_type=r_update.visa_type
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed visa_type ends.' from dual
--/
--select 'Updation of changed visa_renewal_date begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.visa_renewal_date 
from warehouse_person t1 left outer join 
 ( select person_id,
          visa_renewal_date
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.visa_renewal_date <>t2.visa_renewal_date;
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET visa_renewal_date=r_update.visa_renewal_date
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed visa_renewal_date ends.' from dual
--/
--select 'Updation of changed  has_visa begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.has_visa 
from warehouse_person t1 left outer join 
 ( select person_id,
          has_visa
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.has_visa <>nvl(t2.has_visa,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET has_visa=r_update.has_visa
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed  has_visa ends.' from dual
--/
--select 'Updation of changed office_location begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.office_location 
from warehouse_person t1 left outer join 
 ( select person_id,
          office_location
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.office_location <>nvl(t2.office_location,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET office_location=r_update.office_location
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed office_location ends.' from dual
--/
--select 'Updation of changed office_phone begins.' from dual
--/
DECLARE
li_count number;
ls_phone_number varchar2(20);
cursor c_update is
select t1.person_id,
t1.office_phone,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.PHONE_NBR as office_phone,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_PHONE_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.office_phone <>nvl(t2.office_phone,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

IF r_update.office_phone IS NOT NULL THEN

       SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_PHONE_T WHERE ENTITY_ID=r_update.ENTITY_ID and PHONE_TYP_CD = 'WRK';
	   select replace(translate(r_update.office_phone,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;

       select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) into ls_phone_number from dual;


          IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN

            
               INSERT INTO KRIM_ENTITY_PHONE_T (ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,DFLT_IND,ACTV_IND,LAST_UPDT_DT) 
               VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1,r_update.entity_id,'PERSON' ,'WRK',ls_phone_number,'Y','Y',sysdate);
	   
       
          ELSE
    
                UPDATE KRIM_ENTITY_PHONE_T
                SET PHONE_NBR=ls_phone_number
                WHERE ENTITY_ID=r_update.ENTITY_ID
				AND PHONE_TYP_CD = 'WRK';
       
          END IF;

END IF;       


END LOOP;
CLOSE c_update;
END;
/
commit
/
--
--select 'Updation of changed office_phone ends.' from dual
--/
--select 'Updation of changed secondry_office_location begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.secondry_office_location 
from warehouse_person t1 left outer join 
 ( select person_id,
          secondry_office_location
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.secondry_office_location <>nvl(t2.secondry_office_location,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET secondry_office_location=r_update.secondry_office_location
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
----select 'Updation of changed secondry_office_location ends.' from dual
----/
----select 'Updation of changed secondry_office_phone begins.' from dual
--/
DECLARE
li_count number;
ls_phone_number varchar2(20);
cursor c_update is
select t1.person_id,
t1.secondry_office_phone,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.PHONE_NBR as secondry_office_phone,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_PHONE_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.secondry_office_phone <>nvl(t2.secondry_office_phone,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

IF r_update.secondry_office_phone IS NOT NULL THEN

    SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_PHONE_T WHERE ENTITY_ID=r_update.ENTITY_ID AND PHONE_TYP_CD = 'HM' ;
	select replace(translate(r_update.secondry_office_phone,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;

    select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) into ls_phone_number from dual;


      IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
          
           INSERT INTO KRIM_ENTITY_PHONE_T (ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,DFLT_IND,ACTV_IND,LAST_UPDT_DT) 
           VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1,r_update.entity_id,'PERSON','HM',ls_phone_number,'N','Y',sysdate);
	   
       
    ELSE
    
           UPDATE KRIM_ENTITY_PHONE_T
           SET PHONE_NBR= ls_phone_number
           WHERE ENTITY_ID=r_update.ENTITY_ID
		   AND PHONE_TYP_CD = 'HM';
       
    END IF;

END IF;       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed secondry_office_phone ends.' from dual
--/
--select 'Updation of changed school begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.school 
from warehouse_person t1 left outer join 
 ( select person_id,
          school
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.school <>nvl(t2.school,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET school=r_update.school
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed school ends.' from dual
--/
--select 'Updation of changed year_graduated begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.year_graduated 
from warehouse_person t1 left outer join 
 ( select person_id,
          year_graduated
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.year_graduated <>nvl(t2.year_graduated,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET year_graduated=r_update.year_graduated
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed year_graduated ends.' from dual
--/
--select 'Updation of changed primary_title begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.primary_title 
from warehouse_person t1 left outer join 
 ( select person_id,
          primary_title
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.primary_title <>nvl(t2.primary_title,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET primary_title=r_update.primary_title
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed primary_title ends.' from dual
--/
--select 'Updation of changed directory_title begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.directory_title 
from warehouse_person t1 left outer join 
 ( select person_id,
          directory_title
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.directory_title <>nvl(t2.directory_title,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET directory_title=r_update.directory_title
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed directory_title ends.' from dual
--/
--select 'Updation of changed is_faculty begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.is_faculty,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        DECODE(e.AFLTN_TYP_CD,'FCLTY','Y','STAFF','N') as is_faculty,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.is_faculty <>nvl(t2.is_faculty,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID;

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
       
       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
	   VALUES(KRIM_ENTITY_AFLTN_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,DECODE(r_update.is_faculty,'Y','FCLTY','N','STAFF'),'UN','Y','Y',sysdate);

	   
       
    ELSE
    
       UPDATE KRIM_ENTITY_AFLTN_T
       SET AFLTN_TYP_CD=DECODE(r_update.is_faculty,'Y','FCLTY','N','STAFF'),
	   ACTV_IND=r_update.is_faculty
       WHERE ENTITY_ID=r_update.ENTITY_ID;
       
    END IF;

       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_faculty ends.' from dual
--/
--select 'Updation of changed is_graduate_student_staff begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.is_graduate_student_staff,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        DECODE(AFLTN_TYP_CD,'GRD_STDNT_STAFF','Y','N') is_graduate_student_staff,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.is_graduate_student_staff <>nvl(t2.is_graduate_student_staff,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


     SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID AND AFLTN_TYP_CD='GRD_STDNT_STAFF';

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
      IF r_update.is_graduate_student_staff='Y' THEN
    
       
       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			 VALUES(KRIM_ENTITY_AFLTN_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'GRD_STDNT_STAFF','UN','Y','Y',sysdate);
       
      END IF;

    ELSE
   
       UPDATE KRIM_ENTITY_AFLTN_T
       SET ACTV_IND=r_update.is_graduate_student_staff
       WHERE ENTITY_ID=r_update.ENTITY_ID
       AND AFLTN_TYP_CD='GRD_STDNT_STAFF';
       
    END IF;


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_graduate_student_staff ends.' from dual
--/
--select 'Updation of changed is_research_staff begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.is_research_staff,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        DECODE(AFLTN_TYP_CD,'RSRCH_STAFF','Y','N') is_research_staff,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.is_research_staff <>nvl(t2.is_research_staff,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


     SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID AND AFLTN_TYP_CD='RSRCH_STAFF';

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
      IF r_update.is_research_staff='Y' THEN
    
       
       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			 VALUES(KRIM_ENTITY_AFLTN_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'RSRCH_STAFF','UN','Y','Y',sysdate);
       
      END IF;

    ELSE
   
       UPDATE KRIM_ENTITY_AFLTN_T
       SET ACTV_IND=r_update.is_research_staff
       WHERE ENTITY_ID=r_update.ENTITY_ID
       AND AFLTN_TYP_CD='RSRCH_STAFF';
       
    END IF;


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_research_staff ends.' from dual
--/
--select 'Updation of changed is_service_staff begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.is_service_staff,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        DECODE(AFLTN_TYP_CD,'SRVC_STAFF','Y','N') is_service_staff,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.is_service_staff <>nvl(t2.is_service_staff,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


     SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID AND AFLTN_TYP_CD='SRVC_STAFF';

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
      IF r_update.is_service_staff='Y' THEN
    
       
       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
	   VALUES(KRIM_ENTITY_AFLTN_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'SRVC_STAFF','UN','Y','Y',sysdate);
       
      END IF;

    ELSE
   
       UPDATE KRIM_ENTITY_AFLTN_T
       SET ACTV_IND=r_update.is_service_staff
       WHERE ENTITY_ID=r_update.ENTITY_ID
       AND AFLTN_TYP_CD='SRVC_STAFF';
       
    END IF;


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_service_staff ends.' from dual
--/
--select 'Updation of changed is_support_staff begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.is_support_staff,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        DECODE(AFLTN_TYP_CD,'SUPPRT_STAFF','Y','N') is_support_staff,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.is_support_staff <>nvl(t2.is_support_staff,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


     SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID AND AFLTN_TYP_CD='SUPPRT_STAFF';

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
      IF r_update.is_support_staff='Y' THEN
    
       
       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			 VALUES(KRIM_ENTITY_AFLTN_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'SUPPRT_STAFF','UN','Y','Y',sysdate);
       
      END IF;

    ELSE
   
       UPDATE KRIM_ENTITY_AFLTN_T
       SET ACTV_IND=r_update.is_support_staff
       WHERE ENTITY_ID=r_update.ENTITY_ID
       AND AFLTN_TYP_CD='SUPPRT_STAFF';
       
    END IF;


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_support_staff ends.' from dual
--/
--select 'Updation of changed IS_OTHER_ACCADEMIC_GROUP begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.IS_OTHER_ACCADEMIC_GROUP,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        DECODE(AFLTN_TYP_CD,'OTH_ACADMC_GRP','Y','N') IS_OTHER_ACCADEMIC_GROUP,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.IS_OTHER_ACCADEMIC_GROUP <>nvl(t2.IS_OTHER_ACCADEMIC_GROUP,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


     SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID AND AFLTN_TYP_CD='OTH_ACADMC_GRP';

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
      IF r_update.IS_OTHER_ACCADEMIC_GROUP='Y' THEN
    
       
       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			 VALUES(KRIM_ENTITY_AFLTN_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'OTH_ACADMC_GRP','UN','Y','Y',sysdate);
       
      END IF;

    ELSE
   
       UPDATE KRIM_ENTITY_AFLTN_T
       SET ACTV_IND=r_update.IS_OTHER_ACCADEMIC_GROUP
       WHERE ENTITY_ID=r_update.ENTITY_ID
       AND AFLTN_TYP_CD='OTH_ACADMC_GRP';
       
    END IF;


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed IS_OTHER_ACCADEMIC_GROUP ends.' from dual
--/
--select 'Updation of changed is_medical_staff begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.is_medical_staff,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        DECODE(AFLTN_TYP_CD,'MED_STAFF','Y','N') is_medical_staff,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
 where t1.is_medical_staff <>nvl(t2.is_medical_staff,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


     SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID AND AFLTN_TYP_CD='MED_STAFF';

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
      IF r_update.is_medical_staff='Y' THEN
    
       
       INSERT INTO KRIM_ENTITY_AFLTN_T(ENTITY_AFLTN_ID,OBJ_ID,VER_NBR,ENTITY_ID,AFLTN_TYP_CD,CAMPUS_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
			 VALUES(KRIM_ENTITY_AFLTN_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'MED_STAFF','UN','Y','Y',sysdate);
       
      END IF;

    ELSE
   
       UPDATE KRIM_ENTITY_AFLTN_T
       SET ACTV_IND=r_update.is_medical_staff
       WHERE ENTITY_ID=r_update.ENTITY_ID
       AND AFLTN_TYP_CD='MED_STAFF';
       
    END IF;


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_medical_staff ends.' from dual
--/
--select 'Updation of changed home_unit begins.' from dual
--/
DECLARE
li_count number;
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.home_unit,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.PRMRY_DEPT_CD as home_unit,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_EMP_INFO_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
		where t1.home_unit <>nvl(t2.home_unit,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;

IF r_update.home_unit IS NOT NULL THEN
    SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_EMP_INFO_T WHERE ENTITY_ID=r_update.ENTITY_ID;

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
       SELECT MAX(ENTITY_AFLTN_ID) INTO li_seq_entity_afltn_id FROM KRIM_ENTITY_AFLTN_T WHERE ENTITY_ID=r_update.ENTITY_ID;
       
       INSERT INTO KRIM_ENTITY_EMP_INFO_T(ENTITY_EMP_ID,OBJ_ID,VER_NBR,ENTITY_ID,EMP_STAT_CD,EMP_TYP_CD,PRMRY_DEPT_CD,ENTITY_AFLTN_ID,ACTV_IND,PRMRY_IND,EMP_ID,LAST_UPDT_DT) 
       VALUES(KRIM_ENTITY_EMP_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'A','O',r_update.home_unit,li_seq_entity_afltn_id,'Y','Y',r_update.person_id,sysdate);

	   
       
    ELSE
    
       UPDATE KRIM_ENTITY_EMP_INFO_T
       SET PRMRY_DEPT_CD=r_update.home_unit
       WHERE ENTITY_ID=r_update.ENTITY_ID;
       
    END IF;
END IF;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed home_unit ends.' from dual
--/
--select 'Updation of changed vacation_accural begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.vacation_accural 
from warehouse_person t1 left outer join 
 ( select person_id,
          vacation_accural
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.vacation_accural <>nvl(t2.vacation_accural,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET school=r_update.vacation_accural
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed vacation_accural ends.' from dual
--/
--select 'Updation of changed is_on_sabbatical begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.is_on_sabbatical 
from warehouse_person t1 left outer join 
 ( select person_id,
          is_on_sabbatical
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.is_on_sabbatical <>nvl(t2.is_on_sabbatical,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET school=r_update.is_on_sabbatical
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed is_on_sabbatical ends.' from dual
--/
--select 'Updation of changed id_provided begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.id_provided 
from warehouse_person t1 left outer join 
 ( select person_id,
          id_provided
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.id_provided <>nvl(t2.id_provided,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET school=r_update.id_provided
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed id_provided ends.' from dual
--/
--select 'Updation of changed id_verified begins.' from dual
--/
DECLARE
li_count number;
cursor c_update is
select t1.person_id,
t1.id_verified 
from warehouse_person t1 left outer join 
 ( select person_id,
          id_verified
        from   PERSON_EXT_T ) t2 on t1.person_id = t2.person_id
 where t1.id_verified <>nvl(t2.id_verified,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       
	     UPDATE PERSON_EXT_T
       SET school=r_update.id_verified
       WHERE person_id=r_update.person_id;
       


END LOOP;
CLOSE c_update;
END;
/
--select 'Updation of changed id_verified ends.' from dual
--/
--select 'Updation of changed address_line2 begins.' from dual
--/
DECLARE
li_count number;
li_country_cd varchar2(2);
li_seq_entity_afltn_id NUMBER(12,0);
cursor c_update is
select t1.person_id,
t1.OFFICE_LOCATION as ADDRESS_LINE_2,
(select p.entity_id from krim_prncpl_t p where p.prncpl_id= t1.person_id) as entity_id
from warehouse_person t1 left outer join 
 ( select p.prncpl_id as person_id,
        e.ADDR_LINE_2 as ADDRESS_LINE_2,
        e.entity_id
        from KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_ADDR_T e ON p.entity_id=e.entity_id) t2 on t1.person_id = t2.person_id
		where t1.OFFICE_LOCATION <> nvl(t2.ADDRESS_LINE_2,0);
r_update c_update%ROWTYPE;

BEGIN
IF c_update%ISOPEN THEN
CLOSE c_update;
END IF;
OPEN c_update;
LOOP
FETCH c_update INTO r_update;
EXIT WHEN c_update%NOTFOUND;


       begin
           select POSTAL_CNTRY_CD into li_country_cd from KRLC_CNTRY_T where upper(ALT_POSTAL_CNTRY_CD) = 'USA';
        exception
        when others then
         li_country_cd := null;
        end;


     SELECT COUNT(ENTITY_ID) INTO li_count  FROM KRIM_ENTITY_ADDR_T WHERE ENTITY_ID=r_update.ENTITY_ID AND ADDR_TYP_CD = 'WRK';

    IF li_count=0 AND r_update.ENTITY_ID IS NOT NULL THEN
    
           INSERT INTO KRIM_ENTITY_ADDR_T(ENTITY_ADDR_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,ADDR_TYP_CD,ADDR_LINE_1,ADDR_LINE_2,ADDR_LINE_3,CITY,STATE_PVC_CD,POSTAL_CD,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT) 
           VALUES(KRIM_ENTITY_ADDR_ID_S.NEXTVAL,SYS_GUID(),1,r_update.ENTITY_ID,'PERSON','WRK','77 Massachusetts Ave.',SUBSTRB(r_update.ADDRESS_LINE_2,1,45),null,'Cambridge','MA','021394307',li_country_cd,'Y','Y',sysdate);
       


    ELSE
   
       UPDATE KRIM_ENTITY_ADDR_T
       SET ADDR_LINE_2=SUBSTRB(r_update.ADDRESS_LINE_2,1,45)
       WHERE ENTITY_ID=r_update.ENTITY_ID
	   AND ADDR_TYP_CD = 'WRK';
       
    END IF;


END LOOP;
CLOSE c_update;
END;
/
commit
/
--select 'Updation of changed address_line2 ends.' from dual
--/
--select 'Updation of changed primary_dept_cd begins.' from dual
--/
update KRIM_ENTITY_EMP_INFO_T
set PRMRY_DEPT_CD = '999999'
where PRMRY_DEPT_CD is null
/
commit
/
--select 'Updation of changed primary_dept_cd ends.' from dual
--/
--select 'Updation of changed AWARD_PERSONS begins.' from dual
--/
create table temp_full_name as
select p.prncpl_id, (case 
when e.last_nm is null then 
e.first_nm||' '||e.middle_nm
when e.middle_nm is null then
e.last_nm||', '|| e.first_nm
when e.middle_nm is null and e.first_nm is null then
e.last_nm
when e.last_nm is null and e.middle_nm is null  then 
e.first_nm
else
e.last_nm||', '|| e.first_nm||' '||e.middle_nm 
END) as full_name
from KRIM_PRNCPL_T p,KRIM_ENTITY_NM_T e
where p.entity_id= e.entity_id
/
drop   table temp
/
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,AWARD_PERSONS a
where t.prncpl_id = a.person_id
and a.ROLODEX_ID is NULL and
trim(a.FULL_NAME) <> trim(t.full_name)
/
update AWARD_PERSONS x
set FULL_NAME =(select full_name
                 from   temp
                 where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
--select 'Updation of changed AWARD_PERSONS ends.' from dual
--/
--select 'Updation of changed AWARD_APPROVED_FOREIGN_TRAVEL begins.' from dual
--/
drop   table temp
/
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,AWARD_APPROVED_FOREIGN_TRAVEL a
where  t.prncpl_id = a.person_id and 
trim(a.TRAVELER_NAME) <> trim(t.full_name)
/
update AWARD_APPROVED_FOREIGN_TRAVEL x
set TRAVELER_NAME = (select full_name
                 from   temp
                  where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
--select 'Updation of changed AWARD_APPROVED_FOREIGN_TRAVEL ends.' from dual
--/
--select 'Updation of changed PROPOSAL_PERSONS begins.' from dual
--/
drop   table temp
/
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,PROPOSAL_PERSONS pp
where  t.prncpl_id = pp.person_id and 
pp.rolodex_id is null and
trim(pp.full_name) <> trim(t.full_name)
/
update PROPOSAL_PERSONS x
set full_name = (select full_name
                 from   temp
                  where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
--select 'Updation of changed PROPOSAL_PERSONS ends.' from dual
--/
--select 'Updation of changed EPS_PROP_PERSON begins.' from dual
--/
drop   table temp
/
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,EPS_PROP_PERSON ep
where  t.prncpl_id=ep.person_id and 
ep.rolodex_id is null and
trim(ep.full_name) <> trim(t.full_name)
/
update EPS_PROP_PERSON x
set full_name = (select full_name
                 from   temp
                 where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
--select 'Updation of changed EPS_PROP_PERSON ends.' from dual
--/
--select 'Updation of changed PROPOSAL_LOG begins.' from dual
--/
drop   table temp
/
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,PROPOSAL_LOG pl
where  t.prncpl_id = pl.pi_id
and pl.ROLODEX_ID is null and
trim(pl.pi_name) <> trim(t.full_name)
/
update PROPOSAL_LOG x
set pi_name = (select full_name
                 from   temp
                 where  person_id= x.pi_id)
where pi_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
drop table temp_full_name
/
--select 'Updation of changed PROPOSAL_LOG ends.' from dual
--/
select 'Purge all rows from  warehouse_appointment ' from dual
/
delete from warehouse_appointment
/
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
select 'Purge all rows from  PERSON_APPOINTMENT ' from dual
/
delete from PERSON_APPOINTMENT
where person_id < '999999978'
/
commit
/
select 'Populate PERSON_APPOINTMENT from warehouse_appointment ' from dual
/
insert into PERSON_APPOINTMENT
( APPOINTMENT_ID,
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
select
SEQ_PERSON_APPOINTMENT.NEXTVAL,
 PERSON_ID,                         
 UNIT_NUMBER,                           
 APPOINTMENT_START_DATE,                     
 APPOINTMENT_END_DATE,                    
 decode(ltrim(rtrim(APPOINTMENT_TYPE)), '11 Months', '5', '12 Months', '6', '9 Months', '3', 'Temporary (< 12 months)', '1', 'Term (=> 12 months)', '7', NULL) ,                      
 JOB_TITLE,
 PREFERED_JOB_TITLE,
 decode(substr(JOB_CODE, 3, 1), '-', SUBSTR(JOB_CODE, 4), JOB_CODE),
 NULL,
 SYSDATE,
 USER,
 1,
SYS_GUID()
FROM warehouse_appointment                   
/
commit
/
update PERSON_APPOINTMENT
set APPOINTMENT_TYPE_CODE = '7'
where APPOINTMENT_TYPE_CODE is null
/
commit
/
delete from WAREHOUSE_DEGREE
/
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
delete from PERSON_DEGREE
where update_user = 'KCSO'
/
insert into PERSON_DEGREE 
select SEQ_PERSON_DEGREE.NEXTVAL, 
d.PERSON_ID,
extract(year from d.GRADUATION_DATE),
decode(m.grantsdotgov_degree_code, NULL, 'UKNW',   m.grantsdotgov_degree_code),
d.DEGREE   ,      
d.FIELD_OF_STUDY ,
d.SPECIALIZATION, 
d.SCHOOL,         
2,
d.SCHOOL_ID,
sysdate,
user ,
1,
sys_guid()
from PERSON_EXT_T p, warehouse_degree d, warehouse_degree_type_mapping m
where p.person_id = d.person_id and d.degree_code = m.warehouse_degree_code (+)
/
commit
/
select 'Person_feed Completed.' from dual
/
exit;
