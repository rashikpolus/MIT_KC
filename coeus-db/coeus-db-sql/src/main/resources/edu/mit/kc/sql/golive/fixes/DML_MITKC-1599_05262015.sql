DECLARE
  li_count number;
BEGIN
  select  count(*) into li_count from REPORT where DESCRIPTION='Payment/Invoice Frequency';
  if li_count = 0 then 
     INSERT INTO REPORT(REPORT_CODE,VER_NBR,DESCRIPTION,FINAL_REPORT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,ACTIVE_FLAG)
     VALUES('112',1,'Payment/Invoice Frequency','N',SYSDATE,'admin', SYS_GUID(),'Y');
     
  end if;

  select  count(*) into li_count from REPORT where DESCRIPTION='Final Invoice Due';
  if li_count = 0 then 
     INSERT INTO REPORT(REPORT_CODE,VER_NBR,DESCRIPTION,FINAL_REPORT_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,ACTIVE_FLAG)
     VALUES('113',1,'Final Invoice Due','N',SYSDATE,'admin', SYS_GUID(),'Y');
     
  end if;
  
  select  count(*) into li_count from VALID_CLASS_REPORT_FREQ where REPORT_CODE = '112';
  if li_count = 0 then 
    Insert into VALID_CLASS_REPORT_FREQ (VALID_CLASS_REPORT_FREQ_ID,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
    select (select max(VALID_CLASS_REPORT_FREQ_ID) + 1 from VALID_CLASS_REPORT_FREQ) + rownum,
            '6',
            '112',
            t1.FREQUENCY_CODE,
            sysdate,
            'admin',
            0,
            SYS_GUID()
    from 
    (select distinct PAYMENT_INVOICE_FREQ_CODE as FREQUENCY_CODE    
          from osp$award_header@coeus.kuali t1
          where t1.PAYMENT_INVOICE_FREQ_CODE is not null)t1;
    
   end if;       
 
  select  count(*) into li_count from VALID_CLASS_REPORT_FREQ where REPORT_CODE = '113';
  if li_count = 0 then   
    Insert into VALID_CLASS_REPORT_FREQ (VALID_CLASS_REPORT_FREQ_ID,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,UPDATE_TIMESTAMP,
    UPDATE_USER,VER_NBR,OBJ_ID)
    values((select max(VALID_CLASS_REPORT_FREQ_ID) + 1 from VALID_CLASS_REPORT_FREQ),'6','113','14',sysdate,'admin',0,SYS_GUID()); 
    
  end if;    
  
   select count(CONTACT_TYPE_CODE) into li_count from CONTACT_TYPE where DESCRIPTION='Payment Invoice Contact';
   if li_count = 0 then
      INSERT INTO CONTACT_TYPE(CONTACT_TYPE_CODE,VER_NBR,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID)
      VALUES('43',1,'Payment Invoice Contact',sysdate,'admin',SYS_GUID());
   end if;
  

END;
/
