TRUNCATE TABLE krcr_parm_t
/
INSERT INTO krcr_parm_t(
nmspc_cd,
cmpnt_cd,
parm_nm,
appl_id,
obj_id,
ver_nbr,
parm_typ_cd,
val,
parm_desc_txt,
eval_oprtr_cd
)
SELECT nmspc_cd,
cmpnt_cd,
parm_nm,
appl_id,
obj_id,
ver_nbr,
parm_typ_cd,
val,
parm_desc_txt,
eval_oprtr_cd
FROM krcr_parm_t@kc_stag_db_link
/
commit
/
