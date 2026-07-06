; extends

(assignment_statement
  (identifier) @local.definition.var)

(member_expression
  (identifier)
  (call_expression
    function: (identifier)
  )
) @local.definition.function

(member_expression
  (identifier)
  (identifier) @local.definition.constant
)

(switch_case
  condition: (member_expression
    (identifier)
    (identifier) @local.definition.constant
  )
)
(switch_case
  condition: (member_expression
    (identifier) @local.definition.constant
  )
)
