--
-- Kuali Coeus, a comprehensive research administration system for higher education.
-- 
-- Copyright 2005-2015 Kuali, Inc.
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
-- 
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

--
-- NOTE: when assembling this script for release, please merge any table rebuilds with those from 2011-04-28.sql
--

-----------------------------------------------------------------------------
-- KREW_DOC_NTE_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_DOC_NTE_T RENAME TO TEMP_KREW_DOC_NTE_T;
DECLARE
c NUMBER;
BEGIN
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_NTE_TP1' ;
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE TEMP_KREW_DOC_NTE_T DROP CONSTRAINT KREW_DOC_NTE_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_NTE_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_NTE_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_NTE_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_NTE_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_NTE_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
CREATE TABLE KREW_DOC_NTE_T ( 
    DOC_NTE_ID      VARCHAR2(40),
    DOC_HDR_ID      VARCHAR2(40) NOT NULL,
    AUTH_PRNCPL_ID  VARCHAR2(40) NOT NULL,
    CRT_DT          DATE NOT NULL,
    TXT             VARCHAR2(4000) NULL,
    VER_NBR         NUMBER(8,0) DEFAULT 0 NULL
);
ALTER TABLE KREW_DOC_NTE_T ADD CONSTRAINT KREW_DOC_NTE_TP1 PRIMARY KEY (DOC_NTE_ID);
CREATE INDEX KREW_DOC_NTE_TI1 ON KREW_DOC_NTE_T (DOC_HDR_ID);
INSERT INTO KREW_DOC_NTE_T
(DOC_NTE_ID, DOC_HDR_ID, AUTH_PRNCPL_ID, CRT_DT, TXT, VER_NBR)
SELECT CAST(DOC_NTE_ID as VARCHAR2(40)), DOC_HDR_ID, AUTH_PRNCPL_ID, CRT_DT, TXT, VER_NBR
FROM TEMP_KREW_DOC_NTE_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_NTE_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_NTE_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_ATT_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_ATT_T RENAME TO TEMP_KREW_ATT_T;
DECLARE
c NUMBER;
BEGIN
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_ATT_TP1' ;
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE TEMP_KREW_ATT_T DROP CONSTRAINT KREW_ATT_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ATT_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ATT_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ATT_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ATT_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ATT_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
CREATE TABLE KREW_ATT_T (
    ATTACHMENT_ID   VARCHAR2(40),
    NTE_ID          VARCHAR2(40) NULL,
    FILE_NM         VARCHAR2(255) NOT NULL,
    FILE_LOC        VARCHAR2(255) NOT NULL,
    MIME_TYP        VARCHAR2(255) NOT NULL,
    VER_NBR         NUMBER(8,0) DEFAULT 0 NULL
);
ALTER TABLE KREW_ATT_T ADD CONSTRAINT KREW_ATT_TP1 PRIMARY KEY (ATTACHMENT_ID);
CREATE INDEX KREW_ATT_TI1 ON KREW_ATT_T(NTE_ID);
INSERT INTO KREW_ATT_T
(ATTACHMENT_ID, NTE_ID, FILE_NM, FILE_LOC, MIME_TYP, VER_NBR)
SELECT CAST(ATTACHMENT_ID as VARCHAR2(40)), CAST(NTE_ID as VARCHAR2(40)), FILE_NM, FILE_LOC, MIME_TYP, VER_NBR
FROM TEMP_KREW_ATT_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_ATT_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_ATT_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_ACTN_ITM_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_ACTN_ITM_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_ACTN_ITM_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_ACTN_ITM_T DROP CONSTRAINT KREW_ACTN_ITM_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_ITM_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_ITM_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_ITM_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_ITM_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_ITM_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_ITM_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_ITM_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI5' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_ITM_TI5' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_ITM_TI5';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_ITM_TI5 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_ACTN_ITM_T RENAME TO TEMP_KREW_ACTN_ITM_T;
CREATE TABLE KREW_ACTN_ITM_T
(
      ACTN_ITM_ID VARCHAR2(40)
        , PRNCPL_ID VARCHAR2(40) NOT NULL
        , ASND_DT DATE NOT NULL
        , RQST_CD CHAR(1) NOT NULL
        , ACTN_RQST_ID VARCHAR2(40) NOT NULL
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , ROLE_NM VARCHAR2(2000)
        , DLGN_PRNCPL_ID VARCHAR2(40)
        , DOC_HDR_TTL VARCHAR2(255)
        , DOC_TYP_LBL VARCHAR2(128) NOT NULL
        , DOC_HDLR_URL VARCHAR2(255) NOT NULL
        , DOC_TYP_NM VARCHAR2(64) NOT NULL
        , RSP_ID VARCHAR2(40) NOT NULL
        , DLGN_TYP VARCHAR2(1)
        , VER_NBR NUMBER(8) default 0
        , DTYPE VARCHAR2(50)
        , GRP_ID VARCHAR2(40)
        , DLGN_GRP_ID VARCHAR2(40)
        , RQST_LBL VARCHAR2(255)
);
ALTER TABLE KREW_ACTN_ITM_T
    ADD CONSTRAINT KREW_ACTN_ITM_TP1
PRIMARY KEY (ACTN_ITM_ID);
CREATE INDEX KREW_ACTN_ITM_TI1
  ON KREW_ACTN_ITM_T
  (PRNCPL_ID);
CREATE INDEX KREW_ACTN_ITM_TI2
  ON KREW_ACTN_ITM_T
  (DOC_HDR_ID);
CREATE INDEX KREW_ACTN_ITM_TI3
  ON KREW_ACTN_ITM_T
  (ACTN_RQST_ID);
CREATE INDEX KREW_ACTN_ITM_TI5
  ON KREW_ACTN_ITM_T
  (PRNCPL_ID, DLGN_TYP, DOC_HDR_ID);
INSERT INTO KREW_ACTN_ITM_T
(ACTN_ITM_ID, PRNCPL_ID, ASND_DT, RQST_CD, ACTN_RQST_ID, DOC_HDR_ID, ROLE_NM, DLGN_PRNCPL_ID,
 DOC_HDR_TTL, DOC_TYP_LBL, DOC_HDLR_URL, DOC_TYP_NM, RSP_ID, DLGN_TYP, VER_NBR, DTYPE,
 GRP_ID, DLGN_GRP_ID, RQST_LBL)
SELECT CAST(ACTN_ITM_ID as VARCHAR2(40)), PRNCPL_ID, ASND_DT, RQST_CD, CAST(ACTN_RQST_ID as VARCHAR2(40)), DOC_HDR_ID,
 ROLE_NM, DLGN_PRNCPL_ID,
 DOC_HDR_TTL, DOC_TYP_LBL, DOC_HDLR_URL, DOC_TYP_NM, CAST(RSP_ID as VARCHAR2(40)), DLGN_TYP, VER_NBR, DTYPE,
 GRP_ID, DLGN_GRP_ID, RQST_LBL
FROM TEMP_KREW_ACTN_ITM_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_ACTN_ITM_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_ACTN_ITM_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_ACTN_TKN_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_ACTN_TKN_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_ACTN_TKN_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_ACTN_TKN_T DROP CONSTRAINT KREW_ACTN_TKN_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_TKN_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_TKN_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_TKN_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_TKN_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_TKN_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_TKN_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_TKN_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI4' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI4' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_TKN_TI4';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_TKN_TI4 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI5' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_TKN_TI5' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_TKN_TI5';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_TKN_TI5 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_ACTN_TKN_T RENAME TO TEMP_KREW_ACTN_TKN_T;
CREATE TABLE KREW_ACTN_TKN_T
(
      ACTN_TKN_ID VARCHAR2(40)
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , PRNCPL_ID VARCHAR2(40) NOT NULL
        , DLGTR_PRNCPL_ID VARCHAR2(40)
        , ACTN_CD CHAR(1) NOT NULL
        , ACTN_DT DATE NOT NULL
        , DOC_VER_NBR NUMBER(8) NOT NULL
        , ANNOTN VARCHAR2(2000)
        , CUR_IND NUMBER(1) default 1
        , VER_NBR NUMBER(8) default 0
        , DLGTR_GRP_ID VARCHAR2(40)
);
ALTER TABLE KREW_ACTN_TKN_T
    ADD CONSTRAINT KREW_ACTN_TKN_TP1
PRIMARY KEY (ACTN_TKN_ID);
CREATE INDEX KREW_ACTN_TKN_TI1
  ON KREW_ACTN_TKN_T
  (DOC_HDR_ID, PRNCPL_ID);
CREATE INDEX KREW_ACTN_TKN_TI2
  ON KREW_ACTN_TKN_T
  (DOC_HDR_ID, PRNCPL_ID, ACTN_CD);
CREATE INDEX KREW_ACTN_TKN_TI3
  ON KREW_ACTN_TKN_T
  (PRNCPL_ID);
CREATE INDEX KREW_ACTN_TKN_TI4
  ON KREW_ACTN_TKN_T
  (DLGTR_PRNCPL_ID);
CREATE INDEX KREW_ACTN_TKN_TI5
  ON KREW_ACTN_TKN_T
  (DOC_HDR_ID);
INSERT INTO KREW_ACTN_TKN_T
(ACTN_TKN_ID, DOC_HDR_ID, PRNCPL_ID, DLGTR_PRNCPL_ID, ACTN_CD, ACTN_DT, DOC_VER_NBR, ANNOTN,
CUR_IND, VER_NBR, DLGTR_GRP_ID)
SELECT CAST(ACTN_TKN_ID as VARCHAR2(40)), DOC_HDR_ID, PRNCPL_ID, DLGTR_PRNCPL_ID, ACTN_CD, ACTN_DT, DOC_VER_NBR, ANNOTN,
CUR_IND, VER_NBR, DLGTR_GRP_ID
FROM TEMP_KREW_ACTN_TKN_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_ACTN_TKN_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_ACTN_TKN_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_ACTN_RQST_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_ACTN_RQST_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_ACTN_RQST_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_ACTN_RQST_T DROP CONSTRAINT KREW_ACTN_RQST_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T11' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T11' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T11';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T11 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T12' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T12' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T12';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T12 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T13' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T13' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T13';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T13 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T14' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T14' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T14';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T14 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T15' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T15' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T15';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T15 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T16' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T16' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T16';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T16 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T17' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T17' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T17';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T17 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T19' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_ACTN_RQST_T19' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_ACTN_RQST_T19';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_ACTN_RQST_T19 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_ACTN_RQST_T RENAME TO TEMP_KREW_ACTN_RQST_T;
CREATE TABLE KREW_ACTN_RQST_T
(
      ACTN_RQST_ID VARCHAR2(40)
        , PARNT_ID VARCHAR2(40)
        , ACTN_RQST_CD CHAR(1) NOT NULL
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , RULE_ID VARCHAR2(40)
        , STAT_CD CHAR(1) NOT NULL
        , RSP_ID VARCHAR2(40) NOT NULL
        , PRNCPL_ID VARCHAR2(40)
        , ROLE_NM VARCHAR2(2000)
        , QUAL_ROLE_NM VARCHAR2(2000)
        , QUAL_ROLE_NM_LBL_TXT VARCHAR2(2000)
        , RECIP_TYP_CD CHAR(1)
        , PRIO_NBR NUMBER(8) NOT NULL
        , RTE_TYP_NM VARCHAR2(255)
        , RTE_LVL_NBR NUMBER(8) NOT NULL
        , RTE_NODE_INSTN_ID VARCHAR2(40)
        , ACTN_TKN_ID VARCHAR2(40)
        , DOC_VER_NBR NUMBER(8) NOT NULL
        , CRTE_DT DATE NOT NULL
        , RSP_DESC_TXT VARCHAR2(200)
        , FRC_ACTN NUMBER(1) default 0
        , ACTN_RQST_ANNOTN_TXT VARCHAR2(2000)
        , DLGN_TYP CHAR(1)
        , APPR_PLCY CHAR(1)
        , CUR_IND NUMBER(1) default 1
        , VER_NBR NUMBER(8) default 0
        , GRP_ID VARCHAR2(40)
        , RQST_LBL VARCHAR2(255)
);
ALTER TABLE KREW_ACTN_RQST_T
    ADD CONSTRAINT KREW_ACTN_RQST_TP1
PRIMARY KEY (ACTN_RQST_ID);
CREATE INDEX KREW_ACTN_RQST_T11
  ON KREW_ACTN_RQST_T
  (DOC_HDR_ID);
CREATE INDEX KREW_ACTN_RQST_T12
  ON KREW_ACTN_RQST_T
  (PRNCPL_ID);
CREATE INDEX KREW_ACTN_RQST_T13
  ON KREW_ACTN_RQST_T
  (ACTN_TKN_ID);
CREATE INDEX KREW_ACTN_RQST_T14
  ON KREW_ACTN_RQST_T
  (PARNT_ID);
CREATE INDEX KREW_ACTN_RQST_T15
  ON KREW_ACTN_RQST_T
  (RSP_ID);
CREATE INDEX KREW_ACTN_RQST_T16
  ON KREW_ACTN_RQST_T
  (STAT_CD, RSP_ID);
CREATE INDEX KREW_ACTN_RQST_T17
  ON KREW_ACTN_RQST_T
  (RTE_NODE_INSTN_ID);
CREATE INDEX KREW_ACTN_RQST_T19
  ON KREW_ACTN_RQST_T
  (STAT_CD, DOC_HDR_ID);
INSERT INTO KREW_ACTN_RQST_T
(ACTN_RQST_ID, PARNT_ID, ACTN_RQST_CD, DOC_HDR_ID, RULE_ID, STAT_CD, RSP_ID, PRNCPL_ID,
ROLE_NM, QUAL_ROLE_NM, QUAL_ROLE_NM_LBL_TXT, RECIP_TYP_CD, PRIO_NBR, RTE_TYP_NM,
RTE_LVL_NBR, RTE_NODE_INSTN_ID, ACTN_TKN_ID, DOC_VER_NBR, CRTE_DT, RSP_DESC_TXT,
FRC_ACTN, ACTN_RQST_ANNOTN_TXT, DLGN_TYP, APPR_PLCY, CUR_IND, VER_NBR, GRP_ID, RQST_LBL)
SELECT CAST(ACTN_RQST_ID as VARCHAR2(40)), CAST(PARNT_ID as VARCHAR2(40)),
ACTN_RQST_CD, DOC_HDR_ID, CAST(RULE_ID as VARCHAR2(40)), STAT_CD, CAST(RSP_ID as VARCHAR2(40)), PRNCPL_ID,
ROLE_NM, QUAL_ROLE_NM, QUAL_ROLE_NM_LBL_TXT, RECIP_TYP_CD, PRIO_NBR, RTE_TYP_NM,
RTE_LVL_NBR, CAST(RTE_NODE_INSTN_ID as VARCHAR2(40)), CAST(ACTN_TKN_ID as VARCHAR2(40)), DOC_VER_NBR,
CRTE_DT, RSP_DESC_TXT,
FRC_ACTN, ACTN_RQST_ANNOTN_TXT, DLGN_TYP, APPR_PLCY, CUR_IND, VER_NBR, GRP_ID, RQST_LBL
FROM TEMP_KREW_ACTN_RQST_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_ACTN_RQST_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_ACTN_RQST_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_TMPL_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_RULE_TMPL_T DROP CONSTRAINT KREW_RULE_TMPL_TC0;
ALTER TABLE KREW_RULE_TMPL_T DROP CONSTRAINT KREW_RULE_TMPL_TI1;
ALTER TABLE KREW_RULE_TMPL_T RENAME TO TEMP_KREW_RULE_TMPL_T;
ALTER TABLE TEMP_KREW_RULE_TMPL_T DROP CONSTRAINT KREW_RULE_TMPL_TP1;
CREATE TABLE KREW_RULE_TMPL_T
(
      RULE_TMPL_ID VARCHAR2(40)
        , NM VARCHAR2(250) NOT NULL
        , RULE_TMPL_DESC VARCHAR2(2000)
        , DLGN_RULE_TMPL_ID VARCHAR2(40)
        , VER_NBR NUMBER(8) default 0
        , OBJ_ID VARCHAR2(36) NOT NULL

    , CONSTRAINT KREW_RULE_TMPL_TC0 UNIQUE (OBJ_ID)
    , CONSTRAINT KREW_RULE_TMPL_TI1 UNIQUE (NM)
);
ALTER TABLE KREW_RULE_TMPL_T
    ADD CONSTRAINT KREW_RULE_TMPL_TP1
PRIMARY KEY (RULE_TMPL_ID);
INSERT INTO KREW_RULE_TMPL_T
(RULE_TMPL_ID, NM, RULE_TMPL_DESC, DLGN_RULE_TMPL_ID, VER_NBR, OBJ_ID)
SELECT CAST(RULE_TMPL_ID as VARCHAR2(40)), NM, RULE_TMPL_DESC, CAST(DLGN_RULE_TMPL_ID as VARCHAR2(40)),
VER_NBR, OBJ_ID
FROM TEMP_KREW_RULE_TMPL_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_TMPL_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_TMPL_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_TMPL_ATTR_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RULE_TMPL_ATTR_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RULE_TMPL_ATTR_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RULE_TMPL_ATTR_T DROP CONSTRAINT KREW_RULE_TMPL_ATTR_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_TMPL_ATTR_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RULE_TMPL_ATTR_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RULE_TMPL_ATTR_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RULE_TMPL_ATTR_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_TMPL_ATTR_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RULE_TMPL_ATTR_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RULE_TMPL_ATTR_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RULE_TMPL_ATTR_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_TMPL_ATTR_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RULE_TMPL_ATTR_T RENAME TO TEMP_KREW_RULE_TMPL_ATTR_T;
ALTER TABLE TEMP_KREW_RULE_TMPL_ATTR_T DROP CONSTRAINT KREW_RULE_TMPL_ATTR_TC0;
CREATE TABLE KREW_RULE_TMPL_ATTR_T
(
      RULE_TMPL_ATTR_ID VARCHAR2(40)
        , RULE_TMPL_ID VARCHAR2(40) NOT NULL
        , RULE_ATTR_ID VARCHAR2(40) NOT NULL
        , REQ_IND NUMBER(1) NOT NULL
        , ACTV_IND NUMBER(1) NOT NULL
        , DSPL_ORD NUMBER(5) NOT NULL
        , DFLT_VAL VARCHAR2(2000)
        , VER_NBR NUMBER(8) default 0
        , OBJ_ID VARCHAR2(36) NOT NULL
    , CONSTRAINT KREW_RULE_TMPL_ATTR_TC0 UNIQUE (OBJ_ID)
);
ALTER TABLE KREW_RULE_TMPL_ATTR_T
    ADD CONSTRAINT KREW_RULE_TMPL_ATTR_TP1
PRIMARY KEY (RULE_TMPL_ATTR_ID);
CREATE INDEX KREW_RULE_TMPL_ATTR_TI1
  ON KREW_RULE_TMPL_ATTR_T
  (RULE_TMPL_ID);
CREATE INDEX KREW_RULE_TMPL_ATTR_TI2
  ON KREW_RULE_TMPL_ATTR_T
  (RULE_ATTR_ID);
INSERT INTO KREW_RULE_TMPL_ATTR_T
(RULE_TMPL_ATTR_ID, RULE_TMPL_ID, RULE_ATTR_ID, REQ_IND, ACTV_IND, DSPL_ORD, DFLT_VAL, VER_NBR, OBJ_ID)
SELECT
CAST(RULE_TMPL_ATTR_ID as VARCHAR2(40)), CAST(RULE_TMPL_ID as VARCHAR2(40)),
CAST(RULE_ATTR_ID as VARCHAR2(40)), REQ_IND, ACTV_IND, DSPL_ORD, DFLT_VAL, VER_NBR, OBJ_ID
FROM TEMP_KREW_RULE_TMPL_ATTR_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_TMPL_ATTR_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_TMPL_ATTR_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_RULE_T DROP CONSTRAINT KREW_RULE_TC0;
ALTER TABLE KREW_RULE_T DROP CONSTRAINT KREW_RULE_TP1;
ALTER TABLE KREW_RULE_T DROP CONSTRAINT KREW_RULE_TR1;
ALTER TABLE KREW_RULE_T RENAME TO TEMP_KREW_RULE_T;
CREATE TABLE KREW_RULE_T
(
      RULE_ID VARCHAR2(40)
        , NM VARCHAR2(256)
        , RULE_TMPL_ID VARCHAR2(40)
        , RULE_EXPR_ID VARCHAR2(40)
        , ACTV_IND NUMBER(1) NOT NULL
        , RULE_BASE_VAL_DESC VARCHAR2(2000)
        , FRC_ACTN NUMBER(1) NOT NULL
        , DOC_TYP_NM VARCHAR2(64) NOT NULL
        , DOC_HDR_ID VARCHAR2(40)
        , TMPL_RULE_IND NUMBER(1)
        , FRM_DT DATE
        , TO_DT DATE
        , DACTVN_DT DATE
        , CUR_IND NUMBER(1) default 0
        , RULE_VER_NBR NUMBER(8) default 0
        , DLGN_IND NUMBER(1)
        , PREV_RULE_VER_NBR VARCHAR2(40)
        , ACTVN_DT DATE
        , VER_NBR NUMBER(8) default 0
        , OBJ_ID VARCHAR2(36) NOT NULL
    , CONSTRAINT KREW_RULE_TC0 UNIQUE (OBJ_ID)
);
ALTER TABLE KREW_RULE_T
    ADD CONSTRAINT KREW_RULE_TP1
PRIMARY KEY (RULE_ID);
INSERT INTO KREW_RULE_T
(RULE_ID, NM, RULE_TMPL_ID, RULE_EXPR_ID, ACTV_IND, RULE_BASE_VAL_DESC, FRC_ACTN,
DOC_TYP_NM, DOC_HDR_ID, TMPL_RULE_IND, FRM_DT, TO_DT, DACTVN_DT, CUR_IND, RULE_VER_NBR,
DLGN_IND, PREV_RULE_VER_NBR, ACTVN_DT, VER_NBR, OBJ_ID)
SELECT
CAST(RULE_ID as VARCHAR2(40)), NM, CAST(RULE_TMPL_ID as VARCHAR2(40)), CAST(RULE_EXPR_ID as VARCHAR2(40)),
ACTV_IND, RULE_BASE_VAL_DESC, FRC_ACTN,
DOC_TYP_NM, DOC_HDR_ID, TMPL_RULE_IND, FRM_DT, TO_DT, DACTVN_DT, CUR_IND, RULE_VER_NBR,
DLGN_IND, CAST(PREV_RULE_VER_NBR as VARCHAR2(40)), ACTVN_DT, VER_NBR, OBJ_ID
FROM TEMP_KREW_RULE_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DLGN_RSP_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_DLGN_RSP_T DROP CONSTRAINT KREW_DLGN_RSP_TC0;
ALTER TABLE KREW_DLGN_RSP_T DROP CONSTRAINT KREW_DLGN_RSP_TP1;
ALTER TABLE KREW_DLGN_RSP_T RENAME TO TEMP_KREW_DLGN_RSP_T;
CREATE TABLE KREW_DLGN_RSP_T
(
      DLGN_RULE_ID VARCHAR2(40)
        , RSP_ID VARCHAR2(40) NOT NULL
        , DLGN_RULE_BASE_VAL_ID VARCHAR2(40) NOT NULL
        , DLGN_TYP VARCHAR2(20) NOT NULL
        , VER_NBR NUMBER(8) default 0
        , OBJ_ID VARCHAR2(36) NOT NULL
    , CONSTRAINT KREW_DLGN_RSP_TC0 UNIQUE (OBJ_ID)
);
ALTER TABLE KREW_DLGN_RSP_T
    ADD CONSTRAINT KREW_DLGN_RSP_TP1
PRIMARY KEY (DLGN_RULE_ID);
INSERT INTO KREW_DLGN_RSP_T
(DLGN_RULE_ID, RSP_ID, DLGN_RULE_BASE_VAL_ID, DLGN_TYP, VER_NBR, OBJ_ID)
SELECT
CAST(DLGN_RULE_ID as VARCHAR2(40)), CAST(RSP_ID as VARCHAR2(40)), CAST(DLGN_RULE_BASE_VAL_ID as VARCHAR2(40)),
DLGN_TYP, VER_NBR, OBJ_ID
FROM TEMP_KREW_DLGN_RSP_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DLGN_RSP_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DLGN_RSP_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_RSP_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RULE_RSP_TC0' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RULE_RSP_TC0' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RULE_RSP_T DROP CONSTRAINT KREW_RULE_RSP_TC0';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_RSP_TC0 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RULE_RSP_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RULE_RSP_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RULE_RSP_T DROP CONSTRAINT KREW_RULE_RSP_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_RSP_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RULE_RSP_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RULE_RSP_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RULE_RSP_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_RSP_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RULE_RSP_T RENAME TO TEMP_KREW_RULE_RSP_T;
CREATE TABLE KREW_RULE_RSP_T
(
      RULE_RSP_ID VARCHAR2(40)
        , RSP_ID VARCHAR2(40) NOT NULL
        , RULE_ID VARCHAR2(40) NOT NULL
        , PRIO NUMBER(5)
        , ACTN_RQST_CD VARCHAR2(2000)
        , NM VARCHAR2(200)
        , TYP VARCHAR2(1)
        , APPR_PLCY CHAR(1)
        , VER_NBR NUMBER(8) default 0
        , OBJ_ID VARCHAR2(36) NOT NULL
    , CONSTRAINT KREW_RULE_RSP_TC0 UNIQUE (OBJ_ID)
);
ALTER TABLE KREW_RULE_RSP_T
    ADD CONSTRAINT KREW_RULE_RSP_TP1
PRIMARY KEY (RULE_RSP_ID);
CREATE INDEX KREW_RULE_RSP_TI1
  ON KREW_RULE_RSP_T
  (RULE_ID);
INSERT INTO KREW_RULE_RSP_T
(RULE_RSP_ID, RSP_ID, RULE_ID, PRIO, ACTN_RQST_CD, NM, TYP, APPR_PLCY, VER_NBR, OBJ_ID)
SELECT CAST(RULE_RSP_ID as VARCHAR2(40)), CAST(RSP_ID as VARCHAR2(40)), CAST(RULE_ID as VARCHAR2(40)),
PRIO, ACTN_RQST_CD, NM, TYP, APPR_PLCY, VER_NBR, OBJ_ID
FROM TEMP_KREW_RULE_RSP_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_RSP_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_RSP_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_EXT_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RULE_EXT_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RULE_EXT_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RULE_EXT_T DROP CONSTRAINT KREW_RULE_EXT_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_EXT_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RULE_EXT_T1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RULE_EXT_T1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RULE_EXT_T1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_EXT_T1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RULE_EXT_T RENAME TO TEMP_KREW_RULE_EXT_T;
CREATE TABLE KREW_RULE_EXT_T
(
      RULE_EXT_ID VARCHAR2(40)
        , RULE_TMPL_ATTR_ID VARCHAR2(40) NOT NULL
        , RULE_ID VARCHAR2(40) NOT NULL
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RULE_EXT_T
    ADD CONSTRAINT KREW_RULE_EXT_TP1
PRIMARY KEY (RULE_EXT_ID);
CREATE INDEX KREW_RULE_EXT_T1
  ON KREW_RULE_EXT_T
  (RULE_ID);
INSERT INTO KREW_RULE_EXT_T
(RULE_EXT_ID, RULE_TMPL_ATTR_ID, RULE_ID, VER_NBR)
SELECT CAST(RULE_EXT_ID as VARCHAR2(40)), CAST(RULE_TMPL_ATTR_ID as VARCHAR2(40)),
CAST(RULE_ID as VARCHAR2(40)), VER_NBR
FROM TEMP_KREW_RULE_EXT_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_EXT_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_EXT_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_NODE_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_NODE_T DROP CONSTRAINT KREW_RTE_NODE_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI4' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_TI4' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_TI4';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_TI4 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_NODE_T RENAME TO TEMP_KREW_RTE_NODE_T;
CREATE TABLE KREW_RTE_NODE_T
(
      RTE_NODE_ID VARCHAR2(40)
        , DOC_TYP_ID NUMBER(19)
        , NM VARCHAR2(255) NOT NULL
        , TYP VARCHAR2(255) NOT NULL
        , RTE_MTHD_NM VARCHAR2(255)
        , RTE_MTHD_CD VARCHAR2(2)
        , FNL_APRVR_IND NUMBER(1)
        , MNDTRY_RTE_IND NUMBER(1)
        , ACTVN_TYP VARCHAR2(250)
        , BRCH_PROTO_ID VARCHAR2(40)
        , VER_NBR NUMBER(8) default 0
        , CONTENT_FRAGMENT VARCHAR2(4000)
        , GRP_ID VARCHAR2(40)
        , NEXT_DOC_STAT VARCHAR2(64)
);
ALTER TABLE KREW_RTE_NODE_T
    ADD CONSTRAINT KREW_RTE_NODE_TP1
PRIMARY KEY (RTE_NODE_ID);
CREATE INDEX KREW_RTE_NODE_TI1
  ON KREW_RTE_NODE_T
  (NM, DOC_TYP_ID);
CREATE INDEX KREW_RTE_NODE_TI2
  ON KREW_RTE_NODE_T
  (DOC_TYP_ID, FNL_APRVR_IND);
CREATE INDEX KREW_RTE_NODE_TI3
  ON KREW_RTE_NODE_T
  (BRCH_PROTO_ID);
CREATE INDEX KREW_RTE_NODE_TI4
  ON KREW_RTE_NODE_T
  (DOC_TYP_ID);
INSERT INTO KREW_RTE_NODE_T
(RTE_NODE_ID, DOC_TYP_ID, NM, TYP, RTE_MTHD_NM, RTE_MTHD_CD, FNL_APRVR_IND,
MNDTRY_RTE_IND, ACTVN_TYP, BRCH_PROTO_ID, VER_NBR, CONTENT_FRAGMENT, GRP_ID, NEXT_DOC_STAT)
SELECT CAST(RTE_NODE_ID as VARCHAR2(40)), DOC_TYP_ID, NM, TYP, RTE_MTHD_NM, RTE_MTHD_CD, FNL_APRVR_IND,
MNDTRY_RTE_IND, ACTVN_TYP, CAST(BRCH_PROTO_ID as VARCHAR2(40)), VER_NBR, CONTENT_FRAGMENT, GRP_ID, NEXT_DOC_STAT
FROM TEMP_KREW_RTE_NODE_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_NODE_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_NODE_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_NODE_INSTN_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_INSTN_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_INSTN_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_NODE_INSTN_T DROP CONSTRAINT KREW_RTE_NODE_INSTN_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI4' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_TI4' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_TI4';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_TI4 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_NODE_INSTN_T RENAME TO TEMP_KREW_RTE_NODE_INSTN_T;
CREATE TABLE KREW_RTE_NODE_INSTN_T
(
      RTE_NODE_INSTN_ID VARCHAR2(40)
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , RTE_NODE_ID VARCHAR2(40) NOT NULL
        , BRCH_ID VARCHAR2(40)
        , PROC_RTE_NODE_INSTN_ID VARCHAR2(40)
        , ACTV_IND NUMBER(1) default 0 NOT NULL
        , CMPLT_IND NUMBER(1) default 0 NOT NULL
        , INIT_IND NUMBER(1) default 0 NOT NULL
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RTE_NODE_INSTN_T
    ADD CONSTRAINT KREW_RTE_NODE_INSTN_TP1
PRIMARY KEY (RTE_NODE_INSTN_ID);
CREATE INDEX KREW_RTE_NODE_INSTN_TI1
  ON KREW_RTE_NODE_INSTN_T
  (DOC_HDR_ID, ACTV_IND, CMPLT_IND);
CREATE INDEX KREW_RTE_NODE_INSTN_TI2
  ON KREW_RTE_NODE_INSTN_T
  (RTE_NODE_ID);
CREATE INDEX KREW_RTE_NODE_INSTN_TI3
  ON KREW_RTE_NODE_INSTN_T
  (BRCH_ID);
CREATE INDEX KREW_RTE_NODE_INSTN_TI4
  ON KREW_RTE_NODE_INSTN_T
  (PROC_RTE_NODE_INSTN_ID);
INSERT INTO KREW_RTE_NODE_INSTN_T
(RTE_NODE_INSTN_ID, DOC_HDR_ID, RTE_NODE_ID, BRCH_ID, PROC_RTE_NODE_INSTN_ID,
ACTV_IND, CMPLT_IND, INIT_IND, VER_NBR)
SELECT CAST(RTE_NODE_INSTN_ID as VARCHAR2(40)), DOC_HDR_ID,
CAST(RTE_NODE_ID as VARCHAR2(40)), CAST(BRCH_ID as VARCHAR2(40)),
CAST(PROC_RTE_NODE_INSTN_ID as VARCHAR2(40)),
ACTV_IND, CMPLT_IND, INIT_IND, VER_NBR
FROM TEMP_KREW_RTE_NODE_INSTN_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_NODE_INSTN_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_NODE_INSTN_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_NODE_INSTN_LNK_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_INSTN_LNK_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_INSTN_LNK_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_NODE_INSTN_LNK_T DROP CONSTRAINT KREW_RTE_NODE_INSTN_LNK_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_LNK_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_LNK_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_LNK_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_LNK_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_LNK_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_LNK_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_LNK_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_LNK_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_LNK_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_NODE_INSTN_LNK_T RENAME TO TEMP_KREW_RTE_NODE_INSTN_LNK_T;
CREATE TABLE KREW_RTE_NODE_INSTN_LNK_T
(
      FROM_RTE_NODE_INSTN_ID VARCHAR2(40)
        , TO_RTE_NODE_INSTN_ID VARCHAR2(40)
);
ALTER TABLE KREW_RTE_NODE_INSTN_LNK_T
    ADD CONSTRAINT KREW_RTE_NODE_INSTN_LNK_TP1
PRIMARY KEY (FROM_RTE_NODE_INSTN_ID,TO_RTE_NODE_INSTN_ID);
CREATE INDEX KREW_RTE_NODE_INSTN_LNK_TI1
  ON KREW_RTE_NODE_INSTN_LNK_T
  (FROM_RTE_NODE_INSTN_ID);
CREATE INDEX KREW_RTE_NODE_INSTN_LNK_TI2
  ON KREW_RTE_NODE_INSTN_LNK_T
  (TO_RTE_NODE_INSTN_ID);
INSERT INTO KREW_RTE_NODE_INSTN_LNK_T
(FROM_RTE_NODE_INSTN_ID,TO_RTE_NODE_INSTN_ID)
SELECT CAST(FROM_RTE_NODE_INSTN_ID as VARCHAR2(40)),CAST(TO_RTE_NODE_INSTN_ID as VARCHAR2(40))
FROM TEMP_KREW_RTE_NODE_INSTN_LNK_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_NODE_INSTN_LNK_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_NODE_INSTN_LNK_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_BRCH_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_BRCH_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_BRCH_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_BRCH_T DROP CONSTRAINT KREW_RTE_BRCH_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI4' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI4' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_TI4';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_TI4 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI5' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_TI5' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_TI5';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_TI5 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_BRCH_T RENAME TO TEMP_KREW_RTE_BRCH_T;
CREATE TABLE KREW_RTE_BRCH_T
(
      RTE_BRCH_ID VARCHAR2(40)
        , NM VARCHAR2(255) NOT NULL
        , PARNT_ID VARCHAR2(40)
        , INIT_RTE_NODE_INSTN_ID VARCHAR2(40)
        , SPLT_RTE_NODE_INSTN_ID VARCHAR2(40)
        , JOIN_RTE_NODE_INSTN_ID VARCHAR2(40)
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RTE_BRCH_T
    ADD CONSTRAINT KREW_RTE_BRCH_TP1
PRIMARY KEY (RTE_BRCH_ID);
CREATE INDEX KREW_RTE_BRCH_TI1
  ON KREW_RTE_BRCH_T
  (NM);
CREATE INDEX KREW_RTE_BRCH_TI2
  ON KREW_RTE_BRCH_T
  (PARNT_ID);
CREATE INDEX KREW_RTE_BRCH_TI3
  ON KREW_RTE_BRCH_T
  (INIT_RTE_NODE_INSTN_ID);
CREATE INDEX KREW_RTE_BRCH_TI4
  ON KREW_RTE_BRCH_T
  (SPLT_RTE_NODE_INSTN_ID);
CREATE INDEX KREW_RTE_BRCH_TI5
  ON KREW_RTE_BRCH_T
  (JOIN_RTE_NODE_INSTN_ID);
INSERT INTO KREW_RTE_BRCH_T
(RTE_BRCH_ID, NM, PARNT_ID, INIT_RTE_NODE_INSTN_ID, SPLT_RTE_NODE_INSTN_ID, JOIN_RTE_NODE_INSTN_ID, VER_NBR)
SELECT
CAST(RTE_BRCH_ID as VARCHAR2(40)), NM, CAST(PARNT_ID as VARCHAR2(40)),
CAST(INIT_RTE_NODE_INSTN_ID as VARCHAR2(40)), CAST(SPLT_RTE_NODE_INSTN_ID as VARCHAR2(40)),
CAST(JOIN_RTE_NODE_INSTN_ID as VARCHAR2(40)), VER_NBR
FROM TEMP_KREW_RTE_BRCH_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_BRCH_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_BRCH_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_BRCH_ST_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_BRCH_ST_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_BRCH_ST_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_BRCH_ST_T DROP CONSTRAINT KREW_RTE_BRCH_ST_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_ST_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_ST_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_ST_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_ST_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_ST_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_ST_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_ST_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_ST_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_ST_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_ST_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_ST_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_ST_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_ST_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_BRCH_ST_T RENAME TO TEMP_KREW_RTE_BRCH_ST_T;
CREATE TABLE KREW_RTE_BRCH_ST_T
(
      RTE_BRCH_ST_ID VARCHAR2(40)
        , RTE_BRCH_ID VARCHAR2(40) NOT NULL
        , KEY_CD VARCHAR2(255) NOT NULL
        , VAL VARCHAR2(2000)
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RTE_BRCH_ST_T
    ADD CONSTRAINT KREW_RTE_BRCH_ST_TP1
PRIMARY KEY (RTE_BRCH_ST_ID);
CREATE INDEX KREW_RTE_BRCH_ST_TI1
  ON KREW_RTE_BRCH_ST_T
  (RTE_BRCH_ID, KEY_CD);
CREATE INDEX KREW_RTE_BRCH_ST_TI2
  ON KREW_RTE_BRCH_ST_T
  (RTE_BRCH_ID);
CREATE INDEX KREW_RTE_BRCH_ST_TI3
  ON KREW_RTE_BRCH_ST_T
  (KEY_CD, VAL);
INSERT INTO KREW_RTE_BRCH_ST_T
(RTE_BRCH_ST_ID, RTE_BRCH_ID, KEY_CD, VAL, VER_NBR)
SELECT
CAST(RTE_BRCH_ST_ID as VARCHAR2(40)), CAST(RTE_BRCH_ID as VARCHAR2(40)), KEY_CD, VAL, VER_NBR
FROM TEMP_KREW_RTE_BRCH_ST_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_BRCH_ST_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_BRCH_ST_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_NODE_INSTN_ST_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_INSTN_ST_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_INSTN_ST_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_NODE_INSTN_ST_T DROP CONSTRAINT KREW_RTE_NODE_INSTN_ST_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_ST_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_ST_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_ST_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_ST_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_ST_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_ST_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_ST_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_ST_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_ST_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_ST_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_INSTN_ST_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_INSTN_ST_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_INSTN_ST_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_NODE_INSTN_ST_T RENAME TO TEMP_KREW_RTE_NODE_INSTN_ST_T;
CREATE TABLE KREW_RTE_NODE_INSTN_ST_T
(
      RTE_NODE_INSTN_ST_ID VARCHAR2(40)
        , RTE_NODE_INSTN_ID VARCHAR2(40) NOT NULL
        , KEY_CD VARCHAR2(255) NOT NULL
        , VAL VARCHAR2(2000)
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RTE_NODE_INSTN_ST_T
    ADD CONSTRAINT KREW_RTE_NODE_INSTN_ST_TP1
PRIMARY KEY (RTE_NODE_INSTN_ST_ID);
CREATE INDEX KREW_RTE_NODE_INSTN_ST_TI1
  ON KREW_RTE_NODE_INSTN_ST_T
  (RTE_NODE_INSTN_ID, KEY_CD);
CREATE INDEX KREW_RTE_NODE_INSTN_ST_TI2
  ON KREW_RTE_NODE_INSTN_ST_T
  (RTE_NODE_INSTN_ID);
CREATE INDEX KREW_RTE_NODE_INSTN_ST_TI3
  ON KREW_RTE_NODE_INSTN_ST_T
  (KEY_CD, VAL);
INSERT INTO KREW_RTE_NODE_INSTN_ST_T
(RTE_NODE_INSTN_ST_ID, RTE_NODE_INSTN_ID, KEY_CD, VAL, VER_NBR)
SELECT
CAST(RTE_NODE_INSTN_ST_ID as VARCHAR2(40)), CAST(RTE_NODE_INSTN_ID as VARCHAR2(40)), KEY_CD, VAL, VER_NBR
FROM TEMP_KREW_RTE_NODE_INSTN_ST_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_NODE_INSTN_ST_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_NODE_INSTN_ST_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DOC_TYP_ATTR_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_TYP_ATTR_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_DOC_TYP_ATTR_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_DOC_TYP_ATTR_T DROP CONSTRAINT KREW_DOC_TYP_ATTR_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_TYP_ATTR_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_TYP_ATTR_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_TYP_ATTR_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_TYP_ATTR_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_TYP_ATTR_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_DOC_TYP_ATTR_T RENAME TO TEMP_KREW_DOC_TYP_ATTR_T;
CREATE TABLE KREW_DOC_TYP_ATTR_T
(
      DOC_TYP_ATTRIB_ID VARCHAR2(40)
        , DOC_TYP_ID VARCHAR2(40) NOT NULL
        , RULE_ATTR_ID VARCHAR2(40) NOT NULL
        , ORD_INDX NUMBER(4) default 0
);
ALTER TABLE KREW_DOC_TYP_ATTR_T
    ADD CONSTRAINT KREW_DOC_TYP_ATTR_TP1
PRIMARY KEY (DOC_TYP_ATTRIB_ID);
CREATE INDEX KREW_DOC_TYP_ATTR_TI1
  ON KREW_DOC_TYP_ATTR_T
  (DOC_TYP_ID);
INSERT INTO KREW_DOC_TYP_ATTR_T
(DOC_TYP_ATTRIB_ID, DOC_TYP_ID, RULE_ATTR_ID, ORD_INDX)
SELECT
CAST(DOC_TYP_ATTRIB_ID as VARCHAR2(40)), CAST(DOC_TYP_ID as VARCHAR2(40)),
CAST(RULE_ATTR_ID as VARCHAR2(40)), ORD_INDX
FROM TEMP_KREW_DOC_TYP_ATTR_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_TYP_ATTR_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_TYP_ATTR_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_ATTR_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_RULE_ATTR_T DROP CONSTRAINT KREW_RULE_ATTR_TC0;
ALTER TABLE KREW_RULE_ATTR_T DROP CONSTRAINT KREW_RULE_ATTR_TP1;
ALTER TABLE KREW_RULE_ATTR_T RENAME TO TEMP_KREW_RULE_ATTR_T;
CREATE TABLE KREW_RULE_ATTR_T
(
      RULE_ATTR_ID VARCHAR2(40)
        , NM VARCHAR2(255) NOT NULL
        , LBL VARCHAR2(2000) NOT NULL
        , RULE_ATTR_TYP_CD VARCHAR2(2000) NOT NULL
        , DESC_TXT VARCHAR2(2000)
        , CLS_NM VARCHAR2(2000)
        , XML CLOB
        , VER_NBR NUMBER(8) default 0
        , APPL_ID VARCHAR2(255)
        , OBJ_ID VARCHAR2(36) NOT NULL
    , CONSTRAINT KREW_RULE_ATTR_TC0 UNIQUE (OBJ_ID)
);
ALTER TABLE KREW_RULE_ATTR_T
    ADD CONSTRAINT KREW_RULE_ATTR_TP1
PRIMARY KEY (RULE_ATTR_ID);
INSERT INTO KREW_RULE_ATTR_T
(RULE_ATTR_ID, NM, LBL, RULE_ATTR_TYP_CD, DESC_TXT, CLS_NM, XML, VER_NBR, APPL_ID, OBJ_ID)
SELECT
CAST(RULE_ATTR_ID as VARCHAR2(40)), NM, LBL, RULE_ATTR_TYP_CD, DESC_TXT, CLS_NM, XML, VER_NBR, APPL_ID, OBJ_ID
FROM TEMP_KREW_RULE_ATTR_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_ATTR_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_ATTR_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_TMPL_OPTN_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_RULE_TMPL_OPTN_T DROP CONSTRAINT KREW_RULE_TMPL_OPTN_TP1;
ALTER TABLE KREW_RULE_TMPL_OPTN_T RENAME TO TEMP_KREW_RULE_TMPL_OPTN_T;
CREATE TABLE KREW_RULE_TMPL_OPTN_T
(
      RULE_TMPL_OPTN_ID VARCHAR2(40)
        , RULE_TMPL_ID VARCHAR2(40)
        , KEY_CD VARCHAR2(250)
        , VAL VARCHAR2(2000)
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RULE_TMPL_OPTN_T
    ADD CONSTRAINT KREW_RULE_TMPL_OPTN_TP1
PRIMARY KEY (RULE_TMPL_OPTN_ID);
INSERT INTO KREW_RULE_TMPL_OPTN_T
(RULE_TMPL_OPTN_ID, RULE_TMPL_ID, KEY_CD, VAL, VER_NBR)
SELECT
CAST(RULE_TMPL_OPTN_ID as VARCHAR2(40)), CAST(RULE_TMPL_ID as VARCHAR2(40)), KEY_CD, VAL, VER_NBR
FROM TEMP_KREW_RULE_TMPL_OPTN_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_TMPL_OPTN_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_TMPL_OPTN_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_OUT_BOX_ITM_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_OUT_BOX_ITM_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_OUT_BOX_ITM_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_OUT_BOX_ITM_T DROP CONSTRAINT KREW_OUT_BOX_ITM_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_OUT_BOX_ITM_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_OUT_BOX_ITM_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_OUT_BOX_ITM_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_OUT_BOX_ITM_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_OUT_BOX_ITM_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_OUT_BOX_ITM_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_OUT_BOX_ITM_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_OUT_BOX_ITM_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_OUT_BOX_ITM_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_OUT_BOX_ITM_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_OUT_BOX_ITM_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_OUT_BOX_ITM_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_OUT_BOX_ITM_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_OUT_BOX_ITM_T RENAME TO TEMP_KREW_OUT_BOX_ITM_T;
CREATE TABLE KREW_OUT_BOX_ITM_T
(
      ACTN_ITM_ID VARCHAR2(40)
        , PRNCPL_ID VARCHAR2(40) NOT NULL
        , ASND_DT DATE NOT NULL
        , RQST_CD CHAR(1) NOT NULL
        , ACTN_RQST_ID VARCHAR2(40) NOT NULL
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , ROLE_NM VARCHAR2(2000)
        , DLGN_PRNCPL_ID VARCHAR2(40)
        , DOC_HDR_TTL VARCHAR2(255)
        , DOC_TYP_LBL VARCHAR2(128) NOT NULL
        , DOC_HDLR_URL VARCHAR2(255) NOT NULL
        , DOC_TYP_NM VARCHAR2(64) NOT NULL
        , RSP_ID VARCHAR2(40) NOT NULL
        , DLGN_TYP VARCHAR2(1)
        , VER_NBR NUMBER(8) default 0
        , GRP_ID VARCHAR2(40)
        , DLGN_GRP_ID VARCHAR2(40)
        , RQST_LBL VARCHAR2(255)
);
ALTER TABLE KREW_OUT_BOX_ITM_T
    ADD CONSTRAINT KREW_OUT_BOX_ITM_TP1
PRIMARY KEY (ACTN_ITM_ID);
CREATE INDEX KREW_OUT_BOX_ITM_TI1
  ON KREW_OUT_BOX_ITM_T
  (PRNCPL_ID);
CREATE INDEX KREW_OUT_BOX_ITM_TI2
  ON KREW_OUT_BOX_ITM_T
  (DOC_HDR_ID);
CREATE INDEX KREW_OUT_BOX_ITM_TI3
  ON KREW_OUT_BOX_ITM_T
  (ACTN_RQST_ID);
INSERT INTO KREW_OUT_BOX_ITM_T
(ACTN_ITM_ID, PRNCPL_ID, ASND_DT, RQST_CD, ACTN_RQST_ID, DOC_HDR_ID, ROLE_NM,
DLGN_PRNCPL_ID, DOC_HDR_TTL, DOC_TYP_LBL, DOC_HDLR_URL, DOC_TYP_NM, RSP_ID,
DLGN_TYP, VER_NBR, GRP_ID, DLGN_GRP_ID, RQST_LBL)
SELECT
CAST(ACTN_ITM_ID as VARCHAR2(40)), PRNCPL_ID, ASND_DT, RQST_CD, CAST(ACTN_RQST_ID as VARCHAR2(40)),
DOC_HDR_ID, ROLE_NM,
DLGN_PRNCPL_ID, DOC_HDR_TTL, DOC_TYP_LBL, DOC_HDLR_URL, DOC_TYP_NM,
CAST(RSP_ID as VARCHAR2(40)),
DLGN_TYP, VER_NBR, GRP_ID, DLGN_GRP_ID, RQST_LBL
FROM TEMP_KREW_OUT_BOX_ITM_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_OUT_BOX_ITM_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_OUT_BOX_ITM_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_NODE_CFG_PARM_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_CFG_PARM_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_NODE_CFG_PARM_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_NODE_CFG_PARM_T DROP CONSTRAINT KREW_RTE_NODE_CFG_PARM_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_CFG_PARM_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_NODE_CFG_PARM_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_NODE_CFG_PARM_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_NODE_CFG_PARM_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_NODE_CFG_PARM_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_NODE_CFG_PARM_T RENAME TO TEMP_KREW_RTE_NODE_CFG_PARM_T;
CREATE TABLE KREW_RTE_NODE_CFG_PARM_T
(
      RTE_NODE_CFG_PARM_ID VARCHAR2(40)
        , RTE_NODE_ID VARCHAR2(40) NOT NULL
        , KEY_CD VARCHAR2(255) NOT NULL
        , VAL VARCHAR2(4000)
);
ALTER TABLE KREW_RTE_NODE_CFG_PARM_T
    ADD CONSTRAINT KREW_RTE_NODE_CFG_PARM_TP1
PRIMARY KEY (RTE_NODE_CFG_PARM_ID);
CREATE INDEX KREW_RTE_NODE_CFG_PARM_TI1
  ON KREW_RTE_NODE_CFG_PARM_T
  (RTE_NODE_ID);
INSERT INTO KREW_RTE_NODE_CFG_PARM_T
(RTE_NODE_CFG_PARM_ID, RTE_NODE_ID, KEY_CD, VAL)
SELECT
CAST(RTE_NODE_CFG_PARM_ID as VARCHAR2(40)), CAST(RTE_NODE_ID as VARCHAR2(40)), KEY_CD, VAL
FROM TEMP_KREW_RTE_NODE_CFG_PARM_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_NODE_CFG_PARM_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_NODE_CFG_PARM_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DOC_TYP_PROC_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_TYP_PROC_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_DOC_TYP_PROC_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_DOC_TYP_PROC_T DROP CONSTRAINT KREW_DOC_TYP_PROC_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_TYP_PROC_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_TYP_PROC_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_TYP_PROC_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_TYP_PROC_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_TYP_PROC_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_TYP_PROC_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_TYP_PROC_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_TYP_PROC_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_TYP_PROC_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_TYP_PROC_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_TYP_PROC_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_TYP_PROC_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_TYP_PROC_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_DOC_TYP_PROC_T RENAME TO TEMP_KREW_DOC_TYP_PROC_T;
CREATE TABLE KREW_DOC_TYP_PROC_T
(
      DOC_TYP_PROC_ID VARCHAR2(40)
        , DOC_TYP_ID VARCHAR2(40) NOT NULL
        , INIT_RTE_NODE_ID NUMBER(22)
        , NM VARCHAR2(255) NOT NULL
        , INIT_IND NUMBER(1) default 0 NOT NULL
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_DOC_TYP_PROC_T
    ADD CONSTRAINT KREW_DOC_TYP_PROC_TP1
PRIMARY KEY (DOC_TYP_PROC_ID);
CREATE INDEX KREW_DOC_TYP_PROC_TI1
  ON KREW_DOC_TYP_PROC_T
  (DOC_TYP_ID);
CREATE INDEX KREW_DOC_TYP_PROC_TI2
  ON KREW_DOC_TYP_PROC_T
  (INIT_RTE_NODE_ID);
CREATE INDEX KREW_DOC_TYP_PROC_TI3
  ON KREW_DOC_TYP_PROC_T
  (NM);
INSERT INTO KREW_DOC_TYP_PROC_T
(DOC_TYP_PROC_ID, DOC_TYP_ID, INIT_RTE_NODE_ID, NM, INIT_IND, VER_NBR)
SELECT
CAST(DOC_TYP_PROC_ID as VARCHAR2(40)), CAST(DOC_TYP_ID as VARCHAR2(40)), INIT_RTE_NODE_ID,
NM, INIT_IND, VER_NBR
FROM TEMP_KREW_DOC_TYP_PROC_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_TYP_PROC_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_TYP_PROC_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DOC_LNK_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_LNK_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_DOC_LNK_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_DOC_LNK_T DROP CONSTRAINT KREW_DOC_LNK_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_LNK_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_LNK_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_LNK_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_LNK_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_LNK_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_DOC_LNK_T RENAME TO TEMP_KREW_DOC_LNK_T;
CREATE TABLE KREW_DOC_LNK_T
(
      DOC_LNK_ID VARCHAR2(40)
        , ORGN_DOC_ID VARCHAR2(40) NOT NULL
        , DEST_DOC_ID VARCHAR2(40) NOT NULL
);
ALTER TABLE KREW_DOC_LNK_T
    ADD CONSTRAINT KREW_DOC_LNK_TP1
PRIMARY KEY (DOC_LNK_ID);
CREATE INDEX KREW_DOC_LNK_TI1
  ON KREW_DOC_LNK_T
  (ORGN_DOC_ID);
INSERT INTO KREW_DOC_LNK_T
(DOC_LNK_ID, ORGN_DOC_ID, DEST_DOC_ID)
SELECT
CAST(DOC_LNK_ID as VARCHAR2(40)), ORGN_DOC_ID, DEST_DOC_ID
FROM TEMP_KREW_DOC_LNK_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_LNK_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_LNK_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RTE_BRCH_PROTO_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RTE_BRCH_PROTO_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RTE_BRCH_PROTO_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RTE_BRCH_PROTO_T DROP CONSTRAINT KREW_RTE_BRCH_PROTO_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_PROTO_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RTE_BRCH_PROTO_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RTE_BRCH_PROTO_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RTE_BRCH_PROTO_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RTE_BRCH_PROTO_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RTE_BRCH_PROTO_T RENAME TO TEMP_KREW_RTE_BRCH_PROTO_T;
CREATE TABLE KREW_RTE_BRCH_PROTO_T
(
      RTE_BRCH_PROTO_ID VARCHAR2(40)
        , BRCH_NM VARCHAR2(255) NOT NULL
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RTE_BRCH_PROTO_T
    ADD CONSTRAINT KREW_RTE_BRCH_PROTO_TP1
PRIMARY KEY (RTE_BRCH_PROTO_ID);
CREATE INDEX KREW_RTE_BRCH_PROTO_TI1
  ON KREW_RTE_BRCH_PROTO_T
  (BRCH_NM);
INSERT INTO KREW_RTE_BRCH_PROTO_T
(RTE_BRCH_PROTO_ID, BRCH_NM, VER_NBR)
SELECT
CAST(RTE_BRCH_PROTO_ID as VARCHAR2(40)), BRCH_NM, VER_NBR
FROM TEMP_KREW_RTE_BRCH_PROTO_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RTE_BRCH_PROTO_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RTE_BRCH_PROTO_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_HLP_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_HLP_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_HLP_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_HLP_T DROP CONSTRAINT KREW_HLP_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_HLP_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_HLP_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_HLP_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_HLP_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_HLP_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_HLP_T RENAME TO TEMP_KREW_HLP_T;
CREATE TABLE KREW_HLP_T
(
      HLP_ID VARCHAR2(40)
        , NM VARCHAR2(500) NOT NULL
        , KEY_CD VARCHAR2(500) NOT NULL
        , HLP_TXT VARCHAR2(4000) NOT NULL
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_HLP_T
    ADD CONSTRAINT KREW_HLP_TP1
PRIMARY KEY (HLP_ID);
CREATE INDEX KREW_HLP_TI1
  ON KREW_HLP_T
  (KEY_CD);
INSERT INTO KREW_HLP_T
(HLP_ID, NM, KEY_CD, HLP_TXT, VER_NBR)
SELECT
CAST(HLP_ID as VARCHAR2(40)), NM, KEY_CD, HLP_TXT, VER_NBR
FROM TEMP_KREW_HLP_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_HLP_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_HLP_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_EXT_VAL_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_RULE_EXT_VAL_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_RULE_EXT_VAL_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_RULE_EXT_VAL_T DROP CONSTRAINT KREW_RULE_EXT_VAL_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_EXT_VAL_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RULE_EXT_VAL_T1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RULE_EXT_VAL_T1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RULE_EXT_VAL_T1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_EXT_VAL_T1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_RULE_EXT_VAL_T2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_RULE_EXT_VAL_T2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_RULE_EXT_VAL_T2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_RULE_EXT_VAL_T2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_RULE_EXT_VAL_T RENAME TO TEMP_KREW_RULE_EXT_VAL_T;
CREATE TABLE KREW_RULE_EXT_VAL_T
(
      RULE_EXT_VAL_ID VARCHAR2(40)
        , RULE_EXT_ID VARCHAR2(40) NOT NULL
        , VAL VARCHAR2(2000) NOT NULL
        , KEY_CD VARCHAR2(2000) NOT NULL
        , VER_NBR NUMBER(8) default 0
);
ALTER TABLE KREW_RULE_EXT_VAL_T
    ADD CONSTRAINT KREW_RULE_EXT_VAL_TP1
PRIMARY KEY (RULE_EXT_VAL_ID);
CREATE INDEX KREW_RULE_EXT_VAL_T1
  ON KREW_RULE_EXT_VAL_T
  (RULE_EXT_ID);
CREATE INDEX KREW_RULE_EXT_VAL_T2
  ON KREW_RULE_EXT_VAL_T
  (RULE_EXT_VAL_ID, KEY_CD);
INSERT INTO KREW_RULE_EXT_VAL_T
(RULE_EXT_VAL_ID, RULE_EXT_ID, VAL, KEY_CD, VER_NBR)
SELECT
CAST(RULE_EXT_VAL_ID as VARCHAR2(40)), CAST(RULE_EXT_ID as VARCHAR2(40)), VAL, KEY_CD, VER_NBR
FROM TEMP_KREW_RULE_EXT_VAL_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_EXT_VAL_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_EXT_VAL_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_RULE_EXPR_T
-----------------------------------------------------------------------------
ALTER TABLE KREW_RULE_EXPR_T DROP CONSTRAINT KREW_RULE_EXPR_TP1;
ALTER TABLE KREW_RULE_EXPR_T RENAME TO TEMP_KREW_RULE_EXPR_T;
ALTER TABLE TEMP_KREW_RULE_EXPR_T DROP CONSTRAINT KREW_RULE_EXPR_TC0;
CREATE TABLE KREW_RULE_EXPR_T
(
      RULE_EXPR_ID VARCHAR2(40)
        , TYP VARCHAR2(256) NOT NULL
        , RULE_EXPR VARCHAR2(4000)
        , OBJ_ID VARCHAR2(36) NOT NULL
        , VER_NBR NUMBER(8) default 0
    , CONSTRAINT KREW_RULE_EXPR_TC0 UNIQUE (OBJ_ID)
);
ALTER TABLE KREW_RULE_EXPR_T
    ADD CONSTRAINT KREW_RULE_EXPR_TP1
PRIMARY KEY (RULE_EXPR_ID);
INSERT INTO KREW_RULE_EXPR_T
(RULE_EXPR_ID, TYP, RULE_EXPR, OBJ_ID, VER_NBR)
SELECT
CAST(RULE_EXPR_ID as VARCHAR2(40)), TYP, RULE_EXPR, OBJ_ID, VER_NBR
FROM TEMP_KREW_RULE_EXPR_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_RULE_EXPR_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_RULE_EXPR_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_APP_DOC_STAT_TRAN_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_APP_DOC_STAT_TRAN_TC0' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_APP_DOC_STAT_TRAN_TC0' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_APP_DOC_STAT_TRAN_T DROP CONSTRAINT KREW_APP_DOC_STAT_TRAN_TC0';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_APP_DOC_STAT_TRAN_TC0 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_APP_DOC_STAT_TRAN_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_APP_DOC_STAT_TRAN_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_APP_DOC_STAT_TRAN_T DROP CONSTRAINT KREW_APP_DOC_STAT_TRAN_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_APP_DOC_STAT_TRAN_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_APP_DOC_STAT_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_APP_DOC_STAT_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_APP_DOC_STAT_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_APP_DOC_STAT_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_APP_DOC_STAT_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_APP_DOC_STAT_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_APP_DOC_STAT_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_APP_DOC_STAT_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_APP_DOC_STAT_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_APP_DOC_STAT_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_APP_DOC_STAT_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_APP_DOC_STAT_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_APP_DOC_STAT_TRAN_T RENAME TO TEMP_KREW_APP_DOC_STAT_TRAN_T;
CREATE TABLE KREW_APP_DOC_STAT_TRAN_T
(
      APP_DOC_STAT_TRAN_ID VARCHAR2(40)
        , DOC_HDR_ID VARCHAR2(40)
        , APP_DOC_STAT_FROM VARCHAR2(64)
        , APP_DOC_STAT_TO VARCHAR2(64)
        , STAT_TRANS_DATE DATE
        , VER_NBR NUMBER(8) default 0
        , OBJ_ID VARCHAR2(36) NOT NULL
    , CONSTRAINT KREW_APP_DOC_STAT_TRAN_TC0 UNIQUE (OBJ_ID)
);
ALTER TABLE KREW_APP_DOC_STAT_TRAN_T
    ADD CONSTRAINT KREW_APP_DOC_STAT_TRAN_TP1
PRIMARY KEY (APP_DOC_STAT_TRAN_ID);
CREATE INDEX KREW_APP_DOC_STAT_TI1
  ON KREW_APP_DOC_STAT_TRAN_T
  (DOC_HDR_ID, STAT_TRANS_DATE);
CREATE INDEX KREW_APP_DOC_STAT_TI2
  ON KREW_APP_DOC_STAT_TRAN_T
  (DOC_HDR_ID, APP_DOC_STAT_FROM);
CREATE INDEX KREW_APP_DOC_STAT_TI3
  ON KREW_APP_DOC_STAT_TRAN_T
  (DOC_HDR_ID, APP_DOC_STAT_TO);
INSERT INTO KREW_APP_DOC_STAT_TRAN_T
(APP_DOC_STAT_TRAN_ID, DOC_HDR_ID, APP_DOC_STAT_FROM, APP_DOC_STAT_TO, STAT_TRANS_DATE, VER_NBR, OBJ_ID)
SELECT
CAST(APP_DOC_STAT_TRAN_ID as VARCHAR2(40)), DOC_HDR_ID, APP_DOC_STAT_FROM, APP_DOC_STAT_TO, STAT_TRANS_DATE, VER_NBR, OBJ_ID
FROM TEMP_KREW_APP_DOC_STAT_TRAN_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_APP_DOC_STAT_TRAN_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_APP_DOC_STAT_TRAN_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DOC_HDR_EXT_DT_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_DT_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_DT_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_DOC_HDR_EXT_DT_T DROP CONSTRAINT KREW_DOC_HDR_EXT_DT_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_DT_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_DT_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_DT_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_DT_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_DT_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_DT_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_DT_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_DT_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_DT_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_DT_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_DT_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_DT_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_DT_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_DOC_HDR_EXT_DT_T RENAME TO TEMP_KREW_DOC_HDR_EXT_DT_T;
CREATE TABLE KREW_DOC_HDR_EXT_DT_T
(
      DOC_HDR_EXT_DT_ID VARCHAR2(40)
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , KEY_CD VARCHAR2(256) NOT NULL
        , VAL DATE
);
ALTER TABLE KREW_DOC_HDR_EXT_DT_T
    ADD CONSTRAINT KREW_DOC_HDR_EXT_DT_TP1
PRIMARY KEY (DOC_HDR_EXT_DT_ID);
CREATE INDEX KREW_DOC_HDR_EXT_DT_TI1
  ON KREW_DOC_HDR_EXT_DT_T
  (KEY_CD, VAL);
CREATE INDEX KREW_DOC_HDR_EXT_DT_TI2
  ON KREW_DOC_HDR_EXT_DT_T
  (DOC_HDR_ID);
CREATE INDEX KREW_DOC_HDR_EXT_DT_TI3
  ON KREW_DOC_HDR_EXT_DT_T
  (VAL);
INSERT INTO KREW_DOC_HDR_EXT_DT_T
(DOC_HDR_EXT_DT_ID, DOC_HDR_ID, KEY_CD, VAL)
SELECT
CAST(DOC_HDR_EXT_DT_ID as VARCHAR2(40)), DOC_HDR_ID, KEY_CD, VAL
FROM TEMP_KREW_DOC_HDR_EXT_DT_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_HDR_EXT_DT_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_HDR_EXT_DT_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DOC_HDR_EXT_LONG_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_LONG_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_LONG_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_DOC_HDR_EXT_LONG_T DROP CONSTRAINT KREW_DOC_HDR_EXT_LONG_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_LONG_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_LONG_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_LONG_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_LONG_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_LONG_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_LONG_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_LONG_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_LONG_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_LONG_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_LONG_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_LONG_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_LONG_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_LONG_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_DOC_HDR_EXT_LONG_T RENAME TO TEMP_KREW_DOC_HDR_EXT_LONG_T;
CREATE TABLE KREW_DOC_HDR_EXT_LONG_T
(
      DOC_HDR_EXT_LONG_ID VARCHAR2(40)
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , KEY_CD VARCHAR2(256) NOT NULL
        , VAL NUMBER(22)
);
ALTER TABLE KREW_DOC_HDR_EXT_LONG_T
    ADD CONSTRAINT KREW_DOC_HDR_EXT_LONG_TP1
PRIMARY KEY (DOC_HDR_EXT_LONG_ID);
CREATE INDEX KREW_DOC_HDR_EXT_LONG_TI1
  ON KREW_DOC_HDR_EXT_LONG_T
  (KEY_CD, VAL);
CREATE INDEX KREW_DOC_HDR_EXT_LONG_TI2
  ON KREW_DOC_HDR_EXT_LONG_T
  (DOC_HDR_ID);
CREATE INDEX KREW_DOC_HDR_EXT_LONG_TI3
  ON KREW_DOC_HDR_EXT_LONG_T
  (VAL);
INSERT INTO KREW_DOC_HDR_EXT_LONG_T
(DOC_HDR_EXT_LONG_ID, DOC_HDR_ID, KEY_CD, VAL)
SELECT
CAST(DOC_HDR_EXT_LONG_ID as VARCHAR2(40)), DOC_HDR_ID, KEY_CD, VAL
FROM TEMP_KREW_DOC_HDR_EXT_LONG_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_HDR_EXT_LONG_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_HDR_EXT_LONG_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DOC_HDR_EXT_FLT_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_FLT_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_FLT_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_DOC_HDR_EXT_FLT_T DROP CONSTRAINT KREW_DOC_HDR_EXT_FLT_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_FLT_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_FLT_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_FLT_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_FLT_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_FLT_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_FLT_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_FLT_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_FLT_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_FLT_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_FLT_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_FLT_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_FLT_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_FLT_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_DOC_HDR_EXT_FLT_T RENAME TO TEMP_KREW_DOC_HDR_EXT_FLT_T;
CREATE TABLE KREW_DOC_HDR_EXT_FLT_T
(
      DOC_HDR_EXT_FLT_ID VARCHAR2(40)
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , KEY_CD VARCHAR2(256) NOT NULL
        , VAL NUMBER(30,15)
);
ALTER TABLE KREW_DOC_HDR_EXT_FLT_T
    ADD CONSTRAINT KREW_DOC_HDR_EXT_FLT_TP1
PRIMARY KEY (DOC_HDR_EXT_FLT_ID);
CREATE INDEX KREW_DOC_HDR_EXT_FLT_TI1
  ON KREW_DOC_HDR_EXT_FLT_T
  (KEY_CD, VAL);
CREATE INDEX KREW_DOC_HDR_EXT_FLT_TI2
  ON KREW_DOC_HDR_EXT_FLT_T
  (DOC_HDR_ID);
CREATE INDEX KREW_DOC_HDR_EXT_FLT_TI3
  ON KREW_DOC_HDR_EXT_FLT_T
  (VAL);
INSERT INTO KREW_DOC_HDR_EXT_FLT_T
(DOC_HDR_EXT_FLT_ID, DOC_HDR_ID, KEY_CD, VAL)
SELECT
CAST(DOC_HDR_EXT_FLT_ID as VARCHAR2(40)), DOC_HDR_ID, KEY_CD, VAL
FROM TEMP_KREW_DOC_HDR_EXT_FLT_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_HDR_EXT_FLT_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_HDR_EXT_FLT_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/
-----------------------------------------------------------------------------
-- KREW_DOC_HDR_EXT_T
-----------------------------------------------------------------------------
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_TP1' ;
=======
select count(*) into c from user_constraints where CONSTRAINT_NAME = 'KREW_DOC_HDR_EXT_TP1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE KREW_DOC_HDR_EXT_T DROP CONSTRAINT KREW_DOC_HDR_EXT_TP1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_TP1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_TI1' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_TI1' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_TI1';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_TI1 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_TI2' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_TI2' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_TI2';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_TI2 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
DECLARE
c NUMBER;
BEGIN
<<<<<<< HEAD
select count(*) into c from all_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_TI3' ;
=======
select count(*) into c from user_indexes where INDEX_NAME = 'KREW_DOC_HDR_EXT_TI3' ;
>>>>>>> coeus-1505.70
IF c>0 THEN
EXECUTE IMMEDIATE 'DROP INDEX KREW_DOC_HDR_EXT_TI3';
ELSE
DBMS_OUTPUT.PUT_LINE('KREW_DOC_HDR_EXT_TI3 does not exist, so not running statement to change/drop it.');
END IF;
end;
/
ALTER TABLE KREW_DOC_HDR_EXT_T RENAME TO TEMP_KREW_DOC_HDR_EXT_T;
CREATE TABLE KREW_DOC_HDR_EXT_T
(
      DOC_HDR_EXT_ID VARCHAR2(40)
        , DOC_HDR_ID VARCHAR2(40) NOT NULL
        , KEY_CD VARCHAR2(256) NOT NULL
        , VAL VARCHAR2(2000)
);
ALTER TABLE KREW_DOC_HDR_EXT_T
    ADD CONSTRAINT KREW_DOC_HDR_EXT_TP1
PRIMARY KEY (DOC_HDR_EXT_ID);
CREATE INDEX KREW_DOC_HDR_EXT_TI1
  ON KREW_DOC_HDR_EXT_T
  (KEY_CD, VAL);
CREATE INDEX KREW_DOC_HDR_EXT_TI2
  ON KREW_DOC_HDR_EXT_T
  (DOC_HDR_ID);
CREATE INDEX KREW_DOC_HDR_EXT_TI3
  ON KREW_DOC_HDR_EXT_T
  (VAL);
INSERT INTO KREW_DOC_HDR_EXT_T
(DOC_HDR_EXT_ID, DOC_HDR_ID, KEY_CD, VAL)
SELECT
CAST(DOC_HDR_EXT_ID as VARCHAR2(40)), DOC_HDR_ID, KEY_CD, VAL
FROM TEMP_KREW_DOC_HDR_EXT_T;
DECLARE temp NUMBER;
BEGIN
    SELECT COUNT(*) INTO temp FROM user_tables WHERE table_name = 'TEMP_KREW_DOC_HDR_EXT_T';
    IF temp > 0 THEN EXECUTE IMMEDIATE 'DROP TABLE TEMP_KREW_DOC_HDR_EXT_T CASCADE CONSTRAINTS PURGE'; END IF;
end;
/

-----------------------------------------------------------------------------
-- FOREIGN KEY CONSTRAINTS IMPACTED BY CHANGES
-----------------------------------------------------------------------------
ALTER TABLE KREW_RULE_T
    ADD CONSTRAINT KREW_RULE_TR1 FOREIGN KEY (RULE_EXPR_ID)
    REFERENCES KREW_RULE_EXPR_T (RULE_EXPR_ID);
ALTER TABLE KREW_RTE_NODE_CFG_PARM_T
    ADD CONSTRAINT EN_RTE_NODE_CFG_PARM_TR1 FOREIGN KEY (RTE_NODE_ID)
    REFERENCES KREW_RTE_NODE_T (RTE_NODE_ID);
