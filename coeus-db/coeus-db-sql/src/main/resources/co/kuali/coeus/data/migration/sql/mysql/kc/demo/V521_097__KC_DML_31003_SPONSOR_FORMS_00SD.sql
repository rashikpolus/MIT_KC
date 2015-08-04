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

DELIMITER /
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'009800',2,'Generic Printing Forms (Coeus 4.x)','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'000340',5,'NIH 398 package (Coeus 4.0)','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'000340',6,'NIH 2590 package (Coeus 4.0)','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'000340',1,'NIH 398 package (Coeus 3.8)','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'009800',1,'Generic Printing Forms','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'999999',1,'294 Subcontracting Report For Individual Contracts','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'000500',2,'NSF Forms (Coeus 3.8)','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'000340',2,'NIH 2590 package (Coeus 3.8)','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'000500',1,'NSF forms (Coeus 4.0)','admin',NOW(),UUID(),1)
/
INSERT INTO SEQ_SPONSOR_FORMS VALUES(NULL)
/
INSERT INTO SPONSOR_FORMS (SPONSOR_FORM_ID,SPONSOR_CODE,PACKAGE_NUMBER,PACKAGE_NAME,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
VALUES ((SELECT (MAX(ID)) FROM SEQ_SPONSOR_FORMS),'999999',2,'295 Summary Subcontracting Report','admin',NOW(),UUID(),1)
/
DELIMITER ;
