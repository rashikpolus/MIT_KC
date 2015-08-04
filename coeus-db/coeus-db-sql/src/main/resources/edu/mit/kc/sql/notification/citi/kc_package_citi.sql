set define off;

create or replace package kc_package_citi as
function FN_POPULATE_PERS_TRAINING
        return NUMBER;
function FN_MAP_TRAINING_TYPE(LS_TRAINING_GROUP VARCHAR2 ,  li_stage_number NUMBER) 
        return NUMBER;
        
function FN_GET_TRAINING_MODULE(li_training_code number) 
        return NUMBER;   
function fn_gen_citi_feed_email
	return NUMBER;
        
end;
/
create or replace package body kc_package_citi as

FUNCTION FN_MAP_TRAINING_TYPE( LS_TRAINING_GROUP VARCHAR2 ,  li_stage_number NUMBER) return number is

 ls_person_id      varchar(9);
 li_training_code  number;
  
 
 
 BEGIN
 
  IF (li_stage_number = 1) then
    
 
    if (upper(ls_training_group) = 'BIOMEDICAL RESEARCH INVESTIGATORS' ) then
      li_training_code := 15;
    elsif (upper(ls_training_group) = 'SOCIAL & BEHAVIORAL RESEARCH INVESTIGATORS') then
      li_training_code := 14;
    elsif (upper(ls_training_group) = 'IRB-SOCIAL-BEHAVIORAL-FRENCH') then
      li_training_code := 14;
    elsif (upper(ls_training_group) = 'DATA OR SPECIMENS ONLY RESEARCH') then
      li_training_code := 17;
    elsif (upper(ls_training_group) = 'IRB MEMBERS') then
      li_training_code := 26;
    elsif (upper(ls_training_group) = 'HUMANITIES RESPONSIBLE CONDUCT OF RESEARCH') then
       li_training_code := 40;
    elsif (upper(ls_training_group) = 'SOCIAL AND BEHAVIORAL RESPONSIBLE CONDUCT OF RESEARCH') then
       li_training_code := 41;
    elsif (upper(ls_training_group) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ENGINEERS') then
        li_training_code := 42;
    elsif (upper(ls_training_group) = 'PHYSICAL SCIENCE RESPONSIBLE CONDUCT OF RESEARCH') then
        li_training_code := 43;
    elsif (upper(ls_training_group) = 'BIOMEDICAL RESPONSIBLE CONDUCT OF RESEARCH') then
        li_training_code := 44;
    elsif (upper(ls_training_group) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ADMINISTRATORS') then
        li_training_code := 45;
    elsif (upper(ls_training_group) = 'NIH/PHS CONFLICT OF INTEREST COURSE') then
        li_training_code := 54;
    elsif (upper(ls_training_group) = 'WORKING WITH THE IACUC') then
        li_training_code := 57;
    elsif (upper(ls_training_group) = 'ASEPTIC SURGERY') then
        li_training_code := 59;
    elsif (upper(ls_training_group) = 'ANTIBODY PRODUCTION IN ANIMALS') then
        li_training_code := 60;
    elsif (upper(ls_training_group) = 'ESSENTIALS FOR IACUC MEMBERS') then
        li_training_code := 61;
    elsif (upper(ls_training_group) = 'IACUC COMMUNITY MEMBER') then
        li_training_code := 62;
    elsif (upper(ls_training_group) = 'REDUCING PAIN AND DISTRESS IN LABORATORY MICE AND RATS') then
        li_training_code := 63;
    elsif (upper(ls_training_group) = 'WILDLIFE RESEARCH') then
        li_training_code := 64;
    elsif (upper(ls_training_group) = 'WORKING WITH AMPHIBIANS IN RESEARCH SETTINGS.') then
        li_training_code := 65;
    --elsif (upper(ls_training_group) = 'WORKING WITH CATS IN RESEARCH SETTINGS') then
        --li_training_code := 66;
    elsif (upper(ls_training_group) = 'WORKING WITH DOGS IN RESEARCH SETTINGS') then
        li_training_code := 67;
    elsif (upper(ls_training_group) = 'WORKING WITH FERRETS IN RESEARCH SETTINGS') then
        li_training_code := 68;
    elsif (upper(ls_training_group) = 'WORKING WITH FISH IN RESEARCH SETTINGS') then
        li_training_code := 69;
    elsif (upper(ls_training_group) = 'WORKING WITH GERBILS IN RESEARCH SETTINGS') then
        li_training_code := 70;
    elsif (upper(ls_training_group) = 'WORKING WITH GUINEA PIGS IN RESEARCH SETTINGS') then
        li_training_code := 71;
    elsif (upper(ls_training_group) = 'WORKING WITH HAMSTERS IN RESEARCH SETTINGS') then
        li_training_code := 72;
    elsif (upper(ls_training_group) = 'WORKING WITH MICE IN RESEARCH') then
        li_training_code := 73;
    elsif (upper(ls_training_group) = 'WORKING WITH NON-HUMAN PRIMATES IN RESEARCH SETTINGS') then
       li_training_code := 74;
    elsif (upper(ls_training_group) = 'WORKING WITH RABBITS IN RESEARCH SETTINGS') then
        li_training_code := 75;
    elsif (upper(ls_training_group) = 'WORKING WITH RATS IN RESEARCH SETTINGS') then
        li_training_code := 76;   
    elsif (upper(ls_training_group) = 'WORKING WITH SWINE IN RESEARCH SETTINGS') then
        li_training_code := 77;
    elsif (upper(ls_training_group) = 'WORKING WITH ZEBRAFISH (DANIO RERIO) IN RESEARCH SETTINGS') then
        li_training_code := 78;
    elsif (upper(ls_training_group) = 'POST-APPROVAL MONITORING (PAM)') then
       li_training_code := 79;    
        
    end if;
    
  ELSE
  
    if (upper(ls_training_group) = 'BIOMEDICAL RESEARCH INVESTIGATORS' ) then
      li_training_code := 23;
    elsif (upper(ls_training_group) = 'SOCIAL & BEHAVIORAL RESEARCH INVESTIGATORS') then
      li_training_code := 25;
    elsif (upper(ls_training_group)= 'DATA OR SPECIMENS ONLY RESEARCH') then
      li_training_code := 24;
    elsif (upper(ls_training_group) = 'IRB MEMBERS') then
      li_training_code := 27;
    elsif (upper(ls_training_group )= 'HUMANITIES RESPONSIBLE CONDUCT OF RESEARCH') then
       li_training_code := 46;
    elsif (upper(ls_training_group )= 'SOCIAL AND BEHAVIORAL RESPONSIBLE CONDUCT OF RESEARCH') then
       li_training_code := 47;
    elsif (upper(ls_training_group) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ENGINEERS') then
        li_training_code := 48;
    elsif (upper(ls_training_group) = 'PHYSICAL SCIENCE RESPONSIBLE CONDUCT OF RESEARCH') then
        li_training_code := 49;
    elsif (upper(ls_training_group) = 'BIOMEDICAL RESPONSIBLE CONDUCT OF RESEARCH') then
        li_training_code := 50;
    elsif (upper(ls_training_group) = 'RESPONSIBLE CONDUCT OF RESEARCH FOR ADMINISTRATORS') then
        li_training_code := 51;
    elsif (upper(ls_training_group) = 'WORKING WITH THE IACUC - REFRESHER') then
        li_training_code :=58;
    elsif (upper(ls_training_group) = 'WORKING WITH CATS IN RESEARCH SETTINGS') then
        li_training_code := 66;
    end if;
    
    END IF;
    

    
  return li_training_code;
 
 END FN_MAP_TRAINING_TYPE;
 
function FN_GET_TRAINING_MODULE (li_training_code number) return number is

 li_module_code  number;

  begin

    SELECT TRAINING_MODULES.MODULE_CODE
    INTO  li_module_code
    FROM TRAINING_MODULES
    WHERE TRAINING_MODULES.TRAINING_CODE = li_training_code;
	
/*
     IF li_training_code in(15,14,17,23,24,25,26,27) THEN
	    li_module_code:=7;
	 ELSIF li_training_code in(40,41,42,43,44,45,46,47,48,49,50,51) THEN
	    li_module_code:=100;
	 END IF;
*/

    return li_module_code;
    
     EXCEPTION
          WHEN OTHERS then
          return 0;
          
	 
    return li_module_code;


  end FN_GET_TRAINING_MODULE;
  
FUNCTION FN_POPULATE_PERS_TRAINING return number is

 ls_person_id      varchar(9);
 li_training_code  number;
 li_count         number;
 li_count_rcr     number;
 li_count_human   number;
 li_count_coi     number;
 li_count_iacuc   number;
 li_training_no   number;
 li_loop          number;
 ld_followup_date  date;
 li_ret           number;
 li_rows          number;
 li_inserts       number;
 li_humsubj_rows  number;
 li_rcr_rows      number;
 li_coi_rows      number;
 li_iacuc_rows    number;
 li_module_code   number;
 ls_name          varchar2(90);
 ls_training_desc TRAINING.DESCRIPTION%type;
 

cursor cur_citi_data is
  SELECT   C.CUSTOM_FIELD2, C.CURRICULUM, C.TRAINING_GROUP, C.STAGE_NUMBER, C.DATE_COMPLETED,  C.LAST_NAME, C.FIRST_NAME, C.EMAIL, C.USER_NAME
    FROM   CITI_TRAINING C
    WHERE  C.CUSTOM_FIELD2 IS NOT NULL
    ORDER BY C.CUSTOM_FIELD2;
    
  rec_citi_data cur_citi_data%ROWTYPE;
  
cursor cur_citi_errors is
   SELECT  C.CURRICULUM, C.TRAINING_GROUP, C.STAGE_NUMBER, C.DATE_COMPLETED,  C.LAST_NAME, C.FIRST_NAME, C.EMAIL, C.USER_NAME
    FROM   CITI_TRAINING C
    WHERE  C.CUSTOM_FIELD2 IS  NULL;
    
    rec_citi_err cur_citi_errors%ROWTYPE;

BEGIN
   
    delete from CITI_ERROR_LOG;
    
    li_humsubj_rows := 0;
    li_rcr_rows := 0;
    li_coi_rows := 0;
    li_inserts := 0;
    li_iacuc_rows :=0;
    li_rows := 0;
    
    open cur_citi_data;
    
    loop
       fetch cur_citi_data into rec_citi_data;
       exit when cur_citi_data%NOTFOUND;
        
       li_rows := li_rows + 1;
               
             -- check for missing person id in osp$person
           
              SELECT count(*)
              into   li_count
              FROM   KRIM_PRNCPL_T
              WHERE  PRNCPL_ID = rec_citi_data.custom_field2;
              
              if (li_count = 0) then
                                           
                  INSERT INTO CITI_ERROR_LOG
                  ( PERSON_ID, ERROR_MESSAGE , UPDATE_TIMESTAMP ) 
 	              VALUES ( rec_citi_data.custom_field2,
                  ' Person ' || rec_citi_data.custom_field2 || ' is missing in osp$person table' , SYSDATE )  ;            
              
              else     
              
                    begin
              
                        select  max(PERSON_TRAINING.TRAINING_NUMBER)
                        into    li_training_no
                        from    PERSON_TRAINING
                        where   person_id = rec_citi_data.custom_field2 ; 
                
                        if (li_training_no is null) then
                            li_training_no := 0;
                        end if;
                    EXCEPTION WHEN OTHERS THEN
                        li_training_no :=0;
                    end;
              
                    -- check for refresher course but no basic course 
                    -- maybe add to this to be specific about type of curriculum
                    -- but for now just check if there is no record at all in person training 
                    if (rec_citi_data.stage_number = 2 or rec_citi_data.stage_number = 3) then
               
                        -- make sure there is a basic course record in training table 
                        select count(*) 
                        into   li_count
                        from   PERSON_TRAINING p
                        where  p.person_id = rec_citi_data.custom_field2;
                        --    and    p.training_code in ( 14,15,17,20,21,22,26,40,41,42,43 ) ;
                
                        if (li_count = 0) then
                          SELECT e.last_nm||', '||e.first_nm||' '|| e.middle_nm
                          INTO  ls_name
                          FROM   KRIM_PRNCPL_T p inner join KRIM_ENTITY_NM_T e 
                          ON p.ENTITY_ID=e.ENTITY_ID
                          WHERE  p.PRNCPL_ID = rec_citi_data.custom_field2;
                          
                                                   
                            INSERT INTO CITI_ERROR_LOG
                                ( person_id, ERROR_MESSAGE, UPDATE_TIMESTAMP ) 
 	                             VALUES ( rec_citi_data.custom_field2,
                                ' Person ' || rec_citi_data.custom_field2 || ' - ' || ls_name || ' completed refresher but is missing basic couse' , SYSDATE )  ;   
                         end if;
                
                    end if;
                
                    -- get value for follow up date and training code 
                     
                    li_training_code := FN_MAP_TRAINING_TYPE( rec_citi_data.TRAINING_GROUP  , rec_citi_data.stage_number);       
                 
                    li_module_code := FN_GET_TRAINING_MODULE (li_training_code );
                    
                    if (li_module_code = 0) then 
                        -- bad training code
                        SELECT e.last_nm||', '||e.first_nm||' '|| e.middle_nm
                          INTO  ls_name
                          FROM    KRIM_PRNCPL_T p inner join KRIM_ENTITY_NM_T e 
                          ON p.ENTITY_ID=e.ENTITY_ID
                          WHERE  p.PRNCPL_ID = rec_citi_data.custom_field2;
                          
                        INSERT INTO CITI_ERROR_LOG
                            ( person_id, ERROR_MESSAGE, UPDATE_TIMESTAMP ) 
                            VALUES ( rec_citi_data.custom_field2,
                             ' - ' || ls_name || ' has bad training code: ' || li_training_code , SYSDATE )  ;   
                    else
                
                         li_count_human := 0;
                         li_count_rcr := 0;
                         li_count_coi := 0;
                         li_count_iacuc := 0;
                
                        if (li_module_code = 7 ) then
                             --only need followup date for human subjects
                 
                              ld_followup_date := add_months( rec_citi_data.date_completed , 36 ) - 1;
         
                            --look for dups 
                            select count(*)
                            into   li_count_human
                            from   PERSON_TRAINING p
                            where  p.person_id = rec_citi_data.custom_field2
                            and    p.training_code = li_training_code
                            and    TO_CHAR(p.date_submitted,'MM/DD/YYYY') = TO_CHAR(rec_citi_data.date_completed,'MM/DD/YYYY')
                            and    TO_CHAR(p.followup_date,'MM/DD/YYYY') = TO_CHAR(ld_followup_date,'MM/DD/YYYY')
                            and    p.score = 'P';
                        
                        elsif (li_module_code = 100) then
                        
                            select count(*)
                            into   li_count_rcr
                            from   PERSON_TRAINING p
	                        where  p.person_id = rec_citi_data.custom_field2
                            and    p.training_code = li_training_code
                            and     TO_CHAR(p.date_submitted,'MM/DD/YYYY') = TO_CHAR(rec_citi_data.date_completed,'MM/DD/YYYY')
                            and    p.score = 'P';
  
                       elsif (li_module_code = 8) then
                           -- followupdate for coi is 4 years 
                            ld_followup_date := add_months(rec_citi_data.date_completed, 48 ) - 1;
                            
                            select count(*)
                            into   li_count_coi
                            from   PERSON_TRAINING p
                            where  p.person_id = rec_citi_data.custom_field2
                            and    p.training_code = li_training_code
                            and    TO_CHAR(p.date_submitted,'MM/DD/YYYY') = TO_CHAR(rec_citi_data.date_completed,'MM/DD/YYYY')
                            and    TO_CHAR(p.followup_date,'MM/DD/YYYY') = TO_CHAR(ld_followup_date,'MM/DD/YYYY')
                            and    p.score = 'P';
                     elsif (li_module_code = 9) then
                            select count(*)
                            into   li_count_iacuc
                            from   PERSON_TRAINING p
                            where  p.person_id = rec_citi_data.custom_field2
                            and    p.training_code = li_training_code
                            and     TO_CHAR(p.date_submitted,'MM/DD/YYYY') = TO_CHAR(rec_citi_data.date_completed,'MM/DD/YYYY')
                            and    p.score = 'P';
                
                        end if;              
                 
                        if (li_count_human = 0) and (li_count_rcr = 0) and (li_count_coi = 0) and (li_count_iacuc = 0) then
                            begin
                    
                                li_module_code :=FN_GET_TRAINING_MODULE (li_training_code );
                                
                                if (li_module_code = 7) then
                     
                                    insert into PERSON_TRAINING
                                        (person_training_id,person_id, training_number, training_code, date_submitted, date_acknowledged,
                                            followup_date, score, update_timestamp, update_user,ver_nbr,obj_id,active_flag)
                                    values (SEQ_PERSON_TRAINING_ID.nextval,rec_citi_data.custom_field2,li_training_no + 1,  li_training_code, rec_citi_data.date_completed, sysdate,
                                        ld_followup_date, 'P', sysdate, user,1,sys_guid(),'Y');
                         
                                    li_humsubj_rows :=  li_humsubj_rows + 1;
                       
                                elsif (li_module_code = 100) then
                     
                                    insert into PERSON_TRAINING
                                        (person_training_id,person_id, training_number, training_code, date_submitted, date_acknowledged,
                                        score, update_timestamp, update_user,ver_nbr,obj_id,active_flag)
                                    values (SEQ_PERSON_TRAINING_ID.nextval,rec_citi_data.custom_field2,li_training_no + 1,  li_training_code, rec_citi_data.date_completed, sysdate,
                                         'P', sysdate, user,1,sys_guid(),'Y');
                         
                                    li_rcr_rows := li_rcr_rows + 1;
                                    
                                elsif (li_module_code = 8) then
                     
                                    insert into PERSON_TRAINING
                                        (person_training_id,person_id, training_number, training_code, date_submitted, date_acknowledged,
                                            followup_date, score, update_timestamp, update_user,ver_nbr,obj_id,active_flag)
                                    values (SEQ_PERSON_TRAINING_ID.nextval,rec_citi_data.custom_field2,li_training_no + 1,  li_training_code, rec_citi_data.date_completed, sysdate,
                                        ld_followup_date, 'P', sysdate, user,1,sys_guid(),'Y');
                         
                                    li_coi_rows := li_coi_rows + 1;
                                    
                                elsif (li_module_code = 9) then
                     
                                    insert into PERSON_TRAINING
                                        (person_training_id,person_id, training_number, training_code, date_submitted, date_acknowledged,
                                        score, update_timestamp, update_user,ver_nbr,obj_id,active_flag)
                                    values (SEQ_PERSON_TRAINING_ID.nextval,rec_citi_data.custom_field2,li_training_no + 1,  li_training_code, rec_citi_data.date_completed, sysdate,
                                         'P', sysdate, user,1,sys_guid(),'Y');
                         
                                    li_iacuc_rows := li_iacuc_rows + 1;
                        
                                end if;
                  
                                li_inserts := li_inserts + 1;
                                
                                -- insert names into error log for checking 
                                BEGIN
                                
                                    SELECT e.last_nm||', '||e.first_nm||' '|| e.middle_nm
                                    INTO  ls_name
                                    FROM    KRIM_PRNCPL_T p inner join KRIM_ENTITY_NM_T e 
                                    ON p.ENTITY_ID=e.ENTITY_ID
                                    WHERE  p.PRNCPL_ID = rec_citi_data.custom_field2;
                                 
                                    SELECT     DESCRIPTION
                                    INTO       ls_training_desc
                                    FROM       TRAINING
                                    WHERE      TRAINING_CODE = li_training_code;
                                 
                                    INSERT INTO CITI_ERROR_LOG
                                         ( person_id, ERROR_MESSAGE, UPDATE_TIMESTAMP ) 
                                    VALUES ( rec_citi_data.custom_field2,
                                            ' - ' || ls_name || ' inserted into training table. Training type is ' || ls_training_desc , SYSDATE );   
                          
                                 EXCEPTION WHEN OTHERS THEN
                                     ls_name := null;
                                 
                                 end;
                  
                            end;
                
                        end if;
         
                    end if;
      
             end if;
       
    end loop;
    
    close cur_citi_data;
      
    -- find any citi records that are missing person_ids
    
    open  cur_citi_errors ;
        loop
             fetch  cur_citi_errors  into rec_citi_err;
             exit when  cur_citi_errors%NOTFOUND;  
       
            begin  
                INSERT INTO CITI_ERROR_LOG
                    ( ERROR_MESSAGE , UPDATE_TIMESTAMP ) 
 	            VALUES ( 
                     ' Person ' || rec_citi_err.last_name || ', ' || rec_citi_err.first_name  || ' is missing person id in citi table', SYSDATE )  ;
            end;
            
        end loop;

    close cur_citi_errors;

    INSERT INTO CITI_ERROR_LOG (ERROR_MESSAGE, UPDATE_TIMESTAMP)
      VALUES ('Total Number of rows read from CITI_TRAINING is ' || li_rows || '; number of inserts= ' || li_inserts , SYSDATE );
      
    INSERT INTO CITI_ERROR_LOG (ERROR_MESSAGE, UPDATE_TIMESTAMP)
      VALUES ('RCR rows inserted is ' || li_rcr_rows || ' - Human subjects rows inserted is ' || li_humsubj_rows , SYSDATE );
      
     li_ret :=  fn_gen_citi_feed_email;
 return 1;
 
END FN_POPULATE_PERS_TRAINING; 

/**********************************************/
function fn_gen_citi_feed_email
	return NUMBER IS
/**********************************************/
li_log_count         number;
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   clob;
ls_MailReceiver    varchar2(256) := 'citi-feed@mit.edu';

cursor cur_log_messge is 
	select person_id, error_message, to_char(update_timestamp,'DD-MON-YYYY') as udt from citi_error_log;
rec_message  	cur_log_messge%ROWTYPE;

BEGIN
	select count(*) into li_log_count from citi_error_log;
	if li_log_count > 0 then
		--open 	cur_generic for 
		 --select person_id, error_message, trunc(update_timestamp)  from citi_error_log;
		 --fetch cur_generic into mail_message;
		 mail_subject:= 'citi feed log';
		 open cur_log_messge;
		 loop 
		 fetch cur_log_messge into rec_message;
		 mail_message :=mail_message || '<p>'||rec_message.person_id ||'&nbsp; &nbsp; &nbsp;'|| rec_message.error_message ||'&nbsp; &nbsp; &nbsp;'||rec_message.udt ||'</p>';
		 exit when cur_log_messge%NOTFOUND;
		 end loop;
		 close cur_log_messge;
		 begin
		 	KC_MAIL_GENERIC_PKG.SEND_MAIL(-999,ls_MailReceiver,null,ls_MailReceiver,mail_subject,mail_message);
		 
		 	exception
		 	  when others then
				return 0;
		end;
	end if;
	return 1;
END;
end ;
/

set define on;