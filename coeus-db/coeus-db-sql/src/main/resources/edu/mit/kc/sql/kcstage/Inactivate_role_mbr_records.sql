update krim_role_mbr_t set  actv_to_dt  = sysdate   
	--select count(*) from krim_role_mbr_t 
  where mbr_id not in (
	select prncpl_id from  krim_prncpl_t 
          where prncpl_nm in ('admin','geot','sdowdy','cwood','snair','kr','kc')
        )
	and 
  --select count(*) from krim_role_mbr_t where 
  role_id not in (select role_id from krim_role_t where role_nm like '%Award Budget%');
  
update krim_role_mbr_t set  actv_to_dt  = sysdate   
  where mbr_id in (
	select prncpl_id from  krim_prncpl_t 
	where --prncpl_nm ='aeh' and
	role_id in (select role_id from krim_role_t where role_nm='Manager')
	);  
  
  
update krim_role_mbr_t set  actv_to_dt  = null   
  where mbr_id in (
	select prncpl_id from  krim_prncpl_t 
	where prncpl_nm ='aeh'
	); 
  
select * from krim_role_perm_t where role_id in (select role_id from krim_role_t where role_nm like '%Award Budget%')

select * from krim_perm_t where nm like '%Export%'

select * from krim_role_t where role_nm='User'

select count(*) from krim_role_mbr_t where mbr_id in (select prncpl_id from krim_prncpl_t where prncpl_id='admin')

update krim_prncpl_t set ACTV_IND='Y' where prncpl_nm in ('admin','kr')


select count(*) from krim_role_mbr_t 
  where mbr_id in (
	select prncpl_id from  krim_prncpl_t 
	where prncpl_nm in ('kc')
	)
  
  
select * from krim_role_mbr_t 
--update krim_role_mbr_t set  actv_to_dt  = null
where 
  role_id in (select role_id from krim_role_t where role_nm='Manager');  


update krim_role_mbr_t set  actv_to_dt  = null
where 
  role_id in (select role_id from krim_role_t where role_nm='Kuali Rules Management System Administrator');  
  
  
update krim_role_mbr_t set  actv_to_dt  = null 
	--select count(*) from krim_role_mbr_t 
  where mbr_id in (
	select prncpl_id from  krim_prncpl_t 
          where prncpl_nm in ('acia',
                  'mbaguer',
                  'wbarrett',
                  'sarahb',
                  'pcaissie',
                  'icariolo',
                  'mchristy',
                  'mclarkso',
                  'mcorcor',
                  'kdawson',
                  'kdenutte',
                  'jpd',
                  'ncaissie',
                  'sdowdy',
                  'rdownes',
                  'tduff',
                  'mff',
                  'nfoley',
                  'rfrost',
                  'mgnetto',
                  'jrgold',
                  'cgoodwin',
                  'rgrewal',
                  'ehall',
                  'rhanlon',
                  'cheaton',
                  'aeh',
                  'laureena',
                  'hudak',
                  'i_annac',
                  'rlateva',
                  'rlay',
                  'klazzaro',
                  'mleskiw',
                  'jenlu',
                  'kmann',
                  'rmathews',
                  'mam',
                  'tmelende',
                  'vmorris',
                  'snair',
                  'lnelson',
                  'cnewf',
                  'dan4th',
                  'kiirja',
                  'spettit',
                  'lpiazza',
                  'hponnoju',
                  'powderly',
                  'dquimby',
                  'jdrob',
                  'jennymr',
                  'nsahag',
                  'ele',
                  'kshikes',
                  'sullaway',
                  'geot',
                  'bvallely',
                  'pviejo',
                  'svogel',
                  'cwood'
                )

        )
	and role_id in (select role_id from krim_role_t where role_nm = 'View Award');

select count(*) from krim_role_mbr_t 
--update krim_role_mbr_t set  actv_to_dt  = null 
 where mbr_id in (
	select prncpl_id from  krim_prncpl_t 
          where prncpl_nm in ('acia') and role_id in (select role_id from krim_role_t where role_nm = 'View Award'))

