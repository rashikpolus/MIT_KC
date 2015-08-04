-- Inserting to krew_attr_defn_t becasue KREW_PPL_FLW_ATTR_T has the foreign key relationship   
DECLARE
  li_count PLS_INTEGER;
  CURSOR c_data IS
  SELECT nm, nmspc_cd, lbl, actv, cmpnt_nm, desc_txt FROM krew_attr_defn_t@kc_stag_db_link 
  WHERE attr_defn_id IN (SELECT attr_defn_id FROM krew_ppl_flw_attr_t@kc_stag_db_link);
  r_data c_data%rowtype;
BEGIN

  OPEN c_data;
  LOOP
  FETCH c_data INTO r_data;
  EXIT WHEN c_data%NOTFOUND;
  
  SELECT COUNT(attr_defn_id) INTO li_count FROM krew_attr_defn_t
  WHERE nm = r_data.nm
  AND nmspc_cd = r_data.nmspc_cd;
  
  IF li_count = 0 THEN
    INSERT INTO krew_attr_defn_t(
    attr_defn_id,
    nm,
    nmspc_cd,
    lbl,
    actv,
    cmpnt_nm,
    ver_nbr,
    desc_txt
    )
    VALUES(
    krew_attr_defn_s.nextval,
    r_data.nm,
    r_data.nmspc_cd,
    r_data.lbl,
    r_data.actv,
    r_data.cmpnt_nm,
    1,
    r_data.desc_txt
    );  
  END IF;
  
  END LOOP;
  CLOSE c_data;

END;
/
commit
/
ALTER TABLE KREW_PPL_FLW_ATTR_T DISABLE CONSTRAINT KREW_PPL_FLW_ATTR_FK1
/
ALTER TABLE KREW_PPL_FLW_MBR_T DISABLE CONSTRAINT KREW_PPL_FLW_MBR_FK1
/
ALTER TABLE KREW_PPL_FLW_DLGT_T DISABLE CONSTRAINT KREW_PPL_FLW_DLGT_FK1
/
-- repopulating krew_ppl_flw_attr_t
TRUNCATE TABLE krew_ppl_flw_attr_t
/
INSERT INTO krew_ppl_flw_attr_t(
ppl_flw_attr_id,
ppl_flw_id,
attr_defn_id,
attr_val,
ver_nbr
)
SELECT ppl_flw_attr_id,
ppl_flw_id,
attr_defn_id,
attr_val,
ver_nbr
FROM krew_ppl_flw_attr_t@kc_stag_db_link
/
-- repopulating krew_ppl_flw_dlgt_t
TRUNCATE TABLE krew_ppl_flw_dlgt_t
/
INSERT INTO krew_ppl_flw_dlgt_t(
ppl_flw_dlgt_id,
ppl_flw_mbr_id,
mbr_id,
mbr_typ_cd,
dlgn_typ_cd,
ver_nbr,
actn_rqst_plcy_cd,
rsp_id
)
SELECT ppl_flw_dlgt_id,
ppl_flw_mbr_id,
mbr_id,
mbr_typ_cd,
dlgn_typ_cd,
ver_nbr,
actn_rqst_plcy_cd,
rsp_id
FROM krew_ppl_flw_dlgt_t@kc_stag_db_link
/
TRUNCATE TABLE krew_ppl_flw_t
/
-- repopulating krew_ppl_flw_t
INSERT INTO krew_ppl_flw_t(
ppl_flw_id,
nm,
nmspc_cd,
typ_id,
actv,
ver_nbr,
desc_txt
)
SELECT ppl_flw_id,
nm,
nmspc_cd,
typ_id,
actv,
ver_nbr,
desc_txt
FROM krew_ppl_flw_t@kc_stag_db_link
/
-- repopulating krew_ppl_flw_mbr_t
TRUNCATE TABLE krew_ppl_flw_mbr_t
/
INSERT INTO krew_ppl_flw_mbr_t(
ppl_flw_mbr_id,
ppl_flw_id,
mbr_typ_cd,
mbr_id,
prio,
ver_nbr,
actn_rqst_plcy_cd,
rsp_id,
frc_actn
)
SELECT ppl_flw_mbr_id,
ppl_flw_id,
mbr_typ_cd,
mbr_id,
prio,
ver_nbr,
actn_rqst_plcy_cd,
rsp_id,
frc_actn
FROM krew_ppl_flw_mbr_t@kc_stag_db_link
/
ALTER TABLE KREW_PPL_FLW_ATTR_T ENABLE CONSTRAINT KREW_PPL_FLW_ATTR_FK1
/
ALTER TABLE KREW_PPL_FLW_MBR_T ENABLE CONSTRAINT KREW_PPL_FLW_MBR_FK1
/
ALTER TABLE KREW_PPL_FLW_DLGT_T ENABLE CONSTRAINT KREW_PPL_FLW_DLGT_FK1
/
-- Updating sequence_objects
declare
ls_max_val NUMBER(6,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ppl_flw_attr_id) into ls_max_val from krew_ppl_flw_attr_t;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select krew_ppl_flw_attr_s.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KREW_PPL_FLW_ATTR_S increment by '||li_increment);
    select krew_ppl_flw_attr_s.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KREW_PPL_FLW_ATTR_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(6,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ppl_flw_dlgt_id) into ls_max_val from krew_ppl_flw_dlgt_t;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select krew_ppl_flw_dlgt_s.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KREW_PPL_FLW_DLGT_S increment by '||li_increment);
    select krew_ppl_flw_dlgt_s.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KREW_PPL_FLW_DLGT_S increment by 1');
  end if;

end;
/
declare
ls_max_val NUMBER(6,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
begin

  select max(ppl_flw_mbr_id) into ls_max_val from krew_ppl_flw_mbr_t;
  if ls_max_val is null then
  ls_max_val := 0;
  end if;    
  select krew_ppl_flw_mbr_s.nextval into li_present_seq_val from dual;
  if li_present_seq_val < ls_max_val then  
    li_increment := ls_max_val - li_present_seq_val;  
    execute immediate('alter sequence KREW_PPL_FLW_MBR_S increment by '||li_increment);
    select krew_ppl_flw_mbr_s.nextval into li_present_seq_val from dual;   
    execute immediate('alter sequence KREW_PPL_FLW_MBR_S increment by 1');
  end if;

end;
/
DECLARE
ls_max_val NUMBER(6,0);
li_present_seq_val NUMBER;
li_increment NUMBER;
BEGIN

  SELECT MAX(ppl_flw_id) INTO ls_max_val FROM krew_ppl_flw_t;
  IF ls_max_val IS NULL THEN
  ls_max_val := 0;
  END IF;    
  SELECT krew_ppl_flw_s.nextval INTO li_present_seq_val FROM dual;
  IF li_present_seq_val < ls_max_val THEN  
    li_increment := ls_max_val - li_present_seq_val;  
    EXECUTE IMMEDIATE('alter sequence KREW_PPL_FLW_S increment by '||li_increment);
    SELECT krew_ppl_flw_s.nextval INTO li_present_seq_val FROM DUAL;   
    EXECUTE IMMEDIATE('alter sequence KREW_PPL_FLW_S increment by 1');
  END IF;

END;
/
