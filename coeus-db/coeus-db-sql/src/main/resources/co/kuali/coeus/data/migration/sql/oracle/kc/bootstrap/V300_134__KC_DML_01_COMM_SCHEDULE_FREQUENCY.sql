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

TRUNCATE TABLE COMM_SCHEDULE_FREQUENCY DROP STORAGE;
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (1,'Daily',1,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (2,'Weekly',7,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (3,'Yearly',null,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (4,'Monthly',null,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (5,'BiWeekly',14,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (6,'BiWeekly- 1st 3rd',null,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (7,'BiWeekly- 2d  4th',null,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (8,'Monthly- 1st',null,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (9,'Monthly- 2d',null,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (10,'Monthly- 3d',null,'admin',SYSDATE,SYS_GUID(),1);
INSERT INTO COMM_SCHEDULE_FREQUENCY (FREQUENCY_CODE,DESCRIPTION,NO_OF_DAYS,UPDATE_USER,UPDATE_TIMESTAMP,OBJ_ID,VER_NBR) 
    VALUES (11,'Monthly- 4th',null,'admin',SYSDATE,SYS_GUID(),1);
