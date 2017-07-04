grammar miserable_graphing;

@header {
   import java.util.Stack;
}

@parser::members {
   int node_count = 0;
   String vizgraph_string = "";

   int GetId() {
      return node_count++;
   }

   int PrintNode (String label) {
      int id = GetId();
      vizgraph_string += (id + " [label=\"" + label + "\"]\n");
      return id;
   }
   void PrintEdge (int id1, int id2) {
      if ( id1 >= 0 && id2 >= 0 )
         vizgraph_string += (id1 + " -> " + id2 + "\n");
   }
   void PrintEdges (int id, Stack<Integer> s) {
      while( ! s.empty() )
         PrintEdge(id, s.pop());
   }

   void PrintGraph () {
      System.out.println("digraph G {\nordering=out\n" + vizgraph_string + "}");
   }
}

// Production Rules
// ----------------

prog
: expr
{
   PrintGraph();
}
;

expr returns [int id]
: call
{
   $id = $call.id;
}
| definition e2=expr
{
   $id = PrintNode("Expr w/ Def");
   PrintEdge($id, $definition.id);
   PrintEdge($id, $e2.id);
}
| Number
{
   $id = PrintNode($Number.text);
}
| Parameter
{
   $id = PrintNode($Parameter.text);
}
| ParentParameter
{
   $id = PrintNode($ParentParameter.text);
}
;

exprs returns [Stack<Integer> s]
: expr e2=exprs
{
   $s = $e2.s;
   $s.push(new Integer($expr.id));
}
|
{
   $s = new Stack<Integer>();
}
;

call returns [int id]
: Label exprs SemiColon
{
   $id = PrintNode($Label.text);
   while( ! $exprs.s.empty() )
      PrintEdge($id, $exprs.s.pop());
}
;

definition returns [int id]
: Exclamation Label expr
{
   $id = PrintNode($Exclamation.text);
   PrintEdge($id, PrintNode($Label.text));
   PrintEdge($id, $expr.id);
}
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

