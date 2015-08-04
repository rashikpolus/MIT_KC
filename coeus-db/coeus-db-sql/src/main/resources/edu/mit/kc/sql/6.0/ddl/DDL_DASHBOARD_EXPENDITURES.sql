CREATE TABLE DASHBOARD_EXPENDITURES
(
   EXP_ID   	NUMBER (12) NOT NULL,
   PERSON_ID  VARCHAR2 (60) NOT NULL,
   USER_NAME	VARCHAR2 (60) NULL,
   FISCAL_YEAR	CHAR(4) NOT NULL,
   DIRECT_EXP		NUMBER(12,2) NOT NULL,
   SUBAWARD_EXP	NUMBER(12,2) NOT NULL,
   FA_EXP	NUMBER(12,2) NOT NULL,
   UPDATE_TIMESTAMP             DATE DEFAULT SYSDATE NOT NULL,
   UPDATE_USER                  VARCHAR2 (60) NOT NULL,
   VER_NBR                      NUMBER (8) DEFAULT 1 NOT NULL,
   OBJ_ID                       VARCHAR2 (36) DEFAULT SYS_GUID() NOT NULL
)
/

ALTER TABLE DASHBOARD_EXPENDITURES
ADD CONSTRAINT PK_DASHBOARD_EXPENDITURES
PRIMARY KEY (EXP_ID)
/
