create or replace function fn_sap_resend_batch(
ai_sap_feed_batch_id number,
ai_batch_id number,
ai_need_subsequent in number, 
as_path in varchar2
) return number is
li_return number;
li_total_resend number;
begin
 
  li_total_resend := 0;
  
  IF ai_need_subsequent = 1 THEN -- this mean need to resend subsequent batches also 
     FOR rec in (  select sap_feed_batch_id from sap_feed_batch_list where sap_feed_batch_id >= ai_sap_feed_batch_id ) 
      LOOP
        begin
            li_return := fn_spool_batch(rec.sap_feed_batch_id ,ai_batch_id, as_path);
            li_total_resend := li_total_resend + 1;
        exception
         when others then
          null;
        end;
     END LOOP;
 
  ELSE   -- just resend the input sap feed batch id
      begin
           li_return := fn_spool_batch(ai_sap_feed_batch_id ,ai_batch_id, as_path);
           li_total_resend := li_total_resend + 1;
      exception
      when others then
         null;
      end;
     
  END IF;  
  
  return li_total_resend;
  
END;
/
