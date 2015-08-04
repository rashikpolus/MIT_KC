create or replace
function fn_kc_deactivate_inst_prop
return varchar2 is
li_ret          number;
li_year         number;
li_FYyear       number;
li_CalMonth     number;
li_FYMonth      number;
ls_YearandMonth varchar2(4);
ldt_Today       date;
ls_Return       varchar2(10);

BEGIN
    
    ldt_Today := sysdate;    
	
    --Delete all rows .
    delete from temp_deactivated_ip;
	
    li_year := to_number(extract(year from ldt_Today));    
    
    li_CalMonth := to_number(extract(month from ldt_Today));
    
    if li_CalMonth >= 1 and li_CalMonth <= 7 then
    li_FYyear := li_year - 1;
    else
    li_FYyear := li_year;
    end if;
    
    --Calculate the Fiscal month's proposal to deactivate based on current calendar month
    case li_CalMonth
    
    when 1 then li_FYMonth := 7;
    when 2 then li_FYMonth := 8;
    when 3 then li_FYMonth := 9;
    when 4 then li_FYMonth := 10;
    when 5 then li_FYMonth := 11;
    when 6 then li_FYMonth := 12;
    when 7 then li_FYMonth := 1;
    when 8 then li_FYMonth := 2;
    when 9 then li_FYMonth := 3;
    when 10 then li_FYMonth := 4;
    when 11 then li_FYMonth := 5;
    when 12 then li_FYMonth := 6;
    
    end case;
    
    ls_YearandMonth := trim(substr(li_FYyear, 3, 2)) || trim(to_char(li_FYMonth, '00'));
	
    INSERT INTO TEMP_DEACTIVATED_IP
    SELECT proposal_number, sequence_number, status_code, sponsor_code, title, ldt_Today as "Deactivate_date"
    FROM PROPOSAL
    WHERE substr(PROPOSAL_NUMBER,1, 4) = ls_YearandMonth
	AND STATUS_CODE = 1 
	AND SEQUENCE_NUMBER = ( SELECT MAX(A.SEQUENCE_NUMBER) FROM PROPOSAL A
    WHERE PROPOSAL.PROPOSAL_NUMBER = A.PROPOSAL_NUMBER);
	
    update PROPOSAL
    set status_code = 4 
    WHERE substr(PROPOSAL_NUMBER,1, 4) = ls_YearandMonth 
    AND STATUS_CODE = 1
    AND SEQUENCE_NUMBER = ( SELECT MAX(A.SEQUENCE_NUMBER) FROM PROPOSAL A
    WHERE PROPOSAL.PROPOSAL_NUMBER = A.PROPOSAL_NUMBER);
    
    commit;
    
    ls_return := to_char(ldt_Today, 'MM-DD-YYYY');
    
    return ls_return;

END;  
/
