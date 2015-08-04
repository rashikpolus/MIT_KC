update comm_schedule
set start_time = (start_time + (12/24)) ,
    end_time = (end_time + (12/24)),
	time = (time + (12/24))	
where schedule_id in (select schedule_id from osp$comm_schedule@coeus.kuali)
/
commit
/
