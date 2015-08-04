create or replace function fn_coi_prop_transition (
    as_dev_proposal_num IN OSP$EPS_PROPOSAL.PROPOSAL_NUMBER@COEUS.KUALI%TYPE,
    as_inst_prop_num IN OSP$PROPOSAL.PROPOSAL_NUMBER@COEUS.KUALI%TYPE
    )
    return number
    is
    ls_disclosure OSP$COI_DISCLOSURE.COI_DISCLOSURE_NUMBER@COEUS.KUALI%type;
    li_sequence NUMBER;
    li_latest_seq NUMBER;
    li_disposition NUMBER;
    li_count NUMBER;
    
    cursor cur(c_dev_proposal VARCHAR2) is
    select cd.coi_disclosure_number,cd.sequence_number,cd.disclosure_disposition_code
    from osp$coi_disclosure@COEUS.KUALI cd where cd.module_item_key = c_dev_proposal;
    rec cur%rowtype;
    
    cursor cur_ip(c_inst_proposal VARCHAR2) is
    select cd.coi_disclosure_number,cd.sequence_number
    from osp$coi_disclosure@COEUS.KUALI cd where cd.module_item_key = c_inst_proposal;
    rec_ip cur_ip%rowtype;
    
    begin
    
    --COEUS-457:Resubmission issue - Introduce the status Void. 
    if cur_ip%isopen then
      close cur_ip;
    end if;
    
    open cur_ip(as_inst_prop_num);
    loop
    fetch cur_ip into rec_ip;
    exit when cur_ip%NOTFOUND;
    
      UPDATE osp$coi_disclosure@COEUS.KUALI t SET t.disclosure_disposition_code = 4 --VOID
      WHERE  t.coi_disclosure_number = rec_ip.coi_disclosure_number
      AND    t.sequence_number       = rec_ip.sequence_number;
    
    end loop;     
    close cur_ip;
    --COEUS-457:Resubmission issue - Introduce the status Void. 
    
    if cur%isopen then
      close cur;
    end if;
    
    open cur(as_dev_proposal_num);
    loop
    fetch cur into rec;
    exit when cur%NOTFOUND;
    ls_disclosure:=rec.coi_disclosure_number;
    li_sequence:=rec.sequence_number;
    li_disposition:=rec.disclosure_disposition_code;

      if li_disposition = 1 then -- APPROVED
         select sequence_number into li_latest_seq from osp$coi_disclosure@COEUS.KUALI where coi_disclosure_number = ls_disclosure
         and update_timestamp in (select max(update_timestamp) from osp$coi_disclosure@COEUS.KUALI where COI_DISCLOSURE_NUMBER = ls_disclosure
                   and DISCLOSURE_DISPOSITION_CODE = 1);
          if li_latest_seq = li_sequence then

           update OSP$COI_DISCLOSURE@COEUS.KUALI set module_item_key = as_inst_prop_num where COI_DISCLOSURE_NUMBER = ls_disclosure and
           module_item_key = as_dev_proposal_num;

           update OSP$COI_DISC_DETAILS@COEUS.KUALI set module_item_key = as_inst_prop_num,module_code = 2 where COI_DISCLOSURE_NUMBER = ls_disclosure and
           module_item_key = as_dev_proposal_num;

          else

           update OSP$COI_DISC_DETAILS@COEUS.KUALI set module_item_key = as_inst_prop_num,module_code = 2 where COI_DISCLOSURE_NUMBER = ls_disclosure and
           module_item_key = as_dev_proposal_num;

          end if;
      else
           update OSP$COI_DISCLOSURE@COEUS.KUALI set module_item_key = as_inst_prop_num where COI_DISCLOSURE_NUMBER = ls_disclosure and
           module_item_key = as_dev_proposal_num;

           update OSP$COI_DISC_DETAILS@COEUS.KUALI set module_item_key = as_inst_prop_num,module_code = 2 where COI_DISCLOSURE_NUMBER = ls_disclosure and
           module_item_key = as_dev_proposal_num;
      end if;
      
     end loop;
     
    close cur;
    return 1;
    end;
/