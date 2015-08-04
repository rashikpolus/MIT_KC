DECLARE
ls_query VARCHAR2(1000);
ls_constraint VARCHAR2(200);
BEGIN
 Select distinct constraint_name into ls_constraint
from all_constraints 
 where constraint_type='R'
   and r_constraint_name in (select constraint_name 
                               from all_constraints 
                              where constraint_type in ('P','U') 
                                and table_name='ROLODEX')
and table_name='SPONSOR'; 

IF ls_constraint IS NOT NULL THEN

ls_query:='ALTER TABLE SPONSOR ENABLE CONSTRAINT '|| ls_constraint;
EXECUTE IMMEDIATE(ls_query); 

ELSE 
ls_query:='ALTER TABLE SPONSOR ADD CONSTRAINT FK_ROLODEX FOREIGN KEY (ROLODEX_ID) REFERENCES ROLODEX(ROLODEX_ID)';
EXECUTE IMMEDIATE(ls_query); 
END IF;
END;
/
