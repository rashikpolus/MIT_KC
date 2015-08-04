set serveroutput on;
declare
li_submission_id number(12);
li_protocol_id number(12);
li_count number;
li_cnt number;
cursor c_protocol_submission is
select 	pa.proto_amend_ren_number,pa.protocol_number,pa.sequence_number,ps.submission_number,ps.schedule_id,ps.committee_id,ps.schedule_id_fk,ps.committee_id_fk,
ps.submission_type_code,ps.submission_type_qual_code,ps.submission_status_code,ps.protocol_review_type_code,ps.submission_date,ps.comments,ps.yes_vote_count,ps.no_vote_count,ps.abstainer_count,
ps.voting_comments,ps.update_timestamp,ps.update_user,ps.recused_count,ps.is_billable,ps.comm_decision_motion_type_code
from TMP_MISSING_AMEND_RENW_PROTO pa inner join PROTOCOL_SUBMISSION ps
on  pa.protocol_number = ps.protocol_number and pa.sequence_number = ps.sequence_number
order by ps.protocol_number,ps.sequence_number,ps.submission_number;
r_protocol_submission  c_protocol_submission%rowtype;

begin
if c_protocol_submission%isopen then
close c_protocol_submission;
end if;
open c_protocol_submission;
loop
fetch c_protocol_submission into r_protocol_submission;
exit when c_protocol_submission%notfound; 

	begin
	
		select protocol_id  into li_protocol_id from protocol where protocol_number = r_protocol_submission.proto_amend_ren_number
		and sequence_number = 0;
				
		select submission_id  into li_submission_id from protocol_submission where protocol_number = r_protocol_submission.proto_amend_ren_number
		and sequence_number = 0 and submission_number = r_protocol_submission.submission_number;
	
	exception
    when others then
     dbms_output.put_line('Exception in fetching submission id protocol_submission ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
    end;
	
    select count(protocol_number) into li_cnt from protocol_submission_doc where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0;
	 if li_cnt = 0 then
	 
	 begin
	 
	 
		 insert into protocol_submission_doc(submission_doc_id,protocol_number,sequence_number,submission_number,protocol_id,submission_id_fk,document_id,file_name,document,update_timestamp,update_user,ver_nbr,obj_id,description,content_type)
		 select seq_protocol_id.nextval,r_protocol_submission.proto_amend_ren_number,0,submission_number,li_protocol_id,li_submission_id,document_id,file_name,document,update_timestamp,update_user,1,sys_guid(),description,content_type
		 from protocol_submission_doc 
		 where protocol_number = r_protocol_submission.protocol_number
		 and sequence_number = r_protocol_submission.sequence_number
		 and submission_number = r_protocol_submission.submission_number;	 
	 exception
     when others then
     dbms_output.put_line('Exception in protocol_submission_doc ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
     end;
	 end if;


	
	 select count(protocol_number) into li_cnt from protocol_exempt_chklst where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0;
	 if li_cnt = 0 then
	 
	 begin
		 insert into protocol_exempt_chklst(protocol_exempt_chklst_id,protocol_id,submission_id_fk,protocol_number,sequence_number,submission_number,exempt_studies_checklist_code,update_timestamp,update_user,ver_nbr,obj_id)
		 select seq_protocol_id.nextval,li_protocol_id,li_submission_id,r_protocol_submission.proto_amend_ren_number,0,submission_number,exempt_studies_checklist_code,update_timestamp,update_user,1,sys_guid() 
		 from protocol_exempt_chklst
		 where protocol_number = r_protocol_submission.protocol_number
		 and sequence_number = r_protocol_submission.sequence_number
		 and submission_number = r_protocol_submission.submission_number;
	 exception
     when others then
     dbms_output.put_line('Exception in protocol_exempt_chklst ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
     end;
	 
	 end if;

	
	 select count(protocol_number) into li_cnt from protocol_expidited_chklst where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0;
	 if li_cnt = 0 then
	 
	 begin
		 insert into protocol_expidited_chklst(protocol_expedited_chklst_id,protocol_id,submission_id_fk,protocol_number,sequence_number,submission_number,expedited_rev_chklst_code,update_timestamp,update_user,ver_nbr,obj_id)
		 select seq_protocol_id.nextval,li_protocol_id,li_submission_id,r_protocol_submission.proto_amend_ren_number,0,submission_number,expedited_rev_chklst_code,update_timestamp,update_user,1,sys_guid() 
		 from protocol_expidited_chklst
		 where protocol_number = r_protocol_submission.protocol_number
		 and sequence_number = r_protocol_submission.sequence_number
		 and submission_number = r_protocol_submission.submission_number;
	 exception
     when others then
     dbms_output.put_line('Exception in protocol_expidited_chklst ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
     end;
	 
	 end if;

     select count(protocol_number) into li_cnt from protocol_actions where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0;
	 if li_cnt = 0 then
	
	begin
		insert into protocol_actions(protocol_action_id,protocol_number,sequence_number,submission_number,action_id,protocol_action_type_code,protocol_id,submission_id_fk,comments,action_date,update_timestamp,update_user,ver_nbr,actual_action_date,obj_id,prev_submission_status_code,submission_type_code,prev_protocol_status_code,followup_action_code)
		select seq_protocol_id.nextval,r_protocol_submission.proto_amend_ren_number,0,submission_number,action_id,protocol_action_type_code,li_protocol_id,li_submission_id,comments,action_date,update_timestamp,update_user,ver_nbr,actual_action_date,obj_id,prev_submission_status_code,submission_type_code,prev_protocol_status_code,followup_action_code
		from protocol_actions
		where protocol_number = r_protocol_submission.protocol_number
		and sequence_number = r_protocol_submission.sequence_number
		and submission_number = r_protocol_submission.submission_number;
	exception
    when others then
    dbms_output.put_line('Exception in protocol_actions ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
    end;
	
	end if;
	

	
end loop;
close c_protocol_submission;
end;
/
declare
li_action_id number(12);
li_protocol_id number(12);
li_submission_id number(12);
li_count number;
li_cnt number;
cursor c_protocol_submission is
	select pa.proto_amend_ren_number,pa.protocol_number,pa.sequence_number,ps.submission_number,ps.action_id
	from TMP_MISSING_AMEND_RENW_PROTO pa inner join protocol_actions ps
	on  pa.protocol_number = ps.protocol_number and pa.sequence_number = ps.sequence_number
	order by ps.protocol_number,ps.sequence_number,ps.submission_number,ps.action_id;
r_protocol_submission  c_protocol_submission%rowtype;

begin
if c_protocol_submission%isopen then
close c_protocol_submission;
end if;
open c_protocol_submission;
loop
fetch c_protocol_submission into r_protocol_submission;
exit when c_protocol_submission%notfound;

	
	 
      select count(protocol_number) into li_cnt from protocol_correspondence where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0;
	  if li_count = 0 then
	  	    select seq_protocol_id.nextval into li_action_id from dual;
	
	 
	 begin
		   select protocol_id  into li_protocol_id from protocol where protocol_number = r_protocol_submission.proto_amend_ren_number
			and sequence_number = 0;
	 
		 insert into protocol_correspondence(id,protocol_number,sequence_number,action_id,protocol_id,action_id_fk,proto_corresp_type_code,final_flag,update_timestamp,update_user,ver_nbr,correspondence,obj_id,create_timestamp,create_user,final_flag_timestamp)
		 select seq_protocol_id.nextval,r_protocol_submission.proto_amend_ren_number,0,action_id,li_protocol_id,li_action_id,proto_corresp_type_code,final_flag,update_timestamp,update_user,1,correspondence,sys_guid(),create_timestamp,create_user,final_flag_timestamp
		 from protocol_correspondence
		 where protocol_number = r_protocol_submission.protocol_number
		 and sequence_number = r_protocol_submission.sequence_number
		 and action_id = r_protocol_submission.action_id;
	 exception
     when others then
     dbms_output.put_line('Exception in protocol_correspondence ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
     end;
	 
	 end if;
	 

end loop;
close c_protocol_submission;
end;
/
declare
  li_count number;
  li_protocol_id protocol.protocol_id%type;
  cursor c_data is
    SELECT PROTO_AMEND_REN_NUMBER,PROTOCOL_NUMBER,SEQUENCE_NUMBER  FROM TMP_MISSING_AMEND_RENW_PROTO;
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
    
  --- PROTOCOL_REFERENCES 
    select count(*) into li_count from PROTOCOL_REFERENCES
    where protocol_number = r_data.proto_amend_ren_number; 
    
    if li_count = 0 then 
       begin
          INSERT INTO PROTOCOL_REFERENCES(PROTOCOL_REFERENCE_ID,PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,
          PROTOCOL_REFERENCE_NUMBER,PROTOCOL_REFERENCE_TYPE_CODE,REFERENCE_KEY,APPLICATION_DATE,
          APPROVAL_DATE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
          SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,r_data.proto_amend_ren_number,0,PROTOCOL_REFERENCE_NUMBER,
          PROTOCOL_REFERENCE_TYPE_CODE,REFERENCE_KEY,APPLICATION_DATE,APPROVAL_DATE,COMMENTS,UPDATE_TIMESTAMP,
          UPDATE_USER,1,SYS_GUID()
          FROM PROTOCOL_REFERENCES 
          WHERE PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER
          AND SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER; 
       
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_REFERENCES ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
    end if; 
  
 --- PROTOCOL_RESEARCH_AREAS 
    select count(*) into li_count from PROTOCOL_RESEARCH_AREAS
    where protocol_number = r_data.proto_amend_ren_number; 
    
    if li_count = 0 then 
       begin
          INSERT INTO PROTOCOL_RESEARCH_AREAS(ID,PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,RESEARCH_AREA_CODE,
          UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
          SELECT SEQ_PROTOCOL_RESEARCH_AREAS_ID.NEXTVAL,li_protocol_id,r_data.proto_amend_ren_number,0,
          t1.RESEARCH_AREA_CODE,t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,1,SYS_GUID()
          FROM PROTOCOL_RESEARCH_AREAS t1
          WHERE t1.PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER
          AND   t1.SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;        
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_RESEARCH_AREAS ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
    end if;  
  
 --- PROTOCOL_REVIEWERS 
    select count(*) into li_count from PROTOCOL_REVIEWERS
    where protocol_number = r_data.proto_amend_ren_number;  
  
    if li_count = 0 then 
       begin
            INSERT INTO PROTOCOL_REVIEWERS(PROTOCOL_REVIEWER_ID,PROTOCOL_ID,SUBMISSION_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,
                         SUBMISSION_NUMBER,PERSON_ID,NON_EMPLOYEE_FLAG,REVIEWER_TYPE_CODE,UPDATE_TIMESTAMP,
                         UPDATE_USER,VER_NBR,OBJ_ID,ROLODEX_ID)     
            SELECT SEQ_PROTOCOL_ID.nextval, li_protocol_id,  
            (   select SUBMISSION_ID from PROTOCOL_SUBMISSION where PROTOCOL_NUMBER = r_data.proto_amend_ren_number 
               and SEQUENCE_NUMBER = 0 and SUBMISSION_NUMBER = t1.SUBMISSION_NUMBER
            ),
            r_data.proto_amend_ren_number,0,t1.SUBMISSION_NUMBER,t1.PERSON_ID,t1.NON_EMPLOYEE_FLAG,t1.REVIEWER_TYPE_CODE,
            t1.UPDATE_TIMESTAMP,t1.UPDATE_USER,1,SYS_GUID(),t1.ROLODEX_ID
            FROM PROTOCOL_REVIEWERS t1         
            WHERE t1.PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER
            AND  t1.SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_REVIEWERS ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
     end if;  
 
 --- PROTOCOL_RISK_LEVELS 
    select count(*) into li_count from PROTOCOL_RISK_LEVELS
    where protocol_number = r_data.proto_amend_ren_number;  
  
    if li_count = 0 then 
       begin
            INSERT INTO PROTOCOL_RISK_LEVELS(PROTOCOL_RISK_LEVELS_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,RISK_LEVEL_CODE,
            COMMENTS,DATE_ASSIGNED,DATE_INACTIVATED,STATUS,UPDATE_USER,UPDATE_TIMESTAMP,PROTOCOL_ID,VER_NBR,OBJ_ID)
            SELECT SEQ_PROTOCOL_ID.NEXTVAL,r_data.proto_amend_ren_number,0,RISK_LEVEL_CODE,COMMENTS,DATE_ASSIGNED,DATE_INACTIVATED,
            STATUS,UPDATE_USER,UPDATE_TIMESTAMP,li_protocol_id,VER_NBR,SYS_GUID()
            FROM PROTOCOL_RISK_LEVELS         
            WHERE PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER
            AND   SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_RISK_LEVELS ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
     end if;  

 --- PROTOCOL_SPECIAL_REVIEW 
    select count(*) into li_count from PROTOCOL_SPECIAL_REVIEW
    where protocol_number = r_data.proto_amend_ren_number;  
  
    if li_count = 0 then 
       begin
            INSERT INTO PROTOCOL_SPECIAL_REVIEW(PROTOCOL_SPECIAL_REVIEW_ID,PROTOCOL_ID,VER_NBR,SPECIAL_REVIEW_NUMBER,
            SPECIAL_REVIEW_CODE,APPROVAL_TYPE_CODE,PROTOCOL_NUMBER,APPLICATION_DATE,APPROVAL_DATE,EXPIRATION_DATE,
            COMMENTS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID)
            SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,VER_NBR,SPECIAL_REVIEW_NUMBER,SPECIAL_REVIEW_CODE,APPROVAL_TYPE_CODE,
            r_data.proto_amend_ren_number,APPLICATION_DATE,APPROVAL_DATE,EXPIRATION_DATE,COMMENTS,UPDATE_USER,
            UPDATE_TIMESTAMP,SYS_GUID() 
            FROM PROTOCOL_SPECIAL_REVIEW 
            WHERE PROTOCOL_ID in ( select PROTOCOL_ID FROM PROTOCOL 
                                   WHERE PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER
                                   AND SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER
                                 ); 
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_SPECIAL_REVIEW ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
     end if; 

 --- PROTOCOL_LOCATION 
    select count(*) into li_count from PROTOCOL_LOCATION
    where protocol_number = r_data.proto_amend_ren_number;  
  
    if li_count = 0 then 
       begin
          INSERT INTO PROTOCOL_LOCATION(PROTOCOL_LOCATION_ID,PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,PROTOCOL_ORG_TYPE_CODE,
          ORGANIZATION_ID,ROLODEX_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
          SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,r_data.proto_amend_ren_number,0,PROTOCOL_ORG_TYPE_CODE,
          ORGANIZATION_ID,ROLODEX_ID,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,SYS_GUID()
          FROM PROTOCOL_LOCATION
          WHERE PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER 
          AND SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;
  
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_LOCATION ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
     end if; 



 --- PROTOCOL_NOTEPAD 
    select count(*) into li_count from PROTOCOL_NOTEPAD
    where protocol_number = r_data.proto_amend_ren_number;  
  
    if li_count = 0 then 
       begin
         
         INSERT INTO PROTOCOL_NOTEPAD(PROTOCOL_NOTEPAD_ID,PROTOCOL_ID_FK,PROTOCOL_NUMBER,SEQUENCE_NUMBER,ENTRY_NUMBER,COMMENTS,
         RESTRICTED_VIEW,NOTE_TYPE,VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
         SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,r_data.proto_amend_ren_number,0,ENTRY_NUMBER,COMMENTS,RESTRICTED_VIEW,NOTE_TYPE,
         VER_NBR,UPDATE_TIMESTAMP,UPDATE_USER,SYS_GUID()
         FROM PROTOCOL_NOTEPAD
         WHERE PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER 
         AND SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;
  
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_NOTEPAD ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
     end if; 

 --- PROTOCOL_UNITS 
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
     
    
 --- PROTOCOL_VULNERABLE_SUB 
    select count(*) into li_count from PROTOCOL_VULNERABLE_SUB
    where protocol_number = r_data.proto_amend_ren_number;  
  
    if li_count = 0 then 
       begin
        
          INSERT INTO PROTOCOL_VULNERABLE_SUB(PROTOCOL_VULNERABLE_SUB_ID,PROTOCOL_ID,PROTOCOL_NUMBER,SEQUENCE_NUMBER,
          VULNERABLE_SUBJECT_TYPE_CODE,SUBJECT_COUNT,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
          SELECT SEQ_PROTOCOL_ID.NEXTVAL,li_protocol_id,r_data.proto_amend_ren_number,0,VULNERABLE_SUBJECT_TYPE_CODE,SUBJECT_COUNT,
          UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,SYS_GUID() 
          FROM PROTOCOL_VULNERABLE_SUB 
          WHERE PROTOCOL_NUMBER = r_data.PROTOCOL_NUMBER 
          AND SEQUENCE_NUMBER = r_data.SEQUENCE_NUMBER;
       
            
       exception
       when others then
       dbms_output.put_line('Exception in PROTOCOL_VULNERABLE_SUB ,for PROTO_AMEND_REN_NUMBER '||r_data.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
       
     end if;     
   
     
     
 end loop;
 close c_data;


end;
/
declare
li_action_id number(12);
li_protocol_id number(12);
li_submission_id number(12);
li_reviewer_id number(12);
li_count number(4);
cursor c_protocol_submission is
	select pa.proto_amend_ren_number,pa.protocol_number,pa.sequence_number,ps.protocol_id,ps.SUBMISSION_ID,ps.submission_number
	from TMP_MISSING_AMEND_RENW_PROTO pa inner join protocol_submission ps
	on  pa.protocol_number = ps.protocol_number and pa.sequence_number = ps.sequence_number
	order by ps.protocol_number,ps.sequence_number,ps.submission_number;
r_protocol_submission  c_protocol_submission%rowtype;

begin
if c_protocol_submission%isopen then
close c_protocol_submission;
end if;
open c_protocol_submission;
loop
fetch c_protocol_submission into r_protocol_submission;
exit when c_protocol_submission%notfound;

	begin
     select protocol_id into li_protocol_id from protocol where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0;
	 select submission_id into li_submission_id from protocol_submission where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0 and submission_number = r_protocol_submission.submission_number;
	when others then 
		dbms_output.put_line('Exception in submission_id 777 ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
		continue;
	end;

	begin
	 select protocol_reviewer_id into li_reviewer_id from protocol_reviewers where protocol_number = r_protocol_submission.proto_amend_ren_number and sequence_number = 0 and submission_number = r_protocol_submission.submission_number;
	exception
	when others then 
		li_reviewer_id := null;
	end;
	 
	 select count(protocol_id_fk) into li_count from comm_schedule_minutes where protocol_id_fk = li_protocol_id and submission_id_fk = li_submission_id;
	if li_count = 0 then
       
	   begin
		   insert into comm_schedule_minutes(comm_schedule_minutes_id,final_flag,reviewer_id_fk,schedule_id_fk,protocol_id_fk,entry_number,minute_entry_type_code,submission_id_fk,private_comment_flag,protocol_contingency_code,minute_entry,update_timestamp,update_user,ver_nbr,obj_id,protocol_onln_rvw_fk,comm_schedule_act_items_id_fk,create_user,create_timestamp)
		   select seq_meeting_id.nextval,final_flag,li_reviewer_id,schedule_id_fk,li_protocol_id,entry_number,minute_entry_type_code,li_submission_id,private_comment_flag,protocol_contingency_code,minute_entry,update_timestamp,update_user,1,sys_guid(),protocol_onln_rvw_fk,comm_schedule_act_items_id_fk,create_user,create_timestamp
		   from comm_schedule_minutes
		   where protocol_id_fk = r_protocol_submission.protocol_id 
		   and submission_id_fk = r_protocol_submission.SUBMISSION_ID;
	   exception
       when others then
       dbms_output.put_line('Exception in comm_schedule_minutes ,for PROTO_AMEND_REN_NUMBER '||r_protocol_submission.proto_amend_ren_number||', Error is '||sqlerrm);
       end;
	end if;
	
end loop;
close c_protocol_submission;
end;
/
ALTER TABLE PROTOCOL_ONLN_RVWS DISABLE CONSTRAINT FK6_PROTOCOL_ONLN_RVW_DOCUMENT
/
declare
ls_doc_typ_id VARCHAR2(40);
li_protocol_id number(12);
li_submission_id number(12);
li_reviewer_id number(12);
li_count number(4);
cursor c_missing is
	select pa.proto_amend_ren_number,pa.protocol_number,pa.sequence_number,ps.protocol_id,ps.submission_id_fk,ps.submission_number 
	from TMP_MISSING_AMEND_RENW_PROTO pa inner join protocol_reviewers ps
	on  pa.protocol_number = ps.protocol_number and pa.sequence_number = ps.sequence_number
	order by ps.protocol_number,ps.sequence_number,ps.submission_number;
r_missing c_missing%rowtype;

begin
if c_missing%isopen then
close c_missing;
end if;
open c_missing;
loop
fetch c_missing into r_missing;
exit when c_missing%notfound;

	begin 
		select protocol_id into li_protocol_id from protocol where protocol_number = r_missing.proto_amend_ren_number and sequence_number = 0;
	exception
		when others then
		continue;
	end;
	
	select count(protocol_id) into li_count from protocol_onln_rvws where protocol_id = li_protocol_id; 
       
	if li_count = 0 then
		begin 
		  select protocol_reviewer_id into li_reviewer_id from protocol_reviewers where protocol_number = r_missing.proto_amend_ren_number and sequence_number = 0 and submission_number = r_missing.submission_number;
		exception
		when others then
		continue;
		end;
    
	  select submission_id into li_submission_id from protocol_submission where protocol_number = r_missing.proto_amend_ren_number and sequence_number = 0 and submission_number = r_missing.submission_number;
	
	   begin
	   insert into protocol_onln_rvws(protocol_onln_rvw_id,
                                    document_number,
                                    protocol_id,
                                    submission_id_fk,
                                    protocol_reviewer_fk,
                                    protocol_onln_rvw_status_code,
                                    review_determ_recom_cd,
                                    date_requested,
                                    date_due,
                                    update_timestamp,
                                    update_user,
                                    ver_nbr,
                                    obj_id,
                                    actions_performed,
                                    reviewer_approved,
                                    admin_accepted)
							 select SEQ_PROTOCOL_ID.nextval,
							        'MP'||KREW_DOC_HDR_S.NEXTVAL,
							        li_protocol_id,
									li_submission_id,
									li_reviewer_id,
									protocol_onln_rvw_status_code,
                                    review_determ_recom_cd,
                                    date_requested,
                                    date_due,
                                    update_timestamp,
                                    update_user,
                                    1,
                                    sys_guid(),
                                    actions_performed,
                                    reviewer_approved,
                                    admin_accepted
							 from  protocol_onln_rvws
							 where protocol_id = r_missing.protocol_id
	                         and submission_id_fk = r_missing.submission_id_fk;
		exception
        when others then
        dbms_output.put_line('Exception in protocol_onln_rvw_document ,for proto_amend_ren_number '||r_missing.proto_amend_ren_number||', Error is '||sqlerrm);
        continue;
	   end;		
							 
							 
							  
		
        begin		
		insert into protocol_onln_rvw_document(document_number,
                                            ver_nbr,
                                            obj_id,
                                            update_timestamp,
                                            update_user)
									 select document_number,
									        1,
											sys_guid(),
											update_timestamp,
                                            update_user
									   from protocol_onln_rvws 
									   where protocol_id = li_protocol_id
	                                   and submission_id_fk = li_submission_id;
		exception
        when others then
        dbms_output.put_line('Exception in protocol_onln_rvw_document ,for proto_amend_ren_number '||r_missing.proto_amend_ren_number||', Error is '||sqlerrm);
        end;							   
									   
		select max(DOC_TYP_ID) into ls_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM='ProtocolOnlineReviewDocument';
	 
                    begin
						insert into krew_doc_hdr_t(doc_hdr_id,doc_typ_id,doc_hdr_stat_cd,rte_lvl,stat_mdfn_dt,crte_dt,aprv_dt,fnl_dt,rte_stat_mdfn_dt,ttl,app_doc_id,doc_ver_nbr,initr_prncpl_id,ver_nbr,rte_prncpl_id,dtype,obj_id,app_doc_stat,app_doc_stat_mdfn_dt)
						select a.document_number,ls_doc_typ_id,'F',0,sysdate,a.update_timestamp,sysdate,null,sysdate,('ProtocolOnlineReviewDocument'||'-'||r_missing.proto_amend_ren_number) ttl,null,1,nvl(p.prncpl_id,'unknownuser'),1,null,null,sys_guid(),null,null 
						from protocol_onln_rvws a left outer join krim_prncpl_t p on lower(p.prncpl_nm)=lower(a.update_user)
						where a.protocol_id = li_protocol_id
						and a.submission_id_fk = li_submission_id;
					exception
                    when others then
                    dbms_output.put_line('Exception in krew_doc_hdr_t ,for proto_amend_ren_number '||r_missing.proto_amend_ren_number||', Error is '||sqlerrm);
                    end; 
                    
					begin
						insert into krns_doc_hdr_t(doc_hdr_id,obj_id,ver_nbr,fdoc_desc,org_doc_hdr_id,tmpl_doc_hdr_id,explanation)
						select a.document_number,sys_guid(),1,r_missing.proto_amend_ren_number,null,null,null from protocol_onln_rvws a 
						where a.protocol_id = li_protocol_id
						and a.submission_id_fk = li_submission_id;
					exception
                    when others then
                    dbms_output.put_line('Exception in krns_doc_hdr_t ,for proto_amend_ren_number '||r_missing.proto_amend_ren_number||', Error is '||sqlerrm);
                    end; 
                    
					begin
						insert into krew_doc_hdr_cntnt_t(doc_hdr_id,doc_cntnt_txt)
						select a.document_number,null from protocol_onln_rvws a
						where protocol_id = li_protocol_id
						and submission_id_fk = li_submission_id;
					exception
                    when others then
                    dbms_output.put_line('Exception in krew_doc_hdr_cntnt_t ,for proto_amend_ren_number '||r_missing.proto_amend_ren_number||', Error is '||sqlerrm);
                    end; 
                    
					begin
						insert into temp_krew_3(document_number,rte_brch_id,rte_node_id,rte_node_instn_id,module)
						select document_number,krew_rte_node_s.nextval,krew_rte_node_s.nextval,krew_rte_node_s.nextval,'irb' from protocol_onln_rvws
						where protocol_id = li_protocol_id
						and submission_id_fk = li_submission_id;
                    exception
                    when others then
                    null;
                    end;					
    end if;
end loop;
close c_missing;
end;
/
insert into krew_rte_brch_t(rte_brch_id,nm,parnt_id,init_rte_node_instn_id,splt_rte_node_instn_id,join_rte_node_instn_id,ver_nbr)
select rte_brch_id,'primary',null,null,null,null,1 from temp_krew_3 where module='irb'
/ 

declare
ls_doc_typ_id varchar2(40);
begin 
	select max(doc_typ_id) into ls_doc_typ_id from krew_doc_typ_t where doc_typ_nm='ProtocolOnlineReviewDocument';
	insert into krew_rte_node_t(rte_node_id,doc_typ_id,nm,typ,rte_mthd_nm,rte_mthd_cd,fnl_aprvr_ind,mndtry_rte_ind,actvn_typ,brch_proto_id,ver_nbr,content_fragment,grp_id,next_doc_stat)
	select rte_node_id,ls_doc_typ_id,'initiated','org.kuali.rice.kew.engine.node.initialnode',null,null,0,0,'p',null,1,null,null,null from temp_krew_3 where module='irb';
	 
end;
/
insert into krew_rte_node_instn_t(rte_node_instn_id,doc_hdr_id,rte_node_id,brch_id,proc_rte_node_instn_id,actv_ind,cmplt_ind,init_ind,ver_nbr)
select rte_node_instn_id,document_number,rte_node_id,rte_brch_id,null,1,0,0,1 from temp_krew_3 where module='irb'
/ 

insert into krew_init_rte_node_instn_t(doc_hdr_id,rte_node_instn_id)
select document_number,rte_node_instn_id from temp_krew_3 where module='irb'
/ 

insert into krew_actn_rqst_t(actn_rqst_id,parnt_id,actn_rqst_cd,doc_hdr_id,rule_id,stat_cd,rsp_id,prncpl_id,role_nm,qual_role_nm,qual_role_nm_lbl_txt,recip_typ_cd,prio_nbr,rte_typ_nm,rte_lvl_nbr,rte_node_instn_id,actn_tkn_id,doc_ver_nbr,crte_dt,rsp_desc_txt,frc_actn,actn_rqst_annotn_txt,dlgn_typ,appr_plcy,cur_ind,ver_nbr,grp_id,rqst_lbl)
select krew_actn_rqst_s.nextval,null,'c',k.doc_hdr_id,null,'a',-3,k.initr_prncpl_id,null,null,null,'u',0,null,0,t.rte_node_instn_id,null,1,sysdate,'initiator needs to complete document.',1,null,null,'f',1	,0,null,null from krew_doc_hdr_t k inner join temp_krew_3 t on k.doc_hdr_id=t.document_number where k.ttl like 'ProtocolOnlineReviewDocument%' and t.module='irb' 
/ 

insert into krew_actn_tkn_t(actn_tkn_id,doc_hdr_id,prncpl_id,dlgtr_prncpl_id,actn_cd,actn_dt,doc_ver_nbr,annotn,cur_ind,ver_nbr,dlgtr_grp_id)
select krew_actn_tkn_s.nextval,k.doc_hdr_id,k.initr_prncpl_id,null,'s',sysdate,1,null,1,1,null from krew_doc_hdr_t k inner join temp_krew_3 t on k.doc_hdr_id=t.document_number where k.ttl like 'ProtocolOnlineReviewDocument%' and t.module='irb' 
/ 
					
ALTER TABLE PROTOCOL_ONLN_RVWS ENABLE CONSTRAINT FK6_PROTOCOL_ONLN_RVW_DOCUMENT
/	
declare
li_protocol_id number(12);
cursor c_amend_renew is
select p.PROTO_AMEND_REN_NUMBER,ps.PROTOCOL_ID from TMP_MISSING_AMEND_RENW_PROTO p
inner join PROTOCOL ps on p.PROTO_AMEND_REN_NUMBER = ps.PROTOCOL_NUMBER
and ps.SEQUENCE_NUMBER = 0; 
r_amend_renew c_amend_renew%rowtype;

begin
if c_amend_renew%isopen then
close c_amend_renew;
end if;
open c_amend_renew;
loop
fetch c_amend_renew into r_amend_renew;
exit when c_amend_renew%notfound;

    update proto_amend_renewal 
	set protocol_id = r_amend_renew.protocol_id
	where proto_amend_ren_number = r_amend_renew.proto_amend_ren_number;
	
end loop;
close c_amend_renew;
end;
/

