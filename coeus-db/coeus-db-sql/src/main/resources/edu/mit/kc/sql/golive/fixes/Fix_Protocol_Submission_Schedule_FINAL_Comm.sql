DECLARE

-- set lastest schedule and committee - where committee document is final
li_schedule_id_fk NUMBER(12);
li_committee_id_fk NUMBER(12);
li_schedule_id VARCHAR2(12);

CURSOR c_p_subm IS
	select a.SUBMISSION_ID, a.SCHEDULE_ID
	from protocol_submission a where a.SCHEDULE_ID is not null;

CURSOR c_sch_min IS
	select c.COMM_SCHEDULE_MINUTES_ID, c.schedule_id_fk
	from COMM_SCHEDULE_MINUTES c;
	
BEGIN

FOR subm_rec in c_p_subm
LOOP

		SELECT max(s.id) into li_schedule_id_fk
  		FROM COMM_SCHEDULE s, committee c, committee_document d
 		WHERE c.id = s.COMMITTEE_ID_FK and d.DOCUMENT_NUMBER = c.DOCUMENT_NUMBER AND 
 		d.DOC_STATUS_CODE = 'F' and s.SCHEDULE_ID = subm_rec.SCHEDULE_ID;
    
    --dbms_output.put_line('asssd'|| li_schedule_id_fk || 'sdsddf');
    
		SELECT committee_id_fk into li_committee_id_fk 
		FROM comm_schedule c
		WHERE c.id = li_schedule_id_fk;

		UPDATE PROTOCOL_SUBMISSION
		set schedule_id_fk = li_schedule_id_fk,
		committee_id_fk = li_committee_id_fk
		WHERE submission_id = subm_rec.SUBMISSION_ID;

END LOOP;

FOR sch_min_rec in c_sch_min
LOOP

		SELECT schedule_id into li_schedule_id 
		FROM comm_schedule 
		WHERE id = sch_min_rec.schedule_id_fk;
		
		SELECT max(s.id) into li_schedule_id_fk
  		FROM COMM_SCHEDULE s, committee c, committee_document d
 		WHERE c.id = s.COMMITTEE_ID_FK and d.DOCUMENT_NUMBER = c.DOCUMENT_NUMBER AND 
 		d.DOC_STATUS_CODE = 'F' and s.SCHEDULE_ID = li_schedule_id;
	
    --dbms_output.put_line('2212112 '|| li_schedule_id_fk || ' 2212112');

		SELECT committee_id_fk into li_committee_id_fk 
		FROM comm_schedule c
		WHERE c.id = li_schedule_id_fk;

		UPDATE COMM_SCHEDULE_MINUTES
		set schedule_id_fk = li_schedule_id_fk
		WHERE COMM_SCHEDULE_MINUTES_ID = sch_min_rec.COMM_SCHEDULE_MINUTES_ID;

END LOOP;

END;
/
	
SELECT *
  FROM protocol_submission
 WHERE schedule_id_fk IN (19599, 19960);  
 
SELECT *
  FROM COMM_SCHEDULE_MINUTES c
 WHERE schedule_id_fk IN (19599, 19960); 
