ALTER TABLE AWARD_BUDGET_PERIOD_EXT ADD TOTAL_FRINGE_AMOUNT_1 NUMBER(12,2)
/
UPDATE AWARD_BUDGET_PERIOD_EXT SET TOTAL_FRINGE_AMOUNT_1 = TOTAL_FRINGE_AMOUNT
/
commit
/
ALTER TABLE AWARD_BUDGET_PERIOD_EXT DROP COLUMN TOTAL_FRINGE_AMOUNT
/
ALTER TABLE AWARD_BUDGET_PERIOD_EXT RENAME COLUMN TOTAL_FRINGE_AMOUNT_1 TO TOTAL_FRINGE_AMOUNT
/
