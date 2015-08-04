CREATE TABLE BUDGET_SUB_AWARD_ATT_BAK AS SELECT * FROM  BUDGET_SUB_AWARD_ATT
/
ALTER TABLE BUDGET_SUB_AWARD_ATT ADD FILE_DATA_ID VARCHAR2(36) NULL
/
UPDATE BUDGET_SUB_AWARD_ATT  SET FILE_DATA_ID = SYS_GUID()
/
INSERT INTO FILE_DATA(ID,DATA)
SELECT FILE_DATA_ID,ATTACHMENT FROM BUDGET_SUB_AWARD_ATT
/
ALTER TABLE BUDGET_SUB_AWARD_ATT MODIFY FILE_DATA_ID NOT NULL
/
ALTER TABLE BUDGET_SUB_AWARD_ATT DROP COLUMN ATTACHMENT
/
