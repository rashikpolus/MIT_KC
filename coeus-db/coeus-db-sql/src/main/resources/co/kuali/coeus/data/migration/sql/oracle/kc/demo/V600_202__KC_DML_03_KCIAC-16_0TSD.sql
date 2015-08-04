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

INSERT INTO QUESTIONNAIRE(QUESTIONNAIRE_REF_ID,QUESTIONNAIRE_ID,NAME,DESCRIPTION,SEQUENCE_NUMBER,IS_FINAL,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR)
    VALUES (SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,SEQ_QUESTIONNAIRE_ID.NEXTVAL,'IACUC Long','IACUC Long Questionnaire',1,'Y','admin',SYSDATE,SYS_GUID(),1);
INSERT INTO QUESTIONNAIRE(QUESTIONNAIRE_REF_ID,QUESTIONNAIRE_ID,NAME,DESCRIPTION,SEQUENCE_NUMBER,IS_FINAL,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR)
    VALUES (SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,SEQ_QUESTIONNAIRE_ID.NEXTVAL,'IACUC Short','IACUC Short Questionnaire',1,'Y','admin',SYSDATE,SYS_GUID(),1);
INSERT INTO QUESTIONNAIRE_USAGE(QUESTIONNAIRE_USAGE_ID,QUESTIONNAIRE_REF_ID_FK,MODULE_ITEM_CODE,MODULE_SUB_ITEM_CODE,RULE_ID,QUESTIONNAIRE_LABEL,QUESTIONNAIRE_SEQUENCE_NUMBER,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR)
    VALUES (SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID FROM QUESTIONNAIRE WHERE NAME = 'IACUC Long' AND SEQUENCE_NUMBER = 1),(SELECT MODULE_CODE FROM COEUS_MODULE WHERE DESCRIPTION = 'IACUC Protocol'),0,NULL,'IACUC Long Questionnaire',1,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO QUESTIONNAIRE_USAGE(QUESTIONNAIRE_USAGE_ID,QUESTIONNAIRE_REF_ID_FK,MODULE_ITEM_CODE,MODULE_SUB_ITEM_CODE,RULE_ID,QUESTIONNAIRE_LABEL,QUESTIONNAIRE_SEQUENCE_NUMBER,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR)
    VALUES (SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID FROM QUESTIONNAIRE WHERE NAME = 'IACUC Short' AND SEQUENCE_NUMBER = 1),(SELECT MODULE_CODE FROM COEUS_MODULE WHERE DESCRIPTION = 'IACUC Protocol'),0,NULL,'IACUC Short Questionnaire',1,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),1,1,1,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),2,33,2,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),3,85,3,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),4,89,4,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),5,301,5,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),6,309,6,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N','4','Y',SYS_GUID(),1,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),7,9,1,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N','4','Y',SYS_GUID(),1,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),8,33,2,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N','8','5',SYS_GUID(),3,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),9,37,1,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('Y','4','Arizona',SYS_GUID(),5,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),10,305,1,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N','11','01/01/2010',SYS_GUID(),6,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),11,313,1,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N','1','N',SYS_GUID(),7,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Long'),12,69,1,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Short'),1,1,1,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('N',SYS_GUID(),0,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Short'),2,69,2,SYSDATE,'admin',1);
INSERT INTO QUESTIONNAIRE_QUESTIONS (CONDITION_FLAG,CONDITION_TYPE,CONDITION_VALUE,OBJ_ID,PARENT_QUESTION_NUMBER,QUESTIONNAIRE_QUESTIONS_ID,QUESTIONNAIRE_REF_ID_FK,QUESTION_NUMBER,QUESTION_REF_ID_FK,QUESTION_SEQ_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR)
  VALUES ('Y','1','GOOG',SYS_GUID(),2,SEQ_QUESTIONNAIRE_REF_ID.NEXTVAL,(SELECT QUESTIONNAIRE_REF_ID from QUESTIONNAIRE WHERE NAME='IACUC Short'),3,17,1,SYSDATE,'admin',1);
