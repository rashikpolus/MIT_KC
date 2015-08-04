create or replace procedure upd_sap_feed_log_error(sap_feed_batch_id number, batch_id in number, feed_id in number,
                                      error_message in varchar2) as
begin
	INSERT INTO SAP_FEED_ERROR_LOG
         ( SAP_FEED_ERROR_ID,
			SAP_FEED_BATCH_ID,
			BATCH_ID,
			  FEED_ID,
           ERROR_MESSAGE,
           UPDATE_USER,
           UPDATE_TIMESTAMP,
           VER_NBR,
           OBJ_ID)
 	 VALUES ( 
			SEQ_SAP_FEED_ERROR_ID.nextval,
			sap_feed_batch_id,
			batch_id,
			feed_id,
           error_message,
           USER,
           SYSDATE,
           1,
           SYS_GUID())  ;
end;
/