SET DEFINE OFF
/
drop table TEMP_LOOKUP_RTE_NODE_LNK
/
drop table TEMP_LOOKUP_RTE_NODE
/
drop table TEMP_LOOKUP_CFG_PARM
/
drop table TEMP_INSERT_NODE
/
CREATE TABLE TEMP_LOOKUP_RTE_NODE 
   (	DOC_TYP_NM VARCHAR2(64), 
	NM VARCHAR2(255), 
	TYP VARCHAR2(255), 
	PROTO_BRCH_NM VARCHAR2(255), 
	RTE_MTHD_NM VARCHAR2(255), 
	RTE_MTHD_CD VARCHAR2(2),
	ACTVN_TYP	VARCHAR2(1),
	SORT_ID     NUMBER(3),
	GENERATE_BRCH_PROTO VARCHAR2(1)
)
/
CREATE TABLE TEMP_LOOKUP_RTE_NODE_LNK(
DOC_TYP_NM	VARCHAR2(64),
FROM_NM VARCHAR2(255),
TO_NM VARCHAR2(255)
)
/
CREATE TABLE TEMP_LOOKUP_CFG_PARM(
DOC_TYP_NM	VARCHAR2(64),
NM	VARCHAR2(255),
KEY_CD	VARCHAR2(255),
VAL	VARCHAR2(4000)
)
/
CREATE TABLE TEMP_INSERT_NODE( 
RTE_NODE_ID	VARCHAR2(40),
DOC_HDR_ID	VARCHAR2(40),
NM VARCHAR2(255), 
TYP VARCHAR2(255), 
PROTO_BRCH_NM VARCHAR2(255), 
RTE_MTHD_NM VARCHAR2(255), 
RTE_MTHD_CD VARCHAR2(2),
ACTVN_TYP	VARCHAR2(1)
)
/
declare
li_count number;
begin
  select count(DOC_TYP_NM) into li_count from TEMP_LOOKUP_CFG_PARM;
  if li_count = 0 then
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','Initiated','contentFragment ','<start name="Initiated">
            <activationType>P</activationType>
            <mandatoryRoute>false</mandatoryRoute>
            <finalApproval>false</finalApproval>
            </start>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','Initiated','activationType','P');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','UnitRouting','activationType','P');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','Initiated','mandatoryRoute','false');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','Initiated','finalApproval','false');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','Initiated','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','isHierarchyChild','contentFragment','<split name="isHierarchyChild">
            <type>org.kuali.coeus.sys.framework.workflow.SimpleBooleanSplitNode</type>
            </split>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','isHierarchyChild','type','org.kuali.coeus.sys.framework.workflow.SimpleBooleanSplitNode');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','isHierarchyChild','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPInitial','contentFragment','<role name="OSPInitial">
            <qualifierResolverClass>org.kuali.rice.kew.role.NullQualifierResolver</qualifierResolverClass>
            <activationType>S</activationType>
            <finalApproval>false</finalApproval>
            </role>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPInitial','qualifierResolverClass','org.kuali.rice.kew.role.NullQualifierResolver');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPInitial','activationType','S');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPInitial','finalApproval','false');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPInitial','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','ProposalPersons','contentFragment','<role name="ProposalPersons">
            <qualifierResolver>ProposalPersons-XPathQualifierResolver</qualifierResolver>
            <activationType>P</activationType>
            <finalApproval>false</finalApproval>
            </role>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','ProposalPersons','qualifierResolver','ProposalPersons-XPathQualifierResolver');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','ProposalPersons','activationType','P');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','ProposalPersons','finalApproval','false');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','ProposalPersons','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','PeopleFlows','contentFragment','<requests name="PeopleFlows">
            <activationType>R</activationType>
            <rulesEngine executorClass="org.kuali.coeus.propdev.impl.core.ProposalDevelopmentRulesEngineExecutorImpl"/>
            </requests>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','PeopleFlows','activationType','R');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','PeopleFlows','rulesEngine',null);
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','PeopleFlows','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','UnitRouting','contentFragment','<requests name="UnitRouting">
            <qualifierResolver>DepartmentRouting-XPathQualifierResolver</qualifierResolver>
            <!--  <qualifierResolverClass>org.kuali.rice.kew.role.NullQualifierResolver</qualifierResolverClass> -->
            <ruleTemplate>CustomApproval</ruleTemplate>
            <activationType>P</activationType>
            <finalApproval>false</finalApproval>
            </requests>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','UnitRouting','qualifierResolver','DepartmentRouting-XPathQualifierResolver');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','UnitRouting','ruleTemplate','CustomApproval');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','UnitRouting','finalApproval','false');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','UnitRouting','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','DepartmentalRouting','contentFragment','<requests name="DepartmentalRouting">
            <qualifierResolver>DepartmentRouting-XPathQualifierResolver</qualifierResolver>
            <!--  <qualifierResolverClass>org.kuali.rice.kew.role.NullQualifierResolver</qualifierResolverClass> -->
            <ruleTemplate>DepartmentalApproval</ruleTemplate>
            <activationType>P</activationType>
            <finalApproval>false</finalApproval>
            </requests>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','DepartmentalRouting','qualifierResolver','DepartmentRouting-XPathQualifierResolver');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','DepartmentalRouting','ruleTemplate','DepartmentalApproval');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','DepartmentalRouting','finalApproval','false');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','DepartmentalRouting','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPOfficeRouting','contentFragment','<role name="OSPOfficeRouting">
            <qualifierResolverClass>org.kuali.rice.kew.role.NullQualifierResolver</qualifierResolverClass>
            <activationType>S</activationType>
            <finalApproval>false</finalApproval>
            </role>
            ');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPOfficeRouting','qualifierResolver','org.kuali.rice.kew.role.NullQualifierResolver');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPOfficeRouting','activationType','S');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPOfficeRouting','finalApproval','false');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','OSPOfficeRouting','ruleSelector','Template');
            Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','contentFragment','<requests name="WaitForHierarchyDisposition">
            <activationType>S</activationType>
            <ruleTemplate>HierarchyParentDispositionApproval</ruleTemplate>
            <mandatoryRoute>true</mandatoryRoute>
            <ignorePrevious>true</ignorePrevious>
            <finalApproval>false</finalApproval>
            </requests>
            ');
    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','activationType','S');
    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','ruleTemplate','HierarchyParentDispositionApproval');
    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','mandatoryRoute','true');
    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','ignorePrevious','true');
    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','finalApproval','false');
    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','ruleSelector','Template');

    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','Join','contentFragment','false');
    Insert into TEMP_LOOKUP_CFG_PARM (DOC_TYP_NM,NM,KEY_CD,VAL) values ('ProposalDevelopmentDocument','Join','ruleSelector','Template');
  end if;

  select count(DOC_TYP_NM) into li_count from TEMP_LOOKUP_RTE_NODE;
  if li_count = 0 then

        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','Initiated','org.kuali.rice.kew.engine.node.InitialNode','null',null,null,'P',1);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','isHierarchyChild','org.kuali.coeus.sys.framework.workflow.SimpleBooleanSplitNode','null',null,null,'S',2);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID,GENERATE_BRCH_PROTO) values ('ProposalDevelopmentDocument','OSPInitial','org.kuali.rice.kew.engine.node.RoleNode','false','org.kuali.rice.kew.role.RoleRouteModule','RM','S',3,'Y');
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','ProposalPersons','org.kuali.rice.kew.engine.node.RoleNode','false','org.kuali.rice.kew.role.RoleRouteModule','RM','P',4);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','PeopleFlows','org.kuali.rice.kew.engine.node.RequestsNode','false',null,'RE','R',5);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','UnitRouting','org.kuali.rice.kew.engine.node.RequestsNode','false','CustomApproval','FR','P',6);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','DepartmentalRouting','org.kuali.rice.kew.engine.node.RequestsNode','false','DepartmentalApproval','FR','P',7);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','OSPOfficeRouting','org.kuali.rice.kew.engine.node.RoleNode','false','org.kuali.rice.kew.role.RoleRouteModule','RM','S',8);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID) values ('ProposalDevelopmentDocument','Join','org.kuali.rice.kew.engine.node.SimpleJoinNode','false',null,null,'S',9);
        Insert into TEMP_LOOKUP_RTE_NODE (DOC_TYP_NM,NM,TYP,PROTO_BRCH_NM,RTE_MTHD_NM,RTE_MTHD_CD,ACTVN_TYP,SORT_ID,GENERATE_BRCH_PROTO) values ('ProposalDevelopmentDocument','WaitForHierarchyDisposition','org.kuali.rice.kew.engine.node.RequestsNode','true','HierarchyParentDispositionApproval','FR','S',10,'Y');
  end if;
  
  select count(DOC_TYP_NM) into li_count from TEMP_LOOKUP_RTE_NODE_LNK;
  if li_count = 0 then  
	Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','Initiated','OSPInitial');
    Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','OSPInitial','PeopleFlows');
    Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','PeopleFlows','OSPOfficeRouting');
 	
 --    Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','Initiated','OSPInitial');
 --    Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','ProposalPersons','PeopleFlows');
  
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','Initiated','isHierarchyChild');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','isHierarchyChild','OSPInitial');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','OSPInitial','ProposalPersons');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','ProposalPersons','PeopleFlows');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','PeopleFlows','UnitRouting');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','UnitRouting','DepartmentalRouting');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','isHierarchyChild','WaitForHierarchyDisposition');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','isHierarchyChild','Join');
--      Insert into TEMP_LOOKUP_RTE_NODE_LNK (DOC_TYP_NM,FROM_NM,TO_NM) values ('ProposalDevelopmentDocument','OSPOfficeRouting','Join');
 end if;

commit;
UPDATE TEMP_LOOKUP_RTE_NODE
SET DOC_TYP_NM=trim(DOC_TYP_NM),
NM=trim(NM),
TYP=trim(TYP),
PROTO_BRCH_NM=trim(PROTO_BRCH_NM),
RTE_MTHD_NM=trim(RTE_MTHD_NM),
RTE_MTHD_CD=trim(RTE_MTHD_CD);

UPDATE TEMP_LOOKUP_RTE_NODE_LNK
SET DOC_TYP_NM=trim(DOC_TYP_NM),
FROM_NM=trim(FROM_NM),
TO_NM=trim(TO_NM);

UPDATE TEMP_LOOKUP_CFG_PARM
SET DOC_TYP_NM=trim(DOC_TYP_NM),
NM=trim(NM),
KEY_CD=trim(KEY_CD),
VAL=trim(VAL);
commit;
end;
/
drop table OSP$EPS_PROPOSAL
/
CREATE TABLE OSP$EPS_PROPOSAL
(	"PROPOSAL_NUMBER" VARCHAR2(8) NOT NULL ENABLE, 
"PROPOSAL_TYPE_CODE" NUMBER(3,0) NOT NULL ENABLE, 
"STATUS_CODE" NUMBER(3,0) NOT NULL ENABLE, 
"CREATION_STATUS_CODE" NUMBER(3,0) NOT NULL ENABLE, 
"BASE_PROPOSAL_NUMBER" VARCHAR2(8), 
"CONTINUED_FROM" VARCHAR2(8), 
"TEMPLATE_FLAG" CHAR(1 BYTE) NOT NULL ENABLE, 
"ORGANIZATION_ID" VARCHAR2(8), 
"PERFORMING_ORGANIZATION_ID" VARCHAR2(8), 
"CURRENT_ACCOUNT_NUMBER" VARCHAR2(100), 
"CURRENT_AWARD_NUMBER" CHAR(10), 
"TITLE" VARCHAR2(200), 
"SPONSOR_CODE" CHAR(6), 
"SPONSOR_PROPOSAL_NUMBER" VARCHAR2(70), 
"INTR_COOP_ACTIVITIES_FLAG" CHAR(1), 
"INTR_COUNTRY_LIST" VARCHAR2(150), 
"OTHER_AGENCY_FLAG" CHAR(1), 
"NOTICE_OF_OPPORTUNITY_CODE" NUMBER(3,0), 
"PROGRAM_ANNOUNCEMENT_NUMBER" VARCHAR2(50), 
"PROGRAM_ANNOUNCEMENT_TITLE" VARCHAR2(255), 
"ACTIVITY_TYPE_CODE" NUMBER(3,0) NOT NULL ENABLE, 
"REQUESTED_START_DATE_INITIAL" DATE, 
"REQUESTED_START_DATE_TOTAL" DATE, 
"REQUESTED_END_DATE_INITIAL" DATE, 
"REQUESTED_END_DATE_TOTAL" DATE, 
"DURATION_MONTHS" NUMBER(3,0), 
"NUMBER_OF_COPIES" VARCHAR2(7), 
"DEADLINE_DATE" DATE, 
"DEADLINE_TYPE" CHAR(1), 
"MAILING_ADDRESS_ID" NUMBER(6,0), 
"MAIL_BY" CHAR(1), 
"MAIL_TYPE" VARCHAR2(3), 
"CARRIER_CODE_TYPE" VARCHAR2(3), 
"CARRIER_CODE" VARCHAR2(20), 
"MAIL_DESCRIPTION" VARCHAR2(80), 
"MAIL_ACCOUNT_NUMBER" VARCHAR2(100), 
"SUBCONTRACT_FLAG" CHAR(1) NOT NULL ENABLE, 
"NARRATIVE_STATUS" CHAR(1), 
"BUDGET_STATUS" CHAR(1), 
"OWNED_BY_UNIT" VARCHAR2(8) NOT NULL ENABLE, 
"CREATE_TIMESTAMP" DATE NOT NULL ENABLE, 
"CREATE_USER" VARCHAR2(8) NOT NULL ENABLE, 
"UPDATE_TIMESTAMP" DATE NOT NULL ENABLE, 
"UPDATE_USER" VARCHAR2(8) NOT NULL ENABLE, 
"NSF_CODE" VARCHAR2(15), 
"PRIME_SPONSOR_CODE" CHAR(6), 
"CFDA_NUMBER" VARCHAR2(6), 
"AGENCY_PROGRAM_CODE" VARCHAR2(50), 
"AGENCY_DIVISION_CODE" VARCHAR2(50), 
"AWARD_TYPE_CODE" NUMBER(3,0));
commit;
insert into OSP$EPS_PROPOSAL(PROPOSAL_NUMBER,PROPOSAL_TYPE_CODE,STATUS_CODE,CREATION_STATUS_CODE,BASE_PROPOSAL_NUMBER,CONTINUED_FROM,TEMPLATE_FLAG,ORGANIZATION_ID,
PERFORMING_ORGANIZATION_ID,CURRENT_ACCOUNT_NUMBER,CURRENT_AWARD_NUMBER,TITLE,SPONSOR_CODE,SPONSOR_PROPOSAL_NUMBER,INTR_COOP_ACTIVITIES_FLAG,INTR_COUNTRY_LIST,
OTHER_AGENCY_FLAG,NOTICE_OF_OPPORTUNITY_CODE,PROGRAM_ANNOUNCEMENT_NUMBER,PROGRAM_ANNOUNCEMENT_TITLE,ACTIVITY_TYPE_CODE,REQUESTED_START_DATE_INITIAL,REQUESTED_START_DATE_TOTAL,
REQUESTED_END_DATE_INITIAL,REQUESTED_END_DATE_TOTAL,DURATION_MONTHS,NUMBER_OF_COPIES,DEADLINE_DATE,DEADLINE_TYPE,MAILING_ADDRESS_ID,MAIL_BY,MAIL_TYPE,CARRIER_CODE_TYPE,CARRIER_CODE,
MAIL_DESCRIPTION,MAIL_ACCOUNT_NUMBER,SUBCONTRACT_FLAG,NARRATIVE_STATUS,BUDGET_STATUS,OWNED_BY_UNIT,CREATE_TIMESTAMP,CREATE_USER,UPDATE_TIMESTAMP,UPDATE_USER,NSF_CODE,PRIME_SPONSOR_CODE,
CFDA_NUMBER,AGENCY_PROGRAM_CODE,AGENCY_DIVISION_CODE,AWARD_TYPE_CODE)
SELECT PROPOSAL_NUMBER,PROPOSAL_TYPE_CODE,STATUS_CODE,CREATION_STATUS_CODE,BASE_PROPOSAL_NUMBER,CONTINUED_FROM,TEMPLATE_FLAG,ORGANIZATION_ID,
PERFORMING_ORGANIZATION_ID,CURRENT_ACCOUNT_NUMBER,CURRENT_AWARD_NUMBER,TITLE,SPONSOR_CODE,SPONSOR_PROPOSAL_NUMBER,INTR_COOP_ACTIVITIES_FLAG,INTR_COUNTRY_LIST,
OTHER_AGENCY_FLAG,NOTICE_OF_OPPORTUNITY_CODE,PROGRAM_ANNOUNCEMENT_NUMBER,PROGRAM_ANNOUNCEMENT_TITLE,ACTIVITY_TYPE_CODE,REQUESTED_START_DATE_INITIAL,REQUESTED_START_DATE_TOTAL,
REQUESTED_END_DATE_INITIAL,REQUESTED_END_DATE_TOTAL,DURATION_MONTHS,NUMBER_OF_COPIES,DEADLINE_DATE,DEADLINE_TYPE,MAILING_ADDRESS_ID,MAIL_BY,MAIL_TYPE,CARRIER_CODE_TYPE,CARRIER_CODE,
MAIL_DESCRIPTION,MAIL_ACCOUNT_NUMBER,SUBCONTRACT_FLAG,NARRATIVE_STATUS,BUDGET_STATUS,OWNED_BY_UNIT,CREATE_TIMESTAMP,CREATE_USER,UPDATE_TIMESTAMP,UPDATE_USER,NSF_CODE,PRIME_SPONSOR_CODE,
CFDA_NUMBER,AGENCY_PROGRAM_CODE,AGENCY_DIVISION_CODE,AWARD_TYPE_CODE FROM OSP$EPS_PROPOSAL@coeus.kuali
/
commit
/
create index OSP$EPS_PROPOSAL_IX on OSP$EPS_PROPOSAL(PROPOSAL_NUMBER)
/
create index TEMP_INSERT_NODE_I1  on TEMP_INSERT_NODE(DOC_HDR_ID)
/
----------------------
DELETE FROM KREW_RTE_BRCH_T WHERE RTE_BRCH_ID IN(SELECT k.BRCH_ID FROM KREW_RTE_NODE_INSTN_T k inner join EPS_PROPOSAL e on k.DOC_HDR_ID=e.DOCUMENT_NUMBER inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number));
DELETE FROM KREW_RTE_BRCH_PROTO_T where RTE_BRCH_PROTO_ID in (select BRCH_PROTO_ID FROM KREW_RTE_NODE_T WHERE  RTE_NODE_ID IN (SELECT k.RTE_NODE_ID FROM TEMP_INSERT_NODE k inner join EPS_PROPOSAL e on k.DOC_HDR_ID=e.DOCUMENT_NUMBER inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number))
);
DELETE FROM  KREW_RTE_NODE_LNK_T where from_rte_node_id in ((SELECT k.RTE_NODE_ID FROM TEMP_INSERT_NODE k inner join EPS_PROPOSAL e on k.DOC_HDR_ID=e.DOCUMENT_NUMBER inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number))
);
DELETE FROM  KREW_RTE_NODE_CFG_PARM_T where rte_node_id in ((SELECT k.RTE_NODE_ID FROM TEMP_INSERT_NODE k inner join EPS_PROPOSAL e on k.DOC_HDR_ID=e.DOCUMENT_NUMBER inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number))
);
DELETE FROM KREW_RTE_NODE_T WHERE  RTE_NODE_ID IN (SELECT k.RTE_NODE_ID FROM TEMP_INSERT_NODE k inner join EPS_PROPOSAL e on k.DOC_HDR_ID=e.DOCUMENT_NUMBER inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number));
DELETE FROM KREW_ACTN_RQST_T WHERE DOC_HDR_ID IN (SELECT e.DOCUMENT_NUMBER FROM EPS_PROPOSAL e inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number));
DELETE FROM KREW_RTE_NODE_INSTN_T WHERE DOC_HDR_ID IN(SELECT e.DOCUMENT_NUMBER FROM EPS_PROPOSAL e inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number)); 
DELETE FROM KREW_INIT_RTE_NODE_INSTN_T WHERE DOC_HDR_ID IN(SELECT e.DOCUMENT_NUMBER FROM EPS_PROPOSAL e inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number));
DELETE FROM KREW_ACTN_TKN_T WHERE DOC_HDR_ID IN(SELECT e.DOCUMENT_NUMBER FROM EPS_PROPOSAL e inner join OSP$EPS_PROPOSAL ep on e.proposal_number=to_number(ep.proposal_number));
commit
/
truncate table TEMP_INSERT_NODE
/
declare
	li_doc_typ_id VARCHAR2(40);
	ls_doc_typ_nm VARCHAR2(64) := 'ProposalDevelopmentDocument';
	li_krew_rnt_node NUMBER(19,0);
	li_krew_rnt_brch NUMBER(19,0);
	li_krew_rne_node_instn NUMBER(19,0);
	li_krew_actn_rqst NUMBER(19,0);
	li_krew_actn_tkn NUMBER(19,0);
	li_krew_rte_brch_proto_true NUMBER(19,0);
	li_krew_rte_brch_proto_false NUMBER(19,0);
	ls_doc_nbr VARCHAR2(40);
	
	li_krew_rnt_node_active number;
	li_krew_rnt_node_complt number;
	ls_initr_prncpl_id VARCHAR2(40);
	
	cursor c_data is
	select t1.document_number, t1.CREATE_USER from 
  eps_proposal t1 inner join osp$eps_proposal t2 on t1.proposal_number = to_number(t2.proposal_number);
--   where t1.proposal_number in (select min(to_number(proposal_number)) from osp$eps_proposal) ; -- added for testing

	r_data c_data%rowtype;

	
	cursor c_temp is
	select * from TEMP_LOOKUP_RTE_NODE where DOC_TYP_NM = ls_doc_typ_nm order by sort_id;
	r_temp c_temp%rowtype;
	
begin  

	select max(to_number(DOC_TYP_ID)) into li_doc_typ_id from KREW_DOC_TYP_T where DOC_TYP_NM = ls_doc_typ_nm;

open c_data;
loop
fetch c_data into r_data;
exit when c_data%notfound;

		ls_doc_nbr := r_data.document_number;
				
		begin
		select PRNCPL_ID into ls_initr_prncpl_id from  KRIM_PRNCPL_T where LOWER(PRNCPL_NM) = LOWER(r_data.CREATE_USER);
		exception when others then
			ls_initr_prncpl_id:='unknownuser';
		end;  
				
			
		
		select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_brch from dual ;			
		select KREW_ACTN_RQST_S.NEXTVAL into li_krew_actn_rqst from dual ;
		select KREW_ACTN_TKN_S.NEXTVAL into li_krew_actn_tkn from dual ;
		
		INSERT INTO KREW_RTE_BRCH_T(RTE_BRCH_ID,NM,PARNT_ID,INIT_RTE_NODE_INSTN_ID,SPLT_RTE_NODE_INSTN_ID,JOIN_RTE_NODE_INSTN_ID,VER_NBR)
		VALUES(li_krew_rnt_brch,'PRIMARY',NULL,NULL,NULL,NULL,1);		
		
		INSERT INTO KREW_ACTN_TKN_T(ACTN_TKN_ID,DOC_HDR_ID,PRNCPL_ID,DLGTR_PRNCPL_ID,ACTN_CD,ACTN_DT,DOC_VER_NBR,ANNOTN,CUR_IND,VER_NBR,DLGTR_GRP_ID)
		VALUES(li_krew_actn_tkn,ls_doc_nbr,ls_initr_prncpl_id,NULL,'S',SYSDATE,1,NULL,1,1,NULL);	
		
		
		commit;			


-- new logic change START
		
		
-- inserting to temp table START
		li_krew_rte_brch_proto_true := null;
		li_krew_rte_brch_proto_false := null;
		open c_temp;
		loop
		fetch c_temp into r_temp;
		exit when c_temp%notfound;
		
			
			if r_temp.GENERATE_BRCH_PROTO = 'Y' then
			
			    if lower(r_temp.PROTO_BRCH_NM) = 'true' then
						select KREW_RTE_NODE_S.NEXTVAL into li_krew_rte_brch_proto_true from dual ;		
						INSERT INTO KREW_RTE_BRCH_PROTO_T(RTE_BRCH_PROTO_ID,BRCH_NM,VER_NBR)
						VALUES(li_krew_rte_brch_proto_true, 'True',1);
				end if;
			
				if lower(r_temp.PROTO_BRCH_NM) = 'false' then
						select KREW_RTE_NODE_S.NEXTVAL into li_krew_rte_brch_proto_false from dual ;
						INSERT INTO KREW_RTE_BRCH_PROTO_T(RTE_BRCH_PROTO_ID,BRCH_NM,VER_NBR)
						VALUES(li_krew_rte_brch_proto_false, 'False',1);
				end if;
		
				
			end if;
			
			select KREW_RTE_NODE_S.NEXTVAL into li_krew_rnt_node from dual ;			
			
			INSERT INTO TEMP_INSERT_NODE( RTE_NODE_ID, DOC_HDR_ID, NM, TYP, PROTO_BRCH_NM, RTE_MTHD_NM, RTE_MTHD_CD,ACTVN_TYP )	
			values(li_krew_rnt_node,ls_doc_nbr,r_temp.NM , r_temp.TYP,decode( upper(r_temp.PROTO_BRCH_NM),'TRUE',li_krew_rte_brch_proto_true, 'FALSE',li_krew_rte_brch_proto_false,null),r_temp.RTE_MTHD_NM, r_temp.RTE_MTHD_CD,r_temp.ACTVN_TYP);
		
		end loop;
		close c_temp;
		
		
		commit;
-- inserting to temp table END
		
		INSERT INTO KREW_RTE_NODE_T(RTE_NODE_ID,DOC_TYP_ID,NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,FNL_APRVR_IND,MNDTRY_RTE_IND,ACTVN_TYP,BRCH_PROTO_ID,VER_NBR,CONTENT_FRAGMENT,GRP_ID,NEXT_DOC_STAT)
		SELECT RTE_NODE_ID,li_doc_typ_id,NM,TYP,RTE_MTHD_NM,RTE_MTHD_CD,0,0,ACTVN_TYP, PROTO_BRCH_NM,1,null,null,null
		FROM TEMP_INSERT_NODE  where DOC_HDR_ID = ls_doc_nbr;
			
		
		
		INSERT INTO KREW_RTE_NODE_INSTN_T(RTE_NODE_INSTN_ID,DOC_HDR_ID,RTE_NODE_ID,BRCH_ID,PROC_RTE_NODE_INSTN_ID,ACTV_IND,CMPLT_IND,INIT_IND,VER_NBR)		
		select KREW_RTE_NODE_S.NEXTVAL,DOC_HDR_ID,RTE_NODE_ID,li_krew_rnt_brch,NULL,1,0,0,1 
		from TEMP_INSERT_NODE where DOC_HDR_ID = ls_doc_nbr
		and upper(nm) = 'INITIATED';
		
			
			
		INSERT INTO KREW_RTE_NODE_LNK_T(FROM_RTE_NODE_ID,TO_RTE_NODE_ID)	
		select 
		(select s1.RTE_NODE_ID from TEMP_INSERT_NODE s1 where s1.DOC_HDR_ID = ls_doc_nbr and upper(s1.NM) = upper(t1.FROM_NM) )  FROM_RTE_NODE_ID, 
		(select s2.RTE_NODE_ID from TEMP_INSERT_NODE s2 where s2.DOC_HDR_ID = ls_doc_nbr and upper(s2.NM) = upper(t1.TO_NM))  TO_RTE_NODE_ID
		from TEMP_LOOKUP_RTE_NODE_LNK	t1 
		where t1.DOC_TYP_NM = ls_doc_typ_nm;
		
		

		
		INSERT INTO KREW_RTE_NODE_CFG_PARM_T(RTE_NODE_CFG_PARM_ID, RTE_NODE_ID, KEY_CD, VAL)		
		SELECT KREW_RTE_NODE_CFG_PARM_S.nextval, t1.RTE_NODE_ID, t2.KEY_CD, t2.VAL
		FROM TEMP_INSERT_NODE t1 inner join TEMP_LOOKUP_CFG_PARM t2 on upper(t1.NM) = upper(t2.NM)
		where t1.DOC_HDR_ID = ls_doc_nbr
		and   t2.DOC_TYP_NM = ls_doc_typ_nm;
				
		commit;				
-- new logic change END

						
		INSERT INTO KREW_INIT_RTE_NODE_INSTN_T(DOC_HDR_ID,RTE_NODE_INSTN_ID)
		SELECT t1.doc_hdr_id , t1.rte_node_instn_id 
		FROM krew_rte_node_instn_t t1 inner join krew_rte_node_t t2 on t1.rte_node_id = t2.rte_node_id
		WHERE t1.doc_hdr_id = ls_doc_nbr
		and   upper(t2.nm) = 'INITIATED';
	


		INSERT INTO KREW_ACTN_RQST_T(ACTN_RQST_ID,PARNT_ID,ACTN_RQST_CD,DOC_HDR_ID,RULE_ID,STAT_CD,RSP_ID,PRNCPL_ID,ROLE_NM,QUAL_ROLE_NM,QUAL_ROLE_NM_LBL_TXT,RECIP_TYP_CD,PRIO_NBR,RTE_TYP_NM,RTE_LVL_NBR,RTE_NODE_INSTN_ID,ACTN_TKN_ID,DOC_VER_NBR,CRTE_DT,RSP_DESC_TXT,FRC_ACTN,ACTN_RQST_ANNOTN_TXT,DLGN_TYP,APPR_PLCY,CUR_IND,VER_NBR,GRP_ID,RQST_LBL)
		SELECT li_krew_actn_rqst,NULL,'C',t1.doc_hdr_id ,NULL,'A',-3,ls_initr_prncpl_id,NULL,NULL,NULL,'U',0,NULL,0, t1.rte_node_instn_id ,NULL,1,SYSDATE,'Initiator needs to complete document.',1,NULL,NULL,'F',1	,0,NULL,NULL
		FROM krew_rte_node_instn_t t1 inner join krew_rte_node_t t2 on t1.rte_node_id = t2.rte_node_id
		WHERE t1.doc_hdr_id = ls_doc_nbr
		and   upper(t2.nm) = 'INITIATED';
		
		
	
		commit;
		
		
end loop;
close c_data;


end;
/