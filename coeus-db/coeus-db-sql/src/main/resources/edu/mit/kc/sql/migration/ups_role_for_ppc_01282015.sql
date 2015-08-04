set serveroutput on;
declare
ls_role_id_old krim_role_t.role_id%type;
ls_role_id_new krim_role_t.role_id%type;
begin
  begin
    select role_id into ls_role_id_old from krim_role_t where role_nm = 'Aggregator';
    select role_id into ls_role_id_new from krim_role_t where role_nm = 'Aggregator Document Level';
    update krim_role_mbr_t set role_id = ls_role_id_new where role_id = ls_role_id_old;
    update document_access set role_nm = 'Aggregator Document Level' where role_nm = 'Aggregator';
    delete from krim_role_perm_t where role_id  = ls_role_id_old;
    delete from krim_role_t where role_id  = ls_role_id_old;
  exception
  when others then
  dbms_output.put_line('Error in Aggregator'||sqlerrm);
  end;
commit;

  begin
    select role_id into ls_role_id_old from krim_role_t where role_nm = 'Viewer';
    select role_id into ls_role_id_new from krim_role_t where role_nm = 'Viewer Document Level';
    update krim_role_mbr_t set role_id = ls_role_id_new where role_id = ls_role_id_old;
    update document_access set role_nm = 'Viewer Document Level' where role_nm = 'Viewer';
    delete from krim_role_perm_t where role_id  = ls_role_id_old;
    delete from krim_role_t where role_id  = ls_role_id_old;
  exception
  when others then
  dbms_output.put_line('Error in Viewer'||sqlerrm);
  end;
commit;

  begin
    select role_id into ls_role_id_old from krim_role_t where role_nm = 'Narrative Writer';
    select role_id into ls_role_id_new from krim_role_t where role_nm = 'Narrative Writer Document Level';
    update krim_role_mbr_t set role_id = ls_role_id_new where role_id = ls_role_id_old;
    update document_access set role_nm = 'Narrative Writer Document Level' where role_nm = 'Narrative Writer';
    delete from krim_role_perm_t where role_id  = ls_role_id_old;
    delete from krim_role_t where role_id  = ls_role_id_old;
  exception
  when others then
  dbms_output.put_line('Error in Narrative Writer'||sqlerrm);
  end;
commit;

  begin
    select role_id into ls_role_id_old from krim_role_t where role_nm = 'Budget Creator';
    select role_id into ls_role_id_new from krim_role_t where role_nm = 'Budget Creator Document Level';
    update krim_role_mbr_t set role_id = ls_role_id_new where role_id = ls_role_id_old;
    update document_access set role_nm = 'Budget Creator Document Level' where role_nm = 'Budget Creator';
    delete from krim_role_perm_t where role_id  = ls_role_id_old;
    delete from krim_role_t where role_id  = ls_role_id_old;
  exception
  when others then
  dbms_output.put_line('Error in Budget Creator'||sqlerrm);
  end;
commit;

  begin
    select role_id into ls_role_id_old from krim_role_t where role_nm = 'Approver';
    select role_id into ls_role_id_new from krim_role_t where role_nm = 'approver Document Level';
    update krim_role_mbr_t set role_id = ls_role_id_new where role_id = ls_role_id_old;
    update document_access set role_nm = 'approver Document Level' where role_nm = 'Approver';
    delete from krim_role_perm_t where role_id  = ls_role_id_old;
    delete from krim_role_t where role_id  = ls_role_id_old;
  exception
  when others then
  dbms_output.put_line('Error in Approver'||sqlerrm);
  end;
commit;

end;
/
delete from krim_role_perm_t
where role_id in (select role_id from krim_role_t where role_nm = 'Aggregator Document Level')
and perm_id in (select perm_id from krim_perm_t where nm ='Certify')
/
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Aggregator Document Level')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'NOTIFY_PROPOSAL_PERSONS');
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(
           ROLE_PERM_ID,
           OBJ_ID,
           VER_NBR,
           ROLE_ID,
           PERM_ID,
           ACTV_IND
            )
      VALUES(
      KRIM_ROLE_PERM_ID_S.nextval,
      sys_guid(),
      1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Aggregator Document Level'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'NOTIFY_PROPOSAL_PERSONS'),
      'Y'
      );    
    end if;

end;
/
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Investigators Document Level'))and nmspc_cd ='KC-PD')
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Certify');
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(
           ROLE_PERM_ID,
           OBJ_ID,
           VER_NBR,
           ROLE_ID,
           PERM_ID,
           ACTV_IND
            )
      VALUES(
      KRIM_ROLE_PERM_ID_S.nextval,
      sys_guid(),
      1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Investigators Document Level'))and nmspc_cd ='KC-PD'),
      (select PERM_ID from KRIM_PERM_T where nm = 'Certify'),
      'Y'
      );    
    end if;

end;
/
declare
  li_count number;
begin

    select count(role_perm_id)
    into li_count
    from KRIM_ROLE_PERM_T
    where role_id = (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Proposal Proxy certify')))
    and   PERM_ID = (select PERM_ID from KRIM_PERM_T where nm = 'Certify');
    
    if li_count = 0 then
      INSERT INTO KRIM_ROLE_PERM_T(
           ROLE_PERM_ID,
           OBJ_ID,
           VER_NBR,
           ROLE_ID,
           PERM_ID,
           ACTV_IND
            )
      VALUES(
      KRIM_ROLE_PERM_ID_S.nextval,
      sys_guid(),
      1,
      (select  ROLE_ID from KRIM_ROLE_T where trim(upper(ROLE_NM)) = trim(upper('Proposal Proxy certify'))),
      (select PERM_ID from KRIM_PERM_T where nm = 'Certify'),
      'Y'
      );    
    end if;

end;
/
commit
/
