lexer grammar miserable;

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
Number
: [0-9]+
;
Label
: [a-zA-Z]+
| '++'
| '~&&'
| '$'
;

