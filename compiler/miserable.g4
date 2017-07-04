grammar miserable;


// Production Rules
// ----------------

prog
: expr
;

expr
: call
| definition expr
| Number
| Parameter
| ParentParameter
;

exprs
: expr exprs
|
;

call
: Label exprs SemiColon
;

definition
: Exclamation Label expr
;


// Token Classes
// -------------

WhiteSpace
: [ \t\n\r]+ -> skip
;
SemiColon
: ';'
;
Exclamation
: '!'
;
Parameter
: '_'
;
ParentParameter
: '_^'
;
Number
: [0-9]+
;
Label
: [a-zA-Z]+
| '++'
| '~&&'
| '$'
;

