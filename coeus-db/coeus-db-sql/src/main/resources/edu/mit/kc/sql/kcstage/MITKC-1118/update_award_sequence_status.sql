select ' Started award_sequence_status_update ' from dual
/
DECLARE
ls_award_sequence_status VARCHAR2(10);
li_count number;
ls_doc VARCHAR2(40);

CURSOR c_sync IS
select award_number , max(sequence_number) sequence_number from award
group by award_number;
r_sync c_sync%rowtype;

BEGIN
IF c_sync%ISOPEN THEN
CLOSE c_sync;
END IF;
OPEN c_sync;
LOOP
FETCH c_sync INTO r_sync;
EXIT WHEN c_sync%NOTFOUND;

        
        UPDATE AWARD
        SET AWARD_SEQUENCE_STATUS='ACTIVE'
        WHERE AWARD_NUMBER = r_sync.AWARD_NUMBER
        AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER;
        
        update  VERSION_HISTORY t1 set t1.version_status ='ACTIVE'
	      where t1.seq_owner_version_name_value = r_sync.award_number
	      and t1.seq_owner_seq_number = r_sync.sequence_number
		    and t1.seq_owner_class_name = 'org.kuali.kra.award.home.Award';
		
        UPDATE AWARD
        SET AWARD_SEQUENCE_STATUS='ARCHIVED'
        WHERE AWARD_NUMBER = r_sync.AWARD_NUMBER
        AND SEQUENCE_NUMBER <> r_sync.SEQUENCE_NUMBER;
        
        update  VERSION_HISTORY t1 set t1.version_status ='ARCHIVED'
	     where t1.seq_owner_version_name_value = r_sync.award_number
	     and t1.seq_owner_seq_number <> r_sync.sequence_number
		  and t1.seq_owner_class_name = 'org.kuali.kra.award.home.Award';
   
		commit;
END LOOP;
CLOSE c_sync;
END;
/
select ' Ended award_sequence_status_update ' from dual
/