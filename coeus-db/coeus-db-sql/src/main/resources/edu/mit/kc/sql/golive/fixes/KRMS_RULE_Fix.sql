select * from krms_agenda_t where actv='N'

select * from krms_rule_t where rule_id = 'KC2001'

select * from krms_agenda_t where nm='060700 SoE MITES Proposal Routing'

update krms_agenda_t set actv='Y'  WHERE NM='060700 SoE MITES Proposal Routing'

update krms_agenda_t set actv='N' where nm='Development Proposal Branching Questionnaire'


update krms_agenda_t set INIT_AGENDA_ITM_ID='10112',actv='Y' 
WHERE NM ='152000 Chemistry';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10123',actv='Y' 
WHERE NM='165000 Center for Environmental Health Sciences';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10121',actv='Y' 
WHERE NM='159700 Koch Inst - Integrative Cancer Research';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10118',actv='Y' 
WHERE NM='159300 Picower Institute for Learning and Memory';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10003',actv='Y' 
WHERE NM='430000 CBI All Proposals';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10122',actv='Y' 
WHERE NM='159900 Laboratory for Nuclear Science';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10113',actv='Y' 
WHERE NM='153000 Earth, Atmospheric, and Planetary';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10053',actv='Y' 
WHERE NM='035000 Urban Studies and Planning Proposal Routing';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10115',actv='Y' 
WHERE NM='154501 Simons Center for the Social Brain';

update krms_agenda_t set INIT_AGENDA_ITM_ID='10120',actv='Y' 
WHERE NM='159600 Kavli Inst for Astrophysics and Space Rsrh';
select * from krms_rule_t where nm like '%060700%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10065' WHERE NM='060700 SoE MITES Proposal Routing'
/
update question set question_id = '143' where question='Have lobbying activities been conducted on behalf of this proposal? Disclosure of Lobbying Activities (GPG, Chapter II.C.1.e)'
/
update question set question_id = '144' where question like 'Select a Funding Mechanism'
/
select * from krms_rule_t where nm like '%271000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10014',actv='Y' WHERE NM='271000 Libraries'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10125',actv='Y' WHERE NM='170000 Leaders for Global Operations Program'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10119',actv='Y' WHERE NM='159400 Center for Global Change Science'
/
select * from krms_rule_t where nm like '%035000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10053',actv='Y' WHERE NM='035000 Urban Studies and Planning Proposal Routing'
/
select * from krms_rule_t where nm like '%151000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10061',actv='Y' WHERE NM='151000 Biology'
/
select * from krms_rule_t where nm like '%093700%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10077',actv='Y' WHERE NM='093700 Music and Theater Arts'
/
select * from krms_rule_t where nm like '%150000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10111',actv='Y' WHERE NM='150000 School of Science Agenda'
/
select * from krms_rule_t where nm like '%401866%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10029',actv='Y' WHERE NM='401866 Collaborative Initiatives'
/
select * from krms_rule_t where nm like '%030000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10101',actv='Y' WHERE NM='030000 School of Architecture Proposal Routing'
/
select * from krms_rule_t where nm like '%153000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10113',actv='Y' WHERE NM='153000 Earth, Atmospheric, and Planetary'
/
select * from krms_rule_t where nm like '%154501%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10115',actv='Y' WHERE NM='154501 Simons Center for the Social Brain'
/
select * from krms_rule_t where nm like '%159300%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10118',actv='Y' WHERE NM='159300 Picower Institute for Learning and Memory'
/
select * from krms_rule_t where nm like '%159400%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10119',actv='Y' WHERE NM='159400 Center for Global Change Science'
/
select * from krms_rule_t where nm like '%159600%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10120',actv='Y' WHERE NM='159600 Kavli Inst for Astrophysics and Space Rsrh'
/
select * from krms_rule_t where nm like '%159700%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10121',actv='Y' WHERE NM='159700 Koch Inst - Integrative Cancer Research'
/
select * from krms_rule_t where nm like '%159900%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10122',actv='Y' WHERE NM='159900 Laboratory for Nuclear Science'
/
select * from krms_rule_t where nm like '%165000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10123',actv='Y' WHERE NM='165000 Center for Environmental Health Sciences'
/
select * from krms_rule_t where nm like '%170000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10125',actv='Y' WHERE NM='170000 Leaders for Global Operations Program'
/
select * from krms_rule_t where nm like '%401860%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10161',actv='Y' WHERE NM='401860 VP Research Proposal Routing'
/
select * from krms_rule_t where nm like '%430000%'
/
update krms_agenda_t set INIT_AGENDA_ITM_ID='10003',actv='Y' WHERE NM='430000 CBI All Proposals'
/
update krms_agenda_t set actv='Y'
/



select * from krms_agenda_t where nm = '060700 SoE MITES Proposal Routing'

select * from krms_agenda_t@kc_stag_db_link where nm = '060700 SoE MITES Proposal Routing'

update krms_agenda_t set INIT_AGENDA_ITM_ID = '10060' where nm = '060700 SoE MITES Proposal Routing'


select INIT_AGENDA_ITM_ID from krms_agenda_t where nm = '150000 School of Science Agenda';
select INIT_AGENDA_ITM_ID from krms_agenda_t@kc_stag_db_link where nm = '150000 School of Science Agenda';

select a.nm from krms_agenda_t a,krms_agenda_t@kc_stag_db_link b where a.NM=b.NM and a.INIT_AGENDA_ITM_ID<>b.INIT_AGENDA_ITM_ID

update krms_agenda_t a set INIT_AGENDA_ITM_ID = 
  (select INIT_AGENDA_ITM_ID from krms_agenda_t@kc_stag_db_link b where a.NM=b.NM and a.INIT_AGENDA_ITM_ID<>b.INIT_AGENDA_ITM_ID)
where exists (select INIT_AGENDA_ITM_ID from krms_agenda_t@kc_stag_db_link b where a.NM=b.NM and a.INIT_AGENDA_ITM_ID<>b.INIT_AGENDA_ITM_ID)


select INIT_AGENDA_ITM_ID from krms_agenda_t where nm = '150000 School of Science Agenda';
select INIT_AGENDA_ITM_ID from krms_agenda_t@kc_stag_db_link where nm = '150000 School of Science Agenda';

select * from krms_agenda_t where nm = '150000 School of Science Agenda';

select * from krms_agenda_itm_t@kc_stag_db_link where agenda_id not in (select agenda_id from krms_agenda_itm_t)

insert into krms_agenda_itm_t 
  (select * from krms_agenda_itm_t@kc_stag_db_link where agenda_id not in (select agenda_id from krms_agenda_itm_t))

select * from krms_rule_t where nm like '150000%' order by rule_id
/
select * from krms_rule_t@kc_stag_db_link where nm like '150000%'  order by rule_id

