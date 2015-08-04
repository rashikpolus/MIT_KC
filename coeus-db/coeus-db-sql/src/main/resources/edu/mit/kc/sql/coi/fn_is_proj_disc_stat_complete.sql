create or replace
function fn_is_proj_disc_stat_complete
	(as_module_item_key in OSP$INV_COI_DISCLOSURE.MODULE_ITEM_KEY%TYPE ,
	 as_module_code in OSP$INV_COI_DISCLOSURE.MODULE_CODE%TYPE,
	 as_person_id in VARCHAR2)
return number is	
    li_ret                  NUMBER;   
	li_coi_count			NUMBER;
    li_person_count			NUMBER;

BEGIN
	
    li_ret := 1;

    IF as_module_code = 1 THEN -- AWARD
       
           -- Get latest status of the max disclosure for this award for this person            
                    select count(distinct(cdd.coi_project_status_code))  into li_coi_count from osp$coi_disclosure cd , osp$coi_disc_details cdd     
                    where cd.coi_disclosure_number = cdd.coi_disclosure_number
                    and   cd.sequence_number = cdd.sequence_number
                    and   cd.person_id in  (  select regexp_substr(as_person_id,'[^,]+', 1, level)  from dual 
												connect by regexp_substr(as_person_id, '[^,]+', 1, level) is not null )                     
                    and   cdd.module_item_key like  substr(as_module_item_key, 1, 6) || '%'  
					and   cdd.coi_project_status_code	not in ( 230, 240, 330, 340 ) --bad status
                    and   cd.SEQUENCE_NUMBER = (select max(sequence_number)  from osp$coi_disclosure where PERSON_ID = cd.person_id 
												and module_item_key =  cdd.module_item_key);
												
					
					-- total number of person for that project	
					select count(person_id) into li_person_count
					from ( 	select regexp_substr(as_person_id,'[^,]+', 1, level) as person_id  from dual 
									connect by regexp_substr(as_person_id, '[^,]+', 1, level) is not null 
						  );
					
					if li_coi_count <> li_person_count then
						li_ret := -1;
					end if;
					
               

    ELSIF as_module_code = 2 THEN /* PROPOSAL **/      

            -- Get latest status of the max disclosure for this proposal for this person            
                  select count(distinct(cdd.coi_project_status_code))  into li_coi_count from osp$coi_disclosure cd , osp$coi_disc_details cdd     
                  where cd.coi_disclosure_number = cdd.coi_disclosure_number
                  and   cd.sequence_number = cdd.sequence_number
                  and   cd.person_id in  (  select regexp_substr(as_person_id,'[^,]+', 1, level)  from dual 
												connect by regexp_substr(as_person_id, '[^,]+', 1, level) is not null )                    
                  and   cdd.module_item_key =  as_module_item_key   
				  and   cdd.coi_project_status_code	not in ( 230, 240, 330, 340 ) --bad status
                  and   cd.SEQUENCE_NUMBER = (select max(sequence_number)  from osp$coi_disclosure where PERSON_ID = cd.person_id 
                         and module_item_key =  cdd.module_item_key); 
							
			-- total number of person for that project	
				  select count(person_id) into li_person_count
				  from ( 	select regexp_substr(as_person_id,'[^,]+', 1, level) as person_id  from dual 
									connect by regexp_substr(as_person_id, '[^,]+', 1, level) is not null 
						);
					
					if li_coi_count <> li_person_count then
						li_ret := -1;
					end if;					
         

    END IF;

    return li_ret;
END;
/
