# miserable
A computer language I am writing which is intended to be infuriating to use.

The compiler will all be implemented via the Antlr4 tool.
I don't know much about it so I will probably miss some powerful aspects of antlr and instead use it in a barbaric manner. Sorry.
Even though the language is intentionally horrible, I'd like the compiler to be decent.

### Design Choices

#### 1. *Minimalistic* in most ways.
Short Circuit NAND is enough to implement logic and conditionals.

#### 2. Require terrible *taboo programming techniques*
Overflow is necessary to define subtraction.

#### 3. *Implicit* always beats Explicit.
No hand holding! There will not be any brackets which can be infered.
The programmer should be responsible to know exactly how the language works and how their code will run.

#### 4. *Inefficient* code writing is fine
Enforce thousands or millions of increments to do addition, but optimize the heck out of that in the compiler.

#### 5. *Unfriendly* syntax
Just look below where I have attached a code snippit.

### Code Form

Each file has one expression.
That expression evaluates to will be outputted at runtime.
Any number of definitions can be defined also, either internal or external to the expression.
File names can be called as functions.
Definitions are _DYNAMICLY SCOPED_ and shared between files.

### Code Snippet Examples

```
! factorial ~| ?0 _ 1 * n factorial - _ 1 / defines a factorial method /
! pi 314 ! circle * * pi _ _ circle 5 / calculates area of a circle with size 5, times 100. /
```

### Grammar

The above language poses problems for creating a grammar, so I will first run a precompiler to add delimiters. It will create the form:
```
! factorial ~| ?0 _ ; 1 * n factorial - _ 1 ; ; ; ;
! pi 314 ; ! circle * * pi _ ; _ ; circle 5 ;
```
This form will make creating a parse tree very convenient

The production rules look as follows, with expr at the top level:

```
expr
  -> definition expr
  -> call
  -> number
  -> "_"
exprs
  -> expr exprs
  -> <epsilon>
definition
  -> "!" label expr
call
  -> label exprs ";"
number
  -> number digit
  -> digit
digit
  -> "0" | "1" | ... | "9"
label
  -> word
  -> provided_function
word
  -> word letter
  -> letter
letter
  -> "a" | "b" | ... | "z" | "A" | "B" | ... | "Z"
provided_function
  -> "++"
  -> "~&&"
  -> "$"
```

### Special forms
```
label exprs ";" = function call
"!" label expr  = function definition
"_"             = input parameter in a function definition
```

### Provided functions
```
++ <x>      = <x> incremented by 1
~&& <x> <y> = nand of <x> and <y>'s last bits. short-circuits if <x> is false
$ <x>       = prints <x>
```

### Extended set
I may later release a version with these defined. Most you can define yourself.
If you're interested, these are all aliassed in the precompiler.
You can write functions with the aliased names then use the symbols.
The aliasses are all listed below this section.
#### Logic
```
~~  <p>      = not of <x>'s last bit
&&  <p> <q>  = and of <x> and <y>'s last bits. short-circuits if <x> is false
~|| <p> <q>  = nor of <x> and <y>'s last bits. short-circuits if <x> is true
||  <p> <q>  = or of <x> and <y>'s last bits. short-circuits if <x> is true
~|  <p> <q>  = nor of <x> and <y> bitwise.
|   <p> <q>  = or of <x> and <y> bitwise.
~&  <p> <q>  = nand of <x> and <y> bitwise
&   <p> <q>  = and of <x> and <y> bitwise
~   <p>      = not of <x> bitwise.
```
#### Arithmetic
```
-- <x>       = <x> decremented by 1
+ <x> <y>    = <y> added to <x>
- <x> <y>    = <y> subtracted from <x>
* <x> <y>    = <x> and <y> multiplied
/ <x> <y>    = <x> divided by <y>. remainder ignored.
% <x> <y>    = the remainder from <x> divided by <y>.
```
#### Tests/Conditionals
```
?0  <num>         <1> <2> = if <num> is equal to 0,    return <1> else <2>
?t  <bool>        <1> <2> = if <bool>'s last bit is 1, return <1> else <2>
?f  <bool>        <1> <2> = if <bool>'s last bit is 0, return <1> else <2>
?=  <val1> <val2> <1> <2> = if val1 is equal to val2,  return <1> else <2>
?<  <val1> <val2> <1> <2> = if val1 is less than val2, return <1> else <2>
?>  <val1> <val2> <1> <2> = if val1 is more than val2, return <1> else <2>
?<= <val1> <val2> <1> <2> = if val2 is more than val1, return <1> else <2>
?>= <val1> <val2> <1> <2> = if val2 is less than val1, return <1> else <2>
```
#### Prints
```
$A <expr> = print ascii only
$D <expr> = print decimal number only
$H <expr> = print hex number only
$B <expr> = print bool value only
```

### Aliasses
```
~~  extset0not
&&  extset0and
~|| extset0nor
||  extset0or
~|  extset0norBitwise
|   extset0orBitwise
~&  extset0nandBitwise
&   extset0andBitwise
~   extset0notBitwise
--  extset0dec
+   extset0add
-   extset0sub
*   extset0mult
/   extset0div
%   extset0mod
?0  extset0testZero
?t  extset0testTrue
?f  extset0testFalse
?=  extset0testEqual
?<  extset0testLT
?>  extset0testMT
?<= extset0testLTE
?>= extset0testMTE
$A  <no alias, maybe I'll implement it later>
$D  <no alias, maybe I'll implement it later>
$H  <no alias, maybe I'll implement it later>
$B  <no alias, maybe I'll implement it later>
```
