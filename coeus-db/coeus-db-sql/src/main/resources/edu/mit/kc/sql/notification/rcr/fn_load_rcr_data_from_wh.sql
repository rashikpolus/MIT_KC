CREATE OR REPLACE FUNCTION FN_LOAD_RCR_DATA_FROM_WH
return number is

ls_PersonID  RCR_APPOINTMENTS.PERSON_ID%type;
ls_AccountNumber   RCR_APPOINTMENTS.ACCOUNT_NUMBER%type;
ldt_AppntDate   RCR_APPOINTMENTS.APPOINTMENT_DATE%type;
ls_AppntType  RCR_APPOINTMENTS.APPOINTMENT_TYPE%type;
ldt_loadDate  RCR_APPOINTMENTS.DATA_LOAD_DATE%type;
ldt_PayrollDate RCR_PAYROLL_DATES.BASE_DATE%type;

ls_PayrollPeriodKey  RCR_APPOINTMENTS.APPOINTMENT_TYPE%type;

li_ParyollNumber RCR_PAYROLL_DATES.PAYROLL_NUMBER%type;
li_ret number;


CURSOR C_new_appnt IS 
    select PERSON_ID,
        ACCOUNT_NUMBER,
        APPOINTMENT_DATE,
        APPOINTMENT_TYPE
    from  RCR_APPOINT_WH
    where (PERSON_ID, ACCOUNT_NUMBER) not in 
        (select   distinct PERSON_ID, ACCOUNT_NUMBER   
            from RCR_APPOINTMENTS);
            
CURSOR C_new_payroll IS 
    select PERSON_ID,
        ACCOUNT_NUMBER,
        PAYROLL_PAYMENT_DATE
    from  RCR_PAYROLL_WH
    where (PERSON_ID, ACCOUNT_NUMBER, PAYROLL_PAYMENT_DATE) not in 
        (select  PERSON_ID, ACCOUNT_NUMBER, BASE_DATE 
            from RCR_PAYROLL_DATES
            where PAYROLL_NUMBER = (select max(a.PAYROLL_NUMBER)
                from RCR_PAYROLL_DATES a
                where RCR_PAYROLL_DATES.PERSON_ID = A.PERSON_ID
                and RCR_PAYROLL_DATES.ACCOUNT_NUMBER = A.ACCOUNT_NUMBER));            
            
cursor c_appnt_type is
    Select substr(payroll_edacca_detail.PAYROLL_IN_PERIOD_KEY, 8, 1)
            FROM 
                WAREUSER.Payroll_Edacca_Detail@WAREHOUSE_SDOWDY.MIT.EDU Payroll_Edacca_Detail,
                WAREUSER.Project_Osp@WAREHOUSE_SDOWDY.MIT.EDU Project_Osp 
            where Payroll_Edacca_Detail.mit_id = ls_PersonID
            and Project_Osp.Cost_Collector_Key=Payroll_Edacca_Detail.Cost_Collector_Key
            and  project_osp.project_wbs_id = ls_AccountNumber
     order by payroll_edacca_detail.PAYROLL_IN_PERIOD_KEY asc;
                         
        

BEGIN

    delete from RCR_APPOINT_WH;

    insert into RCR_APPOINT_WH
    Select distinct 
        payroll_edacca_detail.mit_id, 
        project_osp.project_wbs_id, 
        payroll_edacca_detail.appt_begin_date,
        'Regular'
    FROM 
        WAREUSER.Payroll_Edacca_Detail@WAREHOUSE_SDOWDY.MIT.EDU Payroll_Edacca_Detail, 
        WAREUSER.Time_Month@WAREHOUSE_SDOWDY.MIT.EDU  TM, 
        WAREUSER.Hr_Position@WAREHOUSE_SDOWDY.MIT.EDU Hr_Position, 
        WAREUSER.Project_Osp@WAREHOUSE_SDOWDY.MIT.EDU Project_Osp , 
        WAREUSER.Osp_Award_Terms_Detail@WAREHOUSE_SDOWDY.MIT.EDU Osp_Award_Terms_Detail 
    WHERE Project_Osp.Cost_Collector_Key=Payroll_Edacca_Detail.Cost_Collector_Key 
            AND     Hr_Position.Hr_Position_Key=Payroll_Edacca_Detail.Hr_Position_Key 
            AND     TM.Time_Month_Key=Payroll_Edacca_Detail.Time_Month_Key 
            AND     Project_Osp.Mit_Award_Number=Osp_Award_Terms_Detail.Mit_Award_Key
            AND  TM.Fiscal_Year>='2010'  
            AND  Osp_Award_Terms_Detail.OSP_AWARD_TERMS_TYPE_KEY='TRMAPP134'
            AND  ( (Payroll_Edacca_Detail.Hr_Appt_Subtype IN 
                    ('Fellowship', 
                    'Graduate Student Appt', 
                    'Non-Acad Short Term Appt - Non Exempt', 
                    'Student Appointment')) OR 
                (Hr_Position.Position_Title LIKE '%Posrdoc%' OR Hr_Position.Position_Title LIKE '%Postdoc%') OR 
                (Hr_Position.Personnel_Subarea IN ('Fellows', 'Grad Std Fellow', 
                            'Grad Std Mult P', 'Grad Std Other', 
                            'Grad Std RA', 'Grad Std TA', 'Stdt Hrly UGrad', 'UROP')) ) 
           AND Hr_Position.Personnel_Subarea NOT IN ('Service RDTEU')
           AND Payroll_Edacca_Detail.Appt_Begin_Date IN 
            (SELECT MIN ( Payroll_Edacca_Detail1.APPT_BEGIN_DATE ) 
            FROM WAREUSER.Payroll_Edacca_Detail@WAREHOUSE_SDOWDY.MIT.EDU  Payroll_Edacca_Detail1
            WHERE (Payroll_Edacca_Detail1.Cost_Collector_Key=Payroll_Edacca_Detail.COST_COLLECTOR_KEY 
                AND Payroll_Edacca_Detail1.Mit_Id=Payroll_Edacca_Detail.MIT_ID)) ;
                

 	
	open c_new_appnt;
	loop
		fetch c_new_appnt into ls_PersonID, ls_AccountNumber, ldt_AppntDate, ls_AppntType;
		exit when c_new_appnt%NOTFOUND;
        
        ls_PayrollPeriodKey := null;
        open c_appnt_type;
        
        fetch c_appnt_type into ls_PayrollPeriodKey;
               
        close c_appnt_type;
        
        if ls_PayrollPeriodKey is null then
            ls_PayrollPeriodKey := 'U';
        end if;
        
		 begin		
			INSERT INTO RCR_APPOINTMENTS (
			RCR_APPOINT_ID,PERSON_ID, ACCOUNT_NUMBER, APPOINTMENT_DATE, 
			APPOINTMENT_TYPE, DATA_LOAD_DATE, UPDATE_TIMESTAMP, 
			UPDATE_USER,VER_NBR,OBJ_ID) 
			VALUES ( SEQ_RCR_APPOINT_ID.nextval,ls_PersonID, ls_AccountNumber, ldt_AppntDate,
			ls_PayrollPeriodKey, trunc(sysdate), sysdate, user,1,sys_guid());		
		exception
            when others then
                li_ret := 0;
        end;
		
	end loop; 
	close c_new_appnt;

-- Load Payroll Data 

    DELETE FROM RCR_PAYROLL_WH;

    INSERT INTO RCR_PAYROLL_WH
    select distinct a.mit_id, a.PROJECT_WBS_ID, Payroll_Edacca_Detail.PAYROLL_PAYMENT_DATE
    from 
        ( Select distinct payroll_edacca_detail.mit_id, payroll_edacca_detail.Cost_Collector_Key, payroll_edacca_detail.payroll_for_period_key, 
            sum(payroll_edacca_DETAIL.PAYROLL_DIST_AMOUNT), PAYROLL_EDACCA_DETAIL.APPT_BEGIN_DATE, PROJECT_OSP.PROJECT_WBS_ID
             FROM wareuser.Payroll_Edacca_Detail@WAREHOUSE_SDOWDY.MIT.EDU Payroll_Edacca_Detail,  
                  wareuser.Time_Month@WAREHOUSE_SDOWDY.MIT.EDU Time_Month, 
                  wareuser.Hr_Position@WAREHOUSE_SDOWDY.MIT.EDU Hr_Position, 
                  wareuser.Project_Osp@WAREHOUSE_SDOWDY.MIT.EDU Project_Osp, 
                  wareuser.Osp_Award_Terms_Detail@WAREHOUSE_SDOWDY.MIT.EDU Osp_Award_Terms_Detail
           WHERE (Project_Osp.Cost_Collector_Key=Payroll_Edacca_Detail.Cost_Collector_Key 
                AND Hr_Position.Hr_Position_Key=Payroll_Edacca_Detail.Hr_Position_Key 
                AND Time_Month.Time_Month_Key=Payroll_Edacca_Detail.Time_Month_Key 
                AND Project_Osp.Mit_Award_Number=Osp_Award_Terms_Detail.Mit_Award_Key)  
                AND (Osp_Award_Terms_Detail.Osp_Award_Terms_Type_Key='TRMAPP134' 
                AND (Payroll_Edacca_Detail.Hr_Appt_Subtype IN ('Fellowship', 'Graduate Student Appt', 'Student Appointment') 
                    OR (Hr_Position.Position_Title LIKE '%Posrdoc%' 
                    OR Hr_Position.Position_Title LIKE '%Postdoc%') 
                    OR Hr_Position.Personnel_Subarea IN ('Fellows', 'Grad Std Fellow', 'Grad Std Mult P', 'Grad Std Other', 'Grad Std RA', 'Grad Std TA', 'Stdt Hrly UGrad', 'UROP'))
                AND Hr_Position.Personnel_Subarea NOT IN ('Service RDTEU') 
                AND Time_Month.Fiscal_Year>='2010')
           group by payroll_edacca_detail.mit_id, payroll_edacca_detail.Cost_Collector_Key, payroll_edacca_detail.payroll_for_period_key, 
            PAYROLL_EDACCA_DETAIL.APPT_BEGIN_DATE, PROJECT_OSP.PROJECT_WBS_ID
           having sum(payroll_edacca_DETAIL.PAYROLL_DIST_AMOUNT) > 0) a,
           wareuser.Payroll_Edacca_Detail@WAREHOUSE_SDOWDY.MIT.EDU Payroll_Edacca_Detail
     where  a.mit_id = Payroll_Edacca_Detail.mit_id
        and a.Cost_Collector_Key = Payroll_Edacca_Detail.Cost_Collector_Key
        --and a.payroll_for_period_key = Payroll_Edacca_Detail.payroll_for_period_key
        and Payroll_Edacca_Detail.PAYROLL_PAYMENT_DATE = (  select min(Payroll_Edacca_Detail1.PAYROLL_PAYMENT_DATE)
            from wareuser.Payroll_Edacca_Detail@WAREHOUSE_SDOWDY.MIT.EDU Payroll_Edacca_Detail1
            where Payroll_Edacca_Detail.mit_id = Payroll_Edacca_Detail1.mit_id
               and Payroll_Edacca_Detail.Cost_Collector_Key = Payroll_Edacca_Detail1.Cost_Collector_Key
               --and Payroll_Edacca_Detail.payroll_for_period_key = Payroll_Edacca_Detail1.payroll_for_period_key
               );

    open C_new_payroll;
    
    loop
        fetch C_new_payroll into ls_PersonID, ls_AccountNumber,  ldt_PayrollDate;
        exit when C_new_payroll%NOTFOUND;
        
        select max(PAYROLL_NUMBER)
        into li_ParyollNumber
        from RCR_PAYROLL_DATES
        where PERSON_ID = ls_PersonID
        and ACCOUNT_NUMBER = ls_AccountNumber;
        
        if li_ParyollNumber is null then
            li_ParyollNumber := 1;
        else
            li_ParyollNumber := li_ParyollNumber + 1;
        end if;
        
        begin
            INSERT INTO RCR_PAYROLL_DATES (RCR_PAYROLL_DATES_ID,PERSON_ID, ACCOUNT_NUMBER, PAYROLL_NUMBER,
            BASE_DATE, TRAINING_DEADLINE, UPDATE_TIMESTAMP, UPDATE_USER,VER_NBR,OBJ_ID)
            VALUES ( SEQ_RCR_PAYROLL_DATES_ID.nextval,ls_PersonID, ls_AccountNumber, li_ParyollNumber,
            trunc(ldt_PayrollDate), Trunc(ldt_PayrollDate) + 60, sysdate, user,1,sys_guid());
        exception
            when others then
                li_ret := 0;
        end;
        
    end loop;
    
    close C_new_payroll;
    
    
    /************** 
    Drop appointments and payroll dates that are no longer in warehouse feed
    Delete these rows from RSR tables and insert them to RCR_dropped tables so that we have a record.
    ************************/
    
    INSERT INTO RCR_PAYROLL_DATES_DROPPED
    SELECT PERSON_ID, ACCOUNT_NUMBER, PAYROLL_NUMBER, BASE_DATE, TRAINING_DEADLINE, UPDATE_TIMESTAMP, UPDATE_USER, sysdate
    FROM RCR_PAYROLL_DATES
    WHERE ( PERSON_ID, ACCOUNT_NUMBER ) NOT IN (SELECT DISTINCT PERSON_ID, ACCOUNT_NUMBER FROM RCR_PAYROLL_WH);   

    delete FROM RCR_PAYROLL_DATES
    WHERE ( PERSON_ID, ACCOUNT_NUMBER ) NOT IN (SELECT DISTINCT PERSON_ID, ACCOUNT_NUMBER FROM RCR_PAYROLL_WH);
    
    insert into RCR_APPOINTMENTS_DROPPED
    select PERSON_ID, ACCOUNT_NUMBER, APPOINTMENT_DATE, APPOINTMENT_TYPE, DATA_LOAD_DATE, UPDATE_TIMESTAMP, UPDATE_USER, SYSDATE
     from RCR_APPOINTMENTS
    where (PERSON_ID, ACCOUNT_NUMBER) not in (select  distinct PERSON_ID, ACCOUNT_NUMBER     
                from RCR_APPOINT_WH);
                
    delete from  RCR_APPOINTMENTS
    where (PERSON_ID, ACCOUNT_NUMBER) not in (select  distinct PERSON_ID, ACCOUNT_NUMBER     
                from RCR_APPOINT_WH);           


	return 1;
END;
/