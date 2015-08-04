CREATE TABLE SYSTEM_ALERTS
(
   ALERT_ID   	NUMBER (12) NOT NULL,
   MODULE_NMSPC_CD    VARCHAR2 (20) NOT NULL,
   MODULE_NAME		    		VARCHAR2 (500) NOT NULL,
   ALERT_MESSAGE		VARCHAR2 (1000) NOT NULL,
   USER_NAME		    		VARCHAR2 (60) NOT NULL,
   PRIORITY	NUMBER(1) NOT NULL,
   ACTIVE					CHAR(1) NOT NULL,
   UPDATE_TIMESTAMP             DATE DEFAULT SYSDATE NOT NULL,
   UPDATE_USER                  VARCHAR2 (60) NOT NULL,
   VER_NBR                      NUMBER (8) DEFAULT 1 NOT NULL,
   OBJ_ID                       VARCHAR2 (36) DEFAULT SYS_GUID() NOT NULL
)
/

ALTER TABLE SYSTEM_ALERTS
ADD CONSTRAINT PK_SYSTEM_ALERTS
PRIMARY KEY (ALERT_ID)
/