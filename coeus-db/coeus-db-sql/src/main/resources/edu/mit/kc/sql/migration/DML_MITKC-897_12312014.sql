UPDATE PROPOSAL
SET COST_SHARING_INDICATOR = DECODE(COST_SHARING_INDICATOR,'P1',1,'P0',1,0),
IDC_RATE_INDICATOR = DECODE(IDC_RATE_INDICATOR,'P1',1,'P0',1,0),
SPECIAL_REVIEW_INDICATOR = DECODE(SPECIAL_REVIEW_INDICATOR,'P1',1,'P0',1,0),
SCIENCE_CODE_INDICATOR = DECODE(SCIENCE_CODE_INDICATOR,'P1',1,'P0',1,0),
IP_REVIEW_ACTIVITY_INDICATOR = DECODE(IP_REVIEW_ACTIVITY_INDICATOR,'P1',1,'P0',1,0)
/
commit
/