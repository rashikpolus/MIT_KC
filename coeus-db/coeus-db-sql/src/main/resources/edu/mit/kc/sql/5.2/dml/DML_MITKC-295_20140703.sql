-- NSF Code
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'nsfCode', 'java.lang.String', 'Y', 1, 'NSF Code', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='nsfCode' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='nsfCode'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='nsfCode'), 1, 'NSF Code')
/
-- Subcontarct Flag
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'subcontracts', 'java.lang.Boolean', 'Y', 1, 'Subcontarct Flag', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='subcontracts' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='subcontracts'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='subcontracts'), 1, 'Subcontarct Flag')
/

-- Program Announcement Title
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'programAnnouncementTitle', 'java.lang.String', 'Y', 1, 'Program Announcement Title', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='programAnnouncementTitle' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='programAnnouncementTitle'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='programAnnouncementTitle'), 1, 'Program Announcement Title')
/
-- Proposal Number
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'proposalNumber', 'java.lang.String', 'Y', 1, 'Proposal Number', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='proposalNumber' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='proposalNumber'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='proposalNumber'), 1, 'Proposal Number')
/
-- Continued From
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'continuedFrom', 'java.lang.String', 'Y', 1, 'Continued From', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='continuedFrom' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='continuedFrom'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='continuedFrom'), 1, 'Continued From')
/
-- Sponsor Code
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'sponsorCode', 'java.lang.String', 'Y', 1, 'Sponsor Code', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='sponsorCode' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='sponsorCode'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='sponsorCode'), 1, 'Sponsor Code')
/
-- Proposal Title
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'title', 'java.lang.String', 'Y', 1, 'Proposal Title', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='title' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='title'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='title'), 1, 'Proposal Title')
/

--Notice Of Opportunity Code
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'noticeOfOpportunityCode', 'java.lang.String', 'Y', 1, 'Notice Of Opportunity Code', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='noticeOfOpportunityCode' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='noticeOfOpportunityCode'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='noticeOfOpportunityCode'), 1, 'Notice Of Opportunity Code')
/
--Deadline Type
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'deadlineType', 'java.lang.String', 'Y', 1, 'Deadline Type', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='deadlineType' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='deadlineType'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='deadlineType'), 1, 'Deadline Type')
/
--Prime Sponsor Code
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'primeSponsorCode', 'java.lang.String', 'Y', 1, 'Prime Sponsor Code', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='primeSponsorCode' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='primeSponsorCode'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='primeSponsorCode'), 1, 'Prime Sponsor Code')
/
--Sponsor Proposal Number
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'sponsorProposalNumber', 'java.lang.String', 'Y', 1, 'Sponsor Proposal Number', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='sponsorProposalNumber' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='sponsorProposalNumber'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='sponsorProposalNumber'), 1, 'Sponsor Proposal Number')
/
--Number Of Copies
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'numberOfCopies', 'java.lang.String', 'Y', 1, 'Number Of Copies', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='numberOfCopies' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='numberOfCopies'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='numberOfCopies'), 1, 'Number Of Copies')
/
--Proposal State Type Code
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'proposalStateTypeCode', 'java.lang.String', 'Y', 1, 'Proposal State Type Code', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='proposalStateTypeCode' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='proposalStateTypeCode'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='proposalStateTypeCode'), 1, 'Proposal State Type Code')
/
--Prev Grants Gov Tracking ID
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'prevGrantsGovTrackingID', 'java.lang.String', 'Y', 1, 'Prev Grants Gov Tracking ID', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='prevGrantsGovTrackingID' and NMSPC_CD='KC-PD'), 'N')
/

-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='prevGrantsGovTrackingID'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='prevGrantsGovTrackingID'), 1, 'Prev Grants Gov Tracking ID')
/
--Agency Routing Identifier
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'agencyRoutingIdentifier', 'java.lang.String', 'Y', 1, 'Agency Routing Identifier', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='agencyRoutingIdentifier' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='agencyRoutingIdentifier'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='agencyRoutingIdentifier'), 1, 'Agency Routing Identifier')
/
--Opportunity Id For GG
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'opportunityIdForGG', 'java.lang.String', 'Y', 1, 'Opportunity Id For GG', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='opportunityIdForGG' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='opportunityIdForGG'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/

-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='opportunityIdForGG'), 1, 'Opportunity Id For GG')
/
--Last Synced Budget Document Number
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'lastSyncedBudgetDocumentNumber', 'java.lang.String', 'Y', 1, 'Last Synced Budget Document Number', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='lastSyncedBudgetDocumentNumber' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='lastSyncedBudgetDocumentNumber'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='lastSyncedBudgetDocumentNumber'), 1, 'Last Synced Budget Document Number')
/
--Hierarchy Budget Type
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'hierarchyBudgetType', 'java.lang.String', 'Y', 1, 'Hierarchy Budget Type', 'KC-PD')
/
-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyBudgetType' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='hierarchyBudgetType'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyBudgetType'), 1, 'Hierarchy Budget Type')
/
--Hierarchy Last Sync Hash Code
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'hierarchyLastSyncHashCode', 'java.lang.Integer', 'Y', 1, 'Hierarchy Last Sync Hash Code', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyLastSyncHashCode' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='hierarchyLastSyncHashCode'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyLastSyncHashCode'), 1, 'Hierarchy Last Sync Hash Code')
/
--Hierarchy Parent Proposal Number
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'hierarchyParentProposalNumber', 'java.lang.String', 'Y', 1, 'Hierarchy Parent Proposal Number', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyParentProposalNumber' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='hierarchyParentProposalNumber'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyParentProposalNumber'), 1, 'Hierarchy Parent Proposal Number')
/
--Hierarchy Originating Child Proposal Number
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'hierarchyOriginatingChildProposalNumber', 'java.lang.String', 'Y', 1, 'Hierarchy Originating Child Proposal Number', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyOriginatingChildProposalNumber' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='hierarchyOriginatingChildProposalNumber'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyOriginatingChildProposalNumber'), 1, 'Hierarchy Originating Child Proposal Number')
/
--Hierarchy Status Name
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'hierarchyStatusName', 'java.lang.String', 'Y', 1, 'Hierarchy Status Name', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyStatusName' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='hierarchyStatusName'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='hierarchyStatusName'), 1, 'Hierarchy Status Name')
/
--Budget Status
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'budgetStatus', 'java.lang.String', 'Y', 1, 'Budget Status', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='budgetStatus' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='budgetStatus'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='budgetStatus'), 1, 'Budget Status')
/
--nextProposalPersonNumber
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'nextProposalPersonNumber', 'java.lang.Integer', 'Y', 1, 'Next Proposal Person Number', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='nextProposalPersonNumber' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='nextProposalPersonNumber'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='nextProposalPersonNumber'), 1, 'Next Proposal Person Number')
/
--Mailing Address Id
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'mailingAddressId', 'java.lang.Integer', 'Y', 1, 'Mailing Address Id', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailingAddressId' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='mailingAddressId'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailingAddressId'), 1, 'Mailing Address Id')
/
--Mail Description
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'mailDescription', 'java.lang.String', 'Y', 1, 'Mail Description', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailDescription' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='mailDescription'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailDescription'), 1, 'Mail Description')
/
--mailAccountNumber
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'mailAccountNumber', 'java.lang.String', 'Y', 1, 'Mail Account Number', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailAccountNumber' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='mailAccountNumber'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailAccountNumber'), 1, 'Mail Account Number')
/
--Mail Type
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'mailType', 'java.lang.String', 'Y', 1, 'Mail Type', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailType' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='mailType'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailType'), 1, 'Mail Type')
/
--mailBy
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'mailBy', 'java.lang.String', 'Y', 1, 'Mail By', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailBy' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='mailBy'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='mailBy'), 1, 'Mail By')
/
--New Description
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'newDescription', 'java.lang.String', 'Y', 1, 'New Description', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='newDescription' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='newDescription'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='newDescription'), 1, 'New Description')
/
--New Science Keyword Code
-- Term Specification entry
insert into KRMS_TERM_SPEC_T (TERM_SPEC_ID, NM, TYP, ACTV, VER_NBR, DESC_TXT, NMSPC_CD) 
values (CONCAT('KCMIT', KRMS_TERM_SPEC_S.NEXTVAL), 'newScienceKeywordCode', 'java.lang.String', 'Y', 1, 'New Science Keyword Code', 'KC-PD')
/

-- Make valid for the Proposal Development Context
insert into KRMS_CNTXT_VLD_TERM_SPEC_T (CNTXT_TERM_SPEC_PREREQ_ID, CNTXT_ID, TERM_SPEC_ID, PREREQ) 
values (CONCAT('KCMIT', KRMS_CNTXT_VLD_TERM_SPEC_S.NEXTVAL), 'KC-PD-CONTEXT', (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='newScienceKeywordCode' and NMSPC_CD='KC-PD'), 'N')
/
-- Associate the Term Spec with the appropriate Category
insert into KRMS_TERM_SPEC_CTGRY_T (TERM_SPEC_ID, CTGRY_ID) values ((select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NMSPC_CD='KC-PD' and NM='newScienceKeywordCode'), 
(select CTGRY_ID from KRMS_CTGRY_T where NMSPC_CD='KC-PD' and NM='Property'))
/
-- Term entry 
insert into KRMS_TERM_T (TERM_ID, TERM_SPEC_ID, VER_NBR, DESC_TXT) 
values (CONCAT('KCMIT', KRMS_TERM_S.NEXTVAL), (select TERM_SPEC_ID from KRMS_TERM_SPEC_T where NM='newScienceKeywordCode'), 1, 'New Science Keyword Code')
/
