INSERT INTO WL_ABSENTEE(ABSENTEE_ID,PERSON_ID,LEAVE_START_DATE,LEAVE_END_DATE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT 	SEQ_ABSENTEE_ID.NEXTVAL,PERSON_ID,LEAVE_START_DATE,LEAVE_END_DATE,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$ABSENTEE@coeus.kuali
/
INSERT INTO WL_CAPACITY(WLCAPACITY_ID,PERSON_ID,CAPACITY,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT 	SEQ_WL_CAPACITY_ID.NEXTVAL,PERSON_ID,CAPACITY,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$CAPACITY@coeus.kuali
/
INSERT INTO WL_ASSIGNED_BY(	ASSIGNED_BY_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT ASSIGNED_BY_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$ASSIGNED_BY@coeus.kuali
/
INSERT INTO WL_CURRENT_LOAD(LOAD_ID,ROUTING_NUMBER,PROPOSAL_NUMBER,ORIG_APPROVER,ORIG_USER_ID,PERSON_ID,USER_ID,SPONSOR_CODE,SPONSOR_GROUP,COMPLEXITY,LEAD_UNIT,ACTIVE_FLAG,ARRIVAL_DATE,INACTIVE_DATE,REROUTED_FLAG,ASSIGNED_BY,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID,LAST_APPROVER)
SELECT	SEQ_WL_CURRENT_LOAD_ID.NEXTVAL,ROUTING_NUMBER,PROPOSAL_NUMBER,ORIG_APPROVER,ORIG_USER_ID,PERSON_ID,USER_ID,SPONSOR_CODE,SPONSOR_GROUP,COMPLEXITY,LEAD_UNIT,ACTIVE_FLAG,ARRIVAL_DATE,INACTIVE_DATE,REROUTED_FLAG,ASSIGNED_BY,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID(),LAST_APPROVER FROM WL$CURRENT_LOAD@coeus.kuali
/
INSERT INTO WL_FLEXIBILITY(FLEXIBILITY_ID,PERSON_ID,SPONSOR_GROUP,FLEXIBILITY,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT 	SEQ_WL_FLEXIBILITY_ID.NEXTVAl,PERSON_ID,SPONSOR_GROUP,FLEXIBILITY,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$FLEXIBILITY@coeus.kuali
/
INSERT INTO WL_LOAD_SIMULATION(	SIM_ID,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SIM_ID,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$LOAD_SIMULATION@coeus.kuali
/
INSERT INTO WL_OPTIMIZATION_DATA(OPTIMIZATION_ID,PERSON_ID,SPONSOR_GROUP,UPDATE_USER,UPDATE_TIMESTAMP,VER_NBR,OBJ_ID)
SELECT SEQ_WL_OPTIMIZATION_ID.NEXTVAL,PERSON_ID,SPONSOR_GROUP,UPDATE_USER,UPDATE_TIMESTAMP,1,SYS_GUID() FROM WL$OPTIMIZATION_DATA@coeus.kuali
/
INSERT INTO WL_PROP_AGGREGATOR_COMPLEXITY(COMPLEXITY_ID,AGGREGATOR_USER_ID,AGGREGATOR_PERSON_ID,AVERAGE_ERROR_COUNT,COMPLEXITY,PROPOSAL_COUNT,VER_NBR,OBJ_ID)
SELECT SEQ_WL_COMPLEXITY_ID.NEXTVAL,AGGREGATOR_USER_ID,AGGREGATOR_PERSON_ID,AVERAGE_ERROR_COUNT,COMPLEXITY,PROPOSAL_COUNT,1,SYS_GUID() FROM WL$PROP_AGGREGATOR_COMPLEXITY@coeus.kuali
/
INSERT INTO WL_PROP_AGGREGATOR_ERR_COUNT(COUNT_ID,PROPOSAL_NUMBER,ROUTING_NUMBER,AGGREGATOR_USER_ID,AGGREGATOR_PERSON_ID,ROUTING_START_DATE,NUM_OF_ERRORS,VER_NBR,OBJ_ID)
SELECT SEQ_WL_AGGREG_COUNT_ID.NEXTVAL,PROPOSAL_NUMBER,ROUTING_NUMBER,AGGREGATOR_USER_ID,AGGREGATOR_PERSON_ID,ROUTING_START_DATE,NUM_OF_ERRORS,1,SYS_GUID() FROM WL$PROP_AGGREGATOR_ERR_COUNT@coeus.kuali
/
INSERT INTO WL_PROP_CANNED_REVIEW_COMMENTS(CANNED_REVIEW_COMMENT_CODE,DESCRIPTION,SPONSOR_GROUP,SPONSOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)	
SELECT CANNED_REVIEW_COMMENT_CODE,DESCRIPTION,SPONSOR_GROUP,SPONSOR_TYPE_CODE,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$PROP_CANNED_REVIEW_COMMENTS@coeus.kuali
/
INSERT INTO WL_PROP_REV_COMM_LAST_YEAR(REV_COMM_ID,PROPOSAL_NUMBER,INST_PROPOSAL_NUMBER,DEV_PROPOSAL_NUMBER,CA_ID,CA_NAME,AL_ID,AL_NAME,CR_ID,CR_NAME,CANNED_REVIEW_COMMENT_CODE,
DESCRIPTION,SPONSOR_GROUP,SPONSOR_TYPE_CODE,CA_FLAG,AL_FLAG,CR_FLAG,AGGREGATOR_ID,AGGREGATOR_NAME,SPONSOR_CODE,DL_ID,DL_NAME,ROUTING_START_DATE,VER_NBR,OBJ_ID)
SELECT SEQ_WL_REV_COMM_ID.NEXTVAL,PROPOSAL_NUMBER,INST_PROPOSAL_NUMBER,to_number(DEV_PROPOSAL_NUMBER),CA_ID,CA_NAME,AL_ID,AL_NAME,CR_ID,CR_NAME,CANNED_REVIEW_COMMENT_CODE,
DESCRIPTION,SPONSOR_GROUP,SPONSOR_TYPE_CODE,CA_FLAG,AL_FLAG,CR_FLAG,AGGREGATOR_ID,AGGREGATOR_NAME,SPONSOR_CODE,DL_ID,DL_NAME,ROUTING_START_DATE,1,SYS_GUID() FROM  WL$PROP_REV_COMM_LAST_YEAR@coeus.kuali  
/
INSERT INTO WL_PROP_REVIEW_ACTION(REVIEW_ACTION_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT REVIEW_ACTION_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM  WL$PROP_REVIEW_ACTION@coeus.kuali
/
INSERT INTO WL_PROP_REVIEW_COMMENTS(PROP_REV_COMM_ID,PROPOSAL_NUMBER,REVIEW_NUMBER,PERSON_ID,COMMENT_NUMBER,CANNED_REVIEW_COMMENT_CODE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,MENTOR_PERSON_ID,VER_NBR,OBJ_ID)
SELECT SEQ_WL_PROP_REV_COMM_ID.NEXTVAL,PROPOSAL_NUMBER,REVIEW_NUMBER,PERSON_ID,COMMENT_NUMBER,CANNED_REVIEW_COMMENT_CODE,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,MENTOR_PERSON_ID,1,SYS_GUID() FROM WL$PROP_REVIEW_COMMENTS@coeus.kuali
/
INSERT INTO WL_PROP_REVIEW_ROLE(REVIEW_ROLE_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT REVIEW_ROLE_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$PROP_REVIEW_ROLE@coeus.kuali
/
INSERT INTO WL_PROP_REVIEW_TIME_SPENT(REVIEW_TIME_SPENT_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT 	REVIEW_TIME_SPENT_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$PROP_REVIEW_TIME_SPENT@coeus.kuali
/
INSERT INTO WL_REVIEW_ASSIGNMENTS(REV_ASSIGNMENT_ID,ROUTING_NUMBER,PROPOSAL_NUMBER,SPONSOR_CODE,ORIG_APPROVER,NEW_APPROVER,ASSIGNED_BY,ASSIGNED_TIMESTAMP,IS_FIRST_MAP,IS_FIRST_ROUTNIG,VER_NBR,OBJ_ID)
SELECT SEQ_WL_REV_ASSIGNMENT_ID.NEXTVAL,ROUTING_NUMBER,PROPOSAL_NUMBER,SPONSOR_CODE,ORIG_APPROVER,NEW_APPROVER,ASSIGNED_BY,ASSIGNED_TIMESTAMP,IS_FIRST_MAP,IS_FIRST_ROUTNIG,1,SYS_GUID() FROM WL$REVIEW_ASSIGNMENTS@coeus.kuali
/
INSERT INTO WL_SUBMISSION_VEHICLE(SUBMISSION_VEHICLE_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SUBMISSION_VEHICLE_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$SUBMISSION_VEHICLE@coeus.kuali
/
INSERT INTO WL_PROP_REVIEW_DETAILS(PROP_REV_DET_ID,PROPOSAL_NUMBER,REVIEW_NUMBER,PERSON_ID,ROUTING_NUMBER,REVIEW_ACTION_CODE,REVIEW_ROLE_CODE,REVIEW_TIME_SPENT_CODE,TIME_SPENT_ASSIS_DLC_CODE,SUBMISSION_VEHICLE_CODE,REVIEWED_DEAN_OFFICE_FLAG,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_WL_PROP_REV_DET_ID.NEXTVAL,PROPOSAL_NUMBER,REVIEW_NUMBER,PERSON_ID,ROUTING_NUMBER,REVIEW_ACTION_CODE,REVIEW_ROLE_CODE,REVIEW_TIME_SPENT_CODE,TIME_SPENT_ASSIS_DLC_CODE,SUBMISSION_VEHICLE_CODE,REVIEWED_DEAN_OFFICE_FLAG,COMMENTS,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$PROP_REVIEW_DETAILS@coeus.kuali
/
INSERT INTO WL_SIM_CAPACITY(SIM_CAPACITY_ID,SIM_ID,PERSON_ID,CAPACITY,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_SIM_CAPACITY_ID.NEXTVAL,SIM_ID,PERSON_ID,CAPACITY,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM  WL$SIM_CAPACITY@coeus.kuali
/
INSERT INTO WL_SIM_CURRENT_LOAD(SIM_CURRENT_LOAD_ID,SIM_ID,ROUTING_NUMBER,PROPOSAL_NUMBER,POC_PERSON_ID,POC_USER_ID,APPROVER_USER_ID,APPROVER_PERSON_ID,SIM_PERSON_ID,SIM_USER_ID,SPONSOR_CODE,SPONSOR_GROUP,COMPLEXITY,LEAD_UNIT,ACTIVE_FLAG,ARRIVAL_DATE,INACTIVE_DATE,REROUTED_FLAG,ASSIGNED_BY,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT 	SEQ_SIM_CURRENT_LOAD_ID.NEXTVAL,SIM_ID,ROUTING_NUMBER,PROPOSAL_NUMBER,POC_PERSON_ID,POC_USER_ID,APPROVER_USER_ID,APPROVER_PERSON_ID,SIM_PERSON_ID,SIM_USER_ID,SPONSOR_CODE,SPONSOR_GROUP,COMPLEXITY,LEAD_UNIT,ACTIVE_FLAG,ARRIVAL_DATE,INACTIVE_DATE,REROUTED_FLAG,ASSIGNED_BY,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$SIM_CURRENT_LOAD@coeus.kuali
/
INSERT INTO WL_SIM_FLEXIBILITY(SIM_FLEXIBILITY_ID,SIM_ID,PERSON_ID,SPONSOR_GROUP,FLEXIBILITY,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SEQ_SIM_FLEXIBILITY_ID.NEXTVAL,SIM_ID,PERSON_ID,SPONSOR_GROUP,FLEXIBILITY,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$SIM_FLEXIBILITY@coeus.kuali
/
INSERT INTO WL_SIM_HEADER(SIM_ID,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,SIM_START_DATE,SIM_END_DATE,SIM_RUN_STATUS_CODE,VER_NBR,OBJ_ID)
SELECT 	SEQ_SIM_ID.NEXTVAL,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,SIM_START_DATE,SIM_END_DATE,SIM_RUN_STATUS_CODE,1,SYS_GUID() FROM WL$SIM_HEADER@coeus.kuali
/
INSERT INTO WL_SIM_RUN_STATUS(SIM_RUN_STATUS_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SIM_RUN_STATUS_CODE,DESCRIPTION,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM WL$SIM_RUN_STATUS@coeus.kuali
/
INSERT INTO WL_SIM_UNIT_ASSIGNMENTS(SIM_UNIT_ASSIGNMENTS_ID,SIM_ID,PERSON_ID,UNIT_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,VER_NBR,OBJ_ID)
SELECT SIM_UNIT_ASSIGNMENTS_ID.NEXTVAL,SIM_ID,PERSON_ID,UNIT_NUMBER,UPDATE_TIMESTAMP,UPDATE_USER,1,SYS_GUID() FROM	WL$SIM_UNIT_ASSIGNMENTS@coeus.kuali
/
INSERT INTO WL_UNIT_ASSIGNMENTS(UNIT_ASSIGN_ID,PERSON_ID,UNIT_NUMBER,UPDATE_USER,UPDATE_TIMESTAMP,VER_NBR,OBJ_ID)
SELECT 	SEQ_WL_UNIT_ASSIGN_ID.NEXTVAL,PERSON_ID,UNIT_NUMBER,UPDATE_USER,UPDATE_TIMESTAMP,1,SYS_GUID() FROM WL$UNIT_ASSIGNMENTS@coeus.kuali
/
commit
/