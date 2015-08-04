create or replace
function fn_generate_sap_budget_feed(as_path IN VARCHAR2,
					as_update_user IN VARCHAR2,
					as_batch_id IN NUMBER,
					as_dt_now IN DATE)
return number is

ls_award_budget_status			krcr_parm_t.val%TYPE;
li_sap_budget_feed_details_id	sap_budget_feed_details.sap_budget_feed_details_id%type;	
ls_sap_feed_fiscal_year			krcr_parm_t.val%TYPE;
li_budget_id 					award_budget_ext.budget_id%type;
ls_account_number				award.account_number%type;
li_no_of_records				NUMBER;
ls_batch_file_name              sap_budget_feed_batch_list.batch_file_name%type;
li_sap_budget_feed_batch_id     sap_budget_feed_batch_list.sap_budget_feed_batch_id%type;
ls_amount 						sap_budget_feed.amount%type;
ret 							number;
li_inserted                     PLS_INTEGER := 0;
li_count 						NUMBER;
ls_cost_element     			SAP_BUDGET_FEED.COST_ELEMENT%type;
ls_auth_total					sap_feed.auth_total%type;
ls_mit_account_number			sap_feed.mit_sap_account%type;
li_cost_share_count				NUMBER;
ls_sap_spon_code 				VARCHAR2(6) := '009906';

	CURSOR c_sap_bud_ext IS
			select a.award_id, a.budget_id, b.AWARD_NUMBER 
			from award_budget_ext a, award b
			where a.AWARD_ID = b.AWARD_ID
				AND a.AWARD_BUDGET_STATUS_CODE IN ( select regexp_substr('10,15','[^,]+', 1, level) from dual
														connect by regexp_substr('10,15', '[^,]+', 1, level) is not null );	
  CURSOR c_sap_bud_det(v_award_number in VARCHAR2) IS
		SELECT	t2.account_number,
		t2.award_number,
		t2.sequence_number,
		t2.AWARD_SEQUENCE_STATUS,
		t2.STATUS_CODE
		FROM AWARD t2
		WHERE t2.AWARD_NUMBER =  v_award_number AND t2.AWARD_SEQUENCE_STATUS = 'ACTIVE' AND
		t2.status_code <> 6;  -- do not include award on hold status		

	CURSOR c_award_budget is
		select t1.cost_element as gl_account_key,
		sum(t1.line_item_cost+nvl(t2.obligated_amount,0)) amount
		from budget_details t1 , award_budget_details_ext t2		
		where t1.budget_details_id = t2.budget_details_id(+) and t1.budget_id = li_budget_id   
		group by t1.cost_element
		
		UNION	
		
		SELECT decode(t3.activity_type_code,1,'422121', '422123') gl_account_key,
			nvl(t1.amount,0) AS AMOUNT
		FROM (
			  select t1.budget_id,
			  sum(t1.total_indirect_cost) amount
			  from budget_periods t1 	   
			  where t1.budget_id = li_budget_id
			  group by t1.budget_id    
			) t1 	
		INNER JOIN  AWARD_BUDGET_EXT t2 on t1.budget_id = t2.budget_id
		INNER JOIN award t3 on t2.award_id = t3.award_id
		
		UNION
		
		select '422127' As gl_account_key,
		nvl(sum(TOTAL_FRINGE_AMOUNT),0) AS amount
		from award_budget_period_ext t1
		inner join budget_periods t2 on t1.budget_period_number = t2.budget_period_number
		where t2.budget_id = li_budget_id;		
	
		r_award_budget c_award_budget%rowtype;
	
	CURSOR c_cs_award IS
		SELECT nvl(t1.auth_total,'0') auth_total ,t1.mit_sap_account,t2.award_number,t2.sequence_number 
		from sap_feed t1
		inner join sap_feed_details t2 on t1.feed_id = t2.feed_id
		where t1.batch_id = as_batch_id
		and t1.spon_code = ls_sap_spon_code;
		
	r_cs_award c_cs_award%rowtype;
		
begin	
	
	begin				
		select val into ls_award_budget_status from krcr_parm_t where parm_nm = 'SAP_AWD_BUD_FEED_STATUS';
	
	exception
	when others then
		raise_application_error(-20101, 'Error occured while fetching SAP_AWD_BUD_FEED_STATUS. '||sqlerrm);
		return -1;
	end;
	
	select val into ls_sap_feed_fiscal_year from krcr_parm_t where parm_nm = 'SAP_FEED_CURRENT_FISCAL_YEAR';
	
	li_no_of_records := 0;
	
	
		SELECT	count(t1.budget_id) INTO li_count
		FROM AWARD_BUDGET_EXT t1
		INNER JOIN AWARD t2 on t1.award_id = t2.award_id
		WHERE t2.status_code != 6 and -- do not include award on hold status 
		t1.AWARD_BUDGET_STATUS_CODE IN ( select regexp_substr(ls_award_budget_status,'[^,]+', 1, level) from dual
												connect by regexp_substr(ls_award_budget_status, '[^,]+', 1, level) is not null );
												
												
		--- checking if there is any cost sharing account in master feed batch id
		SELECT count(t1.feed_id) into li_cost_share_count
		from sap_feed t1
		inner join sap_feed_details t2 on t1.feed_id = t2.feed_id
		where t1.batch_id = as_batch_id
		and t1.spon_code = ls_sap_spon_code;										
		
		IF li_count = 0 AND li_cost_share_count = 0 THEN -- There is nothing to feed
			return -100;
		END IF;	
		
	
		ls_batch_file_name := concat(concat(concat('dospfpl1.', ltrim(to_char(as_batch_id, '000'))), '.'),
															to_char(as_dt_now, 'YYYYMMDDHH24MISS'));
															
		li_sap_budget_feed_batch_id := 	seq_sap_budget_feed_batch_id.nextval;												
		
		INSERT INTO sap_budget_feed_batch_list(
						sap_budget_feed_batch_id,
						batch_id,
						batch_file_name,
						batch_timestamp,
						update_user,
						no_of_records,
						update_timestamp,
						ver_nbr,
						obj_id
						)
				VALUES(
				li_sap_budget_feed_batch_id,
				as_batch_id,
				ls_batch_file_name,
				as_dt_now,
				as_update_user,
				li_no_of_records,
				sysdate,
				1,
				sys_guid()
				);				
	FOR sap_ext_rec in c_sap_bud_ext
	LOOP
		FOR sap_det_rec in c_sap_bud_det(sap_ext_rec.award_number)
		LOOP
			li_sap_budget_feed_details_id := seq_sap_budget_feed_details_id.nextval;
			ls_account_number := sap_det_rec.account_number;
			
			INSERT INTO SAP_BUDGET_FEED_DETAILS(
			SAP_BUDGET_FEED_DETAILS_ID,
			SAP_BUDGET_FEED_BATCH_ID,
			BATCH_ID,
			BUDGET_ID,
			AWARD_NUMBER,
			SEQUENCE_NUMBER,
			FEED_STATUS,
			UPDATE_USER,
			UPDATE_TIMESTAMP,
			VER_NBR,
			OBJ_ID
			)
			VALUES(
			li_sap_budget_feed_details_id,
			li_sap_budget_feed_batch_id,
			as_batch_id,
			sap_ext_rec.budget_id,
			sap_det_rec.award_number,
			sap_det_rec.sequence_number,
			'P',
			lower(as_update_user),
			sysdate,
			1,
			sys_guid()
			);
				li_inserted := 1;
				li_budget_id := sap_ext_rec.budget_id;
				
					open c_award_budget;
					loop
					fetch c_award_budget into r_award_budget;
					exit when c_award_budget%notfound;
					
						if r_award_budget.amount >= 0 then
								ls_amount := '+'||LPAD( ( to_number(r_award_budget.amount) * 100 ), 14, '0');
						else
								ls_amount := '-'||LPAD(ABS( ( to_number(r_award_budget.amount) * 100 )), 14, '0');
						end if;
						
						
						select count(sap_obj_cd) into li_count FROM SAP_KC_OBJ_CD_MAPPING WHERE KC_OBJ_CD = r_award_budget.gl_account_key;
						
						if li_count = 1 then
							SELECT SAP_OBJ_CD into ls_cost_element FROM SAP_KC_OBJ_CD_MAPPING WHERE KC_OBJ_CD = r_award_budget.gl_account_key;
							
						else
							ls_cost_element := r_award_budget.gl_account_key;
							
						end if;
										
					
						INSERT INTO SAP_BUDGET_FEED(
									SAP_BUDGET_FEED_ID,
									SAP_BUDGET_FEED_DETAILS_ID,
									SAP_BUDGET_FEED_BATCH_ID,
									BATCH_ID,
									FISCAL_YEAR,
									ACCOUNT_NUMBER,
									COST_ELEMENT,
									AMOUNT,
									VER_NBR,
									OBJ_ID
									)
						VALUES(  SEQ_SAP_BUDGET_FEED_ID.NEXTVAL,
								 li_sap_budget_feed_details_id,
								 li_sap_budget_feed_batch_id,
								 as_batch_id,
								 ls_sap_feed_fiscal_year,
								 ls_account_number,
								 ls_cost_element,						 
								 ls_amount,
								 1,
								 sys_guid()
							  );
							  
							 li_no_of_records := li_no_of_records + 1; 
							 
					end loop;
					close c_award_budget;
		
	    END LOOP;	
	END LOOP;
		
	--- S T A R T S    cost sharing in the budget feed		
		--- checking if there is any cost sharing account in master feed batch id	
		SELECT count(t1.feed_id) into li_cost_share_count
		from sap_feed t1
		inner join sap_feed_details t2 on t1.feed_id = t2.feed_id
		where t1.batch_id = as_batch_id
		and t1.spon_code = ls_sap_spon_code;	
		
		if li_cost_share_count > 0 then 
		
				open c_cs_award;
				loop
				fetch c_cs_award into r_cs_award;
				exit when c_cs_award%notfound;
				
					ls_auth_total 			:= r_cs_award.auth_total;
					ls_mit_account_number	:= r_cs_award.mit_sap_account;
				
					if to_number(ls_auth_total) >= 0 then
							ls_amount := '+'||LPAD( ( to_number(ls_auth_total) ), 14, '0');
					else
							ls_amount := '-'||LPAD(ABS( ( to_number(ls_auth_total) )), 14, '0');
					end if;
					
					li_sap_budget_feed_details_id := seq_sap_budget_feed_details_id.nextval;					
								
					INSERT INTO SAP_BUDGET_FEED_DETAILS(
					SAP_BUDGET_FEED_DETAILS_ID,
					SAP_BUDGET_FEED_BATCH_ID,
					BATCH_ID,
					BUDGET_ID,
					AWARD_NUMBER,
					SEQUENCE_NUMBER,
					FEED_STATUS,
					UPDATE_USER,
					UPDATE_TIMESTAMP,
					VER_NBR,
					OBJ_ID
					)
					VALUES(
					li_sap_budget_feed_details_id,
					li_sap_budget_feed_batch_id,
					as_batch_id,
					replace(r_cs_award.award_number,'-'),					
					r_cs_award.award_number,
					r_cs_award.sequence_number,
					'P',
					lower(as_update_user),
					sysdate,
					1,
					sys_guid()
					);		
										
					INSERT INTO SAP_BUDGET_FEED(
								SAP_BUDGET_FEED_ID,
								SAP_BUDGET_FEED_DETAILS_ID,
								SAP_BUDGET_FEED_BATCH_ID,
								BATCH_ID,
								FISCAL_YEAR,
								ACCOUNT_NUMBER,
								COST_ELEMENT,
								AMOUNT,
								VER_NBR,
								OBJ_ID
								)
					VALUES(  SEQ_SAP_BUDGET_FEED_ID.NEXTVAL,
							 li_sap_budget_feed_details_id,
							 li_sap_budget_feed_batch_id,
							 as_batch_id,
							 ls_sap_feed_fiscal_year,
							 ls_mit_account_number,
							 '400000',						 
							 ls_amount,
							 1,
							 sys_guid() );
								  
					li_no_of_records := li_no_of_records + 1; 
				
				end loop;
				close c_cs_award;
	
				
		end if;		
	--- E N D S   cost sharing in the budget feed 
		
		UPDATE 	AWARD_BUDGET_EXT SET AWARD_BUDGET_STATUS_CODE = 9 --Posted
		WHERE budget_id IN ( SELECT budget_id FROM SAP_BUDGET_FEED_DETAILS WHERE BATCH_ID = as_batch_id);
		
		UPDATE SAP_BUDGET_FEED_DETAILS SET FEED_STATUS = 'F'  WHERE BATCH_ID = as_batch_id;
		
		UPDATE sap_budget_feed_batch_list SET no_of_records = li_no_of_records  WHERE sap_budget_feed_batch_id = li_sap_budget_feed_batch_id;
		
		COMMIT;		
		
		
	ret := fn_spool_awd_budget_batch(li_sap_budget_feed_batch_id, as_path);

	return li_sap_budget_feed_batch_id;

end;
/
