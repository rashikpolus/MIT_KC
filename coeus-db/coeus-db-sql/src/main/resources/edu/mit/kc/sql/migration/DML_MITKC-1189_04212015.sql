insert into DISTRIBUTION(OSP_DISTRIBUTION_CODE,VER_NBR,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,OBJ_ID,ACTIVE_FLAG)
values('-1',1,'dummy',sysdate,'admin',sys_guid(),'Y')
/
commit
/
update AWARD_TEMPLATE_REPORT_TERMS set OSP_DISTRIBUTION_CODE = -1
where OSP_DISTRIBUTION_CODE is null
/
declare
cursor c_templ is
select max(TEMPLATE_REPORT_TERMS_ID) as MAX_TEMPLATE_REPORT_TERMS_ID,AWARD_TEMPLATE_CODE,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE from AWARD_TEMPLATE_REPORT_TERMS 
group by AWARD_TEMPLATE_CODE,REPORT_CLASS_CODE,REPORT_CODE,FREQUENCY_CODE,FREQUENCY_BASE_CODE,OSP_DISTRIBUTION_CODE,DUE_DATE
having count(AWARD_TEMPLATE_CODE)>1;
r_templ c_templ%rowtype;

begin
     if c_templ%isopen then
	    close c_templ;
	 end if;
	 open c_templ;
	 loop
	 fetch c_templ into r_templ;
	 exit when c_templ%notfound;
	        
		if r_templ.DUE_DATE is not null then
	         update AWARD_TEMPL_REP_TERMS_RECNT
			 set TEMPLATE_REPORT_TERMS_ID = r_templ.MAX_TEMPLATE_REPORT_TERMS_ID
			 where TEMPLATE_REPORT_TERMS_ID in(select TEMPLATE_REPORT_TERMS_ID from AWARD_TEMPLATE_REPORT_TERMS 
			 where TEMPLATE_REPORT_TERMS_ID <> r_templ.MAX_TEMPLATE_REPORT_TERMS_ID	
             and AWARD_TEMPLATE_CODE = r_templ.AWARD_TEMPLATE_CODE
             and REPORT_CLASS_CODE = r_templ.REPORT_CLASS_CODE
             and REPORT_CODE = r_templ.REPORT_CODE	
             and FREQUENCY_CODE = r_templ.FREQUENCY_CODE
             and FREQUENCY_BASE_CODE = r_templ.FREQUENCY_BASE_CODE
             and OSP_DISTRIBUTION_CODE = r_templ.OSP_DISTRIBUTION_CODE
             and DUE_DATE = r_templ.DUE_DATE);			 
	 
             delete from AWARD_TEMPLATE_REPORT_TERMS
			 where TEMPLATE_REPORT_TERMS_ID <> r_templ.MAX_TEMPLATE_REPORT_TERMS_ID
             and AWARD_TEMPLATE_CODE = r_templ.AWARD_TEMPLATE_CODE
             and REPORT_CLASS_CODE = r_templ.REPORT_CLASS_CODE
             and REPORT_CODE = r_templ.REPORT_CODE	
             and FREQUENCY_CODE = r_templ.FREQUENCY_CODE
             and FREQUENCY_BASE_CODE = r_templ.FREQUENCY_BASE_CODE
             and OSP_DISTRIBUTION_CODE = r_templ.OSP_DISTRIBUTION_CODE
             and DUE_DATE = r_templ.DUE_DATE;
		else
            
            update AWARD_TEMPL_REP_TERMS_RECNT
			 set TEMPLATE_REPORT_TERMS_ID = r_templ.MAX_TEMPLATE_REPORT_TERMS_ID
			 where TEMPLATE_REPORT_TERMS_ID in(select TEMPLATE_REPORT_TERMS_ID from AWARD_TEMPLATE_REPORT_TERMS 
			 where TEMPLATE_REPORT_TERMS_ID <> r_templ.MAX_TEMPLATE_REPORT_TERMS_ID	
             and AWARD_TEMPLATE_CODE = r_templ.AWARD_TEMPLATE_CODE
             and REPORT_CLASS_CODE = r_templ.REPORT_CLASS_CODE
             and REPORT_CODE = r_templ.REPORT_CODE	
             and FREQUENCY_CODE = r_templ.FREQUENCY_CODE
             and FREQUENCY_BASE_CODE = r_templ.FREQUENCY_BASE_CODE
             and OSP_DISTRIBUTION_CODE = r_templ.OSP_DISTRIBUTION_CODE);			 
	 
             delete from AWARD_TEMPLATE_REPORT_TERMS
			 where TEMPLATE_REPORT_TERMS_ID <> r_templ.MAX_TEMPLATE_REPORT_TERMS_ID
             and AWARD_TEMPLATE_CODE = r_templ.AWARD_TEMPLATE_CODE
             and REPORT_CLASS_CODE = r_templ.REPORT_CLASS_CODE
             and REPORT_CODE = r_templ.REPORT_CODE	
             and FREQUENCY_CODE = r_templ.FREQUENCY_CODE
             and FREQUENCY_BASE_CODE = r_templ.FREQUENCY_BASE_CODE
             and OSP_DISTRIBUTION_CODE = r_templ.OSP_DISTRIBUTION_CODE;			
		end if;	 
	 end loop;
     close 	c_templ;
end;
/	 
update AWARD_TEMPLATE_REPORT_TERMS set OSP_DISTRIBUTION_CODE = null where OSP_DISTRIBUTION_CODE = -1
/
delete from DISTRIBUTION where OSP_DISTRIBUTION_CODE = -1
/
commit
/
declare
cursor c_templ is
select max(TEMPL_REP_TERMS_RECNT_ID) as TEMPL_REP_TERMS_RECNT_ID,TEMPLATE_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES from AWARD_TEMPL_REP_TERMS_RECNT
group by TEMPLATE_REPORT_TERMS_ID,CONTACT_TYPE_CODE,ROLODEX_ID,NUMBER_OF_COPIES
having count(TEMPL_REP_TERMS_RECNT_ID)>1;			 
r_templ c_templ%rowtype;

begin
     if c_templ%isopen then
	    close c_templ;
	 end if;
	 open c_templ;
	 loop
	 fetch c_templ into r_templ;
	 exit when c_templ%notfound;
          

            delete from AWARD_TEMPL_REP_TERMS_RECNT
            where TEMPL_REP_TERMS_RECNT_ID <> r_templ.TEMPL_REP_TERMS_RECNT_ID
            and TEMPLATE_REPORT_TERMS_ID = r_templ.TEMPLATE_REPORT_TERMS_ID
            and CONTACT_TYPE_CODE = r_templ.CONTACT_TYPE_CODE
            and ROLODEX_ID = r_templ.ROLODEX_ID;	
           
	 end loop;
     close 	c_templ;
end;
/	 	