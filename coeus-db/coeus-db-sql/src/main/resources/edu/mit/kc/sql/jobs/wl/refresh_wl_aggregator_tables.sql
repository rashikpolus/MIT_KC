--Script to populate WL aggregator tables.
-- This script will be called from a CRON job daily
--
set heading off;
set echo off;

select 'Deleting all rows from WL$PROP_AGGREGATOR_ERR_COUNT' from dual;

delete from WL$PROP_AGGREGATOR_ERR_COUNT ;

select 'Load WL$PROP_AGGREGATOR_ERR_COUNT. Aggregator Error Count for all routed proposals.' from dual;

insert into WL$PROP_AGGREGATOR_ERR_COUNT 
select P.PROPOSAL_NUMBER,  R.ROUTING_NUMBER,
lower(ROUTING_START_USER), u.person_id, ROUTING_START_DATE, fn_wl_prop_error_count (P.PROPOSAL_NUMBER)
 from osp$eps_proposal p,  osp$routing r, osp$user u
where P.CREATION_STATUS_CODE not in (1)   --Exclude In progress proposals
and R.MODULE_CODE = 3
and R.ROUTING_START_DATE is not null
and R.MODULE_ITEM_KEY = P.PROPOSAL_NUMBER
and R.ROUTING_NUMBER = (select min(r2.routing_number) from osp$routing r2
        where R.MODULE_ITEM_KEY = R2.MODULE_ITEM_KEY
            and R2.MODULE_CODE = 3)
and upper(R.ROUTING_START_USER) = upper(U.USER_ID);            
rem
rem
select 'Deleting all rows from WL$PROP_AGGREGATOR_COMPLEXITY' from dual;
delete from WL$PROP_AGGREGATOR_COMPLEXITY;
rem
rem
select 'Load WL$PROP_AGGREGATOR_COMPLEXITY - Proposals routed after ' || to_char(trunc(add_months(sysdate, -12)), 'mm/dd/yyyy')  from dual;

INSERT INTO WL$PROP_AGGREGATOR_COMPLEXITY
SELECT AGGREGATOR_USER_ID, AGGREGATOR_PERSON_ID, avg(NUM_OF_ERRORS), NULL, count(distinct PROPOSAL_NUMBER)
FROM WL$PROP_AGGREGATOR_ERR_COUNT
WHERE  ROUTING_START_DATE > = trunc(add_months(sysdate, -12))
group by AGGREGATOR_USER_ID, AGGREGATOR_PERSON_ID;

--Update Complexity


select 'Set Complexity = 3 when proposal count <= 5' from dual;

update WL$PROP_AGGREGATOR_COMPLEXITY
set COMPLEXITY = 3
where  PROPOSAL_COUNT <= 5;

select 'Set Complexity = 1 when average error count >= 0 and < 2' from dual;

update WL$PROP_AGGREGATOR_COMPLEXITY
set COMPLEXITY = 1
where AVERAGE_ERROR_COUNT >= 0 and AVERAGE_ERROR_COUNT < 2
and PROPOSAL_COUNT > 5;

select 'Set Complexity = 2 when average error count >=2 and < 3' from dual;

update WL$PROP_AGGREGATOR_COMPLEXITY
set COMPLEXITY = 2
where AVERAGE_ERROR_COUNT >= 2 and AVERAGE_ERROR_COUNT < 3
and PROPOSAL_COUNT > 5;

select 'Set Complexity = 3 when average error count >=3' from dual;

update WL$PROP_AGGREGATOR_COMPLEXITY
set COMPLEXITY = 3
where AVERAGE_ERROR_COUNT >= 3
and PROPOSAL_COUNT > 5;

commit;
rem
rem
exit;

