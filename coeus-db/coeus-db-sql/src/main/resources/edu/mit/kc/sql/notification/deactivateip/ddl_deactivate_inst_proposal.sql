CREATE TABLE TEMP_DEACTIVATED_IP
(PROPOSAL_NUMBER VARCHAR2(8) NOT NULL ENABLE, 
SEQUENCE_NUMBER NUMBER(4,0) NOT NULL ENABLE, 
STATUS_CODE NUMBER(3,0) NOT NULL ENABLE, 
SPONSOR_CODE CHAR(6) NOT NULL ENABLE, 
TITLE VARCHAR2(200) NOT NULL ENABLE, 
DEACTIVATE_DATE DATE
)
/
