CREATE TABLE person_inactive_exception(
prncpl_id VARCHAR2(40)    
)
/
INSERT INTO person_inactive_exception(prncpl_id)
select t2.prncpl_id from krim_entity_nm_t t1 inner join krim_prncpl_t t2 on t1.entity_id = t2.entity_id
where upper(trim(t1.last_nm)) like 'TBA%'
/
INSERT INTO person_inactive_exception(prncpl_id)
select t2.prncpl_id from krim_prncpl_t t2 
where prncpl_nm in ('admin','kr','notsys','kc','guest','kc-notificaion','mitkc')
/
commit
/

