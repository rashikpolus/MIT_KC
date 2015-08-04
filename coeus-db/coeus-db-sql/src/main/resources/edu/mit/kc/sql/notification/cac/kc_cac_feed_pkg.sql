CREATE OR REPLACE package kc_cac_feed_pkg as
    FUNCTION  FN_CACapp return number;
    FUNCTION  fn_CACProcess1(    as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE)
      RETURN NUMBER;
    FUNCTION  fn_CACaccount(    as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE)
      RETURN NUMBER;
    FUNCTION  fn_CACinstProposal(    as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE)
      RETURN NUMBER;
    FUNCTION  fn_CACaward(
      as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE,
      as_award_num  in award.award_number%TYPE,
      as_award_id   in award.award_id%TYPE)
      RETURN NUMBER;
    FUNCTION  fn_CACLogInfo(
      as_WBS_IP     in CAC_DATA.WBS_IP_1%TYPE,
      as_AWARD_IP_NUMBER in CAC_LOG_DATA.AWARD_IP_NUMBER%TYPE,
      as_COMMENTS in CAC_LOG_DATA.COMMENTS%TYPE,
      as_lOG_NOTE     in CAC_LOG_DATA.lOG_NOTE%TYPE,
      as_SPREV_APPROVAL_DATE      in CAC_LOG_DATA.SPREV_APPROVAL_DATE %TYPE,
      as_AWARD_EXPIRATION_DATE     in CAC_LOG_DATA.AWARD_EXPIRATION_DATE%TYPE,
      as_LOG_INDICATOR    in CAC_LOG_DATA.LOG_INDICATOR%TYPE)
      RETURN NUMBER;       
    FUNCTION  fn_cac_a_upd_sprev(    as_WBS_IP     in CAC_DATA.WBS_IP_1%TYPE,
      as_award_num     in award.award_number%TYPE,
      as_award_id      in award.award_id%TYPE,
      as_PROTOCOL_NUMBER     in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
      RETURN NUMBER;
    FUNCTION  fn_cac_a_insert_sprev(as_WBS_IP     in CAC_DATA.WBS_IP_1%TYPE,
        as_award_num     in award.award_number%TYPE,
        as_award_id      in award.award_id%TYPE,
      as_PROTOCOL_NUMBER     in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
      RETURN NUMBER;
     FUNCTION  fn_cac_p_upd_sprev(
         as_prop_num     in CAC_DATA.WBS_IP_1%TYPE,
         as_prop_id      in proposal.proposal_id%TYPE,
      as_PROTOCOL_NUMBER     in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
      RETURN NUMBER;
    FUNCTION  fn_cac_p_insert_sprev(
        as_prop_num     in CAC_DATA.WBS_IP_1%TYPE,
        as_prop_id      in proposal.proposal_id%TYPE,
      as_PROTOCOL_NUMBER     in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
      RETURN NUMBER;
    FUNCTION FN_CAC_A_ONE_PENDING_NO_PROTO(
      as_award_id in AWARD_SPECIAL_REVIEW.AWARD_ID%type)
      RETURN NUMBER;
    FUNCTION FN_CAC_FINAL_EXPIRATION_DATE(
      AS_AWARD_ID IN award_amount_info.award_id%TYPE)
      RETURN award_amount_info.FINAL_EXPIRATION_DATE%TYPE;
    FUNCTION  FN_CAC_GET_APRDATE_IN_A_SPREV(
      AS_AWARD_ID IN award_special_review.award_id%TYPE,
      as_proto_num in AWARD_SPECIAL_REVIEW.PROTOCOL_NUMBER%type)
      RETURN award_special_review.APPROVAL_DATE%TYPE;
    FUNCTION  FN_CAC_GET_APRDATE_IN_P_SPREV(
      as_proposal_id in PROPOSAL_SPECIAL_REVIEW.PROPOSAL_ID%type,
      as_proto_num in PROPOSAL_SPECIAL_REVIEW.PROTOCOL_NUMBER%type)
        RETURN PROPOSAL_SPECIAL_REVIEW.APPROVAL_DATE%TYPE;
       FUNCTION  FN_CAC_GET_MAX_A_SPREV_NUM(
        AS_AWARD_ID IN award_special_review.award_id%TYPE )
        RETURN award_special_review.special_review_number%TYPE; 
    FUNCTION  FN_CAC_GET_MAX_P_SPREV_NUM(
        AS_PROPOSAL_ID IN proposal_special_review.proposal_id%TYPE )
        RETURN proposal_special_review.special_review_number%TYPE;         
    FUNCTION  fn_cac_get_parent_award(
        as_award_num  in award.award_number%TYPE)
        RETURN AWARD_HIERARCHY.PARENT_AWARD_NUMBER%TYPE;      
    FUNCTION  FN_CAC_IS_PROTONUM_IN_A_SPREV(
        as_proto_num in AWARD_SPECIAL_REVIEW.PROTOCOL_NUMBER%type,
      as_award_id in AWARD_SPECIAL_REVIEW.AWARD_ID%type)
      RETURN NUMBER;
    FUNCTION  FN_CAC_IS_PROTONUM_IN_P_SPREV(
        as_proto_num in PROPOSAL_SPECIAL_REVIEW.PROTOCOL_NUMBER%type,
      as_prop_id in PROPOSAL.PROPOSAL_ID%type)
      RETURN NUMBER;
    FUNCTION  FN_CAC_P_ONE_PENDING_NO_PROTO(
        as_proposal_id in PROPOSAL_SPECIAL_REVIEW.PROPOSAL_ID%type)
      RETURN NUMBER; 
    FUNCTION  fn_gen_cac_emails(
        ad_RunDate in date)
      RETURN NUMBER;
    FUNCTION  fn_gen_no_data_email RETURN NUMBER;   
      
end;
/
create or replace
package body kc_cac_feed_pkg as
  gl_APPROVAL_DATE             CAC_DATA.APPROVAL_DATE%TYPE ;
  gl_CONTACT_EMAIL            CAC_DATA.CONTACT_EMAIL%TYPE ;
  gl_DEPT                                        CAC_DATA.DEPT%TYPE ;
  gl_EXPIRATION_DATE           CAC_DATA.EXPIRATION_DATE%TYPE ;
  gl_FUNDING_AGENCY            CAC_DATA.FUNDING_AGENCY%TYPE ;
  gl_FUNDING_AGENCY2           CAC_DATA.FUNDING_AGENCY2%TYPE ;
  gl_FUNDING_AGENCY3           CAC_DATA.FUNDING_AGENCY3%TYPE ;
  gl_FUNDING_AGENCY4           CAC_DATA.FUNDING_AGENCY4%TYPE ;
  gl_FUNDING_AGENCY5           CAC_DATA.FUNDING_AGENCY5%TYPE ;
  gl_FUNDING_AGENCY6           CAC_DATA.FUNDING_AGENCY6%TYPE ;
  gl_GRANT_NUMBER              CAC_DATA.GRANT_NUMBER%TYPE ;
  gl_GRANT_NUMBER2             CAC_DATA.GRANT_NUMBER2%TYPE ;
  gl_GRANT_NUMBER3             CAC_DATA.GRANT_NUMBER3%TYPE ;
  gl_GRANT_NUMBER4             CAC_DATA.GRANT_NUMBER4%TYPE ;
  gl_GRANT_NUMBER5             CAC_DATA.GRANT_NUMBER5%TYPE ;
  gl_GRANT_NUMBER6             CAC_DATA.GRANT_NUMBER6%TYPE ;
  gl_PI_EMAIL                        CAC_DATA.PI_EMAIL%TYPE ;
  gl_PI_FIRST_NAME              CAC_DATA.PI_FIRST_NAME%TYPE ;
  gl_PI_LAST_NAME                CAC_DATA.PI_LAST_NAME%TYPE ;
  gl_PREVIOUS_PROTOCOL_NUMBER  CAC_DATA.PREVIOUS_PROTOCOL_NUMBER%TYPE ;
  gl_PROPOSAL_TYPE             CAC_DATA.PROPOSAL_TYPE%TYPE ;
  gl_PROTOCOL_NUMBER           CAC_DATA.PROTOCOL_NUMBER%TYPE ;
  gl_REVIEW_LEVEL              CAC_DATA.REVIEW_LEVEL%TYPE ;
  gl_SUBMISSION_DATE           CAC_DATA.SUBMISSION_DATE%TYPE ;
  gl_WBS_IP_1                  CAC_DATA.WBS_IP_1%TYPE ;
  gl_WBS_IP_2                  CAC_DATA.WBS_IP_2%TYPE ;
  gl_WBS_IP_3                  CAC_DATA.WBS_IP_3%TYPE ;
  gl_WBS_IP_4                  CAC_DATA.WBS_IP_4%TYPE ;
  gl_WBS_IP_5                  CAC_DATA.WBS_IP_5%TYPE ;
  gl_WBS_IP_6                  CAC_DATA.WBS_IP_6%TYPE ;

  gl_insert_a_new_row     Number := 0 ;
  gl_insert_p_new_row     Number := 0 ;
  gd_a_sprve_approval_date     AWARD_SPECIAL_REVIEW.APPROVAL_DATE%TYPE;
  gd_p_sprve_approval_date     PROPOSAL_SPECIAL_REVIEW.APPROVAL_DATE%TYPE;
  gl_a_appear_in_sprev Number;
  gl_p_appear_in_sprev Number;

  gl_a_sprev_count  Number :=0;
  gl_p_sprev_count  Number :=0;


/***********************************************/
FUNCTION  FN_CACapp RETURN NUMBER IS
/***********************************************/

     ll_ret Number := 0;
     ll_cac_data_rows Number := 0;

BEGIN
  select count(protocol_number)
  into ll_cac_data_rows
  from cac_data;

  if ll_cac_data_rows >0 then
    DECLARE CURSOR C_CAC_DATA IS
    SELECT
      APPROVAL_DATE,
      CONTACT_EMAIL,
      DEPT,
      EXPIRATION_DATE ,
      FUNDING_AGENCY,
      FUNDING_AGENCY2,
      FUNDING_AGENCY3,
      FUNDING_AGENCY4,
      FUNDING_AGENCY5,
      FUNDING_AGENCY6,
      GRANT_NUMBER,
      GRANT_NUMBER2,
      GRANT_NUMBER3 ,
      GRANT_NUMBER4,
      GRANT_NUMBER5,
      GRANT_NUMBER6 ,
      PI_EMAIL,
      PI_FIRST_NAME,
      PI_LAST_NAME,
      PREVIOUS_PROTOCOL_NUMBER ,
      PROPOSAL_TYPE ,
      PROTOCOL_NUMBER ,
      REVIEW_LEVEL ,
      SUBMISSION_DATE,
      WBS_IP_1,
      WBS_IP_2,
      WBS_IP_3,
      WBS_IP_4,
      WBS_IP_5,
      WBS_IP_6
    FROM CAC_DATA;

    BEGIN
      OPEN C_CAC_DATA;
        LOOP
        FETCH C_CAC_DATA
        INTO  gl_APPROVAL_DATE,
              gl_CONTACT_EMAIL,
              gl_DEPT,
              gl_EXPIRATION_DATE ,
              gl_FUNDING_AGENCY,
              gl_FUNDING_AGENCY2,
              gl_FUNDING_AGENCY3,
              gl_FUNDING_AGENCY4,
              gl_FUNDING_AGENCY5,
              gl_FUNDING_AGENCY6,
              gl_GRANT_NUMBER,
              gl_GRANT_NUMBER2,
              gl_GRANT_NUMBER3 ,
              gl_GRANT_NUMBER4,
              gl_GRANT_NUMBER5,
              gl_GRANT_NUMBER6 ,
              gl_PI_EMAIL,
              gl_PI_FIRST_NAME,
              gl_PI_LAST_NAME,
              gl_PREVIOUS_PROTOCOL_NUMBER ,
              gl_PROPOSAL_TYPE ,
              gl_PROTOCOL_NUMBER ,
              gl_REVIEW_LEVEL ,
              gl_SUBMISSION_DATE,
              gl_WBS_IP_1,
              gl_WBS_IP_2,
              gl_WBS_IP_3,
              gl_WBS_IP_4,
              gl_WBS_IP_5,
              gl_WBS_IP_6;

             EXIT WHEN C_CAC_DATA%NOTFOUND;
        if gl_FUNDING_AGENCY  IS NOT NULL and  lower(gl_FUNDING_AGENCY) = 'see attached'  then
          dbms_output.put_line('When see attached is in the first Funding Agency column.');
          ll_ret := fn_CACLogInfo('','','see attached is in the first Funding Agency column.','CAC','','','');
        else

            if gl_WBS_IP_1 IS NOT NULL  then
              dbms_output.put_line('Grant Number1 in Data File: ' || gl_WBS_IP_1);
              ll_ret := fn_CACProcess1(gl_WBS_IP_1);
            end if;

            if gl_WBS_IP_2 IS NOT NULL  then
              dbms_output.put_line('Grant Number2 in Data File: ' || gl_WBS_IP_2);
              ll_ret := fn_CACProcess1(gl_WBS_IP_2);
            end if;

            if gl_WBS_IP_3 IS NOT NULL  then
              dbms_output.put_line('Grant Number3 in Data File: ' || gl_WBS_IP_3);
              ll_ret := fn_CACProcess1(gl_WBS_IP_3);
            end if;

            if gl_WBS_IP_4 IS NOT NULL  then
              dbms_output.put_line('Grant Number4 in Data File: ' || gl_WBS_IP_4);
              ll_ret := fn_CACProcess1(gl_WBS_IP_4);
            end if;

             if gl_WBS_IP_5 IS NOT NULL  then
              dbms_output.put_line('Grant Number5 in Data File: ' || gl_WBS_IP_5);
              ll_ret := fn_CACProcess1(gl_WBS_IP_5);

            end if;
            if gl_WBS_IP_6 IS NOT NULL  then
              dbms_output.put_line('Grant Number6 in Data File: ' || gl_WBS_IP_6);
              ll_ret := fn_CACProcess1(gl_WBS_IP_6);
            end if;

        end if;
        END LOOP;
          dbms_output.put_line('finished in fn_cacapp');
      CLOSE C_CAC_DATA;
      --send email
      ll_ret := fn_gen_cac_emails(sysdate);
    END;
  else
    ll_ret := fn_gen_no_data_email();
    --dbms_output.put_line('finished in fn_cacapp no data');
  end if;

return 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('EXCEPTION in fn_cacapp');
    return -1;
END;


/******************************************************************************/
FUNCTION  fn_CACProcess1(
    as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE)
  RETURN NUMBER IS
/******************************************************************************/
ll_ret Number;
--ll_start_pos Number := 1;
ll_pos Number := 0;

--ll_appearance Number := 1;
--ll_wbs_ip_num CAC_DATA.WBS_IP_1%TYPE := as_WBS_IP ;

begin
  if (LENGTH(TRIM(TRANSLATE(as_WBS_IP, '0123456789', ' ')))) is Null then
      if LENGTH(TRIM(as_WBS_IP)) = 7 then -- account number
        ll_ret := fn_CACaccount(as_WBS_IP);
      elsif LENGTH(TRIM(as_WBS_IP)) = 8 then -- institutle proposal number
        ll_ret := fn_CACinstProposal(as_WBS_IP);
      else
       --log to the table with 'invalid WBS number/Institute Proposal number'
       dbms_output.put_line('invalid WBS number/Institute Proposal number');
       ll_ret := fn_CACLogInfo(as_WBS_IP,'','Invalid WBS number/Institute Proposal number','CAC','','','');
      end if;
  else
    --log to the table with 'invalid WBS number/Institute Proposal number'
       dbms_output.put_line('invalid WBS number/Institute Proposal number');
       ll_ret := fn_CACLogInfo(as_WBS_IP,'','Invalid WBS number/Institute Proposal number','CAC','','','');

  end if;

  return ll_ret;

end;

/******************************************************************************/
FUNCTION  fn_CACaccount(
    as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE)
  RETURN NUMBER IS
/******************************************************************************/

ll_ret Number;
ll_wbs_ip_num CAC_DATA.WBS_IP_1%TYPE := as_WBS_IP ;
ll_comments            varchar2(900);
ll_count         Number;
ll_award_num  award.award_number%TYPE;
ll_award_id  award.award_id%TYPE;
ll_protocol_num CAC_DATA.PROTOCOL_NUMBER%TYPE := gl_PROTOCOL_NUMBER;
begin
  select count(*)
    into   ll_count
    from award where (trim(account_number)  = trim(ll_wbs_ip_num))
         and AWARD_SEQUENCE_STATUS = 'ACTIVE';

  if ll_count = 1 then
        DECLARE cursor c_award_num is
            select  award_number,sponsor_award_number,account_number,award_id
          from award
          where (trim(account_number)  = trim(ll_wbs_ip_num))
          and AWARD_SEQUENCE_STATUS = 'ACTIVE';
          
    begin
      for award_number in c_award_num
      loop
        ll_award_num := award_number.award_number;
        ll_award_id := award_number.award_id;
        if gl_APPROVAL_DATE is NOT NULL then
          loop
          ll_ret := fn_CACaward( as_WBS_IP, ll_award_num,ll_award_id);

          if ( ll_ret = 1 ) then

                ll_award_num := fn_cac_get_parent_award(ll_award_num);
                ll_award_id := 0;

                    exit when (SUBSTR(ll_award_num, 8,5) = '00000' );
          else

            exit;

          end if;
	    if ll_award_id = 0 then
		select  award_id
		into ll_award_id
		from award
		where award_number = ll_award_num
		  and AWARD_SEQUENCE_STATUS = 'ACTIVE';
	    end if;
          end loop;
        --else
          --approval date is null
          --ll_comments := 'Approval date is null.';
          --insert...
        end if;

      end loop;
    end;

  elsif ll_count > 1 then
  --find duplocate awards.  Duplicate account nos. found associated different MIT award nos. - CAC
    ll_comments := 'Duplicate account nos. found associated different MIT award nos.' ;
    ll_ret := fn_CACLogInfo(as_WBS_IP,'',ll_comments,'CAC','','','');
    --insert ...
  else
  --no match found, is invalid WBS number log with 'Invalid WBS number'
     ll_comments := 'Invalid WBS number.';
     ll_ret := fn_CACLogInfo(as_WBS_IP,'',ll_comments,'CAC','','','');
    --insert
  end if;
  dbms_output.put_line('fn_CACaccount' ||as_WBS_IP);
  return 1;
end;

/******************************************************************************/
FUNCTION  fn_CACinstProposal(
  as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE)
  RETURN NUMBER IS
/******************************************************************************/
--ll_appear_in_prop_sprev Number;
ll_award_num  award.award_number%TYPE;
ll_award_id  award.award_id%TYPE;
ll_proposal_id  proposal.proposal_id%TYPE;
ll_funded_prop Number;
ll_comments            varchar2(900);
ll_count     Number;
ll_one_blank_in_sprev Number;
ll_protocol_num CAC_DATA.PROTOCOL_NUMBER%TYPE := gl_PROTOCOL_NUMBER;
ll_ret Number;
ll_status proposal.status_code%TYPE;

begin
  --find ip in proposal table
  select count( distinct proposal_number )
  into ll_count
  from proposal
  where proposal_number =trim(as_WBS_IP);

  if ll_count = 1 then --this institute proposal is in coeus
    --DECLARE cursor c_ip_num is
          select  STATUS_CODE, proposal_id
          into ll_status,ll_proposal_id
          from proposal
          where (trim(proposal_number)  = trim(as_WBS_IP))
          and PROPOSAL_SEQUENCE_STATUS = 'ACTIVE';

        select  COUNT(*)
	    into gl_p_sprev_count
	    from PROPOSAL_SPECIAL_REVIEW
        where PROPOSAL_id  = ll_proposal_id;

    --begin
      --for proposal_number in c_ip_num
      --loop
    --update institute proposal record: Check if protocol is listed in proposal special review
    if  (gl_p_sprev_count > 0 ) then
        gl_p_appear_in_sprev := FN_CAC_IS_PROTONUM_IN_P_SPREV(gl_PROTOCOL_NUMBER,ll_proposal_id);
        dbms_output.put_line('--protocol in prop sprev --' || gl_p_appear_in_sprev);
        if gl_p_appear_in_sprev > 1 then
        --the proposal contains multiple rows with the same protocol number, throw an exception.
          ll_comments := 'Multiple rows in a proposal with same protocol no.';
          ll_ret := fn_CACLogInfo(as_WBS_IP,'',ll_comments,'OSP','','','');
          --insert...
        else
          gd_p_sprve_approval_date := null;
          if gl_p_appear_in_sprev = 0 then
          --check if the proposal contains one (and only one) pending/Delayed Requirement animal usage special review (wiht no protocol num)
            ll_one_blank_in_sprev := FN_CAC_P_ONE_PENDING_NO_PROTO(ll_proposal_id);
            if ll_one_blank_in_sprev = 1 then
              ll_protocol_num := null;
            end if;
          end if;

          if gl_p_appear_in_sprev = 1 or ll_one_blank_in_sprev = 1 then
           --update the protocol
            --ll_comments := 'Institute proposal special review updated.';
            --li_ret := fn_CACLogInfo(as_prop_num,as_prop_num,ll_comments,'',gd_p_sprve_approval_date,'','U');
            gl_p_appear_in_sprev := 1;
            ll_ret := fn_cac_p_upd_sprev(as_WBS_IP,ll_proposal_id, ll_protocol_num);

          else
            --insert the protocol
            if ll_one_blank_in_sprev > 1 then
                ll_comments := 'Institute proposal special review inserted.';
                ll_ret := fn_CACLogInfo(as_WBS_IP,ll_protocol_num,ll_comments,'','','','I');
            else
                ll_comments := 'CAC approved protocol inserted where no pending special review existed prior.';
                ll_ret := fn_CACLogInfo(as_WBS_IP,ll_protocol_num,ll_comments,'OSP','','','I');
            end if;

            ll_ret := fn_cac_p_insert_sprev(as_WBS_IP, ll_proposal_id, ll_protocol_num);
          end if;

        end if;
    else
        ll_comments := 'CAC approved protocol inserted where no pending special review existed prior.';
        ll_ret := fn_CACLogInfo(as_WBS_IP,ll_protocol_num,ll_comments,'OSP','','','I');
        ll_ret := fn_cac_p_insert_sprev(as_WBS_IP,ll_proposal_id, ll_protocol_num);
    end if;
   -- end if;
  --    end loop;
  --  end ;--begin
    --check institute proposal is linked to award (institute proposal status is funded) or not
    if ll_status = 2 then
      select count( distinct substr( award_number,1,6) )
      into ll_funded_prop
      from award
      where award_id in (select award_id from award_funding_proposals
                        where PROPOSAL_ID in (select proposal_id from proposal where proposal_number = trim(as_WBS_IP)and PROPOSAL_SEQUENCE_STATUS <> 'PENDING' and PROPOSAL_SEQUENCE_STATUS <> 'CANCELED'))
              and (AWARD_SEQUENCE_STATUS <> 'PENDING' and AWARD_SEQUENCE_STATUS <> 'CANCELED');
      if ll_funded_prop = 1 then
        select  distinct substr( award_number,1,6)
        into ll_award_num
        from award
        where award_id in (select award_id from award_funding_proposals
                        where PROPOSAL_ID in (select proposal_id from proposal where proposal_number = trim(as_WBS_IP)and PROPOSAL_SEQUENCE_STATUS <> 'PENDING'and PROPOSAL_SEQUENCE_STATUS <> 'CANCELED'))
              and (AWARD_SEQUENCE_STATUS <> 'PENDING' and AWARD_SEQUENCE_STATUS <> 'CANCELED');

        ll_award_num := ll_award_num || '-00001' ;

        select award_id
        into ll_award_id
        from award
        where award_number = ll_award_num
            and AWARD_SEQUENCE_STATUS = 'ACTIVE';
            
        ll_ret := fn_CACaward( as_WBS_IP, ll_award_num,ll_award_id);


      elsif ll_funded_prop > 1 then
      --Institute proposals linked to multiple awards, not in the same award hierarchy - OSP
      ll_comments := 'Institute proposals linked to multiple awards, not in the same award hierarchy. ';
      dbms_output.put_line('--Institute proposals linked to multiple awards, not in the same award hierarchy - OSP --' || as_WBS_IP);
      --ll_ret := fn_CACLogInfo(as_WBS_IP,'',ll_comments,'OSP','','','8');
      ll_ret := fn_CACLogInfo(as_WBS_IP,'',ll_comments,'CAC','','','');
      --insert
      else
      --not linked to award with funded proposal, should not happen
      dbms_output.put_line('--funded IP but not in award --' || as_WBS_IP);
      end if;
    end if;
  else
  --no match found, is invalid institute propopal number log with 'Invalid ip number'
    ll_comments := 'Invalid Institute Proposal number.';
    --insert
    dbms_output.put_line('--ip is not in coeus--' ||as_WBS_IP);
    ll_ret := fn_CACLogInfo(as_WBS_IP,'',ll_comments,'CAC','','','');
  end if;

return 1;

end;



/******************************************************************************/
FUNCTION  fn_CACaward(
  as_WBS_IP in CAC_DATA.WBS_IP_1%TYPE,
  as_award_num  in award.award_number%TYPE,
  as_award_id in award.award_id%TYPE)
  RETURN NUMBER IS
/******************************************************************************/
--ll_award_num  award.award_number%TYPE;
--ll_appear_in_prop_sprev Number;
ll_comments      varchar2(900);
--ll_count     Number;
ld_FINAL_EXPIRATION_DATE         award_amount_info.FINAL_EXPIRATION_DATE%TYPE;
ll_one_blank_in_sprev Number;
ll_protocol_num CAC_DATA.PROTOCOL_NUMBER%TYPE := gl_PROTOCOL_NUMBER;
ll_ret Number;
ll_award_ret Number := 1;
begin
  --get special_review_count
  select  COUNT(*)
  into gl_a_sprev_count
  from AWARD_SPECIAL_REVIEW
      where AWARD_id  = as_award_id;


  gd_a_sprve_approval_date := null;
  ld_FINAL_EXPIRATION_DATE := FN_CAC_FINAL_EXPIRATION_DATE(as_award_id);
          --Check if the Final Expiration date of the award is prior to the protocol approval date
         -- if (to_date(ld_FINAL_EXPIRATION_DATE,'mm/dd/yyyy') >= to_date(gl_APPROVAL_DATE,'mm/dd/yyyy')) then
        if (ld_FINAL_EXPIRATION_DATE >= to_date(gl_APPROVAL_DATE,'mm/dd/yyyy')) then
          --check special review indicator
          if   (gl_a_sprev_count > 0 ) then
          -- has special review...
            --Check if protocol is listed in special review of the award
            gl_a_appear_in_sprev := FN_CAC_IS_PROTONUM_IN_A_SPREV(gl_PROTOCOL_NUMBER,as_award_id);
            dbms_output.put_line('--gl_a_appear_in_sprev--' ||gl_a_appear_in_sprev);
            if gl_a_appear_in_sprev > 1 then
              --the award contains multiple rows with the same protocol number, throw an exception.
              ll_comments := 'Multiple rows in an award with same protocol no.';
              ll_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'OSP','','','');
            else
              if gl_a_appear_in_sprev = 0 then
            --check if the award contains one (and only one) pending/Delayed Requirement animal usage special review (with no protocol num)
                ll_one_blank_in_sprev := FN_CAC_A_ONE_PENDING_NO_PROTO(as_award_id);
                if ll_one_blank_in_sprev = 1 then
                  ll_protocol_num := null;
                end if;
              end if;


              if gl_a_appear_in_sprev = 1 or ll_one_blank_in_sprev = 1 then
              --update the protocol
                --ll_comments := 'Award special review updated.';
                --li_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'',gd_a_sprve_approval_date,'','U');
                gl_a_appear_in_sprev := 1;
                ll_ret := fn_cac_a_upd_sprev(as_WBS_IP,as_award_num, as_award_id, ll_protocol_num);

              else
              --insert the protocol
                if ll_one_blank_in_sprev > 1 then
                    ll_comments := 'Award special review inserted.';
                    ll_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'','','','I');
                else
                    ll_comments := 'CAC approved protocol inserted where no pending special review existed prior.';
                    ll_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'OSP','','','I');
                end if;
                ll_ret := fn_cac_a_insert_sprev(as_WBS_IP,as_award_num, as_award_id, ll_protocol_num);
              end if;


            end if;
          else
          -- no special review
            ll_comments := 'CAC approved protocol inserted where no pending special review existed prior.';
            ll_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'OSP','','','I');
            ll_ret := fn_cac_a_insert_sprev(as_WBS_IP,as_award_num, as_award_id, ll_protocol_num);
          end if;
        else
          --the final expiration date is prior to the protocol approval date
            ll_comments := 'The final expiration date is prior to the protocol approval date.';
            --ll_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'OSP','',ld_FINAL_EXPIRATION_DATE,'3');
            ll_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'CAC','',ld_FINAL_EXPIRATION_DATE,'');
            ll_award_ret := -1;
            --insert...
        end if;
 return ll_award_ret;
end;


/******************************************************************************/
FUNCTION  fn_CACLogInfo(
  as_WBS_IP     in CAC_DATA.WBS_IP_1%TYPE,
  as_AWARD_IP_NUMBER in CAC_LOG_DATA.AWARD_IP_NUMBER%TYPE,
  as_COMMENTS in CAC_LOG_DATA.COMMENTS%TYPE,
  as_lOG_NOTE     in CAC_LOG_DATA.lOG_NOTE%TYPE,
  as_SPREV_APPROVAL_DATE      in CAC_LOG_DATA.SPREV_APPROVAL_DATE %TYPE,
  as_AWARD_EXPIRATION_DATE     in CAC_LOG_DATA.AWARD_EXPIRATION_DATE%TYPE,
  as_LOG_INDICATOR    in CAC_LOG_DATA.LOG_INDICATOR%TYPE)
  RETURN NUMBER IS
/******************************************************************************/
begin
    INSERT INTO CAC_LOG_DATA
    ( CAC_LOG_DATA_ID,
      PROTOCOL_NUMBER_CAC,
      AWARD_IP_NUMBER,
      WBS_IP_CAC,
      COMMENTS,
      lOG_NOTE,
      SPREV_APPROVAL_DATE,
      AWARD_EXPIRATION_DATE,
      SUBMISSION_DATE_CAC,
      APPROVAL_DATE_CAC,
      LOG_INDICATOR,
      UPDATE_TIMESTAMP,
      VER_NBR,
      OBJ_ID)
    VALUES (SEQ_CAC_LOG_DATA_ID.NEXTVAL,
       gl_PROTOCOL_NUMBER,
       as_AWARD_IP_NUMBER,
       as_WBS_IP,
       as_COMMENTS,
       as_lOG_NOTE,
       as_SPREV_APPROVAL_DATE,
       as_AWARD_EXPIRATION_DATE,
       gl_SUBMISSION_DATE,
       gl_APPROVAL_DATE,
       as_LOG_INDICATOR,
       sysdate,
       1,
       SYS_GUID());
  return 1;
end;


/******************************************************************************/
FUNCTION  fn_cac_a_upd_sprev(
  as_WBS_IP     in CAC_DATA.WBS_IP_1%TYPE,
  as_award_num  in award.award_number%TYPE,
  as_award_id     in award.award_id%TYPE,
  as_PROTOCOL_NUMBER        in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
 RETURN NUMBER IS
/******************************************************************************/
li_ret Number;
ll_comments            varchar2(900);

begin
   gd_a_sprve_approval_date := FN_CAC_GET_APRDATE_IN_A_SPREV(as_award_id,as_PROTOCOL_NUMBER);

  if (gd_a_sprve_approval_date is null) or ( to_date(gl_APPROVAL_DATE,'mm/dd/yyyy')  > gd_a_sprve_approval_date) then
      if as_PROTOCOL_NUMBER is null then
        select comments
        into ll_comments
        from award_special_review
        where AWARD_ID = as_award_id
          AND PROTOCOL_NUMBER is null
          AND SPECIAL_REVIEW_CODE = 2;
          --AND SPECIAL_REVIEW_CODE = 2 and (APPROVAL_TYPE_CODE = 1 or APPROVAL_TYPE_CODE = 6 ); ????
      else
        select comments
        into ll_comments
        from award_special_review
        where AWARD_ID = as_award_id
          AND PROTOCOL_NUMBER = trim(as_PROTOCOL_NUMBER)
          AND SPECIAL_REVIEW_CODE = 2;

      end if;
      if ll_comments is null then
        ll_comments := 'Updated the approval date ' || gd_a_sprve_approval_date || ' thru CAC data feed on ' || to_char(sysdate, 'mm/dd/yyyy');
      else
        ll_comments := ll_comments ||' Updated the approval date ' || gd_a_sprve_approval_date || ' thru CAC data feed on ' || to_char(sysdate, 'mm/dd/yyyy');
      end if;
      if as_PROTOCOL_NUMBER is null then
        update award_special_review
        set approval_date = to_date(gl_APPROVAL_DATE,'mm/dd/yyyy'),
                    APPLICATION_DATE = to_date(gl_SUBMISSION_DATE,'mm/dd/yyyy'),
                    approval_type_code = 2,
                    PROTOCOL_NUMBER = gl_PROTOCOL_NUMBER,
                    comments = ll_comments
        where AWARD_ID = as_award_id
            AND PROTOCOL_NUMBER is null
            AND SPECIAL_REVIEW_CODE = 2;
            --AND SPECIAL_REVIEW_CODE = 2 and (APPROVAL_TYPE_CODE = 1 or APPROVAL_TYPE_CODE = 6 );???
      else
        update award_special_review
        set approval_date = to_date(gl_APPROVAL_DATE,'mm/dd/yyyy'),
                    APPLICATION_DATE = to_date(gl_SUBMISSION_DATE,'mm/dd/yyyy'),
                    approval_type_code = 2,
                    comments = ll_comments
        where AWARD_ID = as_award_id
            AND PROTOCOL_NUMBER = trim(as_PROTOCOL_NUMBER)
            AND SPECIAL_REVIEW_CODE = 2;

      end if;
      ll_comments := 'Award special review updated.';
      li_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'',gd_a_sprve_approval_date,'','U');

  elsif to_date(gl_APPROVAL_DATE,'mm/dd/yyyy')  <  gd_a_sprve_approval_date then
  --protocol exists in Coeus -- award  specail review and Approval Date in the CAC feed is earlier than the date in the award record in Coeus.
  dbms_output.put_line('approval date in coeus ' ||gd_a_sprve_approval_date);
  ll_comments := 'Protocol exists in Coeus and Approval Date in the CAC feed is earlier than the date in the award record in Coeus.';
  li_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'OSP',gd_a_sprve_approval_date,'','');
  --else -- same date
  --ll_comments := 'Protocol exists in Coeus and Approval Date in the CAC feed is same as the date in the award record in Coeus.';
  --li_ret := fn_CACLogInfo(as_WBS_IP,as_award_num,ll_comments,'REP',gd_a_sprve_approval_date,'','3');
  --insert
  end if;

            dbms_output.put_line('fn_cac_upd_sprev' ||as_award_num);
  return 1;
end;

/******************************************************************************/
FUNCTION  fn_cac_a_insert_sprev(
  as_WBS_IP     in CAC_DATA.WBS_IP_1%TYPE,
  as_award_num     in award.award_number%TYPE,
  as_award_id     in award.award_id%TYPE,
  as_PROTOCOL_NUMBER        in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
 RETURN NUMBER IS
/******************************************************************************/
ll_comments            varchar2(900);
ll_next_special_rev_num Number;
ll_AWARD_SPECIAL_REVIEW_ID   AWARD_SPECIAL_REVIEW.AWARD_SPECIAL_REVIEW_ID%TYPE;
ll_SPECIAL_REVIEW_NUMBER     AWARD_SPECIAL_REVIEW.SPECIAL_REVIEW_NUMBER%TYPE;
ll_SPECIAL_REVIEW_CODE       AWARD_SPECIAL_REVIEW.SPECIAL_REVIEW_CODE%TYPE;
ll_APPROVAL_TYPE_CODE        AWARD_SPECIAL_REVIEW.APPROVAL_TYPE_CODE%TYPE;
ll_PROTOCOL_NUMBER           AWARD_SPECIAL_REVIEW.PROTOCOL_NUMBER%TYPE;
ld_APP_DATE                  AWARD_SPECIAL_REVIEW.APPLICATION_DATE%TYPE;
ld_APPROVAL_DATE             AWARD_SPECIAL_REVIEW.APPROVAL_DATE%TYPE;
ll_COMMENTS_SP               AWARD_SPECIAL_REVIEW.COMMENTS%TYPE;
li_ret Number;
begin

  ll_next_special_rev_num := FN_CAC_GET_MAX_A_SPREV_NUM(as_award_id);

  if ll_next_special_rev_num > 0 then
        ll_next_special_rev_num := ll_next_special_rev_num + 1;
  else
        ll_next_special_rev_num := 1;
  end if;
  INSERT INTO AWARD_SPECIAL_REVIEW
            (EXPIRATION_DATE,
            AWARD_SPECIAL_REVIEW_ID,
            AWARD_ID,
            VER_NBR,
            SPECIAL_REVIEW_NUMBER,
            SPECIAL_REVIEW_CODE,
            APPROVAL_TYPE_CODE,
            PROTOCOL_NUMBER,
            APPLICATION_DATE,
            APPROVAL_DATE,
            UPDATE_USER,
            UPDATE_TIMESTAMP,
            OBJ_ID,
            COMMENTS)
          VALUES(NULL,
            SEQ_AWARD_SPECIAL_REVIEW_ID.NEXTVAL,
            as_award_id,
            1,
            ll_next_special_rev_num ,
            2,
            2,
            trim(gl_PROTOCOL_NUMBER),
            to_date(gl_SUBMISSION_DATE,'mm/dd/yyyy'),
            to_date(gl_APPROVAL_DATE,'mm/dd/yyyy'),
            user,
            SYSDATE,
            SYS_GUID(),
            'Inserted thru CAC data feed on ' || to_char(sysdate, 'mm/dd/yyyy'));

  dbms_output.put_line('fn_cac_insert_sprev' ||as_award_num);
  return 1;
end;

/******************************************************************************/
FUNCTION  fn_cac_p_upd_sprev(
    as_prop_num     in CAC_DATA.WBS_IP_1%TYPE,
    as_prop_id      in proposal.proposal_id%TYPE,
  as_PROTOCOL_NUMBER        in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
 RETURN NUMBER IS
/******************************************************************************/
li_ret Number;
ll_comments            varchar2(900);

begin
  gd_p_sprve_approval_date := FN_CAC_GET_APRDATE_IN_P_SPREV(as_prop_id,as_PROTOCOL_NUMBER);

  if (gd_p_sprve_approval_date is null) or ( to_date(gl_APPROVAL_DATE,'mm/dd/yyyy')  > gd_p_sprve_approval_date) then
      if as_PROTOCOL_NUMBER is null then
        select comments
        into ll_comments
        from proposal_special_review
        where PROPOSAL_ID = as_prop_id
          AND PROTOCOL_NUMBER is null
          AND SPECIAL_REVIEW_CODE = 2;
      else
        select comments
        into ll_comments
        from proposal_special_review
        where PROPOSAL_ID = as_prop_id
          AND PROTOCOL_NUMBER = trim(as_PROTOCOL_NUMBER)
          AND SPECIAL_REVIEW_CODE = 2;
      end if;
      if ll_comments is null then
        ll_comments := 'Updated the approval date ' || gd_p_sprve_approval_date || ' thru CAC data feed on ' || to_char(sysdate, 'mm/dd/yyyy');
      else
        ll_comments := ll_comments ||' Updated the approval date ' || gd_p_sprve_approval_date || ' thru CAC data feed on ' || to_char(sysdate, 'mm/dd/yyyy');
      end if;

      if as_PROTOCOL_NUMBER is null then
        update proposal_special_review
        set approval_date = to_date(gl_APPROVAL_DATE,'mm/dd/yyyy'),
                    APPLICATION_DATE = to_date(gl_SUBMISSION_DATE,'mm/dd/yyyy'),
                    approval_type_code = 2,
                    PROTOCOL_NUMBER = gl_PROTOCOL_NUMBER,
                    comments = ll_comments
        where PROPOSAL_ID = as_prop_id
            AND PROTOCOL_NUMBER is null
            AND SPECIAL_REVIEW_CODE = 2;
      else
        update proposal_special_review
        set approval_date = to_date(gl_APPROVAL_DATE,'mm/dd/yyyy'),
                    APPLICATION_DATE = to_date(gl_SUBMISSION_DATE,'mm/dd/yyyy'),
                    approval_type_code = 2,
                    comments = ll_comments
        where PROPOSAL_ID = as_prop_id
            AND PROTOCOL_NUMBER = trim(as_PROTOCOL_NUMBER)
            AND SPECIAL_REVIEW_CODE = 2;

      end if;

      ll_comments := 'Institute proposal special review updated.';
      li_ret := fn_CACLogInfo(as_prop_num,as_prop_num,ll_comments,'',gd_p_sprve_approval_date,'','U');


  elsif to_date(gl_APPROVAL_DATE,'mm/dd/yyyy')  <  gd_p_sprve_approval_date then
  --protocol exists in Coeus -- proposal specail review and Approval Date in the CAC feed is earlier than the date in the award record in Coeus.
    dbms_output.put_line('approval date in coeus ' ||gd_p_sprve_approval_date);
    ll_comments := 'Protocol exists in Coeus and Approval Date in the CAC feed is earlier than the date in the institute proposal record in Coeus.';
    li_ret := fn_CACLogInfo(as_prop_num,as_prop_num,ll_comments,'OSP',gd_p_sprve_approval_date,'','');
  --else -- same date
  --ll_comments := 'Protocol exists in Coeus and Approval Date in the CAC feed is same as the date in the institute proposal record in Coeus.';
  --li_ret := fn_CACLogInfo(as_prop_num,as_prop_num,ll_comments,'REP',gd_p_sprve_approval_date,'','4');
  --insert
  end if;
            dbms_output.put_line('fn_cac_p_upd_sprev' ||as_prop_num);
  return 1 ;
end;

/******************************************************************************/
FUNCTION  fn_cac_p_insert_sprev(
    as_prop_num     in CAC_DATA.WBS_IP_1%TYPE,
    as_prop_id      in proposal.proposal_id%TYPE,
  as_PROTOCOL_NUMBER        in  CAC_DATA.PROTOCOL_NUMBER%TYPE)
 RETURN NUMBER IS
/******************************************************************************/
ll_comments            varchar2(900);
ll_next_special_rev_num Number;
ll_PROPOSAL_SPECIAL_REVIEW_ID  PROPOSAL_SPECIAL_REVIEW.PROPOSAL_SPECIAL_REVIEW_ID%TYPE;
ll_SPECIAL_REVIEW_NUMBER     PROPOSAL_SPECIAL_REVIEW.SPECIAL_REVIEW_NUMBER%TYPE;
ll_SPECIAL_REVIEW_CODE     PROPOSAL_SPECIAL_REVIEW.SPECIAL_REVIEW_CODE%TYPE;
ll_APPROVAL_TYPE_CODE         PROPOSAL_SPECIAL_REVIEW.APPROVAL_TYPE_CODE%TYPE;
ll_PROTOCOL_NUMBER         PROPOSAL_SPECIAL_REVIEW.PROTOCOL_NUMBER%TYPE;
ld_APP_DATE             PROPOSAL_SPECIAL_REVIEW.APPLICATION_DATE%TYPE;
ld_APPROVAL_DATE         PROPOSAL_SPECIAL_REVIEW.APPROVAL_DATE%TYPE;
ll_COMMENTS_SP            PROPOSAL_SPECIAL_REVIEW.COMMENTS%TYPE;
li_ret Number;
begin

ll_next_special_rev_num := FN_CAC_GET_MAX_P_SPREV_NUM(as_prop_id);
 if ll_next_special_rev_num > 0 then
        ll_next_special_rev_num := ll_next_special_rev_num + 1;
 else
        ll_next_special_rev_num := 1;
 end if;

       ---insert one matched new row to award special review table
   INSERT INTO PROPOSAL_SPECIAL_REVIEW
            ( EXPIRATION_DATE,
            PROPOSAL_SPECIAL_REVIEW_ID,
            PROPOSAL_ID,
            VER_NBR,
            SPECIAL_REVIEW_NUMBER,
            SPECIAL_REVIEW_CODE,
            APPROVAL_TYPE_CODE,
            PROTOCOL_NUMBER,
            APPLICATION_DATE,
            APPROVAL_DATE,
            UPDATE_USER,
            UPDATE_TIMESTAMP,
            OBJ_ID,
            COMMENTS)
         VALUES (
            NULL,
            SEQ_PROPOSAL_SPECIAL_REVIEW_ID.NEXTVAL,
            as_prop_id,
            1,
            ll_next_special_rev_num ,
            2     ,
            2,
            trim(gl_PROTOCOL_NUMBER),
            to_date(gl_SUBMISSION_DATE,'mm/dd/yyyy'),
            to_date(gl_APPROVAL_DATE,'mm/dd/yyyy'),
            user,
            SYSDATE,
            SYS_GUID(),
            'Inserted thru CAC data feed on ' || to_char(sysdate, 'mm/dd/yyyy')
            );

   dbms_output.put_line('fn_cac_p_insert_sprev' ||as_prop_num);
  return 1;
end;

/******************************************************************************/
FUNCTION FN_CAC_A_ONE_PENDING_NO_PROTO(
      as_award_id in  AWARD_SPECIAL_REVIEW.AWARD_ID%type)
      RETURN NUMBER IS
/******************************************************************************/
ll_count     Number;

BEGIN
    SELECT COUNT(*)
    INTO ll_count
    FROM AWARD_SPECIAL_REVIEW
    WHERE AWARD_ID = as_award_id
    AND SPECIAL_REVIEW_CODE = 2 and (APPROVAL_TYPE_CODE = 1 or APPROVAL_TYPE_CODE = 6 );

    IF ll_count = 1 THEN
    SELECT COUNT(*)
    INTO ll_count
    FROM AWARD_SPECIAL_REVIEW
    WHERE AWARD_ID = as_award_id
    AND SPECIAL_REVIEW_CODE = 2 and (APPROVAL_TYPE_CODE = 1 or APPROVAL_TYPE_CODE = 6 )
    AND (PROTOCOL_NUMBER is null or trim(PROTOCOL_NUMBER) = '');

    if ll_count = 1 then
      return 1;
    else
      return 2;
    end if;

    ELSE
        RETURN ll_count;
    END IF;

    EXCEPTION
          WHEN NO_DATA_FOUND THEN
    RETURN 0;

END ;

/******************************************************************************/
FUNCTION FN_CAC_FINAL_EXPIRATION_DATE(
      AS_AWARD_ID IN award_amount_info.award_id%TYPE)
      RETURN award_amount_info.FINAL_EXPIRATION_DATE%TYPE IS
/******************************************************************************/
ld_final_expiration_date award_amount_info.FINAL_EXPIRATION_DATE%TYPE;
BEGIN
  SELECT  FINAL_EXPIRATION_DATE
  INTO   ld_final_expiration_date
  FROM   award_amount_info
  WHERE AWARD_id = AS_AWARD_ID
   AND AWARD_AMOUNT_INFO_ID = ( select max(a.AWARD_AMOUNT_INFO_ID)
        from AWARD_AMOUNT_INFO a
        where a.AWARD_ID = award_amount_info.AWARD_ID);

  RETURN (ld_final_expiration_date) ;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN Null ;
END;

/******************************************************************************/
FUNCTION  FN_CAC_GET_APRDATE_IN_A_SPREV(
   AS_AWARD_ID IN award_special_review.award_id%TYPE,
   as_proto_num in AWARD_SPECIAL_REVIEW.PROTOCOL_NUMBER%type)
   RETURN award_special_review.APPROVAL_DATE%TYPE IS
/******************************************************************************/
ld_approval_date award_special_review.APPROVAL_DATE%TYPE;
BEGIN
  if as_proto_num is null then
    SELECT  APPROVAL_DATE
    INTO     ld_approval_date
    FROM   award_special_review
    WHERE AWARD_id = AS_AWARD_ID
     AND PROTOCOL_NUMBER is null
     AND SPECIAL_REVIEW_CODE = 2;
  else
    SELECT  APPROVAL_DATE
    INTO     ld_approval_date
    FROM   award_special_review
    WHERE AWARD_id = AS_AWARD_ID
     AND PROTOCOL_NUMBER = trim(as_proto_num)
     AND SPECIAL_REVIEW_CODE = 2;
  end if;
    RETURN (ld_approval_date) ;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN Null ;
END;

/******************************************************************************/
FUNCTION  FN_CAC_GET_MAX_A_SPREV_NUM(
        AS_AWARD_ID IN award_special_review.award_id%TYPE )
        RETURN award_special_review.special_review_number%TYPE IS
/******************************************************************************/
li_reviewnum AWARD_SPECIAL_REVIEW.SPECIAL_REVIEW_NUMBER%type;

begin

	    select max(special_review_number)
		into  li_reviewnum
		from AWARD_SPECIAL_REVIEW
		where AWARD_SPECIAL_REVIEW.AWARD_ID = AS_AWARD_ID;

		return li_reviewnum;

exception
		when  no_data_found then
			return 0;
end;

/******************************************************************************/
FUNCTION  FN_CAC_GET_MAX_P_SPREV_NUM(
        AS_PROPOSAL_ID IN proposal_special_review.proposal_id%TYPE )
        RETURN proposal_special_review.special_review_number%TYPE IS
/******************************************************************************/
li_reviewnum PROPOSAL_SPECIAL_REVIEW.SPECIAL_REVIEW_NUMBER%type;

begin

	    select max(special_review_number)
		into  li_reviewnum
		from PROPOSAL_SPECIAL_REVIEW
		where PROPOSAL_SPECIAL_REVIEW.PROPOSAL_ID = AS_PROPOSAL_ID;

		return li_reviewnum;

exception
		when  no_data_found then
			return 0;
end;


/******************************************************************************/
FUNCTION fn_cac_get_parent_award(as_award_num in award.award_number%TYPE)
        return AWARD_HIERARCHY.PARENT_AWARD_NUMBER%TYPE is
/******************************************************************************/
ls_parent_award  AWARD_HIERARCHY.PARENT_AWARD_NUMBER%TYPE;
-- this function returns the parent award number of the source award

begin

	     SELECT  distinct AWARD_HIERARCHY.PARENT_AWARD_NUMBER
    	 INTO 	ls_parent_award
    	 FROM 	AWARD_HIERARCHY
   	     WHERE 	AWARD_HIERARCHY.AWARD_NUMBER = as_award_num;

         return ls_parent_award;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '000000-00000' ;

end;


/******************************************************************************/
FUNCTION  FN_CAC_GET_APRDATE_IN_P_SPREV(
      as_proposal_id in PROPOSAL_SPECIAL_REVIEW.PROPOSAL_ID%type,
      as_proto_num in PROPOSAL_SPECIAL_REVIEW.PROTOCOL_NUMBER%type)
      RETURN PROPOSAL_SPECIAL_REVIEW.APPROVAL_DATE%TYPE IS
/******************************************************************************/
ld_approval_date PROPOSAL_SPECIAL_REVIEW.APPROVAL_DATE%TYPE;
BEGIN
  if as_proto_num is null then
    SELECT  APPROVAL_DATE
    INTO     ld_approval_date
    FROM   PROPOSAL_SPECIAL_REVIEW
    WHERE PROPOSAL_ID = as_proposal_id
     AND PROTOCOL_NUMBER is null
     AND SPECIAL_REVIEW_CODE = 2;
  else
    SELECT  APPROVAL_DATE
    INTO     ld_approval_date
    FROM   PROPOSAL_SPECIAL_REVIEW
    WHERE PROPOSAL_ID = as_proposal_id
     AND PROTOCOL_NUMBER = trim(as_proto_num)
     AND SPECIAL_REVIEW_CODE = 2;
  end if;
    RETURN (ld_approval_date) ;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN Null ;
END;


/******************************************************************************/
FUNCTION  FN_CAC_IS_PROTONUM_IN_A_SPREV(
    as_proto_num in AWARD_SPECIAL_REVIEW.PROTOCOL_NUMBER%type,
  as_award_id in AWARD_SPECIAL_REVIEW.AWARD_ID%type)
  RETURN NUMBER IS
/******************************************************************************/
ll_count     Number;

BEGIN
    SELECT COUNT(*)
    INTO ll_count
    FROM AWARD_SPECIAL_REVIEW
    WHERE AWARD_ID = as_award_id
        AND PROTOCOL_NUMBER = trim(as_proto_num)
        AND SPECIAL_REVIEW_CODE = 2;

    IF ll_count > 0 THEN
        RETURN ll_count;
    ELSE
        RETURN 0;
    END IF;

    EXCEPTION
          WHEN NO_DATA_FOUND THEN
    RETURN 0;

END ;

/******************************************************************************/
FUNCTION  FN_CAC_IS_PROTONUM_IN_P_SPREV(
    as_proto_num in PROPOSAL_SPECIAL_REVIEW.PROTOCOL_NUMBER%type,
  as_prop_id in PROPOSAL.PROPOSAL_ID%type)
  RETURN NUMBER IS
/******************************************************************************/
ll_count     Number;

BEGIN
    SELECT COUNT(*)
    INTO ll_count
    FROM PROPOSAL_SPECIAL_REVIEW
    WHERE PROPOSAL_ID = as_prop_id
    AND PROTOCOL_NUMBER = trim(as_proto_num)
    AND SPECIAL_REVIEW_CODE = 2;

    IF ll_count > 0 THEN
        RETURN ll_count;
    ELSE
        RETURN 0;
    END IF;

    EXCEPTION
          WHEN NO_DATA_FOUND THEN
    RETURN 0;

END ;



/******************************************************************************/
FUNCTION  FN_CAC_P_ONE_PENDING_NO_PROTO(
    as_proposal_id in PROPOSAL_SPECIAL_REVIEW.PROPOSAL_ID%type)
  RETURN NUMBER IS
/******************************************************************************/
ll_count     Number;

BEGIN
    SELECT COUNT(*)
    INTO ll_count
    FROM PROPOSAL_SPECIAL_REVIEW
    WHERE PROPOSAL_ID = as_proposal_id
    AND SPECIAL_REVIEW_CODE = 2 and (APPROVAL_TYPE_CODE = 1 or APPROVAL_TYPE_CODE = 6 );


    IF ll_count = 1 THEN
    SELECT COUNT(*)
    INTO ll_count
    FROM PROPOSAL_SPECIAL_REVIEW
    WHERE PROPOSAL_ID = as_proposal_id
    AND SPECIAL_REVIEW_CODE = 2 and (APPROVAL_TYPE_CODE = 1 or APPROVAL_TYPE_CODE = 6 )
    AND (PROTOCOL_NUMBER is null or trim(PROTOCOL_NUMBER) = '');

    if ll_count = 1 then
      return 1;
    else
      return 2;
    end if;

    ELSE
        RETURN ll_count;
    END IF;

    EXCEPTION
          WHEN NO_DATA_FOUND THEN
    RETURN 0;

END ;

/******************************************************************************/
FUNCTION  fn_gen_cac_emails(ad_RunDate in date)
  RETURN NUMBER IS
/******************************************************************************/

mail_conn             utl_smtp.connection;
mesg                     clob;
mesg_osp                   clob;
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
tab                     varchar2(1) := chr(9);
li_number 		number := 0;

ls_recipients           varchar2(2000);
ls_PROTOCOL_NUMBER          CAC_LOG_DATA.PROTOCOL_NUMBER_CAC%TYPE ;
ls_AWARD_IP_NUMBER          CAC_LOG_DATA.AWARD_IP_NUMBER%TYPE ;
ls_WBS_IP_CAC               CAC_LOG_DATA.WBS_IP_CAC%TYPE ;
ls_COMMENTS                 CAC_LOG_DATA.COMMENTS%TYPE ;
ls_APPROVAL_DATE_CAC        CAC_LOG_DATA.APPROVAL_DATE_CAC%TYPE ;


ll_MAIL_SENT_STATUS    varchar2(8);
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   clob;
mail_message_in_table   clob;
mail_message_osp  clob;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
li_notification_type_id notification_type.notification_type_id% type := null;
li_notification_is_active pls_integer;

cursor cur_cac_email is
        select PROTOCOL_NUMBER_CAC, AWARD_IP_NUMBER,WBS_IP_CAC,COMMENTS
        from CAC_LOG_DATA
        where LOG_NOTE = 'CAC' and TRUNC(UPDATE_TIMESTAMP) = TRUNC(ad_RunDate)
        order by LOG_INDICATOR;

cursor cur_osp_email is
        select PROTOCOL_NUMBER_CAC, AWARD_IP_NUMBER,WBS_IP_CAC,COMMENTS,APPROVAL_DATE_CAC
        from CAC_LOG_DATA
        where LOG_NOTE = 'OSP' and TRUNC(UPDATE_TIMESTAMP) = TRUNC(ad_RunDate)
        order by LOG_INDICATOR;

BEGIN
      li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,200,'501');
	  if li_notification_is_active = 1 then
		open cur_cac_email;
			mesg := '';
			loop
			FETCH cur_cac_email INTO  ls_PROTOCOL_NUMBER, ls_AWARD_IP_NUMBER,ls_WBS_IP_CAC, ls_COMMENTS;
			EXIT WHEN cur_cac_email%NOTFOUND;
			mesg := mesg || '<tr>
					<td>' || ls_PROTOCOL_NUMBER || '</td>
					<td>' || ls_WBS_IP_CAC || '</td>
					<td>' || ls_COMMENTS || '</td>
				   </tr>';
			end loop;
	   close cur_cac_email;

       ls_recipients := 'CACPO@mit.edu ' ;
       ll_MAIL_SENT_STATUS := 'Y';
       -- sending email start
		begin
			 KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,200,'501',mail_subject,mail_message_in_table);
             --mail_message := replace(mail_message_in_table, '{list}',mesg );
             li_number := instr(mail_message_in_table,'{list}');
             mail_message := RPAD(mail_message_in_table,li_number-1);
             mail_message := mail_message || mesg || substr(mail_message_in_table , li_number+6);


             KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_recipients,null,NULL,mail_subject,mail_message);
		exception
		when others then
			ll_MAIL_SENT_STATUS := 'N';

		end;
		-- sending email end

        begin
			select NOTIFICATION_TYPE_ID into li_notification_type_id
			from NOTIFICATION_TYPE
			where MODULE_CODE = 200
			and ACTION_CODE		= '501';

		exception
		when others then
		li_notification_type_id := null;
		end;

        -- inserting into KC tables START
	    li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'CAC',mail_message);
        begin
            if li_ntfctn_id <>  -1 then
                KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,substr(ls_recipients, 1, INSTR(ls_recipients, '@')-1),ll_MAIL_SENT_STATUS);
            end if;
        exception
	    when others then
		NULL;
        end;

    end if;

--second email
      li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,200,'502');
	  if li_notification_is_active = 1 then

	   open cur_osp_email;
		mesg_osp := '';
        loop
        FETCH cur_osp_email INTO  ls_PROTOCOL_NUMBER, ls_AWARD_IP_NUMBER,ls_WBS_IP_CAC, ls_COMMENTS, ls_APPROVAL_DATE_CAC;
        EXIT WHEN cur_osp_email%NOTFOUND;
        mesg_osp := mesg_osp || '<tr>
                <td>' || ls_PROTOCOL_NUMBER || '</td>
                <td>' || ls_AWARD_IP_NUMBER || '</td>
                <td>' || ls_WBS_IP_CAC || '</td>
                <td>' || ls_COMMENTS || '</td>
                <td>' || ls_APPROVAL_DATE_CAC || '</td>
               </tr>';
        end loop;
		close cur_osp_email;
       ls_recipients := 'coeus-data@mit.edu' ;
       ll_MAIL_SENT_STATUS := 'Y';
       li_notification_type_id := null;
       -- sending email start
		begin
			 KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,200,'502',mail_subject,mail_message_in_table);
             --mail_message := replace(mail_message_in_table, '{list}',mesg_osp );
             li_number := instr(mail_message_in_table,'{list}');
			 mail_message := RPAD(mail_message_in_table,li_number-1);
             mail_message := mail_message || mesg_osp || substr(mail_message_in_table , li_number+6);

             KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_recipients,null,NULL,mail_subject,mail_message);
		exception
		when others then
			ll_MAIL_SENT_STATUS := 'N';

		end;
		-- sending email end

        begin
			select NOTIFICATION_TYPE_ID into li_notification_type_id
			from NOTIFICATION_TYPE
			where MODULE_CODE = 200
			and ACTION_CODE		= '502';

		exception
		when others then
		li_notification_type_id := null;
		end;

        -- inserting into KC tables START
	    li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'CAC',mail_message);
        begin
            if li_ntfctn_id <>  -1 then
                KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,substr(ls_recipients, 1, INSTR(ls_recipients, '@')-1),ll_MAIL_SENT_STATUS);
            end if;
        exception
	    when others then
		NULL;
        end;

	end if;

    return 1;

END;

/******************************************************************************/
FUNCTION  fn_gen_no_data_email
  RETURN NUMBER IS
/******************************************************************************/

mail_conn             utl_smtp.connection;
mesg                     VARCHAR2( 6000 );
crlf                     VARCHAR2( 2 ) := CHR( 13 ) || CHR( 10 );
tab                     varchar2(1) := chr(9);
ls_recipients           varchar2(2000);

ll_MAIL_SENT_STATUS    varchar2(8);
mail_subject   NOTIFICATION_TYPE.SUBJECT%TYPE;
mail_message   NOTIFICATION_TYPE.MESSAGE%TYPE ;
li_ntfctn_id   KREN_NTFCTN_T.NTFCTN_ID%TYPE;
li_notification_type_id notification_type.notification_type_id% type := null;
li_notification_is_active  PLS_INTEGER;

BEGIN

   ls_recipients := 'coeus-data@mit.edu' ;
   ll_MAIL_SENT_STATUS := 'Y';

        -- sending email start
	  li_notification_is_active := KC_MAIL_GENERIC_PKG.FN_NOTIFICATION_IS_ACTIVE(null,200,'503');
	  if li_notification_is_active = 1 then

		begin
			 KC_MAIL_GENERIC_PKG.GET_NOTIFICATION_TYP_DETS(li_notification_type_id,200,'503',mail_subject,mail_message);
			 KC_MAIL_GENERIC_PKG.SEND_MAIL(li_notification_type_id,ls_recipients,null,NULL,mail_subject,mail_message);
		exception
		when others then
			ll_MAIL_SENT_STATUS := 'N';

		end;
		-- sending email end

        begin
			select NOTIFICATION_TYPE_ID into li_notification_type_id
			from NOTIFICATION_TYPE
			where MODULE_CODE = 200
			and ACTION_CODE		= '503';

		exception
		when others then
		li_notification_type_id := null;
		end;

        -- inserting into KC tables START
	    li_ntfctn_id := KC_MAIL_GENERIC_PKG.FN_INSERT_KREN_NTFCTN(li_notification_type_id,'CAC',mail_message);
        begin
            if li_ntfctn_id <>  -1 then
                KC_MAIL_GENERIC_PKG.FN_INSRT_KREN_NTFCTN_MSG_DELIV(li_notification_type_id,li_ntfctn_id,substr(ls_recipients, 1, INSTR(ls_recipients, '@')-1),ll_MAIL_SENT_STATUS);
            end if;
        exception
	    when others then
		NULL;
        end;

	end if;

    return 1;

    EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20101, 'Error Generating Email. ' || SQLERRM
      );
        return 1;
END;
end;
/
