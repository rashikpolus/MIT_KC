
DELETE FROM DASH_BOARD_MENU_ITEMS
/

INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create Proposal', '/kc-pd-krad/proposalDevelopment?methodToCall=docHandler&command=initiate&viewId=PropDev-InitiateView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search for Proposals', '/kr-krad/lookup?methodToCall=start&viewId=DevelopmentProposals-LookupViewId', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Proposals Enroute', '/kr-krad/lookup?methodToCall=start&viewId=EnrouteDevelopmentProposals-LookupViewId', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View All My Proposals', '/kr-krad/lookup?methodToCall=search&viewId=AllDevelopmentProposals-LookupViewId', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create Proposal Log', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Fmaintenance.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.institutionalproposal.proposallog.ProposalLog&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create Institute Proposal', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.institutionalproposal.proposallog.ProposalLog%26docFormKey%3D88888888%26includeCustomActionUrls%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%3FforInstitutionalProposal%26hideReturnLink%3Dtrue%26showMaintenanceLinks%3Dtrue%26refreshCaller%3Dcancel&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search Proposal Log', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.institutionalproposal.proposallog.ProposalLog%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26showMaintenanceLinks%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search for Institutional Proposals', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.institutionalproposal.home.InstitutionalProposal%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create Negotiations', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FnegotiationNegotiation.do%3FmethodToCall%3DdocHandler%26command%3Dinitiate%26docTypeName%3DNegotiationDocument&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search Negotiations', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.negotiations.bo.Negotiation%26docFormKey%3D88888888%26includeCustomActionUrls%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View All My Negotiations', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.negotiations.bo.Negotiation%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26negotiatorName%3Dadmin*admin%26lookupProtocolPersonId%3Dadmin%26searchCriteriaEnabled%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create Post-Award', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FawardHome.do%3FmethodToCall%3DdocHandler%26command%3Dinitiate%26docTypeName%3DAwardDocument%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search For Post-Award', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.award.home.Award%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Award Report Tracking', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FreportTrackingLookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.award.paymentreports.awardreports.reporting.ReportTracking%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create SubAward', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FsubAwardHome.do%3FmethodToCall%3DdocHandler%26command%3Dinitiate%26docTypeName%3DSubAwardDocument%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search For SubAward', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.subaward.bo.SubAward%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View All my Awards', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.award.home.Award%26docFormKey%3D88888888%26includeCustomActionUrls%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26projectPersons.fullName%3Dadmin*admin&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create IRB Protocol', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FprotocolProtocol.do%3FmethodToCall%3DdocHandler%26command%3Dinitiate%26docFormKey%3D88888888%26docTypeName%3DProtocolDocument%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search For IRB Protocols', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Amend or Renew IRB Protocol', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupActionAmendRenewProtocol%3Dtrue&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Notify IRB of a Protocol', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupActionNotifyIRBProtocol%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Request a Status Change on a IRB Protocol', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupActionRequestProtocol%3Dtrue&viewId=Kc-Header-IframeView', 'A', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Pending Protocols', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupPendingProtocol%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Protocols Pending PI Action', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupPendingProtocol%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Protocols Pending Committee Action', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupPendingProtocol%3Dtrue%26protocolStatusCode%3D100&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Protocols Under Development', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupPendingProtocol%3Dtrue%26protocolStatusCode%3D101&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View All My Protocols', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.irb.Protocol%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupProtocolPersonId%3Dadmin%26investigator%3Dadmin*admin&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View All My Reviews', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.iacuc.onlinereview.IacucProtocolOnlineReview%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupReviewerPersonId%3Dadmin&viewId=Kc-Header-IframeView', 'A', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View All My Schedules', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dsearch%26businessObjectClassName%3Dorg.kuali.kra.committee.bo.CommitteeSchedule%26showMaintenanceLinks%3Dtrue%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26committee.committeeMemberships.personId%3Dadmin&viewId=Kc-Header-IframeView', 'A', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Pessimistic Lock', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.rice.krad.document.authorization.PessimisticLock%26showMaintenanceLinks%3Dtrue%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search For Grants.gov Opportunity', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.coeus.propdev.impl.s2s.S2sOpportunity%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Address Book', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.coeus.common.framework.rolodex.Rolodex%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26docFormKey%3D88888888&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search For A Sponsor', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.coeus.common.framework.sponsor.Sponsor%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search For A Keyword', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.coeus.common.framework.keyword.ScienceKeyword&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Current & Pending Support', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FcurrentOrPendingReport.do%3FreturnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Perform Person Mass Change', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FpersonMassChangeHome.do%3FmethodToCall%3DdocHandler%26command%3Dinitiate%26docFormKey%3D88888888%26docTypeName%3DPersonMassChangeDocument%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View ISR/SSR Reporting', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FisrSsrReporting.do%3F%3FmethodToCall%3DdocHandler%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Award Subcontracting Goals and Expenditures', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FawardSubcontractingGoalsExpenditures.do%3FmethodToCall%3Dstart%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Generate Subcontracting Expenditure Data', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FsubcontractingExpendituresDataGeneration.do%3FmethodToCall%3Dstart%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Reporting', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Freporting.do%3FmethodToCall%3DgetReportParametersFromDesign%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Create IRB Commiittee', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FcommitteeCommittee.do%3FmethodToCall%3DdocHandler%26command%3Dinitiate%26docTypeName%3DCommitteeDocument%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Search For IRB Commiittee', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.committee.bo.Committee%26docFormKey%3D88888888%26includeCustomActionUrls%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Protocol Submissions', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.irb.actions.submit.ProtocolSubmission%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View IRB Schedules', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.kra.committee.bo.CommitteeSchedule%26docFormKey%3D88888888%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Agenda', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr-krad%2Flookup%3FmethodToCall%3Dstart%26dataObjectClassName%3Dorg.kuali.rice.krms.impl.repository.AgendaBo%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Context', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr-krad%2Flookup%3FmethodToCall%3Dstart%26dataObjectClassName%3Dorg.kuali.rice.krms.impl.repository.ContextBo%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Attribute Definition', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr-krad%2Flookup%3FmethodToCall%3Dstart%26dataObjectClassName%3Dorg.kuali.rice.krms.impl.repository.KrmsAttributeDefinitionBo%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Terms', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr-krad%2Flookup%3FmethodToCall%3Dstart%26dataObjectClassName%3Dorg.kuali.rice.krms.impl.repository.TermBo%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Term Specifications', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr-krad%2Flookup%3FmethodToCall%3Dstart%26dataObjectClassName%3Dorg.kuali.rice.krms.impl.repository.TermSpecificationBo%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Category', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr-krad%2Flookup%3FmethodToCall%3Dstart%26dataObjectClassName%3Dorg.kuali.rice.krms.impl.repository.CategoryBo%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View People Flow', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr-krad%2Flookup%3FmethodToCall%3Dstart%26dataObjectClassName%3Dorg.kuali.rice.kew.impl.peopleflow.PeopleFlowBo%26showMaintenanceLinks%3Dtrue%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'Edit Preferences', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkew%2FPreferences.do%3FreturnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Routing Report', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkew%2FRoutingReport.do%3FreturnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', NULL, 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Rules', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkr%2Flookup.do%3FmethodToCall%3Dstart%26businessObjectClassName%3Dorg.kuali.rice.kew.rule.RuleBaseValues%26docFormKey%3D88888888%26returnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView%26hideReturnLink%3Dtrue%26lookupActionNotifyIRBProtocol%3Dtrue&viewId=Kc-Header-IframeView', 'O', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Rule QuickLinks', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2Fkew%2FRuleQuickLinks.do%3FreturnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', 'A', 'Y', sysdate, 'admin', 1, sys_guid())
/
INSERT INTO DASH_BOARD_MENU_ITEMS (DASH_BOARD_MENU_ITEM_ID, MENU_ITEM, MENU_ACTION, MENU_TYPE_FLAG, ACTIVE, UPDATE_TIMESTAMP, UPDATE_USER, VER_NBR, OBJ_ID)
VALUES (SEQ_DASH_BOARD_MENU_ITEM_ID.NEXTVAL, 'View Current and Pending Personnel Support', '/kc-krad/landingPage?methodToCall=start&href=<<APPLICATION_URL>>%2FcurrentOrPendingReport.do%3FreturnLocation%3D<<APPLICATION_URL>>%252Fkc-krad%252FlandingPage%253FviewId%253DKc-LandingPage-RedirectView&viewId=Kc-Header-IframeView', 'A', 'Y', sysdate, 'admin', 1, sys_guid())
/
