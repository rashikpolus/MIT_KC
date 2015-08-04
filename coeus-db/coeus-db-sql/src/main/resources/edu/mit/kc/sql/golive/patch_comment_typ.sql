ALTER TABLE AWARD_COMMENT DISABLE CONSTRAINT FK_AWARD_COMMENT_COMMENT_TYPE
/
ALTER TABLE AWARD_TEMPLATE_COMMENTS DISABLE CONSTRAINT FK_AWARD_TEMPLATE_COMMENT_CODE
/
ALTER TABLE PROPOSAL_COMMENTS DISABLE CONSTRAINT FK_PROPOSAL_COMMENTS_CODE
/
delete from COMMENT_TYPE
/
commit
/
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('20','Pre-Award Sponsor Auth Comments ','N','N','N',to_date('28-OCT-14','DD-MON-RR'),'admin',1,'06846FA11709C545E0531C3C0312BD01');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('21','Pre-Award Institutional Auth Comments','N','N','N',to_date('28-OCT-14','DD-MON-RR'),'admin',1,'06846FA1170AC545E0531C3C0312BD01');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('23','Benefits Rates Comments','N','N','N',to_date('28-OCT-14','DD-MON-RR'),'admin',1,'06846FA1170BC545E0531C3C0312BD01');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('22','Current Action Comments','N','N','N',to_date('28-OCT-14','DD-MON-RR'),'admin',1,'06846FA1170CC545E0531C3C0312BD01');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('2','General Comments','Y','N','Y',to_date('18-JUN-96','DD-MON-RR'),'sdowdy',1,'08CBADA0A1B48F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('4','Intellectual Property Comments','Y','N','Y',to_date('20-SEP-95','DD-MON-RR'),'pgreer',1,'08CBADA0A1B58F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('9','Cost Sharing Comments','N','N','N',to_date('16-OCT-95','DD-MON-RR'),'ospa',1,'08CBADA0A1B68F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('3','Fiscal Report Comments','Y','N','Y',to_date('06-JUN-08','DD-MON-RR'),'sdowdy',1,'08CBADA0A1B78F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('1','Invoice Instructions','N','N','N',to_date('06-JUN-08','DD-MON-RR'),'rhanlon',1,'08CBADA0A1B88F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('10','Special Review Comments','N','N','N',to_date('19-JAN-96','DD-MON-RR'),'sdowdy',1,'08CBADA0A1B98F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('7','Special Rate ','N','N','N',to_date('06-SEP-95','DD-MON-RR'),'ospa',1,'08CBADA0A1BA8F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('8','Indirect Cost Comments','N','N','N',to_date('20-SEP-95','DD-MON-RR'),'ospa',1,'08CBADA0A1BB8F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('5','Procurement Comments','Y','N','Y',to_date('20-SEP-95','DD-MON-RR'),'pgreer',1,'08CBADA0A1BC8F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('12','Proposal Summary','N','N','N',to_date('19-JAN-96','DD-MON-RR'),'sdowdy',1,'08CBADA0A1BD8F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('6','Property Comments','Y','N','Y',to_date('20-SEP-95','DD-MON-RR'),'pgreer',1,'08CBADA0A1BE8F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('13','Proposal Comments','N','N','N',to_date('19-JAN-96','DD-MON-RR'),'sdowdy',1,'08CBADA0A1BF8F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('16','Proposal IP Review Comment','N','N','N',to_date('08-APR-00','DD-MON-RR'),'OSPA',1,'08CBADA0A1C08F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('17','Proposal IP Reviewer Comment','N','N','N',to_date('08-APR-00','DD-MON-RR'),'OSPA',1,'08CBADA0A1C18F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('19','ARRA Quarterly Activities','N','Y','Y',to_date('16-SEP-09','DD-MON-RR'),'sdowdy',1,'08CBADA0A1C28F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('18','ARRA Award Description','N','Y','Y',to_date('08-SEP-09','DD-MON-RR'),'sdowdy',1,'08CBADA0A1C38F37E0531C3C03122513');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('CG1','Stop Work Reason','N','N','N',to_date('14-JAN-15','DD-MON-RR'),'admin',1,'0CA64690497974BDE0534F3C0312E0AA');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('CG2','Additional Forms Description','N','N','N',to_date('14-JAN-15','DD-MON-RR'),'admin',1,'0CA64690497A74BDE0534F3C0312E0AA');
Insert into COMMENT_TYPE (COMMENT_TYPE_CODE,DESCRIPTION,TEMPLATE_FLAG,CHECKLIST_FLAG,AWARD_COMMENT_SCREEN_FLAG,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID) values ('CG3','Reason for Excluding from Invoicing','N','N','N',to_date('14-JAN-15','DD-MON-RR'),'admin',1,'0CA64690497B74BDE0534F3C0312E0AA');
commit
/
ALTER TABLE AWARD_COMMENT ENABLE CONSTRAINT FK_AWARD_COMMENT_COMMENT_TYPE
/
ALTER TABLE AWARD_TEMPLATE_COMMENTS ENABLE CONSTRAINT FK_AWARD_TEMPLATE_COMMENT_CODE
/
ALTER TABLE PROPOSAL_COMMENTS ENABLE CONSTRAINT FK_PROPOSAL_COMMENTS_CODE
/
