declare
li_count NUMBER;
li_perm_id_seq KRIM_PERM_T.PERM_ID%type;
begin
select count(PERM_ID) 
into li_count 
FROM KRIM_PERM_T WHERE nm = 'NOTIFY_PROPOSAL_PERSONS' and nmspc_cd = 'KC-PD';
  if li_count = 0 then
      Insert into KRIM_PERM_T (PERM_ID,OBJ_ID,VER_NBR,PERM_TMPL_ID,NMSPC_CD,NM,DESC_TXT,ACTV_IND) 
      values (KRIM_PERM_ID_S.NEXTVAL,sys_guid(),1,'58','KC-PD','NOTIFY_PROPOSAL_PERSONS','Allows user to send person ceritification notifications','Y');
  end if;

end;
/
commit
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
commit
/