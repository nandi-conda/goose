(function_declaration
  body: (block
    "{"
    (_)* @function.inside
    "}")) @function.around

(extern_member) @function.around

(function_value) @function.around

(struct_declaration
  body: (field_declaration_list
    "{"
    (_)* @class.inside
    "}")) @class.around

(enum_declaration) @class.around

[
  (line_comment)
  (block_comment)
]+ @comment.around
