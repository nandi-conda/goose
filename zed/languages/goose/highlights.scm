; Goose highlighting for Zed, adapted from the upstream tree-sitter query. Later patterns win where two
; cover the same bytes, so the broad rules come first.

(identifier) @variable

; The implicit parameter of a function value without a parameter list.
((identifier) @variable.special
 (#eq? @variable.special "it"))

(parameter name: (identifier) @variable.parameter)
(function_value_parameter name: (identifier) @variable.parameter)

(field_declaration name: (identifier) @property)
(field_expression field: (identifier) @property)
(field_initializer name: (identifier) @property)

(namespace_declaration name: (identifier) @namespace)
(import_path (identifier) @namespace)
(scoped_identifier namespace: (identifier) @namespace)

(function_declaration name: (identifier) @function)
(function_declaration name: (scoped_identifier name: (identifier) @function))
(call_expression function: (identifier) @function.call)
(call_expression function: (scoped_identifier name: (identifier) @function.call))
; A call through a dot is a method call or a call of a free function by UFCS.
(call_expression function: (field_expression field: (identifier) @function.method))
(return_expression target: (identifier) @function)
(return_expression target: (scoped_identifier name: (identifier) @function))

(struct_declaration name: (identifier) @type)
(struct_declaration name: (scoped_identifier name: (identifier) @type))
(enum_declaration name: (identifier) @type)
(enum_declaration name: (scoped_identifier name: (identifier) @type))
(type_alias_declaration name: (identifier) @type)
(type_alias_declaration name: (scoped_identifier name: (identifier) @type))
(type_parameter name: (identifier) @type)
(named_type name: (identifier) @type)
(named_type name: (scoped_identifier name: (identifier) @type))
(struct_literal name: (identifier) @type)
(struct_literal name: (scoped_identifier name: (identifier) @type))
(primitive_type) @type.builtin

(enum_variant name: (identifier) @constant)
(variant_type variant: (identifier) @constant)
(struct_literal variant: (identifier) @constant)
(variant_pattern variant: (identifier) @constant)
(pattern_list (identifier) @constant)
(range_pattern (identifier) @constant)
(negative_pattern (identifier) @constant)

; A payload-less variant: Shape.Dot. Types and variants are PascalCase by
; convention, which separates them from a field read.
((field_expression value: (identifier) @type field: (identifier) @constant)
 (#match? @type "^[A-Z]")
 (#match? @constant "^[A-Z]"))

(wildcard_pattern) @variable.special
(self) @variable.special

(function_modifier) @keyword

[
  "fn"
  "thread_fn"
  "struct"
  "enum"
  "type"
  "let"
  "var"
  "const"
  "pad"
  "reusable"
  "namespace"
  "block"
  "fields"
  "variants"
  "types"
  "in"
  "upto"
] @keyword

"as" @keyword

[
  "import"
  "from"
] @keyword

"return" @keyword

[
  "if"
  "else"
  "match"
  "guard"
] @keyword

[
  "while"
  "for"
  "loop"
  "break"
  (continue_expression)
] @keyword

(boolean_literal) @boolean
(null) @constant.builtin
(int_literal) @number
(float_literal) @number
(char_literal) @string.special
(string_literal) @string
(raw_string_literal) @string
(escape_sequence) @string.escape

[
  "=" ".="
  "+" "-" "*" "/" "%"
  "==" "!=" ".==" ".!=" "<" "<=" ">" ">="
  "&&" "||" "!"
  "&" "|" "^" "~" "<<" ">>"
  "+=" "-=" "*=" "/=" "%="
  "&=" "|=" "^=" "<<=" ">>="
  "++" "--"
  "->" "=>"
  ".."
  "?"
] @operator

[
  "(" ")" "[" "]" "{" "}"
] @punctuation.bracket

[
  "," ";" ":" "::" "."
] @punctuation.delimiter

(line_comment) @comment
(block_comment) @comment
