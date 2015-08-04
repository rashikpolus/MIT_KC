alter table SUBAWARD add constraint  FK_ORGANIZATION foreign key(ORGANIZATION_ID) 
references ORGANIZATION(ORGANIZATION_ID)
/
alter table ORGANIZATION_CORRESPONDENT add constraint  FK1_ORGANIZATION_CORRESPONDENT foreign key(ORGANIZATION_ID) 
references ORGANIZATION(ORGANIZATION_ID)
/
alter table EPS_PROPOSAL add constraint  FK_EPS_PROPOSAL_ORGANIZATION foreign key(ORGANIZATION_ID) 
references ORGANIZATION(ORGANIZATION_ID)
/
alter table EPS_PROP_SITES add constraint  FK_EPS_SITES_ORGANIZATION foreign key(ORGANIZATION_ID) 
references ORGANIZATION(ORGANIZATION_ID)
/
alter table UNIT add constraint  FK_UNIT_ORGANIZATION foreign key(ORGANIZATION_ID) 
references ORGANIZATION(ORGANIZATION_ID)
/
alter table IACUC_ORG_CORRESPONDENT add constraint  FK_IACUC_ORGANIZATION foreign key(ORGANIZATION_ID) 
references ORGANIZATION(ORGANIZATION_ID)
/
alter table IACUC_ORG_CORRESPONDENT add constraint  FK_IACUC_ORGANIZATION foreign key(ORGANIZATION_ID) 
references ORGANIZATION(ORGANIZATION_ID)
/
alter table EPS_PROP_SITES add constraint  FK_EPS_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table PROPOSAL_PERSONS add constraint  FK_PROP_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table IACUC_PROTOCOL_REVIEWERS add constraint  FK_IACUC_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table AWARD_PERSONS add constraint  FK_AWARD_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table BUDGET_PERSONS add constraint  FK_BUDGET_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table EPS_PROP_PERSON_BIO add constraint  FK_PROP_BIO_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table IACUC_PROTOCOL_LOCATION add constraint  FK_IACUC_LOC_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table IACUC_PROTOCOL_PERSONS add constraint  FK_IACUC_PERS_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table EPS_PROP_PERSON add constraint  FK_EPS_PROP_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table PROPOSAL_LOG add constraint  FK_PROPOSAL_LOG_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table PROTOCOL_LOCATION add constraint  FK_PROTOCOL_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table COMM_MEMBERSHIPS add constraint  FK_COMM_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table AWARD_APPROVED_FOREIGN_TRAVEL add constraint  FK_FOREIGN_TRIP_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table PROTOCOL_PERSONS add constraint  FK_PROTO_ROLODEX foreign key(ROLODEX_ID) 
references ROLODEX(ROLODEX_ID)
/
alter table BUDGET_DETAILS add constraint  FK_BUDGET_COST foreign key(COST_ELEMENT) 
references COST_ELEMENT(COST_ELEMENT)
/
