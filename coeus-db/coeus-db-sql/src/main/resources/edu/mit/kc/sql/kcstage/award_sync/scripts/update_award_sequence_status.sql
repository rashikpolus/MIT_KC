select ' Started award_sequence_status_update ' from dual
/
DECLARE
ls_award_sequence_status VARCHAR2(10);
li_count number;
ls_doc VARCHAR2(40);

CURSOR c_sync IS
select award_number , max(sequence_number) sequence_number from award 
where award_number in ( select replace(mit_award_number,'-','-00') from TEMP_TAB_TO_SYNC_AWARD)
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
/*
DECLARE
ls_award_sequence_status VARCHAR2(10);
li_count number;
ls_doc VARCHAR2(40);

CURSOR c_sync IS
select award_number , max(sequence_number) sequence_number from award 
where award_number in ( select replace(mit_award_number,'-','-00') from TEMP_TAB_TO_SYNC_AWARD)
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

BEGIN
SELECT AWARD_SEQUENCE_STATUS into ls_award_sequence_status FROM AWARD WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER-1;
EXCEPTION 
WHEN OTHERS THEN
ls_award_sequence_status:=NULL;
END;
IF ls_award_sequence_status IS NOT NULL THEN
    
    IF ls_award_sequence_status='ACTIVE' THEN
   
        UPDATE AWARD
        SET AWARD_SEQUENCE_STATUS='ARCHIVED'
        WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER;
        
         update  VERSION_HISTORY t1 set t1.version_status ='ARCHIVED'
	       where t1.seq_owner_version_name_value = r_sync.award_number;
         
        UPDATE AWARD
        SET AWARD_SEQUENCE_STATUS='ACTIVE'
        WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER
        AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER;
        
         update  VERSION_HISTORY t1 set t1.version_status ='ACTIVE'
	       where t1.seq_owner_version_name_value = r_sync.award_number
	       and t1.seq_owner_seq_number = r_sync.sequence_number;
         
     ELSIF ls_award_sequence_status='PENDING' THEN
     
          
            SELECT count(AWARD_NUMBER) into li_count FROM AWARD WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER-2;
            
            IF li_count>0 THEN
            
                UPDATE AWARD
                SET AWARD_SEQUENCE_STATUS='ARCHIVED'
                WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER;
                
        
                update  VERSION_HISTORY t1 set t1.version_status ='ARCHIVED'
                where t1.seq_owner_version_name_value = r_sync.award_number;
	             
                
                UPDATE AWARD
                SET AWARD_SEQUENCE_STATUS='ACTIVE'
                WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER
                AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER-1;
        
                update  VERSION_HISTORY t1 set t1.version_status ='ACTIVE'
                where t1.seq_owner_version_name_value = r_sync.award_number
	              and t1.seq_owner_seq_number = r_sync.sequence_number-1;
                
                select document_number into ls_doc from award where award_number=r_sync.award_number and sequence_number=r_sync.sequence_number-1;
                
                UPDATE KREW_DOC_HDR_T
                SET DOC_HDR_STAT_CD='F'
                WHERE DOC_HDR_ID=ls_doc;
                
                
                UPDATE AWARD
                SET AWARD_SEQUENCE_STATUS='PENDING'
                WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER
                AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER;
        
                update  VERSION_HISTORY t1 set t1.version_status ='PENDING'
                where t1.seq_owner_version_name_value = r_sync.award_number
	              and t1.seq_owner_seq_number = r_sync.sequence_number;
                
                select document_number into ls_doc from award where award_number=r_sync.award_number and sequence_number=r_sync.sequence_number;
                
                UPDATE KREW_DOC_HDR_T
                SET DOC_HDR_STAT_CD='S'
                WHERE DOC_HDR_ID=ls_doc;
                
         ELSE
         
                UPDATE AWARD
                SET AWARD_SEQUENCE_STATUS='ACTIVE'
                WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER
                AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER-1;
        
                update  VERSION_HISTORY t1 set t1.version_status ='ACTIVE'
                where t1.seq_owner_version_name_value = r_sync.award_number
	              and t1.seq_owner_seq_number = r_sync.sequence_number-1;
                
                select document_number into ls_doc from award where award_number=r_sync.award_number and sequence_number=r_sync.sequence_number-1;
                
                UPDATE KREW_DOC_HDR_T
                SET DOC_HDR_STAT_CD='F'
                WHERE DOC_HDR_ID=ls_doc;
                
                
                UPDATE AWARD
                SET AWARD_SEQUENCE_STATUS='PENDING'
                WHERE AWARD_NUMBER=r_sync.AWARD_NUMBER
                AND SEQUENCE_NUMBER=r_sync.SEQUENCE_NUMBER;
        
                update  VERSION_HISTORY t1 set t1.version_status ='PENDING'
                where t1.seq_owner_version_name_value = r_sync.award_number
	              and t1.seq_owner_seq_number = r_sync.sequence_number;
                
                select document_number into ls_doc from award where award_number=r_sync.award_number and sequence_number=r_sync.sequence_number;
                
                UPDATE KREW_DOC_HDR_T
                SET DOC_HDR_STAT_CD='S'
                WHERE DOC_HDR_ID=ls_doc;
                
        END IF;
        
   END IF;
END IF;
END LOOP;
CLOSE c_sync;
END;
/
*/
select ' Ended award_sequence_status_update ' from dual
/