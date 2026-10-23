; extends

; The grammar queries tag calls and definitions the same way. Tag calls
; separately so the minimal themes can leave them uncolored. typescript and tsx
; inherit this.
(call_expression
  function: (identifier) @function.call)

(call_expression
  function: (member_expression
    property: (property_identifier) @function.method.call))
