CREATE OR REPLACE TRIGGER T_AWD_APPR_SUB_BFR_IN_ROW 
before insert on AWARD_APPROVED_SUBAWARDS for each row

declare


ls_AwardNumber      VARCHAR2(12 BYTE);
ls_Sequence         NUMBER(4,0);
ls_SubName          VARCHAR2(60 BYTE);
ll_Amt              NUMBER(12,2);
ll_OldAmt           NUMBER(12,2);

li_rc 				number;
li_Count            number;


begin

    ls_AwardNumber      := :new.AWARD_NUMBER;
    ls_Sequence         := :new.SEQUENCE_NUMBER;
    ls_SubName          := :new.ORGANIZATION_NAME;
    ll_Amt              := :new.AMOUNT;


    --check if the Sub that is being added in not in any prior sequence
    select count(AWARD_NUMBER)
    into li_Count
    from AWARD_APPROVED_SUBAWARDS
    where AWARD_NUMBER = ls_AwardNumber
    and ORGANIZATION_NAME  = ls_SubName
    and  SEQUENCE_NUMBER < ls_Sequence;
    
    if li_Count = 0 then
        li_rc := kc_sub_notifications_pkg.fn_gen_sub_award_notifications(ls_AwardNumber, ls_SubName, ll_Amt, 1);
    else
        begin
		
			SELECT AMOUNT
            into ll_OldAmt           
			from AWARD_APPROVED_SUBAWARDS 
			WHERE AWARD_APPROVED_SUBAWARD_ID IN (
						   SELECT MAX(t1.award_approved_subaward_id)
						   from AWARD_APPROVED_SUBAWARDS t1
									  where t1.AWARD_NUMBER = ls_AwardNumber
									  and  t1.ORGANIZATION_NAME  = ls_SubName
									  and  t1.SEQUENCE_NUMBER = ( select max(s2.sequence_number) from AWARD_APPROVED_SUBAWARDS s2
																 where t1.AWARD_NUMBER = S2.AWARD_NUMBER
															    and S2.SEQUENCE_NUMBER <= ls_Sequence
															  )
												);
        exception
            when others then
                ll_OldAmt := 0;
        end;
        
        if ll_OldAmt is null then
             ll_OldAmt := 0;
        end if;
        
       if ll_Amt <> ll_OldAmt then
         li_rc := kc_sub_notifications_pkg.fn_gen_sub_award_notifications(ls_AwardNumber, ls_SubName, ll_Amt, 2);
       end if;
        
    end if;


exception
	when others then
		raise_application_error(-20100, 'Error generating Subcontract notifications' || SQLERRM);

end;
/