lexer grammar miserable;

@header {
package compiler;
}

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

