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
/
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
 UPDATE_USER
)                    
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
 CP.IS_VETERAN ,                     
 CP.VETERAN_TYPE,                   
 CP.VISA_CODE,                      
 CP.VISA_TYPE,                      
 CP.VISA_RENEWAL_DATE,              
 CP.HAS_VISA,                       
 CP.OFFICE_LOCATION,                
 CP.OFFICE_PHONE,                   
 CP.SECONDRY_OFFICE_LOCATION,     
 CP.SECONDRY_OFFICE_PHONE,         
 CP.SCHOOL,                         
 CP.YEAR_GRADUATED,                 
-- INITCAP(DIRECTORY_DEPARTMENT),           
 null,
 CP.SALUTATION,                     
 CP.COUNTRY_OF_CITIZENSHIP,         
 CP.PRIMARY_TITLE,                  
 CP.DIRECTORY_TITLE,                
 CP.HOME_UNIT,              
 CP.IS_FACULTY,                     
 CP.IS_GRADUATE_STUDENT_STAFF,   
 null,   
 CP.IS_SERVICE_STAFF,               
 CP.IS_SUPPORT_STAFF,               
 CP.IS_OTHER_ACCADEMIC_GROUP,        
 CP.IS_MEDICAL_STAFF,               
 CP.VACATION_ACCURAL,               
 CP.IS_ON_SABBATICAL,                
 CP.ID_PROVIDED,                    
 CP.ID_VERIFIED,
 SYSDATE,
 USER
 FROM TEST_PERSON_FEED cp,
     TEST_KRB_PERSON kp
 WHERE CP.MIT_ID = KP.MIT_ID (+)            
/
commit
/
rem
rem ** Dont have to worry about duplicates any more
rem ** new view in warehouse have taken care of duplicates
rem
--select 'Deleting Duplicates from warehouse_person ' from dual
--/
rem
rem Delete Duplicates from warehouse_person
rem
rem
--delete
--from warehouse_person
--where person_id in (
--select person_id
--from warehouse_person
--group by person_id 
--having count(person_id) > 1) and
--rowid not in (select  rowid from warehouse_person p
--where p.person_id = warehouse_person.person_id and 
--rownum = 1)
--/
rem
rem
rem  insert into person tables in kc if there is any new rows
rem
rem
select 'Inserting new rows into kcperson tables'  from dual
/
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
ls_suppress_email_ind VARCHAR2(1):='Y';
ls_suppress_addr_ind VARCHAR2(1):='Y';
ls_suppress_phone_ind VARCHAR2(1):='Y';
ls_suppress_prsnl_ind VARCHAR2(1):='Y';
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
ls_phone_number varchar2(20);
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
 '02139' POSTAL_CODE,
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
FOLLOWUP_DATE,SCORE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER  from  OSP$PERSON_TRAINING@coeus.kuali where PERSON_ID=para_personID;   
r_perT c1_data%ROWTYPE;

BEGIN
    IF c_pers%ISOPEN THEN
      CLOSE c_pers;
    END IF;
    OPEN c_pers;
    LOOP
    FETCH c_pers INTO r_pers;
    EXIT WHEN c_pers%NOTFOUND;
    
    select KRIM_ENTITY_ID_S.NEXTVAL into li_seq_entity_id from dual;          
    select KRIM_ENTITY_EMP_ID_S.NEXTVAL into li_seq_entity_emp_id from dual; 
    select KRIM_ENTITY_NM_ID_S.NEXTVAL into li_seq_entity_nm_id from dual;
    
    INSERT INTO KRIM_ENTITY_T(ENTITY_ID,OBJ_ID,VER_NBR,ACTV_IND,LAST_UPDT_DT) 
    VALUES( li_seq_entity_id,SYS_GUID(),li_ver_nbr,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);


    begin
            select KREW_DOC_HDR_S.NEXTVAL into li_seq_fdoc_nbr from dual;

            INSERT INTO KRIM_PERSON_DOCUMENT_T(FDOC_NBR,ENTITY_ID,OBJ_ID,VER_NBR,PRNCPL_ID,PRNCPL_NM,PRNCPL_PSWD,UNIV_ID,ACTV_IND)
            VALUES(li_seq_fdoc_nbr,li_seq_entity_id,SYS_GUID(),li_ver_nbr,r_pers.person_id,lower(r_pers.USER_NAME),NULL,NULL,decode(r_pers.status,'A','Y','N'));

            INSERT INTO KRIM_PRNCPL_T(PRNCPL_ID,OBJ_ID,VER_NBR,PRNCPL_NM,ENTITY_ID,PRNCPL_PSWD,ACTV_IND,LAST_UPDT_DT)
            VALUES(r_pers.person_id,SYS_GUID(),li_ver_nbr,lower(r_pers.USER_NAME),li_seq_entity_id,NULL,decode(r_pers.status,'A','Y','N'),r_pers.UPDATE_TIMESTAMP);

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
    dbms_output.put_line('Error occoured for KRIM_ENTITY_AFLTN_T  for the person '||r_pers.person_id);
    END;


    BEGIN
      INSERT INTO KRIM_ENTITY_ENT_TYP_T(ENT_TYP_CD,ENTITY_ID,ACTV_IND,OBJ_ID,VER_NBR,LAST_UPDT_DT) 
      VALUES(ls_ent_typ_cd,li_seq_entity_id,ls_actv_ind,SYS_GUID(),li_ver_nbr,r_pers.UPDATE_TIMESTAMP);   
    EXCEPTION
    WHEN OTHERS THEN 
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
				             select replace(translate(r_pers.SECONDRY_OFFICE_PHONE,'.+*/\()x ','---------'),'-') into ls_phone_number from dual;

                     select substr(ls_phone_number,1,3)||'-'||substr(ls_phone_number,4,3)||'-'||substr(ls_phone_number,7,4) into ls_phone_number from dual; 				
				             INSERT INTO KRIM_ENTITY_PHONE_T(ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR,PHONE_EXTN_NBR,POSTAL_CNTRY_CD,DFLT_IND,ACTV_IND,LAST_UPDT_DT)
				             VALUES(li_seq_entity_phn_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_ent_typ_cd,ls_phn_code,ls_phone_number,NULL,NULL,ls_dflt_ind,ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
				             ls_dflt_ind:='N';     
		          END IF;

          EXCEPTION
          WHEN OTHERS THEN 
          dbms_output.put_line('Error occoured for KRIM_ENTITY_PHONE_T OR KRIM_PHONE_TYP_T  for the person '||r_pers.person_id); 
          END;  

          IF r_pers.EMAIL_ADDRESS IS NOT NULL THEN

             BEGIN

                  select KRIM_ENTITY_EMAIL_ID_S.NEXTVAL into li_seq_entity_email_id from dual;
                  INSERT INTO KRIM_ENTITY_EMAIL_T(ENTITY_EMAIL_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,EMAIL_TYP_CD,EMAIL_ADDR,DFLT_IND,ACTV_IND,LAST_UPDT_DT) 
                  VALUES(li_seq_entity_email_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,ls_ent_typ_cd,'WRK',r_pers.EMAIL_ADDRESS,'Y',ls_actv_ind,r_pers.UPDATE_TIMESTAMP);
              EXCEPTION
              WHEN OTHERS THEN 
                  dbms_output.put_line('Error occoured for KRIM_ENTITY_EMAIL_T  for the person '||r_pers.person_id); 
              END;   

           END IF;  

           BEGIN   
              INSERT INTO KRIM_ENTITY_NM_T(ENTITY_NM_ID,OBJ_ID,VER_NBR,ENTITY_ID,NM_TYP_CD,FIRST_NM,MIDDLE_NM,LAST_NM,SUFFIX_NM,TITLE_NM,DFLT_IND,ACTV_IND,LAST_UPDT_DT,PREFIX_NM,NOTE_MSG,NM_CHNG_DT)  
              VALUES(li_seq_entity_nm_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,'PRFR',r_pers.FIRST_NAME,r_pers.MIDDLE_NAME,r_pers.LAST_NAME,NULL,NULL,'Y',ls_actv_ind,r_pers.UPDATE_TIMESTAMP,NULL,NULL,NULL);

           EXCEPTION
           WHEN OTHERS THEN 
           dbms_output.put_line('Error occoured for KRIM_ENTITY_NM_T  for the person '||r_pers.person_id); 
           END;     

            ls_person_id:=r_pers.person_id;
            BEGIN
               INSERT INTO KRIM_ENTITY_EMP_INFO_T(ENTITY_EMP_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENTITY_AFLTN_ID,EMP_STAT_CD,EMP_TYP_CD,BASE_SLRY_AMT,PRMRY_IND,ACTV_IND,PRMRY_DEPT_CD,EMP_ID,EMP_REC_ID,LAST_UPDT_DT) 
               VALUES(li_seq_entity_emp_id,SYS_GUID(),li_ver_nbr,li_seq_entity_id,li_seq_entity_afltn_id,r_pers.STATUS,'O',0.00,'Y',ls_actv_ind,r_pers.home_unit,ls_person_id,'1',r_pers.UPDATE_TIMESTAMP);

-- END IF;
            EXCEPTION
            WHEN OTHERS THEN 
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
                 dbms_output.put_line('Error occoured for PERSON_EXT_T  for the person '||r_pers.person_id);        
             END; 

             BEGIN
               INSERT INTO KRIM_ENTITY_BIO_T(ENTITY_ID,DECEASED_DT,MARITAL_STATUS,PRIM_LANG_CD,SEC_LANG_CD,BIRTH_CNTRY_CD,BIRTH_STATE_PVC_CD,BIRTH_CITY,GEO_ORIGIN,OBJ_ID,VER_NBR,BIRTH_DT,GNDR_CD,LAST_UPDT_DT,NOTE_MSG,GNDR_CHG_CD) 
               VALUES(li_seq_entity_id,NULL,NULL,NULL,NULL,NULL,r_pers.STATE,r_pers.CITY,NULL,SYS_GUID(),li_ver_nbr,r_pers.DATE_OF_BIRTH,NVL2(r_pers.GENDER,SUBSTRB(r_pers.GENDER,1,1),' '),r_pers.UPDATE_TIMESTAMP,NULL,NULL);
             EXCEPTION
             WHEN OTHERS THEN 
                  dbms_output.put_line('Error occoured for KRIM_ENTITY_BIO_T  for the person '||r_pers.person_id);        
             END; 

             BEGIN
               INSERT INTO KRIM_ENTITY_PRIV_PREF_T(ENTITY_ID,OBJ_ID,VER_NBR,SUPPRESS_NM_IND,SUPPRESS_EMAIL_IND,SUPPRESS_ADDR_IND,SUPPRESS_PHONE_IND,SUPPRESS_PRSNL_IND,LAST_UPDT_DT) 
               VALUES(li_seq_entity_id,SYS_GUID(),li_ver_nbr,ls_suppress_nm_ind,ls_suppress_email_ind,ls_suppress_addr_ind,ls_suppress_phone_ind,ls_suppress_prsnl_ind,r_pers.UPDATE_TIMESTAMP);

             EXCEPTION
             WHEN OTHERS THEN 
                 dbms_output.put_line('Error occoured for KRIM_ENTITY_PRIV_PREF_T for the person '||r_pers.person_id);        
             END;

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
rem
rem
rem  update any data that may have changed for rows of
rem  data already included in osp$person
rem
rem  for performance, a temporary table is created and
rem  dropped at each comparison
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
(select person_id,
        last_name,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        e.last_nm as last_name,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_NM_T e ON p.entity_id=e.entity_id)
/
rem
/*update KRIM_ENTITY_NM_T x
set last_nm = (select last_name
                 from   temp
                 where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
*/
MERGE INTO KRIM_ENTITY_NM_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	last_nm   = b.last_name       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_NM_ID,OBJ_ID,VER_NBR,ENTITY_ID,NM_TYP_CD,LAST_NM,DFLT_IND,ACTV_IND,LAST_UPDT_DT)  
VALUES(KRIM_ENTITY_NM_ID_S.NEXTVAL,SYS_GUID(),1,b.entity_id,'PRFR',b.last_name,'Y','Y',sysdate)
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
(select person_id,
        first_name,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        e.first_nm as first_name,
        e.entity_id
 from    KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_NM_T e ON p.entity_id=e.entity_id)
/
rem
/* update KRIM_ENTITY_NM_T x
set first_nm = (select first_name
                 from   temp
                  where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
*/
MERGE INTO KRIM_ENTITY_NM_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	first_nm   = b.first_name       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_NM_ID,OBJ_ID,VER_NBR,ENTITY_ID,NM_TYP_CD,first_nm,DFLT_IND,ACTV_IND,LAST_UPDT_DT)  
VALUES(KRIM_ENTITY_NM_ID_S.NEXTVAL,SYS_GUID(),1,b.entity_id,'PRFR',b.first_name,'Y','Y',sysdate)
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
(select person_id,
        middle_name,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        e.middle_nm as middle_name,
        e.entity_id
 from    KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_NM_T e ON p.entity_id=e.entity_id)
/
rem
/* update KRIM_ENTITY_NM_T x
set middle_nm = (select middle_name
                 from   temp
                 where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
*/
MERGE INTO KRIM_ENTITY_NM_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	middle_nm   = b.middle_name       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_NM_ID,OBJ_ID,VER_NBR,ENTITY_ID,NM_TYP_CD,middle_nm,DFLT_IND,ACTV_IND,LAST_UPDT_DT)  
VALUES(KRIM_ENTITY_NM_ID_S.NEXTVAL,SYS_GUID(),1,b.entity_id,'PRFR',b.middle_name,'Y','Y',sysdate)
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
(select person_id,
        user_name
 from   warehouse_person
 minus
 select PRNCPL_ID as person_id,
        PRNCPL_NM as user_name
 from   KRIM_PRNCPL_T)
/
rem
update KRIM_PRNCPL_T x
set PRNCPL_NM = (select user_name
                 from   temp
                 where  person_id = x.prncpl_id)
where prncpl_id in (select person_id
                            from   temp)
/
commit
/
drop   table temp
/
rem
create table temp
as
(select  person_id,
        user_name
 from   warehouse_person
 minus
 select PRNCPL_ID as person_id,
        PRNCPL_NM as user_name
 from   KRIM_PERSON_DOCUMENT_T)
/
rem
update KRIM_PERSON_DOCUMENT_T x
set PRNCPL_NM = (select user_name
                 from   temp
                 where  person_id = x.prncpl_id)
where prncpl_id in (select person_id
                            from   temp)
/
commit
/
rem
rem Set User_name to null
rem
select 'Set user_name as NULL for all incative people.' from dual
/
--rem  Call the function fn_set_username_null_pfeed to generate emails with list of 
--rem persons whose user_names should be set to NULL
--rem This function will also update user_name column in osp$person table
--var li_ret number;
--exec :li_ret := fn_set_username_null_pfeed('coeus-dev-team@mit.edu', 'Coeus Person Feed Kerberos ID cleanup ** Production **');
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
(select person_id,
        email_address,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        EMAIL_ADDR as email_address,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_EMAIL_T e ON p.entity_id=e.entity_id)
/
rem
MERGE INTO KRIM_ENTITY_EMAIL_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	EMAIL_ADDR   = b.email_address       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_EMAIL_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,EMAIL_TYP_CD,EMAIL_ADDR,DFLT_IND,ACTV_IND,LAST_UPDT_DT) 
VALUES(KRIM_ENTITY_EMAIL_ID_S.NEXTVAL,SYS_GUID(),1,b.entity_id,'PERSON','WRK',b.email_address,'Y','Y',sysdate)
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
(select person_id,
        date_of_birth,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as  person_id,
        e.BIRTH_DT as date_of_birth,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_BIO_T e ON p.entity_id=e.entity_id)
/
rem
/*update KRIM_ENTITY_BIO_T x
set BIRTH_DT = (select date_of_birth
                 from   temp
                 where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
*/
MERGE INTO KRIM_ENTITY_BIO_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	BIRTH_DT   = b.date_of_birth       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_ID,OBJ_ID,VER_NBR,BIRTH_DT,GNDR_CD,LAST_UPDT_DT) 
VALUES(b.entity_id,SYS_GUID(),1,b.date_of_birth ,' ',sysdate)
/
commit
/
rem
rem	 Sync age
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
(select person_id,
        age_by_fiscal_year
 from   warehouse_person
 minus
 select person_id,
        age_by_fiscal_year
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set age_by_fiscal_year = (select age_by_fiscal_year
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        gender,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        GNDR_CD as gender,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_BIO_T e ON p.entity_id=e.entity_id)
/
rem
/*update KRIM_ENTITY_BIO_T x
set GNDR_CD = (select gender
                 from   temp
                  where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
*/
MERGE INTO KRIM_ENTITY_BIO_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	GNDR_CD   = NVL2(b.gender,SUBSTR(b.gender,1,1),' ')       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_ID,OBJ_ID,VER_NBR,GNDR_CD,LAST_UPDT_DT) 
VALUES(b.entity_id,SYS_GUID(),1,NVL2(b.gender,SUBSTR(b.gender,1,1),' '),sysdate)
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
(select person_id,
        race
 from   warehouse_person
 minus
 select person_id,
        race
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set race = (select race
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        education_level
 from   warehouse_person
 minus
 select person_id,
        education_level
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set education_level = (select education_level
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        major
 from   warehouse_person
 minus
 select person_id,
        major
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set major = (select major
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        is_handicapped
 from   warehouse_person
 minus
 select person_id,
        is_handicapped
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set is_handicapped = (select is_handicapped
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        handicap_type
 from   warehouse_person
 minus
 select person_id,
        handicap_type
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set handicap_type = (select handicap_type
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        is_veteran
 from   warehouse_person
 minus
 select person_id,
        is_veteran
 from   PERSON_EXT_T)
/
update PERSON_EXT_T x
set is_veteran = (select is_veteran
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        veteran_type
 from   warehouse_person
 minus
 select person_id,
        veteran_type
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set veteran_type = (select veteran_type
                 from   temp
                 where  person_id= x.person_id)
where person_id in (select person_id
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
(select person_id,
        visa_code
 from   warehouse_person
 minus
 select person_id,
        visa_code
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set visa_code = (select visa_code
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        visa_type
 from   warehouse_person
 minus
 select person_id,
        visa_type
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set visa_type = (select visa_type
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        visa_renewal_date
 from   warehouse_person
 minus
 select person_id,
        visa_renewal_date
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set visa_renewal_date = (select visa_renewal_date
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        has_visa
 from   warehouse_person
 minus
 select person_id,
        has_visa
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set has_visa = (select has_visa
                 from   temp
                 where  person_id= x.person_id)
where person_id in (select person_id
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
(select person_id,
        office_location
 from   warehouse_person
 minus
 select person_id,
        office_location
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set office_location = (select office_location
                 from   temp
                 where  person_id= x.person_id)
where person_id in (select person_id
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
(select person_id,
        office_phone,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        e.PHONE_NBR as office_phone,
        e.entity_id
 from    KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_PHONE_T e ON p.entity_id=e.entity_id)
/
rem
/*update KRIM_ENTITY_PHONE_T x
set PHONE_NBR = (select office_phone
                 from   temp
                 where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
*/
MERGE INTO KRIM_ENTITY_PHONE_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	PHONE_NBR   = b.office_phone       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR) 
VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1,b.entity_id,'PERSON' ,'WRK',b.office_phone)
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
(select person_id,
        secondry_office_location
 from   warehouse_person
 minus
 select person_id,
        secondry_office_location
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set secondry_office_location = (select secondry_office_location
                 from   temp
                 where person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        secondry_office_phone,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        e.PHONE_NBR as secondry_office_phone,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_PHONE_T e ON p.entity_id=e.entity_id)
/
rem
/*update KRIM_ENTITY_PHONE_T x
set PHONE_NBR = (select secondry_office_phone
                 from   temp
                 where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
*/
MERGE INTO KRIM_ENTITY_PHONE_T a
USING temp b
ON (a.entity_id = b.entity_id)
WHEN MATCHED THEN
  UPDATE SET
	PHONE_NBR   = b.secondry_office_phone       
WHEN NOT MATCHED THEN  
INSERT (ENTITY_PHONE_ID,OBJ_ID,VER_NBR,ENTITY_ID,ENT_TYP_CD,PHONE_TYP_CD,PHONE_NBR) 
VALUES(KRIM_ENTITY_PHONE_ID_S.NEXTVAL,SYS_GUID(),1,b.entity_id,'PERSON' ,'WRK',b.secondry_office_phone)
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
(select person_id,
        school
 from   warehouse_person
 minus
 select person_id,
        school
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set school = (select school
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        year_graduated
 from   warehouse_person
 minus
 select person_id,
        year_graduated
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set year_graduated = (select year_graduated
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
rem	 Sync primary_title
rem
select 'Sync primary_title.' from dual
/
drop   table temp
/
rem
create table temp
as
(select person_id,
        primary_title
 from   warehouse_person
 minus
 select person_id,
        primary_title
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set primary_title = (select primary_title
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        directory_title
 from   warehouse_person
 minus
 select person_id,
        directory_title
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set directory_title = (select directory_title
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        home_unit,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        e.PRMRY_DEPT_CD as home_unit,
        e. entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_EMP_INFO_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_EMP_INFO_T x
set PRMRY_DEPT_CD = (select home_unit
                 from   temp
                 where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
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
(select person_id,
        is_faculty,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        DECODE(AFLTN_TYP_CD,'FCLTY','Y','STAFF','N') as is_faculty,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id)
/

rem
update KRIM_ENTITY_AFLTN_T x
set AFLTN_TYP_CD = (select DECODE(is_faculty,'Y','FCLTY','N','STAFF') is_faculty
                 from   temp
                  where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
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
(select person_id,
        is_graduate_student_staff,
		(select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id,
        DECODE(AFLTN_TYP_CD,'GRD_STDNT_STAFF','Y') is_graduate_student_staff,
		e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_AFLTN_T x
set ACTV_IND = 'N'
where entity_id in (select entity_id
                            from   temp)
 and AFLTN_TYP_CD='GRD_STDNT_STAFF'                           
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
(select person_id,
        is_research_staff
 from   warehouse_person
 minus
 select person_id,
        is_research_staff
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set is_research_staff = (select is_research_staff
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
                            from   temp)
/
commit
/
drop   table temp
/
rem
create table temp
as
(select person_id,
        is_research_staff,
		(select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id,
        DECODE(AFLTN_TYP_CD,'RSRCH_STAFF','Y') is_research_staff,
		e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_AFLTN_T x
set ACTV_IND = 'N'
where entity_id in (select entity_id
                            from   temp)
and AFLTN_TYP_CD='RSRCH_STAFF'                           
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
(select person_id,
        is_service_staff,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id,
       DECODE(AFLTN_TYP_CD,'SRVC_STAFF','Y') is_service_staff,
		e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_AFLTN_T x
set ACTV_IND = 'N'
where entity_id in (select entity_id
                            from   temp)
and AFLTN_TYP_CD='SRVC_STAFF'
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
(select person_id,
        is_support_staff,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id,
       DECODE(AFLTN_TYP_CD,'SUPPRT_STAFF','Y') is_support_staff,
		e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_AFLTN_T x
set ACTV_IND = 'N'
where entity_id in (select entity_id
                            from   temp)
and AFLTN_TYP_CD='SUPPRT_STAFF'
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
(select person_id,
        IS_OTHER_ACCADEMIC_GROUP,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id,
       DECODE(AFLTN_TYP_CD,'OTH_ACADMC_GRP','Y') IS_OTHER_ACCADEMIC_GROUP,
		e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_AFLTN_T x
set ACTV_IND = 'N'
where entity_id in (select entity_id
                            from   temp)
and AFLTN_TYP_CD='OTH_ACADMC_GRP'
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
(select person_id,
        is_medical_staff,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id,
       DECODE(AFLTN_TYP_CD,'MED_STAFF','Y') IS_OTHER_ACCADEMIC_GROUP,
		e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_AFLTN_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_AFLTN_T x
set ACTV_IND = 'N'
where entity_id in (select entity_id
                            from   temp)
and AFLTN_TYP_CD='MED_STAFF'
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
(select person_id,
        vacation_accural
 from   warehouse_person
 minus
 select person_id,
        vacation_accural
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set vacation_accural = (select vacation_accural
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        is_on_sabbatical
 from   warehouse_person
 minus
 select person_id,
        is_on_sabbatical
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set is_on_sabbatical = (select is_on_sabbatical
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        id_provided
 from   warehouse_person
 minus
 select person_id,
        id_provided
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set id_provided = (select id_provided
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        id_verified
 from   warehouse_person
 minus
 select person_id,
        id_verified
 from   PERSON_EXT_T)
/
rem
update PERSON_EXT_T x
set id_verified = (select id_verified
                 from   temp
                 where  person_id = x.person_id)
where person_id in (select person_id
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
(select person_id,
        OFFICE_LOCATION as ADDRESS_LINE_2,
        (select p.entity_id from krim_prncpl_t p where p.prncpl_id=person_id) as entity_id
 from   warehouse_person
 minus
 select p.prncpl_id as person_id,
        e.ADDR_LINE_2 as ADDRESS_LINE_2,
        e.entity_id
 from   KRIM_PRNCPL_T p INNER JOIN KRIM_ENTITY_ADDR_T e ON p.entity_id=e.entity_id)
/
rem
update KRIM_ENTITY_ADDR_T x
set ADDR_LINE_2 = (select ADDRESS_LINE_2
                 from   temp
                 where  entity_id =x.entity_id)
where entity_id in (select entity_id from temp)
/
commit
/

rem
update KRIM_ENTITY_EMP_INFO_T
set PRMRY_DEPT_CD = '999999'
where PRMRY_DEPT_CD is null
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
select 'Sync AWARD_PERSONS.' from dual
/
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
rem
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,AWARD_PERSONS a
where t.prncpl_id = a.person_id
and a.ROLODEX_ID is NULL and
trim(a.FULL_NAME) <> trim(t.full_name)
/
rem
select * from temp
/
rem
update AWARD_PERSONS x
set FULL_NAME =(select full_name
                 from   temp
                 where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
rem
rem
rem
select 'Sync AWARD_APPROVED_FOREIGN_TRAVEL.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,AWARD_APPROVED_FOREIGN_TRAVEL a
where  t.prncpl_id = a.person_id and 
trim(a.TRAVELER_NAME) <> trim(t.full_name)
/
rem
rem
select * from temp
/
rem
update AWARD_APPROVED_FOREIGN_TRAVEL x
set TRAVELER_NAME = (select full_name
                 from   temp
                  where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
rem
rem
rem
select 'Sync PROPOSAL_PERSONS.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,PROPOSAL_PERSONS pp
where  t.prncpl_id = pp.person_id and 
pp.rolodex_id is null and
trim(pp.full_name) <> trim(t.full_name)
/
rem
rem
rem
update PROPOSAL_PERSONS x
set full_name = (select full_name
                 from   temp
                  where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
rem
rem
rem
select 'Sync EPS_PROP_PERSON.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,EPS_PROP_PERSON ep
where  t.prncpl_id=ep.person_id and 
ep.rolodex_id is null and
trim(ep.full_name) <> trim(t.full_name)
/
rem
update EPS_PROP_PERSON x
set full_name = (select full_name
                 from   temp
                 where  person_id= x.person_id)
where person_id in (select person_id
                            from   temp) and ROLODEX_ID is NULL
/
commit
/
rem
rem
rem
select 'Sync PROPOSAL_LOG.' from dual
/
drop   table temp
/
rem
create table temp 
as
select distinct t.prncpl_id as person_id,t.full_name
from temp_full_name t,PROPOSAL_LOG pl
where  t.prncpl_id = pl.pi_id
and pl.ROLODEX_ID is null and
trim(pl.pi_name) <> trim(t.full_name)
/
rem
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
 UNIT_NUMBER,                           
 decode(PRIMARY_SECONDARY_INDICATOR, null, 'Unknown', PRIMARY_SECONDARY_INDICATOR),                   
 APPOINTMENT_START_DATE,                     
 APPOINTMENT_END_DATE,                    
 APPOINTMENT_TYPE,                      
 JOB_TITLE,
 PREFERED_JOB_TITLE,
 JOB_CODE
FROM Test_APPOINTMENT                    
/
commit
/
rem
rem
rem
rem **Should not delete appointments for people with ID > 999999983
rem **These are all TBAs
rem
select 'Purge all rows from  PERSON_APPOINTMENT ' from dual
/
delete from PERSON_APPOINTMENT
where person_id < '999999983'
/
commit
/
rem
rem
rem
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
 decode(ltrim(rtrim(APPOINTMENT_TYPE)), '11 Months', '11M DURATION', '12 Months', '12M DURATION', '9 Months', '9M DURATION', 'Temporary (< 12 months)', 'TMP EMPLOYEE', 'Term (=> 12 months)', 'REG EMPLOYEE', NULL) ,                      
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
rem
commit
/
rem ************************************************
rem following update is a temp fix for issue COEUSQA-3815
rem ************************************************
update PERSON_APPOINTMENT
set APPOINTMENT_TYPE_CODE = 'REG EMPLOYEE'
where APPOINTMENT_TYPE_CODE is null
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
select * from TEST_DEGREE
/
commit
/
rem 
rem 
rem **** Purge data from osp$person_degree table
rem *** do not delete any rows that were updated by Coeus users.  
rem 
rem 
delete from PERSON_DEGREE
where update_user = 'OSPA'
/
rem  *** Populate osp$person_degree
rem 
insert into PERSON_DEGREE 
select SEQ_PERSON_DEGREE.NEXTVAL, 
d.PERSON_ID,
d.GRADUATION_DATE,
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
rem 
commit
/

rem 
rem 
exit;