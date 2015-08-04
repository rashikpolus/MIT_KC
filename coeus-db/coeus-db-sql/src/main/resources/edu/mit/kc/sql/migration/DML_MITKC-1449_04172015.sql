update award_budget_ext set award_budget_status_code = 14 --Cancelled
where budget_id in ( select budget_id from budget 
                     where document_number in ( '1173048','1170585','1161252','1154892','1146289','1154154','1175245' )
                    )
and award_budget_status_code <> 14
/
commit
/
