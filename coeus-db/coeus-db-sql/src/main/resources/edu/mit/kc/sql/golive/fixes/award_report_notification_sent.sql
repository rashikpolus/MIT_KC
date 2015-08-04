set serveroutput on;
declare
	ls_award_number varchar2(12);
	li_award_report_terms number(12,0);
	ls_person_id varchar2(40);
	li_rolodex_id number(8,0);
	li_count number;
	cursor c_notif is
	select distinct replace(a.MIT_AWARD_NUMBER,'-','-00') MIT_AWARD_NUMBER,a.REPORT_CLASS_CODE,a.REPORT_CODE,
	a.FREQUENCY_CODE,a.FREQUENCY_BASE_CODE,a.OSP_DISTRIBUTION_CODE,n.person_id,
	a.DUE_DATE,a.REPORT_STATUS_CODE,t.ACTION_CODE,t.START_DATE, t.RUN_DATE,t.END_DATE, a.UPDATE_TIMESTAMP,a.UPDATE_USER 
	from OSP$AWARD_REPORTING@coeus.kuali a 
	inner join OSP$NOTIFICATION_DETAILS@coeus.kuali n on a.MIT_AWARD_NUMBER = n.MODULE_ITEM_KEY and a.REPORT_NUMBER = n.REPORT_NUMBER
	inner join OSP$NOTIFICATION@coeus.kuali t on n.NOTIFICATION_ID = t.NOTIFICATION_ID;
	r_notif c_notif%rowtype;

begin
	if c_notif%isopen then
	close c_notif;
	end if;
	open c_notif;
	
	loop
	fetch c_notif into r_notif;
	exit when c_notif%notfound;

		 select count(*) into li_count from KC_MIG_AWARD_CONV where AWARD_NUMBER = r_notif.MIT_AWARD_NUMBER;
		 
		 if li_count = 0 then		   
		   ls_award_number := r_notif.MIT_AWARD_NUMBER;
		   
		 else 		 
		   select CHANGE_AWARD_NUMBER into ls_award_number from KC_MIG_AWARD_CONV where AWARD_NUMBER = r_notif.MIT_AWARD_NUMBER;
		   
		 end if;
		 
		/*
		begin
			 select ap.person_id,ap.rolodex_id into ls_person_id,li_rolodex_id 
			 from award_persons ap 
			 where ap.sequence_number = (select max(aw.sequence_number) from award_persons aw where aw.award_number=ap.award_number) 
			 and ap.contact_role_code ='PI'
			 and ap.award_number = ls_award_number;
		 exception
		 when others then
			dbms_output.put_line('PI is missing for award_number:'||ls_award_number ||', '||sqlerrm);
			continue;
		 end;
		*/
		IF r_notif.DUE_DATE IS NULL THEN
		 
				 begin
					 select MIN(AWARD_REPORT_TERM_ID) into li_award_report_terms from AWARD_REPORT_TRACKING
					 where AWARD_NUMBER = ls_award_number
					 and ( PI_PERSON_ID = r_notif.person_id or PI_ROLODEX_ID = r_notif.person_id)
					 and REPORT_CLASS_CODE = r_notif.REPORT_CLASS_CODE
					 and REPORT_CODE = r_notif.REPORT_CODE
					 and nvl(FREQUENCY_CODE,-1) = r_notif.FREQUENCY_CODE
					 and nvl(FREQUENCY_BASE_CODE,-1) = r_notif.FREQUENCY_BASE_CODE
					 and nvl(OSP_DISTRIBUTION_CODE,-1) = r_notif.OSP_DISTRIBUTION_CODE
					 and STATUS_CODE = r_notif.REPORT_STATUS_CODE;
				 exception
				 when others then
					li_award_report_terms := null;
					dbms_output.put_line('AWARD_NUMBER:'||ls_award_number||'PERSON_ID:'||r_notif.person_id||'REPORT_CLASS:'
					||r_notif.REPORT_CLASS_CODE||'REPORT_CODE:'||r_notif.REPORT_CODE||'FREQUENCY_CODE:'||r_notif.FREQUENCY_CODE||'FREQUENCY_BASE_CODE:'
					||r_notif.FREQUENCY_BASE_CODE||'OSP_DISTRIBUTION_CODE:'||r_notif.OSP_DISTRIBUTION_CODE);					
				 end ;
		ELSE
		
				 begin
					 select MIN(AWARD_REPORT_TERM_ID) into li_award_report_terms from AWARD_REPORT_TRACKING
					 where AWARD_NUMBER = ls_award_number
					 and ( PI_PERSON_ID = r_notif.person_id or PI_ROLODEX_ID = r_notif.person_id )
					 and REPORT_CLASS_CODE = r_notif.REPORT_CLASS_CODE
					 and REPORT_CODE = r_notif.REPORT_CODE
					 and nvl(FREQUENCY_CODE,-1) = r_notif.FREQUENCY_CODE
					 and nvl(FREQUENCY_BASE_CODE,-1) = r_notif.FREQUENCY_BASE_CODE
					 and nvl(OSP_DISTRIBUTION_CODE,-1) = r_notif.OSP_DISTRIBUTION_CODE
					 and STATUS_CODE = r_notif.REPORT_STATUS_CODE
					 and DUE_DATE = r_notif.DUE_DATE;
				 exception
				 when others then
					li_award_report_terms := null;
					dbms_output.put_line('AWARD_NUMBER:'||ls_award_number||'PERSON_ID:'||r_notif.person_id||'REPORT_CLASS:'
					||r_notif.REPORT_CLASS_CODE||'REPORT_CODE:'||r_notif.REPORT_CODE||'FREQUENCY_CODE:'||r_notif.FREQUENCY_CODE||'FREQUENCY_BASE_CODE:'
					||r_notif.FREQUENCY_BASE_CODE||'OSP_DISTRIBUTION_CODE:'||r_notif.OSP_DISTRIBUTION_CODE);					
				 end ;
					 
		END IF;
			
		if li_award_report_terms is not null then 
			begin
				insert into AWARD_REPORT_NOTIFICATION_SENT(AWARD_REPORT_TERM_ID,
														AWARD_NUMBER,
														DUE_DATE,
														SENT_DATE,
														ACTION_CODE,
														UPDATE_TIMESTAMP,
														UPDATE_USER,
														VER_NBR,
														OBJ_ID)
												  values(li_award_report_terms,
														 ls_award_number,
														 nvl(r_notif.DUE_DATE,sysdate),
														 r_notif.START_DATE,
														 r_notif.ACTION_CODE,
														 r_notif.UPDATE_TIMESTAMP,
														 r_notif.UPDATE_USER,
														 1,
														 sys_guid());
			exception
			when others then
				dbms_output.put_line('Error in AWARD_REPORT_NOTIFICATION_SENT , award_number:'||ls_award_number||' .'||sqlerrm);
				continue;
			end;											 
		
		end if;	
													 
	end loop;
	close c_notif;
end;
/