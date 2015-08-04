update protocol_actions
set comments = trim(substr(comments,13))
where protocol_action_id in (
    select protocol_action_id
    from protocol_actions where length(protocol_number) > 10
    and substr(protocol_number,11,1) = 'R'
    and comments is not null
    and instr(comments,'Renewal-') > 0
)
/
update protocol_actions
set comments = trim(substr(comments,15))
where protocol_action_id in (
  select protocol_action_id
  from protocol_actions where length(protocol_number) > 10
  and substr(protocol_number,11,1) = 'A'
  and comments is not null
  and instr(comments,'Amendment-') > 0
)
/
