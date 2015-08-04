
--Delete all rows from Temp Table
delete from DASHBOARD_EXPENDITURES_WH;

commit;

--Extract Data from Warehouse.
--Here one person can have multiple rows per FY.
--We are pulling data for last 7 years
insert into DASHBOARD_EXPENDITURES_WH 
SELECT AL3.SUPERVISOR_MIT_ID, 
     AL2.FISCAL_YEAR, 
     AL1.LEVEL2_CATEGORY, 
     AL1.LEVEL5_CATEGORY, 
     SUM ( AL4.AMOUNT ),
     SYS_GUID()
FROM 
     WAREUSER.GL_ACCOUNT_REPORT@WAREHOUSE_COEUS.MIT.EDU AL1, 
     WAREUSER.TIME_MONTH@WAREHOUSE_COEUS.MIT.EDU AL2, 
     WAREUSER.PROJECT@WAREHOUSE_COEUS.MIT.EDU AL3, 
     WAREUSER.BALANCES_BY_FISCAL_PERIOD@WAREHOUSE_COEUS.MIT.EDU AL4 
WHERE 
     AL1.GL_ACCOUNT_KEY=AL4.GL_ACCOUNT_KEY AND
AL1.REPORT_TYPE='MTDC Base/Non Base' AND 
     AL1.LEVEL1_CATEGORY='Expenses' AND 
     AL2.TIME_MONTH_KEY=AL4.TIME_MONTH_KEY AND 
     AL4.COST_COLLECTOR_KEY=AL3.COST_COLLECTOR_KEY AND
     to_number(AL2.FISCAL_YEAR) >= (select distinct to_number(fiscal_year) - 6
                                    from WAREUSER.TIME_MONTH@WAREHOUSE_COEUS.MIT.EDU
                                    where sysdate between start_date and end_date)    
   AND     NOT AL4.AMOUNT=0
GROUP BY 
     AL3.SUPERVISOR_MIT_ID, 
     AL2.FISCAL_YEAR, 
     AL1.LEVEL2_CATEGORY, 
     AL1.LEVEL5_CATEGORY;

commit;

delete from DASHBOARD_EXPENDITURES;

commit;

--Reset sequence object used for EXP_ID column
DROP SEQUENCE KCSO.SEQ_DASHBOARD_EXPENDITURES_ID;

CREATE SEQUENCE KCSO.SEQ_DASHBOARD_EXPENDITURES_ID
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER;


--Insert into DASHBOARD_EXPENDITURES
--This is a rollup from DASHBOARD_EXPENDITURES_WH table.
insert into DASHBOARD_EXPENDITURES
select SEQ_DASHBOARD_EXPENDITURES_ID.nextval, ep.PERSON_ID, P.PRNCPL_NM, ep.FISCAL_YEAR, 
nvl(direct.DIRECT_EXP, 0), nvl(sub.SUB_EXP, 0), nvl(fa.FA_EXP, 0), 
sysdate, user, 1, SYS_GUID()
from (select distinct D.PERSON_ID, d.FISCAL_YEAR
from DASHBOARD_EXPENDITURES_WH d) ep,  
KRIM_PRNCPL_T P,
    (select PERSON_ID, FISCAL_YEAR, sum(EXP_AMOUNT) DIRECT_EXP
        from DASHBOARD_EXPENDITURES_WH
        where LEVEL2_CATEGORY = 'Direct Expenses'
        and LEVEL5_CATEGORY not in ('Subrecipient Costs', 'Subrecipient Expense-not MTDC')
        group by PERSON_ID, FISCAL_YEAR) direct,    
     (select PERSON_ID, FISCAL_YEAR, sum(EXP_AMOUNT) SUB_EXP
        from DASHBOARD_EXPENDITURES_WH
        where LEVEL2_CATEGORY = 'Direct Expenses'
        and LEVEL5_CATEGORY in ('Subrecipient Costs', 'Subrecipient Expense-not MTDC')
        group by PERSON_ID, FISCAL_YEAR) sub, 
    (select PERSON_ID, FISCAL_YEAR, sum(EXP_AMOUNT) FA_EXP
        from DASHBOARD_EXPENDITURES_WH
        where LEVEL2_CATEGORY <> 'Direct Expenses'
        group by PERSON_ID, FISCAL_YEAR) fa
where ep.PERSON_ID = P.PRNCPL_ID (+)
and ep.PERSON_ID = direct.PERSON_ID (+)
and ep.FISCAL_YEAR = direct.FISCAL_YEAR (+)
and ep.PERSON_ID = fa.PERSON_ID (+)
and ep.FISCAL_YEAR = fa.FISCAL_YEAR (+)
and ep.PERSON_ID = sub.PERSON_ID (+)
and ep.FISCAL_YEAR = sub.FISCAL_YEAR (+);

commit;

exit;

