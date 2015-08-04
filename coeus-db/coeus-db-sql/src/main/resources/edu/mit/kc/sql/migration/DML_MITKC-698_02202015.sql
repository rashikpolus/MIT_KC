declare
ls_report_code varchar2(3);
ls_report_code_1 varchar2(3);
li_template_report number(12,0);

cursor c_temp_report is
select TEMPLATE_CODE,NON_COMPETING_CONT_PRPSL_DUE,BASIS_OF_PAYMENT_CODE,METHOD_OF_PAYMENT_CODE,UPDATE_TIMESTAMP,UPDATE_USER from OSP$TEMPLATE@coeus.kuali
where NON_COMPETING_CONT_PRPSL_DUE is not null and NON_COMPETING_CONT_PRPSL_DUE<>0;
r_temp_report c_temp_report%rowtype;

begin

   select  REPORT_CODE into ls_report_code from report where description = 'Non-competing Continuation';
   
   if c_temp_report%isopen then
     close c_temp_report;
   end if;
   open c_temp_report;
   loop
   fetch c_temp_report into r_temp_report;
   exit when c_temp_report%notfound;
   
             
             select SEQ_AWARD_TEMPLATE.NEXTVAL into li_template_report from dual;

       insert into AWARD_TEMPLATE_REPORT_TERMS(
                   TEMPLATE_REPORT_TERMS_ID,
                   VER_NBR,
                   AWARD_TEMPLATE_CODE,
                   REPORT_CLASS_CODE,
                   REPORT_CODE,
                   FREQUENCY_CODE,
                   FREQUENCY_BASE_CODE,
                   OSP_DISTRIBUTION_CODE,
                   DUE_DATE,
                   UPDATE_TIMESTAMP,
                   UPDATE_USER,
                   OBJ_ID)
		   values( li_template_report,
		           1,
				   r_temp_report.TEMPLATE_CODE,
				   '7',
				   ls_report_code,
				   r_temp_report.NON_COMPETING_CONT_PRPSL_DUE,
				   null,
				   null,
				   null,
				   r_temp_report.UPDATE_TIMESTAMP,
				   r_temp_report.UPDATE_USER,
				   sys_guid()); 
				   
    end loop;
    close c_temp_report;
end;
/
declare
ls_report_code varchar2(3);
li_template_report number(12,0);

cursor c_temp_report is
select TEMPLATE_CODE,COMPETING_RENEWAL_PRPSL_DUE,BASIS_OF_PAYMENT_CODE,METHOD_OF_PAYMENT_CODE,UPDATE_TIMESTAMP,UPDATE_USER from OSP$TEMPLATE@coeus.kuali
where COMPETING_RENEWAL_PRPSL_DUE is not null and COMPETING_RENEWAL_PRPSL_DUE<>0;
r_temp_report c_temp_report%rowtype;

begin

   select REPORT_CODE into ls_report_code  from REPORT where DESCRIPTION='Competing Renewal';
   
   if c_temp_report%isopen then
     close c_temp_report;
   end if;
   open c_temp_report;
   loop
   fetch c_temp_report into r_temp_report;
   exit when c_temp_report%notfound;
   
             
             select SEQ_AWARD_TEMPLATE.NEXTVAL into li_template_report from dual;

       insert into AWARD_TEMPLATE_REPORT_TERMS(
                   TEMPLATE_REPORT_TERMS_ID,
                   VER_NBR,
                   AWARD_TEMPLATE_CODE,
                   REPORT_CLASS_CODE,
                   REPORT_CODE,
                   FREQUENCY_CODE,
                   FREQUENCY_BASE_CODE,
                   OSP_DISTRIBUTION_CODE,
                   DUE_DATE,
                   UPDATE_TIMESTAMP,
                   UPDATE_USER,
                   OBJ_ID)
		   values( li_template_report,
		           1,
				   r_temp_report.TEMPLATE_CODE,
				   '7',
				   ls_report_code,
				   r_temp_report.COMPETING_RENEWAL_PRPSL_DUE,
				   null,
				   null,
				   null,
				   r_temp_report.UPDATE_TIMESTAMP,
				   r_temp_report.UPDATE_USER,
				   sys_guid()); 
				   
    end loop;
    close c_temp_report;
end;
/		    
declare
ls_report_code varchar2(3);
li_template_report number(12,0);
li_rolodex_id number(12,0):=100046;
ls_contact VARCHAR2(3);
cursor c_temp_report is
select TEMPLATE_CODE,PAYMENT_INVOICE_FREQ_CODE,INVOICE_NUMBER_OF_COPIES,BASIS_OF_PAYMENT_CODE,METHOD_OF_PAYMENT_CODE,UPDATE_TIMESTAMP,UPDATE_USER from OSP$TEMPLATE@coeus.kuali
where PAYMENT_INVOICE_FREQ_CODE is not null and PAYMENT_INVOICE_FREQ_CODE<>0;
r_temp_report c_temp_report%rowtype;

begin

   select REPORT_CODE into ls_report_code from REPORT where DESCRIPTION='Payment/Invoice Frequency';
   select CONTACT_TYPE_CODE into  ls_contact from CONTACT_TYPE where DESCRIPTION='Payment Invoice Contact';
   
   if c_temp_report%isopen then
     close c_temp_report;
   end if;
   open c_temp_report;
   loop
   fetch c_temp_report into r_temp_report;
   exit when c_temp_report%notfound;
   
             
             select SEQ_AWARD_TEMPLATE.NEXTVAL into li_template_report from dual;
			 

       insert into AWARD_TEMPLATE_REPORT_TERMS(
                   TEMPLATE_REPORT_TERMS_ID,
                   VER_NBR,
                   AWARD_TEMPLATE_CODE,
                   REPORT_CLASS_CODE,
                   REPORT_CODE,
                   FREQUENCY_CODE,
                   FREQUENCY_BASE_CODE,
                   OSP_DISTRIBUTION_CODE,
                   DUE_DATE,
                   UPDATE_TIMESTAMP,
                   UPDATE_USER,
                   OBJ_ID)
		   values( li_template_report,
		           1,
				   r_temp_report.TEMPLATE_CODE,
				   '6',
				   ls_report_code,
				   r_temp_report.PAYMENT_INVOICE_FREQ_CODE,
				   null,
				   null,
				   null,
				   r_temp_report.UPDATE_TIMESTAMP,
				   r_temp_report.UPDATE_USER,
				   sys_guid()); 
				   
				   
	   if  r_temp_report.INVOICE_NUMBER_OF_COPIES is not null then
	   
	               insert into AWARD_TEMPL_REP_TERMS_RECNT(TEMPL_REP_TERMS_RECNT_ID,
                                                           TEMPLATE_REPORT_TERMS_ID,
                                                           CONTACT_TYPE_CODE,
                                                           ROLODEX_ID,
                                                           NUMBER_OF_COPIES,
                                                           VER_NBR,
                                                           UPDATE_TIMESTAMP,
                                                           UPDATE_USER,
                                                           OBJ_ID)
												   values (SEQ_AWARD_TEMPLATE.NEXTVAL,
												           li_template_report,
														   ls_contact,
														   li_rolodex_id,
														   r_temp_report.INVOICE_NUMBER_OF_COPIES,
														   1,
														   r_temp_report.UPDATE_TIMESTAMP,
														   r_temp_report.UPDATE_USER,
														   sys_guid());
														   
	    end if;
				   
    end loop;
    close c_temp_report;
end;
/
declare
ls_report_code varchar2(3);
li_template_report number(12,0);
li_rolodex_id number(12,0):=100046;
ls_contact VARCHAR2(3);
cursor c_temp_report is
select TEMPLATE_CODE,FINAL_INVOICE_DUE,INVOICE_NUMBER_OF_COPIES,BASIS_OF_PAYMENT_CODE,METHOD_OF_PAYMENT_CODE,UPDATE_TIMESTAMP,UPDATE_USER from OSP$TEMPLATE@coeus.kuali
where FINAL_INVOICE_DUE is not null;
r_temp_report c_temp_report%rowtype;

begin

    select REPORT_CODE into ls_report_code  from REPORT where DESCRIPTION='Final Invoice Due';
	select CONTACT_TYPE_CODE into  ls_contact from CONTACT_TYPE where DESCRIPTION='Payment Invoice Contact';
   if c_temp_report%isopen then
     close c_temp_report;
   end if;
   open c_temp_report;
   loop
   fetch c_temp_report into r_temp_report;
   exit when c_temp_report%notfound;
   
             
             select SEQ_AWARD_TEMPLATE.NEXTVAL into li_template_report from dual;
			 

       insert into AWARD_TEMPLATE_REPORT_TERMS(
                   TEMPLATE_REPORT_TERMS_ID,
                   VER_NBR,
                   AWARD_TEMPLATE_CODE,
                   REPORT_CLASS_CODE,
                   REPORT_CODE,
                   FREQUENCY_CODE,
                   FREQUENCY_BASE_CODE,
                   OSP_DISTRIBUTION_CODE,
                   DUE_DATE,
                   UPDATE_TIMESTAMP,
                   UPDATE_USER,
                   OBJ_ID)
		   values( li_template_report,
		           1,
				   r_temp_report.TEMPLATE_CODE,
				   '6',
				   ls_report_code,
				   14,
				   6,
				   null,
				   null,
				   r_temp_report.UPDATE_TIMESTAMP,
				   r_temp_report.UPDATE_USER,
				   sys_guid()); 
				   
				   
	   if  r_temp_report.INVOICE_NUMBER_OF_COPIES is not null then
	   
	               insert into AWARD_TEMPL_REP_TERMS_RECNT(TEMPL_REP_TERMS_RECNT_ID,
                                                           TEMPLATE_REPORT_TERMS_ID,
                                                           CONTACT_TYPE_CODE,
                                                           ROLODEX_ID,
                                                           NUMBER_OF_COPIES,
                                                           VER_NBR,
                                                           UPDATE_TIMESTAMP,
                                                           UPDATE_USER,
                                                           OBJ_ID)
												   values (SEQ_AWARD_TEMPLATE.NEXTVAL,
												           li_template_report,
														   ls_contact,
														   li_rolodex_id,
														   r_temp_report.INVOICE_NUMBER_OF_COPIES,
														   1,
														   r_temp_report.UPDATE_TIMESTAMP,
														   r_temp_report.UPDATE_USER,
														   sys_guid());
														   
	    end if;
				   
    end loop;
    close c_temp_report;
end;
/		    		    