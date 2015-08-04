create or replace
function fn_check_coi_hierarchy
  (as_award in AWARD.AWARD_NUMBER%TYPE )
return number is
/* check if sponsor or prime sponsor are in coi hierarchy
return -1 if not in hierarchy
return 1 if in no key persons hierarchy (kp do not need to do coi)
return 2 if in key persons hierarchy (kp need to do coi)
*/

ls_Sponsor  AWARD.SPONSOR_CODE%type;
ls_primesponsor AWARD.PRIME_SPONSOR_CODE%type;
li_count_nokp number;
li_count_kp   number;

begin

   begin

        select sponsor_code
        into ls_Sponsor
        from award
            where award_number = as_award
             and sequence_number = (select max(a.sequence_number)
                  from award a
                  where award.award_number = a.award_number);
    exception
        when others then
            raise_application_error(-20100, 'Error retrieveing sponsor code for award ' || as_award || ' ' ||
                                            SQLERRM);
            return -1;
    end;


    begin

        select PRIME_SPONSOR_CODE
        into ls_PrimeSponsor
        from award
            where award_number = as_award
             and sequence_number = (select max(a.sequence_number)
                  from award a
                  where award.award_number = a.award_number);
    exception
        when others then
            raise_application_error(-20100, 'Error retrieveing prime sponsor code for award ' || as_award || ' ' ||
                                            SQLERRM);
            return -1;
    end;

    SELECT COUNT(*)
     INTO   li_count_nokp
     FROM   SPONSOR_HIERARCHY
     where  hierarchy_name = 'COI Disclosures'
     and    sponsor_code IN ( ls_sponsor, ls_PrimeSponsor)
     and    upper(trim(level1) ) =  'COI DISCLOSURES NO KP';


     SELECT COUNT(*)
     INTO   li_count_kp
     FROM   SPONSOR_HIERARCHY
     where  hierarchy_name = 'COI Disclosures'
     and    sponsor_code IN ( ls_sponsor, ls_PrimeSponsor)
     and    upper(trim(level1) ) =   'COI DISCLOSURES WITH KP REQ' ;

     if (li_count_kp > 0) then
       return 2;
     elsif (li_count_nokp > 0) then
       return 1;
     else
       return -1;
     end if;

     end;
/