create or replace
function fn_generate_sap_feed
					(as_path in VARCHAR2,
					as_update_user in VARCHAR2,
					as_batch_id in number,
					as_ld_now in date)
return number is
li_feed_id 					SAP_FEED_DETAILS.FEED_ID%TYPE;
award_number 				SAP_FEED_DETAILS.AWARD_NUMBER%TYPE;
sequence_number  			SAP_FEED_DETAILS.SEQUENCE_NUMBER%TYPE;
feed_type 					SAP_FEED_DETAILS.FEED_TYPE%TYPE;
li_batch_id 				SAP_FEED_BATCH_LIST.BATCH_ID%TYPE;
rec_batch_list 				SAP_FEED_BATCH_LIST%ROWTYPE;
ld_now						DATE;
li_feed_count				number;
li_sort_id					SAP_FEED.SORT_ID%TYPE;
li_sap_feed_batch       	SAP_FEED_BATCH_LIST.SAP_FEED_BATCH_ID%TYPE;
ls_TransactionID			SAP_FEED_DETAILS.TRANSACTION_ID%TYPE;

ret 							number;

cursor cur_pending_transactions IS
		 SELECT DISTINCT SAP_FEED_DETAILS.TRANSACTION_ID
			FROM SAP_FEED_DETAILS
			WHERE SAP_FEED_DETAILS.FEED_STATUS = 'P'
			ORDER BY SAP_FEED_DETAILS.TRANSACTION_ID ASC   ;


cursor cur_pending_feeds_minus (trans_id VARCHAR2 ) is
			SELECT SAP_FEED_DETAILS.FEED_ID,
         			 SAP_FEED_DETAILS.AWARD_NUMBER,
         			 SAP_FEED_DETAILS.SEQUENCE_NUMBER,
         			 SAP_FEED_DETAILS.FEED_TYPE
    					 FROM SAP_FEED_DETAILS,AWARD_AMOUNT_INFO
  						 WHERE SAP_FEED_DETAILS.FEED_STATUS = 'P'  AND
						 SAP_FEED_DETAILS.TRANSACTION_ID = trans_id AND
						 SAP_FEED_DETAILS.TRANSACTION_ID = AWARD_AMOUNT_INFO.TRANSACTION_ID(+)  AND
						 SAP_FEED_DETAILS.AWARD_NUMBER = AWARD_AMOUNT_INFO.AWARD_NUMBER (+) AND
						 AWARD_AMOUNT_INFO.OBLIGATED_CHANGE < 0
						 ORDER BY SAP_FEED_DETAILS.AWARD_NUMBER desc  ;

cursor cur_pending_feeds (trans_id VARCHAR2 ) is
			SELECT SAP_FEED_DETAILS.FEED_ID,
         			 SAP_FEED_DETAILS.AWARD_NUMBER,
         			 SAP_FEED_DETAILS.SEQUENCE_NUMBER,
         			 SAP_FEED_DETAILS.FEED_TYPE
    					 FROM SAP_FEED_DETAILS,AWARD_AMOUNT_INFO
  						 WHERE SAP_FEED_DETAILS.FEED_STATUS = 'P'  AND
						 SAP_FEED_DETAILS.TRANSACTION_ID = trans_id AND
						 SAP_FEED_DETAILS.TRANSACTION_ID = AWARD_AMOUNT_INFO.TRANSACTION_ID(+)  AND
						 SAP_FEED_DETAILS.AWARD_NUMBER = AWARD_AMOUNT_INFO.AWARD_NUMBER (+) AND
						 ((AWARD_AMOUNT_INFO.OBLIGATED_CHANGE >= 0) OR (AWARD_AMOUNT_INFO.OBLIGATED_CHANGE IS NULL))
						 ORDER BY SAP_FEED_DETAILS.FEED_ID ASC  ;

begin

	SELECT COUNT(SAP_FEED_DETAILS.FEED_ID)
	INTO li_feed_count
	 FROM SAP_FEED_DETAILS
 	 WHERE SAP_FEED_DETAILS.FEED_STATUS = 'P'   ;

	IF li_feed_count < 1 THEN   --IF there are no feeds pending then exit with -100
		--dbms_output.put_line('< 1');
		return (-100);
		--return;
	END IF;
	-- Modified with COEUSDEV-563:Award Sync to Parent is not triggering SAP feed
	
	/*SELECT seq_sap_batch_id.NEXTVAL, sysdate
	INTO li_batch_id, ld_now
	FROM DUAL;
	*/
	ld_now 		:= as_ld_now;
	li_batch_id := as_batch_id;
	-- COEUSDEV-563:End

--dbms_output.put_line('sel from dual');

	rec_batch_list.no_of_records := 0;
	rec_batch_list.batch_id := li_batch_id;
	rec_batch_list.batch_timestamp := ld_now;
	-- Modified with COEUSDEV-563:Award Sync to Parent is not triggering SAP feed
	rec_batch_list.update_user := lower(as_update_user);
	-- COEUSDEV-563:End
	rec_batch_list.batch_file_name := concat(concat(concat('dospfmas.', ltrim(to_char(li_batch_id, '000'))), '.'),
															to_char(ld_now, 'YYYYMMDDHH24MISS'));
----dbms_output.put_line('before insert');

	select SEQ_SAP_FEED_BATCH_ID.nextval into li_sap_feed_batch from dual;
	rec_batch_list.SAP_FEED_BATCH_ID := li_sap_feed_batch;
	
	INSERT INTO SAP_FEED_BATCH_LIST
	VALUES (rec_batch_list.SAP_FEED_BATCH_ID,rec_batch_list.batch_id, rec_batch_list.batch_file_name,
			  rec_batch_list.batch_timestamp, rec_batch_list.update_user,
				rec_batch_list.no_of_records,sysdate,1,sys_guid());

	--dbms_output.put_line('after insert');

	open cur_pending_transactions;

	li_sort_id := 0;
	loop
		fetch cur_pending_transactions into ls_TransactionID;
		exit when cur_pending_transactions%NOTFOUND;

		--Process all negative changes for this transaction
		open cur_pending_feeds_minus (ls_TransactionID);

		loop
			fetch cur_pending_feeds_minus into li_feed_id,award_number,
			  												sequence_number, feed_type;
			exit when cur_pending_feeds_minus%NOTFOUND;

			li_sort_id := li_sort_id + 1;
			ret := kc_sap_feed_pkg.generate_feed(li_sap_feed_batch,li_batch_id, li_feed_id,award_number,sequence_number,
													feed_type, ls_TransactionID, li_sort_id);

			IF ret = -1 THEN

      		UPDATE SAP_FEED_DETAILS
     			SET FEED_STATUS = 'E',
				 	BATCH_ID    =  li_batch_id,
					SAP_FEED_BATCH_ID = li_sap_feed_batch
   			WHERE SAP_FEED_DETAILS.FEED_ID = li_feed_id   ;
			ELSE

				UPDATE SAP_FEED_DETAILS
     			SET FEED_STATUS = 'F',				
   			 	BATCH_ID    =  li_batch_id,
				SAP_FEED_BATCH_ID = li_sap_feed_batch
   			WHERE SAP_FEED_DETAILS.FEED_ID = li_feed_id   ;

				rec_batch_list.no_of_records := rec_batch_list.no_of_records + 1;

			END IF;

		end loop;  --end of minus loop
		close cur_pending_feeds_minus;

		--Process rest of the changes for this transaction

		open cur_pending_feeds (ls_TransactionID);

		loop
			fetch cur_pending_feeds into li_feed_id,award_number,
			  												sequence_number, feed_type;
			exit when cur_pending_feeds%NOTFOUND;

			li_sort_id := li_sort_id + 1;
			ret := kc_sap_feed_pkg.generate_feed(li_sap_feed_batch,li_batch_id, li_feed_id,award_number, sequence_number,
													feed_type, ls_TransactionID, li_sort_id);

			IF ret = -1 THEN

      		UPDATE SAP_FEED_DETAILS
     			SET FEED_STATUS = 'E',
				 	BATCH_ID    =  li_batch_id,
					SAP_FEED_BATCH_ID = li_sap_feed_batch
   			WHERE SAP_FEED_DETAILS.FEED_ID = li_feed_id   ;
			ELSE

				UPDATE SAP_FEED_DETAILS
     			SET FEED_STATUS = 'F',
   			 	BATCH_ID    =  li_batch_id,
				SAP_FEED_BATCH_ID = li_sap_feed_batch
   			WHERE SAP_FEED_DETAILS.FEED_ID = li_feed_id   ;

				rec_batch_list.no_of_records := rec_batch_list.no_of_records + 1;

			END IF;

		end loop;  --end of cur_pending_feeds loop
		close cur_pending_feeds;

	end loop; --end of transactions loop


	CLOSE cur_pending_transactions;

	  UPDATE SAP_FEED_BATCH_LIST
     SET NO_OF_RECORDS = rec_batch_list.no_of_records
		WHERE SAP_FEED_BATCH_LIST.SAP_FEED_BATCH_ID = li_sap_feed_batch;

		COMMIT;

	ret := fn_spool_batch(li_sap_feed_batch,li_batch_id, as_path);

	return (li_sap_feed_batch);

end;
/